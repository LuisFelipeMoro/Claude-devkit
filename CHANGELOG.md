# Changelog

## [Unreleased] — Stack-aware coders, leaner context, self-dogfooding

A follow-up pass focused on efficiency and specialization, on top of the TDD/Harness work below.

### Specialized coders (shared core + thin overlays)
The single Coder is now a shared TDD **core** plus one of two thin tier overlays, chosen by
the story's tier:
- **Backend** (`coder-backend`) — Go/Java/JS-TS/PHP/Rust/server-Kotlin; table-driven, integration,
  race, security tests; api-spec **producer**.
- **Frontend** (`coder-frontend`) — React/Next.js/HTMX/HTML-CSS/Flutter/Kotlin-Android; Testing
  Library/Playwright, a11y, **SSR/RSC** (server render + hydration tests); api-spec **consumer**.

Dispatch is **stack-aware**: the orchestrator spawns only the coder(s) the story needs (a
backend-only repo never spawns a frontend coder), and each loads **only the detected
language's** rules — never all of them. Full-stack stories are split BE/FE around the
`api-spec.yaml` contract. QA stays a **single tier-aware auditor** — no agent sprawl.

### Leaner, drift-free context
- The two ~95%-identical `CLAUDE.md` files are deduped — the repo-root one now `@include`s the
  canonical plugin copy. One source, no drift.
- The heavy per-language standard tables left `CLAUDE.md` (loaded every session) and consolidated
  into the single `language-rules-reference.md`, loaded on demand. `CLAUDE.md` is ~50% lighter.
- Coverage thresholds now have one declared source of truth (`quality-gate-reference.md`).

### External dependencies dropped
- `superpowers:test-driven-development` reference removed — the Coder does TDD itself now; a
  direct change writes the failing test first, then runs `/code-review-gate`. `superpowers:using-git-worktrees`
  → native `git worktree`.
- Skill-routing trigger phrases in both `CLAUDE.md` files broadened and modernized; `/rote`
  (run) split from `/rote-adapter` (create).

### Harness wiring & self-CI
- Hooks now auto-install via the plugin manifest (`hooks/hooks.json`) — the SessionStart memory
  hook and env-guard are active by default, not a manual settings paste.
- The devkit dogfoods its own Sensors: a CI workflow runs shellcheck + bash syntax + JSON
  validation on the toolkit itself.
- All four plugins now carry a `version`.

---

## [Unreleased] — TDD-first, Harness-strict overhaul

This release rebuilds the devkit around two ideas: every line of code is driven by a
test written *first*, and the whole toolkit behaves like a proper agentic **Harness**
(Guides, Sensors, Memory, Orchestration). Here's what actually changed and why it
matters day to day.

### The big shift: tests come first now

The pipeline used to be test-*after* — Amelia (Coder) wrote the implementation and was
forbidden to touch tests, then Quinn (QA) wrote tests against the finished code. That's
backwards, and it let untested-by-design code slip through.

- **Amelia now owns the full Red → Green → Refactor loop.** She writes the failing test
  first, watches it fail for the right reason, writes the least code to make it pass,
  then refactors under green. She owns both the test files and the implementation.
- **Quinn stopped writing tests and became the auditor.** Because the person who wrote
  the code is blind to what they skipped, Quinn now does the adversarial review: *does
  this test actually prove anything?* She hunts tautological and over-mocked tests
  (the ones that can never fail), demands the missing corner cases (boundaries, nulls,
  overflow, unicode, concurrency, time, error paths), and checks that no existing test
  was weakened to make a change pass. Gaps route back to Amelia via a new
  `QA→CODER TEST GAP` signal — Quinn never writes the test herself.

### Plans get stress-tested before anyone writes code

- `/grill-me` is now a **mandatory** step in planning, not an optional offer. Every plan
  gets poked for holes — missing error cases, auth gaps, undecided edge cases — while
  changes are still cheap.
- The architect no longer invents an answer to fill a gap. If the requirements support a
  decision, it's decided and written into the architecture. If they don't, it becomes an
  explicit open question for the human. Nothing ambiguous gets deferred into the
  implementation anymore — that's treated as a planning error.

### The toolkit is now a real Harness

- **Guides** — both `CLAUDE.md` files gained a Harness contract and a TDD discipline
  section, so the rules are stated up front instead of implied.
- **Sensors** — the existing git hooks (lint in error-mode, tests + coverage gate) are
  now explicitly framed as exit-code sensors: they block on failure and return a code,
  never prose to argue with.
- **Memory** — brand new. A `PROGRESS.md` at the repo root records what's done, what
  failed, and the current state. A new `session-bootstrap.sh` SessionStart hook reads it
  so a fresh session resumes with context instead of starting blind. Pipelines and
  `/handoff` keep it up to date.
- **Orchestration** — the implementer-is-not-the-validator split is now explicit, and the
  acceptance contract (ACs + Definition of Done) is frozen before any code is written.

### Right model for the right job

Agents now pick a model by task instead of defaulting to one tier: `haiku` for read-only
exploration and quick questions, `sonnet` for planning, reasoning, validation and long
sessions, `opus` for actually writing code. Cheaper where it can be, stronger where it
counts.

### Code-producing skills are test-first too

- **Database migrations** — write the migration test first (up applies, down fully
  reverses, idempotent), watch it go red, then write the SQL.
- **Observability** — assert the log fields and spans with an in-memory sink before
  instrumenting.
- **Performance profiling** — pin current behaviour with a characterization test before
  optimizing, so a speedup can't silently change results.
- **Quality gate / code-review gate / PR review** — all now check for tests-first
  evidence and reject tautological or absent tests for shipped behaviour.
- **rote-adapter** — define the acceptance test (which call, what a valid response looks
  like) before generating the adapter.

### Docs

- README, role diagrams, and the spec-driven workflow were rewritten to match the new
  Coder-builds / QA-audits reality, plus the new SessionStart hook and `PROGRESS.md`.

### Left alone on purpose

Read-only and non-coding pieces (analyst, PM, requirement analysis, business/technical
analysis, grill-me, rote, the rote API specialists, checkcomments, security-review,
release-management, write-a-skill) were not forced into a TDD shape that doesn't fit them.
