#!/usr/bin/env python3
"""Claude Code PreToolUse hook: blocks throwaway/debug files from landing in
the repo root. cairn convention: they belong in <base>/tasks/MM-DD-<topic>/scratch/.

Auto-detects the base dir (.cairn or .trellis). Generic patterns below are
cross-project; add project-specific ones in the marked section.
"""
from __future__ import annotations

import datetime
import json
import os
import re
import sys
from pathlib import Path

# Windows consoles default to gbk; writing CJK/emoji would UnicodeEncodeError → force utf-8
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")
    except (AttributeError, ValueError):
        pass

# ── generic patterns (cross-project, keep) ──────────────────────────────
HARD_BLOCK_PATTERNS = [
    re.compile(r"^_[^/\\]+\.(py|sql|csv|tsv|json|log|txt|xml|yml|yaml|md|sh)$"),
    re.compile(r"^tmp_[^/\\]+\.(py|sql|csv|tsv|json|log|txt|xml|yml|yaml|md|sh)$"),
    re.compile(r"^(patch|verify|check|fix|find|probe|fetch)_[^/\\]+\.(py|sql|sh)$"),
    re.compile(r"^(trigger|retry|retrigger)[-_][^/\\]+\.(py|sh|json|jsonl)$"),
    re.compile(r"^test[-_][^/\\]+\.(py|png)$"),
    re.compile(r"^scratch[^/\\]*\.(py|sql|md|txt)$"),
]

# ── project-specific patterns (edit per repo) ────────────────────────────
# HARD_BLOCK_PATTERNS += [
#     re.compile(r"^pd_[^/\\]+\.(json|jsonl|py)$"),
# ]

# large data/log files never belong in the repo root
SIZE_LIMIT_BYTES = 1 * 1024 * 1024  # 1 MB
LARGE_FILE_EXT = {".json", ".tsv", ".csv", ".log", ".xml", ".txt"}

BASE_CANDIDATES = (".cairn", ".trellis")


def find_base(project_root: Path) -> str:
    for cand in BASE_CANDIDATES:
        if (project_root / cand / "tasks").is_dir():
            return cand
    return BASE_CANDIDATES[0]


def get_recent_task_dirs(project_root: Path, base: str, limit: int = 3) -> list[str]:
    tasks_dir = project_root / base / "tasks"
    if not tasks_dir.is_dir():
        return []
    candidates = []
    for entry in tasks_dir.iterdir():
        if entry.is_dir() and re.match(r"^\d{2}-\d{2}-", entry.name):
            candidates.append((entry.stat().st_mtime, entry.name))
    candidates.sort(reverse=True)
    return [n for _, n in candidates[:limit]]


def format_block_message(name: str, reason: str, project_root: Path) -> str:
    base = find_base(project_root)
    today = datetime.date.today().strftime("%m-%d")
    recent = get_recent_task_dirs(project_root, base)
    recent_lines = "\n".join(f"    - {base}/tasks/{r}/scratch/" for r in recent) \
        or "    (no tasks yet — create one with mktmp.sh)"
    return (
        f"[block-root-scratch] blocked write: {name}\n"
        f"  reason: {reason}\n"
        f"  correct location: {base}/tasks/{today}-<topic>/scratch/{name}\n"
        f"  new task: ./{base}/scripts/mktmp.sh <topic>\n"
        f"  or append to a recent task (by mtime):\n{recent_lines}"
    )


def main() -> int:
    raw = sys.stdin.read()
    if not raw:
        return 0
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        return 0

    tool = payload.get("tool_name") or payload.get("tool", "")
    if tool not in {"Write", "Edit", "MultiEdit"}:
        return 0

    tool_input = payload.get("tool_input") or payload.get("input") or {}
    target = tool_input.get("file_path") or tool_input.get("notebook_path") or ""
    if not target:
        return 0

    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
    try:
        abs_target = Path(target).resolve()
        abs_root = Path(project_dir).resolve()
    except (OSError, ValueError):
        return 0

    if tool in {"Edit", "MultiEdit"} and abs_target.exists():
        return 0
    try:
        rel = abs_target.relative_to(abs_root)
    except ValueError:
        return 0
    if len(rel.parts) != 1:
        return 0

    name = rel.parts[0]

    for pat in HARD_BLOCK_PATTERNS:
        if pat.match(name):
            sys.stderr.write(format_block_message(
                name, f"repo root forbids {pat.pattern}-style throwaway files", abs_root) + "\n")
            return 2

    ext = Path(name).suffix.lower()
    if ext in LARGE_FILE_EXT:
        content = tool_input.get("content", "")
        if isinstance(content, str) and len(content.encode("utf-8")) > SIZE_LIMIT_BYTES:
            size_mb = len(content.encode("utf-8")) / 1024 / 1024
            sys.stderr.write(format_block_message(
                name, f"repo root forbids data/log files > 1 MB (this one: {size_mb:.1f} MB)",
                abs_root) + "\n")
            return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
