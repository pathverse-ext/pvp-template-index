# Plugin Index Scripts

Modular bash scripts for processing and indexing PathVerse plugins.

## Scripts

### `download-assets.sh`
Downloads manifest.json and plugin.evc from a GitHub release.

**Usage:**
```bash
./download-assets.sh REPO TAG_NAME TEMP_DIR
```

**Example:**
```bash
./download-assets.sh pathverse-ext/pvp-my-plugin v1.0.0 temp_download
```

### `calculate-checksum.sh`
Calculates SHA256 checksum of a plugin.evc file.

**Usage:**
```bash
./calculate-checksum.sh PLUGIN_FILE
```

**Example:**
```bash
SHA256=$(./calculate-checksum.sh temp_download/plugin.evc)
echo $SHA256
```

### `evict-previous-patch.sh`
Evicts (removes) previous patch versions of a plugin based on semantic versioning rules.

**Eviction Rules:**
- Patch version increments evict the previous patch: `1.0.1` evicts `1.0.0`
- Minor/major version changes do NOT evict previous minor versions: `1.1.0` does NOT evict `1.0.9`
- Only same major.minor with lower patch numbers are evicted
- **Pinned versions are never evicted** (manifest with `"pin": true`)

**Usage:**
```bash
./evict-previous-patch.sh INDEX_FILE PLUGIN_NAME NEW_VERSION
```

**Example:**
```bash
# Adding v1.0.1 will evict v1.0.0
./evict-previous-patch.sh index.json my_plugin v1.0.1

# Adding v1.1.0 will NOT evict v1.0.9 (different minor version)
./evict-previous-patch.sh index.json my_plugin v1.1.0

# Pinned versions are protected from eviction
# If v1.0.0 has "pin": true in manifest, it won't be evicted by v1.0.1
```

### `update-index.sh`
Updates index.json with a new plugin entry using SHA256 as the key.

**Usage:**
```bash
./update-index.sh INDEX_FILE MANIFEST_FILE SHA256_KEY
```

**Example:**
```bash
./update-index.sh index.json temp_download/manifest.json f0b36c58bccc...
```

### `commit-changes.sh`
Commits and pushes changes to the repository.

**Usage:**
```bash
./commit-changes.sh SHA256_KEY PLUGIN_NAME VERSION REPO
```

**Example:**
```bash
./commit-changes.sh f0b36c58bccc... my-plugin v1.0.0 pathverse-ext/pvp-my-plugin
```

## Index Structure

The index uses SHA256 checksums as keys with manifest data as values:

```json
{
  "sha256_of_plugin": {
    "name": "plugin_name",
    "description": "Plugin description",
    "version": "1.0.0",
    "author": "Author Name"
  }
}
```

## Plugin Storage

Plugins are stored in the `plugins/` directory with SHA256 checksums as filenames:

```
plugins/
  f0b36c58bccc1faf14fd20021b2ea6c214b437eeab8892a07f44ebb5b7c81883.evc
  535a057921f17ce48c00489424fc41f40a66beab7a38cb77c71d736498c8a183.evc
```

This structure ensures:
- No duplicate plugins (same content = same SHA256)
- Version-agnostic storage (content-based addressing)
- Efficient deduplication across versions
