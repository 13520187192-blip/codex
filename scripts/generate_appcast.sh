#!/usr/bin/env bash
set -euo pipefail

APP_NAME="BreakReminder"
DIST_DIR="dist"
VERSION="${1:-${GITHUB_REF_NAME#v}}"
ZIP_PATH="${2:-${DIST_DIR}/${APP_NAME}-${VERSION}.zip}"

if [[ -z "${VERSION}" ]]; then
  echo "Version is required. Pass as first arg or use GITHUB_REF_NAME=vX.Y.Z"
  exit 1
fi

if [[ ! -f "${ZIP_PATH}" ]]; then
  echo "Zip artifact not found: ${ZIP_PATH}"
  exit 1
fi

mkdir -p "${DIST_DIR}"

DOWNLOAD_URL="${DOWNLOAD_URL:-https://github.com/${GITHUB_REPOSITORY}/releases/download/v${VERSION}/$(basename "${ZIP_PATH}")}"
PUB_DATE="$(date -u '+%a, %d %b %Y %H:%M:%S %z')"
LENGTH="$(stat -f%z "${ZIP_PATH}")"

SIGNATURE="${SPARKLE_ED_SIGNATURE:-}"
if [[ -z "${SIGNATURE}" && -n "${SPARKLE_PRIVATE_KEY:-}" && -x "${SPARKLE_SIGN_TOOL:-}" ]]; then
  key_file="$(mktemp)"
  trap 'rm -f "${key_file}"' EXIT
  printf '%s' "${SPARKLE_PRIVATE_KEY}" > "${key_file}"
  SIGNATURE="$(${SPARKLE_SIGN_TOOL} --ed-key-file "${key_file}" "${ZIP_PATH}" | awk '{print $1}')"
fi

signature_attr=""
if [[ -n "${SIGNATURE}" ]]; then
  signature_attr=" sparkle:edSignature=\"${SIGNATURE}\""
fi

cat > "${DIST_DIR}/appcast.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>${APP_NAME} Updates</title>
    <item>
      <title>Version ${VERSION}</title>
      <pubDate>${PUB_DATE}</pubDate>
      <sparkle:version>${VERSION}</sparkle:version>
      <enclosure url="${DOWNLOAD_URL}" length="${LENGTH}" type="application/octet-stream"${signature_attr} />
    </item>
  </channel>
</rss>
XML

echo "Generated ${DIST_DIR}/appcast.xml"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "appcast_path=${DIST_DIR}/appcast.xml" >> "${GITHUB_OUTPUT}"
fi
