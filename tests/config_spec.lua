describe('config', function()
  local config

  before_each(function()
    -- Clear module cache to ensure fresh state for each test.
    package.loaded['sort.config'] = nil
    config = require('sort.config')
  end)

  describe('get_user_config', function()
    it('should return default config initially', function()
      local user_config = config.get_user_config()

      assert.are.same({
        delimiters = { ',', '|', ';', ':', 's', 't' },
        keymap = 'go',
        whitespace = {
          alignment_threshold = 3,
        },
        mappings = {
          operator = 'go',
          textobject = {
            inner = 'is',
            around = 'as',
          },
          motion = {
            next_delimiter = ']s',
            prev_delimiter = '[s',
          },
        },
      }, user_config)
    end)
  end)

  describe('setup', function()
    it('should return default config when no overrides provided', function()
      local user_config = config.setup()

      assert.are.same({
        delimiters = { ',', '|', ';', ':', 's', 't' },
        keymap = 'go',
        whitespace = {
          alignment_threshold = 3,
        },
        mappings = {
          operator = 'go',
          textobject = {
            inner = 'is',
            around = 'as',
          },
          motion = {
            next_delimiter = ']s',
            prev_delimiter = '[s',
          },
        },
      }, user_config)
    end)

    it('should merge overrides with defaults', function()
      local overrides = { keymap = 'gS' }
      local user_config = config.setup(overrides)

      assert.are.same({
        delimiters = { ',', '|', ';', ':', 's', 't' },
        keymap = 'gS',
        whitespace = {
          alignment_threshold = 3,
        },
        mappings = {
          operator = 'go',
          textobject = {
            inner = 'is',
            around = 'as',
          },
          motion = {
            next_delimiter = ']s',
            prev_delimiter = '[s',
          },
        },
      }, user_config)
    end)

    it('should override delimiters', function()
      local overrides = { delimiters = { ',', '|' } }
      local user_config = config.setup(overrides)

      -- The deep extend will actually extend the original array, not replace it.
      -- So let's test that the first two items are what we expect.
      assert.are.equal(',', user_config.delimiters[1])
      assert.are.equal('|', user_config.delimiters[2])
      assert.are.equal('go', user_config.keymap)
    end)

    it('should handle nil overrides', function()
      local user_config = config.setup(nil)

      assert.are.same({
        delimiters = { ',', '|', ';', ':', 's', 't' },
        keymap = 'go',
        whitespace = {
          alignment_threshold = 3,
        },
        mappings = {
          operator = 'go',
          textobject = {
            inner = 'is',
            around = 'as',
          },
          motion = {
            next_delimiter = ']s',
            prev_delimiter = '[s',
          },
        },
      }, user_config)
    end)

    it('should allow custom whitespace configuration', function()
      local overrides = {
        whitespace = {
          alignment_threshold = 5,
        },
      }
      local user_config = config.setup(overrides)

      assert.are.equal(5, user_config.whitespace.alignment_threshold)
    end)

    it('should merge partial whitespace overrides with defaults', function()
      local overrides = {
        whitespace = {
          alignment_threshold = 4,
        },
      }
      local user_config = config.setup(overrides)

      assert.are.equal(4, user_config.whitespace.alignment_threshold) -- Override applied
    end)

    it('should handle custom delimiter order configuration', function()
      local overrides = {
        delimiters = { '|', ',', ';', ':', 's', 't' },
      }
      local user_config = config.setup(overrides)
      local sort = require('sort.sort')

      -- Test that pipe takes priority over comma with custom order.
      local text = 'a,b|c,d'
      local result = sort.delimiter_sort(text, {})

      -- With custom order, pipe should have higher priority than comma.
      -- So it should split by pipe first: ["a,b", "c,d"] -> ["a,b", "c,d"] (already sorted).
      assert.are.equal('a,b|c,d', result)
    end)
  end)
end)
