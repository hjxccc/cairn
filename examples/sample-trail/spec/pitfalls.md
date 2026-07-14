# Pitfalls ledger

> One line per pitfall. New pitfalls append; changed countermeasures edit the original line in place (`rev:MM-DD`).

- 03-18 fixed-schedule retry jobs synchronize into storms → always add jitter + retry cap to any replay cron [retry][cron]
- 03-11 price cache survives currency switch → invalidate on currency-change event, TTL alone is not enough (rev:03-13, was "shorten TTL") [cache][currency]
- 03-12 anonymizer <2.3 leaks email domains → version pre-check now in the staging-data SOP [pii][staging]
