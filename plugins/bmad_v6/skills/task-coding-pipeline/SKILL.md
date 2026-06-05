---
name: task-coding-pipeline
description: Use when given a single coding task to implement — skips planning, runs Architecture then decomposes into independently-testable sub-tasks, coding, QA with quality gates, review, stress testing, and verdict per sub-task.
---

Run BMAD v6 implementation pipeline (no planning phase). If no task provided, ask first.

## Phase 1 — Planning (once)

> **Backend-Driven Architecture check (mandatory):** Verify tier placement for every component: **Frontend** = render only; **BFF** = orchestrate + shape for UI; **Core** = domain logic. Flag and push back on any AC asking the wrong tier to own logic.

Load and follow `skills/planning.md` starting from **Phase 1 (Architecture)**.

- Skip Phase 0 — task description is the input; Brief + PRD not required.
- Derive tech stack from existing codebase if present.
- Produce **Task Manifest** (Phase 3 single-task path). Confirm before continuing.

**Sub-task sizing rules:**
- Max ~200 lines of production code per sub-task
- Each sub-task has a clear interface boundary (function, class, module, endpoint)
- Sub-tasks must be independently testable — split if not

---

## Phase 2 — Sub-Task Loop (repeat per sub-task)

**A. Story** — `agents/scrum-master.md`
Input: Task Manifest row + Architecture → Output: `story-{slug}.md`

**B. Code** — sub-agent with `agents/coder.md` + `story-{slug}.md`
- Coder runs Phase 0 Analysis before writing code (reads spec, explores patterns, drafts plan)
- Coder emits `CODER DONE` signal when implementation is ready for QA
- Orchestrator stores compact ref: `"ST1: {file}.{ext}, {N} lines, implements {Interface}"`

**C. QA** — `agents/qa.md`
Input: ACs from Task Manifest (including Security ACs) + full code
Must include ≥1 security test per Security AC

Quinn runs tests and all quality gates. Route on Quinn's output signal:

- `QA→REVIEWER APPROVAL` → proceed to D (Review + Stress in parallel)
- `QA→CODER BUG REPORT` or `QA→CODER COVERAGE REQUEST` → Bug-Fix Loop
- `QA ESCALATION` (after 3 iterations) → proceed to D with FAIL status

See `references/quality-gate-reference.md` **Bug-Fix Loop Protocol** for exact procedure, iteration counting, and coverage failure sub-path.

**D. Review + Stress** *(triggered by QA signal — never before QA approval or escalation)*:
- `agents/reviewer.md` → full code, language-specific checks
- `agents/stress.md` → full code + tests, Security Under Stress

If Reviewer or StressTester emits `TUNER REQUEST` → load `agents/tuner.md` (Tyler):
- Tyler applies MINOR/NIT fixes; emits `TUNER COMPLETE`
- Reviewer re-scores only changed files; use higher score for Verdict
- Maximum 2 iterations; on `TUNER LIMIT REACHED` → proceed to E

**E. Verdict** — `agents/verdict.md`
Input: Review score + Stress score + QA summary + AC checklist + Gate Report
Unmitigated CRITICAL security = automatic NOT READY.

**F. Checkpoint**

| Score | Security | Gates | Action |
|-------|----------|-------|--------|
| ≥ 8.0 | No CRITICAL | All green | Next sub-task or final summary |
| ≥ 8.0 | CRITICAL | Any | NOT READY — fix security first |
| < 8.0 | Any | Any | Show issues; ask: *"Fix and re-run / skip / stop?"* |

On re-run: pass only delta (CRITICAL/MAJOR issues + failing ACs + failed gates).

**Post-verdict (PRODUCTION READY)**: load `agents/devops.md` (Ops) — generates Dockerfile, .dockerignore, docker-compose.yml, optional CI/k8s.

> **Context Budget**: After each sub-task: drop code + story. Retain: Architecture + Manifest + all scores.
> If running 4+ sub-tasks or context >75% full: summarize completed sub-tasks to one-line refs:
> `"ST{N}: {slug} — DONE (Review: X/10, Stress: Y/10, QA: Z/10)"` — never drop scores.

---

Use `references/output-format.md` headers. Show Pipeline Summary after each Verdict.
Load agent files on demand — never pre-load all at once.
