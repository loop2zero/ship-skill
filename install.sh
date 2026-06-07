#!/usr/bin/env bash
# Install the `ship` skill into Claude Code's skills directory.
set -euo pipefail
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
SRC="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DEST"
for s in ship ship-upgrade; do
  rm -rf "${DEST:?}/$s"
  cp -r "$SRC/$s" "$DEST/$s"
  echo "installed: $DEST/$s"
done
cp "$SRC/VERSION" "$DEST/ship/VERSION"
echo "ship-skill $(cat "$SRC/VERSION") installed. Use /ship in Claude Code."
