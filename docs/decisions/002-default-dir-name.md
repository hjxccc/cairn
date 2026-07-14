# 002 — Default base dir is `.cairn/`, with auto-detect for `.trellis/`

- Status: current
- Date: 2026-07-14
- Source: open-sourcing discussion

## Context

The conventions were incubated inside a `.trellis/` directory (legacy of the framework we autopsied). Open-sourcing needs a default name.

## Options

- A. `.cairn/` default; scripts and hook auto-detect `.trellis/` for legacy repos; `install.sh --dir` for anything else (✅ chosen)
- B. Keep `.trellis/` (❌ rejected: brands the project with the framework it replaced, confusing for newcomers)
- C. Configurable only, no default (❌ rejected: defaults are the product; forcing a choice at install is friction)

## Rationale

The name is the brand; auto-detection makes migration from incubation repos free (mktmp.sh derives the base from its own location, the hook probes `.cairn` then `.trellis`).

## Consequences

Two names exist in the wild during transition; docs consistently say `<base>` where it matters.
