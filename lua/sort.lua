local config = require('config')
local utils = require('utils')

local sort = {}

sort.setup = config.setup

--- Sort by either lines or specified delimiters.
sort.sort = function(...)
  -- TODO: Parse the options.
  local input = table.concat({ ... }, ' ')
  local selection = utils.get_visual_selection()
  local is_multiple_lines_selected = selection.start.row < selection.stop.row

  if is_multiple_lines_selected then
    vim.api.nvim_command('\'<,\'>sort' .. ' ' .. input)
  else
    -- TODO: Support !, i and u.
    local user_config = config.get_user_config()
    local text = utils.get_text_between_columns(selection)

    local matches, sorted_words
    for _, delimiter in ipairs(user_config.delimiters) do
      matches = utils.split_by_delimiter(text, delimiter)
      local delimiterCount = #matches - 1

      if delimiterCount > 0 then
        sorted_words = utils.convert_to_words_list(matches)
        break
      end
    end

    if sorted_words == nil then
      return
    end

    print(vim.inspect(sorted_words))
  end
end

return sort
