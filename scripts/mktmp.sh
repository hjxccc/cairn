#!/usr/bin/env bash
# mktmp.sh — create a MM-DD-<topic> task dir with its scratch/ subdir.
#
# Usage:
#   ./.cairn/scripts/mktmp.sh <topic>
#   cd "$(./.cairn/scripts/mktmp.sh payment-timeout-debug)"
#
# stdout = absolute path of scratch/ (so $(...) can cd straight into it)
# stderr = human-readable notes
#
# Works under any base dir name (.cairn, .trellis, ...) — it derives the
# base from its own location: <repo>/<base>/scripts/mktmp.sh

set -e

topic="${1:-}"
if [[ -z "$topic" ]]; then
  echo "usage: $0 <topic>            # kebab-case, e.g. payment-timeout-debug" >&2
  exit 1
fi

if [[ ! "$topic" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "error: topic must be kebab-case (lowercase letters, digits, dashes)" >&2
  echo "  got: $topic" >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # <repo>/<base>/scripts
base_dir="$(dirname "$script_dir")"                          # <repo>/<base>
today=$(date +%m-%d)
task_dir="$base_dir/tasks/${today}-${topic}"
scratch_dir="$task_dir/scratch"
index="$base_dir/tasks/INDEX.md"
slug="${today}-${topic}"

# B1 — stack a 🚧 placeholder on INDEX at *start*, so a forgotten wrap-up becomes
# visible debt (doctor flags it) instead of a silent gap. Idempotent; it reuses
# INDEX, never a separate state file. You rewrite the line into a real conclusion
# at wrap-up (or delete it if the task produced nothing worth remembering).
stack_placeholder () {
  [[ -f "$index" ]] || { echo "[mktmp]   (no tasks/INDEX.md — skipped placeholder)" >&2; return 0; }
  if grep -qF -- "$slug" "$index"; then
    echo "[mktmp]   INDEX already lists $slug (kept as-is)" >&2; return 0
  fi
  local ph line hdr
  if grep -q '## 条目' "$index"; then ph="待补结论（收尾时改写这行）"; else ph="TBD (fill in the conclusion at wrap-up)"; fi
  line="- 🚧 ${slug} — ${ph}"
  hdr="$(grep -nE '^## ' "$index" | head -1 | cut -d: -f1)"
  [[ -n "$hdr" ]] || { echo "[mktmp]   (no entries header in INDEX — skipped placeholder)" >&2; return 0; }
  { head -n "$hdr" "$index"; printf '%s\n' "$line"; tail -n +"$((hdr + 1))" "$index"; } > "$index.tmp" \
    && mv "$index.tmp" "$index"
  echo "[mktmp]   stacked 🚧 placeholder on INDEX (rewrite it at wrap-up):" >&2
  echo "[mktmp]     $line" >&2
}

if [[ -d "$task_dir" ]]; then
  echo "[mktmp] task dir exists, reusing: $task_dir" >&2
else
  mkdir -p "$scratch_dir"
  echo "[mktmp] created: $task_dir/" >&2
  echo "[mktmp]   - scratch/   (gitignored; put debug scripts, dumps, screenshots here)" >&2
  stack_placeholder
fi

echo "$scratch_dir"
