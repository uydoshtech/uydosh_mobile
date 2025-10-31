# Version Bumping System

This directory contains scripts and tools to automatically manage version numbers for the Flutter app.

## Files

- `bump_version.py` - Main script for incrementing version numbers
- `README.md` - This documentation file

## How It Works

The version bumping system automatically updates:
1. `pubspec.yaml` - Flutter app version
2. `lib/base/constants/app_version.dart` - Version constants used in the app
3. `lib/presentation/widgets/burger_menu_widget.dart` - UI version display

## Usage

### Manual Version Bumping

```bash
# Bump build number (1.0.0+1 -> 1.0.0+2)
python3 scripts/bump_version.py build

# Bump patch version (1.0.0+1 -> 1.0.1+1)
python3 scripts/bump_version.py patch

# Bump minor version (1.0.0+1 -> 1.1.0+1)
python3 scripts/bump_version.py minor

# Bump major version (1.0.0+1 -> 2.0.0+1)
python3 scripts/bump_version.py major
```

### Using Makefile Commands

```bash
# Show current version
make version

# Bump build number
make bump-build

# Bump patch version
make bump-patch

# Bump minor version
make bump-minor

# Bump major version
make bump-major

# Bump version and commit changes
make commit-version
```

### Automatic Version Bumping

The system includes a git pre-commit hook that automatically bumps the build number on every commit.

## Version Format

The app uses semantic versioning with build numbers:
- **Major.Minor.Patch+BuildNumber**
- Example: `1.0.0+2`

- **Major**: Breaking changes
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, backward compatible
- **BuildNumber**: Increments with each build/commit

## Git Hooks

### Pre-commit Hook
Located at `.git/hooks/pre-commit`, this hook automatically:
1. Increments the build number
2. Updates all version-related files
3. Stages the changes for commit

### Disabling Auto-bumping
To disable automatic version bumping for a commit, use:
```bash
git commit --no-verify
```

## Best Practices

1. **Feature Branches**: Use `make bump-minor` when adding new features
2. **Bug Fixes**: Use `make bump-patch` for bug fixes
3. **Breaking Changes**: Use `make bump-major` for breaking changes
4. **Regular Development**: Let the pre-commit hook handle build number increments

## Troubleshooting

### Script Errors
If the script fails, check:
- Python 3 is installed
- Script has execute permissions (`chmod +x scripts/bump_version.py`)
- All required files exist

### Version Mismatch
If versions get out of sync:
1. Run `make version` to see current state
2. Use appropriate bump command to fix
3. Commit the changes

### Git Hook Issues
If the pre-commit hook isn't working:
1. Ensure it's executable: `chmod +x .git/hooks/pre-commit`
2. Check for syntax errors in the hook
3. Verify Python path in the hook
