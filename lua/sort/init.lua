local config = require('sort.config')
local interface = require('sort.interface')
local sort = require('sort.sort')
local utils = require('sort.utils')
local mappings = require('sort.mappings')

local M = {
  _VERSION = '2.1.2',
  _DESCRIPTION = 'Sorting plugin for Neovim',
  _URL = 'https://github.com/sQVe/sort.nvim',
  _LICENSE = 'MIT',
}

M.setup = function(opts)
  config.setup(opts)
  mappings.setup()

  local repeat_mod = require('sort.repeat')
  repeat_mod.setup()
end

--- Sort by either lines or specified delimiters.
--- @param bang string
--- @param arguments string
M.sort = function(bang, arguments)
  local selection = interface.get_visual_selection()
  local is_multiple_lines_selected = selection.from.row < selection.to.row

  if
    selection.from.row == 0
    or (
      selection.from.row == selection.to.row
      and selection.from.column == selection.to.column
    )
  then
    return
  end

  if is_multiple_lines_selected then
    sort.line_sort(bang, arguments)
  else
    local options = utils.parse_arguments(bang, arguments)

    -- Apply config defaults if not explicitly set by arguments
    local user_config = config.get_user_config()
    options.ignore_case = options.ignore_case or user_config.ignore_case

    local text = interface.get_text_between_columns(selection)
    local sorted_text = sort.delimiter_sort(text, options)

    interface.set_line_text(selection, sorted_text)
  end
end

return M
