local M = {}

--- TODO: Description.
--- @param matches string[]
--- @return SortedWord[] sorted_words
M.convert_to_words_list = function(matches)
  local sorted_words = {}

  for idx, match in ipairs(matches) do
    table.insert(sorted_words, {
      index = idx,
      text = M.trim_leading_and_trailing_whitespace(match),
    })
  end

  table.sort(sorted_words, function(a, b)
    return a.text < b.text
  end)

  return sorted_words
end

--- TODO: Description.
--- @param bang string
--- @param arguments string
--- @return SortOptions options
M.parse_arguments = function(bang, arguments)
  local raw_options = M.split_by_delimiter(arguments, '%s')[1] or ''

  local options = {}
  options.ignore_case = string.match(raw_options, 'i') == 'i'
  options.reverse = bang == '!'
  options.unique = string.match(raw_options, 'u') == 'u'

  return options
end

--- Split by delimiter
--- @param text string
--- @param delimiter string
--- @return string[] matches
M.split_by_delimiter = function(text, delimiter)
  local matches = {}
  local delimiterRe = '([^' .. delimiter .. ']+)'

  if delimiter then
    string.gsub(text, delimiterRe, function(match)
      table.insert(matches, match)
    end)
  end

  return matches
end

--- TODO: Description.
--- @param text string
--- @return string
M.trim_leading_and_trailing_whitespace = function(text)
  local leadingWhitespaceRe = '^%s+'
  local trailingWhitespaceRe = '%s+$'

  text = string.gsub(text, leadingWhitespaceRe, '')
  text = string.gsub(text, trailingWhitespaceRe, '')

  return text
end

return M
