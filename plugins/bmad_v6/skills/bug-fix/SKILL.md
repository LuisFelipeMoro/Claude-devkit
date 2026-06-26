---
name: bug-fix
description: Use when investigating and fixing a behavioral bug. Dispatches Sam (Bug Investigator) and Amelia (Coder) as sub-agents to keep exploration out of main context. Trigger phrases: "bug", "fix", "broken", "not working", "wrong behavior", "unexpected", "crash", "regression", "debug", "fails with".
---

> **Discipline**: Failing test written RED before any fix. Never modify existing tests to fit the fix.

## Phase 1 — Investigate (Sam sub-agent)

Input: Bug description from user. Ask if not provided: "What's the wrong behavior? How do I reproduce it?"
Output: BUG REPORT + SAM HANDOFF packet.
Boundary: does NOT fix anything.

```
Agent(
  description: "Sam — bug investigation",
  subagent_type: "claude",
  model: "sonnet",
  prompt: """
Read agents/bug-investigator.md — that is your persona and instructions.

Bug: [paste user's bug description]
Working directory: [cwd]

Run your full Phase 0 → Phase 1 → Phase 2.
Write the failing test to disk. Run it and confirm RED (show failure output).

Return ONLY:
1. BUG REPORT — root cause in ≤3 sentences
2. Failing test: file path + full failure output (quoted)
3. SAM HANDOFF — everything Amelia needs to fix it, ≤200 words
"""
)
```

Show BUG REPORT and SAM HANDOFF to user before continuing.

## Phase 2 — Fix (Amelia sub-agent)

Input: SAM HANDOFF from Phase 1 (includes Sam's failing RED test).
Output: `CODER DONE — BUGFIX COMPLETE` signal (see Agent Handoff Signals in `references/quality-gate-reference.md`).
Boundary: make Sam's RED test GREEN with the minimum fix. Amelia may ADD regression tests for edge cases the fix exposes; she must NOT weaken, delete, or rewrite an existing test to fit the fix.

```
Agent(
  description: "Amelia — bug fix",
  subagent_type: "claude",
  model: "opus",
  prompt: """
Read agents/coder.md (core) PLUS the tier overlay for the bug's stack —
agents/coder-backend.md if the fix is server/API/domain, agents/coder-frontend.md if it is UI/SSR/client.
Load only the language-rules-reference.md section for the affected language.

SAM HANDOFF:
[paste full SAM HANDOFF]

Minimum change to fix the root cause. Run Sam's failing test after your fix to confirm GREEN.
You may ADD regression tests for edge cases the fix exposes; never weaken, delete, or rewrite an existing test to make it pass.

Return ONLY: CODER DONE — BUGFIX COMPLETE — [file:line — what changed, one sentence]
"""
)
```

## Phase 3 — Verify (Quinn)

Input: `CODER DONE` signal from Phase 2.
Output: Gate report or `QA→CODER BUG REPORT` if regressions found.

Run full test suite for detected stack:

| File present | Command |
|---|---|
| `next.config.*` | `rtk pnpm vitest run` |
| `go.mod` | `rtk go test ./...` |
| `Cargo.toml` | `rtk cargo test` |
| `package.json` | `rtk npx jest --passWithNoTests` |

Gate report:
```
| Gate       | Status | Details                   |
|------------|--------|---------------------------|
| new test   | ✅     | [name] RED → GREEN        |
| full suite | ✅     | N tests, 0 failed         |
```

Regressions: emit `QA→CODER BUG REPORT` → route back to Amelia (max 3 iterations).
After 3 failures: escalate to `/task-coding-pipeline` with original BUG REPORT as input.

## Phase 4 — Review (Reviewer)

Input: `QA→REVIEWER APPROVAL` from Phase 3 (all gates green) + changed files.
Output: Review score + findings.
Boundary: Reviewer sees changed files only — not full codebase.

Load `agents/reviewer.md`. Pass:
- Full content of files changed by the fix
- Gate summary: `"Gates: all green — {N} tests, 0 failed"`

| Score | Security | Action |
|-------|----------|--------|
| ≥ 8.0 | No CRITICAL | Proceed to Phase 5 |
| Any | CRITICAL | BLOCK — security issue introduced by fix; route back to Amelia |
| < 8.0 | No CRITICAL | Show findings; ask user to confirm before closing |

## Phase 5 — Summary

```
Bug Fix Summary
Root cause: [one sentence]
Fix:        [file:line — what changed]
Test:       [test name — file]
Suite:      [N passed, 0 failed]
Review:     [X/10 — key finding if any]
```
