local M = {}

--- @type Config
local defaults = {}
defaults.delimiters = {
  ',',
  '|',
  ' ', -- Space.
  '	', -- Tab.
}

local user_config = defaults

--- Get user config.
--- @return Config user_config
M.get_user_config = function()
  return user_config
end

--- Setup user config by merging defaults and overrides.
--- @param overrides Config
--- @return Config user_config
M.setup = function(overrides)
  user_config = vim.tbl_deep_extend('force', defaults, overrides)

  return user_config
end

return M
