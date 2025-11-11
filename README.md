# pvp-template-index

PathVerse Plugin Index - A content-addressed plugin registry using SHA256 checksums.

## Structure

### Index Format
The `index.json` uses SHA256 checksums as keys with plugin manifest data as values:

```json
{
  "f0b36c58bccc1faf14fd20021b2ea6c214b437eeab8892a07f44ebb5b7c81883": {
    "name": "dart_plugin_template",
    "description": "A template plugin for dart_eval (Dart only)",
    "version": "0.1.1",
    "author": "Your Name"
  }
}
```

### Plugin Storage
Plugins are stored in `plugins/` directory with SHA256 filenames:
```
plugins/
  f0b36c58bccc1faf14fd20021b2ea6c214b437eeab8892a07f44ebb5b7c81883.evc
  535a057921f17ce48c00489424fc41f40a66beab7a38cb77c71d736498c8a183.evc
```

## Features

- **Content-Addressed**: SHA256 checksums ensure integrity and prevent duplicates
- **Version-Agnostic**: Same plugin binary across versions shares the same file
- **Modular Scripts**: Bash scripts in `scripts/` directory for easy maintenance
- **Automated Indexing**: GitHub Actions workflow for automatic plugin registration
- **Smart Eviction**: Automatically removes previous patch versions to save space

## Version Eviction Policy

When a new plugin version is indexed, previous patch versions are automatically evicted:

- ✅ `v1.0.1` **evicts** `v1.0.0` (same major.minor, higher patch)
- ✅ `v1.0.2` **evicts** `v1.0.1` (same major.minor, higher patch)
- ❌ `v1.1.0` **does NOT evict** `v1.0.9` (different minor version)
- ❌ `v2.0.0` **does NOT evict** `v1.9.9` (different major version)
- 📌 **Pinned versions are never evicted** (manifest with `"pin": true`)

This ensures only the latest patch of each minor version is kept, reducing storage while maintaining compatibility across minor/major versions.

### Pinning Versions

To prevent a specific version from being evicted, add `"pin": true` to its manifest.json:

```json
{
  "name": "my_plugin",
  "version": "1.0.5",
  "pin": true
}
```

Pinned versions remain in the index even when newer patches are released.

## Workflow

The indexing process is automated via GitHub Actions:

1. Plugin repository creates a release with `manifest.json` and `plugin.evc`
2. Repository dispatch triggers the index workflow
3. Downloads assets, calculates SHA256
4. **Evicts previous patch versions** (e.g., v1.0.1 removes v1.0.0)
5. Updates index and stores plugin as `{sha256}.evc`
6. Commits changes including any evicted file deletions

See [`scripts/README.md`](scripts/README.md) for details on the modular bash scripts.

## Documentation

- **[Quick Reference](QUICK_REFERENCE.md)** - At-a-glance rules and commands
- **[Eviction Examples](EVICTION_EXAMPLES.md)** - Detailed scenarios and visualizations
- **[Pin Feature Guide](PIN_FEATURE.md)** - How to use the pin system
- **[Scripts Documentation](scripts/README.md)** - Modular bash scripts reference

