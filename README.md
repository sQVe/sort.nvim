# 🔠 sort.nvim

**Sort** is a sorting plugin for [Neovim](https://neovim.io) which provides a simple command that mimics `:sort` and supports both line-wise and delimiter sorting. **Sort** intelligently picks a sorting strategy, by using a configurable priority list, which minimizes manual input and should cover most sorting cases by simply running `:Sort` on a range.

## ❓ Why

- Delimiter sorting.
- Picks sorting strategy intelligently, by using a configurable priority list.
- Minimize manual input.
- Efficient and lightweight.
- Utilize and mimic builtin `:sort` when possible.
- Silence the nitpicker within you.

## 📦 Installation

#### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua

use({
  'sQVe/sort.nvim',

  -- Optional setup for overriding defaults.
  config = function()
    require("sort").setup({
      -- Input configuration here.
      -- Refer to the configuration section below for options.
    })
  end
})
```

#### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script

Plug 'sQVe/sort.nvim'

" Optional setup for overriding defaults.
lua << EOF
  require("sort").setup({
    -- Input configuration here.
    -- Refer to the configuration section below for options.
  })
EOF
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
    's', -- Space
    't'  -- Tab
   }
}
```

## 📗 Usage

https://user-images.githubusercontent.com/2284724/145567686-3b52978c-58fe-4f32-ad27-c2b1060870ba.mp4

Sorting with **Sort** is easy via the provided `:Sort` command. Two different strategies are utilized depending on the visual selection:

- Multiple lines

  All arguments provided to `:Sort` are feed to the builtin `:sort` command, and thus mirroring all features provided by the builtin sort. See `:help :sort` for usage and options.

- Single line

  ```
  :[range]Sort[!] [delimiter][i][u]
  ```

  - With `[!]` the sort order is reversed.

  - With `[delimiter]` the delimiter is manually set instead of iterating over `config.delimiters` and sorting by the highest priority delimiter with results. Valid delimiters are:

    - Any punctuation character (!, ?, &, ...), matching the `%p` lua pattern character class.
    - `s`: Space
    - `t`: Tab

  - With `[i]` case is ignored.

  - With `[u]` only keep the first instance of words within selection.
    **_Note_** leading and trailing white space isn't considered when testing for uniqueness.

## 🤝 Contributing

All contributions are great and highly appreciated, be it a bug, fix or feature request. Don't hesitate to reach out via the [issue tracker](https://github.com/sQVe/sort.nvim/issues).

Please _consider_ the following before making a **PR**:

- Install [stylua](https://github.com/johnnymorganz/stylua) to ensure proper formatting.

## 🏁 Roadmap

- [ ] Extend support for delimiter sorting, mirroring `:sort` options:
  - [ ] `b` option to sort by binary (2).
  - [ ] `n` option to sort by decimal (10).
  - [ ] `o` option to sort by octal (8).
  - [ ] `x` option to sort by hexidecimal (16).
- [ ] Decent test coverage.
