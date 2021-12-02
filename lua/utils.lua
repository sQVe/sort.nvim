local utils = {}

--- Get text between two columns.
--- @param selection Selection
--- @return string text
utils.get_text_between_columns = function(selection)
  local line = vim.api.nvim_buf_get_lines(
    0,
    selection.start.row - 1,
    selection.stop.row,
    false
  )[1]
  local text = string.sub(line, selection.start.column, selection.stop.column)

  return text
end

--- Get rows and columns of currect visual selection.
--- @return Selection
utils.get_visual_selection = function()
  local _, srow, scol, _ = unpack(vim.fn.getpos('\'<'))
  local _, erow, ecol, _ = unpack(vim.fn.getpos('\'>'))
  local is_selection_inversed = srow > erow or (srow == erow and scol >= ecol)

  local selection = {}
  selection.start = { row = srow, column = scol }
  selection.stop = { row = erow, column = ecol }

  if is_selection_inversed then
    selection.start = { row = erow, column = ecol }
    selection.stop = { row = scol, column = scol }
  end

  return selection
end

--- Split by delimiter
--- @param text string
--- @param delimiter string
--- @return string[] matches
utils.split_by_delimiter = function(text, delimiter)
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
utils.trim_leading_and_trailing_whitespace = function(text)
  local leadingWhitespaceRe = '^%s+'
  local trailingWhitespaceRe = '%s+$'

  text = string.gsub(text, leadingWhitespaceRe, '')
  text = string.gsub(text, trailingWhitespaceRe, '')

  return text
end

--- TODO: Description.
--- @param matches string[]
--- @return SortedWord[] sorted_words
utils.convert_to_words_list = function(matches)
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

return utils
