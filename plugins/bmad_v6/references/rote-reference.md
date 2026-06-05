# Reference: rote — Task Execution & Commands

## When to use rote

Use for: tickets, issues, PRs, calendar events, workspace data, any API with an installed adapter.
Do NOT use for: pure local file ops, math, writing, real-time streaming.

## Claude ↔ CLI Pairing Model

```
User intent
    │
    ▼
/rote skill (Claude)          rote CLI (terminal / extension)
    │                               │
    │  Phase 0: state snapshot ◄────┤ rote adapter list / rote flow search ""
    │                               │
    │  Rule 1: flow found ──────────► run flow from /tmp
    │  Rule 1: no flow              │
    │  Rule 2: adapter call ────────► rote <id>_call ...
    │                               │
    │  Rule 3: crystallize ─────────► rote flow crystallize + release
    │                               │
    └──────────────────────────────►  rote @N to extract cached result
```

**Contract**: Every non-destructive Claude adapter call becomes a crystallized CLI flow.
On next invocation, Phase 0 discovers it, and Rule 1 replays it — no repeat discovery.

## 5-Step Task Execution Flow

### Step 1 — Search for existing flows
```bash
rote flow search "<intent>"
```
Flow found → run from `/tmp`:
```bash
# Shell flows:
${ROTE_HOME:-$HOME/.rote}/flows/{endpoint}/{name}.sh [args]
# TypeScript — MUST use rote deno, NOT system deno:
rote deno run --allow-all ${ROTE_HOME:-$HOME/.rote}/flows/{endpoint}/{name}.ts [args]
```
No flow → Step 2.

### Step 2 — Discover adapter
```bash
rote explore "<intent>"
```

### Step 3 — Use the adapter
```bash
rote adapter info <id>
rote <id>_probe
rote <id>_call <tool> '{"param":"value"}'
```

### Step 4 — Crystallize flow (mandatory after any new ad-hoc call)
```bash
rote flow crystallize "<name>" --adapter <id> --intent "<description>"
rote flow release "<name>"
```

Name format: `<adapter>-<verb>-<noun>` (e.g. `linear-list-my-open-tickets`, `github-list-open-prs`).

Skip only for: destructive ops, one-off ops, calls too parameterized to generalize.

### Step 5 — Run with model tracking (long-running or automated flows)
```bash
rote init my-task --seq
cd ${ROTE_HOME:-$HOME/.rote}/rote/workspaces/my-task
rote run --inference-id $(uuidgen) --model claude-sonnet-4-6 --model-type chat \
  --model-version 20250514 ${ROTE_HOME:-$HOME/.rote}/flows/{path}/flow.sh [params]
rote @1 '.result' -r
```

## Adapter management
```bash
rote adapter list
rote adapter new <id> --yes
rote adapter set <id> base_url <url>      # fix wrong URL — never recreate
rote adapter set <id> additional_headers.Authorization '${TOKEN}'
rote adapter remove <id>
```

## Token efficiency
- Paginate: `rote <id>_call list '{"per_page":10,"page":1}'`
- Filter at source: pass `state`, `labels`, `since` params when available
- Reuse cache: `rote @<N> '.field' -r` before re-fetching

## CLI-only flows (crystallized outside Claude)

Flows crystallized directly from the terminal are visible to the skill at next invocation via Phase 0.
No action needed from Claude — `rote flow search ""` discovers them automatically.

To run a CLI-crystallized flow from Claude: use Rule 1 path exactly as with any other flow.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `flow search` empty | No flows yet — advance to `rote explore` |
| Phase 0 shows no adapters | Run `rote adapter list` manually to confirm; install if needed |
| TS flow fails | Use `rote deno run --allow-all`, not `deno run` |
| Wrong `base_url` | `rote adapter set <id> base_url <url>` — never recreate |
| Secrets in output | Use `'${TOKEN_NAME}'` reference in adapter set |
| `rote @N` returns null | Try `rote @N '.' -r` to see full structure |
| Flow crystallized by CLI, not visible in skill | Verify with `rote flow search ""` in Phase 0 |
