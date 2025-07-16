local config = require('sort.config')
local utils = require('sort.utils')

local M = {}

--- Find the next delimiter position from the cursor.
--- @param forward boolean True to search forward, false for backward
--- @return table|nil Position {row, col} or nil if not found
local function find_next_delimiter(forward)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  local col = cursor_pos[2] + 1 -- Convert to 1-based indexing

  local user_config = config.get_user_config()
  local delimiters = user_config.delimiters

  -- Get current line.
  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''

  if line == '' then
    vim.notify(
      'No sortable delimiters found on current line',
      vim.log.levels.INFO
    )
    return nil
  end

  -- Find delimiters in the current line.
  for _, delimiter in ipairs(delimiters) do
    local translated_delimiter = utils.translate_delimiter(delimiter)
    local matches = utils.split_by_delimiter(line, translated_delimiter)

    if #matches > 1 then
      -- Find delimiter positions.
      local positions = {}
      local current_pos = 1

      for i = 1, #matches - 1 do
        current_pos = current_pos + string.len(matches[i])
        table.insert(positions, current_pos)
        current_pos = current_pos + string.len(translated_delimiter)
      end

      -- Find the next position based on direction.
      if forward then
        for _, pos in ipairs(positions) do
          if pos > col then
            return { row, pos }
          end
        end
      else
        for i = #positions, 1, -1 do
          local pos = positions[i]
          if pos < col then
            return { row, pos }
          end
        end
      end

      -- If we found any delimiters, we can stop searching.
      if #positions > 0 then
        break
      end
    end
  end

  return nil
end

--- Move to the next delimiter.
--- @return string Movement command for vim
M.next_delimiter = function()
  local pos = find_next_delimiter(true)

  if not pos then
    return '' -- No movement
  end

  -- Move to the delimiter position.
  return string.format('%dG%d|', pos[1], pos[2])
end

--- Move to the previous delimiter.
--- @return string Movement command for vim
M.prev_delimiter = function()
  local pos = find_next_delimiter(false)

  if not pos then
    return '' -- No movement
  end

  -- Move to the delimiter position.
  return string.format('%dG%d|', pos[1], pos[2])
end

return M
