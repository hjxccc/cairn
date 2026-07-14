# Summary — payment timeout storm (03-18)

## Symptom
Payment gateway timeouts spiking every ~45 minutes, self-resolving after 2–3 min. No deploy correlation.

## Root cause
Our idempotent replay job retried *all* pending payments on a fixed cron with no jitter and no retry cap. Each spike was our own replay wave hammering the gateway, which throttled us, which created more pending payments — a self-inflicted retry storm.

## Fix
- Retry cap (5 attempts, exponential backoff) + per-job jitter (0–120s)
- Alert on pending-payment queue depth instead of gateway error rate (leading indicator)

## Evidence
- `scratch/gateway-429s.png` — throttle responses lining up with cron schedule (scratch is local-only; not in this example)
- Queue depth graph flat since fix; zero storms in 72h

## Follow-ups (wrap-up self-check)
- Will we do this again? → yes, distilled [sop/investigate-payment-timeouts.md](../../sop/index.md)
- Six-months-why? → no architectural choice made here; no decision entry
