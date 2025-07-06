local M = {}

-- This module is kept minimal for potential vim-repeat integration
-- Vim's built-in dot-repeat should handle most cases automatically

--- Set up repeat mappings (if needed for vim-repeat integration).
M.setup = function()
  -- Create a <Plug> mapping for repeat (for vim-repeat plugin compatibility)
  vim.keymap.set('n', '<Plug>SortRepeat', function()
    -- This shouldn't normally be called since we use vim's native repeat
    vim.notify('Dot-repeat should work natively. If you see this, there may be an issue.', vim.log.levels.WARN)
  end, {
    desc = 'Sort repeat (fallback)',
    silent = true,
  })
end

return M