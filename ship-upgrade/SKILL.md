---
name: ship-upgrade
description: Use when asked to upgrade / update the ship skill to the latest version. Triggers: "/ship-upgrade", "upgrade ship", "update ship skill".
---

# ship-upgrade

Upgrade the `ship` skill to the latest published version and show what changed.

## Steps

### 1. Detect install location
```bash
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
[ -d "$DEST/ship" ] || { echo "ERROR: ship not installed in $DEST"; exit 1; }
echo "install: $DEST"
```

### 2. Current vs remote version
```bash
LOCAL=$(cat "$DEST/ship/VERSION" 2>/dev/null || echo "unknown")
REMOTE=$(curl -sL https://raw.githubusercontent.com/loop2zero/ship-skill/main/VERSION || echo "")
echo "local=$LOCAL remote=$REMOTE"
```
If `REMOTE` empty → report network error, stop. If `LOCAL == REMOTE` → already latest, stop.

### 3. Confirm with the user (AskUserQuestion)
"ship **v$REMOTE** is available (you're on v$LOCAL). Upgrade now?" → Yes / Not now.

### 4. Backup + reinstall
```bash
BK="$DEST/.ship-backup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$BK"
cp -r "$DEST/ship" "$DEST/ship-upgrade" "$BK/" 2>/dev/null || true
TMP=$(mktemp -d)
git clone --depth 1 https://github.com/loop2zero/ship-skill.git "$TMP"
bash "$TMP/install.sh"
rm -rf "$TMP"
echo "upgraded to v$REMOTE (backup: $BK)"
```

### 5. Report what's new
Fetch the repo's CHANGELOG/commit log and summarize the diff between `$LOCAL` and
`$REMOTE` for the user. If `install.sh` failed, restore from `$BK` and warn.
