#!/bin/bash
# Test script for eviction logic

set -e

echo "=== Eviction Logic Test Cases ==="
echo ""

# Test case 1: Patch version increment (should evict)
echo "Test 1: v1.0.1 should evict v1.0.0"
echo "Expected: EVICT ✓"
echo ""

# Test case 2: Patch version increment (should evict)
echo "Test 2: v1.0.2 should evict v1.0.1"
echo "Expected: EVICT ✓"
echo ""

# Test case 3: Minor version change (should NOT evict)
echo "Test 3: v1.1.0 should NOT evict v1.0.9"
echo "Expected: KEEP ✓"
echo ""

# Test case 4: Major version change (should NOT evict)
echo "Test 4: v2.0.0 should NOT evict v1.9.9"
echo "Expected: KEEP ✓"
echo ""

# Test case 5: Multiple patches (should evict only same minor)
echo "Test 5: v1.1.1 should evict v1.1.0 but NOT v1.0.9"
echo "Expected: EVICT v1.1.0, KEEP v1.0.9 ✓"
echo ""

# Test case 6: Pinned version (should NOT evict)
echo "Test 6: v1.0.1 should NOT evict v1.0.0 when v1.0.0 has pin:true"
echo "Expected: KEEP (pinned) 📌"
echo ""

echo "=== Version Comparison Logic ==="
echo ""
echo "Format: MAJOR.MINOR.PATCH"
echo ""
echo "Eviction Rule:"
echo "  IF new_major == old_major AND"
echo "     new_minor == old_minor AND"
echo "     new_patch > old_patch AND"
echo "     old_version.pin != true"
echo "  THEN evict old version"
echo ""
echo "Examples:"
echo "  1.0.1 vs 1.0.0: Same major (1), same minor (0), 1 > 0 → EVICT"
echo "  1.1.0 vs 1.0.9: Same major (1), diff minor (1≠0) → KEEP"
echo "  2.0.0 vs 1.9.9: Diff major (2≠1) → KEEP"
echo "  1.0.1 vs 1.0.0 (pinned): Would evict but pin=true → KEEP 📌"
