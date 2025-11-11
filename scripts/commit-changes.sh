#!/bin/bash
set -e

# Commit and push changes to repository
# Usage: commit-changes.sh SHA256_KEY PLUGIN_NAME VERSION REPO

SHA256_KEY="$1"
PLUGIN_NAME="$2"
VERSION="$3"
REPO="$4"

if [ -z "$SHA256_KEY" ] || [ -z "$PLUGIN_NAME" ] || [ -z "$VERSION" ] || [ -z "$REPO" ]; then
  echo "Error: Missing required arguments"
  echo "Usage: commit-changes.sh SHA256_KEY PLUGIN_NAME VERSION REPO"
  exit 1
fi

# Configure Git
git config user.name "github-actions[bot]"
git config user.email "github-actions[bot]@users.noreply.github.com"

# Add changed files (including any deletions from eviction)
git add "plugins/${SHA256_KEY}.evc"
git add plugins/*.evc 2>/dev/null || true  # Add any remaining plugins
git add -u plugins/  # Stage deletions
git add index.json

# Check if there are changes to commit
if git diff --staged --quiet; then
  echo "No changes to commit"
else
  git commit -m "Add $PLUGIN_NAME $VERSION" \
    -m "" \
    -m "Plugin: $PLUGIN_NAME" \
    -m "Version: $VERSION" \
    -m "SHA256: $SHA256_KEY" \
    -m "Source: $REPO"
  
  git push
  echo "✓ Successfully indexed $PLUGIN_NAME $VERSION (SHA256: $SHA256_KEY)"
fi
