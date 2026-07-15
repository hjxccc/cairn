# 001 — Idempotency keys over distributed locks for refund processing

- Status: current
- Date: 03-15
- Source: `tasks/03-15-refund-double-credit/`

## Context
Concurrent webhook deliveries caused duplicate refund credits. We needed exactly-once *effect* on refund execution.

## Options
- A. Idempotency key per refund intent, unique-constraint enforced at the DB (✅ chosen)
- B. Distributed lock (Redis) around refund execution (❌ rejected: lock TTL vs slow gateway calls is unwinnable — expire early and you double-credit anyway, expire late and you block the queue; also adds a Redis dependency to the money path)
- C. Dedupe on the webhook consumer only (❌ rejected: doesn't cover retries from *our* replay job, which was the actual second writer)

## Rationale
The database is already the source of truth on the money path; a unique constraint is the only guard that holds regardless of who the writer is.

## Consequences
Refund table carries an intent-key column forever; all new writers must supply it (enforced by a NOT NULL + code review checklist line).
