# 🔠 sort.nvim

**Sort** is a sorting plugin for [Neovim](https://neovim.io) that provides a simple command to mimic `:sort` and supports both line-wise and delimiter sorting. This plugin intelligently selects a sorting strategy by using a configurable priority list, minimizing manual input and covering most sorting cases with just the `:Sort` command on a range.

## ❓ Why

- Supports delimiter sorting.
- Intelligently selects a sorting strategy using a configurable priority list.
- Minimizes manual input required from the user.
- Efficient and lightweight.
- Mimics the functionality of Neovim's built-in `:sort` command where possible.
- Helps to satisfy the perfectionist in you by ensuring your text is neatly sorted.

## 📦 Installation

#### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua.

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
" Vim Script.

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

Sorting with the **Sort** plugin is made easy through the provided `:Sort` command. The plugin utilizes two different strategies depending on the visual selection:

- Multiple lines

  When selecting multiple lines, all arguments provided to `:Sort` are fed to the built-in `:sort` command, thereby mirroring all of the features provided by the built-in sort. See `:help :sort` for usage and options.

- Single line

  ```
  :[range]Sort[!] [delimiter][b][i][n][o][u][x]
  ```

  - Use `[!]` to reverse the sort order.
  - Use `[delimiter]` to manually set the delimiter instead of iterating over `config.delimiters` and sorting by the highest priority delimiter. Valid delimiters include:
    - Any punctuation character (!, ?, &, ...), matching the `%p` lua pattern character class.
    - `s`: Space
    - `t`: Tab
  - Use `[b]` to sort based on the first binary number in the word.
  - Use `[i]` to ignore the case when sorting.
  - Use `[n]` to sort based on the first decimal number in the word.
  - Use `[o]` to sort based on the first octal number in the word.
  - Use `[u]` to only keep the first instance of words within the selection. Leading and trailing whitespace are not considered when testing for uniqueness.
  - Use `[x]` to sort based on the first hexadecimal number in the word. A leading `0x` or `0X` is ignored.

## ⌨️ Keybinding

By default, **Sort** does not set any keybindings. Here's an example of how you can set a keybinding to trigger `:Sort`. In this example, the keybinding `go` is used, but you can change it to whatever you prefer:

```vim
" Vim Script.

nnoremap <silent> go <Cmd>Sort<CR>
vnoremap <silent> go <Esc><Cmd>Sort<CR>
```

```lua
-- Lua.

vim.cmd([[
  nnoremap <silent> go <Cmd>Sort<CR>
  vnoremap <silent> go <Esc><Cmd>Sort<CR>
]])
```

A common workflow, before sorting, is to visually select inside a set of characters with `vi<character>`. Instead of doing that manually before running **Sort** you could add the keybindings like:

```vim
" Vim Script.

nnoremap <silent> go" vi"<Esc><Cmd>Sort<CR>
nnoremap <silent> go' vi'<Esc><Cmd>Sort<CR>
nnoremap <silent> go( vi(<Esc><Cmd>Sort<CR>
nnoremap <silent> go[ vi[<Esc><Cmd>Sort<CR>
nnoremap <silent> gop vip<Esc><Cmd>Sort<CR>
nnoremap <silent> go{ vi{<Esc><Cmd>Sort<CR>
```

## 🤝 Contributing

All contributions to Sort are greatly appreciated, whether it's a bug fix or a feature request. If you would like to contribute, please don't hesitate to reach out via the [issue tracker](https://github.com/sQVe/sort.nvim/issues).

Before making a pull request, please consider the following:

- Follow the existing code style and formatting conventions .
  - Install [stylua](https://github.com/johnnymorganz/stylua) to ensure proper formatting.
- Write clear and concise commit messages that describe the changes you've made.

## 🏁 Roadmap

- [x] Extend support for delimiter sorting to mirror the options available in `:sort`:
  - [x] `b` option to sort by binary (2).
  - [x] `n` option to sort by decimal (10).
  - [x] `o` option to sort by octal (8).
  - [x] `x` option to sort by hexidecimal (16).
- [ ] Improve test coverage to ensure the stability and reliability of the plugin.
- [ ] Add support for natural sorting to provide more intuitive sorting of strings that include numeric values.
- [ ] Add opt-in motion mappings to enable users to trigger Sort commands more efficiently using keybindings.
