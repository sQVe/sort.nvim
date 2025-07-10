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
  local alignment_patterns = {}

  -- Count occurrences of each whitespace pattern.
  for _, ws in ipairs(whitespace_list) do
    if string.len(ws) >= alignment_threshold then
      -- Track alignment patterns separately.
      table.insert(alignment_patterns, ws)
    else
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

  -- For comma-separated values, if the dominant pattern is empty string,
  -- only add space if there are mixed spacing patterns (not all empty).
  if delimiter == ',' and dominant_pattern == '' then
    -- Check if there are any non-empty patterns.
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
    -- For comma delimiters, prefer single space for readability only when we have
    -- multiple inconsistent non-alignment patterns that need normalization.
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

--- Parse a string into natural sorting segments (alternating text and numbers).
--- @param str string
--- @return table[] segments Array of {text: string, is_number: boolean}
M.parse_natural_segments = function(str)
  local segments = {}
  local i = 1

  while i <= #str do
    local start = i
    local current_char = str:sub(i, i)
    local is_digit = string.match(current_char, '%d') ~= nil

    -- Collect all characters of the same type (digit or non-digit).
    -- Don't treat minus as special - just group by digit vs non-digit.
    while i <= #str do
      local char = str:sub(i, i)
      local char_is_digit = string.match(char, '%d') ~= nil
      if char_is_digit ~= is_digit then
        break
      end
      i = i + 1
    end

    local segment_text = str:sub(start, i - 1)
    table.insert(segments, {
      text = segment_text,
      is_number = is_digit,
    })
  end

  return segments
end

--- Compare two natural sorting segments.
--- @param seg_a table Segment with text and is_number fields
--- @param seg_b table Segment with text and is_number fields
--- @param ignore_case boolean Whether to ignore case for text comparison
--- @return number -1 if a < b, 0 if a == b, 1 if a > b
M.compare_natural_segments = function(seg_a, seg_b, ignore_case)
  if seg_a.is_number and seg_b.is_number then
    -- Both are numbers - compare numerically.
    local num_a = tonumber(seg_a.text)
    local num_b = tonumber(seg_b.text)
    if num_a < num_b then
      return -1
    elseif num_a > num_b then
      return 1
    else
      return 0
    end
  else
    -- At least one is text - compare as strings.
    local text_a = ignore_case and string.lower(seg_a.text) or seg_a.text
    local text_b = ignore_case and string.lower(seg_b.text) or seg_b.text

    -- Special case: if both text segments end with minus and are followed by number segments,
    -- treat this as negative number comparison.
    if
      not seg_a.is_number
      and not seg_b.is_number
      and string.sub(text_a, -1) == '-'
      and string.sub(text_b, -1) == '-'
    then
      -- This suggests they might be negative number prefixes.
      -- We'll let the normal string comparison handle this, but the caller
      -- should be aware this might need special handling.
    end

    if text_a < text_b then
      return -1
    elseif text_a > text_b then
      return 1
    else
      return 0
    end
  end
end

--- Compare two strings using natural sorting algorithm.
--- @param a string First string to compare
--- @param b string Second string to compare
--- @param ignore_case boolean Whether to ignore case
--- @return boolean True if a should come before b
M.natural_compare = function(a, b, ignore_case)
  -- Special case: detect negative number pattern.
  -- If both strings have the pattern "prefix-number" where prefix is the same,
  -- treat the numbers as negative for comparison.
  local prefix_a, num_a = string.match(a, '^(.-)%-(%d+)$')
  local prefix_b, num_b = string.match(b, '^(.-)%-(%d+)$')

  if prefix_a and num_a and prefix_b and num_b then
    local cmp_prefix_a = ignore_case and string.lower(prefix_a) or prefix_a
    local cmp_prefix_b = ignore_case and string.lower(prefix_b) or prefix_b
    if cmp_prefix_a == cmp_prefix_b then
      -- Both have the same prefix followed by minus and number.
      -- Compare as negative numbers.
      local neg_a = -tonumber(num_a)
      local neg_b = -tonumber(num_b)
      return neg_a < neg_b
    end
  end

  -- Standard natural sorting.
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
