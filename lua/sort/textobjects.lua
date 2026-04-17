local config = require('sort.config')
local utils = require('sort.utils')

local M = {}

--- Find the boundaries of a sortable region around the cursor.
--- @param include_delimiters boolean Whether to include surrounding delimiters
--- @return table|nil selection Selection object or nil if no sortable region found
function M._find_sortable_region(include_delimiters)
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

  -- Compute every segment's [start, finish] up front so we can snap deterministically
  -- when the cursor sits on a delimiter or past the last segment.
  local segments = {}
  local current_pos = 1
  for i, match in ipairs(matches) do
    segments[i] = {
      start = current_pos,
      finish = current_pos + string.len(match) - 1,
    }
    current_pos = current_pos + string.len(match) + string.len(best_delimiter)
  end

  local segment_index = nil
  for i, seg in ipairs(segments) do
    if col >= seg.start and col <= seg.finish then
      segment_index = i
      break
    end
  end

  if segment_index == nil then
    -- Cursor on a delimiter or past the last segment. Empty boundary
    -- segments (from leading/trailing delimiters) have finish < start and
    -- must be skipped — otherwise the returned selection has to < from.
    for i = #segments, 1, -1 do
      if
        segments[i].finish >= segments[i].start and segments[i].finish < col
      then
        segment_index = i
        break
      end
    end
    if segment_index == nil then
      for i = 1, #segments do
        if segments[i].finish >= segments[i].start then
          segment_index = i
          break
        end
      end
    end
    if segment_index == nil then
      return nil
    end
  end

  local segment_start = segments[segment_index].start
  local segment_end = segments[segment_index].finish

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

--- Apply a selection using the right mechanism for the given editor mode.
--- In visual modes (v/V/<C-v>), `normal! v` would toggle visual off and drop
--- the user into normal mode; set `<`/`>` marks and reselect with `gv` instead.
--- @param selection table Selection with from/to row and column
--- @param mode string Mode letter from vim.api.nvim_get_mode().mode
function M._apply_selection(selection, mode)
  local row = selection.from.row
  local start_col_zero = selection.from.column - 1
  local end_col_zero = selection.to.column - 1

  local is_visual = mode == 'v' or mode == 'V' or mode == '\22'
  if is_visual then
    vim.fn.setpos("'<", { 0, row, selection.from.column, 0 })
    vim.fn.setpos("'>", { 0, row, selection.to.column, 0 })
    vim.cmd('normal! gv')
    return
  end

  vim.api.nvim_win_set_cursor(0, { row, start_col_zero })
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, { row, end_col_zero })
end

--- Select inner sortable region (without delimiters).
function M.select_inner()
  local selection = M._find_sortable_region(false)

  if not selection then
    vim.notify('No sortable region found around cursor', vim.log.levels.WARN)
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<Nop>', true, false, true),
      'n',
      false
    )
    return
  end

  M._apply_selection(selection, vim.api.nvim_get_mode().mode)
end

--- Select around sortable region (with delimiters).
function M.select_around()
  local selection = M._find_sortable_region(true)

  if not selection then
    vim.notify('No sortable region found around cursor', vim.log.levels.WARN)
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<Nop>', true, false, true),
      'n',
      false
    )
    return
  end

  M._apply_selection(selection, vim.api.nvim_get_mode().mode)
end

return M
