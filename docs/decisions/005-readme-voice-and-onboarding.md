# 005 — README voice: plain, pain-first, AI-era install, no competitor put-downs

- Status: current
- Date: 2026-07-15
- Source: a README revision pass (with a codex gpt-5.6-sol honesty critique) turning the landing page from insider framing into cold-readable positioning

## Context

The README opened with insider framing ("the 20% of AI-coding-workflow frameworks that survives contact with real work") and, mid-edit, grew a head-to-head comparison table against heavyweight auto-injection frameworks. A first-time visitor couldn't tell what cairn is, what it fixes, or how to install it without reading the whole autopsy story first. Several decisions were made together about the landing page's voice.

## Options / what we decided

1. **Lead with plain-language pains, not a comparison table.** Three everyday pains (new-chat amnesia / lost mid-task / same landmine twice) in ordinary wording, each with cairn's repo-native answer, plus one diagram (`assets/why-cairn*.svg`). *Rejected:* a "three routes" comparison table up front — it centers competitors, ages badly, and reads as insecure.
2. **Contrast the approach, never name a competitor to put it down.** Say "auto-injection framework" generically; keep the honest autopsy lineage (cairn is distilled from months of using such a framework). *Rejected:* a named put-down slogan ("X gives AI scaffolding; cairn gives the repo cairns") — ungracious toward the thing cairn learned from, its claims go stale as that project evolves, and it risks targeting the wrong same-named project.
3. **Hero line is a plain claim, not a conclusion.** "An AI agent's memory shouldn't live in the chat — it should live in the repo." The "20% that survives" framing still lives in the autopsy section, where the reader has just seen the dead 80% and it lands.
4. **AI-era install.** Quick start leads with one sentence + repo URL to a skill-aware agent ("install cairn and set it up in this project: <url>"); the manual `git clone` + `install.sh` path is folded into a `<details>` fallback. Quick start sits above the pain section (install-first). *Rejected:* leading with `git clone` and a `/path/to/cairn` placeholder — that's a pre-AI ritual and the placeholder makes people guess.
5. **Honesty pass on absolute claims** (codex-flagged): `~22KB` session injection is one project's measurement, not an inherent class cost; drop "zero-maintenance" / "zero-machinery" / "grep gets it all back" for measured wording; `doctor.sh` checks four drift classes, not two.

## Rationale

Cold readers decide in the first screen; they need what / why / how-to-install in plain words, not a conclusion that only makes sense after the story. Honesty and grace age better than punchy overclaims — every absolute that a skeptic can refute costs more credibility than the phrase buys. And in 2026 onboarding a skill is a sentence to an agent, not a shell ritual, so the README should show that first.

## Consequences

- The landing voice is pain-first and plain; the memorable through-line ("memory belongs in the repo, not the chat") appears in both the hero and the pain section.
- Any competitor comparison lives only in the neutral "how is this different from…" section, stated factually — not in the hero or the pitch.
- Claims must stay measurable and scoped ("one project measured ~22KB"), and README ↔ SKILL ↔ decisions must agree on what the tooling actually does (the doctor drift-class count was out of sync and got fixed here).
