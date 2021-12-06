local config = require('sort.config')
local interface = require('sort.interface')
local utils = require('sort.utils')

local M = {}

--- Get sorted words (text without leading and trailing whitespace).
--- @param matches string[]
--- @param ignore_case? boolean
--- @return string[] sorted_words
M.get_sorted_words = function(matches, ignore_case)
  local sorted_words = {}

  for _, match in ipairs(matches) do
    table.insert(
      sorted_words,
      utils.trim_leading_and_trailing_whitespace(match)
    )
  end

  table.sort(sorted_words, function(a, b)
    a = ignore_case and string.lower(a) or a
    b = ignore_case and string.lower(b) or b

    return a < b
  end)

  return sorted_words
end

--- Get list of leading and trailing whitespaces.
--- @param matches string[]
--- @return string[] leading_whitespaces, string[] trailing_whitespaces
M.get_whitespaces_around_word = function(matches)
  local leading_whitespaces = {}
  local trailing_whitespaces = {}

  for _, match in ipairs(matches) do
    table.insert(leading_whitespaces, utils.get_leading_whitespace(match))
    table.insert(trailing_whitespaces, utils.get_trailing_whitespace(match))
  end

  return leading_whitespaces, trailing_whitespaces
end

--- Sort by top most matching delimiter.
--- @param text string
--- @param options SortOptions
--- @return string sorted_text
M.delimiter_sort = function(text, options)
  local user_config = config.get_user_config()

  local leading_whitespaces, matches, sorted_words, top_delimiter, trailing_whitespaces

  for _, delimiter in ipairs(options.delimiter and { options.delimiter } or user_config.delimiters) do
    top_delimiter = delimiter
    matches = utils.split_by_delimiter(text, delimiter)
    local delimiterCount = #matches - 1

    if delimiterCount > 0 then
      leading_whitespaces, trailing_whitespaces = M.get_whitespaces_around_word(
        matches
      )
      sorted_words = M.get_sorted_words(matches, options.ignore_case)
      break
    end
  end

  print(vim.inspect(sorted_words))

  if sorted_words == nil then
    return
  end

  local sorted_fragments = {}
  for idx, sorted_word in ipairs(sorted_words) do
    table.insert(
      sorted_fragments,
      leading_whitespaces[idx] .. sorted_word .. trailing_whitespaces[idx]
    )
  end

  -- TODO: Support options.

  return table.concat(sorted_fragments, top_delimiter)
end

--- Sort by line, using the default :sort.
--- @param bang string
--- @param arguments string
M.line_sort = function(bang, arguments)
  interface.execute_builtin_sort(bang, arguments)
end

return M
