#!/bin/bash
set -e

# Update index.json with new plugin entry
# Usage: update-index.sh INDEX_FILE MANIFEST_FILE SHA256_KEY

INDEX_FILE="$1"
MANIFEST_FILE="$2"
SHA256_KEY="$3"

if [ -z "$INDEX_FILE" ] || [ -z "$MANIFEST_FILE" ] || [ -z "$SHA256_KEY" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: update-index.sh INDEX_FILE MANIFEST_FILE SHA256_KEY"
  exit 1
fi

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "Error: Manifest file not found: $MANIFEST_FILE"
  exit 1
fi

# Create index.json if it doesn't exist
if [ ! -f "$INDEX_FILE" ]; then
  echo '{}' > "$INDEX_FILE"
fi

# Read manifest content
MANIFEST_CONTENT=$(cat "$MANIFEST_FILE")

# Update index with SHA256 as key and manifest as value
jq --arg sha "$SHA256_KEY" \
   --argjson manifest "$MANIFEST_CONTENT" \
   '.[$sha] = $manifest' "$INDEX_FILE" > "${INDEX_FILE}.tmp"

mv "${INDEX_FILE}.tmp" "$INDEX_FILE"

echo "✓ Updated index.json with SHA256 key: $SHA256_KEY"
