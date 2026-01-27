local M = {}

local leading_whitespace_pattern = '^%s+'
local trailing_whitespace_pattern = '%s+$'

--- Get leading whitespaces.
--- @param text string
--- @return string
M.get_leading_whitespace = function(text)
  local leading_whitespace = string.match(text, leading_whitespace_pattern)

  return leading_whitespace or ''
end

--- Get trailing whitespaces.
--- @param text string
--- @return string
M.get_trailing_whitespace = function(text)
  local trailing_whitespace = string.match(text, trailing_whitespace_pattern)

  return trailing_whitespace or ''
end

--- Split by translated delimiter.
--- @param text string
--- @param translated_delimiter string
--- @return string[] matches
M.split_by_delimiter = function(text, translated_delimiter)
  local matches = {}

  -- Handle empty string case.
  if text == '' then
    return { '' }
  end

  -- Split using a different approach that preserves empty segments.
  local start = 1
  local delimiter_pos = string.find(text, translated_delimiter, start, true)

  while delimiter_pos do
    -- Add the segment before the delimiter (can be empty).
    table.insert(matches, string.sub(text, start, delimiter_pos - 1))
    start = delimiter_pos + string.len(translated_delimiter)
    delimiter_pos = string.find(text, translated_delimiter, start, true)
  end

  -- Add the final segment after the last delimiter (can be empty).
  table.insert(matches, string.sub(text, start))

  return matches
end

--- Parse options provided via bang and/or arguments.
--- @param bang string
--- @param arguments string
--- @return SortOptions options
M.parse_arguments = function(bang, arguments)
  local delimiter_pattern = '[st%p]'
  local numerical_pattern = '[bnox]'
  local options = {}

  options.delimiter = string.match(arguments, delimiter_pattern)

  local numerical = string.match(arguments, numerical_pattern)
  if numerical == 'b' then
    options.numerical = 2
  elseif numerical == 'o' then
    options.numerical = 8
  elseif numerical == 'x' then
    options.numerical = 16
  elseif numerical == 'n' then
    options.numerical = 10
  else
    options.numerical = false
  end

  options.ignore_case = string.match(arguments, 'i') ~= nil
  options.reverse = bang == '!'
  options.unique = string.match(arguments, 'u') ~= nil
  options.natural = string.match(arguments, 'z') ~= nil

  return options
end

--- Parse numbers from string.
--- @param text string
--- @param base? integer
--- @return integer | nil
M.parse_number = function(text, base)
  base = base or 10

  -- Define patterns for different number bases.
  local patterns = {
    [2] = '%-?[01]+',
    [8] = '%-?[0-7]+',
    [10] = '%-?[%d.]+',
    [16] = '%-?0[xX]%x+',
  }

  local match = string.match(text, patterns[base] or patterns[10])

  -- For hexadecimal, also try pattern without 0x prefix.
  if base == 16 and not match then
    match = string.match(text, '%-?%x+')
  end

  return tonumber(match or '', base ~= 10 and base or nil)
end

--- Translate delimiter values to proper characters.
--- @param delimiter string
--- @return string translated_delimiter
M.translate_delimiter = function(delimiter)
  local translate_map = {
    t = '\t',
    s = ' ',
  }

  return translate_map[delimiter] or delimiter
end

--- Trim leading and trailing whitespaces.
--- @param text string
--- @return string
M.trim_leading_and_trailing_whitespace = function(text)
  text = string.gsub(text, leading_whitespace_pattern, '')
  text = string.gsub(text, trailing_whitespace_pattern, '')

  return text
end

--- Detect the dominant whitespace pattern from a list of whitespace strings.
--- @param whitespace_list string[]
--- @param alignment_threshold number
--- @param delimiter? string The delimiter being used (for context-aware decisions)
--- @return string dominant_pattern
M.detect_dominant_whitespace = function(
  whitespace_list,
  alignment_threshold,
  delimiter
)
  local pattern_count = {}

  -- Count occurrences of each whitespace pattern.
  for _, ws in ipairs(whitespace_list) do
    if string.len(ws) < alignment_threshold then
      -- Count all patterns including empty string.
      pattern_count[ws] = (pattern_count[ws] or 0) + 1
    end
  end

  -- Find the most common non-alignment pattern.
  local dominant_pattern = ' ' -- Default to single space.
  local max_count = 0

  for pattern, count in pairs(pattern_count) do
    if count > max_count then
      max_count = count
      dominant_pattern = pattern
    end
  end

  -- Technical decision: Comma-specific whitespace normalization strategy.
  -- For CSV-like data, we apply intelligent spacing rules:
  -- 1. If input has no spaces, preserve that compact style
  -- 2. If input has mixed spacing, normalize to single space for readability
  -- This approach respects user intent while improving consistency.
  if delimiter == ',' and dominant_pattern == '' then
    local has_spaces = false
    for pattern, _ in pairs(pattern_count) do
      if pattern ~= '' then
        has_spaces = true
        break
      end
    end

    -- Only add space if there are mixed patterns.
    if has_spaces then
      dominant_pattern = ' '
    end
  elseif delimiter == ',' then
    local non_empty_pattern_count = 0
    for pattern, _ in pairs(pattern_count) do
      if pattern ~= '' then
        non_empty_pattern_count = non_empty_pattern_count + 1
      end
    end

    -- Only force single space if we have multiple different non-empty patterns.
    if non_empty_pattern_count > 1 and dominant_pattern ~= '' then
      dominant_pattern = ' '
    end
  end

  return dominant_pattern
end

--- Parse a string into natural sorting segments (text, numbers, and punctuation).
--- @param str string
--- @return table[] segments Array of {text: string, is_number: boolean, is_punctuation: boolean}
M.parse_natural_segments = function(str)
  local segments = {}
  local i = 1

  while i <= #str do
    local start = i
    local current_char = str:sub(i, i)
    local is_digit = string.match(current_char, '%d') ~= nil
    local is_letter = string.match(current_char, '%a') ~= nil
    local is_punctuation = not is_digit and not is_letter

    -- For punctuation, treat each character individually for better priority handling.
    if is_punctuation then
      local segment_text = str:sub(i, i)
      table.insert(segments, {
        text = segment_text,
        is_number = false,
        is_punctuation = true,
      })
      i = i + 1
    else
      -- Collect all characters of the same type (digit or letter).
      while i <= #str do
        local char = str:sub(i, i)
        local char_is_digit = string.match(char, '%d') ~= nil
        local char_is_letter = string.match(char, '%a') ~= nil
        local char_is_punctuation = not char_is_digit and not char_is_letter

        -- Break if character type changes.
        if
          char_is_digit ~= is_digit
          or char_is_letter ~= is_letter
          or char_is_punctuation ~= is_punctuation
        then
          break
        end
        i = i + 1
      end

      local segment_text = str:sub(start, i - 1)
      table.insert(segments, {
        text = segment_text,
        is_number = is_digit,
        is_punctuation = is_punctuation,
      })
    end
  end

  return segments
end

--- Compare two natural sorting segments.
--- @param seg_a table Segment with text, is_number, and is_punctuation fields
--- @param seg_b table Segment with text, is_number, and is_punctuation fields
--- @param ignore_case boolean Whether to ignore case for text comparison
--- @return number -1 if a < b, 0 if a == b, 1 if a > b
M.compare_natural_segments = function(seg_a, seg_b, ignore_case)
  -- Natural comparison without global type segregation.
  -- Apply special priority only for punctuation when comparing within same context.

  -- Handle number vs number comparison.
  if seg_a.is_number and seg_b.is_number then
    local num_a = tonumber(seg_a.text)
    local num_b = tonumber(seg_b.text)
    if num_a < num_b then
      return -1
    elseif num_a > num_b then
      return 1
    else
      return 0
    end
  end

  -- Handle punctuation vs non-punctuation (local priority for GitHub issue #11).
  -- This ensures punctuation sorts before text/numbers within the same base context.
  if seg_a.is_punctuation and not seg_b.is_punctuation then
    return -1
  end
  if not seg_a.is_punctuation and seg_b.is_punctuation then
    return 1
  end

  -- Both are text, punctuation, or mixed - compare as strings.
  local text_a = ignore_case and string.lower(seg_a.text) or seg_a.text
  local text_b = ignore_case and string.lower(seg_b.text) or seg_b.text

  -- Technical decision: Handle potential negative number prefixes.
  -- When both segments end with '-', they might represent negative number prefixes.
  -- We delegate to string comparison as extracting the number portion would require
  -- complex lookahead parsing. This design choice prioritizes simplicity over
  -- perfect negative number handling, which is an edge case in most sorting scenarios.
  -- Note: Potential negative number prefixes are handled by string comparison.

  if text_a < text_b then
    return -1
  elseif text_a > text_b then
    return 1
  else
    return 0
  end
end

--- Compare two strings using natural sorting algorithm.
--- @param a string First string to compare
--- @param b string Second string to compare
--- @param ignore_case boolean Whether to ignore case
--- @return boolean True if a should come before b
M.natural_compare = function(a, b, ignore_case)
  local segments_a = M.parse_natural_segments(a)
  local segments_b = M.parse_natural_segments(b)

  local max_segments = math.max(#segments_a, #segments_b)

  for i = 1, max_segments do
    local seg_a = segments_a[i]
    local seg_b = segments_b[i]

    -- Handle case where one string is shorter.
    if not seg_a then
      return true -- a is shorter, should come first
    end
    if not seg_b then
      return false -- b is shorter, should come first
    end

    -- Compare segments.
    local result = M.compare_natural_segments(seg_a, seg_b, ignore_case)
    if result ~= 0 then
      return result < 0
    end
  end

  -- If all segments are equal, use case-sensitive lexicographic comparison as tiebreaker.
  -- This ensures consistent ordering even in case-insensitive mode.
  return a < b
end

--- Normalize whitespace for a segment based on configuration.
--- @param original_whitespace string
--- @param dominant_pattern string
--- @param alignment_threshold number
--- @return string normalized_whitespace
M.normalize_whitespace = function(
  original_whitespace,
  dominant_pattern,
  alignment_threshold
)
  -- If original whitespace is significant (>= threshold), preserve it.
  if string.len(original_whitespace) >= alignment_threshold then
    return original_whitespace
  end

  -- Otherwise, use the dominant pattern.
  return dominant_pattern
end

return M
