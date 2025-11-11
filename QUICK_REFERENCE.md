# Quick Reference: Eviction & Pin System

## Eviction Rules at a Glance

| Scenario | Result | Example |
|----------|--------|---------|
| Patch increment (same major.minor) | ❌ EVICT | v1.0.1 → evicts v1.0.0 |
| Minor increment | ✅ KEEP | v1.1.0 → keeps v1.0.9 |
| Major increment | ✅ KEEP | v2.0.0 → keeps v1.9.9 |
| Version has `pin: true` | 📌 KEEP | v1.0.0 (pinned) → never evicted |

## Manifest Examples

### Regular Version (Will be evicted by newer patches)
```json
{
  "name": "my_plugin",
  "version": "1.0.5",
  "description": "Regular release",
  "author": "Author Name"
}
```

### Pinned Version (Protected from eviction)
```json
{
  "name": "my_plugin",
  "version": "1.0.0",
  "description": "LTS Release",
  "author": "Author Name",
  "pin": true
}
```

## Index Structure

```json
{
  "sha256_checksum": {
    "name": "plugin_name",
    "version": "1.0.5",
    "description": "...",
    "pin": true  // optional
  }
}
```

## Workflow Steps

1. **Download** → `download-assets.sh`
2. **Checksum** → `calculate-checksum.sh` (SHA256 of plugin.evc)
3. **Copy** → Move plugin.evc to `plugins/{sha256}.evc`
4. **Evict** → `evict-previous-patch.sh` (respects pins)
5. **Index** → `update-index.sh` (add to index.json)
6. **Commit** → `commit-changes.sh` (includes deletions)

## Quick Decision Tree

```
New version released (e.g., v1.0.5)
    ↓
Find existing versions with same name
    ↓
For each existing version:
    ├─ Different major? → KEEP
    ├─ Different minor? → KEEP
    ├─ Has pin: true? → KEEP 📌
    ├─ Same major.minor, lower patch? → EVICT ❌
    └─ Same major.minor, higher patch? → KEEP
```

## Common Commands

```bash
# Calculate checksum
./scripts/calculate-checksum.sh temp_download/plugin.evc

# Check for evictions (dry run - read script output)
./scripts/evict-previous-patch.sh index.json plugin_name v1.0.5

# Update index
./scripts/update-index.sh index.json manifest.json <sha256>

# Commit changes
./scripts/commit-changes.sh <sha256> plugin_name v1.0.5 repo/name
```

## File Locations

- **Index**: `index.json`
- **Plugins**: `plugins/{sha256}.evc`
- **Scripts**: `scripts/*.sh`
- **Workflow**: `.github/workflows/index-plugin.yml`

## Documentation Files

- `README.md` - Overview and structure
- `EVICTION_EXAMPLES.md` - Detailed scenarios
- `PIN_FEATURE.md` - Pin system guide
- `scripts/README.md` - Script documentation
