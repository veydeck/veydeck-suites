#!/bin/bash

set -euo pipefail

# Base directory is the workspace root
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Ensure we have a suite directory passed as argument
if [ -z "${1:-}" ]; then
    echo "Error: Missing suite directory argument."
    echo "Usage: $0 <suite_directory>"
    echo "Example: $0 suites/veydeck.host-scanner"
    exit 1
fi

SUITE_DIR="$1"

# Resolve absolute path
if [[ ! "$SUITE_DIR" = /* ]]; then
    SUITE_DIR="$BASE_DIR/$SUITE_DIR"
fi

if [ ! -d "$SUITE_DIR" ]; then
    echo "Error: Suite root directory '$SUITE_DIR' does not exist."
    exit 1
fi

# Ensure required files exist
if [ ! -f "$SUITE_DIR/suite.yaml" ]; then
    echo "Error: suite.yaml not found in $SUITE_DIR."
    exit 1
fi

if [ ! -f "$SUITE_DIR/compose.yaml" ]; then
    echo "Error: compose.yaml not found in $SUITE_DIR."
    exit 1
fi

# Parse suiteId, slug, version, and icon from suite.yaml
SUITE_ID=$(grep -E '^[[:space:]]*suiteId:' "$SUITE_DIR/suite.yaml" | head -n 1 | awk '{print $2}' | tr -d '\r"')
SUITE_SLUG=$(grep -E '^[[:space:]]*slug:' "$SUITE_DIR/suite.yaml" | head -n 1 | awk '{print $2}' | tr -d '\r"')
VERSION=$(grep -E '^[[:space:]]*version:' "$SUITE_DIR/suite.yaml" | head -n 1 | awk '{print $2}' | tr -d '\r"')
ICON_PATH=$(awk '
    /^metadata:/ { in_metadata = 1; next }
    in_metadata && /^[^[:space:]]/ { exit }
    in_metadata && /^[[:space:]]+icon:/ {
        value = $0
        sub(/^[[:space:]]+icon:[[:space:]]*/, "", value)
        gsub(/\r|"/, "", value)
        print value
        exit
    }
' "$SUITE_DIR/suite.yaml")

if [ -z "$SUITE_ID" ] || [ -z "$SUITE_SLUG" ] || [ -z "$VERSION" ] || [ -z "$ICON_PATH" ]; then
    echo "Error: Could not parse suiteId, slug, version, or metadata.icon from suite.yaml."
    exit 1
fi

if [[ ! "$SUITE_SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "Error: metadata.slug may only contain lowercase letters, digits, and hyphen: $SUITE_SLUG"
    exit 1
fi

if [[ "$ICON_PATH" != assets/* ]] || [ ! -f "$SUITE_DIR/$ICON_PATH" ]; then
    echo "Error: metadata.icon must reference an existing file under assets/: $ICON_PATH"
    exit 1
fi

echo "Found suite ID: $SUITE_ID, Slug: $SUITE_SLUG, Version: $VERSION"

# Run validation checks
echo "Running validation checks..."

# Docker Compose validation
if [ ! -f "$SUITE_DIR/.env" ] && [ -f "$SUITE_DIR/.env.example" ]; then
    cp "$SUITE_DIR/.env.example" "$SUITE_DIR/.env"
    REMOVE_DUMMY_ENV=true
else
    REMOVE_DUMMY_ENV=false
fi

if ! docker compose -f "$SUITE_DIR/compose.yaml" config >/dev/null; then
    echo "Error: docker compose config failed for $SUITE_DIR/compose.yaml."
    if [ "$REMOVE_DUMMY_ENV" = true ]; then rm "$SUITE_DIR/.env"; fi
    exit 1
fi

if [ "$REMOVE_DUMMY_ENV" = true ]; then
    rm "$SUITE_DIR/.env"
fi

# Create dist directory if it doesn't exist
RELEASE_OUT_DIR="$BASE_DIR/dist"
mkdir -p "$RELEASE_OUT_DIR"

PACKAGE_NAME="${SUITE_ID}-${VERSION}.vsp"
TARGET_PACKAGE="$RELEASE_OUT_DIR/$PACKAGE_NAME"

echo "Packaging suite..."

# .vsp 套件交付包内部使用 gzip 压缩 tar 格式，仅包含交付文件，不包含套件源码仓库。
tar -C "$SUITE_DIR" --exclude=".env" -czf "$TARGET_PACKAGE" .

echo "--------------------------------------------------------"
echo "Success! Package created at:"
echo "  $TARGET_PACKAGE"
echo "Package contents:"
tar -tf "$TARGET_PACKAGE"
echo "--------------------------------------------------------"
