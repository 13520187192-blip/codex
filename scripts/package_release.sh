#!/usr/bin/env bash
set -euo pipefail

APP_NAME="BreakReminder"
TARGET="BreakReminder"
PROJECT_PATH="BreakReminder.xcodeproj"
BUILD_DIR="build"
DIST_DIR="dist"

VERSION="${1:-${GITHUB_REF_NAME#v}}"
if [[ -z "${VERSION}" ]]; then
  echo "Version is required. Pass as first arg or use GITHUB_REF_NAME=vX.Y.Z"
  exit 1
fi

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "xcodebuild not found. Install Xcode before packaging."
  exit 1
fi

if [[ ! -d "${PROJECT_PATH}" ]]; then
  echo "Missing ${PROJECT_PATH}."
  exit 1
fi

rm -rf "${BUILD_DIR}" "${DIST_DIR}"
mkdir -p "${DIST_DIR}"

xcodebuild \
  -project "${PROJECT_PATH}" \
  -target "${TARGET}" \
  -configuration Release \
  -derivedDataPath "${BUILD_DIR}" \
  CODE_SIGNING_ALLOWED=NO \
  clean build

APP_PATH="${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app"
if [[ ! -d "${APP_PATH}" ]]; then
  echo "Build succeeded but ${APP_PATH} not found."
  exit 1
fi

ZIP_PATH="${DIST_DIR}/${APP_NAME}-${VERSION}.zip"
ditto -c -k --keepParent "${APP_PATH}" "${ZIP_PATH}"
shasum -a 256 "${ZIP_PATH}" > "${ZIP_PATH}.sha256"

echo "Packaged ${ZIP_PATH}"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "zip_path=${ZIP_PATH}" >> "${GITHUB_OUTPUT}"
fi
