local M = {}

local leading_whitespace_pattern = '^%s+'
local trailing_whitespace_pattern = '%s+$'

--- Find all indexes in a list that hold a unique value.
--- @param list string[]
--- @param ignore_case? boolean
--- @return integer[] unique_indexes
M.find_unique_indexes = function(list, ignore_case)
  local unique_indexes = {}
  local value_map = {}

  for idx, value in ipairs(list) do
    local key = ignore_case and string.lower(value) or value
    if value_map[key] == nil then
      value_map[key] = true
      unique_indexes[#unique_indexes + 1] = idx
    end
  end

  return unique_indexes
end

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

--- Check if in visual mode.
--- @return boolean
M.is_visual_mode = function()
  return vim.tbl_contains({ 'V', 'v', '\22' }, vim.fn.mode(1))
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

--- Reverse a list.
--- @param list string[]
--- @return string[] reversed_list
M.reverse_list = function(list)
  local reversed_list = {}
  local list_length = #list

  for i = list_length, 1, -1 do
    reversed_list[list_length - i + 1] = list[i]
  end

  return reversed_list
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
  else
    options.numerical = 10
  end

  options.ignore_case = string.match(arguments, 'i') ~= nil
  options.reverse = bang == '!'
  options.unique = string.match(arguments, 'u') ~= nil

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
M.detect_dominant_whitespace = function(whitespace_list, alignment_threshold, delimiter)
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
