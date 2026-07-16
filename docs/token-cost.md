# Token cost — cairn vs a heavy workflow framework

cairn's core bet is **pay at retrieval, not on every session.** This page puts real, measurable numbers on it — and shows you how to measure your own with `cairn-cost.sh`.

> The "heavy workflow framework" column is a *cost model*, described by behavior — the same category the [autopsy](philosophy.md) is about. No tool is named as a strawman; the point is per-session vs per-retrieval, not a leaderboard.

## The short version

| | cairn | Heavy workflow framework |
|---|---|---|
| **Always-on, every session** | **~350 tok** — a ~5-line preamble + your live 🚧/⏸ panel | **~5,000–7,000 tok** — a static spec injected every session |
| **When you actually do the work** | SKILL loads once (~3.5–4.5k tok) + a grep + one file read | already paid, whether you use it or not |
| **Grows over time with** | number of in-flight tasks (bounded — wrap up to reset) | the framework's injected surface |
| **You can measure it** | `cairn-cost.sh` (one command, zero-dep) | — |

The heavy-framework figure is from a real audit: one project injected **~22 KB of workflow docs every session** (~5–7k tokens) describing a process nobody followed. Details in [the autopsy](philosophy.md).

## The breakdown (measured)

### Always-on tax — paid every session, whether or not you touch cairn
- **Fixed preamble**: ~100–130 tok (a constant — the 5-line cairn note).
- **Your in-flight 🚧/⏸ panel**: ~180–220 tok for a handful of tasks. This is *signal* — your live work, the thing you want surfaced — not overhead. It's also the **only** part that grows over time.
- **≈ ~350 tok total**, most of which is your actual task state.

### On-demand — paid only when you do cairn work
- **SKILL load on trigger**: ~3.5–4.5k tok, **once per session that uses cairn** — not every session. The rarely-needed install/troubleshooting content was split into an on-demand appendix, so common operations (start / wrap up / history / SOP) load ~800–900 tok less.
- **A history grep**: a handful of INDEX lines, ~100–300 tok.
- **Reading one task summary / progress**: ~500–1,500 tok, and only the one file you matched — never the whole archive.

### Compared to the heavy framework
That framework's ~22 KB (~5–7k tok) is paid **every session**, up front, whether the work is a one-line fix or a week-long migration — and the autopsy found most of it described a process nobody followed. cairn's always-on cost is roughly **1/15–1/20** of that, and its payload is your live tasks (signal), not a static document (noise).

## Why cairn stays cheap (by design)
- **Retrieve on demand, inject nothing** (principle 5): the default per-session surface is tiny; history is read only when a task actually needs it.
- **Index + detail** (principle 4): retrieval is a grep on a small index, then read *one* file — not a bulk load.
- **Conventions over machinery** (principle 6): no runtime, no vector store to keep warm, no state files to sync — so there's nothing that quietly grows a per-session tax.

## Measure your own
```bash
./.cairn/scripts/cairn-cost.sh            # always-on footprint + on-demand sizes, with a panel-growth warning
./.cairn/scripts/cairn-cost.sh --tiktoken # exact counts if you have python + tiktoken
```
It reports the always-on tax (fixed preamble + in-flight panel), the on-demand sizes (INDEX, SKILL), and warns when the in-flight panel grows past a budget (default 1,500 tok) — a nudge to wrap a few tasks up, which resets it.

## Method & honesty
- Token counts are **estimates** unless you pass `--tiktoken`: Chinese ~0.6 tok/char, latin/symbols ~0.28 tok/char, tuned to modern o200k / Claude tokenizers. Exact counts need a real tokenizer.
- The **22 KB / 5–7k** figure is *one measured project*, not a universal constant — some heavy frameworks inject less, some more. The takeaway is the **cost model** (pay-per-session vs pay-at-retrieval), not a benchmark score.
- Every number here comes from artifacts you can measure in this repo. No synthetic benchmarks.
