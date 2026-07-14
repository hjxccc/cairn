# Sample trail

A fictional (fully anonymized) two-week trail from an e-commerce payments team, showing all six content types working together:

- **[tasks/INDEX.md](tasks/INDEX.md)** — the stone stack: 7 tasks, one 🚧 in flight, one ⏸ waiting on a vendor. `grep 🚧` is the standup.
- **[tasks/03-18.../summary.md](tasks/03-18-payment-timeout-storm/summary.md)** — a wrap-up with the two-question self-check answered at the bottom.
- **[tasks/03-22.../progress.md](tasks/03-22-checkout-ab-migration/progress.md)** — a multi-session task you can resume cold from "Next / Blocked".
- **[sop/pull-prod-data-to-staging.md](sop/pull-prod-data-to-staging.md)** — a runbook an agent can execute verbatim, with a pre-check that was *added after a near-miss* (the feedback loop working).
- **[spec/pitfalls.md](spec/pitfalls.md)** — three one-liners; note the `rev:03-13` in-place revision.
- **[docs/decisions/001](docs/decisions/001-idempotency-keys-over-locks.md)** — why refunds use idempotency keys, with the rejected options spelled out for the next person who proposes Redis locks.

Notice what's *absent*: no `scratch/` contents (gitignored in real repos — debug dumps die with the task) and no ceremony. The whole trail is ~150 lines of markdown.
