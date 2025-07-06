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

  describe('natural sorting', function()
    -- Basic natural sorting tests
    it('should sort alphanumeric strings naturally', function()
      local text = 'item10,item2,item1,item20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1,item2,item10,item20', result)
    end)

    it('should sort filenames naturally', function()
      local text = 'file10.txt,file2.txt,file1.txt,file20.txt'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('file1.txt,file2.txt,file10.txt,file20.txt', result)
    end)

    it('should sort version numbers naturally', function()
      local text = 'v1.10.0,v1.2.0,v1.1.0,v2.0.0'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('v1.1.0,v1.2.0,v1.10.0,v2.0.0', result)
    end)

    it('should handle mixed strings and numbers', function()
      local text = 'abc,def10,def2,abc10,abc2'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('abc,abc2,abc10,def2,def10', result)
    end)

    it('should handle multiple numeric parts', function()
      local text = 'a1b2c3,a1b10c2,a1b2c10,a10b2c3'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('a1b2c3,a1b2c10,a1b10c2,a10b2c3', result)
    end)

    it('should handle leading zeros', function()
      local text = 'item001,item10,item02,item100'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item001,item02,item10,item100', result)
    end)

    it('should handle negative numbers naturally', function()
      local text = 'item-10,item-2,item-1,item-20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item-20,item-10,item-2,item-1', result)
    end)

    it('should handle decimal numbers naturally', function()
      local text = 'item1.10,item1.2,item1.1,item2.0'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1.1,item1.2,item1.10,item2.0', result)
    end)

    it('should handle numbers at the beginning', function()
      local text = '10item,2item,1item,20item'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('1item,2item,10item,20item', result)
    end)

    it('should handle numbers at the end', function()
      local text = 'item10,item2,item1,item20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1,item2,item10,item20', result)
    end)

    it('should handle numbers in the middle', function()
      local text = 'pre10post,pre2post,pre1post,pre20post'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('pre1post,pre2post,pre10post,pre20post', result)
    end)

    -- Edge cases
    it('should handle empty strings', function()
      local text = 'item10,,item2,item1'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal(',item1,item2,item10', result)
    end)

    it('should handle strings with only numbers', function()
      local text = '10,2,1,20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('1,2,10,20', result)
    end)

    it('should handle strings with only letters', function()
      local text = 'zebra,apple,banana,cherry'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('apple,banana,cherry,zebra', result)
    end)

    it('should handle very large numbers', function()
      local text = 'item999999999,item1000000000,item1,item2'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1,item2,item999999999,item1000000000', result)
    end)

    it('should handle mixed case with numbers', function()
      local text = 'Item10,item2,ITEM1,item20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('ITEM1,Item10,item2,item20', result)
    end)

    it('should handle unicode characters with numbers', function()
      local text = 'ñoño10,ñoño2,ñoño1,ñoño20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('ñoño1,ñoño2,ñoño10,ñoño20', result)
    end)

    it('should handle special characters with numbers', function()
      local text = 'item-10,item_2,item@1,item#20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item#20,item-10,item@1,item_2', result)
    end)

    -- Natural sorting with reverse option
    it('should sort naturally in reverse order', function()
      local text = 'item10,item2,item1,item20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = true,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item20,item10,item2,item1', result)
    end)

    -- Natural sorting with case-insensitive option
    it('should sort naturally case-insensitively', function()
      local text = 'Item10,item2,ITEM1,item20'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('ITEM1,item2,Item10,item20', result)
    end)

    -- Natural sorting with unique option
    it('should sort naturally with unique option', function()
      local text = 'item10,item2,item1,item10,item2'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = true,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1,item2,item10', result)
    end)

    -- Natural sorting with all options combined
    it('should handle natural sorting with all options', function()
      local text = 'Item10,item2,ITEM1,item10,Item2'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = true,
        unique = true,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item10,item2,ITEM1', result)
    end)

    -- Natural sorting with different delimiters
    it('should handle natural sorting with tab delimiter', function()
      local text = 'item10\titem2\titem1\titem20'
      local options = {
        delimiter = 't',
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1\titem2\titem10\titem20', result)
    end)

    it('should handle natural sorting with space delimiter', function()
      local text = 'item10 item2 item1 item20'
      local options = {
        delimiter = 's',
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1 item2 item10 item20', result)
    end)

    it('should handle natural sorting with pipe delimiter', function()
      local text = 'item10|item2|item1|item20'
      local options = {
        delimiter = '|',
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1|item2|item10|item20', result)
    end)

    -- Complex natural sorting scenarios
    it('should handle complex version-like strings', function()
      local text = 'v1.10.0-beta.2,v1.2.0,v1.10.0-beta.10,v1.2.0-alpha.1'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('v1.2.0,v1.2.0-alpha.1,v1.10.0-beta.2,v1.10.0-beta.10', result)
    end)

    it('should handle natural sorting with whitespace preservation', function()
      local text = '  item10  ,\titem2\t,  item1  ,  item20  '
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('  item1  ,\titem2\t,  item10  ,  item20  ', result)
    end)

    it('should handle natural sorting with mixed numeric patterns', function()
      local text = 'chapter1.section10,chapter10.section2,chapter2.section1,chapter1.section2'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('chapter1.section2,chapter1.section10,chapter2.section1,chapter10.section2', result)
    end)

    it('should handle natural sorting with path-like strings', function()
      local text = 'path/to/file10.txt,path/to/file2.txt,path/to/file1.txt,path/to/file20.txt'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('path/to/file1.txt,path/to/file2.txt,path/to/file10.txt,path/to/file20.txt', result)
    end)

    it('should handle natural sorting with zero-padded numbers', function()
      local text = 'item001,item010,item002,item100'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item001,item002,item010,item100', result)
    end)

    it('should handle natural sorting with mixed zero-padded and non-padded', function()
      local text = 'item1,item010,item2,item100'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.delimiter_sort(text, options)
      assert.are.equal('item1,item2,item010,item100', result)
    end)
  end)

  describe('natural sorting for lines', function()
    it('should sort lines naturally', function()
      local text = 'item10\nitem2\nitem1\nitem20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('item1\nitem2\nitem10\nitem20', result)
    end)

    it('should sort filename lines naturally', function()
      local text = 'file10.txt\nfile2.txt\nfile1.txt\nfile20.txt'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('file1.txt\nfile2.txt\nfile10.txt\nfile20.txt', result)
    end)

    it('should sort lines naturally with reverse option', function()
      local text = 'item10\nitem2\nitem1\nitem20'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = true,
        unique = false,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('item20\nitem10\nitem2\nitem1', result)
    end)

    it('should sort lines naturally case-insensitively', function()
      local text = 'Item10\nitem2\nITEM1\nitem20'
      local options = {
        delimiter = nil,
        ignore_case = true,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('ITEM1\nitem2\nItem10\nitem20', result)
    end)

    it('should sort lines naturally with unique option', function()
      local text = 'item10\nitem2\nitem1\nitem10\nitem2'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = true,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('item1\nitem2\nitem10', result)
    end)

    it('should handle natural sorting with whitespace in lines', function()
      local text = '  item10  \n\titem2\t\n  item1  \n  item20  '
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('  item1  \n\titem2\t\n  item10  \n  item20  ', result)
    end)

    it('should handle natural sorting with empty lines', function()
      local text = 'item10\n\nitem2\nitem1\n'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('\n\nitem1\nitem2\nitem10', result)
    end)

    it('should handle complex natural line sorting', function()
      local text = 'chapter1.section10\nchapter10.section2\nchapter2.section1\nchapter1.section2'
      local options = {
        delimiter = nil,
        ignore_case = false,
        numerical = nil,
        reverse = false,
        unique = false,
        natural = true,
      }

      local result = sort.line_sort_text(text, options)
      assert.are.equal('chapter1.section2\nchapter1.section10\nchapter2.section1\nchapter10.section2', result)
    end)
  end)
end)
