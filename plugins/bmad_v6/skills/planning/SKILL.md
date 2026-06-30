---
name: planning
description: Use when you need to break down analyzed requirements into an actionable execution plan — runs Architect to produce architecture.md and the Epic or Task Manifest. Coupled to the coding pipelines; produces plan artifacts only, never triggers implementation.
---

Create an execution plan ready for a coding pipeline to implement. If no task is provided, ask first.
Load agent files on demand — never pre-load all at once; use `references/output-format.md` headers for all agent output.

Behavior contract: [skill.spec.yml](skill.spec.yml) · dependency ledger: [deps.toml](deps.toml) · full phase detail: [references/phases.md](references/phases.md).

## Contract

- **Input**: a task or requirement set (and any existing `product-brief.md` / `PRD.md` / `architecture.md`).
- **Output**: `architecture.md` plus an `epic-manifest.md` or `task-manifest.md` at project root.
- **Boundary**: planning artifacts only — this skill halts after the manifest and starts no implementation. To implement: `/multi-agent-coding-pipeline` (epics) or `/task-coding-pipeline` (single task).
- **Rules**: Phase 2 (grill-me stress) and Phase 3 (human validation of open questions) gate all code; every manifest row is independently testable; `Language` comes from the Architect's tech-stack decision, never inferred. Full forbids are in [skill.spec.yml](skill.spec.yml).

## Steps

1. **Requirements input** — reuse `product-brief.md` / `PRD.md` if present; otherwise run Analyst and/or PM inline (see [references/phases.md](references/phases.md) Phase 0).
2. **Architecture** — load `agents/architect.md` with Brief + PRD; produce `architecture.md` at project root with security architecture, OWASP threat table, and Mermaid data-flow diagram(s).
3. **Stress the plan** — run `/grill-me` against architecture + manifest; decide each supported gap into `architecture.md`, carry the rest to step 4 as open questions. Re-run until no new resolvable gaps.
4. **Human validation** — present diagram, stack, ADRs, open questions, and the `api-spec.yaml` contract (if produced); update and re-confirm on any change. Step 5 begins once `architecture.md` and `api-spec.yaml` (if present) are approved and open questions resolved.
5. **Manifest** — produce an **Epic Manifest** (≥ 2 epics) or **Task Manifest** (single epic) at project root; table shapes in [references/phases.md](references/phases.md) Phase 4.
6. **Plan summary** — for a standalone run, print the summary and stop here. When a pipeline invoked this skill, this step is informational: print the summary and hand back to the orchestrator.
