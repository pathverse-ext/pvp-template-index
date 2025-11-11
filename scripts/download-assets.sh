#!/bin/bash
set -e

# Download release assets from GitHub repository
# Usage: download-assets.sh REPO TAG_NAME TEMP_DIR

REPO="$1"
TAG_NAME="$2"
TEMP_DIR="$3"

if [ -z "$REPO" ] || [ -z "$TAG_NAME" ] || [ -z "$TEMP_DIR" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: download-assets.sh REPO TAG_NAME TEMP_DIR"
  exit 1
fi

mkdir -p "$TEMP_DIR"

echo "Downloading assets from $REPO release $TAG_NAME"

# Download manifest.json
echo "Downloading manifest.json..."
gh release download "$TAG_NAME" \
  --repo "$REPO" \
  --pattern "manifest.json" \
  --dir "$TEMP_DIR"

# Download plugin.evc
echo "Downloading plugin.evc..."
gh release download "$TAG_NAME" \
  --repo "$REPO" \
  --pattern "plugin.evc" \
  --dir "$TEMP_DIR"

# Verify both files exist
if [ ! -f "$TEMP_DIR/manifest.json" ]; then
  echo "Error: manifest.json not found"
  exit 1
fi

if [ ! -f "$TEMP_DIR/plugin.evc" ]; then
  echo "Error: plugin.evc not found"
  exit 1
fi

echo "✓ Assets downloaded to $TEMP_DIR"
ls -la "$TEMP_DIR"
