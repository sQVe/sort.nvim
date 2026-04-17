local M = {}

-- UTF-8 byte sequences for Unicode whitespace characters outside Lua's %s class.
-- Covers Unicode White_Space (excluding ASCII already in %s).
local unicode_whitespace = {
  ['\194\133'] = true, -- U+0085 NEL (Next Line)
  ['\194\160'] = true, -- U+00A0 NBSP
  ['\225\154\128'] = true, -- U+1680 Ogham space mark
  ['\226\128\128'] = true, -- U+2000 en quad
  ['\226\128\129'] = true, -- U+2001 em quad
  ['\226\128\130'] = true, -- U+2002 en space
  ['\226\128\131'] = true, -- U+2003 em space
  ['\226\128\132'] = true, -- U+2004 three-per-em space
  ['\226\128\133'] = true, -- U+2005 four-per-em space
  ['\226\128\134'] = true, -- U+2006 six-per-em space
  ['\226\128\135'] = true, -- U+2007 figure space
  ['\226\128\136'] = true, -- U+2008 punctuation space
  ['\226\128\137'] = true, -- U+2009 thin space
  ['\226\128\138'] = true, -- U+200A hair space
  ['\226\128\168'] = true, -- U+2028 line separator
  ['\226\128\169'] = true, -- U+2029 paragraph separator
  ['\226\128\175'] = true, -- U+202F narrow NBSP
  ['\226\129\159'] = true, -- U+205F medium math space
  ['\227\128\128'] = true, -- U+3000 ideographic space
}

--- Byte length of one whitespace character at position `pos`, or 0 if the
--- character at `pos` is not whitespace.
--- @param text string
--- @param pos integer 1-based byte index
--- @return integer width
local function whitespace_width(text, pos)
  local b = string.byte(text, pos)
  if not b then
    return 0
  end
  -- ASCII whitespace: space, tab, LF, VT, FF, CR.
  if b == 32 or (b >= 9 and b <= 13) then
    return 1
  end
  if b < 0x80 then
    return 0
  end
  local width
  if b < 0xE0 then
    width = 2
  elseif b < 0xF0 then
    width = 3
  else
    width = 4
  end
  local char = string.sub(text, pos, pos + width - 1)
  if unicode_whitespace[char] then
    return width
  end
  return 0
end

--- Byte length of the leading whitespace run.
--- @param text string
--- @return integer
local function leading_whitespace_length(text)
  local pos = 1
  while pos <= #text do
    local w = whitespace_width(text, pos)
    if w == 0 then
      break
    end
    pos = pos + w
  end
  return pos - 1
end

--- Start byte index (1-based) of the trailing whitespace run, or #text + 1 if
--- there is none. A single forward scan finds the last non-whitespace byte.
--- @param text string
--- @return integer
local function trailing_whitespace_start(text)
  local pos = 1
  local last_non_ws_end = 0
  while pos <= #text do
    local b = string.byte(text, pos)
    if not b then
      break
    end
    local width
    if b < 0x80 then
      width = 1
    elseif b < 0xE0 then
      width = 2
    elseif b < 0xF0 then
      width = 3
    else
      width = 4
    end
    local char = string.sub(text, pos, pos + width - 1)
    local is_ws = (b == 32 or (b >= 9 and b <= 13)) or unicode_whitespace[char]
    if not is_ws then
      last_non_ws_end = pos + width - 1
    end
    pos = pos + width
  end
  return last_non_ws_end + 1
end

--- Get leading whitespaces.
--- @param text string
--- @return string
M.get_leading_whitespace = function(text)
  return string.sub(text, 1, leading_whitespace_length(text))
end

--- Get trailing whitespaces.
--- @param text string
--- @return string
M.get_trailing_whitespace = function(text)
  return string.sub(text, trailing_whitespace_start(text))
end

--- Split by translated delimiter. Splitting is always literal — quoted
--- strings (`"a,b",c`) and bracket-protected regions (`(a,b),c`) are not
--- honored, even when the delimiter appears inside them. See README
--- "Limitations".
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
---
--- Flag letters ({b, n, o, x, i, u, z}) bind first, so combining them with
--- other characters doesn't accidentally consume a letter as a delimiter.
--- `s` and `t` only map to space/tab delimiters when they stand alone;
--- combined with other flags they would collide with the flag letter
--- parsing, so they're rejected with a warning instead.
---
--- @param bang string
--- @param arguments string
--- @return SortOptions options
M.parse_arguments = function(bang, arguments)
  local numerical_map = { b = 2, n = 10, o = 8, x = 16 }
  local options = {
    numerical = false,
    ignore_case = false,
    unique = false,
    natural = false,
    reverse = bang == '!',
  }

  -- Standalone 's' or 't' is a delimiter (space/tab shortcut).
  if arguments == 's' or arguments == 't' then
    options.delimiter = arguments
    return options
  end

  for i = 1, #arguments do
    local c = string.sub(arguments, i, i)
    if numerical_map[c] then
      if options.numerical == false then
        options.numerical = numerical_map[c]
      end
    elseif c == 'i' then
      options.ignore_case = true
    elseif c == 'u' then
      options.unique = true
    elseif c == 'z' then
      options.natural = true
    elseif c == 's' or c == 't' then
      vim.notify(
        "sort.nvim: '"
          .. c
          .. "' delimiter shortcut must be standalone, not combined with flags",
        vim.log.levels.WARN
      )
    elseif string.match(c, '%p') then
      options.delimiter = options.delimiter or c
    else
      vim.notify(
        "sort.nvim: unknown flag '" .. c .. "' in arguments",
        vim.log.levels.WARN
      )
    end
  end

  return options
end

--- Parse numbers from string.
--- @param text string
--- @param base? integer
--- @return integer | nil
M.parse_number = function(text, base)
  base = base or 10

  -- Anchored patterns: the whole input must be a valid number in the given base.
  -- Unanchored patterns would match embedded digit runs, e.g. '5xyz' as 5.
  local patterns = {
    [2] = '^%-?[01]+$',
    [8] = '^%-?[0-7]+$',
    [10] = '^%-?[%d.]+$',
    [16] = '^%-?0[xX]%x+$',
  }

  local match = string.match(text, patterns[base] or patterns[10])

  -- For hexadecimal, also try pattern without 0x prefix.
  if base == 16 and not match then
    match = string.match(text, '^%-?%x+$')
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
  local leading = leading_whitespace_length(text)
  local trailing_start = trailing_whitespace_start(text)
  if trailing_start <= leading then
    return ''
  end
  return string.sub(text, leading + 1, trailing_start - 1)
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

  -- Leading '-' before digits is a sign, not a separator. Mid-string '-' keeps
  -- its separator semantics (see "dashes as separators" in natural sort).
  if str:sub(1, 1) == '-' and string.match(str:sub(2, 2), '%d') ~= nil then
    local j = 2
    while j <= #str and string.match(str:sub(j, j), '%d') do
      j = j + 1
    end
    table.insert(segments, {
      text = str:sub(1, j - 1),
      is_number = true,
      is_punctuation = false,
    })
    i = j
  end

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
---
--- Whitespace policy for delimiter_sort:
---   - Items carry their own leading_ws and trailing_ws; whitespace "moves with
---     the item" when items reorder.
---   - When order changes (and natural_sort is disabled), every item's
---     leading_ws is passed through this function uniformly — no positional
---     special-casing. Natural sort preserves whitespace verbatim to protect
---     intentional column alignment.
---   - This function only normalizes leading_ws. The caller zeros trailing_ws
---     directly so all inter-item whitespace lives in the next item's
---     leading_ws.
---   - Whitespace at or above `alignment_threshold` chars is preserved as
---     deliberate column alignment. Shorter whitespace is replaced with the
---     dominant pattern detected across items.
---
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

--- Accepts optional sign, with digits before or after the decimal point,
--- with optional scientific exponent. Requires at least one digit, so `.`
--- alone and `e5` fail. `tonumber` is the final guard.
--- @param str string
--- @return boolean
M.is_pure_number = function(str)
  if str == nil or str == '' then
    return false
  end
  -- Lua patterns have no alternation, so match the two mantissa shapes
  -- separately: digits-first (`5`, `5.`, `5.5`) and dot-first (`.5`).
  local digits_first = '[%+%-]?%d+%.?%d*'
  local dot_first = '[%+%-]?%.%d+'
  local has_basic_number = string.match(str, '^' .. digits_first .. '$') ~= nil
    or string.match(str, '^' .. dot_first .. '$') ~= nil
  local has_scientific = string.match(
    str,
    '^' .. digits_first .. '[eE][%+%-]?%d+$'
  ) ~= nil or string.match(str, '^' .. dot_first .. '[eE][%+%-]?%d+$') ~= nil
  return (has_basic_number or has_scientific) and tonumber(str) ~= nil
end

--- Check if all non-empty items in a list are pure numbers.
--- Returns true for empty arrays or arrays with only empty trimmed values.
--- This triggers mathematical sorting for pure number lists and empty segments.
--- @param items table[] Array of items with trimmed field
--- @return boolean
M.all_pure_numbers = function(items)
  for _, item in ipairs(items) do
    if item.trimmed ~= '' and not M.is_pure_number(item.trimmed) then
      return false
    end
  end
  return true
end

--- Empty strings sort after all numeric values so they cluster at one end
--- instead of slotting between negatives and positives as coerced zeros.
--- Falls back to string comparison if tonumber fails (should not occur when
--- called via the sorting pipeline which pre-validates with all_pure_numbers).
--- @param a string
--- @param b string
--- @return boolean
M.math_compare = function(a, b)
  if a == '' then
    return false
  end
  if b == '' then
    return true
  end
  local na = tonumber(a)
  local nb = tonumber(b)
  if na and nb then
    return na < nb
  end
  return a < b
end

return M
