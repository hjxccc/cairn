# cairn in 10 minutes — a hands-on tutorial

Everything below was actually run; outputs are real.

## 0. Prerequisites

- `git` and `bash` — on Windows, **Git Bash** (ships with Git for Windows) works today; PowerShell-native install is on the roadmap
- `python3` — only needed for the optional root-guard hook
- A coding agent (Claude Code / Cursor / Codex / ...) is recommended but **optional** — the conventions are plain files

## 1. Install (30 seconds)

```bash
git clone https://github.com/hjxccc/cairn
cd your-project
/path/to/cairn/install.sh .
```

Verify it worked — three checks:

```bash
ls .cairn/                                   # → tasks/ scripts/ sop/ spec/ docs/
./.cairn/scripts/mktmp.sh demo && ls .cairn/tasks/   # → 07-14-demo/ created
tail -3 .gitignore                           # → .cairn/tasks/ + .cairn/spec/pitfalls.md ignored
```

Re-running `install.sh` is safe — it never overwrites existing files.

## 2. Wire up your agent (pick your tool)

| Your tool | Do this |
|---|---|
| **Claude Code** | `cp -r /path/to/cairn/skill ~/.claude/skills/cairn` — the agent now handles "start a task / wrap up / have we hit this before" automatically. Optional: merge `hooks/settings-hooks.json` into your project's `.claude/settings.json` (append, don't overwrite) to enable the root-scratch guard. |
| **Cursor / Codex / Windsurf / anything** | Paste `templates/agent-snippet.md` into your `AGENTS.md` / `.cursorrules` / rules file. No hooks needed — the conventions are markdown instructions. |
| **No agent** | Just use the commands below yourself. The files are the product. |

## 3. Day one: your first task

Something breaks. Start a task:

```bash
$ cd "$(./.cairn/scripts/mktmp.sh payment-timeout-debug)"
[mktmp] created: .cairn/tasks/07-14-payment-timeout-debug/
[mktmp]   - scratch/   (gitignored; put debug scripts, dumps, screenshots here)
```

Debug for two hours. Every throwaway artifact — probe scripts, data dumps, screenshots — goes into `scratch/`. It's gitignored; it dies with the task, and that's the point.

Found it? Fixed it? **Wrap up** (tell your agent "wrap up", or do it by hand): stack ONE line on top of `.cairn/tasks/INDEX.md`:

```markdown
- 07-14-payment-timeout-debug — our own retry storm; capped retries + jitter [payment][timeout]
```

Rules for that line: ≤120 chars, a *conclusion* (what you found/fixed — not the topic restated), 2–4 `[keywords]`, newest on top. That line is the whole ritual. Two minutes, max.

## 4. Week two: the payoff

**"Have we dealt with this before?"**

```bash
$ grep -i timeout .cairn/tasks/INDEX.md
- 07-14-payment-timeout-debug — our own retry storm; capped retries + jitter [payment][timeout]
```

One line tells you it's solved, what the cause was, and where to read more. Skip the re-debugging.

**"Where are we?"** — mark long-running tasks with `- 🚧 ` (in progress) or `- ⏸ ` (waiting on something external):

```bash
$ grep "^- 🚧\|^- ⏸" .cairn/tasks/INDEX.md
- 🚧 07-13-checkout-migration — v2 at 25%, error budget healthy [checkout][migration]
- ⏸ 07-11-invoice-fonts — fix ready, waiting on vendor license [invoice][pdf]
```

That's your standup. Multi-session tasks also keep a `progress.md` inside the task dir (goal / done / next / blocked) — resume cold from "next".

## 5. Graduation: when knowledge outgrows a task

At wrap-up, ask two questions:

1. **"Will we do this again?"** Second time doing the same operation → distill it into `sop/<verb-topic>.md` (when-to-use / pre-checks / numbered steps with expected output / verify / rollback) and add a line to `sop/index.md`. Next time: follow the SOP, don't re-explore. Got bitten? → one line in `spec/pitfalls.md`.
2. **"Will someone ask *why* in six months?"** → register `docs/decisions/NNN-<topic>.md` with the rejected options spelled out. Overturned later? Write a new one and mark the old `superseded by NNN` — never rewrite history.

See a complete worked example (7 tasks, an SOP born from a near-miss, a real decision) in [examples/sample-trail](../examples/sample-trail).

## 6. Working in a team

Personal layer (`tasks/`, INDEX, `pitfalls.md`) is gitignored — your trail is yours; share a specific file deliberately with `git add -f`. Team layer (`sop/`, `docs/`, `spec/<topic>.md`) is committed and travels with `git clone`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `mktmp.sh: command not found` | run it with the path: `./.cairn/scripts/mktmp.sh`, or `chmod +x` it |
| hook doesn't block root scratch files | check the PreToolUse entry exists in `.claude/settings.json` and `python3` is on PATH |
| dashboard grep shows header text | use the anchored form: `grep "^- 🚧\|^- ⏸"` |
| installed into the wrong repo | there's nothing to uninstall — delete `.cairn/` and the 3 `.gitignore` lines |
