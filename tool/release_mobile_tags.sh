#!/usr/bin/env bash
set -euo pipefail

# Semver in yellow, build number in green (disabled when not a TTY or NO_COLOR is set).
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_YELLOW='\033[33m'
  C_GREEN='\033[32m'
  C_RESET='\033[0m'
else
  C_YELLOW=''
  C_GREEN=''
  C_RESET=''
fi

usage() {
  cat <<'EOF'
Usage: tool/release_mobile_tags.sh [--bump {build|patch|minor|major}] [--commit]

Creates and pushes BOTH:
  - android-<version>
  - ios-<version>

Where <version> comes from pubspec.yaml "version: x.y.z+build" (converts '+' -> '-' for the git tag).

Options:
  --bump <type>   Bump version first using scripts/bump_version.py (modifies files)
  --commit        Commit the version bump before tagging
EOF
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "Error: not inside a git repository."
  exit 1
fi

cd "${REPO_ROOT}"

BUMPTYPE=""
DO_COMMIT="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --bump)
      BUMPTYPE="${2:-}"
      shift 2
      ;;
    --commit)
      DO_COMMIT="true"
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

if [[ -n "${BUMPTYPE}" ]]; then
  if [[ ! -f "scripts/bump_version.py" ]]; then
    echo "Error: scripts/bump_version.py not found. Remove --bump or add the script."
    exit 1
  fi
  if [[ "${BUMPTYPE}" != "build" && "${BUMPTYPE}" != "patch" && "${BUMPTYPE}" != "minor" && "${BUMPTYPE}" != "major" ]]; then
    echo "Error: invalid --bump value: ${BUMPTYPE}"
    usage
    exit 2
  fi

  python3 scripts/bump_version.py "${BUMPTYPE}"

  if [[ "${DO_COMMIT}" == "true" ]]; then
    # Commit the bump so tags point to an immutable commit.
    git add pubspec.yaml lib/base/constants/app_version.dart lib/presentation/widgets/burger_menu_widget.dart || true
    if ! git diff --cached --quiet; then
      NEW_VERSION="$(grep -m1 -E '^version:[[:space:]]+' pubspec.yaml | sed -E 's/^version:[[:space:]]+//; s/[[:space:]]*#.*//; s/[[:space:]]+$//')"
      git commit -m "Bump version to ${NEW_VERSION}"
      git push
    fi
  else
    if ! git diff --quiet; then
      echo "Version was bumped but not committed."
      echo "Commit & push the bump (or rerun with --commit), then rerun this script."
      exit 1
    fi
  fi
fi

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

if [[ "${VERSION_RAW}" == *+* ]]; then
  VERSION_SEMVER="${VERSION_RAW%%+*}"
  VERSION_BUILD="${VERSION_RAW#*+}"
else
  VERSION_SEMVER="${VERSION_RAW}"
  VERSION_BUILD=""
fi

colored_pubspec_version() {
  if [[ -n "${VERSION_BUILD}" ]]; then
    printf '%b' "${C_YELLOW}${VERSION_SEMVER}${C_RESET}${C_GREEN}+${VERSION_BUILD}${C_RESET}"
  else
    printf '%b' "${C_YELLOW}${VERSION_SEMVER}${C_RESET}"
  fi
}

colored_platform_tag() {
  local platform="$1"
  if [[ -n "${VERSION_BUILD}" ]]; then
    printf '%b' "${platform}-${C_YELLOW}${VERSION_SEMVER}${C_RESET}-${C_GREEN}${VERSION_BUILD}${C_RESET}"
  else
    printf '%b' "${platform}-${C_YELLOW}${VERSION_SEMVER}${C_RESET}"
  fi
}

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

echo -e "Tagging $(colored_platform_tag android) -> ${SHA}"
git tag "${ANDROID_TAG}"
echo -e "Tagging $(colored_platform_tag ios) -> ${SHA}"
git tag "${IOS_TAG}"

git push origin "${ANDROID_TAG}" "${IOS_TAG}"

echo -e "Done. Build version $(colored_pubspec_version). GitHub Actions should start Android (AAB) and iOS (TestFlight) builds."

