# 006 — Mitigate cairn's two weaknesses only with conventions and visibility, never with machinery

- Status: current
- Date: 2026-07-16
- Source: README "cairn's cost (honest)" rows + a senior-architect design pass (Codex, gpt-5.6-sol)

## Context

cairn's README states two honest weaknesses:

- **A · Retrieval is lexical, not semantic.** grep matches literal keywords; a reworded search can miss a real prior task.
- **B · It runs on convention, not runtime enforcement.** The wrap-up INDEX line / pitfall / progress must *actually get written*, and the skill must *actually load*, or the memory has gaps.

The obvious "fixes" (a vector DB for A, a forced state machine for B) are exactly the class of machinery the [autopsy](../philosophy.md) killed — components that need feeding rot. So the question isn't "how do we eliminate A and B", it's "how far can we shrink them without re-growing the machine that dies". This decision fixes that boundary so nobody re-litigates it every quarter.

Framing that drove every call: cairn has **two layers** — a *truth layer* (markdown, the only source of truth, always readable by a human and by grep) and an *assist layer* (hooks / skill / scripts that only lower friction and surface drift). **Deleting anything in the assist layer must never lose knowledge.** Machines may produce hints and derived views; they may not own the truth.

## Options

Phase-1 mitigations (✅ chosen — all convention/visibility, zero feeding):

- **B1 · Start-time placeholder** (✅, highest leverage). `mktmp.sh` idempotently stacks `- 🚧 <slug> — 待补结论/TBD` on top of INDEX at task start; wrap-up *rewrites* that line. Turns a forgotten wrap-up from a silent gap into visible debt that `doctor.sh` already flags. Reuses INDEX — **no second source of truth**.
- **A1 · Query-time term expansion** (✅). The skill tells the agent to generate 4–6 query variants (symptom / business noun / technical identifier / EN↔CN) and OR-grep them. No stored synonym list, no state.
- **A2 · Searchable INDEX lines** (✅). Convention: the one-liner carries the user's phrasing *and* the technical anchor, with synonyms/aliases in `[keywords]`. Compounds over time; costs ~15s of thought at wrap-up.
- **B4 · `doctor.sh --strict` + placeholder annotation** (✅). Stale placeholders are marked "⚠占位从未改写"; `--strict` also lists not-yet-stale placeholders. Checks only *provable* omissions — never guesses whether a pitfall "should" have been recorded.
- **B2 · Minimal handshake in AGENTS.md** (✅, already in place). A ≤10-line cairn protocol lives in AGENTS.md so the conventions still work when the skill fails to load; per-platform files carry only a pointer, never a duplicated copy.

Deferred (✅ as opt-in, add only on real pain): **B3** atomic wrap-up skill action; **A3** a bounded `search.sh` that layers grep → filename → body, escalating to a *rebuildable, gitignored, non-authoritative* SQLite FTS index only at large scale (per [004](004-grep-over-vector-search.md)).

Tempting fixes (❌ rejected — each re-grows the machine that dies):

- ❌ **Vector DB / embeddings / RAG in the core.** Adds a model + chunking + an index to keep in sync; when sync lags it returns a *confidently wrong* answer, which is more dangerous than grep missing. Violates conventions-over-machinery, zero-runtime, portability, retrieve-on-demand.
- ❌ **SQLite FTS as a mandatory, incrementally-maintained DB.** The danger is "who keeps it in sync". Only admissible as a *rebuild-on-demand, deletable, gitignored, never-authoritative* derived index that silently falls back to grep.
- ❌ **A hand-maintained synonym table / tag registry / ontology.** Stale in three months. A1 + A2 cover the need at query time.
- ❌ **`task.json` / `.current-task` / lifecycle state machine / JSONL journal.** Creates a second source of truth (autopsy: 10/148 and 2/148 adoption, pointers stale for weeks). B1 must reuse INDEX, not mint a new pointer.
- ❌ **Resident daemon / file-watcher / background indexer.** Stop the service and the capability vanishes; it's a machine to feed.
- ❌ **Auto-inject the whole INDEX / SOPs / pitfalls every session.** Re-runs the 22KB-per-session death path — context bloat + stale knowledge crowding out the task. Violates retrieve-on-demand.
- ❌ **An LLM that auto-writes memory on every commit / session end.** Produces low-value duplicate prose and turns a normal exit into a model-and-permission-dependent write transaction.
- ❌ **A hard Stop hook that guesses "did you forget a pitfall?".** "Was something worth recording" is a semantic judgment a machine can't make reliably; high false-positive rate trains users to disable the hook.
- ❌ **A full mandatory postmortem / checklist form.** The more complete the form, the lower the long-run completion rate.

## Rationale

A is a lexical-retrieval limit; it shrinks a lot by *widening the words* (A1) and *writing searchable lines* (A2) — both free, both query-/write-time, no persistent state. B cannot be fully eliminated inside the creed: no machine can reliably prove "this should have been written but wasn't", because the value judgment is semantic. So the honest move is to make forgetting **cheap to see** (B1 placeholder + B4 visibility) and **cheap to do right** (B2 handshake so the skill's absence doesn't break the floor), then stop. Every rejected option buys a marginal guarantee by taking on a maintenance object that the autopsy shows will be abandoned — trading a visible, self-healing gap for an invisible, rotting one.

## Consequences

- **The core only ever gains "better conventions and earlier visibility."** Machines may emit prompts and derived views; they may not hold the truth.
- **B1 adds INDEX lines for throwaway tasks too** (chosen over gating on "long task"): a little noise, resolved by wrap-up rewrite or `doctor.sh`. Accepted because a *missed* record costs more than a *visible* placeholder.
- **B is mitigated, not solved** — "should this have been recorded" stays a human call, by design. Anyone proposing a Stop-hook/LLM-writer to "finally enforce it" should re-read the ❌ list here first.
- A future scaling need points at A3's rebuildable FTS index, not at a core vector store — see [004](004-grep-over-vector-search.md).
