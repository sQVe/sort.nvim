local config = require('config')
local utils = require('utils')

local sort = {}

sort.setup = config.setup

-- Sort by either lines or specified delimiters.
sort.sort = function(...)
  local input = table.concat({ ... }, ' ')
  local selection = utils.get_visual_selection()
  local is_multiple_lines_selected = selection.start.row < selection.stop.row

  if is_multiple_lines_selected then
    vim.api.nvim_command('\'<,\'>sort' .. ' ' .. input)
  else
    -- TODO: Handle the input.
    -- TODO: Get text between two columns.
    local text = utils.get_text_between_columns(selection)

    print(text)
  end
end

return sort
