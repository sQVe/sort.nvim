local config = require('sort.config')
local interface = require('sort.interface')
local utils = require('sort.utils')

local M = {}

--- TODO: Description.
--- @param matches string[]
--- @return SortedWord[] sorted_words
M.convert_to_words_list = function(matches)
  local sorted_words = {}

  for idx, match in ipairs(matches) do
    table.insert(sorted_words, {
      index = idx,
      text = utils.trim_leading_and_trailing_whitespace(match),
    })
  end

  table.sort(sorted_words, function(a, b)
    return a.text < b.text
  end)

  return sorted_words
end

--- TODO: Description.
--- @param text string
--- @param options SortOptions
--- @return string sorted_text
M.delimiter_sort = function(text, options)
  local user_config = config.get_user_config()

  local matches, sorted_words, top_delimiter
  for _, delimiter in ipairs(user_config.delimiters) do
    top_delimiter = delimiter
    matches = utils.split_by_delimiter(text, delimiter)
    local delimiterCount = #matches - 1

    if delimiterCount > 0 then
      sorted_words = M.convert_to_words_list(matches)
      break
    end
  end

  if sorted_words == nil then
    return
  end

  local sorted_matches = {}
  for _, sorted_word in ipairs(sorted_words) do
    table.insert(sorted_matches, matches[sorted_word.index])
  end

  -- TODO: Support options.

  return table.concat(sorted_matches, top_delimiter)
end

--- TODO: Description.
--- @param bang string
--- @param arguments string
M.line_sort = function(bang, arguments)
  interface.execute_builtin_sort(bang, arguments)
end

return M
