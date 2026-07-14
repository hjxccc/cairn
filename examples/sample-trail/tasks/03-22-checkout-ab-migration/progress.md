# Progress — checkout v1 → v2 migration

## Goal
100% of traffic on checkout v2 with error rate ≤ v1 baseline; v1 code deleted.

## Done
- 03-22 rollout to 25%, error budget healthy (0.02% vs 0.05% budget)
- 03-21 shadow-traffic comparison: v2 totals match v1 on 50k orders (1 known rounding diff, accepted)
- 03-19 feature flag + kill switch wired, verified flip in staging

## Next
- [ ] 03-26 raise to 50% after Friday traffic peak
- [ ] delete v1 promo-code path once 50% soak passes (⚠️ irreversible, needs decision entry if we keep dual-write)

## Blocked / waiting
- 03-22 waiting on data team to confirm the funnel dashboard reads the v2 event names
