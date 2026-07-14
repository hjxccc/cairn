# Contributing

cairn's bar for adding anything: **would it survive the autopsy?**

Before proposing a feature, check it against the six principles (README). In particular:

- No runtime, no daemon, no database, no required CLI. Bash + one optional hook + markdown is the whole stack, on purpose.
- No mechanism that needs discipline to feed. If a feature only works when users remember to maintain it, it's dead on arrival — see [docs/philosophy.md](docs/philosophy.md) for the body count.
- Any maintenance ritual it adds must fit in the 2-minute wrap-up budget.

Welcome contributions:

- Ports of `install.sh` (PowerShell) and the hook (other agent harnesses)
- Agent-snippet variants for other tools (Cursor rules, Codex AGENTS.md dialects)
- Real-world example trails (anonymized)
- Translations of README / skill

Design changes should come with a `docs/decisions/NNN` draft in the PR — dogfood the convention.
