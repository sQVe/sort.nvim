describe('dot repeat functionality', function()
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

  -- Helper function to simulate operator marks.
  local function set_operator_marks(start_row, start_col, end_row, end_col)
    -- Set operator marks (1-based rows, 1-based cols for marks).
    vim.api.nvim_buf_set_mark(0, '[', start_row, start_col - 1, {})
    vim.api.nvim_buf_set_mark(0, ']', end_row, end_col - 1, {})
  end

  before_each(function()
    -- Clear any existing marks.
    pcall(vim.api.nvim_buf_del_mark, 0, '[')
    pcall(vim.api.nvim_buf_del_mark, 0, ']')
    pcall(vim.api.nvim_buf_del_mark, 0, '<')
    pcall(vim.api.nvim_buf_del_mark, 0, '>')
  end)

  describe('repeat visual mode operation', function()
    it('should repeat visual sort on subsequent selections', function()
      setup_buffer({ 'apple banana zebra', 'cherry date elderberry' })

      -- First operation: visual sort on line 1.
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      set_visual_marks(1, 1, 1, 17)
      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])

      -- Second operation: visual sort on line 2 using repeat.
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      set_visual_marks(2, 1, 2, 21)
      
      -- Simulate dot repeat by calling the same operation.
      operator.sort_operator('char', true)

      result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
      assert.are.equal('cherry date elderberry', result[2])
    end)
  end)

  describe('repeat normal mode operation', function()
    it('should repeat go$ operation with dot', function()
      setup_buffer({ 'zebra apple banana', 'date cherry elderberry' })

      -- First operation: go$ on line 1.
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      set_operator_marks(1, 1, 1, 18)
      operator.sort_operator('char', false)

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])

      -- Second operation: repeat on line 2.
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      set_operator_marks(2, 1, 2, 21)
      operator.sort_operator('char', false)

      result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
      assert.are.equal('cherry date elderberry', result[2])
    end)
  end)

  describe('mixed operation repeat', function()
    it('should remember most recent operation for dot repeat', function()
      setup_buffer({ 'zebra apple banana', 'cherry date elderberry' })

      -- First operation: visual mode sort on line 1.
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      set_visual_marks(1, 1, 1, 18)
      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])

      -- Second operation: normal mode gow (first word) on line 2.
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      set_operator_marks(2, 1, 2, 6) -- "cherry"
      operator.sort_operator('char', false)

      result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
      -- Line 2 should remain unchanged since "cherry" is a single word.
      assert.are.equal('cherry date elderberry', result[2])

      -- Third operation: dot repeat should repeat the last operation (gow).
      -- Move to a line with multiple words and repeat.
      setup_buffer({ 'apple banana zebra', 'elderberry cherry date' })
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      set_operator_marks(2, 1, 2, 11) -- "elderberry"
      operator.sort_operator('char', false)

      result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
      -- Should remain unchanged since selecting single word.
      assert.are.equal('elderberry cherry date', result[2])
    end)
  end)

  describe('dot repeat edge cases', function()
    it('should handle repeat after empty selection', function()
      setup_buffer('zebra apple banana')

      -- Operation on empty text.
      set_operator_marks(1, 1, 1, 1)
      operator.sort_operator('char', false)

      local result = get_buffer_content()
      -- Should remain unchanged.
      assert.are.equal('zebra apple banana', result[1])

      -- Repeat should also handle gracefully.
      set_operator_marks(1, 1, 1, 18)
      operator.sort_operator('char', false)

      result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
    end)

    it('should handle repeat with different text lengths', function()
      setup_buffer({ 'c b a', 'zebra apple banana cherry' })

      -- Short text first.
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      set_operator_marks(1, 1, 1, 5)
      operator.sort_operator('char', false)

      local result = get_buffer_content()
      assert.are.equal('a b c', result[1])

      -- Longer text repeat.
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      set_operator_marks(2, 1, 2, 25)
      operator.sort_operator('char', false)

      result = get_buffer_content()
      assert.are.equal('a b c', result[1])
      assert.are.equal('apple banana cherry zebra', result[2])
    end)
  end)
end)