local M = {}

-- Maximum line length constant used by Neovim's getpos function.
-- This is 2^31 - 1, the maximum value for a 32-bit signed integer.
local maximum_line_length = 2147483647

--- Execute builtin sort command on range.
--- @param bang string
--- @param arguments string
M.execute_builtin_sort = function(bang, arguments)
  vim.cmd("'<,'>sort" .. bang .. ' ' .. arguments)
end


--- Get text between two columns.
--- @param selection Selection
--- @return string text
M.get_text_between_columns = function(selection)
  local line = vim.api.nvim_buf_get_lines(
    0,
    selection.from.row - 1,
    selection.to.row,
    false
  )[1]

  return string.sub(line, selection.from.column, selection.to.column)
end

--- Get rows and columns of current visual selection.
--- @return Selection
M.get_visual_selection = function()
  local _, from_row, from_column, _ = (table.unpack or unpack)(
    vim.fn.getpos("'<")
  )
  local _, to_row, end_column, _ = (table.unpack or unpack)(vim.fn.getpos("'>"))
  local is_selection_inversed = from_row > to_row
    or (from_row == to_row and from_column >= end_column)

  local selection = {
    from = { row = from_row, column = from_column },
    to = { row = to_row, column = end_column },
  }

  local function swap_from_to()
    selection.from, selection.to = selection.to, selection.from
  end

  if is_selection_inversed then
    swap_from_to()
  end

  return selection
end

--- Set text for selection.
--- @param selection Selection
--- @param text string
M.set_line_text = function(selection, text)
  local offset = {
    from = {
      row = selection.from.row - 1,
      column = selection.from.column - 1,
    },
    to = {
      row = selection.to.row - 1,
      column = selection.to.column - 1,
    },
  }

  if selection.to.column == maximum_line_length then
    -- When selection extends to end of line, replace entire lines.
    vim.api.nvim_buf_set_lines(
      0,
      offset.from.row,
      selection.to.row,
      false,
      { text }
    )
  else
    -- Try to set text with original column range.
    local ok, err = pcall(
      vim.api.nvim_buf_set_text,
      0,
      offset.from.row,
      offset.from.column,
      offset.to.row,
      selection.to.column,
      { text }
    )

    -- If that fails (likely due to column bounds), try with adjusted range.
    if not ok then
      local fallback_ok, fallback_err = pcall(
        vim.api.nvim_buf_set_text,
        0,
        offset.from.row,
        offset.from.column,
        offset.to.row,
        offset.to.column,
        { text }
      )

      -- If both attempts fail, notify user with error details.
      if not fallback_ok then
        vim.notify(
          string.format(
            'Failed to set text: %s (fallback: %s)',
            err or 'unknown error',
            fallback_err or 'unknown error'
          ),
          vim.log.levels.ERROR
        )
      end
    end
  end
end

return M
