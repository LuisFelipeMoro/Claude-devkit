---
name: code-review-gate
description: Use after any coding task outside a full pipeline — TDD sessions, direct code changes, ad-hoc fixes. Runs all quality gates then routes to the Reviewer agent. Gates must pass before Reviewer runs. Trigger phrases: "gate and review", "pre-push check", "ready to push", "sign off my code", "check before PR", "review my changes", "done coding".
---

Mandatory gate + review for any code generation outside a pipeline. Every code change must clear this gate before it is considered done.

## Phase 1 — Quality Gates

Input: Working directory with changed files.
Output: Gate report (PASS/FAIL per gate).
Boundary: does NOT fix failing gates — reports only.

Invoke `/quality-gate` skill. If any gate FAILS:
- Show the failing gate + error output
- Stop here. Do not proceed to Phase 2.
- Provide the fix from `references/quality-gate-reference.md` and wait for re-run.

All gates must be green before Phase 2.

## Phase 2 — Reviewer

Input: Gate report (all PASS) + changed files (complete file content, not just diff).
Output: Review score (1–10) + structured findings.
Boundary: Reviewer sees ONLY changed files — not the full codebase.

Collect changed files:
```bash
rtk git diff --name-only HEAD    # unstaged + staged
# or for staged only:
rtk git diff --name-only --cached
```

Load `agents/reviewer.md`. Pass:
1. Full content of each changed file (not a diff — Reviewer needs complete context)
2. One-line gate summary: `"Gates: all green — {X}% coverage, {N} tests"`

Reviewer runs the full Security Deep-Dive checklist, language-specific checks, and the **TDD-compliance check**: every behaviour shipped in the diff has a test that asserts observable outcome (not a tautology, not mock-call-only), corner/error cases are covered, and no existing test was weakened to pass. Absent or tautological tests for shipped behaviour = MAJOR finding.

## Phase 3 — Verdict

| Score | Security | Action |
|-------|----------|--------|
| ≥ 8.0 | No CRITICAL | ✅ `CODE REVIEW GATE PASSED — Score: X/10 · Coverage: Y% · N tests` |
| ≥ 8.0 | CRITICAL finding | ❌ BLOCK — fix security issue first, then re-run from Phase 1 |
| < 8.0 | No CRITICAL | Show findings; ask: *"Fix and re-run, or push with known issues?"* |
| < 8.0 | CRITICAL | ❌ BLOCK — fix required; do not push |

On re-run after fixes: restart from Phase 1 (gates must re-pass after any code change).

## Anti-patterns
- Don't run this inside a pipeline — pipelines embed their own gates + reviewer loop
- Don't skip Phase 2 after Phase 1 passes — gates catch format/coverage/lint, not logic or security bugs
- Don't pass a git diff to the Reviewer — pass complete file content so context-sensitive checks work
