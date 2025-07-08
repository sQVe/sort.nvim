local sort = require('sort.sort')
local utils = require('sort.utils')

local M = {}

--- Get text based on motion type and marks.
--- @param motion_type string Motion type ('line', 'char', 'block')
--- @param start_pos table Start position [row, col]
--- @param end_pos table End position [row, col]
--- @param is_visual_marks boolean Whether marks are from visual mode (0-based) or operator (1-based)
--- @return string text
local function get_text_for_motion(
  motion_type,
  start_pos,
  end_pos,
  is_visual_marks
)
  if motion_type == 'line' then
    local lines =
      vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
    return table.concat(lines, '\n')
  elseif motion_type == 'char' then
    if start_pos[1] == end_pos[1] then
      -- Same line
      local line =
        vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, start_pos[1], false)[1]

      local extracted_text
      if is_visual_marks then
        -- Visual marks are 0-based, string.sub is 1-based, so add 1.
        -- Also add 1 to end_pos to make selection inclusive.
        extracted_text = string.sub(line, start_pos[2] + 1, end_pos[2] + 1)
      else
        -- Operator marks are 0-based, convert to 1-based for string.sub.
        extracted_text = string.sub(line, start_pos[2] + 1, end_pos[2] + 1)
      end

      return extracted_text
    else
      -- Multiple lines
      local lines =
        vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
      if #lines > 0 then
        if is_visual_marks then
          lines[1] = string.sub(lines[1], start_pos[2] + 1)
          lines[#lines] = string.sub(lines[#lines], 1, end_pos[2] + 1)
        else
          lines[1] = string.sub(lines[1], start_pos[2] + 1)
          lines[#lines] = string.sub(lines[#lines], 1, end_pos[2] + 1)
        end
        return table.concat(lines, '\n')
      end
    end
  elseif motion_type == 'block' then
    local lines = {}
    for row = start_pos[1], end_pos[1] do
      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ''
      local start_col = math.min(start_pos[2], end_pos[2])
      local end_col = math.max(start_pos[2], end_pos[2])
      table.insert(lines, string.sub(line, start_col, end_col))
    end
    return table.concat(lines, '\n')
  end
  return ''
end

--- Set text based on motion type and marks.
--- @param motion_type string Motion type ('line', 'char', 'block')
--- @param start_pos table Start position [row, col]
--- @param end_pos table End position [row, col]
--- @param text string New text
--- @param is_visual_marks boolean Whether marks are from visual mode (0-based) or operator (1-based)
local function set_text_for_motion(
  motion_type,
  start_pos,
  end_pos,
  text,
  is_visual_marks
)
  if motion_type == 'line' then
    local lines = vim.split(text, '\n')
    vim.api.nvim_buf_set_lines(0, start_pos[1] - 1, end_pos[1], false, lines)
  elseif motion_type == 'char' then
    -- Check if text contains newlines to determine if it's truly single line
    local lines = vim.split(text, '\n')
    if #lines == 1 and start_pos[1] == end_pos[1] then
      -- Truly single line - get the actual line to check bounds
      local actual_line = vim.api.nvim_buf_get_lines(
        0,
        start_pos[1] - 1,
        start_pos[1],
        false
      )[1] or ''
      local line_len = string.len(actual_line)

      if is_visual_marks then
        -- Visual marks are 0-based, nvim_buf_set_text expects 0-based
        -- Add 1 to end_pos[2] to make selection inclusive, but clamp to line length
        local end_col = math.min(end_pos[2] + 1, line_len)
        vim.api.nvim_buf_set_text(
          0,
          start_pos[1] - 1,
          start_pos[2],
          end_pos[1] - 1,
          end_col,
          { text }
        )
      else
        -- Operator marks are 0-based, use nvim_buf_set_text which expects 0-based
        vim.api.nvim_buf_set_text(
          0,
          start_pos[1] - 1, -- Convert 1-based row to 0-based
          start_pos[2], -- Column already 0-based
          end_pos[1] - 1, -- Convert 1-based row to 0-based
          end_pos[2] + 1, -- Operator marks are inclusive, nvim_buf_set_text expects exclusive end
          { text }
        )
      end
    else
      -- Text spans multiple lines or positions indicate multi-line
      -- For complex multi-line replacements, use line-based replacement
      local lines = vim.split(text, '\n')

      -- Get the current line and modify it to preserve content before/after selection
      local start_line = vim.api.nvim_buf_get_lines(
        0,
        start_pos[1] - 1,
        start_pos[1],
        false
      )[1] or ''
      local end_line = vim.api.nvim_buf_get_lines(
        0,
        end_pos[1] - 1,
        end_pos[1],
        false
      )[1] or ''

      -- Build the replacement lines
      local replacement_lines = {}

      if #lines == 1 then
        -- Single line replacement
        local before_text = ''
        local after_text = ''

        if is_visual_marks then
          before_text = string.sub(start_line, 1, start_pos[2])
          after_text = string.sub(end_line, end_pos[2] + 2)
        else
          before_text = string.sub(start_line, 1, start_pos[2])
          after_text = string.sub(end_line, end_pos[2] + 2)
        end

        table.insert(replacement_lines, before_text .. lines[1] .. after_text)
      else
        -- Multi-line replacement
        -- For line-sorted multiline content, preserve the exact sorted lines
        -- and only add prefix/suffix if they don't interfere with line structure.
        local before_text = string.sub(start_line, 1, start_pos[2])
        local after_text = string.sub(end_line, end_pos[2] + 2)

        -- Only add prefix/suffix if they're meaningful (non-whitespace).
        if string.match(before_text, '%S') then
          lines[1] = before_text .. lines[1]
        end
        if string.match(after_text, '%S') then
          lines[#lines] = lines[#lines] .. after_text
        end

        replacement_lines = lines
      end

      -- Replace the lines
      vim.api.nvim_buf_set_lines(
        0,
        start_pos[1] - 1,
        end_pos[1],
        false,
        replacement_lines
      )
    end
  elseif motion_type == 'block' then
    local lines = vim.split(text, '\n')
    local start_col = math.min(start_pos[2], end_pos[2])
    local end_col = math.max(start_pos[2], end_pos[2])

    for i, line in ipairs(lines) do
      local row = start_pos[1] + i - 2
      vim.api.nvim_buf_set_text(0, row, start_col - 1, row, end_col, { line })
    end
  end
end

--- Handle sorting text that ends with a delimiter (like from f motion).
--- @param text string The text to sort
--- @param options table Sort options
--- @return string sorted_text
local function sort_text_with_trailing_delimiter(text, options)
  if not text or string.len(text) == 0 then
    return text
  end

  -- Check if text ends with a delimiter
  local config = require('sort.config')
  local delimiters = config.get_user_config().delimiters

  local last_char = string.sub(text, -1)
  local has_trailing_delimiter = false
  local trailing_delimiter = ''

  for _, delimiter in ipairs(delimiters) do
    local translated_delimiter = utils.translate_delimiter(delimiter)
    if last_char == translated_delimiter then
      has_trailing_delimiter = true
      trailing_delimiter = translated_delimiter
      break
    end
  end

  if has_trailing_delimiter then
    -- Sort the text without the trailing delimiter, then add it back
    local text_to_sort = string.sub(text, 1, -2)
    local sorted_content = sort.delimiter_sort(text_to_sort, options)
    return sorted_content .. trailing_delimiter
  else
    -- No trailing delimiter, sort normally
    return sort.delimiter_sort(text, options)
  end
end

--- Main operator function for sorting.
--- @param motion_type string Motion type from operatorfunc
--- @param from_visual boolean|nil Whether called from visual mode
M.sort_operator = function(motion_type, from_visual)
  -- Get the marks based on calling context
  local start_pos, end_pos, is_visual_marks

  if from_visual then
    -- Called from visual mode - use visual marks
    start_pos = vim.api.nvim_buf_get_mark(0, '<')
    end_pos = vim.api.nvim_buf_get_mark(0, '>')
    is_visual_marks = true
  else
    -- Called from normal mode operator - use operator marks
    start_pos = vim.api.nvim_buf_get_mark(0, '[')
    end_pos = vim.api.nvim_buf_get_mark(0, ']')
    is_visual_marks = false
  end

  -- Check if we have valid positions
  if start_pos[1] == 0 or end_pos[1] == 0 then
    return
  end

  -- Special handling for $ motion that gets interpreted as line motion
  -- When motion_type is 'line' but we have marks on the same line, treat as char motion
  local effective_motion_type = motion_type
  if motion_type == 'line' and start_pos[1] == end_pos[1] then
    -- This is likely a $ motion that vim interpreted as line motion.
    -- Convert it to character motion to the end of the line.
    local line = vim.api.nvim_buf_get_lines(
      0,
      start_pos[1] - 1,
      start_pos[1],
      false
    )[1] or ''
    end_pos = { start_pos[1], string.len(line) - 1 }
    effective_motion_type = 'char'
  end

  -- Get the text covered by the motion.
  local text = get_text_for_motion(
    effective_motion_type,
    start_pos,
    end_pos,
    is_visual_marks
  )

  if text == '' or text == nil then
    return
  end

  -- Parse default options (can be extended later for operator arguments).
  local options = utils.parse_arguments('', '')
  
  -- Apply natural_sort configuration setting.
  local config = require('sort.config')
  local user_config = config.get_user_config()
  options.natural = user_config.natural_sort

  local sorted_text
  local lines = vim.split(text, '\n')

  if effective_motion_type == 'line' then
    -- For line-wise motions, we need to handle each line separately
    -- but still use delimiter sorting if it's a single line selection.
    if #lines == 1 then
      sorted_text = sort_text_with_trailing_delimiter(text, options)
    else
      -- For multi-line, use proper line sorting.
      -- For line sorting, disable numerical sorting to get alphabetical sorting.
      local line_options = vim.tbl_deep_extend('force', options, {
        numerical = false,
      })
      sorted_text = sort.line_sort_text(text, line_options)
    end
  else
    sorted_text = sort_text_with_trailing_delimiter(text, options)
  end

  -- Set the sorted text
  set_text_for_motion(
    effective_motion_type,
    start_pos,
    end_pos,
    sorted_text,
    is_visual_marks
  )

  -- Set up for dot repeat - operatorfunc should already be set by the mapping
  -- Don't reset it here as it might interfere with the current operation
end

-- Make the function globally accessible for operatorfunc
-- vim's operatorfunc only passes motion_type, so we need a wrapper
_G._sort_operator = function(motion_type)
  return M.sort_operator(motion_type, false) -- false = not from visual mode
end

return M
