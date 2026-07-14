# SOP — pull-prod-data-to-staging

## When to use
A bug only reproduces with realistic data shapes (concurrency, encodings, edge-case amounts).

## Pre-checks
1. `./scripts/staging-health.sh` returns OK
2. You have `analyst` role on the prod replica (read-only) — **never the primary**
3. Anonymizer version ≥ 2.3 (`anonymize --version`) — older versions leak email domains

## Steps
1. `export-slice --tables orders,payments,refunds --days 7 --out /tmp/slice.sql.gz`
   expect: ~200–400MB, exit 0
2. `anonymize --profile pii-strict /tmp/slice.sql.gz`
   expect: report lists 0 remaining PII columns
3. `staging-load /tmp/slice.anon.sql.gz --wipe-first`
   expect: row counts printed match the export report ±0

## Verify
`spot-check.sh --sample 20` — names/emails are synthetic, amounts and timestamps preserved.

## On failure / rollback
- Step 3 partial load → rerun with `--wipe-first` (idempotent)
- Anonymizer reports residual PII → **stop**, do not load; file to security channel

---
Source: `tasks/03-12-staging-data-refresh/` · Updates: 03-18 added anonymizer version pre-check (rev after near-miss)
