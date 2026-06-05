# Engineering Standards

## Sub-agent Discipline

- **1 sub-agent** — default. Good for one focused task (exploration, data fetch, implementation).
- **2 sub-agents** — great. Use for two genuinely independent parallel tasks with no shared state.
- **3 sub-agents** — only when 3 tasks are clearly independent, time-critical, and cannot share context. Justify before spawning.
- **Never spawn 4+** in a single turn.

Use `haiku` for read-only exploration or data fetch. Use `sonnet` for code writing or reasoning.

## Tool Preferences
- **LSP first**: Use LSP (go-to-definition, find-references, diagnostics) for code navigation — grep only when LSP not applicable
- **context7 for docs**: Always fetch current docs via context7 for any library/framework/SDK/API — never rely on training data alone
- **Notifications**: Use PushNotification when waiting >30s on external process, CI, or user input
- **Parallel work**: Use `superpowers:using-git-worktrees` for parallel feature branches
- **Never read `.env` or `.envrc`**: May contain production secrets — never read, never echo, never log
- **After git push**: Hook surfaces open PR comments automatically — for each: if valid issue (bug/missing test/security hole), fix the code + reply via `gh pr comment` explaining what changed; if not actionable (style preference/opinion/already done), reply explaining why. Never leave PR comments unanswered.

## Pipeline & Skills (always use before acting)

Before writing code, designing architecture, reviewing security, or running quality gates — invoke the matching skill. Never free-form tasks that have a defined skill.

| Task | Skill | Trigger phrases |
|------|-------|-----------------|
| New feature / epic / large task | `/multi-agent-coding-pipeline` | "build", "create", "new feature", "epic", "implement X from scratch" |
| Bug investigation and fix | `/bug-fix` | "bug", "fix", "broken", "not working", "wrong behavior", "unexpected", "crash", "regression", "debug", "fails with" |
| Single task, small feature | `/task-coding-pipeline` | "small change", "quick task", "add X to existing" |
| Architecture design | `/architecture` | "architect", "design the system", "how should we structure", "system design" |
| Requirements analysis (no code, no plan) | `/analysis` | "analyze requirements", "assess", "evaluate context", "investigate requirements", "what should we build", "what do we need" |
| Execution plan (no implementation) | `/planning` | "plan", "planning", "make a plan", "create execution plan", "break down into tasks", "roadmap", "how would we approach" |
| Security audit | `/security-review` | "security", "audit", "vulnerability", "OWASP", "pen test", "check for issues", "prompt injection", "LLM security", "LLM01", "AI security", "GenAI risk" |
| Quality gates / CI check | `/quality-gate` | "quality gate", "run gates", "CI check", "lint", "coverage", "run tests" |
| PR review or post-push comments | `/pr-review` | "review PR", "check PR", "PR comments", "code review", "review this diff" |
| Business rules mapping | `/business-analysis` | "business rules", "business logic", "domain rules", "what does the business require" |
| Technical contract mapping | `/technical-analysis` | "technical contract", "interface design", "API contract", "map the interfaces" |
| Cut a release | `/release-management` | "release", "cut a release", "ship", "version", "tag", "changelog" |
| Write a DB migration | `/database-migration` | "migration", "db migration", "schema change", "add column", "alter table" |
| Add logging / metrics / tracing | `/observability` | "logging", "metrics", "tracing", "observability", "add logs", "instrument" |
| Performance investigation | `/performance-profiling` | "performance", "slow", "profiling", "optimize", "latency", "throughput" |
| Run existing integration flow | `/rote` | "run my flow", "search flows", "list adapters", "use existing integration", "what flows do I have" |
| Create a NEW integration adapter | `/rote-adapter` | "connect to X for the first time", "build adapter", "create integration", "new connector", "add new integration", "integrate with X" |
| TDD implementation | `/superpowers:test-driven-development` | direct code ask outside a pipeline — "write this function", "implement this method", "add this helper", small focused coding not warranting a full pipeline |
| Gate + review after any code change | `/code-review-gate` | "gate and review", "pre-push check", "ready to push", "sign off my code", "check before PR", "done coding" |
| Stress-test a plan/design | `/grill-me` | "grill me", "challenge this", "stress-test", "poke holes", "pick this apart" |
| Architectural health review | `/improve-codebase-architecture` | "improve architecture", "zoom out", "architectural review", "find coupling", "codebase health" |
| End-of-session handoff doc | `/handoff` | "handoff", "wrap up", "end session", "save context", "compact this session" |
| Create a new skill | `/write-a-skill` | "write a skill", "create skill", "add skill", "new skill" |

**Rule**: If the user's message contains any trigger phrase above — or the intent clearly matches a row — invoke the skill first. Do not start writing code or analysis until the skill has been loaded. A task that "feels simple" is not an exception.

**Mandatory gate rule**: After ANY coding task that is NOT inside a pipeline (TDD, ad-hoc code change, direct implementation request), ALWAYS run `/code-review-gate` as the mandatory final step before declaring the task done. Gates without a reviewer are insufficient — logic bugs and OWASP vulnerabilities are invisible to format/lint/coverage checks.

**Agents are loaded by pipeline skills** — never load `agents/*.md` files manually unless a pipeline skill instructs it.

## Coding Discipline (12 rules — non-negotiable)

1. **Think before coding**: State assumptions, ask questions, stop when confused. Never guess.
2. **Simplicity first**: Write the minimum code needed. No speculative abstractions.
3. **Surgical changes**: Modify only necessary code, matching existing style. No drive-by refactors.
4. **Goal-driven execution**: Define clear success criteria before starting. Tasks are verifiable goals.
5. **Read before you write**: Review existing callers, exports, and related code before implementing.
6. **Surface conflicts**: Pick one approach, explain the tradeoff, flag contradictions — never average them.
7. **Match conventions**: Existing codebase conventions beat personal preference. Always.
8. **Checkpoint frequently**: After each phase, state: what's done, what's verified, what remains.
9. **Tests verify intent**: Tests encode the *why* of behavioral requirements, not just the *what*.
10. **Do not guess**: State limitations explicitly if code cannot be tested or verified immediately.
11. **One topic per file**: Split guidelines into focused files — never combine unrelated rules.
12. **Fail loudly**: Surface uncertainty and errors. Never hide them.

## Task Discipline (boundaries required)

Every task — before starting — must define:
- **Input**: What does this task receive? (spec, file, data)
- **Output**: What does this task produce? (file written, text printed, test passing)
- **Boundary**: What does this task NOT do? (explicit out-of-scope)

Tasks that lack defined outputs are not tasks — they are conversations. Convert first, then start.

Use `TaskCreate` to track tasks with >1 step. Mark `in_progress` when starting, `completed` when done.

## Universal
- **SOLID + DRY**: Single responsibility; no duplication. Composition over inheritance.
- **Clean Architecture**: Domain logic isolated from I/O layers. No domain leakage into transport/DB/cache.
- **Security-First**: OWASP Top 10 (web) + OWASP LLM Top 10 2025 (AI/GenAI) as hard baselines. Validate all inputs; encode all outputs. Fail secure. No secrets in source/logs/errors.
- **Comments**: Write the *why* only — never the *what*. Remove commented-out code immediately.
- **Scope**: No premature abstractions (3 cases before extracting). No speculative features (YAGNI).

## Quality Gates (hard requirement — never skip)
| Gate | Go | TypeScript |
|------|-----|------|
| Format | `gofmt` | `prettier --check` |
| Lint | `go vet` + `golangci-lint` (0 errors) | `eslint --max-warnings 0` |
| Types | — | `tsc --noEmit` (`strict: true`) |
| Coverage | ≥85% | ≥85% |
| Race | `go test -race ./...` | — |
| Vuln | `govulncheck ./...` | `npm audit --audit-level high` |
| PR Review | Reviewdog in CI pipeline | Reviewdog in CI pipeline |

> **Frontend additions** — React: `eslint-plugin-react-hooks` (0) + `eslint-plugin-jsx-a11y` + `@testing-library/react` ≥ 85% · Next.js: `next lint` + `tsc --noEmit` + `next build` + tests ≥ 85%

## Go
**Authority (in order)**: [Uber Go Style](https://github.com/uber-go/guide/blob/master/style.md) → [Ardan Labs/service](https://github.com/ardanlabs/service) → [JetBrains Go Modern](https://github.com/JetBrains/go-modern-guidelines) → Effective Go

| Rule | Requirement |
|------|-------------|
| Errors | `fmt.Errorf("doing X: %w", err)` — never bare `return err`; **NEVER** `_ =` or `_ :=` to discard errors; handle every error |
| Inspection | `errors.Is` / `errors.As` — never string-match errors |
| Panics | Unrecoverable programmer errors only; **never** in library code |
| Interfaces | Consumer package owns; single-method → `<Verb>er`; no embedding in exported structs |
| Context | `ctx context.Context` always first parameter, named `ctx` |
| Concurrency | Channels to communicate; mutexes only to serialize state access |
| Goroutines | Documented owner + documented termination condition; `errgroup` for fan-out |
| Types | Concrete or generics `[T any]` — never `interface{}` / `any` |
| Zero values | Design types so zero value is safe and usable without constructor |
| Layout | `cmd/` (main only) · `internal/` · `business/` · `foundation/` |
| Tests | Table-driven; `go test -race ./...`; ≥85% line coverage |
| Deps | Stdlib first; `go.uber.org/zap` · `testify` · `golang.org/x/sync` · `ardanlabs/conf/v3` |
| No reflection | `reflect` only for serialization libraries with explicit justification |
| Package names | Lowercase single word — no `utils` / `helpers` / `common` |
| `init()` | Avoid unless truly unavoidable; never in library packages |

## TypeScript
| Rule | Requirement |
|------|-------------|
| Strict | `strict: true` in tsconfig; no `any` on public API or HTTP boundaries |
| Validation | zod/joi at every HTTP boundary before processing request data |
| Crypto | `crypto.randomBytes()` not `Math.random()`; Web Crypto API in browser |
| Cookies | `httpOnly`, `secure`, `sameSite: strict` on all auth cookies |
| OpenAPI | JSDoc `@swagger` blocks or NestJS decorators; must compile zero errors |
| Tests | Jest + `@testing-library`; ≥85% line coverage |
| Lint | `eslint-plugin-security` + `@typescript-eslint`; zero warnings |
| GitHub API | Use `@octokit/rest` for all GitHub REST API integrations |

## React
| Rule | Requirement |
|------|-------------|
| Components | Functional only; hooks rules via `eslint-plugin-react-hooks` (zero violations) |
| A11y | `eslint-plugin-jsx-a11y` — zero warnings; semantic HTML; no div-soup |
| Testing | Vitest or Jest + `@testing-library/react`; no Enzyme; ≥ 85% line coverage |
| State | Local state first; Context for shared; Zustand/Redux only when justified + documented |
| Performance | No premature `memo`/`useMemo`/`useCallback` — profile first |
| Tailwind | If `tailwind.config.*` present: utility classes only; `eslint-plugin-tailwindcss` class-order; no arbitrary values without justification |
| Bundle | No heavy dep without bundle-size justification; tree-shaking enabled |
| Security | No `dangerouslySetInnerHTML` with user data; sanitize via `DOMPurify` before render |

## Next.js
| Rule | Requirement |
|------|-------------|
| Router | App Router preferred for new projects; Pages Router only for legacy |
| Components | Server Components by default; `'use client'` only when state/events required |
| Data fetching | Server Components fetch data server-side; never expose server secrets to client |
| Validation | zod/joi validation in Route Handlers + Server Actions before processing; `next-safe-action` for SA type safety |
| Images | `next/image` for all images — no bare `<img>` tags |
| Fonts | `next/font` for all custom fonts — no external font CDN requests |
| Secrets | `NEXT_PUBLIC_*` only for intentionally public values; server-only vars never referenced in Client Components |
| Security | `next/headers` for cookie/header access in Server Components; CSP via `next.config` headers |
| Lint | `next lint` (eslint-config-next); zero warnings |
| Build | `next build` must pass — catches SSR/hydration issues `tsc --noEmit` misses |
| Testing | Vitest or Jest + `@testing-library/react`; Playwright for E2E; ≥ 85% coverage |
| Bundle | Analyze with `@next/bundle-analyzer`; no unintentional client-side bloat |


## HTML / CSS
| Rule | Requirement |
|------|-------------|
| Semantic HTML | Use `<section>`, `<article>`, `<nav>`, `<header>`, `<footer>`, `<main>`, `<aside>` — no div-soup |
| Accessibility | `lang` on `<html>`; `alt` on every `<img>`; `<label>` for every `<input>`; ARIA only when native semantics insufficient |
| **Tailwind (preferred)** | Use Tailwind utility classes; `eslint-plugin-tailwindcss` for class-order; no arbitrary values without justification; design tokens via `tailwind.config.*` |
| Vanilla CSS (when no Tailwind) | BEM naming or CSS Modules; CSS custom properties for design tokens; no `!important` unless justified; max 3 levels of nesting |
| Responsive | Mobile-first: `min-width` breakpoints; no fixed-width layouts |
| Performance | Animations use `transform`/`opacity` only (GPU-composited); no layout-triggering properties in loops |
| No inline styles | No `style=""` attributes; exception: dynamic values set via JS only |
| Linting | `stylelint` with `stylelint-config-standard`; zero warnings |
| Validation | HTML must pass W3C validator (or `htmlhint`) with zero errors |

## Security Defaults (all languages)
1. **Never read `.env` / `.envrc`** — these files may contain production secrets
2. Validate type · length · format · charset on every external input before any processing
3. Parameterized queries only — never string-concatenate SQL or shell commands
4. Logs: structured JSON; `error` level in prod; always include `request_id` + `timestamp`; never log PII/secrets/tokens/card data
5. Idempotency: UUID v4 key for outbound mutations, token refresh, payment calls; store result with TTL
6. Graceful shutdown: SIGTERM → stop accepting → drain in-flight (≤30s) → close in reverse acquisition order

## AI/GenAI Workloads
- **Inference serving**: Prefer [NVIDIA NIM](https://developer.nvidia.com/nim) for production LLM microservice deployment
- **OWASP LLM Top 10** applies as hard gates (see `/security-review` skill)
- Use context7 to verify any NVIDIA/HuggingFace/LangChain/OpenAI SDK API shapes before implementing

Full OWASP LLM Top 10 2025 checklist enforced by `/security-review` skill — invoke it for any AI/GenAI feature.
