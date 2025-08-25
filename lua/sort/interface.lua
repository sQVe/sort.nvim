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
--- @return string|nil text Returns text or nil on error
M.get_text_between_columns = function(selection)
  if not selection or not selection.from or not selection.to then
    vim.notify(
      'Invalid selection provided for text extraction',
      vim.log.levels.ERROR
    )
    return nil
  end

  local success, lines = pcall(
    vim.api.nvim_buf_get_lines,
    0,
    selection.from.row - 1,
    selection.to.row,
    false
  )
  if not success or not lines or #lines == 0 then
    vim.notify(
      string.format(
        'Failed to retrieve line %d from buffer',
        selection.from.row
      ),
      vim.log.levels.ERROR
    )
    return nil
  end

  local line = lines[1]
  if not line then
    vim.notify(
      string.format('Line %d is empty or invalid', selection.from.row),
      vim.log.levels.ERROR
    )
    return nil
  end

  return string.sub(line, selection.from.column, selection.to.column)
end

--- Get rows and columns of current visual selection.
--- @return Selection|nil Returns selection or nil on error
M.get_visual_selection = function()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")

  if not start_pos or #start_pos < 4 or not end_pos or #end_pos < 4 then
    vim.notify(
      'Invalid visual selection marks - ensure text is selected first',
      vim.log.levels.ERROR
    )
    return nil
  end

  local _, from_row, from_column, _ = unpack(start_pos)
  local _, to_row, end_column, _ = unpack(end_pos)

  if from_row == 0 or to_row == 0 then
    vim.notify('No valid visual selection found', vim.log.levels.ERROR)
    return nil
  end
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
