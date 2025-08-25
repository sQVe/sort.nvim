# 🔠 sort.nvim

[![GitHub release](https://img.shields.io/github/v/release/sQVe/sort.nvim?style=flat-square)](https://github.com/sQVe/sort.nvim/releases/latest)
[![License](https://img.shields.io/github/license/sQVe/sort.nvim?style=flat-square)](https://github.com/sQVe/sort.nvim/blob/main/LICENSE)

**Sort** is a Neovim plugin for intelligent line and delimiter sorting.

## ❓ Why

- **Delimiter-aware sorting**: Automatically detects and sorts by delimiters like commas, pipes, colons, and more.
- **Natural sorting support**: Handles strings with numbers naturally (e.g., "item1", "item2", "item10").
- **Vim-compatible**: Mirrors Neovim's built-in `:sort` command functionality where applicable.
- **Motion-based operations**: Provides text objects and motions for efficient sorting workflows.

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
  -- Delimiter priority order.
  delimiters = {
    ',',
    '|',
    ';',
    ':',
    's', -- Space.
    't'  -- Tab.
  },

  -- Natural sorting (default: true).
  natural_sort = true,

  -- Case-insensitive sorting (default: false).
  ignore_case = false,

  -- Whitespace alignment threshold.
  whitespace = {
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

| Mapping | Mode                   | Description                         |
| ------- | ---------------------- | ----------------------------------- |
| `go`    | Normal                 | Sort operator (use with any motion) |
| `go`    | Visual                 | Sort visual selection               |
| `gogo`  | Normal                 | Sort current line                   |
| `io`    | Operator/Visual        | Inner sortable region text object   |
| `ao`    | Operator/Visual        | Around sortable region text object  |
| `]o`    | Normal/Visual/Operator | Jump to next delimiter              |
| `[o`    | Normal/Visual/Operator | Jump to previous delimiter          |

All sorting operations support Vim's dot-repeat (`.`) functionality, allowing you to easily repeat the last sort operation.

#### Examples

```vim
gow      " Word
go(      " Parentheses
go3j     " 3 lines
goio     " Inner object
goao     " Around object
gop      " Paragraph
gogo     " Current line
```

To disable natural sorting for motions:

```lua
require('sort').setup({
  natural_sort = false,
})
```

### Default case sensitivity

By default, **Sort** performs case-sensitive sorting for all operations. You can configure it to be case-insensitive by default:

```lua
require('sort').setup({
  ignore_case = true,
})
```

**Note**: The `:Sort i` command still works independently of this setting for explicit case-insensitive sorting.

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

Natural sorting handles numbers within text intelligently - comparing them numerically rather than alphabetically:

```
" Regular sorting:
item1, item10, item2   →   item1, item10, item2

" Natural sorting (z flag):
item1, item10, item2   →   item1, item2, item10
```

This is especially useful for:

- Version numbers: `v1.9.0, v1.10.0, v2.0.0` sorts correctly
- File names: `file1.txt, file2.txt, file10.txt` sorts in logical order
- IDs and references: `#1, #2, #10, #100` maintains numeric order

## 🤝 Contributing

All contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.
