# Contributing to sort.nvim

Contributions welcome! Before submitting:

- Follow existing code style
- Install pre-commit hooks (`pip install pre-commit && pre-commit install`)
- Write clear commit messages
- Add tests for new functionality
- Run tests before submitting

## Development Setup

Install [pre-commit](https://pre-commit.com/) hooks:

```bash
pip install pre-commit
pre-commit install
```

Hooks automatically format/lint Lua and shell files using stylua, shfmt, shellcheck, and selene.

### Manual tool installation

| Tool   | Install command                              |
| ------ | -------------------------------------------- |
| stylua | `cargo install stylua`                       |
| shfmt  | `go install mvdan.cc/sh/v3/cmd/shfmt@latest` |
| selene | `cargo install selene`                       |

### Running tests

To run the test suite:

```bash
./scripts/test
```

Use the `-v` or `--verbose` flag for detailed output:

```bash
./scripts/test --verbose
```
