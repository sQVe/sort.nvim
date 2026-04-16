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
  end)
end)
