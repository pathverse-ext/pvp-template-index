#!/bin/bash
set -e

# Calculate SHA256 checksum of plugin.evc file
# Usage: calculate-checksum.sh PLUGIN_FILE
# Outputs: SHA256 checksum to stdout

PLUGIN_FILE="$1"

if [ -z "$PLUGIN_FILE" ]; then
  echo "Error: Missing plugin file path" >&2
  echo "Usage: calculate-checksum.sh PLUGIN_FILE" >&2
  exit 1
fi

if [ ! -f "$PLUGIN_FILE" ]; then
  echo "Error: Plugin file not found: $PLUGIN_FILE" >&2
  exit 1
fi

# Calculate and return SHA256 checksum
sha256sum "$PLUGIN_FILE" | cut -d' ' -f1
