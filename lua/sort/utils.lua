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
  local delimiter, option_keys = string.match(arguments, '(.*)%s(.*)')

  -- TODO: Custom delimiter allowed as `s`, `t` or `%p`.
  -- Mimic pattern so we can match the delimiter.

  if delimiter == nil then
    if string.match(arguments, '^[ui%s]+$') then
      option_keys = arguments
    else
      delimiter = arguments
    end
  end

  delimiter = string.sub(delimiter, 1, 1)

  print(vim.inspect(delimiter), vim.inspect(option_keys))

  local options = {}

  options.delimiter = delimiter
  options.ignore_case = string.match(option_keys, 'i') == 'i'
  options.reverse = bang == '!'
  options.unique = string.match(option_keys, 'u') == 'u'

  return options
end

--- Split by delimiter
--- @param text string
--- @param delimiter string
--- @return string[] matches
M.split_by_delimiter = function(text, delimiter)
  local matches = {}
  local notDelimiterPattern = '([^' .. delimiter .. ']+)'

  string.gsub(text, notDelimiterPattern, function(match)
    table.insert(matches, match)
  end)

  return matches
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

return M
