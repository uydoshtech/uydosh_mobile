#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tool/bump_version.sh [{build|patch|minor|major}] [--commit] [--push]

Bumps version in pubspec.yaml and related app files via scripts/bump_version.py.

Bump types:
  build   Increment build number only (default)
  patch   Increment patch version, reset build to 1
  minor   Increment minor version, reset patch and build
  major   Increment major version, reset minor, patch, and build

Options:
  --bump <type>   Bump type (alternative to positional argument)
  --commit        Git commit the version bump
  --push          Push after commit (requires --commit)
EOF
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "Error: not inside a git repository."
  exit 1
fi

cd "${REPO_ROOT}"

BUMPTYPE="build"
DO_COMMIT="false"
DO_PUSH="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    build|patch|minor|major)
      BUMPTYPE="$1"
      shift
      ;;
    --bump)
      BUMPTYPE="${2:-}"
      shift 2
      ;;
    --commit)
      DO_COMMIT="true"
      shift
      ;;
    --push)
      DO_PUSH="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 2
      ;;
  esac
done

if [[ "${DO_PUSH}" == "true" && "${DO_COMMIT}" != "true" ]]; then
  echo "Error: --push requires --commit."
  exit 2
fi

if [[ "${BUMPTYPE}" != "build" && "${BUMPTYPE}" != "patch" && "${BUMPTYPE}" != "minor" && "${BUMPTYPE}" != "major" ]]; then
  echo "Error: invalid bump type: ${BUMPTYPE}"
  usage
  exit 2
fi

if [[ ! -f "scripts/bump_version.py" ]]; then
  echo "Error: scripts/bump_version.py not found."
  exit 1
fi

python3 scripts/bump_version.py "${BUMPTYPE}"

NEW_VERSION="$(grep -m1 -E '^version:[[:space:]]+' pubspec.yaml | sed -E 's/^version:[[:space:]]+//; s/[[:space:]]*#.*//; s/[[:space:]]+$//')"

if [[ "${DO_COMMIT}" == "true" ]]; then
  git add pubspec.yaml lib/base/constants/app_version.dart lib/presentation/widgets/burger_menu_widget.dart || true
  if ! git diff --cached --quiet; then
    git commit -m "Bump version to ${NEW_VERSION}"
    if [[ "${DO_PUSH}" == "true" ]]; then
      git push
    fi
  fi
fi

echo "Done. Version is now ${NEW_VERSION}."
