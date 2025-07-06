describe('operator functionality', function()
  local operator = require('sort.operator')
  local utils = require('sort.utils')

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

  -- Helper function to simulate operator marks.
  local function set_operator_marks(start_row, start_col, end_row, end_col)
    -- Set operator marks (1-based rows, 1-based cols for marks).
    vim.api.nvim_buf_set_mark(0, '[', start_row, start_col - 1, {})
    vim.api.nvim_buf_set_mark(0, ']', end_row, end_col - 1, {})
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

  describe('sort_operator with operator marks', function()
    it('should sort character motion from cursor to end of line', function()
      setup_buffer('zebra apple banana cherry')

      -- Simulate go$ - from position 1 to end of line.
      set_operator_marks(1, 1, 1, 25)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple banana cherry zebra', result[1])
    end)

    it('should sort partial selection within line', function()
      setup_buffer('prefix zebra apple banana suffix')

      -- Simulate sorting just the middle part (positions 8-25).
      set_operator_marks(1, 8, 1, 25)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('prefix apple banana zebra suffix', result[1])
    end)

    it('should sort entire line with line motion', function()
      setup_buffer('zebra apple banana cherry')

      -- Simulate line motion.
      set_operator_marks(1, 1, 1, 25)

      operator.sort_operator('line')

      local result = get_buffer_content()
      assert.are.equal('apple banana cherry zebra', result[1])
    end)

    it('should handle comma-separated text with operator marks', function()
      setup_buffer('cherry,apple,banana')

      set_operator_marks(1, 1, 1, 19)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple,banana,cherry', result[1])
    end)

    it('should handle multi-line character motion', function()
      setup_buffer({ 'line1 zebra apple', 'banana cherry line2' })

      -- Select from "zebra" on line 1 to "cherry" on line 2.
      set_operator_marks(1, 7, 2, 13)

      operator.sort_operator('char')

      local result = get_buffer_content()
      -- Should sort the selected portion across lines.
      assert.are.equal(
        'line1 apple banana cherry zebra line2',
        table.concat(result, ' ')
      )
    end)
  end)

  describe('sort_operator with visual marks', function()
    it('should sort basic visual character selection', function()
      setup_buffer('zebra apple banana cherry')

      -- Simulate visual selection from start to end.
      set_visual_marks(1, 1, 1, 25)

      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('apple banana cherry zebra', result[1])
    end)

    it('should sort visual line selection', function()
      setup_buffer('zebra apple banana cherry')

      set_visual_marks(1, 1, 1, 25)

      operator.sort_operator('line', true)

      local result = get_buffer_content()
      assert.are.equal('apple banana cherry zebra', result[1])
    end)

    it('should handle partial visual selection', function()
      setup_buffer('prefix zebra apple banana suffix')

      -- Select just the middle words (0-based: 7-25).
      set_visual_marks(1, 7, 1, 25)

      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('prefix apple banana zebra suffix', result[1])
    end)
  end)

  describe('edge cases', function()
    it('should handle empty text', function()
      setup_buffer('')

      set_operator_marks(1, 1, 1, 1)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('', result[1] or '')
    end)

    it('should handle single word', function()
      setup_buffer('word')

      set_operator_marks(1, 1, 1, 4)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('word', result[1])
    end)

    it('should handle text with no delimiters', function()
      setup_buffer('singleword')

      set_operator_marks(1, 1, 1, 10)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('singleword', result[1])
    end)

    it('should handle already sorted text', function()
      setup_buffer('apple banana cherry')

      set_operator_marks(1, 1, 1, 19)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple banana cherry', result[1])
    end)

    it('should handle mixed delimiter priorities', function()
      setup_buffer('c a,b d')

      set_operator_marks(1, 1, 1, 7)

      operator.sort_operator('char')

      local result = get_buffer_content()
      -- Should sort by comma (higher priority), so "c a" and "b d" -> "b d,c a".
      assert.are.equal('b d,c a', result[1])
    end)
  end)

  describe('delimiter priority', function()
    it('should prioritize comma over space', function()
      setup_buffer('zebra apple,banana cherry')

      set_operator_marks(1, 1, 1, 25)

      operator.sort_operator('char')

      local result = get_buffer_content()
      -- Should split by comma: ["zebra apple", "banana cherry"] -> ["banana cherry", "zebra apple"].
      assert.are.equal('banana cherry,zebra apple', result[1])
    end)

    it('should use space when no higher priority delimiters exist', function()
      setup_buffer('zebra apple banana')

      set_operator_marks(1, 1, 1, 18)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple banana zebra', result[1])
    end)

    it('should handle pipe delimiter', function()
      setup_buffer('cherry|apple|banana')

      set_operator_marks(1, 1, 1, 19)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple|banana|cherry', result[1])
    end)

    it('should handle semicolon delimiter', function()
      setup_buffer('cherry;apple;banana')

      set_operator_marks(1, 1, 1, 19)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple;banana;cherry', result[1])
    end)

    it('should handle colon delimiter', function()
      setup_buffer('cherry:apple:banana')

      set_operator_marks(1, 1, 1, 19)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple:banana:cherry', result[1])
    end)
  end)

  describe('smart whitespace normalization', function()
    it('should normalize inconsistent spacing to dominant pattern', function()
      setup_buffer('zebra, apple cherry, date')

      set_operator_marks(1, 1, 1, 25)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple cherry, date, zebra', result[1])
    end)

    it('should preserve no-space pattern when dominant', function()
      setup_buffer('cherry:apple:banana')

      set_operator_marks(1, 1, 1, 19)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple:banana:cherry', result[1])
    end)

    it('should preserve space pattern when dominant', function()
      setup_buffer('cherry, apple, banana')

      set_operator_marks(1, 1, 1, 21)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple, banana, cherry', result[1])
    end)

    it('should normalize mixed spacing to single space default', function()
      setup_buffer('a  b   c    d')

      set_operator_marks(1, 1, 1, 13)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('a b c d', result[1])
    end)

    it('should preserve alignment whitespace (3+ spaces)', function()
      setup_buffer('b,d,   e, f,l')

      set_operator_marks(1, 1, 1, 13)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('b, d,   e, f, l', result[1])
    end)

    it('should handle VM-004: mixed delimiters (comma priority over space)', function()
      setup_buffer('zebra, apple cherry, date')

      set_operator_marks(1, 1, 1, 25)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('apple cherry, date, zebra', result[1])
    end)

    it('should preserve leading whitespace of selection', function()
      setup_buffer('  zebra apple banana')

      set_operator_marks(1, 3, 1, 20)

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('  apple banana zebra', result[1])
    end)

    it('should handle visual mode with smart whitespace', function()
      setup_buffer('  cherry,apple,banana')

      set_visual_marks(1, 3, 1, 21)

      operator.sort_operator('char', true)

      local result = get_buffer_content()
      assert.are.equal('  apple,banana,cherry', result[1])
    end)
  end)

  describe('regression tests for NM-001 and NM-002', function()
    it('NM-001: should sort from cursor to end of line (go$)', function()
      setup_buffer('zebra apple banana cherry')

      -- Simulate go$ from beginning of line to end.
      set_operator_marks(1, 1, 1, 25)

      operator.sort_operator('char', false)

      local result = get_buffer_content()
      assert.are.equal('apple banana cherry zebra', result[1])
    end)

    it('NM-002: should handle around word text object without changes (goaw)', function()
      setup_buffer('zebra apple banana cherry')

      -- Simulate goaw on "banana" - positions 13-19 (1-based): "banana ".
      -- This represents the around-word text object which includes trailing space.
      set_operator_marks(1, 13, 1, 19)

      operator.sort_operator('char', false)

      local result = get_buffer_content()
      -- Should remain unchanged - single word with whitespace should not be "sorted".
      assert.are.equal('zebra apple banana cherry', result[1])
    end)

    it('should not treat single word with leading whitespace as sortable', function()
      setup_buffer('prefix apple suffix')

      -- Simulate selecting " apple" (space + word).
      set_operator_marks(1, 7, 1, 12)

      operator.sort_operator('char', false)

      local result = get_buffer_content()
      -- Should remain unchanged - leading space + single word is not sortable.
      assert.are.equal('prefix apple suffix', result[1])
    end)

    it('should not treat single word with trailing whitespace as sortable', function()
      setup_buffer('prefix apple suffix')

      -- Simulate selecting "apple " (word + space).
      set_operator_marks(1, 8, 1, 13)

      operator.sort_operator('char', false)

      local result = get_buffer_content()
      -- Should remain unchanged - single word + trailing space is not sortable.
      assert.are.equal('prefix apple suffix', result[1])
    end)

    it('should handle inner word text object (goiw)', function()
      setup_buffer('zebra apple banana cherry')

      -- Simulate goiw on "banana" - just the word without spaces.
      set_operator_marks(1, 13, 1, 18)

      operator.sort_operator('char', false)

      local result = get_buffer_content()
      -- Should remain unchanged - single word is not sortable.
      assert.are.equal('zebra apple banana cherry', result[1])
    end)

    it('should properly sort when text object contains multiple sortable items', function()
      setup_buffer('prefix zebra apple banana suffix')

      -- Simulate text object that includes multiple words (e.g., go3w).
      set_operator_marks(1, 8, 1, 25)

      operator.sort_operator('char', false)

      local result = get_buffer_content()
      -- Should sort the multi-word selection.
      assert.are.equal('prefix apple banana zebra suffix', result[1])
    end)
  end)
end)
