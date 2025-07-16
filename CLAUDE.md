# sort.nvim - AI assistant instructions

sort.nvim-specific instructions for AI assistants working on this project.

## 🎯 Project context

sort.nvim is an intelligent sorting plugin for Neovim that provides both line-wise and delimiter-based sorting with automatic strategy selection.

### Key documentation

- **[README.md](README.md)**: Project overview, installation, and configuration
- **[RELEASE.md](RELEASE.md)**: Release process and guidelines
- **[CHANGELOG.md](CHANGELOG.md)**: Version history and changes

## 🚨 Critical requirements

### Development workflow

- **Always run `./scripts/test`**: Run tests (executable script) after code changes

### Key implementation notes

- **Busted-style tests**: Use `describe`/`it`/`assert` with lazy.nvim minit runner
- **Strategy selection**: Automatic detection of optimal sorting approach (line vs delimiter)
- **Operator support**: `gs` operator with text objects (`is`, `as`) and motions (`[s`, `]s`)
- **Natural sorting**: Proper alphanumeric ordering for numbers and punctuation
- **Performance focus**: Efficient algorithms for large files and frequent operations
