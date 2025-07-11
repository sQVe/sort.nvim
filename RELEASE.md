# Release Process

This document outlines the automated process for creating a new release of sort.nvim.

## Creating a Release

1. **Update CHANGELOG.md**:
   - Move changes from "Unreleased" to a new version section.
   - Add the release date: `## [2.1.1] - 2025-07-11`.

2. **Run the release script**:
   ```bash
   ./scripts/release 2.1.1
   ```

The script automatically handles:
- Version validation and conflict checking
- Test execution and code formatting verification  
- Version updates in `lua/sort/init.lua`
- Git commit, tagging, and pushing to origin

## Script Options

```bash
./scripts/release --dry-run 2.1.1    # Preview changes without executing
./scripts/release --help             # Show all available options
```

## Post-release

After the tag is pushed, GitHub Actions will:
- Run the full test suite
- Create a GitHub release with changelog notes
- Generate downloadable archives

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality in a backwards compatible manner  
- **PATCH**: Backwards compatible bug fixes

## Troubleshooting

If the release script fails, it provides clear error messages and suggestions. For GitHub Actions issues, check the workflow logs at: https://github.com/sQVe/sort.nvim/actions