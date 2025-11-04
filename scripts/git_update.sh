#!/usr/bin/env bash
set -euo pipefail

VERSION=""
while getopts v: flag; do
  case "${flag}" in
    v) VERSION=${OPTARG};;
  esac
done

git fetch --prune --unshallow 2>/dev/null || true
CURRENT_VERSION=$(git describe --abbrev=0 --tags 2>/dev/null || true)
if [[ -z "${CURRENT_VERSION}" ]]; then
  CURRENT_VERSION="v0.1.0"
fi
echo "Current Version: ${CURRENT_VERSION}"

CURRENT_VERSION=${CURRENT_VERSION:-v0.1.0}
ver_no_v=${CURRENT_VERSION#v}
IFS='.' read -r MAJOR MINOR PATCH <<EOF
$ver_no_v
EOF

case "$VERSION" in
  major) MAJOR=$((MAJOR+1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR+1)); PATCH=0 ;;
  patch) PATCH=$((PATCH+1)) ;;
  *) echo "Use -v [major|minor|patch]"; exit 1 ;;
esac

NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
echo "($VERSION) updating ${CURRENT_VERSION} to ${NEW_TAG}"

GIT_COMMIT=$(git rev-parse HEAD)
if git describe --contains "$GIT_COMMIT" >/dev/null 2>&1; then
  echo "Already a tag on this commit"
  NEW_TAG="$CURRENT_VERSION"
else
  git tag "${NEW_TAG}"
  git push --tags
  git push
fi

echo "new-tag=${NEW_TAG}" >> "$GITHUB_OUTPUT"
