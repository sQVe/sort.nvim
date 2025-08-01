# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Enhanced release script with automation support. The release script now supports CI environments, dry-run mode, and improved validation for streamlined releases.

### Changed

- Enhanced error handling and validation across core modules for improved stability.
- Updated test infrastructure to use minimal_init.lua for better test isolation and reliability.

## [2.1.2] - 2025-07-30

### Fixed

- Preserve trailing delimiters instead of moving to beginning. This resolves an issue where trailing delimiters (like commas at the end of lists) were incorrectly repositioned to the start of sorted content.

## [2.1.1] - 2025-07-12

### Fixed

- Corrected natural sorting priority for punctuation characters. Shell aliases like `@l` now properly sort before text identifiers like `A` when using natural sorting. This resolves an inconsistency where punctuation-prefixed identifiers were appearing after text identifiers instead of before them.

## [2.1.0] - 2025-07-11

### Added

- Enhanced natural sorting with punctuation priority. Identifiers with punctuation (like `A=`, `func()`) now sort before identifiers with numeric suffixes (like `A1`, `func2`) when using natural sorting (`z` flag). This makes sorting more intuitive for shell aliases, CSS selectors, function definitions, and other programming content. Resolves #11.

## [2.0.1] - 2025-07-10

### Fixed

- Multi-line character motions with text objects (e.g., `goi{`) now preserve whitespace correctly by treating "perfect lines" selections as line motions (#10).

## [2.0.0] - 2025-07-09

### Added

- Visual block sorting support.
- Natural sorting functionality (alphanumeric sorting).
- Motion operations with natural sorting enabled by default.
- Dot-repeat support for sorting operations.
- Comprehensive testing infrastructure with busted framework.
- New feature modules for enhanced functionality.
- Support for keeping leading and trailing delimiters.

### Changed

- **BREAKING**: Refactored core sorting functionality and configuration.
- **BREAKING**: Enhanced line sorting with new internal API.
- Removed unused functions and eliminated redundancy.
- Enhanced README documentation with detailed explanations.
- Changed number types from number to integer for better type safety.
- Removed Node.js dependencies in favor of Lua-based tooling.
- Updated stylua configuration.
- Added motion mapping task to roadmap.
- Updated README with enhanced documentation and explanations.
- Added dot-repeat support documentation.
- Improved README readability.

### Fixed

- Visual line selection sorting issues.
- Column boundary handling when setting text (retry if col end out of bounds).
- Restored functions required by tests.

## [1.0.0] - 2021-12-14

### Added

- Initial release of sort.nvim.
- Core sorting functionality for Neovim.
- Line sorting support with visual selection.
- Delimiter-based sorting within lines.
- Configuration system with customizable options:
  - Custom delimiters with priority system.
  - Reverse sorting option.
  - Unique value filtering.
  - Numerical sorting options.
- Default keybindings for sorting operations.
- Override capability for existing Vim sort command.
- Support for whitespace handling and normalization.
- Numerical sorting support with proper parsing.
- Stylua for code formatting.
- .editorconfig for consistent coding standards.
- Prettier for markdown formatting.
- Initial README with installation and usage instructions.
- Roadmap items for future development.
- Keybinding examples with detailed explanations.
- Documentation for numerical sorting options.

[Unreleased]: https://github.com/sQVe/sort.nvim/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/sQVe/sort.nvim/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/sQVe/sort.nvim/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/sQVe/sort.nvim/releases/tag/v1.0.0
