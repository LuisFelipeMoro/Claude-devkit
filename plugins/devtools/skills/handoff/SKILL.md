---
name: handoff
description: 'Use when ending a long session or switching context. Compacts the conversation into a structured handoff document saved to /tmp. Trigger phrases: "handoff", "wrap up", "end session", "save context", "create handoff", "compact this session", "summarize for next session".'
---

Compact the conversation into a single, standalone handoff document. Save to `/tmp/handoff-<YYYY-MM-DD-HHMMSS>.md`. Print the path and a 3-line summary.

Also update the Harness memory file: write/refresh `PROGRESS.md` at the repo root (`Done` / `Failed` / `Current State` / `Next` — schema in `references/progress-file.md`). The `/tmp` handoff is the rich narrative; `PROGRESS.md` is the durable, committed state the SessionStart bootstrap hook reads next session. The two must agree.

## Rules

- Point to existing artifacts (PRD, plan, ADR) rather than recreating them
- Redact API keys, passwords, and PII
- The Suggested skills section is mandatory — it helps the next session start with the right tool
- If arguments provided, tailor the document toward that next-session objective

## Document format

Follow the structure in `references/handoff-template.md` (Task, Status, Key decisions, Files changed, Next steps, Suggested skills).
