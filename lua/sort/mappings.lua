local config = require('sort.config')
local operator = require('sort.operator')
local textobjects = require('sort.textobjects')
local motions = require('sort.motions')

local M = {}

--- Set up operator mappings.
--- @param mappings table Mapping configuration
local function setup_operator_mappings(mappings)
  local operator_key = mappings.operator

  -- Normal mode operator mapping.
  vim.keymap.set('n', operator_key, function()
    vim.o.operatorfunc = 'v:lua._sort_operator'
    return 'g@'
  end, {
    expr = true,
    desc = 'Sort operator',
    silent = true,
  })

  -- Visual mode mapping.
  vim.keymap.set('x', operator_key, function()
    -- Get the visual selection.
    local mode = vim.fn.mode(1)
    local detected_mode = (
      { ['v'] = 'char', ['V'] = 'line', ['\22'] = 'block' }
    )[mode]

    -- Get selection start and end using vim's visual mode functions.
    local start_row, start_col = unpack(vim.fn.getpos('v'), 2, 3)
    local end_row, end_col = unpack(vim.fn.getpos('.'), 2, 3)

    -- Ensure start is before end.
    if
      start_row > end_row or (start_row == end_row and start_col > end_col)
    then
      start_row, end_row = end_row, start_row
      start_col, end_col = end_col, start_col
    end

    -- For line mode, adjust the end position to include the full last line.
    if detected_mode == 'line' then
      local last_line = vim.api.nvim_buf_get_lines(
        0,
        end_row - 1,
        end_row,
        false
      )[1] or ''
      end_col = string.len(last_line)
    end

    -- Exit visual mode.
    vim.cmd('normal! \27')

    -- Set the marks for the operator.
    vim.api.nvim_buf_set_mark(0, '<', start_row, start_col - 1, {})
    vim.api.nvim_buf_set_mark(0, '>', end_row, end_col - 1, {})

    -- Call the operator with visual mode flag.
    operator.sort_operator(detected_mode, true)
  end, {
    desc = 'Sort selection',
    silent = true,
  })

  -- Line-wise shortcut (operator + operator = line).
  vim.keymap.set('n', operator_key .. operator_key, function()
    vim.o.operatorfunc = 'v:lua._sort_operator'
    return 'g@_'
  end, {
    expr = true,
    desc = 'Sort current line',
    silent = true,
  })
end

--- Set up textobject mappings.
--- @param mappings table Mapping configuration
local function setup_textobject_mappings(mappings)
  local textobj = mappings.textobject

  -- Inner textobject.
  vim.keymap.set({ 'o', 'x' }, textobj.inner, textobjects.select_inner, {
    desc = 'Inner sortable region',
    silent = true,
  })

  -- Around textobject.
  vim.keymap.set({ 'o', 'x' }, textobj.around, textobjects.select_around, {
    desc = 'Around sortable region',
    silent = true,
  })
end

--- Set up motion mappings.
--- @param mappings table Mapping configuration
local function setup_motion_mappings(mappings)
  local motion = mappings.motion

  -- Next delimiter.
  vim.keymap.set(
    { 'n', 'x', 'o' },
    motion.next_delimiter,
    motions.next_delimiter,
    {
      expr = true,
      desc = 'Next delimiter',
      silent = true,
    }
  )

  -- Previous delimiter.
  vim.keymap.set(
    { 'n', 'x', 'o' },
    motion.prev_delimiter,
    motions.prev_delimiter,
    {
      expr = true,
      desc = 'Previous delimiter',
      silent = true,
    }
  )
end

--- Set up all mappings based on configuration.
M.setup = function()
  local user_config = config.get_user_config()
  local mappings = user_config.mappings

  if not mappings then
    return
  end

  -- Set up operator mappings.
  if mappings.operator and mappings.operator ~= false then
    setup_operator_mappings(mappings)
  end

  -- Set up textobject mappings.
  if mappings.textobject and mappings.textobject ~= false then
    setup_textobject_mappings(mappings)
  end

  -- Set up motion mappings.
  if mappings.motion and mappings.motion ~= false then
    setup_motion_mappings(mappings)
  end
end

return M
