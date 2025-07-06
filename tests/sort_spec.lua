describe('sort', function()
  local sort = require('sort.sort')

  describe('delimiter_sort', function()
    it('should sort comma-separated values', function()
      local text = 'cherry,apple,banana'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('apple,banana,cherry', result)
    end)

    it('should sort in reverse order', function()
      local text = 'cherry,apple,banana'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = true,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('cherry,banana,apple', result)
    end)

    it('should remove duplicates when unique is true', function()
      local text = 'cherry,apple,banana,apple,cherry'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('apple,banana,cherry', result)
    end)

    it('should handle leading and trailing delimiters', function()
      local text = ',cherry,apple,banana,'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal(',,,apple,banana,cherry,', result)
    end)

    it('should return original text if no delimiters found', function()
      local text = 'singleword'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('singleword', result)
    end)

    -- Empty segments handling tests.
    it('should handle empty segments between delimiters', function()
      local text = 'apple,,banana,cherry'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal(',apple,banana,cherry', result)
    end)

    it('should handle multiple consecutive empty segments', function()
      local text = 'apple,,,banana,,cherry'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal(',,,apple,banana,cherry', result)
    end)

    it('should handle only empty segments', function()
      local text = ',,,'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal(',,,,,', result)
    end)

    -- Delimiter translation tests.
    it('should handle tab delimiter translation', function()
      local text = 'cherry\tapple\tbanana'
      local options = {
        delimiter = 't',
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('apple\tbanana\tcherry', result)
    end)

    it('should handle space delimiter translation', function()
      local text = 'cherry apple banana'
      local options = {
        delimiter = 's',
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('apple banana cherry', result)
    end)

    -- Negative numbers tests.
    it('should sort negative decimal numbers', function()
      local text = '10,-5,2,-10,0'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = 10,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('-10,-5,0,2,10', result)
    end)

    it('should sort negative binary numbers', function()
      local text = '1010,-101,101,-1010'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = 2,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('-1010,-101,101,1010', result)
    end)

    it('should sort negative octal numbers', function()
      local text = '10,-7,5,-10,0'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = 8,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('-10,-7,0,5,10', result)
    end)

    it('should sort negative hexadecimal numbers', function()
      local text = 'FF,-A,10,-FF,0'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = 16,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('-FF,-A,0,10,FF', result)
    end)

    -- Case-insensitive uniqueness tests.
    it('should handle case-insensitive uniqueness', function()
      local text = 'Apple,apple,APPLE,banana,Banana'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = false,
        unique = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('Apple,banana', result)
    end)

    it('should handle case-insensitive uniqueness with mixed case', function()
      local text = 'Cherry,cherry,BANANA,banana,Apple'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = false,
        unique = true,
      }

      local result = sort.delimiter_sort(text, options)
      -- Current implementation behavior: sorts case-insensitively but preserves first sorted case.
      assert.are.equal('Apple,banana,cherry', result)
    end)

    -- Complex whitespace preservation tests.
    it('should preserve leading and trailing whitespace', function()
      local text = '  apple  ,\tbananа\t,  cherry  '
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('  apple  ,\tbananа\t,  cherry  ', result)
    end)

    it('should handle mixed whitespace types', function()
      local text = 'cherry\n,apple\r,banana\t'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      -- The actual result from implementation (whitespace preserved during sort).
      assert.are.equal('apple\r,banana\t,cherry\n', result)
    end)

    it('should handle whitespace-only segments', function()
      local text = 'apple,   ,banana,\t\t,cherry'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      -- Current behavior: whitespace-only segments are preserved with original whitespace.
      assert.are.equal('\t\t,   ,apple,banana,cherry', result)
    end)

    -- Unicode character handling tests.
    it('should handle Unicode characters in content', function()
      local text = 'ñoño,árbol,zebra,äpfel'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('zebra,árbol,äpfel,ñoño', result)
    end)

    it('should handle Unicode delimiters', function()
      local text = 'cherry→apple→banana'
      local options = {
        delimiter = '→',
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('apple→banana→cherry', result)
    end)

    it('should handle emoji characters', function()
      local text = '🍎,🍌,🍒'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('🍌,🍎,🍒', result)
    end)

    -- Option combinations tests.
    it(
      'should handle all options combined (ignore_case + numerical + reverse + unique)',
      function()
        local text = '10,Apple,5,banana,Apple,10,BANANA'
        local options = {
          delimiter = nil,
          ignore_case = true,
          numerical = 10,
          reverse = true,
          unique = true,
        }

        local result = sort.delimiter_sort(text, options)
        -- Numbers are non-parsed strings, "5" and "10" retain duplicates until unique is applied.
        assert.are.equal('10,5,banana,Apple', result)
      end
    )

    it('should handle ignore_case + reverse + unique', function()
      local text = 'Apple,banana,APPLE,Cherry,banana'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = true,
        unique = true,
      }

      local result = sort.delimiter_sort(text, options)
      -- After case-insensitive reverse sort and unique.
      assert.are.equal('Cherry,banana,APPLE', result)
    end)

    it('should handle numerical + reverse + unique', function()
      local text = '10,5,20,10,5,15'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = 10,
        reverse = true,
        unique = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('20,15,10,5', result)
    end)

    it('should handle ignore_case + numerical + unique', function()
      local text = '10a,5B,20A,10A,5b'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = 10,
        reverse = false,
        unique = true,
      }

      local result = sort.delimiter_sort(text, options)
      -- With numerical sorting, these are sorted by numeric value first, then alphabetically.
      assert.are.equal('5b,10A,20A', result)
    end)

    it(
      'should handle mixed delimiters with proper whitespace normalization',
      function()
        local text = 'zebra, apple cherry, date'
        local options = {
          delimiter = nil,
          ignore_case = false,
          numerical = nil,
          reverse = false,
          unique = false,
        }

        local result = sort.delimiter_sort(text, options)
        assert.are.equal('apple cherry, date, zebra', result)
      end
    )

    it(
      'should preserve alignment whitespace (3+ spaces) while normalizing others',
      function()
        local text = 'b,d,   e, f,l'
        local options = {
          delimiter = nil,
          ignore_case = false,
          numerical = nil,
          reverse = false,
          unique = false,
        }

        local result = sort.delimiter_sort(text, options)
        assert.are.equal('b, d,   e, f, l', result)
      end
    )
  end)

  describe('line_sort_text', function()
    it('should sort lines alphabetically', function()
      local text = 'cherry\napple\nbanana'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('apple\nbanana\ncherry', result)
    end)

    it('should sort lines in reverse order', function()
      local text = 'apple\nbanana\ncherry'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = true,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('cherry\nbanana\napple', result)
    end)

    it('should handle case-insensitive sorting', function()
      local text = 'Cherry\napple\nBanana'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('apple\nBanana\nCherry', result)
    end)

    it('should remove duplicate lines when unique is true', function()
      local text = 'apple\nbanana\napple\ncherry\nbanana'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('apple\nbanana\ncherry', result)
    end)

    it('should handle case-insensitive uniqueness', function()
      local text = 'Apple\napple\nBanana\nbanana\nAPPLE'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = false,
        unique = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('Apple\nBanana', result)
    end)

    it('should sort numerical lines', function()
      local text = '10\n2\n100\n1'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = 10,
        reverse = false,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('1\n2\n10\n100', result)
    end)

    it('should handle empty lines', function()
      local text = 'cherry\n\napple\n\nbanana'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('\n\napple\nbanana\ncherry', result)
    end)

    it('should preserve whitespace in lines', function()
      local text = '  cherry  \n\tapple\t\n banana '
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('\tapple\t\n banana \n  cherry  ', result)
    end)

    it('should handle single line input', function()
      local text = 'single line'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('single line', result)
    end)

    it('should handle empty input', function()
      local text = ''
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('', result)
    end)

    it(
      'should handle mixed options (case-insensitive + reverse + unique)',
      function()
        local text = 'Apple\nbanana\nAPPLE\nCherry\nbanana'
        local options = {
          delimiter = nil,
          ignore_case = true,
          numerical = nil,
          reverse = true,
          unique = true,
        }

        local result = sort.line_sort_text(text, options)
        assert.are.equal('Cherry\nbanana\nApple', result)
      end
    )

    it('should handle numerical + reverse + unique', function()
      local text = '10\n5\n20\n10\n5\n15'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = 10,
        reverse = true,
        unique = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('20\n15\n10\n5', result)
    end)
  end)
end)
