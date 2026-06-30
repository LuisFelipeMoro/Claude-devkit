# PROGRESS.md schema

`PROGRESS.md` lives at the repo root and is the durable, committed state the
SessionStart bootstrap hook reads at the start of the next session. It must stay
in agreement with the rich `/tmp` handoff narrative.

```markdown
# PROGRESS

## Done
- [Completed work, newest last]

## Failed
- [What was attempted and did not work, with the reason]

## Current State
- [Where the codebase / task stands right now]

## Next
- [Ordered next actions for the following session]
```

Rules:
- Append at each checkpoint; never silently rewrite history.
- Keep entries factual and terse — one line each.
- Redact secrets, tokens, and PII.
