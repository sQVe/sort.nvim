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

return M
