#!/usr/bin/env bash
# Optional: duplicate the sideload APK to the static site repository via GitHub Releases.
# Primary rolling release is created in uydosh_mobile by CI (GITHUB_TOKEN) — see release-apk.yml.
#
# Tag "android-latest", asset basename must be app-release.apk
# (matches https://github.com/uydoshtech/uydoshtech.github.io/releases/latest/download/app-release.apk).
# The landing page may read build metadata from releases/tags/android-latest on that repo.
#
# iOS builds go to TestFlight / App Store only — not published here.
#
# Env:
#   UYDOSH_WEBSITE_RELEASE_TOKEN — PAT with contents + releases on the website repo (preferred)
#   SITE_REPO_TOKEN — legacy name (same permissions); used if UYDOSH_WEBSITE_RELEASE_TOKEN is unset
#   GH_TOKEN — fallback when neither of the above is set
#   UYDOSH_WEBSITE_REPO — optional, default uydoshtech/uydoshtech.github.io
#   GITHUB_REPOSITORY, GITHUB_SHA — for release notes (set automatically in Actions)
#   BUILD_NAME, BUILD_NUMBER — shown in release title
#
# Usage:
#   publish_mobile_to_website.sh /path/to/built-app-release.apk

set -euo pipefail

SRC_ASSET="${1:?usage: publish_mobile_to_website.sh <apk-path>}"
REPO="${UYDOSH_WEBSITE_REPO:-uydoshtech/uydoshtech.github.io}"
TAG="android-latest"

TOKEN="${UYDOSH_WEBSITE_RELEASE_TOKEN:-${SITE_REPO_TOKEN:-${GH_TOKEN:-}}}"
if [[ -z "${TOKEN}" ]]; then
  echo "::warning::No UYDOSH_WEBSITE_RELEASE_TOKEN, SITE_REPO_TOKEN, or GH_TOKEN; skipping website publish."
  exit 0
fi
export GH_TOKEN="${TOKEN}"

if [[ ! -f "${SRC_ASSET}" ]]; then
  echo "Error: APK file not found: ${SRC_ASSET}" >&2
  exit 1
fi

TMP_DIR=""
cleanup() {
  if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
    rm -rf "${TMP_DIR}"
  fi
}
trap cleanup EXIT

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/uydosh-website-apk.XXXXXX")"
WORK_ASSET="${TMP_DIR}/app-release.apk"
cp "${SRC_ASSET}" "${WORK_ASSET}"

OWNER="${REPO%%/*}"
NAME="${REPO#*/}"
SHA_FULL="${GITHUB_SHA:-}"
SHA_SHORT=""
if [[ -n "${SHA_FULL}" ]]; then
  SHA_SHORT="${SHA_FULL:0:7}"
fi

NOTES=$(
  cat <<EOF
Automated from ${GITHUB_REPOSITORY:-local}@${SHA_FULL:-unknown}

@${SHA_SHORT:-unknown}
EOF
)

TITLE="Android ${BUILD_NAME:-?}+${BUILD_NUMBER:-?}"

gh release delete "${TAG}" --repo "${REPO}" --yes --cleanup-tag 2>/dev/null || true
gh api -X DELETE "repos/${OWNER}/${NAME}/git/refs/tags/${TAG}" 2>/dev/null || true

gh release create "${TAG}" "${WORK_ASSET}" \
  --repo "${REPO}" \
  --title "${TITLE}" \
  --notes "${NOTES}" \
  --latest
