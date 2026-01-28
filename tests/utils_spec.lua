describe('utils', function()
  local utils = require('sort.utils')

  describe('get_leading_whitespace', function()
    it('should return leading whitespace', function()
      local result = utils.get_leading_whitespace('  hello')
      assert.are.equal('  ', result)
    end)

    it('should return empty string when no leading whitespace', function()
      local result = utils.get_leading_whitespace('hello')
      assert.are.equal('', result)
    end)

    it('should return all whitespace for whitespace-only string', function()
      local result = utils.get_leading_whitespace('   ')
      assert.are.equal('   ', result)
    end)

    it('should handle tabs as whitespace', function()
      local result = utils.get_leading_whitespace('\t\thello')
      assert.are.equal('\t\t', result)
    end)

    it('should handle mixed whitespace', function()
      local result = utils.get_leading_whitespace(' \t hello')
      assert.are.equal(' \t ', result)
    end)

    it('should return empty string for empty input', function()
      local result = utils.get_leading_whitespace('')
      assert.are.equal('', result)
    end)
  end)

  describe('get_trailing_whitespace', function()
    it('should return trailing whitespace', function()
      local result = utils.get_trailing_whitespace('hello  ')
      assert.are.equal('  ', result)
    end)

    it('should return empty string when no trailing whitespace', function()
      local result = utils.get_trailing_whitespace('hello')
      assert.are.equal('', result)
    end)

    it('should return all whitespace for whitespace-only string', function()
      local result = utils.get_trailing_whitespace('   ')
      assert.are.equal('   ', result)
    end)

    it('should handle tabs as whitespace', function()
      local result = utils.get_trailing_whitespace('hello\t\t')
      assert.are.equal('\t\t', result)
    end)

    it('should handle mixed whitespace', function()
      local result = utils.get_trailing_whitespace('hello \t ')
      assert.are.equal(' \t ', result)
    end)

    it('should return empty string for empty input', function()
      local result = utils.get_trailing_whitespace('')
      assert.are.equal('', result)
    end)
  end)

  describe('split_by_delimiter', function()
    it('should return single empty string for empty input', function()
      local result = utils.split_by_delimiter('', ',')
      assert.are.same({ '' }, result)
    end)

    it('should return single element when delimiter not found', function()
      local result = utils.split_by_delimiter('hello', ',')
      assert.are.same({ 'hello' }, result)
    end)

    it('should split by delimiter', function()
      local result = utils.split_by_delimiter('a,b,c', ',')
      assert.are.same({ 'a', 'b', 'c' }, result)
    end)

    it('should handle delimiter at start', function()
      local result = utils.split_by_delimiter(',a,b', ',')
      assert.are.same({ '', 'a', 'b' }, result)
    end)

    it('should handle delimiter at end', function()
      local result = utils.split_by_delimiter('a,b,', ',')
      assert.are.same({ 'a', 'b', '' }, result)
    end)

    it('should handle consecutive delimiters', function()
      local result = utils.split_by_delimiter('a,,b', ',')
      assert.are.same({ 'a', '', 'b' }, result)
    end)

    it('should handle multi-character delimiter', function()
      local result = utils.split_by_delimiter('a::b::c', '::')
      assert.are.same({ 'a', 'b', 'c' }, result)
    end)

    it('should handle tab delimiter', function()
      local result = utils.split_by_delimiter('a\tb\tc', '\t')
      assert.are.same({ 'a', 'b', 'c' }, result)
    end)
  end)

  describe('parse_arguments', function()
    it('should set numerical to 2 for binary flag', function()
      local result = utils.parse_arguments('', 'b')
      assert.are.equal(2, result.numerical)
    end)

    it('should set numerical to 8 for octal flag', function()
      local result = utils.parse_arguments('', 'o')
      assert.are.equal(8, result.numerical)
    end)

    it('should set numerical to 16 for hex flag', function()
      local result = utils.parse_arguments('', 'x')
      assert.are.equal(16, result.numerical)
    end)

    it('should set numerical to 10 for decimal flag', function()
      local result = utils.parse_arguments('', 'n')
      assert.are.equal(10, result.numerical)
    end)

    it('should set numerical to false when no flag', function()
      local result = utils.parse_arguments('', '')
      assert.are.equal(false, result.numerical)
    end)

    it('should set reverse to true when bang is !', function()
      local result = utils.parse_arguments('!', '')
      assert.are.equal(true, result.reverse)
    end)

    it('should set reverse to false when bang is empty', function()
      local result = utils.parse_arguments('', '')
      assert.are.equal(false, result.reverse)
    end)

    it('should set ignore_case when i flag present', function()
      local result = utils.parse_arguments('', 'i')
      assert.are.equal(true, result.ignore_case)
    end)

    it('should set unique when u flag present', function()
      local result = utils.parse_arguments('', 'u')
      assert.are.equal(true, result.unique)
    end)

    it('should set natural when z flag present', function()
      local result = utils.parse_arguments('', 'z')
      assert.are.equal(true, result.natural)
    end)

    it('should parse multiple flags', function()
      local result = utils.parse_arguments('!', 'iuz')
      assert.are.equal(true, result.reverse)
      assert.are.equal(true, result.ignore_case)
      assert.are.equal(true, result.unique)
      assert.are.equal(true, result.natural)
    end)

    it('should parse delimiter t', function()
      local result = utils.parse_arguments('', 't')
      assert.are.equal('t', result.delimiter)
    end)

    it('should parse delimiter s', function()
      local result = utils.parse_arguments('', 's')
      assert.are.equal('s', result.delimiter)
    end)

    it('should parse punctuation delimiter', function()
      local result = utils.parse_arguments('', ',')
      assert.are.equal(',', result.delimiter)
    end)

    it('should use first numerical flag when multiple provided', function()
      local result = utils.parse_arguments('', 'bx')
      assert.are.equal(2, result.numerical)
    end)

    it('should set delimiter to nil when no delimiter provided', function()
      local result = utils.parse_arguments('', 'iuz')
      assert.is_nil(result.delimiter)
    end)
  end)

  describe('parse_number', function()
    it('should parse binary number with base 2', function()
      local result = utils.parse_number('1010', 2)
      assert.are.equal(10, result)
    end)

    it('should parse octal number with base 8', function()
      local result = utils.parse_number('77', 8)
      assert.are.equal(63, result)
    end)

    it('should parse decimal number with base 10', function()
      local result = utils.parse_number('42', 10)
      assert.are.equal(42, result)
    end)

    it('should parse hex number with 0x prefix', function()
      local result = utils.parse_number('0xFF', 16)
      assert.are.equal(255, result)
    end)

    it('should parse hex number without 0x prefix (fallback)', function()
      local result = utils.parse_number('FF', 16)
      assert.are.equal(255, result)
    end)

    it('should parse negative number', function()
      local result = utils.parse_number('-42', 10)
      assert.are.equal(-42, result)
    end)

    it('should return nil when no valid number', function()
      local result = utils.parse_number('abc', 10)
      assert.is_nil(result)
    end)

    it('should default to base 10', function()
      local result = utils.parse_number('42')
      assert.are.equal(42, result)
    end)

    it('should parse decimal with fractional part', function()
      local result = utils.parse_number('3.14', 10)
      assert.are.equal(3.14, result)
    end)

    it('should parse partial valid binary from mixed input', function()
      local result = utils.parse_number('123', 2)
      assert.are.equal(1, result)
    end)

    it('should return nil for empty string', function()
      local result = utils.parse_number('', 10)
      assert.is_nil(result)
    end)
  end)

  describe('translate_delimiter', function()
    it('should translate t to tab', function()
      local result = utils.translate_delimiter('t')
      assert.are.equal('\t', result)
    end)

    it('should translate s to space', function()
      local result = utils.translate_delimiter('s')
      assert.are.equal(' ', result)
    end)

    it('should return other delimiters unchanged', function()
      local result = utils.translate_delimiter(',')
      assert.are.equal(',', result)
    end)

    it('should return pipe unchanged', function()
      local result = utils.translate_delimiter('|')
      assert.are.equal('|', result)
    end)
  end)

  describe('trim_leading_and_trailing_whitespace', function()
    it('should trim leading whitespace', function()
      local result = utils.trim_leading_and_trailing_whitespace('  hello')
      assert.are.equal('hello', result)
    end)

    it('should trim trailing whitespace', function()
      local result = utils.trim_leading_and_trailing_whitespace('hello  ')
      assert.are.equal('hello', result)
    end)

    it('should trim both leading and trailing', function()
      local result = utils.trim_leading_and_trailing_whitespace('  hello  ')
      assert.are.equal('hello', result)
    end)

    it('should preserve internal whitespace', function()
      local result =
        utils.trim_leading_and_trailing_whitespace('  hello world  ')
      assert.are.equal('hello world', result)
    end)

    it('should return empty for whitespace-only', function()
      local result = utils.trim_leading_and_trailing_whitespace('   ')
      assert.are.equal('', result)
    end)

    it('should return empty for empty input', function()
      local result = utils.trim_leading_and_trailing_whitespace('')
      assert.are.equal('', result)
    end)
  end)

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

  describe('detect_dominant_whitespace with comma delimiter', function()
    it(
      'should return space when delimiter is comma and dominant is empty but has spaces',
      function()
        local whitespace_list = { '', '', ' ' }
        local result = utils.detect_dominant_whitespace(whitespace_list, 3, ',')
        assert.are.equal(' ', result)
      end
    )

    it(
      'should return empty when delimiter is comma and only empty strings exist',
      function()
        local whitespace_list = { '', '', '' }
        local result = utils.detect_dominant_whitespace(whitespace_list, 3, ',')
        assert.are.equal('', result)
      end
    )

    it(
      'should return space when delimiter is comma and multiple non-empty patterns',
      function()
        local whitespace_list = { ' ', '  ' }
        local result = utils.detect_dominant_whitespace(whitespace_list, 3, ',')
        assert.are.equal(' ', result)
      end
    )

    it(
      'should not apply comma special handling for other delimiters',
      function()
        local whitespace_list = { '', '', ' ' }
        local result = utils.detect_dominant_whitespace(whitespace_list, 3, '|')
        assert.are.equal('', result)
      end
    )
  end)

  describe('parse_natural_segments', function()
    it('should return empty table for empty string', function()
      local result = utils.parse_natural_segments('')
      assert.are.same({}, result)
    end)

    it('should create single segment for digits only', function()
      local result = utils.parse_natural_segments('123')
      assert.are.equal(1, #result)
      assert.are.equal('123', result[1].text)
      assert.are.equal(true, result[1].is_number)
      assert.are.equal(false, result[1].is_punctuation)
    end)

    it('should create single segment for letters only', function()
      local result = utils.parse_natural_segments('abc')
      assert.are.equal(1, #result)
      assert.are.equal('abc', result[1].text)
      assert.are.equal(false, result[1].is_number)
      assert.are.equal(false, result[1].is_punctuation)
    end)

    it('should create separate segments for digits and letters', function()
      local result = utils.parse_natural_segments('abc123def')
      assert.are.equal(3, #result)
      assert.are.equal('abc', result[1].text)
      assert.are.equal(false, result[1].is_number)
      assert.are.equal('123', result[2].text)
      assert.are.equal(true, result[2].is_number)
      assert.are.equal('def', result[3].text)
      assert.are.equal(false, result[3].is_number)
    end)

    it('should create separate segment for each punctuation', function()
      local result = utils.parse_natural_segments('a-b')
      assert.are.equal(3, #result)
      assert.are.equal('a', result[1].text)
      assert.are.equal('-', result[2].text)
      assert.are.equal(true, result[2].is_punctuation)
      assert.are.equal('b', result[3].text)
    end)

    it('should handle consecutive punctuation as separate segments', function()
      local result = utils.parse_natural_segments('...')
      assert.are.equal(3, #result)
      for _, seg in ipairs(result) do
        assert.are.equal('.', seg.text)
        assert.are.equal(true, seg.is_punctuation)
      end
    end)

    it('should handle punctuation at start', function()
      local result = utils.parse_natural_segments('-123')
      assert.are.equal(2, #result)
      assert.are.equal('-', result[1].text)
      assert.are.equal(true, result[1].is_punctuation)
      assert.are.equal('123', result[2].text)
      assert.are.equal(true, result[2].is_number)
    end)

    it('should treat non-ASCII bytes as punctuation', function()
      local result = utils.parse_natural_segments('café')
      assert.are.equal(3, #result)
      assert.are.equal('caf', result[1].text)
      assert.are.equal(false, result[1].is_number)
      assert.are.equal(false, result[1].is_punctuation)
      assert.are.equal(true, result[2].is_punctuation)
      assert.are.equal(true, result[3].is_punctuation)
    end)

    it('should treat whitespace as punctuation', function()
      local result = utils.parse_natural_segments('hello world')
      assert.are.equal(3, #result)
      assert.are.equal('hello', result[1].text)
      assert.are.equal(false, result[1].is_punctuation)
      assert.are.equal(' ', result[2].text)
      assert.are.equal(true, result[2].is_punctuation)
      assert.are.equal('world', result[3].text)
      assert.are.equal(false, result[3].is_punctuation)
    end)
  end)

  describe('compare_natural_segments', function()
    it('should compare numbers numerically', function()
      local seg_a = { text = '2', is_number = true, is_punctuation = false }
      local seg_b = { text = '10', is_number = true, is_punctuation = false }
      local result = utils.compare_natural_segments(seg_a, seg_b, false)
      assert.are.equal(-1, result)
    end)

    it('should return 0 for equal numbers', function()
      local seg_a = { text = '5', is_number = true, is_punctuation = false }
      local seg_b = { text = '5', is_number = true, is_punctuation = false }
      local result = utils.compare_natural_segments(seg_a, seg_b, false)
      assert.are.equal(0, result)
    end)

    it('should return 1 when first number is larger', function()
      local seg_a = { text = '10', is_number = true, is_punctuation = false }
      local seg_b = { text = '2', is_number = true, is_punctuation = false }
      local result = utils.compare_natural_segments(seg_a, seg_b, false)
      assert.are.equal(1, result)
    end)

    it(
      'should return -1 when first is punctuation and second is not',
      function()
        local seg_a = { text = '-', is_number = false, is_punctuation = true }
        local seg_b = { text = 'a', is_number = false, is_punctuation = false }
        local result = utils.compare_natural_segments(seg_a, seg_b, false)
        assert.are.equal(-1, result)
      end
    )

    it('should return 1 when first is not punctuation and second is', function()
      local seg_a = { text = 'a', is_number = false, is_punctuation = false }
      local seg_b = { text = '-', is_number = false, is_punctuation = true }
      local result = utils.compare_natural_segments(seg_a, seg_b, false)
      assert.are.equal(1, result)
    end)

    it(
      'should compare text case-sensitively when ignore_case is false',
      function()
        local seg_a = { text = 'A', is_number = false, is_punctuation = false }
        local seg_b = { text = 'a', is_number = false, is_punctuation = false }
        local result = utils.compare_natural_segments(seg_a, seg_b, false)
        assert.are.equal(-1, result)
      end
    )

    it(
      'should compare text case-insensitively when ignore_case is true',
      function()
        local seg_a = { text = 'A', is_number = false, is_punctuation = false }
        local seg_b = { text = 'a', is_number = false, is_punctuation = false }
        local result = utils.compare_natural_segments(seg_a, seg_b, true)
        assert.are.equal(0, result)
      end
    )

    it('should return 0 for equal text', function()
      local seg_a = { text = 'abc', is_number = false, is_punctuation = false }
      local seg_b = { text = 'abc', is_number = false, is_punctuation = false }
      local result = utils.compare_natural_segments(seg_a, seg_b, false)
      assert.are.equal(0, result)
    end)

    it('should compare two punctuation characters by string value', function()
      local seg_a = { text = '-', is_number = false, is_punctuation = true }
      local seg_b = { text = '.', is_number = false, is_punctuation = true }
      local result = utils.compare_natural_segments(seg_a, seg_b, false)
      assert.are.equal(-1, result)
    end)

    it('should compare number segment with text segment as strings', function()
      local seg_a = { text = '2', is_number = true, is_punctuation = false }
      local seg_b = { text = 'abc', is_number = false, is_punctuation = false }
      local result = utils.compare_natural_segments(seg_a, seg_b, false)
      assert.are.equal(-1, result)
    end)
  end)

  describe('is_pure_number', function()
    it('should return true for positive integer', function()
      assert.is_true(utils.is_pure_number('42'))
    end)

    it('should return true for negative integer', function()
      assert.is_true(utils.is_pure_number('-42'))
    end)

    it('should return true for positive decimal', function()
      assert.is_true(utils.is_pure_number('3.14'))
    end)

    it('should return true for negative decimal', function()
      assert.is_true(utils.is_pure_number('-10.5'))
    end)

    it('should return true for number with positive sign', function()
      assert.is_true(utils.is_pure_number('+10'))
    end)

    it('should return true for scientific notation', function()
      assert.is_true(utils.is_pure_number('1e5'))
    end)

    it('should return true for negative scientific notation', function()
      assert.is_true(utils.is_pure_number('-1.5e-10'))
    end)

    it('should return true for zero', function()
      assert.is_true(utils.is_pure_number('0'))
    end)

    it('should return true for negative zero', function()
      assert.is_true(utils.is_pure_number('-0'))
    end)

    it('should return false for empty string', function()
      assert.is_false(utils.is_pure_number(''))
    end)

    it('should return false for nil', function()
      assert.is_false(utils.is_pure_number(nil))
    end)

    it('should return false for text', function()
      assert.is_false(utils.is_pure_number('abc'))
    end)

    it('should return false for mixed content', function()
      assert.is_false(utils.is_pure_number('item10'))
    end)

    it('should return false for number with text suffix', function()
      assert.is_false(utils.is_pure_number('10px'))
    end)

    it('should return false for multiple decimal points', function()
      assert.is_false(utils.is_pure_number('1.2.3'))
    end)

    it('should return false for standalone sign', function()
      assert.is_false(utils.is_pure_number('-'))
    end)

    it('should return false for standalone plus sign', function()
      assert.is_false(utils.is_pure_number('+'))
    end)

    it('should return false for incomplete scientific notation', function()
      assert.is_false(utils.is_pure_number('1e'))
    end)

    it('should return false for scientific notation without base', function()
      assert.is_false(utils.is_pure_number('e5'))
    end)

    it('should return false for decimal point only', function()
      assert.is_false(utils.is_pure_number('.'))
    end)

    it('should return false for leading decimal without zero', function()
      assert.is_false(utils.is_pure_number('.5'))
    end)

    it('should return true for trailing decimal', function()
      assert.is_true(utils.is_pure_number('5.'))
    end)

    it('should return false for whitespace around number', function()
      assert.is_false(utils.is_pure_number(' 5 '))
    end)
  end)

  describe('all_pure_numbers', function()
    it('should return true for all pure number items', function()
      local items = {
        { trimmed = '10' },
        { trimmed = '-5' },
        { trimmed = '3.14' },
      }
      assert.is_true(utils.all_pure_numbers(items))
    end)

    it('should return true when empty items are skipped', function()
      local items = {
        { trimmed = '10' },
        { trimmed = '' },
        { trimmed = '-5' },
      }
      assert.is_true(utils.all_pure_numbers(items))
    end)

    it('should return false when any item is not a number', function()
      local items = {
        { trimmed = '10' },
        { trimmed = 'item' },
        { trimmed = '-5' },
      }
      assert.is_false(utils.all_pure_numbers(items))
    end)

    it('should return false for mixed identifiers', function()
      local items = {
        { trimmed = '-10' },
        { trimmed = 'item-10' },
      }
      assert.is_false(utils.all_pure_numbers(items))
    end)

    it('should return true for empty array', function()
      assert.is_true(utils.all_pure_numbers({}))
    end)

    it('should return true for array with only empty trimmed values', function()
      local items = {
        { trimmed = '' },
        { trimmed = '' },
      }
      assert.is_true(utils.all_pure_numbers(items))
    end)

    it(
      'should return false immediately when first item is not a number',
      function()
        local items = {
          { trimmed = 'text' },
          { trimmed = '10' },
          { trimmed = '20' },
        }
        assert.is_false(utils.all_pure_numbers(items))
      end
    )

    it('should return false when last item is not a number', function()
      local items = {
        { trimmed = '10' },
        { trimmed = '20' },
        { trimmed = 'text' },
      }
      assert.is_false(utils.all_pure_numbers(items))
    end)
  end)

  describe('math_compare', function()
    it('should compare positive numbers', function()
      assert.is_true(utils.math_compare('2', '10'))
    end)

    it('should compare negative numbers', function()
      assert.is_true(utils.math_compare('-90', '-10'))
    end)

    it('should compare mixed positive and negative', function()
      assert.is_true(utils.math_compare('-5', '3'))
    end)

    it('should compare decimal numbers', function()
      assert.is_true(utils.math_compare('-10.5', '-2.7'))
    end)

    it('should return false when first is greater', function()
      assert.is_false(utils.math_compare('10', '2'))
    end)

    it('should return false when numbers are equal', function()
      assert.is_false(utils.math_compare('5', '5'))
    end)

    it('should fall back to string comparison for invalid numbers', function()
      assert.is_true(utils.math_compare('abc', 'def'))
    end)

    it('should treat empty string as 0 when compared with positive', function()
      assert.is_true(utils.math_compare('', '5'))
    end)

    it('should treat empty string as 0 when compared with negative', function()
      assert.is_false(utils.math_compare('', '-5'))
    end)

    it('should return false when comparing two empty strings', function()
      assert.is_false(utils.math_compare('', ''))
    end)

    it('should fall back to string comparison when one is invalid', function()
      assert.is_true(utils.math_compare('5', 'abc'))
    end)
  end)

  describe('natural_compare', function()
    it('should return true when a has fewer segments', function()
      local result = utils.natural_compare('a', 'ab', false)
      assert.are.equal(true, result)
    end)

    it('should return false when b has fewer segments', function()
      local result = utils.natural_compare('ab', 'a', false)
      assert.are.equal(false, result)
    end)

    it('should compare segments until first difference', function()
      local result = utils.natural_compare('item2', 'item10', false)
      assert.are.equal(true, result)
    end)

    it('should use string fallback when all segments equal', function()
      local result = utils.natural_compare('abc', 'abc', false)
      assert.are.equal(false, result)
    end)

    it('should sort numbers naturally', function()
      local result = utils.natural_compare('file2', 'file10', false)
      assert.are.equal(true, result)
    end)

    it('should handle case-insensitive comparison with fallback', function()
      local result = utils.natural_compare('ABC', 'abc', true)
      assert.are.equal(true, result)
    end)

    it('should sort punctuation before letters', function()
      local result = utils.natural_compare('-', 'a', false)
      assert.are.equal(true, result)
    end)

    it('should return true when first is empty and second is not', function()
      local result = utils.natural_compare('', 'a', false)
      assert.are.equal(true, result)
    end)

    it('should return false when second is empty and first is not', function()
      local result = utils.natural_compare('a', '', false)
      assert.are.equal(false, result)
    end)

    it('should return false for two empty strings', function()
      local result = utils.natural_compare('', '', false)
      assert.are.equal(false, result)
    end)
  end)
end)
