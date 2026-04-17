describe('textobjects', function()
  local textobjects = require('sort.textobjects')

  local function setup_buffer(content)
    vim.cmd('enew')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { content })
  end

  local function place_cursor(col_zero_based)
    vim.api.nvim_win_set_cursor(0, { 1, col_zero_based })
  end

  describe('_find_sortable_region', function()
    it('selects the segment the cursor is inside', function()
      setup_buffer('aa,bb,cc')
      place_cursor(3)

      local region = textobjects._find_sortable_region(false)

      assert.is_not_nil(region)
      assert.are.equal(4, region.from.column)
      assert.are.equal(5, region.to.column)
    end)

    it('snaps to preceding segment when cursor is on a delimiter', function()
      setup_buffer('aa,bb,cc')
      place_cursor(2)

      local region = textobjects._find_sortable_region(false)

      assert.is_not_nil(region)
      local selected =
        string.sub('aa,bb,cc', region.from.column, region.to.column)
      assert.are.equal('aa', selected)
    end)

    it('snaps to last segment when cursor is past the line', function()
      setup_buffer('aa,bb,cc')
      place_cursor(10)

      local region = textobjects._find_sortable_region(false)

      assert.is_not_nil(region)
      local selected =
        string.sub('aa,bb,cc', region.from.column, region.to.column)
      assert.are.equal('cc', selected)
    end)

    it(
      'snaps around preceding segment when cursor is on delimiter with include_delimiters',
      function()
        setup_buffer('aa,bb,cc')
        place_cursor(2)

        local region = textobjects._find_sortable_region(true)

        assert.is_not_nil(region)
        local selected =
          string.sub('aa,bb,cc', region.from.column, region.to.column)
        assert.are.equal('aa,', selected)
      end
    )

    it(
      'skips empty leading segment when cursor is on the leading delimiter',
      function()
        setup_buffer(',a,b')
        place_cursor(0)

        local region = textobjects._find_sortable_region(false)

        assert.is_not_nil(region)
        assert.is_true(region.to.column >= region.from.column)
        local selected =
          string.sub(',a,b', region.from.column, region.to.column)
        assert.are.equal('a', selected)
      end
    )

    it(
      'skips empty trailing segment when cursor is past the trailing delimiter',
      function()
        setup_buffer('a,b,')
        place_cursor(4)

        local region = textobjects._find_sortable_region(false)

        assert.is_not_nil(region)
        assert.is_true(region.to.column >= region.from.column)
        local selected =
          string.sub('a,b,', region.from.column, region.to.column)
        assert.are.equal('b', selected)
      end
    )
  end)

  describe('_apply_selection', function()
    before_each(function()
      pcall(vim.api.nvim_buf_del_mark, 0, '<')
      pcall(vim.api.nvim_buf_del_mark, 0, '>')
    end)

    it('sets < and > marks when invoked in visual mode', function()
      setup_buffer('aa,bb,cc')
      place_cursor(0)

      local selection = {
        from = { row = 1, column = 1 },
        to = { row = 1, column = 2 },
      }
      textobjects._apply_selection(selection, 'v')

      local lt = vim.api.nvim_buf_get_mark(0, '<')
      local gt = vim.api.nvim_buf_get_mark(0, '>')
      assert.are.equal(1, lt[1])
      assert.are.equal(0, lt[2])
      assert.are.equal(1, gt[1])
      assert.are.equal(1, gt[2])
    end)

    it('moves cursor to selection end in operator-pending mode', function()
      setup_buffer('aa,bb,cc')
      place_cursor(0)

      local selection = {
        from = { row = 1, column = 4 },
        to = { row = 1, column = 5 },
      }
      textobjects._apply_selection(selection, 'no')

      local cursor = vim.api.nvim_win_get_cursor(0)
      assert.are.equal(1, cursor[1])
      assert.are.equal(4, cursor[2])
    end)
  end)
end)
