local config = require('sort.config')
local utils = require('sort.utils')

local M = {}

--- Find the boundaries of a sortable region around the cursor.
--- @param include_delimiters boolean Whether to include surrounding delimiters
--- @return table|nil selection Selection object or nil if no sortable region found
local function find_sortable_region(include_delimiters)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  local col = cursor_pos[2] + 1 -- Convert to 1-based indexing

  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''

  if line == '' then
    return nil
  end

  local user_config = config.get_user_config()
  local delimiters = user_config.delimiters

  -- Find the best delimiter for this line.
  local best_delimiter = nil
  local matches = nil

  for _, delimiter in ipairs(delimiters) do
    local translated_delimiter = utils.translate_delimiter(delimiter)
    local potential_matches =
      utils.split_by_delimiter(line, translated_delimiter)

    if #potential_matches > 1 then
      best_delimiter = translated_delimiter
      matches = potential_matches
      break
    end
  end

  if not best_delimiter or not matches or #matches <= 1 then
    return nil
  end

  -- Find which segment the cursor is in.
  local current_pos = 1
  local segment_start = 1
  local segment_end = 1
  local segment_index = 1

  for i, match in ipairs(matches) do
    segment_start = current_pos
    segment_end = current_pos + string.len(match) - 1

    if col >= segment_start and col <= segment_end then
      segment_index = i
      break
    end

    current_pos = current_pos + string.len(match) + string.len(best_delimiter)
  end

  -- Determine selection boundaries.
  local selection_start = segment_start
  local selection_end = segment_end

  if include_delimiters then
    -- Include surrounding delimiters.
    if segment_index > 1 then
      selection_start = selection_start - string.len(best_delimiter)
    end
    if segment_index < #matches then
      selection_end = selection_end + string.len(best_delimiter)
    end
  end

  return {
    from = { row = row, column = selection_start },
    to = { row = row, column = selection_end },
  }
end

--- Select inner sortable region (without delimiters).
M.select_inner = function()
  local selection = find_sortable_region(false)

  if not selection then
    vim.notify('No sortable region found around cursor', vim.log.levels.WARN)
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<Nop>', true, false, true),
      'n',
      false
    )
    return
  end

  local start_pos = { selection.from.row, selection.from.column - 1 }
  local end_pos = { selection.to.row, selection.to.column - 1 }

  vim.api.nvim_win_set_cursor(0, start_pos)
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, end_pos)
end

--- Select around sortable region (with delimiters).
M.select_around = function()
  local selection = find_sortable_region(true)

  if not selection then
    vim.notify('No sortable region found around cursor', vim.log.levels.WARN)
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<Nop>', true, false, true),
      'n',
      false
    )
    return
  end

  local start_pos = { selection.from.row, selection.from.column - 1 }
  local end_pos = { selection.to.row, selection.to.column - 1 }

  vim.api.nvim_win_set_cursor(0, start_pos)
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, end_pos)
end

return M
