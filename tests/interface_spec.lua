describe('interface', function()
  local interface = require('sort.interface')

  -- Simple mock data storage.
  local mock_data = {}

  before_each(function()
    mock_data = {
      last_command = nil,
      buf_lines = { 'mock line' },
      positions = {},
      set_text_calls = {},
      set_lines_calls = {},
    }

    -- Mock vim.cmd.
    local original_cmd = vim.cmd
    vim.cmd = function(command)
      mock_data.last_command = command
    end

    -- Mock vim.api functions.
    local original_get_lines = vim.api.nvim_buf_get_lines
    vim.api.nvim_buf_get_lines = function(_, _, _, _)
      return mock_data.buf_lines
    end

    local original_set_text = vim.api.nvim_buf_set_text
    vim.api.nvim_buf_set_text = function(
      buf,
      start_row,
      start_col,
      end_row,
      end_col,
      lines
    )
      table.insert(mock_data.set_text_calls, {
        buf = buf,
        start_row = start_row,
        start_col = start_col,
        end_row = end_row,
        end_col = end_col,
        lines = lines,
      })
    end

    -- Mock vim.fn.getpos.
    local original_getpos = vim.fn.getpos
    vim.fn.getpos = function(mark)
      return mock_data.positions[mark] or { 0, 1, 1, 0 }
    end

    -- Store originals for cleanup.
    mock_data._original_cmd = original_cmd
    mock_data._original_get_lines = original_get_lines
    mock_data._original_set_text = original_set_text
    mock_data._original_getpos = original_getpos
  end)

  -- selene: allow(undefined_variable)
  after_each(function()
    -- Restore original functions.
    vim.cmd = mock_data._original_cmd
    vim.api.nvim_buf_get_lines = mock_data._original_get_lines
    vim.api.nvim_buf_set_text = mock_data._original_set_text
    vim.fn.getpos = mock_data._original_getpos
  end)

  describe('execute_builtin_sort', function()
    it('should execute vim sort command', function()
      interface.execute_builtin_sort('!', 'n')
      assert.are.equal("'<,'>sort! n", mock_data.last_command)
    end)

    it('should execute vim sort command without bang', function()
      interface.execute_builtin_sort('', 'ui')
      assert.are.equal("'<,'>sort ui", mock_data.last_command)
    end)
  end)

  describe('get_text_between_columns', function()
    it('should get text between columns', function()
      mock_data.buf_lines = { 'hello world test' }

      local selection = {
        from = { row = 1, column = 7 },
        to = { row = 1, column = 11 },
      }

      local result = interface.get_text_between_columns(selection)
      assert.are.equal('world', result)
    end)
  end)

  describe('get_visual_selection', function()
    it('should get visual selection coordinates', function()
      mock_data.positions = {
        ["'<"] = { 0, 1, 1, 0 },
        ["'>"] = { 0, 1, 10, 0 },
      }

      local selection = interface.get_visual_selection()

      assert.are.equal(1, selection.from.row)
      assert.are.equal(1, selection.from.column)
      assert.are.equal(1, selection.to.row)
      assert.are.equal(10, selection.to.column)
    end)

    it('should handle reversed selection', function()
      mock_data.positions = {
        ["'<"] = { 0, 3, 5, 0 },
        ["'>"] = { 0, 1, 1, 0 },
      }

      local selection = interface.get_visual_selection()

      -- Should swap so from is before to.
      assert.are.equal(1, selection.from.row)
      assert.are.equal(1, selection.from.column)
      assert.are.equal(3, selection.to.row)
      assert.are.equal(5, selection.to.column)
    end)
  end)

  describe('set_line_text', function()
    it('should set text using nvim_buf_set_text', function()
      local selection = {
        from = { row = 1, column = 1 },
        to = { row = 1, column = 5 },
      }

      interface.set_line_text(selection, 'new text')

      assert.are.equal(1, #mock_data.set_text_calls)
      local call = mock_data.set_text_calls[1]
      assert.are.equal(0, call.buf)
      assert.are.same({ 'new text' }, call.lines)
    end)
  end)
end)
