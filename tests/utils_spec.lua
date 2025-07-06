describe('utils whitespace functions', function()
  local utils = require('sort.utils')

  describe('detect_dominant_whitespace', function()
    it('should detect single space as dominant', function()
      local whitespace_list = { '', ' ', ' ', '   ', ' ' }
      local result = utils.detect_dominant_whitespace(whitespace_list, 3)
      assert.are.equal(' ', result)
    end)

    it('should detect empty string as dominant', function()
      local whitespace_list = { '', '', '', ' ', ' ' }
      local result = utils.detect_dominant_whitespace(whitespace_list, 3)
      assert.are.equal('', result)
    end)

    it('should exclude alignment patterns from counting', function()
      local whitespace_list = { '', ' ', '    ', '     ', ' ' }
      local result = utils.detect_dominant_whitespace(whitespace_list, 3)
      assert.are.equal(' ', result) -- 4+ space patterns excluded
    end)

    it('should handle all alignment patterns', function()
      local whitespace_list = { '   ', '    ', '     ' }
      local result = utils.detect_dominant_whitespace(whitespace_list, 3)
      assert.are.equal(' ', result) -- Falls back to default
    end)

    it('should detect double space as dominant', function()
      local whitespace_list = { '  ', '  ', '  ', ' ', '' }
      local result = utils.detect_dominant_whitespace(whitespace_list, 3)
      assert.are.equal('  ', result)
    end)
  end)

  describe('normalize_whitespace', function()
    it('should preserve alignment whitespace', function()
      local result = utils.normalize_whitespace('   ', ' ', 3)
      assert.are.equal('   ', result)
    end)

    it('should normalize short whitespace to dominant', function()
      local result = utils.normalize_whitespace(' ', ' ', 3)
      assert.are.equal(' ', result)
    end)

    it('should normalize empty to dominant', function()
      local result = utils.normalize_whitespace('', ' ', 3)
      assert.are.equal(' ', result)
    end)

    it('should preserve long alignment whitespace', function()
      local result = utils.normalize_whitespace('    ', ' ', 3)
      assert.are.equal('    ', result)
    end)

    it('should handle tab characters as alignment', function()
      local result = utils.normalize_whitespace('\t\t\t', ' ', 3)
      assert.are.equal('\t\t\t', result)
    end)

    it('should normalize when dominant is empty string', function()
      local result = utils.normalize_whitespace(' ', '', 3)
      assert.are.equal('', result)
    end)
  end)
end)
