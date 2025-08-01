# 🔠 sort.nvim

[![GitHub release](https://img.shields.io/github/v/release/sQVe/sort.nvim?style=flat-square)](https://github.com/sQVe/sort.nvim/releases/latest)
[![License](https://img.shields.io/github/license/sQVe/sort.nvim?style=flat-square)](https://github.com/sQVe/sort.nvim/blob/main/LICENSE)

**Sort** is a sorting plugin for [Neovim](https://neovim.io) that provides intelligent sorting capabilities with support for both line-wise and delimiter-based sorting. This plugin automatically selects the most appropriate sorting strategy using a configurable priority system, making sorting efficient and intuitive.

## ❓ Why

- **Delimiter-aware sorting**: Automatically detects and sorts by delimiters like commas, pipes, colons, and more.
- **Intelligent strategy selection**: Uses a configurable priority list to choose the best sorting approach.
- **Natural sorting support**: Handles strings with numbers naturally (e.g., "item1", "item2", "item10").
- **Minimal user input**: The `:Sort` command covers most sorting scenarios without additional configuration.
- **Vim-compatible**: Mirrors Neovim's built-in `:sort` command functionality where applicable.
- **Motion-based operations**: Provides text objects and motions for efficient sorting workflows.
- **Whitespace preservation**: Intelligently handles and normalizes whitespace in sorted content.

## 📦 Installation

#### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'sQVe/sort.nvim',
  config = function()
    require('sort').setup({
      -- Optional configuration overrides.
    })
  end,
}
```

## ⚙ Configuration

**Sort** comes with the following defaults:

```lua
{
  -- List of delimiters, in descending order of priority, to automatically
  -- sort on.
  delimiters = {
    ',',
    '|',
    ';',
    ':',
    's', -- Space.
    't'  -- Tab.
  },

  -- Enable natural sorting for motion operations by default.
  -- When true, sorts "item1,item10,item2" as "item1,item2,item10".
  -- When false, uses lexicographic sorting: "item1,item10,item2".
  natural_sort = true,

  -- Whitespace handling configuration.
  whitespace = {
    -- When whitespace before items is >= this many characters, it's considered
    -- alignment and is preserved. Otherwise, whitespace is normalized to be
    -- consistent when sorting changes item order.
    alignment_threshold = 3,
  },

  -- Default keymappings (set to false to disable).
  mappings = {
    operator = 'go',
    textobject = {
      inner = 'io',
      around = 'ao',
    },
    motion = {
      next_delimiter = ']o',
      prev_delimiter = '[o',
    },
  },
}
```

## 📗 Usage

### Command-based sorting

The `:Sort` command adapts its behavior based on your selection:

#### Multiple lines
When selecting multiple lines, all arguments are passed to Neovim's built-in `:sort` command:

```vim
:[range]Sort[!] [flags]
```

See `:help :sort` for complete documentation of flags and options.

#### Single line (delimiter sorting)
When selecting within a single line, the plugin performs delimiter-based sorting:

```vim
:[range]Sort[!] [delimiter][flags]
```

**Available flags:**
- `!` - Reverse the sort order
- `[delimiter]` - Manually specify delimiter (any punctuation, `s` for space, `t` for tab)
- `b` - Sort by binary numbers
- `i` - Ignore case
- `n` - Sort by decimal numbers
- `o` - Sort by octal numbers
- `u` - Keep only unique items
- `x` - Sort by hexadecimal numbers
- `z` - Natural sorting (handles numbers in strings properly)

### Motion-based sorting

**Sort** provides Vim-style operators and text objects for efficient sorting:

| Mapping | Mode | Description |
|---------|------|-------------|
| `go` | Normal | Sort operator (use with any motion) |
| `go` | Visual | Sort visual selection |
| `gogo` | Normal | Sort current line |
| `io` | Operator/Visual | Inner sortable region text object |
| `ao` | Operator/Visual | Around sortable region text object |
| `]o` | Normal/Visual/Operator | Jump to next delimiter |
| `[o` | Normal/Visual/Operator | Jump to previous delimiter |

All sorting operations support Vim's dot-repeat (`.`) functionality, allowing you to easily repeat the last sort operation.

#### Examples

```vim
" Sort a word.
gow

" Sort inside parentheses.
go(

" Sort 3 lines down.
go3j

" Sort inside quotes using text object.
goio

" Sort around delimiters using text object.
goao

" Sort a paragraph.
gop

" Quick line sort.
gogo
```

### Natural sorting for motions

By default, **Sort** uses natural sorting for motion operations, which handles numbers in strings more intuitively:

```vim
" With natural_sort = true (default):
" 'item1,item10,item2' becomes 'item1,item2,item10'
go$

" With natural_sort = false:
" 'item1,item10,item2' becomes 'item1,item10,item2' (lexicographic)
go$
```

To disable natural sorting for motions:

```lua
require('sort').setup({
  natural_sort = false,
})
```

**Note**: The `:Sort z` command still works independently of this setting for explicit natural sorting.

### Customizing mappings

You can customize the default mappings:

```lua
require('sort').setup({
  mappings = {
    operator = 'gs',
    textobject = {
      inner = 'ii',
      around = 'ai',
    },
    motion = {
      next_delimiter = ']d',
      prev_delimiter = '[d',
    },
  },
})
```

To disable mappings entirely:

```lua
require('sort').setup({
  mappings = {
    operator = false,
    textobject = false,
    motion = false,
  },
})
```

## 🚀 Features

### Natural Sorting

Use the `z` flag to enable natural sorting, which handles numbers in strings properly:

```
" Before: item1, item10, item2
" After:  item1, item2, item10
:Sort z
```

Natural sorting also prioritizes punctuation over numeric continuations, making it ideal for programming content:

```
" Shell aliases
" Before: A1='{ print $1 }', A2='{ print $2 }', A='| awk'
" After:  A='| awk', A1='{ print $1 }', A2='{ print $2 }'

" Function definitions  
" Before: func1(), func10(), func()
" After:  func(), func1(), func10()

" CSS selectors
" Before: .btn1, .btn:hover, .btn=active  
" After:  .btn:hover, .btn=active, .btn1
```

This enhancement ensures that identifiers with punctuation (like `A=`, `func()`) sort before identifiers with numeric suffixes (like `A1`, `func2`).

### Intelligent Whitespace Handling

The plugin automatically normalizes whitespace in sorted content while preserving alignment when appropriate. The `alignment_threshold` setting controls when whitespace is considered significant for alignment purposes.

### Delimiter Priority

When multiple delimiters are present, the plugin uses the configured priority order to determine which delimiter to sort by. This ensures consistent behavior across different text patterns.

## 🤝 Contributing

All contributions are welcome! Whether it's bug reports, feature requests, or pull requests, your help makes **Sort** better for everyone.

Before contributing:
- Follow the existing code style and formatting conventions
- Install the formatters ([stylua](https://github.com/johnnymorganz/stylua) and [shfmt](https://github.com/mvdan/sh)) for consistent formatting
- Write clear commit messages describing your changes
- Add tests for new functionality when applicable
- Run tests before submitting pull requests

### Development Setup

This project uses git hooks to ensure code quality and consistent formatting. To install the pre-commit hook:

```bash
./scripts/install-hooks
```

The pre-commit hook will automatically format:
- **Lua files** using [stylua](https://github.com/JohnnyMorganz/StyLua)
- **Shell scripts** using [shfmt](https://github.com/mvdan/sh)

#### Installing formatters

**stylua** (for Lua files):
- `cargo install stylua` (recommended)
- `brew install stylua` (macOS)
- Download from [stylua releases](https://github.com/JohnnyMorganz/StyLua/releases)

**shfmt** (for shell scripts):
- `go install mvdan.cc/sh/v3/cmd/shfmt@latest` (recommended)
- `brew install shfmt` (macOS)
- Download from [shfmt releases](https://github.com/mvdan/sh/releases)

#### Running tests

To run the test suite:

```bash
./scripts/test
```

Use the `-v` or `--verbose` flag for detailed output:

```bash
./scripts/test --verbose
```

## 🏁 Roadmap

- [x] **Delimiter sorting**: Support for multiple delimiter types with priority-based selection
- [x] **Numerical sorting**: Support for binary, decimal, octal, and hexadecimal number sorting
- [x] **Motion mappings**: Vim-style operators and text objects for efficient sorting
- [x] **Natural sorting**: Intuitive sorting of strings containing numbers
- [x] **Whitespace handling**: Intelligent whitespace preservation and normalization
- [x] **Comprehensive testing**: Full test coverage for stability and reliability
