# Reference: quality-gate — Gate Commands by Stack

> **RTK**: All commands below use `rtk` prefix. The `rtk hook claude` PreToolUse hook also intercepts every Bash call transparently — so even without an explicit prefix, RTK filters output. Use `rtk proxy <cmd>` when you need raw unfiltered output (debugging, structured parsing). Never prefix RTK meta-commands (`rtk gain`, `rtk discover`, `rtk proxy`) with `rtk` again.

## Go
| Gate | Command | Pass |
|------|---------|------|
| Vet | `rtk go vet ./...` | Zero output |
| Lint | `rtk golangci-lint run` | Zero errors |
| Race | `rtk go test -race ./...` | No races |
| Vuln | `rtk govulncheck ./...` | No vulnerabilities |
| SQL | `rtk sqlc vet` | Zero *(skip if no sqlc.yaml)* |
| Coverage | `rtk go test -coverprofile=coverage.out -covermode=atomic ./... && go tool cover -func=coverage.out \| tail -1` | ≥ 85% |

## TypeScript / React / Next.js
| Gate | Command | Pass |
|------|---------|------|
| Types | `rtk tsc --noEmit` | Zero errors |
| Lint | `rtk lint` | Zero warnings |
| Format | `rtk prettier --check .` | No changes |
| Build | `rtk next build` *(Next.js only)* | Zero errors |
| Vuln | `rtk npm audit --audit-level=high` | No high/critical |
| Coverage | `rtk pnpm vitest run --coverage` | ≥ 85% |

> `next build` is a required gate — catches SSR/hydration issues that `tsc` misses.

## Rust
| Gate | Command | Pass |
|------|---------|------|
| Lint | `rtk cargo clippy -- -D warnings` | Zero warnings |
| Format | `rtk cargo fmt --check` | No changes |
| Vuln | `rtk cargo audit` | No vulnerabilities |
| Coverage | `rtk cargo tarpaulin --out Xml` | ≥ 85% |

## Java
| Gate | Command | Pass |
|------|---------|------|
| Bugs | `rtk mvn spotbugs:check` / `rtk ./gradlew spotbugsMain` | Zero |
| Style | `rtk mvn checkstyle:check` | Zero |
| Vuln | `rtk mvn dependency-check:check` | No high/critical CVEs |
| Coverage | `rtk mvn verify` / `rtk ./gradlew test jacocoTestReport` | ≥ 85% |

## PHP
| Gate | Command | Pass |
|------|---------|------|
| Static | `rtk vendor/bin/phpstan analyse --level 8` | Zero |
| Style | `rtk vendor/bin/phpcs` | Zero |
| Vuln | `rtk composer audit` | No vulnerabilities |
| Coverage | `rtk vendor/bin/phpunit --coverage-text` | ≥ 80% |

## Spec Validation *(run first — only if `api-spec.yaml` exists in project root)*

| Gate | Command | Pass |
|------|---------|------|
| Spec lint | `rtk npx @stoplight/spectral-cli lint api-spec.yaml --ruleset .spectral.yaml` | Zero errors |
| Spec validate | `rtk npx swagger-cli validate api-spec.yaml` | Valid |
| Go annotations | `rtk swag init ./...` | Zero errors |
| TS annotations | `rtk tsc --noEmit` | Zero errors |
| Java annotations | `rtk mvn compile` | Zero errors |
| Contract test | `rtk schemathesis run api-spec.yaml --url http://localhost:{port} --checks all` | Zero failures *(integration only)* |

Spec gates fail = QA Score capped at 4, same as any other gate failure.

See `references/spec-driven-reference.md` for `.spectral.yaml` template, annotation patterns, and drift detection guide.

---

## Common Fixes

| Gate | Failure | Fix |
|------|---------|-----|
| `golangci-lint` errcheck | Unhandled error | `if err := fn(); err != nil { return fmt.Errorf("ctx: %w", err) }` |
| `go test -race` | Data race | `sync.Mutex` or `sync.Map` |
| `govulncheck` | CVE | `go get module@patched` + `go mod tidy` |
| `tsc --noEmit` | Implicit `any` | Add explicit type annotation |
| `eslint` detect-object-injection | User input in bracket notation | `Object.prototype.hasOwnProperty.call(obj, key)` |
| `cargo clippy` | `unwrap()` in prod | `?` or `match` |
| Coverage below threshold | Untested paths | Table-driven tests for every error path |

---

## Bug-Fix Loop Protocol

*Shared by task-coding-pipeline, multi-agent-coding-pipeline, and bug-fix. Reference this section — do not copy-paste.*

**Trigger**: Any quality gate FAILS after QA writes tests.

**Rule**: Only Amelia (Coder) touches implementation. Only Quinn (QA) touches test files. No exceptions.

**Loop (max 3 iterations)**:

1. Quinn emits a structured `QA→CODER BUG REPORT`:
   ```
   QA→CODER BUG REPORT
   File: path/to/file.ext
   Line: [line number]
   Test: [failing test name]
   Expected: [what should happen]
   Actual: [what happens instead]
   Gate: [which gate failed — lint / race / coverage / test]
   Classification: LOGIC | TYPING | CONCURRENCY | SECURITY | PERFORMANCE
   ```
2. Pipeline routes BUG REPORT to Amelia — Amelia fixes implementation ONLY.
3. Amelia emits `CODER DONE — BUGFIX [N]: [one-line description]` (N = iteration number).
4. Quinn re-runs ALL quality gates from scratch.
5. Repeat until PASS or max iterations reached.

**After 3 failures** — Quinn escalates:
```
QA ESCALATION: Implementation unresolved after 3 iterations.
[BUG REPORT attached]
Routing to Reviewer with FAIL status.
```
Reviewer receives the FAIL-status artifact and scores accordingly.

**Coverage failure sub-path** (distinct from bug failures):

If coverage < threshold AND Quinn can write more tests:
- Quinn writes additional tests to cover the uncovered paths
- Quinn re-runs coverage gate (does NOT count as a bug-fix iteration)

If coverage < threshold AND uncovered paths are dead code or framework-generated:
- Quinn emits `QA→CODER COVERAGE REQUEST`:
  ```
  QA→CODER COVERAGE REQUEST
  Coverage: {actual}% vs {target}% target
  Uncovered paths: [list file:line ranges]
  Reason untestable: [dead code / unreachable branch / framework-generated]
  Request: Refactor or remove the untestable code paths
  ```
- Amelia refactors implementation to remove or expose the untestable paths.
- Quinn re-runs coverage (counts as one bug-fix iteration).

---

## Agent Handoff Signals

*Standardized output signals for reliable agent-to-agent routing. Every agent output that triggers a routing decision MUST start with one of these exact strings.*

| Signal | Emitted by | Meaning | Pipeline action |
|--------|-----------|---------|-----------------|
| `CODER DONE` | Coder (Amelia) | Implementation complete, ready for QA | Route to Quinn |
| `QA→REVIEWER APPROVAL` | QA (Quinn) | All gates green, coverage met | Route to Reviewer (and Stress in parallel) |
| `QA→CODER BUG REPORT` | QA (Quinn) | Gate failed — implementation bug | Route to Amelia (count iteration) |
| `QA→CODER COVERAGE REQUEST` | QA (Quinn) | Coverage below threshold, implementation refactor needed | Route to Amelia (count iteration) |
| `QA ESCALATION` | QA (Quinn) | 3 iterations failed | Route to Reviewer with FAIL status |
| `BUGFIX COMPLETE` | Coder (Amelia) | Bug fix applied after QA report | Quinn re-runs gates |
| `COVERAGE REFACTOR COMPLETE` | Coder (Amelia) | Untestable code refactored after coverage request | Quinn re-runs coverage gate |
| `TUNER REQUEST` | Reviewer / StressTester | Score ≥ 7, MINOR/NIT only | Route to Tyler (Tuner) |
| `TUNER COMPLETE` | Tuner (Tyler) | Tuning done, re-score | Reviewer re-scores changed files only |
| `CODE REVIEW GATE PASSED` | code-review-gate skill | Gates + Reviewer both pass | Safe to push / open PR |
