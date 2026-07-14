# Grounding: why this structure is not vibes

## Academic: the CoALA memory taxonomy

[CoALA](https://arxiv.org/abs/2309.02427) (Cognitive Architectures for Language Agents) is the standard cognitive taxonomy for LLM agents — Letta, Mem0, and LangChain all build on it. cairn's six types map onto it 1:1:

| CoALA memory | cairn |
|---|---|
| Working memory (session context) | principle 5: retrieve on demand, inject nothing |
| Episodic (records of events) | `tasks/` + INDEX — the INDEX line is the reflection/compression layer from Generative Agents (raw stream → summary) |
| Semantic (facts & constraints) | `spec/pitfalls.md`, decisions, agent rules |
| Procedural (how to do things) | `sop/` + agent skills — same lineage as Voyager's skill library and MetaGPT's SOP-driven agents |

Other alignments:

- **The upgrade chain is consolidation.** *task → SOP → skill* and *pitfall → rule* is exactly what the literature calls consolidating episodic memory into procedural/semantic memory — the "curator" pattern, which shows ~+10% on agent benchmarks without fine-tuning.
- **Rules vs SOPs mirrors memory vs skills** in LangChain's Deep Agents: always-loaded preferences vs on-demand procedures.
- **All five memory operations** (store / retrieve / **update** / compress / forget) are covered: update = SOPs edited on drift + pitfalls revised in place; compress = the INDEX line; forget = not retrieving (deliberate forgetting is a feature, and here it costs nothing).
- **grep is the right retrieval at this scale.** Hybrid vector+BM25+entity retrieval exists for millions of memory entries. A repo's trail is hundreds of lines. Keyword grep on an index file wins on precision, auditability, and zero infrastructure.

## Engineering: what large orgs already trust

| Standard practice | cairn equivalent |
|---|---|
| SRE runbooks (alert → triage commands → decision tree → escalation → follow-ups) | `sop/` template: when-to-use / pre-checks / steps with expected output / verify / rollback |
| Blameless postmortems | task summaries / issue archives |
| "Every postmortem updates at least one runbook" | the wrap-up two-question self-check |
| [ADRs](https://martinfowler.com/bliki/ArchitectureDecisionRecord.html) with supersede chains | `docs/decisions/NNN`, never rewrite — supersede |
| Diátaxis (how-to / reference / explanation) | sop / rules+pitfalls / docs |
| PARA | Projects=tasks, Resources=sop+spec, Archives=the date prefix itself |

## Why decisions can't just live in task folders

1. **Different lookup path.** Tasks are organized by event+date ("did we ever do X?"). Decision queries come from the *present state of the system* ("why is it like this?") — six months later nobody remembers which dated folder to open.
2. **Different lifecycle.** Tasks freeze; decisions stay alive and get overturned. Two task write-ups can each say "we decided…" with no arbiter. The supersede chain guarantees exactly one current answer.
3. **git layering.** Task trails are personal and uncommitted; decisions are the single most share-worthy artifact.

Hence: decisions are *born* in tasks, *registered* in `docs/decisions/` — the same move as "procedures are born in tasks, distilled into SOPs the second time."

## Where cairn deliberately deviates from standard practice

- **Personal layer not in git** — docs-as-code argues for committing docs, but that argument is about team assets; cairn still commits those. Personal trails on a shared repo are noise.
- **No task numbering or state machine** — tasks are a stream, dates sort them; the thing that needs numbering and lifecycle is decisions, and it has both.
- **No vector search, no auto-injection** — wrong scale, and injection empirically rots.
