# 004 — Retrieval is grep over a one-line index, not a vector store

- Status: current
- Date: 2026-07-15
- Source: a design discussion on whether `grep` is a legitimate retrieval mechanism for cairn's history/pitfall/SOP lookup

## Context

cairn's whole recall story is "grep the index, then read the hit" (§5/§6): `grep -i <keyword> tasks/INDEX.md`, `grep sop/index.md`, `grep spec/pitfalls.md`. A fair objection: grep is *lexical* — it matches strings, not meaning. Modern "project/agent memory" tooling usually reaches for embeddings + a vector DB (RAG) so a search for "attachments" also finds an entry that says "file sync." Is grep actually defensible here, or is it just the lazy choice?

The question matters because it's the kind someone will re-litigate in six months ("why don't we just add a vector index?"), so the reasoning — and the escalation ladder — should be written down once.

## What is actually being searched (the number that decides it)

cairn deliberately searches the **one-line index layer, not full text**. On the heaviest real project measured, five months of work is **148 tasks ≈ 148 lines ≈ 15–20 KB** of INDEX.md; pitfalls and the SOP index are tens to low-hundreds of lines. At that size grep is sub-millisecond and the entire index also fits in the model's context. The "grep is slow/noisy" failure mode requires a large *full-text* corpus, which the index+detail split (§0.4) structurally prevents.

## Options

- **A. grep/ripgrep over the one-line index, LLM reads the hit (✅ chosen).** Zero index to build or maintain, deterministic and debuggable, always fresh (greps the current file), and the agent already has ripgrep natively. Its one real weakness — lexical, not semantic — is covered below.
- **B. Full-text search (Postgres FTS / Elasticsearch) (❌ rejected for now).** Adds stemming/ranking but needs an index to maintain and a service to run; unjustified at KB scale, and CJK tokenization is its own headache (already hit in a separate system: "Postgres FTS 无中文分词"). grep's pure-substring match sidesteps CJK segmentation entirely.
- **C. Embeddings + vector DB + rerank (RAG) (❌ rejected for now).** True semantic recall, but it is exactly the "machinery that has to be fed" cairn exists to avoid: an embedding pipeline, re-embedding on every change, a vector store, plus chunking/rerank/context-window tuning that carry their own failure modes (all lived through in a companion RAG system). It also goes stale relative to the files. Massive overkill for a 20 KB index.

## Rationale

At cairn's scale, "retrieve on demand with grep" beats "pre-index everything" because you only pay for the one line you actually want, and there is no index that can rot. The lexical weakness is mitigated by design, not ignored:

1. Every INDEX line carries 2–4 `[keyword]` tags — a hand-built inverted index; you tag with the terms you expect to search later.
2. Conclusions are written with searchable words, not "fixed that bug."
3. Because the index is small enough to fit in context, a grep miss falls back to **reading the whole INDEX and letting the LLM scan it semantically** — so semantic recall comes free from the model, with grep as the fast path.

The strongest precedent: Claude Code itself navigates million-line codebases with ripgrep + LLM reading, *not* an embedding index — the same trade (indexes go stale and cost infrastructure; grep + a capable model is faster and fresher at controllable scale). The 2025–2026 trend for small corpora is back toward "fit it in context / just grep" rather than defaulting to RAG.

## Consequences

- Recall quality depends on discipline that already exists in cairn: good `[keyword]` tags and conclusion-not-log INDEX lines. Garbage-in still means grep-can't-find.
- Users should prefer `rg` over legacy `grep` (faster, respects `.gitignore`), and try a second synonym before concluding "not done before."
- This is explicitly a **scale-bounded** decision. The escalation ladder if the searchable corpus ever outgrows context: `grep/ripgrep → full-text (FTS) → embeddings`. The trigger to climb is concrete — "the one-line indexes no longer fit in the model's context" — which a 148-task project is nowhere near. Revisit then, not before; supersede this decision rather than editing it.
