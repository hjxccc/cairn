<!-- Paste into your AGENTS.md / CLAUDE.md / agent rules file.
     Replace .cairn with your base dir if you installed with --dir. -->

## Work trail & progress (cairn conventions)

- **Throwaway files**: never in the repo root. Debug scripts, SQL, screenshots, data dumps go to `.cairn/tasks/MM-DD-<topic>/scratch/` (gitignored). New task: `cd "$(./.cairn/scripts/mktmp.sh <topic>)"`.
- **Task index**: `.cairn/tasks/INDEX.md`, one line per task. On wrap-up, stack a line on top (one-sentence conclusion + [keywords]). Multi-session tasks: prefix 🚧 and keep `progress.md` (goal/done/next/blocked) in the task dir.
- **Before starting a task**: `grep -i <keyword> .cairn/tasks/INDEX.md` for prior art. "Where are we?" = `grep "^- 🚧\|^- ⏸" .cairn/tasks/INDEX.md`.
- **SOPs**: repeatable procedures live in `.cairn/sop/` (index: `sop/index.md`). Check before doing; follow if found; update on the spot if steps drifted.
- **Wrap-up self-check (two questions)**: ① Will we do this operation again? → create/update an SOP; got bitten? → one line in `.cairn/spec/pitfalls.md` (if a countermeasure changed, edit the original line, don't append a duplicate). ② Will someone ask "why is it like this" in six months? → register `docs/decisions/NNN-<topic>.md` (options incl. rejected ones; supersede, never rewrite old decisions).
- **git layering**: `tasks/`, INDEX, pitfalls are personal trails — not committed by default (gitignored); share a specific file deliberately via `git add -f`. `sop/`, `docs/` are team assets — commit normally.
