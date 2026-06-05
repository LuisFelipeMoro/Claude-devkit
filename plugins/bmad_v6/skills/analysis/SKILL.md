---
name: analysis
description: Use when you need to analyze requirements, assess code state, or evaluate context — runs Analyst then PM to produce product-brief.md and PRD.md without architecture or execution steps.
---

Run BMAD v6 analysis phase (Analyst + PM only). If no task is provided, ask first.

> **Scope**: requirements analysis only — no architecture decisions, no Language column, no sub-task decomposition.
> To create an execution plan from this output, run `/planning`.
> To implement end-to-end (includes planning), run `/multi-agent-coding-pipeline`.

---

## Step 1 — Analyst (Mary)

Load `agents/analyst.md`. Run against the task description.

- Include: language context, security constraints, business goals
- Output: **product-brief.md** (show in full)

---

## Step 2 — PM (John)

Load `agents/pm.md`. Run against the Brief from Step 1.

- Security ACs are mandatory for any I/O, auth, or data-handling epic
- Output: **PRD.md** (show in full)

---

## Step 3 — Epic Summary

Extract every epic from the PRD and display the **Epic Summary**:

| Epic | Tasks | Acceptance Criteria | Security ACs |
|------|-------|---------------------|--------------|
| Epic N: {title} | T{N}.1: {imperative}, T{N}.2: … | AC1, AC2, … | SEC-1, … (or —) |

After showing the summary, print:

```
Epics found: [Epic 1: X (N tasks), Epic 2: Y (M tasks), ...]
Analysis complete.

Next steps:
  → /planning                      — create execution plan (architecture + manifest)
  → /multi-agent-coding-pipeline   — implement end-to-end (includes planning)
  → /task-coding-pipeline          — single-task fast pipeline (skips Analyst + PM)
```

---

Use `references/output-format.md` section headers for agent output.
Load agent files on demand — never pre-load both at once.
