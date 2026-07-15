# 003 — What to borrow from the framework we came from, and what to leave

- Status: current
- Date: 2026-07-15
- Source: a full read of the source framework's CLI, cross-checked against cairn's "conventions over machinery" line

## Context

cairn is the distillation of a heavier AI-workflow framework after a 5-month / 148-task autopsy. Rather than assume the rest of that framework was worthless, we read its entire CLI source and asked, per mechanism: does this solve a real problem in a way that does *not* reintroduce machinery that has to be fed?

## Borrow (adapted to conventions or one small script)

- **A stateless, read-only doctor.** The source framework had no `doctor`, but its update path did three-way file comparison and its task tooling validated that referenced files exist. We keep only the *idea* — derive drift from the current files, report but never fix, persist no state — as `scripts/doctor.sh` (stale/dangling markers, duplicate slugs, dead index links). It is deliberately kept out of the session hook so it costs nothing per conversation.
- **Explicit cross-repo scope.** Borrow a human-readable repo map plus a `[repo:x]` tag on cross-repo tasks. Do *not* borrow monorepo auto-detection, per-session `git status` injection, or a single `package` field.
- **Platform-neutral core with thin native pointers.** One authoritative `AGENTS.md`; where a platform can't read it, add a ~10-line native pointer file. Do not copy the workflow per platform or build a configurator registry.

## Leave (machinery that has to be fed)

- Template-hash three-way upgrade engine (`.template-hashes.json`) — cairn has almost no managed templates; markdown is the user's asset.
- Platform configurator dual-registry + template generator.
- Marketplace distributor / overlay maintenance protocol.
- Migration-manifest chains.
- `.current-task` stale-pointer detection — effective, but the disease *is* the expirable pointer; cairn dropped the pointer, so it does not add detection for it.
- `MANAGED:START/END` blocks in AGENTS.md — a cautionary example: the boundary markers promise "the machine refreshes this," but the update command never implemented that, so upstream's own AGENTS.md now points at renamed directories. A short, stable, hand-maintained pointer is more honest.

## Rationale

Every "borrow" above is a convention or a zero-state script; every "leave" is something that needs discipline to keep true. The tell is concrete: the source framework's *own* docs had already drifted (a hash file named two different ways, a backup path written two different ways, an AGENTS.md pointing at directories that were renamed). Machinery rots even for its authors. We take the ideas, not the machines.
