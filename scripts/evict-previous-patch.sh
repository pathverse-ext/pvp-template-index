#!/bin/bash
set -e

# Evict previous patch versions of a plugin
# Usage: evict-previous-patch.sh INDEX_FILE PLUGIN_NAME NEW_VERSION

INDEX_FILE="$1"
PLUGIN_NAME="$2"
NEW_VERSION="$3"

if [ -z "$INDEX_FILE" ] || [ -z "$PLUGIN_NAME" ] || [ -z "$NEW_VERSION" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: evict-previous-patch.sh INDEX_FILE PLUGIN_NAME NEW_VERSION"
  exit 1
fi

if [ ! -f "$INDEX_FILE" ]; then
  echo "Error: Index file not found: $INDEX_FILE"
  exit 1
fi

# Parse version components (strip 'v' prefix if present)
NEW_VERSION_CLEAN="${NEW_VERSION#v}"
IFS='.' read -r NEW_MAJOR NEW_MINOR NEW_PATCH <<< "$NEW_VERSION_CLEAN"

echo "Checking for evictable versions of $PLUGIN_NAME (new version: $NEW_MAJOR.$NEW_MINOR.$NEW_PATCH)"

# Find all entries with matching plugin name
EVICTED_COUNT=0
EVICTED_SHAS=()

# Read through index and find entries to evict
while IFS= read -r sha; do
  # Get manifest for this SHA
  MANIFEST=$(jq -r --arg sha "$sha" '.[$sha]' "$INDEX_FILE")
  NAME=$(echo "$MANIFEST" | jq -r '.name')
  VERSION=$(echo "$MANIFEST" | jq -r '.version')
  
  # Skip if not the same plugin
  if [ "$NAME" != "$PLUGIN_NAME" ]; then
    continue
  fi
  
  # Check if version is pinned
  PINNED=$(echo "$MANIFEST" | jq -r '.pin // false')
  
  if [ "$PINNED" = "true" ]; then
    echo "  📌 Skipping $NAME v$VERSION (pinned)"
    continue
  fi
  
  # Parse existing version (strip 'v' prefix if present)
  VERSION_CLEAN="${VERSION#v}"
  IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION_CLEAN"
  
  # Eviction logic:
  # - Same major.minor, but lower patch = evict (e.g., 1.0.1 evicts 1.0.0)
  # - Different major or minor = keep (e.g., 1.1.0 doesn't evict 1.0.9)
  # - Pinned versions are never evicted
  if [ "$MAJOR" = "$NEW_MAJOR" ] && [ "$MINOR" = "$NEW_MINOR" ] && [ "$PATCH" -lt "$NEW_PATCH" ]; then
    echo "  ⚠️  Evicting $NAME v$VERSION (SHA: $sha)"
    EVICTED_SHAS+=("$sha")
    ((EVICTED_COUNT++))
  fi
done < <(jq -r 'keys[]' "$INDEX_FILE")

# Remove evicted entries from index
if [ "$EVICTED_COUNT" -gt 0 ]; then
  echo "Removing $EVICTED_COUNT evicted version(s) from index..."
  
  # Build jq filter to delete evicted SHAs
  JQ_FILTER="."
  for sha in "${EVICTED_SHAS[@]}"; do
    JQ_FILTER="$JQ_FILTER | del(.\"$sha\")"
  done
  
  jq "$JQ_FILTER" "$INDEX_FILE" > "${INDEX_FILE}.tmp"
  mv "${INDEX_FILE}.tmp" "$INDEX_FILE"
  
  # Delete evicted plugin files
  for sha in "${EVICTED_SHAS[@]}"; do
    PLUGIN_FILE="plugins/${sha}.evc"
    if [ -f "$PLUGIN_FILE" ]; then
      echo "  🗑️  Deleting $PLUGIN_FILE"
      rm "$PLUGIN_FILE"
    fi
  done
  
  echo "✓ Evicted $EVICTED_COUNT previous patch version(s)"
else
  echo "✓ No versions to evict"
fi
