local M = {}

--- Execute builtin sort command on range.
--- @param bang string
--- @param arguments string
M.execute_builtin_sort = function(bang, arguments)
  vim.api.nvim_command('\'<,\'>sort' .. bang .. ' ' .. arguments)
end

--- Get text between two columns.
--- @param selection Selection
--- @return string text
M.get_text_between_columns = function(selection)
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
M.get_visual_selection = function()
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

--- Set text for selection.
--- @param selection Selection
--- @param text string
M.set_line_text = function(selection, text)
  print(vim.inspect(selection))

  -- Check if using virtual line selection.
  if selection.stop.column == 2147483647 then
    vim.api.nvim_buf_set_lines(
      0,
      selection.start.row - 1,
      selection.stop.row,
      false,
      { text }
    )
  else
    vim.api.nvim_buf_set_text(
      0,
      selection.start.row - 1,
      selection.start.column - 1,
      selection.stop.row - 1,
      selection.stop.column,
      { text }
    )
  end
end

return M
