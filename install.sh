#!/usr/bin/env bash
# cairn installer — scaffolds the directory conventions into a target repo.
#
# Usage:
#   ./install.sh [TARGET_REPO] [--dir NAME]
#
#   TARGET_REPO   path to the repo to install into (default: current directory)
#   --dir NAME    base directory name (default: .cairn; use --dir .trellis
#                 to blend into repos that already use that layout)
#
# Idempotent: re-running never overwrites existing files.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="."
BASE=".cairn"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) BASE="$2"; shift 2 ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) TARGET="$1"; shift ;;
  esac
done

TARGET="$(cd "$TARGET" && pwd)"
B="$TARGET/$BASE"

echo "[cairn] installing into $TARGET (base dir: $BASE)"

# 1. structure
mkdir -p "$B"/{tasks,scripts,sop,spec,docs/decisions} "$TARGET/.claude/hooks"

# 2. templates (never overwrite)
copy_if_absent() { [[ -e "$2" ]] && echo "[cairn]   keep existing $2" || { cp "$1" "$2"; echo "[cairn]   + $2"; }; }
copy_if_absent "$SRC/templates/INDEX.md"      "$B/tasks/INDEX.md"
copy_if_absent "$SRC/templates/sop-index.md"  "$B/sop/index.md"
copy_if_absent "$SRC/templates/pitfalls.md"   "$B/spec/pitfalls.md"
copy_if_absent "$SRC/scripts/mktmp.sh"        "$B/scripts/mktmp.sh"
copy_if_absent "$SRC/hooks/block-root-scratch.py" "$TARGET/.claude/hooks/block-root-scratch.py"
chmod +x "$B/scripts/mktmp.sh" 2>/dev/null || true

# 3. gitignore (idempotent append)
GI="$TARGET/.gitignore"
touch "$GI"
add_ignore() { grep -qxF "$1" "$GI" || { echo "$1" >> "$GI"; echo "[cairn]   .gitignore += $1"; }; }
echo "" >> "$GI"
add_ignore "# cairn personal layer (share a specific file with: git add -f <file>)"
add_ignore "$BASE/tasks/"
add_ignore "$BASE/spec/pitfalls.md"

# 4. next steps
cat <<EOF

[cairn] done. Wire up your agent:

  1) Any agent: append templates/agent-snippet.md to your AGENTS.md / CLAUDE.md
     (edit paths if you used --dir):
       cat "$SRC/templates/agent-snippet.md"

  2) Claude Code (optional but recommended):
       cp -r "$SRC/skill" ~/.claude/skills/cairn
     and merge hooks/settings-hooks.json into $TARGET/.claude/settings.json
     to enable the repo-root scratch guard.

  3) Try it:
       cd "\$($BASE/scripts/mktmp.sh demo-topic)"        # creates a task dir
       # then tell your agent: "wrap up" when done — it stacks a line in INDEX.md

EOF
