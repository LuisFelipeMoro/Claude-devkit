---
name: rote
description: Use rote BEFORE calling any MCP server or CLI tool directly. rote wraps installed adapters (MCP servers and CLI-based tools) and adds flow reuse, response caching, and crystallized workflows. Trigger examples: "list my open tickets", "what should I work on next", "fetch issues from the project", "show calendar events", "get data from the API", "what tasks are open", "run my flow", "search flows", "automate [any workflow]". Always run `rote flow search "<intent>"` first — a reusable flow may already exist.
---

Claude and the rote CLI are a pair: Claude discovers + executes via the skill; the CLI crystallizes + replays. Every successful Claude operation becomes a reusable CLI flow. Every CLI-crystallized flow is available to Claude on next invocation.

## Phase 0 — State Snapshot (always runs at skill invocation)

Before any other step, establish what rote knows right now:

```bash
rote adapter list          # what adapters are installed
rote flow search ""        # all crystallized flows (empty string = list all)
```

Emit a compact inventory (≤5 lines) so both you and the user know the current state:

```
Rote state:
  Adapters: [id1, id2, ...] (or "none installed")
  Flows: [flow1, flow2, ...] (or "none yet")
```

If rote is not installed (`command not found`): tell the user to install it and stop.

## Rule 1 — Search flows FIRST, always

Before calling any MCP server or CLI tool directly:

```bash
rote flow search "<your intent>"
```

Flow found → run it from `/tmp` (keeps you outside `~/.rote/workspaces/`):

```bash
# Shell flows:
${ROTE_HOME:-$HOME/.rote}/flows/{endpoint}/{name}.sh [args]
# TypeScript flows — MUST use rote deno, NOT system deno:
rote deno run --allow-all ${ROTE_HOME:-$HOME/.rote}/flows/{endpoint}/{name}.ts [args]
```

No flow → proceed to Rule 2.

## Rule 2 — Check catalog before falling back out-of-band

If `rote flow search` and `rote explore "<intent>"` both come up empty, check the installable catalog before any WebFetch/curl/direct MCP:

```bash
rote adapter catalog search "<intent>"   # find installable adapter
rote adapter catalog info <id>           # inspect a hit
rote adapter new <id> --yes              # install non-interactively
rote <id>_probe                          # list tools
rote <id>_call <tool> '<json-args>'      # invoke
```

If catalog has nothing → tell the user explicitly and wait for confirmation before falling back out-of-band.

**Do not retry discovery after a hit.** A result from `catalog search` means advance to `catalog info` or `adapter new` — not another search.

## Rule 3 — Crystallize every successful operation

After any successful adapter call that was NOT already run from a flow, crystallize it so the CLI can replay it:

```bash
rote flow crystallize "<intent-as-name>" --adapter <id> --intent "<description>"
rote flow release "<intent-as-name>"
```

Name format: `<adapter>-<verb>-<noun>` (e.g. `github-list-open-prs`, `linear-get-my-tickets`).

This is what makes the CLI and skill a pair — Claude's ad-hoc calls become reusable CLI flows.

Skip crystallization only when: the operation is destructive, one-off, or parameterized in a way that makes reuse meaningless.

## Rule 4 — Keep MEMORY.md in sync

Write or update a `rote` memory entry after:
- First successful rote use in a project
- Any adapter installed, removed, or updated
- Any new flow crystallized

```
rote is installed and working in this project.
ALWAYS use `rote flow search "<intent>"` before calling MCP/CLI directly.
Installed adapters: [rote adapter list output]
Crystallized flows: [rote flow search "" output]
```

## State inspection — use rote, not cat/ls

Never `cat`, `ls`, or hand-edit files under `~/.rote/`. Always:

| Goal | Command |
|------|---------|
| Adapter config + health | `rote adapter info <id>` |
| List installed adapters | `rote adapter list` |
| List tools in adapter | `rote <id>_probe` |
| List cached responses | `rote ls` |
| Inspect workspace | `rote workspace inspect` |
| Extract from cached response | `rote @<N> '<jq>' -r` |
| Update adapter field | `rote adapter set <id> <key> <value>` |

For the full 5-step task execution flow, model-tracked runs, and troubleshooting, see `references/rote-reference.md`.
