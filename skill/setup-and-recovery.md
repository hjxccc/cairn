# cairn — bootstrap & recovery (SKILL on-demand appendix)

> This page is an on-demand appendix to the cairn skill: **read it only when installing cairn or troubleshooting cairn itself.**
> Normal work — start a task / wrap up / history lookup / distill an SOP — never touches it, so it lives outside the SKILL body that loads on every trigger. (This is cairn's own principle 4: index + detail, load on demand.)

## Bootstrap a new repo ("install cairn")

**Fast path — one command, deterministic. Do NOT hand-create the tree file-by-file (that's slow and error-prone):**

```bash
./install.sh <repo>          # from the cairn checkout; idempotent, never overwrites
```

It scaffolds the whole `.cairn/` structure, copies templates/scripts/hook, and patches `.gitignore` in one shot. See `examples/sample-trail/` for what a filled-in trail looks like across all six content types. Then paste `templates/agent-snippet.md` into the repo's agent rules file. 🔴 CHECKPOINT: merge `hooks/settings-hooks.json` into `.claude/settings.json` **append-only** — read the existing file first; wholesale overwrite kills the project's existing hooks. Verify: writing `_test.py` at root gets blocked; `mktmp.sh demo` creates a dir. Manual mkdir only as a fallback if install.sh is unreachable (table below).

## If it fails (fallbacks)

| Symptom | Fix |
|---|---|
| mktmp.sh missing / not executable | `mkdir -p <base>/tasks/MM-DD-<topic>/scratch` by hand; re-copy the script from the cairn checkout after |
| INDEX.md missing / deleted | rebuild the header from `templates/INDEX.md`, stack this task's line; do not backfill history |
| root-scratch guard not firing | check the PreToolUse entry in `.claude/settings.json` and that the hook file exists; restore whichever is missing |
| dashboard grep matches header text | use the anchored form `grep "^- 🚧\|^- ⏸"`; still noisy = an entry doesn't start with `- `, fix its format |
| same-day same-topic dir already exists | mktmp reuses it — use it, never create a variant dir |
| personal-layer file was committed in the past | `git rm --cached <file>` (keeps the working copy) restores the ignore |
| project's other hooks broke after settings merge | it was overwritten wholesale — restore settings from git, redo an append-only merge |
