---
name: rote-adapter
description: Use when creating a NEW integration adapter from scratch — discovers the API, negotiates auth, scopes endpoints, builds, and verifies the adapter in 8 autonomous phases. Use /rote for running existing adapters/flows. Trigger phrases: "build adapter", "create integration", "new connector", "connect to X for the first time", "create rote adapter", "add new integration", "integrate with X".
---

Dispatch the autonomous rote-adapter agent to build a new integration connector from scratch.

## Pre-flight — Choose the right skill

| Intent | Skill |
|--------|-------|
| Create a **new** adapter for a service never connected before | `/rote-adapter` (this skill) |
| Run, search, or reuse an **existing** adapter/flow | `/rote` |

If the user already has a working adapter and just wants to run it, redirect to `/rote`.

## Dispatch

```
Agent(
  description: "rote-adapter — autonomous adapter creation",
  subagent_type: "rote-adapter",
  model: "sonnet",
  prompt: """
Read agents/rote-adapter.md — that is your persona and full 8-phase instructions.

Integration target: [paste user's integration description — service name, what data/actions needed]
Working directory: [cwd]

Run your full Phase 0 → Phase 7 (Discovery → Analysis → Research → Auth → Scope → Creation → Verification → Crystallization).
Contract-first: define the Phase 8 acceptance test (which read-only tool you will call and what a valid response looks like) BEFORE the create command. The adapter is done only when that predefined test passes.

Return ONLY:
1. Adapter name + file path(s) created
2. Auth method used (API key / OAuth2 / Bearer / etc.)
3. Verification result: success output or failure with exact error
4. Crystallized flow name (what /rote can now call)
5. Any manual setup steps remaining for the user (API key env var, OAuth redirect URL, etc.)
"""
)
```

Show the result to the user. If verification failed, surface the exact error and manual steps.

## Anti-patterns
- Don't load `agents/rote-adapter.md` directly — dispatch it as a sub-agent to keep the 8-phase discovery out of main context
- Don't use this for integrations that already have an adapter — use `/rote` instead
- Don't skip verification (Phase 6) — an adapter that doesn't verify is not complete
