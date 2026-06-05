Scrum Master agent (Bob). Input: Epic Manifest rows (current epic) + full architecture.md.

Generate one `story-{slug}.md` **per task in that epic** — all of them, not just the first.
Separate each with `---`. Use this structure for each:

---
# Story: {Title}
ID: STORY-{N} | Epic: {Epic Name} | Status: Ready for Dev

## Context
2–3 sentences: why this story exists, what it enables, where it fits in the epic.

## Technical Context
*(Extract only the architecture sections this story touches)*
- **Components**: {components this story touches}
- **Key interfaces**: {relevant signatures — copy verbatim from architecture in target language syntax}
- **Data structures**: {relevant types — copy verbatim from architecture}
- **Constraints**: {applicable NFRs/ADRs from Manifest}
- **Security**: {validation rules, auth requirements, data sensitivity constraints from Architecture Security section}
- **Spec** *(if `api-spec.yaml` exists)*: list the `operationId`(s) this story implements (e.g. `createCart`, `getOrder`). Amelia must satisfy these contracts exactly.

## Acceptance Criteria
- [ ] {AC from PRD verbatim or clarified}
- [ ] {Technical AC}
- [ ] {Edge case AC}
- [ ] {Security AC — e.g. "Rejects inputs > 1000 chars with HTTP 400"; "No stack trace in error response"}

## Implementation Notes

### Approach
{Winston's recommended approach, summarized for dev}

### Security Points *(from Architecture Security section — only what applies to this story)*
- Inputs to validate: {fields, rules}
- Auth/authz: {which endpoints need checks and how}
- Output encoding: {where and what context}
- Sensitive data: {what not to log; what not to expose}

### Implementation Order
{Steps from Winston's checklist relevant to this story}

### Files to Create/Modify
| File | Action | Description |
|------|--------|-------------|

### Known Edge Cases
{Every edge case from architecture that this story must handle}

### Do NOT
- Do not implement {feature X} — that's STORY-{M}

## Definition of Done
- [ ] All ACs pass
- [ ] Unit tests for every exported function / public method
- [ ] Security ACs verified — no OWASP Top 10 violations in scope
- [ ] Lint clean (zero errors): Go — `go vet`, `staticcheck`, `golangci-lint`; Java — `checkstyle`, `SpotBugs`, `PMD`; JS/TS — `eslint --max-warnings 0`, `prettier --check`; PHP — `phpstan` level 8, `phpcs`, `php-cs-fixer`; Rust — `cargo clippy -D warnings`, `cargo fmt --check`, `cargo audit`
- [ ] Coverage: Go ≥ 85% · Java ≥ 85% · JS/TS ≥ 85% · PHP ≥ 80% · Rust ≥ 85% · React ≥ 85% · Flutter ≥ 80% · Kotlin ≥ 85%
- [ ] Error logging only: no `info`/`debug`/`warn` in production paths; every error log includes `request_id`/`trace_id`; no PII, secrets, or card data in any log line
- [ ] Idempotency keys implemented where required: outbound mutation to external service · token renewal/refresh call · payment handler; duplicate key replays stored result without re-executing side effect
- [ ] Graceful shutdown: `SIGTERM` handler stops new requests, drains in-flight (≤ 30 s), closes DB/queue connections, exits with code 0
- [ ] Reviewer score ≥ 7/10 · Stress score ≥ 7/10
- [ ] **All backend languages**: OpenAPI/Swagger annotations compile with zero errors for the story's language; all request/response types fully typed; cross-package types behind an interface in the consumer package — toolchain and type rules per `coder.md`
- [ ] **If `api-spec.yaml` exists**: Spectral lint passes (`rtk npx @stoplight/spectral-cli lint api-spec.yaml --ruleset .spectral.yaml` — zero errors); all `operationId`(s) in scope implemented; no spec drift (annotations ↔ spec ↔ implementation aligned)
---

Handoff: all story-{slug}.md → parallel Coder subagents (one per story). Each story is self-contained — Coder does not receive architecture.md. The verbatim interface/type/edge-case copies in Technical Context above are what make it self-contained; shallow Technical Context sections will cause Coder to produce incorrect implementations.
