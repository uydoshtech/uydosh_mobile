#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "Error: not inside a git repository."
  exit 1
fi

cd "${REPO_ROOT}"

PUBSPEC="${REPO_ROOT}/pubspec.yaml"
if [[ ! -f "${PUBSPEC}" ]]; then
  echo "Error: pubspec.yaml not found at ${PUBSPEC}"
  exit 1
fi

# Flutter "version: x.y.z+build" — use full string so multiple builds/day differ when build number bumps.
VERSION_RAW="$(grep -m1 -E '^version:[[:space:]]+' "${PUBSPEC}" | sed -E 's/^version:[[:space:]]+//; s/[[:space:]]*#.*//; s/[[:space:]]+$//')"
if [[ -z "${VERSION_RAW}" ]]; then
  echo "Error: could not parse version: line in pubspec.yaml"
  exit 1
fi

# Git tags: '+' is awkward in some tooling; use '-' instead (still matches workflow patterns).
TAG_SUFFIX="${VERSION_RAW//+/-}"
ANDROID_TAG="android-${TAG_SUFFIX}"
IOS_TAG="ios-${TAG_SUFFIX}"

# Avoid local/remote tag conflicts.
git fetch --prune origin >/dev/null

if git show-ref --tags --verify --quiet "refs/tags/${ANDROID_TAG}"; then
  echo "Error: tag already exists locally: ${ANDROID_TAG}"
  exit 1
fi
if git show-ref --tags --verify --quiet "refs/tags/${IOS_TAG}"; then
  echo "Error: tag already exists locally: ${IOS_TAG}"
  exit 1
fi

# Check remote tags exist.
if git ls-remote --tags origin "${ANDROID_TAG}" | grep -q "${ANDROID_TAG}"; then
  echo "Error: tag already exists on origin: ${ANDROID_TAG}"
  exit 1
fi
if git ls-remote --tags origin "${IOS_TAG}" | grep -q "${IOS_TAG}"; then
  echo "Error: tag already exists on origin: ${IOS_TAG}"
  exit 1
fi

SHA="$(git rev-parse --short HEAD)"

echo "Tagging ${ANDROID_TAG} -> ${SHA}"
git tag "${ANDROID_TAG}"
echo "Tagging ${IOS_TAG} -> ${SHA}"
git tag "${IOS_TAG}"

git push origin "${ANDROID_TAG}" "${IOS_TAG}"

echo "Done. GitHub Actions should start Android (AAB) and iOS (TestFlight) builds."

