local M = {}

--- @type Config
local defaults = {
  delimiters = { ',', '|', ';', ':', 's', 't' },
  keymap = 'go',
  natural_sort = true,
  ignore_case = false,
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

local function warn(key, expected, actual)
  vim.notify(
    string.format(
      "sort.nvim: config '%s' expected %s, got %s — ignoring override",
      key,
      expected,
      actual
    ),
    vim.log.levels.WARN
  )
end

local function is_list_of_strings(value)
  if type(value) ~= 'table' then
    return false
  end
  for _, v in ipairs(value) do
    if type(v) ~= 'string' then
      return false
    end
  end
  return true
end

--- Strip invalid keys from `overrides` in place, warning about each.
--- Leaves the rest of `overrides` intact so valid keys still apply.
local function validate(overrides)
  if
    overrides.delimiters ~= nil and not is_list_of_strings(overrides.delimiters)
  then
    warn('delimiters', 'list of strings', type(overrides.delimiters))
    overrides.delimiters = nil
  end

  for _, key in ipairs({ 'keymap' }) do
    if overrides[key] ~= nil and type(overrides[key]) ~= 'string' then
      warn(key, 'string', type(overrides[key]))
      overrides[key] = nil
    end
  end

  for _, key in ipairs({ 'natural_sort', 'ignore_case', 'unique' }) do
    if overrides[key] ~= nil and type(overrides[key]) ~= 'boolean' then
      warn(key, 'boolean', type(overrides[key]))
      overrides[key] = nil
    end
  end

  if type(overrides.whitespace) == 'table' then
    local threshold = overrides.whitespace.alignment_threshold
    if threshold ~= nil then
      if type(threshold) ~= 'number' or threshold < 0 then
        warn(
          'whitespace.alignment_threshold',
          'non-negative number',
          type(threshold) == 'number' and tostring(threshold) or type(threshold)
        )
        overrides.whitespace.alignment_threshold = nil
      end
    end
  elseif overrides.whitespace ~= nil then
    warn('whitespace', 'table', type(overrides.whitespace))
    overrides.whitespace = nil
  end

  if overrides.mappings ~= nil and overrides.mappings ~= false then
    if type(overrides.mappings) ~= 'table' then
      warn('mappings', 'table or false', type(overrides.mappings))
      overrides.mappings = nil
    else
      local m = overrides.mappings
      if
        m.operator ~= nil
        and m.operator ~= false
        and type(m.operator) ~= 'string'
      then
        warn('mappings.operator', 'string or false', type(m.operator))
        m.operator = nil
      end
      local sub_keys = {
        textobject = { 'inner', 'around' },
        motion = { 'next_delimiter', 'prev_delimiter' },
      }
      for group, keys in pairs(sub_keys) do
        if m[group] ~= nil and m[group] ~= false then
          if type(m[group]) ~= 'table' then
            warn('mappings.' .. group, 'table or false', type(m[group]))
            m[group] = nil
          else
            for _, k in ipairs(keys) do
              if m[group][k] ~= nil and type(m[group][k]) ~= 'string' then
                warn(
                  'mappings.' .. group .. '.' .. k,
                  'string',
                  type(m[group][k])
                )
                m[group][k] = nil
              end
            end
          end
        end
      end
    end
  end
end

--- Get user config.
--- @return Config user_config
M.get_user_config = function()
  return user_config
end

--- Setup user config by merging defaults and overrides.
--- @param overrides? Config
--- @return Config user_config
M.setup = function(overrides)
  overrides = vim.deepcopy(overrides or {})
  validate(overrides)
  user_config = vim.tbl_deep_extend('force', user_config, overrides)

  return user_config
end

return M
