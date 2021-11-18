local M = {}

local config = {}

local get_visual_selection_range = function()
    local _, srow, scol, _ = unpack(vim.fn.getpos('\'<'))
    local _, erow, ecol, _ = unpack(vim.fn.getpos('\'>'))

    if srow < erow or (srow == erow and scol <= ecol) then
        return srow - 1, erow, scol - 1, ecol
    end

    return erow - 1, srow, ecol - 1, scol
end

M.setup = function(user_config)
    config = vim.tbl_deep_extend('force', config, user_config)
end

M.sort = function()
    local srow, erow, scol, ecol = get_visual_selection_range()

    if srow < erow then
        -- TODO: How do we pass options into `sort` here?
        vim.api.nvim_command(':\'<,\'>sort')
    else
        -- TODO: How do we get the column selection here instead of the lines?
        print(vim.inspect(vim.api.nvim_buf_get_lines(0, srow, erow, false)))
    end
end

return M
