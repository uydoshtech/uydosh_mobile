#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "Error: not inside a git repository."
  exit 1
fi

cd "${REPO_ROOT}"

git fetch --prune --tags origin >/dev/null

TAG="android-$(date -u +%Y.%m.%d.%H%M)"
SHA="$(git rev-parse --short HEAD)"

echo "Tagging ${TAG} -> ${SHA}"
git tag "${TAG}"
git push origin "${TAG}"

echo "Done. GitHub Actions should start the Android build."
