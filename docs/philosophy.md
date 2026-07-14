# Philosophy: the framework autopsy

cairn wasn't designed — it was *excavated*. We ran a full-featured AI workflow framework (specs, task lifecycles, context-injection hooks, agent pipelines, session journals) on a production multi-repo insurance-tech project for 5 months and 148 tasks, then audited what survived.

## What survived (and why)

| Survivor | Evidence | Why it lived |
|---|---|---|
| Dated task folders `MM-DD-<topic>/` | 148 created, used daily to the last week | one command, zero required fields |
| `scratch/` + root-guard hook | 579MB of debug artifacts safely quarantined | the hook does the discipline, not the human |
| Plain-markdown runbooks | referenced constantly, kept current | reading them saved real time, so updating them felt worth it |

## What died (and why)

| Casualty | Evidence | Cause of death |
|---|---|---|
| Per-task JSONL context injection | 2 of 148 tasks ever used it | required curating a file list per task per agent |
| plan→implement→check→debug pipeline | abandoned after month one | real work was improvised firefighting, not staged delivery |
| `task.json` lifecycle, `.current-task` pointer | 10 of 148; pointer stale for 2+ weeks while still being injected every session | separate state files that nothing naturally updates |
| Session journals | 7 lines in 5 months; the dir became a junk drawer | writing a diary for a tool is a chore with no reader |
| 22KB workflow doc injected every session | described a process nobody followed | injection ≠ adoption |

## The law this implies

> **Anything that requires discipline to feed the machine will die.
> Anything that is a folder plus a habit will survive.**

Corollaries, which became the six principles:

1. The only sustainable persistence layer is files in the repo.
2. The only sustainable creation cost is one command.
3. The only sustainable cleanliness is enforced by a hook, not willpower.
4. The only sustainable retrieval is grep on a one-line-per-item index.
5. The only sustainable context policy is inject-nothing, retrieve-on-demand.
6. The only sustainable state is state that lives *on the thing itself* (a 🚧 marker in the index, a progress.md in the task) and gets touched by the same motion that does the work.

## What the autopsy showed was *missing*

Three gaps that pure survival didn't cover, added deliberately:

- **Decisions** (`docs/decisions/`): 63% of task folders left no readable record; the "why is the system like this" layer needs its own home with supersede semantics, because task archives freeze while decisions stay alive.
- **A feedback loop**: SRE's "every postmortem updates a runbook", implemented as a two-question wrap-up self-check — the cheapest possible ritual (two questions, often two "no"s).
- **In-place revision for pitfalls**: append-only ledgers accumulate contradicting advice; the fix is a rule, not a tool.

## What cairn refuses to be

- **Not a planner.** Spec-driven frameworks orchestrate the future; cairn records the past and marks the present. If you want staged planning, use one *and* cairn.
- **Not a database.** The moment your trail needs a query engine, it stopped being readable in five years.
- **Not automatic.** Automation of memory (auto-inject, auto-summarize) is how context rots. cairn keeps a human-speed ritual — one line, stacked on top, when you wrap up — because the ritual *is* the compression.
