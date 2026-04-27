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
# Git tag: '+' is awkward in some tooling; use '-' instead (still matches workflow android-*).
TAG_SUFFIX="${VERSION_RAW//+/-}"
TAG="android-${TAG_SUFFIX}"

git fetch --prune --tags origin >/dev/null

SHA="$(git rev-parse --short HEAD)"

echo "Tagging ${TAG} -> ${SHA}"
git tag "${TAG}"
git push origin "${TAG}"

echo "Done. GitHub Actions should start the Android build."
