# Release Process

This document outlines the process for creating a new release of sort.nvim.

## Pre-release Checklist

Before creating a release, ensure the following:

- [ ] All tests pass locally (`make test`).
- [ ] Code is properly formatted (`stylua --check lua/`).
- [ ] Documentation is up to date.
- [ ] CHANGELOG.md is updated with the new version and release date.
- [ ] Version number in `lua/sort/init.lua` is updated.

## Creating a Release

1. **Update version number**:
   ```bash
   # Edit lua/sort/init.lua and update _VERSION
   vim lua/sort/init.lua
   ```

2. **Update CHANGELOG.md**:
   - Move changes from "Unreleased" to a new version section.
   - Add the release date.
   - Update the comparison links at the bottom.

3. **Commit the changes**:
   ```bash
   git add lua/sort/init.lua CHANGELOG.md
   git commit -m "chore: prepare release v2.0.0"
   ```

4. **Create and push the tag**:
   ```bash
   git tag -a v2.0.0 -m "Release version 2.0.0"
   git push origin main
   git push origin v2.0.0
   ```

5. **Verify the release**:
   - The GitHub Actions workflow will automatically run tests.
   - If tests pass, a GitHub release will be created with:
     - Release notes from CHANGELOG.md.
     - Downloadable archives (tar.gz and zip).

## Post-release

After the release is created:

1. **Prepare for next development cycle**:
   - Add a new "Unreleased" section to CHANGELOG.md.
   - Update the comparison link for "Unreleased".

2. **Announce the release** (optional):
   - Create announcements in relevant communities.
   - Update any external documentation.

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes.
- **MINOR**: New functionality in a backwards compatible manner.
- **PATCH**: Backwards compatible bug fixes.

## Troubleshooting

If the release workflow fails:

1. Check the GitHub Actions logs for errors.
2. Ensure all required secrets are configured (GITHUB_TOKEN is automatic).
3. Verify the CHANGELOG.md format matches the expected structure.
4. Delete the tag and try again if needed:
   ```bash
   git tag -d v2.0.0
   git push origin :refs/tags/v2.0.0
   ```
