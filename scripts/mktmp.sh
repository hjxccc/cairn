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

if [[ -d "$task_dir" ]]; then
  echo "[mktmp] task dir exists, reusing: $task_dir" >&2
else
  mkdir -p "$scratch_dir"
  echo "[mktmp] created: $task_dir/" >&2
  echo "[mktmp]   - scratch/   (gitignored; put debug scripts, dumps, screenshots here)" >&2
  echo "[mktmp]   when you wrap up: stack one line on top of tasks/INDEX.md" >&2
fi

echo "$scratch_dir"
