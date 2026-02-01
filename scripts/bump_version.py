#!/usr/bin/env python3
"""
Version bumping script for Flutter app.
Automatically increments version numbers in pubspec.yaml and updates UI display.
"""

import re
import sys
import os
from pathlib import Path

def read_pubspec_version():
    """Read current version from pubspec.yaml"""
    pubspec_path = Path("pubspec.yaml")
    if not pubspec_path.exists():
        print("Error: pubspec.yaml not found")
        sys.exit(1)
    
    with open(pubspec_path, 'r') as f:
        content = f.read()
    
    # Find version line
    version_match = re.search(r'version:\s*(\d+\.\d+\.\d+)\+(\d+)', content)
    if not version_match:
        print("Error: Could not parse version from pubspec.yaml")
        sys.exit(1)
    
    semantic_version = version_match.group(1)
    build_number = int(version_match.group(2))
    
    # Split semantic version into components
    major, minor, patch = map(int, semantic_version.split('.'))
    
    return major, minor, patch, build_number

def update_pubspec_version(major, minor, patch, build_number):
    """Update version in pubspec.yaml"""
    pubspec_path = Path("pubspec.yaml")
    
    with open(pubspec_path, 'r') as f:
        content = f.read()
    
    # Update version line
    new_version = f"{major}.{minor}.{patch}+{build_number}"
    content = re.sub(r'version:\s*\d+\.\d+\.\d+\+\d+', f'version: {new_version}', content)
    
    with open(pubspec_path, 'w') as f:
        f.write(content)
    
    print(f"Updated pubspec.yaml to version: {new_version}")

def update_version_constants(major, minor, patch, build_number):
    """Update version constants file"""
    constants_path = Path("lib/base/constants/app_version.dart")
    if not constants_path.exists():
        print("Warning: app_version.dart not found, skipping constants update")
        return
    
    with open(constants_path, 'r') as f:
        content = f.read()
    
    # Update version constants
    content = re.sub(
        r"static const String version = ['\"]\d+\.\d+\.\d+['\"];",
        f"static const String version = \"{major}.{minor}.{patch}\";",
        content,
    )
    content = re.sub(
        r"static const String buildNumber = ['\"]\d+['\"];",
        f"static const String buildNumber = \"{build_number}\";",
        content,
    )
    
    with open(constants_path, 'w') as f:
        f.write(content)
    
    print(f"Updated app_version.dart constants")

def update_ui_version(major, minor, patch):
    """Update version display in UI files"""
    # Update burger menu widget
    burger_menu_path = Path("lib/presentation/widgets/burger_menu_widget.dart")
    if burger_menu_path.exists():
        with open(burger_menu_path, 'r') as f:
            content = f.read()
        
        # Find and replace the version string
        old_version_pattern = r"'Version \d+\.\d+\.\d+'"
        new_version = f"'Version {major}.{minor}.{patch}'"
        content = re.sub(old_version_pattern, new_version, content)
        
        with open(burger_menu_path, 'w') as f:
            f.write(content)
        
        print(f"Updated UI version display to: Version {major}.{minor}.{patch}")

def bump_version(bump_type="build"):
    """Bump version based on type"""
    major, minor, patch, build_number = read_pubspec_version()
    
    if bump_type == "major":
        major += 1
        minor = 0
        patch = 0
        build_number = 1
    elif bump_type == "minor":
        minor += 1
        patch = 0
        build_number = 1
    elif bump_type == "patch":
        patch += 1
        build_number = 1
    elif bump_type == "build":
        build_number += 1
    
    update_pubspec_version(major, minor, patch, build_number)
    update_version_constants(major, minor, patch, build_number)
    update_ui_version(major, minor, patch)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        bump_type = sys.argv[1]
        if bump_type not in ["major", "minor", "patch", "build"]:
            print("Usage: python bump_version.py [major|minor|patch|build]")
            print("Default: build (increments build number)")
            sys.exit(1)
        bump_version(bump_type)
    else:
        # Default to build number increment
        bump_version("build")
