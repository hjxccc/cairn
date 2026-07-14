# 001 — Personal layer (tasks/, INDEX, pitfalls) is not committed by default

- Status: current
- Date: 2026-07-14
- Source: the original framework autopsy + design discussion

## Context

Task trails are one developer's footprints. On a shared repo, everyone committing their 100+ task folders pollutes `git status`, bloats history, and creates merge noise on files nobody else reads.

## Options

- A. Personal layer gitignored by default; share a specific file deliberately via `git add -f` (✅ chosen)
- B. Commit everything so trails migrate with `git clone` (❌ rejected: mutual pollution on team repos; the heavy part — scratch — can't be committed anyway, so the migration benefit is only a few summary files)
- C. Per-developer committed workspace dirs (❌ rejected: ceremonial directories empirically rot — the framework we autopsied had one; 7 lines written in 5 months)

## Rationale

Trails are personal, not team assets; team assets (`sop/`, `docs/`, decisions, agent rules) have their own committed layer. Requiring an explicit `-f` makes sharing a conscious act instead of a default side effect.

## Consequences

Personal trails don't migrate via clone — back them up manually or selectively commit. Files already tracked before adopting cairn stay tracked (gitignore doesn't untrack).
