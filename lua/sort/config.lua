local M = {}

--- @type Config
local defaults = {
  delimiters = { ',', '|', ';', ':', 's', 't' },
  keymap = 'go',
  natural_sort = true,
  ignore_case = false,
  ignore_negative = false,
  unique = false,
  whitespace = {
    alignment_threshold = 3,
  },
  mappings = {
    operator = 'go',
    textobject = {
      inner = 'is',
      around = 'as',
    },
    motion = {
      next_delimiter = ']s',
      prev_delimiter = '[s',
    },
  },
}

local user_config = defaults

--- Get user config.
--- @return Config user_config
M.get_user_config = function()
  return user_config
end

--- Setup user config by merging defaults and overrides.
--- @param overrides? Config
--- @return Config user_config
M.setup = function(overrides)
  user_config = vim.tbl_deep_extend('force', defaults, overrides or {})

  return user_config
end

return M
