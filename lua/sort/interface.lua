local M = {}

local maximum_line_length = 2147483647

--- Execute builtin sort command on range.
--- @param bang string
--- @param arguments string
M.execute_builtin_sort = function(bang, arguments)
  vim.api.nvim_command("'<,'>sort" .. bang .. ' ' .. arguments)
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

  return string.sub(line, selection.start.column, selection.stop.column)
end

--- Get rows and columns of currect visual selection.
--- @return Selection
M.get_visual_selection = function()
  local start_row, start_column = unpack(vim.api.nvim_buf_get_mark(0, '<'))
  local stop_row, stop_column = unpack(vim.api.nvim_buf_get_mark(0, '>'))
  local is_selection_inversed = start_row > stop_row
    or (start_row == stop_row and start_column >= stop_column)

  local selection = {
    start = { row = start_row, column = start_column },
    stop = { row = stop_row, column = stop_column },
  }

  local function swap_start_stop()
    selection.start, selection.stop = selection.stop, selection.start
  end

  if is_selection_inversed then
    swap_start_stop()
  end

  return selection
end

--- Set text for selection.
--- @param selection Selection
--- @param text string
M.set_line_text = function(selection, text)
  local offset = {
    start = {
      row = selection.start.row - 1,
      column = selection.start.column - 1,
    },
    stop = {
      row = selection.stop.row - 1,
      column = selection.stop.column - 1,
    },
  }

  if selection.stop.column == maximum_line_length then
    vim.api.nvim_buf_set_lines(
      0,
      offset.start.row,
      selection.stop.row,
      false,
      { text }
    )
  else
    local ok = pcall(
      vim.api.nvim_buf_set_text,
      0,
      offset.start.row,
      offset.start.column,
      offset.stop.row,
      selection.stop.column,
      { text }
    )

    if not ok then
      vim.api.nvim_buf_set_text(
        0,
        offset.start.row,
        offset.start.column,
        offset.stop.row,
        offset.stop.column,
        { text }
      )
    end
  end
end

return M
