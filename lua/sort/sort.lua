local config = require('sort.config')
local interface = require('sort.interface')
local utils = require('sort.utils')

local M = {}

--- Compare two strings according to sort options.
--- @param a string
--- @param b string
--- @param options SortOptions
--- @return boolean
local function compare_strings(a, b, options)
  -- Use natural sorting if enabled.
  if options.natural then
    return utils.natural_compare(a, b, options.ignore_case)
  end

  local sort_a = options.ignore_case and string.lower(a) or a
  local sort_b = options.ignore_case and string.lower(b) or b

  if options.numerical then
    local na = utils.parse_number(sort_a, options.numerical)
    local nb = utils.parse_number(sort_b, options.numerical)

    if na and nb then
      return na < nb
    elseif na then
      return false
    elseif nb then
      return true
    end
  end

  return sort_a < sort_b
end

--- Sort by top most matching delimiter.
--- @param text string
--- @param options SortOptions
--- @return string|nil sorted_text Returns sorted text or nil on error
M.delimiter_sort = function(text, options)
  if not text or type(text) ~= 'string' then
    vim.notify('Invalid text input for delimiter sorting', vim.log.levels.ERROR)
    return nil
  end

  if not options or type(options) ~= 'table' then
    vim.notify(
      'Invalid options provided for delimiter sorting',
      vim.log.levels.ERROR
    )
    return nil
  end

  local user_config = config.get_user_config()
  local delimiters = options.delimiter and { options.delimiter }
    or user_config.delimiters

  local has_leading_delimiter, has_trailing_delimiter, matches, top_translated_delimiter

  for _, delimiter in ipairs(delimiters) do
    top_translated_delimiter = utils.translate_delimiter(delimiter)
    matches = utils.split_by_delimiter(text, top_translated_delimiter)

    if #matches > 1 then
      has_leading_delimiter =
        string.match(text, '^' .. top_translated_delimiter)
      has_trailing_delimiter =
        string.match(text, top_translated_delimiter .. '$')
      break
    end
  end

  if matches == nil or #matches <= 1 then
    return text
  end

  -- Special case: if we have only 2 matches and one is empty,
  -- this indicates whitespace adjacent to a single item, not a list to sort.
  -- BUT only if this is from a text object selection (like 'aw'), not a manual selection.
  if #matches == 2 and (matches[1] == '' or matches[2] == '') then
    local non_empty_match = matches[1] ~= '' and matches[1] or matches[2]
    if non_empty_match and not string.match(non_empty_match, '%s') then
      return text
    end
  end

  -- Create array of items with their whitespace preserved.
  local items = {}
  for i, match in ipairs(matches) do
    local leading_ws = utils.get_leading_whitespace(match)
    local trailing_ws = utils.get_trailing_whitespace(match)
    local trimmed = utils.trim_leading_and_trailing_whitespace(match)

    -- Skip structural trailing empty segment when:
    -- 1. We have a trailing delimiter but no leading delimiter
    -- 2. This is the last segment and it's empty
    -- 3. This indicates the empty segment is structural, not content
    local is_structural_trailing_empty = has_trailing_delimiter
      and not has_leading_delimiter
      and i == #matches
      and match == ''

    if not is_structural_trailing_empty then
      if trimmed == '' and top_translated_delimiter ~= ' ' then
        -- For other delimiters, preserve whitespace-only segments.
        table.insert(items, {
          original = match,
          trimmed = trimmed,
          leading_ws = '',
          trailing_ws = match,
          original_position = i,
        })
      elseif trimmed ~= '' then
        table.insert(items, {
          original = match,
          trimmed = trimmed,
          leading_ws = leading_ws,
          trailing_ws = trailing_ws,
          original_position = i,
        })
      end
    end
  end

  -- Check if sorting will change the order.
  local original_order = {}
  for i, item in ipairs(items) do
    original_order[i] = item.original_position
  end

  -- Sort items by their trimmed content.
  table.sort(items, function(a, b)
    if options.reverse then
      return compare_strings(b.trimmed, a.trimmed, options)
    else
      return compare_strings(a.trimmed, b.trimmed, options)
    end
  end)

  -- Check if order actually changed.
  local order_changed = false
  for i, item in ipairs(items) do
    if item.original_position ~= original_order[i] then
      order_changed = true
      break
    end
  end

  -- Apply smart whitespace normalization (order changed OR inconsistent spacing with alignment).
  -- For natural sorting, preserve original whitespace even if order changed.
  local whitespace_config = user_config.whitespace or {}
  local needs_normalization = order_changed and not options.natural

  if not needs_normalization then
    local alignment_threshold = whitespace_config.alignment_threshold or 3
    local has_alignment = false
    local non_alignment_patterns = {}

    for _, item in ipairs(items) do
      if item.trimmed ~= '' then
        if string.len(item.leading_ws) >= alignment_threshold then
          has_alignment = true
        else
          non_alignment_patterns[item.leading_ws] = true
        end
      end
    end

    local pattern_count = 0
    for _ in pairs(non_alignment_patterns) do
      pattern_count = pattern_count + 1
    end

    -- If we have alignment whitespace AND inconsistent non-alignment patterns, normalize.
    -- OR if we have multiple space-only patterns of different lengths (inconsistent spacing).
    if has_alignment and pattern_count > 1 then
      needs_normalization = true
    elseif pattern_count > 1 then
      local all_spaces = true
      for pattern, _ in pairs(non_alignment_patterns) do
        if
          pattern ~= ''
          and (
            not string.match(pattern, '^%s+$')
            or string.match(pattern, '[^\32]')
          )
        then
          all_spaces = false
          break
        end
      end

      if all_spaces then
        needs_normalization = true
      end
    end
  end

  if needs_normalization then
    local alignment_threshold = whitespace_config.alignment_threshold or 3

    -- Collect all leading whitespace patterns.
    local whitespace_patterns = {}
    for _, item in ipairs(items) do
      if item.trimmed ~= '' then
        table.insert(whitespace_patterns, item.leading_ws)
      end
    end

    -- Detect dominant whitespace pattern.
    local dominant_pattern = utils.detect_dominant_whitespace(
      whitespace_patterns,
      alignment_threshold,
      top_translated_delimiter
    )

    -- Normalize whitespace for each item.
    for i, item in ipairs(items) do
      if item.trimmed ~= '' then
        -- For comma-separated values, first item should have no leading whitespace.
        if i == 1 and top_translated_delimiter == ',' then
          item.leading_ws = ''
        else
          item.leading_ws = utils.normalize_whitespace(
            item.leading_ws,
            dominant_pattern,
            alignment_threshold
          )
        end
      end
    end
  end

  local sorted_fragments = {}
  if options.unique then
    local seen = {}
    for _, item in ipairs(items) do
      local key = options.ignore_case and string.lower(item.trimmed)
        or item.trimmed
      if not seen[key] then
        seen[key] = true
        table.insert(
          sorted_fragments,
          item.leading_ws .. item.trimmed .. item.trailing_ws
        )
      end
    end
  else
    for _, item in ipairs(items) do
      table.insert(
        sorted_fragments,
        item.leading_ws .. item.trimmed .. item.trailing_ws
      )
    end
  end

  return (has_leading_delimiter and top_translated_delimiter or '')
    .. table.concat(sorted_fragments, top_translated_delimiter)
    .. (has_trailing_delimiter and top_translated_delimiter or '')
end

--- Sort lines of text according to sort options.
--- @param text string Multi-line text to sort
--- @param options SortOptions
--- @return string sorted_text
M.line_sort_text = function(text, options)
  if not text or text == '' then
    return text or ''
  end

  local lines = vim.split(text, '\n')

  if #lines <= 1 then
    return text
  end

  -- Create array of line objects with trimmed content for comparison.
  local line_items = {}
  for i, line in ipairs(lines) do
    local trimmed = utils.trim_leading_and_trailing_whitespace(line)
    table.insert(line_items, {
      original = line,
      trimmed = trimmed,
      original_position = i,
    })
  end

  -- Handle unique option first - remove duplicates before sorting.
  local items_to_sort = {}
  if options.unique then
    local seen = {}
    for _, item in ipairs(line_items) do
      local key = options.ignore_case and string.lower(item.trimmed)
        or item.trimmed
      if not seen[key] then
        seen[key] = true
        table.insert(items_to_sort, item)
      end
    end
  else
    items_to_sort = line_items
  end

  -- Sort lines using the same comparison logic as delimiter sorting but on trimmed content.
  table.sort(items_to_sort, function(a, b)
    if options.reverse then
      return compare_strings(b.trimmed, a.trimmed, options)
    else
      return compare_strings(a.trimmed, b.trimmed, options)
    end
  end)

  -- Extract original lines from sorted items.
  local result_lines = {}
  for _, item in ipairs(items_to_sort) do
    table.insert(result_lines, item.original)
  end

  -- Join lines back together.
  return table.concat(result_lines, '\n')
end

--- Sort by line, using our custom line sorting implementation.
--- @param bang string
--- @param arguments string
M.line_sort = function(bang, arguments)
  local selection = interface.get_visual_selection()
  local options = utils.parse_arguments(bang, arguments)

  -- Apply config defaults if not explicitly set by arguments
  local user_config = config.get_user_config()
  options.ignore_case = options.ignore_case or user_config.ignore_case

  local success, lines = pcall(
    vim.api.nvim_buf_get_lines,
    0,
    selection.from.row - 1,
    selection.to.row,
    false
  )
  if not success or not lines then
    vim.notify(
      string.format(
        'Failed to retrieve lines %d-%d from buffer',
        selection.from.row,
        selection.to.row
      ),
      vim.log.levels.ERROR
    )
    return
  end

  local text = table.concat(lines, '\n')

  local sorted_text = M.line_sort_text(text, options)
  if not sorted_text then
    vim.notify('Failed to sort the selected lines', vim.log.levels.ERROR)
    return
  end

  local sorted_lines = vim.split(sorted_text, '\n')
  local set_success = pcall(
    vim.api.nvim_buf_set_lines,
    0,
    selection.from.row - 1,
    selection.to.row,
    false,
    sorted_lines
  )
  if not set_success then
    vim.notify('Failed to set sorted lines in buffer', vim.log.levels.ERROR)
    return
  end
end

return M
