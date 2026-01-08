describe('operator functionality', function()
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

    it('should sort multiline visual line selection alphabetically', function()
      setup_buffer({
        '        -- Visual marks are 0-based, string.sub is 1-based, so add 1',
        '        -- Also add 1 to end_pos to make selection inclusive',
        '        extracted_text = string.sub(line, start_pos[2] + 1, end_pos[2] + 1)',
      })

      -- Simulate visual line selection of lines 1-2
      -- For line mode, end_col should be set to the length of the last line
      local last_line =
        '        -- Also add 1 to end_pos to make selection inclusive'
      set_visual_marks(1, 1, 2, string.len(last_line))

      operator.sort_operator('line', true)

      local result = get_buffer_content()
      assert.are.equal(
        '        -- Also add 1 to end_pos to make selection inclusive',
        result[1]
      )
      assert.are.equal(
        '        -- Visual marks are 0-based, string.sub is 1-based, so add 1',
        result[2]
      )
      assert.are.equal(
        '        extracted_text = string.sub(line, start_pos[2] + 1, end_pos[2] + 1)',
        result[3]
      )
    end)

    it(
      'should sort multiline visual line selection with different indentation',
      function()
        setup_buffer({
          '    -- Second comment line',
          '  -- First comment line',
          '      -- Third comment line',
        })

        -- Simulate visual line selection of all lines
        local last_line = '      -- Third comment line'
        set_visual_marks(1, 1, 3, string.len(last_line))

        operator.sort_operator('line', true)

        local result = get_buffer_content()
        assert.are.equal('  -- First comment line', result[1])
        assert.are.equal('    -- Second comment line', result[2])
        assert.are.equal('      -- Third comment line', result[3])
      end
    )

    it(
      'should sort multiline visual line selection with mixed content',
      function()
        setup_buffer({
          'zebra = 1',
          'apple = 2',
          'banana = 3',
        })

        -- Simulate visual line selection of all lines
        local last_line = 'banana = 3'
        set_visual_marks(1, 1, 3, string.len(last_line))

        operator.sort_operator('line', true)

        local result = get_buffer_content()
        assert.are.equal('apple = 2', result[1])
        assert.are.equal('banana = 3', result[2])
        assert.are.equal('zebra = 1', result[3])
      end
    )
  end)

  describe('alphabetical sorting over numerical', function()
    it('should sort lines alphabetically not numerically', function()
      -- Keep natural sorting enabled but expect alphabetical sorting over numerical
      setup_buffer({
        'line 10',
        'line 2',
        'line 1',
      })

      -- Simulate visual line selection
      local last_line = 'line 1'
      set_visual_marks(1, 1, 3, string.len(last_line))

      operator.sort_operator('line', true)

      local result = get_buffer_content()
      -- Should be natural sorting (1, 2, 10) with natural sorting enabled
      assert.are.equal('line 1', result[1])
      assert.are.equal('line 2', result[2])
      assert.are.equal('line 10', result[3])
    end)

    it('should sort comment lines alphabetically', function()
      setup_buffer({
        '-- Z comment',
        '-- A comment',
        '-- B comment',
      })

      -- Simulate visual line selection
      local last_line = '-- B comment'
      set_visual_marks(1, 1, 3, string.len(last_line))

      operator.sort_operator('line', true)

      local result = get_buffer_content()
      assert.are.equal('-- A comment', result[1])
      assert.are.equal('-- B comment', result[2])
      assert.are.equal('-- Z comment', result[3])
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

    it(
      'should handle VM-004: mixed delimiters (comma priority over space)',
      function()
        setup_buffer('zebra, apple cherry, date')

        set_operator_marks(1, 1, 1, 25)

        operator.sort_operator('char')

        local result = get_buffer_content()
        assert.are.equal('apple cherry, date, zebra', result[1])
      end
    )

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

    it(
      'NM-002: should handle around word text object without changes (goaw)',
      function()
        setup_buffer('zebra apple banana cherry')

        -- Simulate goaw on "banana" - positions 13-19 (1-based): "banana ".
        -- This represents the around-word text object which includes trailing space.
        set_operator_marks(1, 13, 1, 19)

        operator.sort_operator('char', false)

        local result = get_buffer_content()
        -- Should remain unchanged - single word with whitespace should not be "sorted".
        assert.are.equal('zebra apple banana cherry', result[1])
      end
    )

    it(
      'should not treat single word with leading whitespace as sortable',
      function()
        setup_buffer('prefix apple suffix')

        -- Simulate selecting " apple" (space + word).
        set_operator_marks(1, 7, 1, 12)

        operator.sort_operator('char', false)

        local result = get_buffer_content()
        -- Should remain unchanged - leading space + single word is not sortable.
        assert.are.equal('prefix apple suffix', result[1])
      end
    )

    it(
      'should not treat single word with trailing whitespace as sortable',
      function()
        setup_buffer('prefix apple suffix')

        -- Simulate selecting "apple " (word + space).
        set_operator_marks(1, 8, 1, 13)

        operator.sort_operator('char', false)

        local result = get_buffer_content()
        -- Should remain unchanged - single word + trailing space is not sortable.
        assert.are.equal('prefix apple suffix', result[1])
      end
    )

    it('should handle inner word text object (goiw)', function()
      setup_buffer('zebra apple banana cherry')

      -- Simulate goiw on "banana" - just the word without spaces.
      set_operator_marks(1, 13, 1, 18)

      operator.sort_operator('char', false)

      local result = get_buffer_content()
      -- Should remain unchanged - single word is not sortable.
      assert.are.equal('zebra apple banana cherry', result[1])
    end)

    it(
      'should properly sort when text object contains multiple sortable items',
      function()
        setup_buffer('prefix zebra apple banana suffix')

        -- Simulate text object that includes multiple words (e.g., go3w).
        set_operator_marks(1, 8, 1, 25)

        operator.sort_operator('char', false)

        local result = get_buffer_content()
        -- Should sort the multi-word selection.
        assert.are.equal('prefix apple banana zebra suffix', result[1])
      end
    )
  end)

  describe('natural sorting with motions', function()
    before_each(function()
      -- Clear module cache to ensure fresh config state.
      package.loaded['sort.config'] = nil
    end)

    it('should use natural sorting by default for character motions', function()
      setup_buffer('item10,item2,item1')

      -- Simulate go$ - from position 1 to end of line.
      set_operator_marks(1, 1, 1, 18)

      operator.sort_operator('char')

      local result = get_buffer_content()
      -- Natural sorting should give item1,item2,item10 (not item1,item10,item2).
      assert.are.equal('item1,item2,item10', result[1])
    end)

    it('should use natural sorting by default for line motions', function()
      setup_buffer({
        'file10.txt',
        'file2.txt',
        'file1.txt',
      })

      -- Simulate go2j - sort 3 lines.
      set_operator_marks(1, 1, 3, 10)

      operator.sort_operator('line')

      local result = get_buffer_content()
      -- Natural sorting should give file1.txt, file2.txt, file10.txt.
      assert.are.same({
        'file1.txt',
        'file2.txt',
        'file10.txt',
      }, result)
    end)

    it('should respect natural_sort = false configuration', function()
      -- Clear module cache to ensure fresh config state.
      package.loaded['sort.config'] = nil
      package.loaded['sort.operator'] = nil

      -- Set up config with natural_sort disabled.
      local config = require('sort.config')
      config.setup({ natural_sort = false })

      -- Reload operator module to pick up new config.
      local operator_module = require('sort.operator')

      setup_buffer('item10,item2,item1')

      -- Simulate go$ - from position 1 to end of line.
      set_operator_marks(1, 1, 1, 18)

      operator_module.sort_operator('char')

      local result = get_buffer_content()
      -- Lexicographic sorting should give item1,item10,item2.
      assert.are.equal('item1,item10,item2', result[1])
    end)

    it('should use natural sorting with visual selections', function()
      setup_buffer('version10,version2,version1')

      -- Simulate visual selection.
      set_visual_marks(1, 1, 1, 27)

      operator.sort_operator('char', true) -- true for visual mode

      local result = get_buffer_content()
      -- Natural sorting should give version1,version2,version10.
      assert.are.equal('version1,version2,version10', result[1])
    end)

    it('should handle natural sorting with mixed delimiters', function()
      setup_buffer('step10|step2|step1')

      -- Simulate operator motion.
      set_operator_marks(1, 1, 1, 18)

      operator.sort_operator('char')

      local result = get_buffer_content()
      -- Natural sorting should give step1|step2|step10.
      assert.are.equal('step1|step2|step10', result[1])
    end)

    it('should handle natural sorting with space-delimited items', function()
      setup_buffer('task10 task2 task1')

      -- Simulate operator motion.
      set_operator_marks(1, 1, 1, 18)

      operator.sort_operator('char')

      local result = get_buffer_content()
      -- Natural sorting should give task1 task2 task10.
      assert.are.equal('task1 task2 task10', result[1])
    end)
  end)

  describe('multi-line list sorting inside braces', function()
    it(
      'should correctly sort multi-line comma-separated list inside braces',
      function()
        setup_buffer({
          'names = {',
          "  'Charlie',",
          "  'Angel',",
          "  'Chris',",
          "  'Bro',",
          '}',
        })

        -- Simulate gi{ motion - selecting content inside braces
        -- When { is at the end of a line, i{ selects from the next line
        set_operator_marks(2, 1, 5, 11) -- From start of line 2 to end of last comma

        operator.sort_operator('char')

        local result = get_buffer_content()
        -- Expected: sorted lines with proper formatting preserved
        assert.are.equal('names = {', result[1])
        assert.are.equal("  'Angel',", result[2])
        assert.are.equal("  'Bro',", result[3])
        assert.are.equal("  'Charlie',", result[4])
        assert.are.equal("  'Chris',", result[5])
        assert.are.equal('}', result[6])
      end
    )

    it(
      'should handle multi-line list with different indentation levels',
      function()
        setup_buffer({
          'const items = {',
          "    'zebra',",
          "    'apple',",
          "    'mango',",
          "    'banana',",
          '};',
        })

        -- Simulate gi{ motion
        set_operator_marks(2, 1, 5, 13) -- From start of line 2 to end of last comma

        operator.sort_operator('char')

        local result = get_buffer_content()
        assert.are.equal('const items = {', result[1])
        assert.are.equal("    'apple',", result[2])
        assert.are.equal("    'banana',", result[3])
        assert.are.equal("    'mango',", result[4])
        assert.are.equal("    'zebra',", result[5])
        assert.are.equal('};', result[6])
      end
    )

    it('should handle multi-line list without trailing commas', function()
      setup_buffer({
        'list = {',
        "  'item3'",
        "  'item1'",
        "  'item2'",
        '}',
      })

      -- Simulate gi{ motion
      set_operator_marks(2, 1, 4, 10) -- From start of line 2 to end of line 4

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('list = {', result[1])
      assert.are.equal("  'item1'", result[2])
      assert.are.equal("  'item2'", result[3])
      assert.are.equal("  'item3'", result[4])
      assert.are.equal('}', result[5])
    end)

    it(
      'should treat indented multi-line text objects as line motions',
      function()
        setup_buffer({
          'list = {',
          '  zebra,',
          '  apple,',
          '  banana,',
          '}',
        })

        -- Simulate indent text object selection: start at first non-whitespace,
        -- end before trailing comma on last line.
        set_operator_marks(2, 3, 4, 8)

        operator.sort_operator('char')

        local result = get_buffer_content()
        assert.are.equal('list = {', result[1])
        assert.are.equal('  apple,', result[2])
        assert.are.equal('  banana,', result[3])
        assert.are.equal('  zebra,', result[4])
        assert.are.equal('}', result[5])
      end
    )
  end)

  describe('partial line character motions', function()
    it('should use delimiter sorting for partial line selections', function()
      setup_buffer({
        'prefix [zebra, apple, banana] suffix',
        'another line',
      })

      -- Select just the content inside brackets (partial line)
      set_operator_marks(1, 9, 1, 28) -- From after [ to before ]

      operator.sort_operator('char')

      local result = get_buffer_content()
      assert.are.equal('prefix [apple, banana, zebra] suffix', result[1])
      assert.are.equal('another line', result[2])
    end)

    it(
      'should not treat partial multi-line selections as line motions',
      function()
        setup_buffer({
          'line1 start zebra',
          'apple banana',
          'cherry end line3',
        })

        -- Select from middle of line 1 to middle of line 3
        set_operator_marks(1, 13, 3, 6) -- From "zebra" to "cherry"

        operator.sort_operator('char')

        local result = get_buffer_content()
        -- The partial selection "zebra\napple banana\ncherry" gets sorted by delimiter
        -- This results in the text being rearranged across lines
        assert.are.equal('line1 start banana', result[1])
        assert.are.equal('cherry zebra', result[2])
        assert.are.equal('apple end line3', result[3])
      end
    )
  end)

  describe('visual block sorting', function()
    it('should sort text within visual block selection', function()
      setup_buffer({
        '1. Aaaa',
        '2. Cccc',
        '4. Gggg',
        '3. Dddd',
      })

      -- Simulate visual block selection of just the text part (columns 4-7)
      -- This selects "Aaaa", "Cccc", "Gggg", "Dddd"
      set_visual_marks(1, 4, 4, 7)

      operator.sort_operator('block', true)

      local result = get_buffer_content()
      -- Text should be sorted alphabetically within the block
      assert.are.equal('1. Aaaa', result[1])
      assert.are.equal('2. Cccc', result[2])
      assert.are.equal('4. Dddd', result[3])
      assert.are.equal('3. Gggg', result[4])
    end)

    it('should handle visual block with varying line lengths', function()
      setup_buffer({
        'foo: apple',
        'bar: cherry',
        'baz: banana',
        'qux: date',
      })

      -- Select the fruit names (columns 6-11)
      set_visual_marks(1, 6, 4, 11)

      operator.sort_operator('block', true)

      local result = get_buffer_content()
      -- Fruits should be sorted within the block
      assert.are.equal('foo: apple', result[1])
      assert.are.equal('bar: banana', result[2])
      assert.are.equal('baz: cherry', result[3])
      assert.are.equal('qux: date', result[4])
    end)

    it('should preserve text outside visual block selection', function()
      setup_buffer({
        'prefix zebra suffix',
        'prefix apple suffix',
        'prefix mango suffix',
      })

      -- Select just the middle words (columns 8-12)
      set_visual_marks(1, 8, 3, 12)

      operator.sort_operator('block', true)

      local result = get_buffer_content()
      -- Middle words should be sorted, prefix/suffix preserved
      assert.are.equal('prefix apple suffix', result[1])
      assert.are.equal('prefix mango suffix', result[2])
      assert.are.equal('prefix zebra suffix', result[3])
    end)
  end)
end)
