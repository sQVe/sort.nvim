local M = {}

local leadingWhitespacePattern = '^%s+'
local trailingWhitespacePattern = '%s+$'

--- Get leading whitespaces.
--- @param text string
--- @return string
M.get_leading_whitespace = function(text)
  local leadingWhitespace = string.match(text, leadingWhitespacePattern)

  return leadingWhitespace or ''
end

--- Get trailing whitespaces.
--- @param text string
--- @return string
M.get_trailing_whitespace = function(text)
  local trailingWhitespace = string.match(text, trailingWhitespacePattern)

  return trailingWhitespace or ''
end

--- Parse options provided via bang and/or arguments.
--- @param bang string
--- @param arguments string
--- @return SortOptions options
M.parse_arguments = function(bang, arguments)
  local delimiter = string.match(arguments, '[st%p]')
  local options = {}

  options.delimiter = delimiter
  options.ignore_case = string.match(arguments, 'i') == 'i'
  options.reverse = bang == '!'
  options.unique = string.match(arguments, 'u') == 'u'

  return options
end

--- Split by translated delimiter.
--- @param text string
--- @param translated_delimiter string
--- @return string[] matches
M.split_by_delimiter = function(text, translated_delimiter)
  local matches = {}
  local notDelimiterPattern = '([^' .. translated_delimiter .. ']+)'

  string.gsub(text, notDelimiterPattern, function(match)
    table.insert(matches, match)
  end)

  return matches
end

--- Reverse a list.
--- @param list string[]
--- @return string[] reversed_list
M.reverse_list = function(list)
  local reversed_list = {}

  for i = #list, 1, -1 do
    reversed_list[#reversed_list + 1] = list[i]
  end

  return reversed_list
end

--- Translate delimiter values to proper characters.
--- @param delimiter string
--- @return string translated_delimiter
M.translate_delimiter = function(delimiter)
  local translateMap = {
    t = '\t',
    s = ' ',
  }

  return translateMap[delimiter] or delimiter
end

--- Trim escaped backslash.
--- @param text string
--- @return string
M.trim_escaped_backslash = function(text)
  local escapedBackslashPattern = '\\'

  text = string.gsub(text, escapedBackslashPattern, '')

  return text
end

--- Trim leading and trailing whitespaces.
--- @param text string
--- @return string
M.trim_leading_and_trailing_whitespace = function(text)
  text = string.gsub(text, leadingWhitespacePattern, '')
  text = string.gsub(text, trailingWhitespacePattern, '')

  return text
end

--- Find all indexes in a list that holds a unique value.
--- @param list string[]
--- @return number[] unique_indexes
M.find_unique_indexes = function(list)
  local unique_indexes = {}
  local value_map = {}

  for idx, value in ipairs(list) do
    if value_map[value] == nil then
      value_map[value] = true

      table.insert(unique_indexes, idx)
    end
  end

  return unique_indexes
end

return M
