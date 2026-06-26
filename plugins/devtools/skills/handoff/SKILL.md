---
name: handoff
description: Use when ending a long session or switching context. Compacts the conversation into a structured handoff document saved to /tmp. Trigger phrases: "handoff", "wrap up", "end session", "save context", "create handoff", "compact this session", "summarize for next session".
---

Compact the conversation into a single, standalone handoff document. Save to `/tmp/handoff-<YYYY-MM-DD-HHMMSS>.md`. Print the path and a 3-line summary.

Also update the Harness memory file: write/refresh `PROGRESS.md` at the repo root (`Done` / `Failed` / `Current State` / `Next` — schema in `references/progress-file.md`). The `/tmp` handoff is the rich narrative; `PROGRESS.md` is the durable, committed state the SessionStart bootstrap hook reads next session. The two must agree.

## Document format

```markdown
# Handoff — <date>

## Task
[What was being done and why — 2–3 sentences]

## Status
- Done: [...]
- In progress: [...]
- Blocked: [...] (if any)

## Key decisions
[Non-obvious choices made with rationale — most valuable part, never truncate]

## Files changed
- `path/to/file` — [one-line purpose]

## Next steps (ordered, max 7)
1. [Most urgent first]

## Suggested skills
- `/skill-name` — [why]
```

## Rules

- Point to existing artifacts (PRD, plan, ADR) rather than recreating them
- Redact API keys, passwords, and PII
- Suggested skills section is mandatory — helps next session start with the right tool
- If arguments provided, tailor the document toward that next-session objective
