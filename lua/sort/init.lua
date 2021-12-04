local config = require('sort.config')
local interface = require('sort.interface')
local sort = require('sort.sort')
local utils = require('sort.utils')

local M = {}

M.setup = config.setup

--- Sort by either lines or specified delimiters.
--- @param bang string
--- @param arguments string
M.sort = function(bang, arguments)
  -- TODO: Parse the options.
  local selection = interface.get_visual_selection()
  local is_multiple_lines_selected = selection.start.row < selection.stop.row

  if is_multiple_lines_selected then
    sort.line_sort(bang, arguments)
  else
    local options = utils.parse_arguments(bang, arguments)
    local text = interface.get_text_between_columns(selection)
    local sorted_text = sort.delimiter_sort(text, options)

    interface.set_line_text(selection, sorted_text)
  end
end

return M
