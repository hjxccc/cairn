# Task index (cairn)

> One line per task, **newest on top**. Stack a line when you wrap up.
> Long-running tasks get a leading 🚧 (in progress) or ⏸ (paused, waiting on something external).
> In-flight work: `grep "🚧\|⏸" INDEX.md` · History: `grep -i <keyword> INDEX.md`

## Entries

- 🚧 03-22-checkout-ab-migration — legacy checkout → v2 rollout at 25%; error budget healthy, next batch Friday [checkout][migration][rollout]
- ⏸ 03-21-invoice-pdf-cjk-fonts — CJK glyphs tofu in invoice PDFs = font subset missing; fix ready, waiting on vendor font license [invoice][pdf][fonts]
- 03-20-orders-api-n-plus-one — order list p99 4.2s → 180ms; N+1 on shipment lookups, fixed with batch preload [orders][performance][n+1]
- 03-18-payment-timeout-storm — gateway timeouts every ~45min = retry storm from our own idempotent replays; capped retries + jitter, wrote SOP [payment][timeout][retry-storm]
- 03-15-refund-double-credit — duplicate refunds under concurrent webhooks; idempotency keys chosen over distributed locks → decision 001 [refund][webhook][idempotency]
- 03-12-staging-data-refresh — pulled anonymized prod slice to staging for refund repro; procedure distilled into SOP [staging][data]
- 03-11-cart-price-drift — stale price cache on currency change; fixed TTL + event invalidation, pitfall logged [cart][cache][currency]
