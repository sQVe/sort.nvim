local utils = {}

-- Get text between two columns.
---@param selection Selection
---@return string
utils.get_text_between_columns = function(selection)
    local line = vim.api.nvim_buf_get_lines(
        0,
        selection.start.row - 1,
        selection.stop.row,
        false
    )[1]
    local text = string.sub(line, selection.start.column, selection.stop.column)

    return text
end

-- Get rows and columns of currect visual selection.
utils.get_visual_selection = function()
    local _, srow, scol, _ = unpack(vim.fn.getpos('\'<'))
    local _, erow, ecol, _ = unpack(vim.fn.getpos('\'>'))
    local is_selection_inversed = srow > erow or (srow == erow and scol >= ecol)

    ---@type Selection
    local selection = {}
    selection.start = { row = srow, column = scol }
    selection.stop = { row = erow, column = ecol }

    if is_selection_inversed then
        selection.start = { row = erow, column = ecol }
        selection.stop = { row = scol, column = scol }
    end

    return selection
end

return utils
