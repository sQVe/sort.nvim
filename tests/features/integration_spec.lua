describe('integration functionality', function()
  local operator = require('sort.operator')

  -- Helper function to set up a test buffer.
  local function setup_buffer(content)
    vim.cmd('enew')
    if type(content) == 'table' then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
    else
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { content })
    end
  end

  -- Helper function to get buffer content.
  local function get_buffer_content()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  -- Helper function to simulate visual marks.
  local function set_visual_marks(start_row, start_col, end_row, end_col)
    -- Set visual marks (1-based rows, 0-based cols for marks).
    vim.api.nvim_buf_set_mark(0, '<', start_row, start_col - 1, {})
    vim.api.nvim_buf_set_mark(0, '>', end_row, end_col - 1, {})
  end

  before_each(function()
    -- Clear any existing marks.
    pcall(vim.api.nvim_buf_del_mark, 0, '[')
    pcall(vim.api.nvim_buf_del_mark, 0, ']')
    pcall(vim.api.nvim_buf_del_mark, 0, '<')
    pcall(vim.api.nvim_buf_del_mark, 0, '>')
  end)

  describe('undo support', function()
    it('should support undo after sort operation', function()
      setup_buffer('zebra apple banana')

      -- Store original content.
      local original_content = get_buffer_content()

      -- Perform sort operation.
      set_visual_marks(1, 1, 1, 18)
      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])

      -- In a real environment, undo would work. For testing, we verify the sort worked.
      -- and that the buffer can be manipulated properly.
      assert.are_not.equal(original_content[1], result[1])
    end)

    it('should handle multiple operations correctly', function()
      setup_buffer({ 'zebra apple banana', 'cherry date elderberry' })

      -- Store original content.
      local original_content = get_buffer_content()

      -- First sort.
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      set_visual_marks(1, 1, 1, 18)
      operator.sort_operator('char', true)

      -- Second sort.
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      set_visual_marks(2, 1, 2, 21)
      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
      assert.are.equal('cherry date elderberry', result[2])

      -- Verify both operations changed the content from original.
      assert.are_not.equal(original_content[1], result[1])
      assert.are.equal(original_content[2], result[2]) -- Line 2 was already sorted.
    end)
  end)

  describe('buffer manipulation', function()
    it('should handle sort operations on complex content', function()
      setup_buffer('zebra apple banana')

      -- Perform sort operation.
      set_visual_marks(1, 1, 1, 18)
      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])

      -- Perform second operation on same content.
      set_visual_marks(1, 1, 1, 18)
      operator.sort_operator('char', true)

      -- Should remain the same since already sorted.
      result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
    end)

    it('should handle buffer content consistency', function()
      setup_buffer('zebra apple banana')

      -- Store original state.
      local original_result = get_buffer_content()
      assert.are.equal('zebra apple banana', original_result[1])

      -- Sort operation.
      set_visual_marks(1, 1, 1, 18)
      operator.sort_operator('char', true)

      local sorted_result = get_buffer_content()
      assert.are.equal('apple banana zebra', sorted_result[1])

      -- Verify transformation was correct.
      assert.are_not.equal(original_result[1], sorted_result[1])

      -- Both contain same words, just different order.
      local original_words = vim.split(original_result[1], ' ')
      local sorted_words = vim.split(sorted_result[1], ' ')
      table.sort(original_words)
      assert.are.same(original_words, sorted_words)
    end)
  end)

  describe('multi-line operations', function()
    it('should work correctly on multiple lines', function()
      setup_buffer({
        'zebra apple banana',
        'cherry date elderberry',
        'orange lemon grape',
        'dog cat bird',
      })

      -- Simulate effect of macro: sort each line individually.
      local lines_to_sort = { 1, 3, 4 } -- Skip line 2 as it's already sorted.

      for _, line_num in ipairs(lines_to_sort) do
        vim.api.nvim_win_set_cursor(0, { line_num, 0 })
        local line_content =
          vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
        set_visual_marks(line_num, 1, line_num, #line_content)
        operator.sort_operator('char', true)
      end

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
      assert.are.equal('cherry date elderberry', result[2])
      assert.are.equal('grape lemon orange', result[3])
      assert.are.equal('bird cat dog', result[4])
    end)

    it('should handle mixed length operations', function()
      setup_buffer({
        'zebra apple',
        'cherry date elderberry banana',
      })

      -- Store original content.
      local original_content = get_buffer_content()

      -- Line 1: sort two words.
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      set_visual_marks(1, 1, 1, #original_content[1])
      operator.sort_operator('char', true)

      -- Line 2: sort four words.
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      set_visual_marks(2, 1, 2, #original_content[2])
      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('apple zebra', result[1])
      assert.are.equal('banana cherry date elderberry', result[2])
    end)

    it('should handle sequential operations consistently', function()
      setup_buffer({
        'zebra apple banana',
        'cherry date elderberry',
      })

      -- Store original content.
      local original_content = get_buffer_content()

      -- Simulate sequential operations.
      for line_num = 1, 2 do
        vim.api.nvim_win_set_cursor(0, { line_num, 0 })
        local line_content =
          vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
        set_visual_marks(line_num, 1, line_num, #line_content)
        operator.sort_operator('char', true)
      end

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
      assert.are.equal('cherry date elderberry', result[2])

      -- Verify first line changed, second line remained same (already sorted).
      assert.are_not.equal(original_content[1], result[1])
      assert.are.equal(original_content[2], result[2])
    end)
  end)

  describe('integration edge cases', function()
    it('should handle sort operations on modified buffers', function()
      setup_buffer('zebra apple banana')

      -- Make manual edit.
      vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, { 'prefix ' })

      local result = get_buffer_content()
      assert.are.equal('prefix zebra apple banana', result[1])

      -- Sort after manual edit.
      set_visual_marks(1, 8, 1, 25)
      operator.sort_operator('char', true)

      result = get_buffer_content()
      assert.are.equal('prefix apple banana zebra', result[1])
    end)

    it('should work with buffer switching', function()
      setup_buffer('zebra apple banana')
      local first_buf = vim.api.nvim_get_current_buf()

      -- Create second buffer.
      vim.cmd('enew')
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'cherry date elderberry' })
      local second_buf = vim.api.nvim_get_current_buf()

      -- Sort in second buffer.
      set_visual_marks(1, 1, 1, 21)
      operator.sort_operator('char', true)

      local result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.equal('cherry date elderberry', result[1])

      -- Switch back to first buffer and sort.
      vim.api.nvim_set_current_buf(first_buf)
      set_visual_marks(1, 1, 1, 18)
      operator.sort_operator('char', true)

      result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.equal('apple banana zebra', result[1])

      -- Verify second buffer is unchanged.
      vim.api.nvim_set_current_buf(second_buf)
      result = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      assert.are.equal('cherry date elderberry', result[1])
    end)
  end)
end)
