# Version Management System

This document explains how to automatically increment version numbers in your Flutter app.

## Overview

The version management system automatically updates version numbers across your app whenever you make changes. It includes:

- **Automatic build number increments** on every commit
- **Manual version bumping** for semantic versioning
- **Centralized version constants** for consistent display
- **Git hooks** for seamless integration

## Current Setup

Your app currently uses version `1.0.0+1` where:
- `1.0.0` is the semantic version (major.minor.patch)
- `1` is the build number

## How It Works

### 1. Automatic Version Bumping (Recommended)

Every time you commit code, the git pre-commit hook automatically:
- Increments the build number
- Updates `pubspec.yaml`
- Updates version constants
- Updates UI display
- Stages all changes

**Example workflow:**
```bash
# Make your changes
git add .
git commit -m "Add new feature"
# Version automatically bumped from 1.0.0+1 to 1.0.0+2
```

### 2. Manual Version Bumping

For significant changes, you can manually bump semantic versions:

```bash
# Bug fixes
make bump-patch    # 1.0.0+1 -> 1.0.1+1

# New features
make bump-minor    # 1.0.0+1 -> 1.1.0+1

# Breaking changes
make bump-major    # 1.0.0+1 -> 2.0.0+1
```

## Files Updated

The system updates these files automatically:

1. **`pubspec.yaml`** - Flutter app version
2. **`lib/base/constants/app_version.dart`** - Version constants
3. **`lib/presentation/widgets/burger_menu_widget.dart`** - UI display

## Available Commands

```bash
# Show current version
make version

# Bump build number (automatic on commit)
make bump-build

# Bump semantic versions
make bump-patch
make bump-minor
make bump-major

# Bump and commit version changes
make commit-version

# Show all available commands
make help
```

## Git Hooks

### Pre-commit Hook
Located at `.git/hooks/pre-commit`, this hook runs automatically on every commit.

**To disable for a specific commit:**
```bash
git commit --no-verify
```

**To manually run the hook:**
```bash
.git/hooks/pre-commit
```

## Version Display in UI

The version is displayed in your burger menu using the `AppVersion.displayVersion` constant, which automatically shows the current version.

## Best Practices

1. **Let the system handle build numbers** - Don't manually edit version numbers
2. **Use semantic versioning** for significant changes
3. **Commit frequently** to maintain accurate build numbers
4. **Review version changes** before pushing to remote

## Troubleshooting

### Version Not Updating
- Ensure git hooks are executable: `chmod +x .git/hooks/pre-commit`
- Check Python 3 is installed: `python3 --version`
- Verify script permissions: `chmod +x scripts/bump_version.py`

### Version Mismatch
- Run `make version` to see current state
- Use appropriate bump command to fix
- Commit the changes

### Git Hook Issues
- Check hook permissions and syntax
- Verify Python path in the hook
- Test manually: `python3 scripts/bump_version.py build`

## Customization

### Changing Version Format
Edit `scripts/bump_version.py` to modify version parsing or formatting.

### Adding More Files
Update the script to include additional files that need version updates.

### Branch-Specific Rules
Modify `.git/hooks/pre-commit` to skip version bumping on certain branches.

## Example Workflow

```bash
# 1. Start development
git checkout -b feature/new-feature

# 2. Make changes and commit (build number auto-increments)
git add .
git commit -m "Add new feature"
# Version: 1.0.0+2

# 3. Complete feature, bump minor version
make bump-minor
# Version: 1.1.0+1

# 4. Commit version bump
make commit-version

# 5. Merge to main
git checkout main
git merge feature/new-feature
```

This system ensures your app always has accurate, up-to-date version numbers without manual intervention.
