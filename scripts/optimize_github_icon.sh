#!/usr/bin/env bash

set -euo pipefail

for dir in */; do
  # Verify .git/ presence
  [ -d "$dir/.git" ] || continue

  # Verify .assets/icon.png presence
  icon="$dir.assets/icon.png"
  [ -f "$icon" ] || continue

  # Verify if it's already optimized
  size=$(stat -f%z "$icon" 2>/dev/null || stat -c%s "$icon")
  [ "$size" -gt 1048576 ] || continue

  # Handle icon compression
  echo "Compressing $icon ($(( size / 1024 ))KB)..."
  pngquant --force --output "$icon" "$icon"

  # Create new commit
  git -C "$dir" add .assets/icon.png
  git -C "$dir" commit -m "Optimize the project icon"
  git -C "$dir" push
  echo "Done: $dir"
done