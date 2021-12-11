local config = require('sort.config')
local interface = require('sort.interface')
local utils = require('sort.utils')

local M = {}

--- Get sorted words (text without leading and trailing whitespace).
--- @param matches string[]
--- @param options SortOptions
--- @return string[] sorted_words
M.get_sorted_words = function(matches, options)
  local sorted_words = {}

  for _, match in ipairs(matches) do
    table.insert(
      sorted_words,
      utils.trim_leading_and_trailing_whitespace(match)
    )
  end

  table.sort(sorted_words, function(a, b)
    a = options.ignore_case and string.lower(a) or a
    b = options.ignore_case and string.lower(b) or b

    if options.numerical then
      local na = utils.parse_number(a, options.numerical)
      local nb = utils.parse_number(b, options.numerical)

      if na and nb then
        return na < nb
      elseif na then
        return false
      elseif nb then
        return true
      end
    end

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
  local delimiters = options.delimiter and { options.delimiter }
    or user_config.delimiters

  local leading_whitespaces, matches, sorted_words, top_translated_delimiter, trailing_whitespaces
  for _, delimiter in ipairs(delimiters) do
    top_translated_delimiter = utils.translate_delimiter(delimiter)
    matches = utils.split_by_delimiter(text, top_translated_delimiter)
    local delimiterCount = #matches - 1

    if delimiterCount > 0 then
      leading_whitespaces, trailing_whitespaces = M.get_whitespaces_around_word(
        matches
      )
      sorted_words = M.get_sorted_words(matches, options)
      break
    end
  end

  if sorted_words == nil then
    return text
  end

  if options.reverse then
    leading_whitespaces = utils.reverse_list(leading_whitespaces)
    sorted_words = utils.reverse_list(sorted_words)
    trailing_whitespaces = utils.reverse_list(trailing_whitespaces)
  end

  local sorted_fragments = {}
  if options.unique then
    local unique_indexes = utils.find_unique_indexes(sorted_words)

    for _, idx in ipairs(unique_indexes) do
      table.insert(
        sorted_fragments,
        leading_whitespaces[idx]
          .. sorted_words[idx]
          .. trailing_whitespaces[idx]
      )
    end
  else
    for idx, sorted_word in ipairs(sorted_words) do
      table.insert(
        sorted_fragments,
        leading_whitespaces[idx] .. sorted_word .. trailing_whitespaces[idx]
      )
    end
  end

  return table.concat(sorted_fragments, top_translated_delimiter)
end

--- Sort by line, using the default :sort.
--- @param bang string
--- @param arguments string
M.line_sort = function(bang, arguments)
  interface.execute_builtin_sort(bang, arguments)
end

return M
