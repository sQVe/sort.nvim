local config = {}

---@type Config
local defaults = {}
defaults.delimiters = { [','] = 1 }

local user_config = defaults

-- Get user config.
config.get_config = function()
  return user_config
end

-- Setup config by applying config overries on default config.
---@param overrides Config
config.setup = function(overrides)
  user_config = vim.tbl_deep_extend('force', defaults, overrides)

  return user_config
end

return config
