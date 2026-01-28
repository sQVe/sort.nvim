# Release Process

This document outlines the automated process for creating a new release of sort.nvim.

## Creating a Release

1. **Update and commit CHANGELOG.md**:
   - Move changes from "Unreleased" to a new version section
   - Add the release date: `## [2.1.1] - 2025-07-11`
   - Update the version links at the bottom of the file
   - Commit the changelog: `git commit -m "docs: update changelog for vX.Y.Z"`

2. **Run the release script**:
   ```bash
   ./scripts/release 2.1.1
   ```

The script automatically handles:

- Version validation and conflict checking
- Clean working directory verification
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

## Changelog Validation

GitHub Actions enforces strict semantic versioning rules for changelog validation. Understanding these rules prevents release failures:

### Semantic Versioning Rules

**Patch releases (x.y.Z)** - Only backward-compatible bug fixes:

- ✅ **Allowed sections**: `Fixed`, `Security`
- ❌ **Not allowed**: `Added`, `Changed`, `Deprecated`, `Removed`

**Minor releases (x.Y.z)** - New functionality, backward-compatible:

- ✅ **Allowed sections**: `Added`, `Changed`, `Fixed`, `Security`, `Deprecated`
- ❌ **Not allowed**: `Removed` (unless it's deprecated functionality)

**Major releases (X.y.z)** - Breaking changes:

- ✅ **Allowed sections**: All sections including `Removed`

### Common Validation Errors

**Error**: `Only 'fixed, security' sections are allowed for version x.y.Z`

- **Cause**: Patch release contains `Added` or `Changed` sections
- **Solution**: Either:
  1. Move `Added`/`Changed` items to `Unreleased` section and create patch release
  2. Delete tag and create minor release (x.Y+1.0) instead

**Error**: Changelog entry validation failed

- **Cause**: Version section missing or malformed in CHANGELOG.md
- **Solution**: Ensure proper format: `## [x.y.z] - YYYY-MM-DD`

### Version Selection Guide

Choose version type based on your changes:

- **Bug fixes only** → Patch release (2.1.2)
- **New features or enhancements** → Minor release (2.2.0)
- **Breaking changes** → Major release (3.0.0)

## Troubleshooting

If the release script fails, it provides clear error messages and suggestions. For GitHub Actions issues, check the workflow logs at: https://github.com/sQVe/sort.nvim/actions

### Release Workflow Failures

If GitHub Actions release fails after tagging:

1. Check the workflow logs for specific error messages
2. Fix the issue (often changelog validation)
3. Amend the relevant commits and force-push to re-trigger the workflow
4. If needed, delete and recreate the tag with corrected content
