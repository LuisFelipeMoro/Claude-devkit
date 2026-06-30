# rote reference

Full command syntax, the task-execution flow, model-tracked runs, and
troubleshooting that the lean `SKILL.md` router defers to.

## Phase 0 — State snapshot commands

```bash
rote adapter list          # what adapters are installed
rote flow search ""        # all crystallized flows (empty string = list all)
```

Inventory format (≤5 lines):

```text
Rote state:
  Adapters: [id1, id2, ...] (or "none installed")
  Flows: [flow1, flow2, ...] (or "none yet")
```

## Rule 1 — Running a found flow

Run it from `/tmp` to stay outside `~/.rote/workspaces/`:

```bash
# Shell flows:
${ROTE_HOME:-$HOME/.rote}/flows/{endpoint}/{name}.sh [args]
# TypeScript flows — MUST use rote deno, NOT system deno:
rote deno run --allow-all ${ROTE_HOME:-$HOME/.rote}/flows/{endpoint}/{name}.ts [args]
```

## Rule 2 — Catalog fallback commands

```bash
rote adapter catalog search "<intent>"   # find installable adapter
rote adapter catalog info <id>           # inspect a hit
rote adapter new <id> --yes              # install non-interactively
rote <id>_probe                          # list tools
rote <id>_call <tool> '<json-args>'      # invoke
```

## Rule 3 — Crystallize commands

```bash
rote flow crystallize "<intent-as-name>" --adapter <id> --intent "<description>"
rote flow release "<intent-as-name>"
```

Name format: `<adapter>-<verb>-<noun>` (e.g. `github-list-open-prs`, `linear-get-my-tickets`).

## Rule 4 — MEMORY.md entry template

```text
rote is installed and working in this project.
ALWAYS use `rote flow search "<intent>"` before calling MCP/CLI directly.
Installed adapters: [rote adapter list output]
Crystallized flows: [rote flow search "" output]
```
