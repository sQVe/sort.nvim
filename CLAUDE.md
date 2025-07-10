# sort.nvim development guidelines

sort.nvim-specific development guidelines for the Neovim sorting plugin.

## 🚨 **CRITICAL REQUIREMENTS**

### Development workflow
- **Always run validation**: Run tests with `./scripts/test` after ALL code changes.
- **Double-check before committing**: Review all changes, verify tests pass, ensure code follows guidelines.
- **Use TodoWrite tool**: Plan complex tasks and track progress systematically.
- **Understand first**: Analyze codebase structure before making changes.
- **Verify implementation**: Test functionality after changes, follow existing patterns.

### Code quality standards
- **Type safety**: Use proper Lua type annotations (@param, @return).
- **Error handling**: Explicit errors with meaningful messages, no silent failures.
- **Comments**: End with period, only when necessary.
- **Testing**: Write unit tests for new functionality.

### Git workflow
- **Follow conventional commits**: Use format `type: description` (feat, fix, chore, docs, refactor, test).
- **Use imperative mood**: "add feature" not "added feature".
- **Limit first line to 72 characters**.
- **Reference issues**: Include "Fixes #XX" or "Closes #XX" when applicable.

---

## 📋 **PROJECT OVERVIEW**

### Purpose
Intelligent sorting plugin for Neovim that provides both line-wise and delimiter-based sorting with automatic strategy selection.

### Key features
- **Delimiter-aware sorting**: Automatically detects and sorts by configurable delimiters.
- **Natural sorting**: Handles alphanumeric strings naturally (e.g., "item1", "item2", "item10").
- **Motion support**: Operator-pending mode with text objects and motions.
- **Whitespace normalization**: Smart handling of inconsistent spacing.
- **Visual block sorting**: Sort within visual block selections.

### Project structure
```
lua/sort/
├── init.lua           # Plugin entry point and setup
├── config.lua         # Configuration management
├── sort.lua           # Core sorting algorithms
├── operator.lua       # Operator-pending mode functionality
├── mappings.lua       # Keybinding setup
├── interface.lua      # Neovim API interface
├── utils.lua          # Utility functions
├── textobjects.lua    # Custom text objects (is, as)
├── motions.lua        # Motion commands ([s, ]s)
└── repeat.lua         # Dot-repeat support

tests/
├── sort_spec.lua      # Core sorting tests
├── operator_spec.lua  # Operator functionality tests
└── minimal_init.lua   # Test environment setup
```

---

## 🔧 **TECHNICAL DETAILS**

### Core dependencies
- **Neovim**: 0.5.0+ (for Lua API support).
- **plenary.nvim**: Test framework (dev dependency only).
- **busted**: Lua testing framework via plenary.

### Sorting strategies
1. **Line sorting**: For multi-line selections.
2. **Delimiter sorting**: For single-line selections with delimiters.
3. **Natural sorting**: Optional alphanumeric sorting.

### Operator implementation
- **Perfect lines detection**: Character motions that cover complete lines are converted to line motions.
- **Motion types**: Supports line, char, and block motions.
- **Text extraction**: Handles visual and operator marks differently.
- **Dot-repeat**: Integrates with Vim's repeat functionality.

### Configuration system
- **Deep merging**: User config merged with defaults.
- **Priority delimiters**: Comma > pipe > semicolon > colon > space > tab.
- **Natural sort toggle**: Can be disabled globally.
- **Mappings**: Customizable operator, text object, and motion keys.

---

## 🎯 **IMPLEMENTATION GUIDELINES**

### Adding new features
1. **Research existing code**: Use Grep/Glob to understand current patterns.
2. **Plan with TodoWrite**: Break down complex features into tasks.
3. **Follow conventions**: Match existing code style and structure.
4. **Write tests first**: TDD approach for new functionality.
5. **Update documentation**: README.md and inline comments where necessary.

### Testing approach
- **Unit tests**: For individual functions and modules.
- **Integration tests**: For operator and motion functionality.
- **Edge cases**: Test boundary conditions and error scenarios.
- **Visual mode**: Test all visual mode types (char, line, block).

### Common operations
- **Run tests**: Use `./scripts/test` for the full test suite.
- **Debug specific issues**: Create debug scripts and run with `nvim --headless -c "luafile debug_script.lua" -c "q!" 2>&1`.
- **Verify sorting**: Test with various delimiters and content types.
- **Check operator marks**: Use debug prints to inspect mark positions and text extraction.

### Performance considerations
- **Lazy evaluation**: Only process what's necessary.
- **Efficient algorithms**: Use appropriate sorting strategies.
- **Minimal API calls**: Batch Neovim API operations when possible.

---

## 📝 **CODE STYLE REQUIREMENTS**

### Lua standards
- **Local variables**: Always use `local` for variable declarations.
- **Module pattern**: Return table with public functions.
- **Type annotations**: Use LuaLS annotations for documentation.
- **Error handling**: Use `assert` or explicit error checks.

### Documentation
- **Function docs**: Use `---` comments with @param and @return.
- **Inline comments**: Explain complex logic, end with period.
- **README updates**: Document new features and configuration options.

### Formatting
- **Indentation**: 2 spaces (as configured in .editorconfig).
- **Line length**: Reasonable length, break long lines logically.
- **Consistent style**: Match existing codebase patterns.
- **Stylua**: Project uses stylua for formatting (see .stylua.toml).
