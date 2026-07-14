---
name: cairn
description: cairn — markdown-native work-trail, progress, SOP, decision, and pitfall conventions inside the repo. Zero framework, pure markdown + git. Trigger scenarios: ① start a task / need a scratch dir ("start a task", "mktmp", "where do temp files go"); ② log or query progress ("log progress", "that's it for today", "where are we", "what's in flight"); ③ wrap up a task ("wrap up", "archive this task", "we're done here"); ④ history lookup ("have we dealt with this before", "which task handled X"); ⑤ distill an SOP ("write an SOP", "capture this procedure"); ⑥ log a pitfall ("note this gotcha"); ⑦ bootstrap a new repo ("install cairn", "set up work-trail conventions"); ⑧ "where should I record this" (routing table); ⑨ register a decision ("log a decision", "why did we pick A"). Base dir auto-detect: .cairn or .trellis.
---

# cairn — repo-native project knowledge & progress conventions

> A cairn is a stack of stones on a trail: it doesn't tell you how to walk,
> it tells whoever comes next — someone was here, this path works.

**Base dir**: check for `.cairn/` first, then `.trellis/`; all paths below use `<base>`.

## 0. Six principles (why this shape)

Distilled from a 5-month / 148-task autopsy of a heavyweight AI workflow framework: every component that needed discipline to feed (JSONL injection, agent pipelines, lifecycle state files, session journals) rotted; the dated-folder conventions survived.

1. **The trail lives in the repo, in two layers.** All markdown. Personal layer (`tasks/`, INDEX, pitfalls) is *not* committed by default — everyone's trail differs; share a file deliberately with `git add -f`. Team layer (`sop/`, `docs/`, agent rules) is committed normally.
2. **A task is a dated folder** (`MM-DD-<topic>`), created by one command, no state machine.
3. **Separate dirt from record**: throwaway artifacts go to gitignored `scratch/`; a hook keeps the repo root clean.
4. **Index + detail, always**: one line in an index, details in their own file; retrieve via grep-then-read.
5. **Retrieve on demand, inject nothing** by default. Forgetting = not retrieving; it's free.
6. **Conventions over machinery; state lives on the task** (INDEX markers + the task's own `progress.md`, never a separate pointer file). Any maintenance action >2 minutes is a design bug.

## 1. Six content types

| Type | Answers | Location | Index | Updated |
|---|---|---|---|---|
| Task trail | what/conclusion | `tasks/MM-DD-<topic>/` | `tasks/INDEX.md` | wrap-up |
| Progress | where are we | task's `progress.md` + 🚧 in INDEX | INDEX markers | session end |
| SOP | how to do X | `sop/<verb-topic>.md` | `sop/index.md` | 2nd time doing X |
| Decision | why is it like this | `docs/decisions/NNN-<topic>.md` | numbered filenames | wrap-up check |
| Pitfall / spec | what bites / detailed conventions | `spec/pitfalls.md` + `spec/<topic>.md` | itself / pointer in AGENTS.md | when bitten / when conventions form |
| Docs | designs, write-ups | `docs/` | optional | on completion |

## 2. Task lifecycle (start → work → log → wrap up)

**Locate the project first (multi-project rule)**: walk up from the cwd to the **nearest** `.cairn/` or `.trellis/` — the task belongs to that project (same scoping as `.git`; one instance per project, no cross-pollution). Parent repo + sub-repos: cross-repo tasks go to the parent; single-repo tasks go to that sub-repo if it has cairn installed, else fall up to the parent. Nothing found → offer to bootstrap. 🔴 CHECKPOINT: when one session touches multiple projects, state the target project before ANY write — a stone stacked in the wrong project is worse than none.

**Start**: `cd "$(./<base>/scripts/mktmp.sh <topic>)"` — whichever project's mktmp you call is where the task lands. If the topic feels familiar, do §5 history lookup first.

**Work**: all throwaway artifacts into `scratch/` (the root-guard hook enforces this).

**Log progress** (user says "log progress" / natural session end on long tasks): create/update `progress.md` (goal / done / next / blocked, all dated; incremental, never delete). Ensure the task's INDEX line starts with 🚧 (in progress) or ⏸ (waiting on external).

**Wrap up** (user says "wrap up" / "we're done"; total ≤2 min):
1. Stack one line on **top** of `tasks/INDEX.md` (or rewrite the existing 🚧 line and drop the marker): `- MM-DD-<topic> — one-sentence conclusion [kw1][kw2]` (≤120 chars, conclusion not topic-restatement).
2. If reusable: write a summary md at the task's top level (personal layer; `git add -f` if team-worthy).
3. **Two-question self-check** (the feedback hook): ① *Will we do this again?* → create/update an SOP; bitten → one pitfall line. ② *Will someone ask "why" in six months?* → register a decision.

## 3. Progress ("where are we?")

- All in-flight work: `grep "^- 🚧\|^- ⏸" <base>/tasks/INDEX.md` (anchored, so header text doesn't match) — that's the dashboard, zero upkeep.
- Resume a task: read its `progress.md` "Next"/"Blocked".
- Stale 🚧 markers surface in one grep; fix on sight. Never create a separate current-task pointer file.

## 4. SOPs and decisions (the upgrade chain)

**SOP** = repeatable step sequence (agents are reliable when SOP-driven). Template: when-to-use / pre-checks / numbered steps with expected output / verify / rollback. Distill on the **second** time you do a thing; update on the spot when steps drift. Before doing anything, check `sop/index.md` — follow, don't re-explore.

**Decision** = why the system is the way it is. Born in a task, registered in `docs/decisions/NNN-<topic>.md` (status/date/source/context/options-with-rejections/rationale/consequences, one page). Narrow bar: choices affecting multiple future tasks, rejected options that will be re-proposed, cross-repo agreements. **Never edit a superseded decision** — write a new one and mark the old `superseded by NNN`.

**Chain**: scratch notes → task summary → SOP (project) → agent skill (cross-project); pitfall line → repeated? → agent rule or SOP pre-check.

## 5. History lookup ("have we dealt with this?")

1. `grep -i <keyword> <base>/tasks/INDEX.md`
2. Also check `sop/index.md`, `spec/pitfalls.md`, `docs/decisions/` (it may have graduated).
3. Hit → read that task's summary/progress (never dig through `scratch/`).
4. Not in INDEX ≠ never done (no backfill): fall back to `ls <base>/tasks/ | grep <kw>`.

## 6. Routing table ("where does this go?")

| Content | Destination | git |
|---|---|---|
| throwaway debug artifacts | `tasks/<slug>/scratch/` | ❌ disposable |
| this task's conclusion | summary md + INDEX line | ❌ personal; `git add -f` to share |
| progress/next steps | `progress.md` + 🚧 | ❌ personal |
| repeatable procedure | `sop/` + index line | ✅ team |
| a pitfall | `spec/pitfalls.md` line | ❌ personal; graduate to share |
| detailed conventions (coding standards, domain rules, API contracts) | `spec/<topic>.md` + one pointer line in AGENTS.md | ✅ team |
| rationale for a major choice | `docs/decisions/NNN` | ✅ team |
| always-on rules | CLAUDE.md / AGENTS.md (keep <200 lines) | ✅ |
| designs/write-ups | `docs/` | ✅ |

## 7. Bootstrap a new repo ("install cairn")

Run `install.sh <repo>` from the cairn checkout (creates structure, copies templates/scripts/hook, patches .gitignore), then paste `templates/agent-snippet.md` into the repo's agent rules file. 🔴 CHECKPOINT: merge `hooks/settings-hooks.json` into `.claude/settings.json` **append-only** — read the existing file first; wholesale overwrite kills the project's existing hooks. Verify: writing `_test.py` at root gets blocked; `mktmp.sh demo` creates a dir.

## 8. If it fails (fallbacks)

| Symptom | Fix |
|---|---|
| mktmp.sh missing / not executable | `mkdir -p <base>/tasks/MM-DD-<topic>/scratch` by hand; re-copy the script from the cairn checkout after |
| INDEX.md missing / deleted | rebuild the header from `templates/INDEX.md`, stack this task's line; do not backfill history |
| root-scratch guard not firing | check the PreToolUse entry in `.claude/settings.json` and that the hook file exists; restore whichever is missing |
| dashboard grep matches header text | use the anchored form `grep "^- 🚧\|^- ⏸"`; still noisy = an entry doesn't start with `- `, fix its format |
| same-day same-topic dir already exists | mktmp reuses it — use it, never create a variant dir |
| personal-layer file was committed in the past | `git rm --cached <file>` (keeps the working copy) restores the ignore |
| project's other hooks broke after settings merge | it was overwritten wholesale — restore settings from git, redo an append-only merge |

## 9. Hard rules

- Zero throwaway files at repo root; `scratch/` and >1MB data files never in git.
- Personal layer not committed by default; sharing must be explicit `git add -f`, never bulk.
- INDEX lines: ≤120 chars, conclusions not logs, 2–4 `[keywords]`, newest on top.
- No backfilling old empty task dirs; no half-finished migrations.
- No standalone state pointer files, ever.
- Stale = fix on sight (SOP steps, 🚧 markers). Pitfall countermeasure changed → edit the original line in place (`rev:MM-DD`), don't append a duplicate.
- The only mandatory wrap-up action is the INDEX line; everything else is judgment.
