# Pin Feature Guide

## Overview

The `pin` field in a plugin manifest prevents that version from being evicted when newer patch versions are released.

## Manifest Schema

```json
{
  "name": "plugin_name",
  "description": "Plugin description",
  "version": "1.0.5",
  "author": "Author Name",
  "pin": true  // Optional, defaults to false
}
```

## Use Cases

### 1. Long-Term Support (LTS) Releases

Mark stable releases that should remain available:

```json
{
  "name": "my_plugin",
  "version": "1.0.0",
  "description": "LTS Release - Stable",
  "pin": true
}
```

When v1.0.1, v1.0.2, etc. are released, v1.0.0 remains available.

### 2. Last Known Good Version

Before a major refactor, pin the last stable version:

```json
{
  "name": "my_plugin",
  "version": "2.3.9",
  "description": "Last version before v2.4.0 rewrite",
  "pin": true
}
```

### 3. Critical Hotfix Versions

Pin versions that fix critical bugs:

```json
{
  "name": "my_plugin",
  "version": "1.2.5",
  "description": "Critical security fix",
  "pin": true
}
```

### 4. Compatibility Versions

Maintain versions required for specific integrations:

```json
{
  "name": "my_plugin",
  "version": "3.0.2",
  "description": "Compatible with legacy systems",
  "pin": true
}
```

## Behavior Examples

### Without Pin (Default)
```
Release v1.0.0 → Indexed
Release v1.0.1 → v1.0.0 evicted ❌
Release v1.0.2 → v1.0.1 evicted ❌

Result: Only v1.0.2 remains
```

### With Pin on v1.0.0
```
Release v1.0.0 (pin: true) → Indexed 📌
Release v1.0.1 → v1.0.0 kept (pinned) 📌
Release v1.0.2 → v1.0.1 evicted ❌, v1.0.0 kept 📌

Result: v1.0.0 (pinned) and v1.0.2 coexist
```

### Multiple Pinned Versions
```
Release v1.0.0 (pin: true) → Indexed 📌
Release v1.0.5 (pin: true) → Indexed 📌
Release v1.0.7 → Indexed

Result: v1.0.0 📌, v1.0.5 📌, and v1.0.7 all coexist
```

## Best Practices

### ✅ Do
- Pin LTS releases
- Pin last-known-good before major changes
- Pin critical security fixes
- Document WHY a version is pinned (in description)

### ❌ Don't
- Pin every version (defeats the purpose of eviction)
- Pin development/beta versions
- Pin without documentation
- Use pin for version management (use semver properly)

## Workflow Integration

The pin check happens automatically during the eviction process:

1. New version is released
2. Eviction script checks existing versions
3. **Pin check**: Skip versions with `"pin": true`
4. Evict non-pinned versions matching criteria
5. Index new version

## Removing a Pin

To allow a pinned version to be evicted:

1. Update the manifest in your plugin repository
2. Remove or set `"pin": false`
3. Create a new release
4. The version will be evictable on next patch release

**Note:** You cannot retroactively unpin a version already in the index. The pin status is stored with the indexed manifest.

## Index Format with Pins

```json
{
  "abc123...": {
    "name": "my_plugin",
    "version": "1.0.0",
    "pin": true
  },
  "def456...": {
    "name": "my_plugin",
    "version": "1.0.5",
    "pin": true
  },
  "ghi789...": {
    "name": "my_plugin",
    "version": "1.0.7"
  }
}
```

In this example:
- v1.0.0 and v1.0.5 are pinned and protected
- v1.0.7 is unpinned and will be evicted by v1.0.8
