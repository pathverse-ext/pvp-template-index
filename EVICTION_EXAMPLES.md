# Eviction Logic Examples

## Scenario 1: Patch Version Updates
```
Initial State:
  index.json: { "abc123...": { "name": "my_plugin", "version": "1.0.0" } }
  plugins/abc123....evc

After releasing v1.0.1:
  index.json: { "def456...": { "name": "my_plugin", "version": "1.0.1" } }
  plugins/def456....evc
  
  ❌ Evicted: abc123....evc (v1.0.0)
```

## Scenario 2: Minor Version Update
```
Initial State:
  index.json: { 
    "abc123...": { "name": "my_plugin", "version": "1.0.9" }
  }
  plugins/abc123....evc

After releasing v1.1.0:
  index.json: { 
    "abc123...": { "name": "my_plugin", "version": "1.0.9" },
    "ghi789...": { "name": "my_plugin", "version": "1.1.0" }
  }
  plugins/abc123....evc
  plugins/ghi789....evc
  
  ✅ Kept: abc123....evc (v1.0.9) - different minor version
```

## Scenario 3: Multiple Versions Coexisting
```
State after multiple releases:
  index.json: { 
    "sha_1.0.5": { "name": "my_plugin", "version": "1.0.5" },
    "sha_1.1.3": { "name": "my_plugin", "version": "1.1.3" },
    "sha_2.0.1": { "name": "my_plugin", "version": "2.0.1" }
  }

After releasing v1.1.4:
  index.json: { 
    "sha_1.0.5": { "name": "my_plugin", "version": "1.0.5" },
    "sha_1.1.4": { "name": "my_plugin", "version": "1.1.4" },
    "sha_2.0.1": { "name": "my_plugin", "version": "2.0.1" }
  }
  
  ❌ Evicted: sha_1.1.3 (v1.1.3) - same 1.1.x, higher patch
  ✅ Kept: sha_1.0.5 (v1.0.5) - different minor (1.0 vs 1.1)
  ✅ Kept: sha_2.0.1 (v2.0.1) - different major (2 vs 1)
```

## Version Tree Visualization
```
v1.0.0 ──> v1.0.1 ──> v1.0.2 (only latest patch kept per minor)
           (evicts    (evicts
            v1.0.0)    v1.0.1)

v1.1.0 ──> v1.1.1 ──> v1.1.2 (coexists with v1.0.x)
           (evicts    (evicts
            v1.1.0)    v1.1.1)

v2.0.0 (coexists with all v1.x versions)
```

## Rule Summary

| New Version | Existing Version | Action | Reason |
|------------|------------------|---------|---------|
| 1.0.1 | 1.0.0 | ❌ EVICT | Same major.minor, higher patch |
| 1.0.2 | 1.0.1 | ❌ EVICT | Same major.minor, higher patch |
| 1.1.0 | 1.0.9 | ✅ KEEP | Different minor version |
| 1.1.1 | 1.1.0 | ❌ EVICT | Same major.minor, higher patch |
| 1.1.1 | 1.0.9 | ✅ KEEP | Different minor version |
| 2.0.0 | 1.9.9 | ✅ KEEP | Different major version |
| 2.0.1 | 2.0.0 | ❌ EVICT | Same major.minor, higher patch |
| 1.0.1 | 1.0.0 (pinned) | 📌 KEEP | Pinned versions protected |

## Scenario 4: Pinned Versions
```
Initial State:
  index.json: { 
    "abc123...": { "name": "my_plugin", "version": "1.0.0", "pin": true }
  }
  plugins/abc123....evc

After releasing v1.0.1:
  index.json: { 
    "abc123...": { "name": "my_plugin", "version": "1.0.0", "pin": true },
    "def456...": { "name": "my_plugin", "version": "1.0.1" }
  }
  plugins/abc123....evc
  plugins/def456....evc
  
  📌 Protected: abc123....evc (v1.0.0 is pinned)
```

### Pinning Use Cases

**When to pin a version:**
- Stable releases that should remain available indefinitely
- Last known good version before major refactoring
- Versions required for backward compatibility
- Critical hotfix versions

**How to pin:**
Add `"pin": true` to the manifest.json before releasing:
```json
{
  "name": "my_plugin",
  "version": "1.0.5",
  "description": "Stable LTS version",
  "pin": true
}
```
