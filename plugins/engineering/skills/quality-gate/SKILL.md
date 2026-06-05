---
name: quality-gate
description: Use when you need to verify code is shippable. Detects the project stack, runs format + lint + type-check + tests + vuln scan in the correct order, and reports PASS/FAIL per gate. All gates must pass before any handoff. Trigger phrases: "quality gate", "run gates", "CI check", "lint", "coverage", "run tests", "check before PR".
---

Detect the project stack, run every gate for that stack, report PASS/FAIL. All gates must pass before handoff.

## Stack Detection

```bash
find . -maxdepth 2 -name "go.mod" -o -name "Cargo.toml" -o -name "pom.xml" \
  -o -name "build.gradle" -o -name "package.json" -o -name "composer.json" \
  -o -name "tsconfig.json" -o -name "pubspec.yaml" 2>/dev/null
```

Stop at first match per stack. Multi-language monorepos run all matched stacks.

| File | Stack |
|------|-------|
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml` / `build.gradle*` | Java |
| `package.json` + `tsconfig.json` + `next.config.*` | Next.js |
| `package.json` + `tsconfig.json` + `"react"` in deps | React |
| `package.json` + `tsconfig.json` | TypeScript |
| `composer.json` | PHP |
| `pubspec.yaml` | Flutter |
| `build.gradle.kts` + `android {}` | Kotlin Android |

For gate commands per stack, see `references/quality-gate-reference.md`.

## Execution Order (fail-fast by default)

1. Format check *(fastest)*
2. Type check / vet / static analysis
3. Lint
4. Tests + coverage
5. Race detector *(Go only)*
6. Vulnerability scan *(network — run last)*

## Output

```
## Quality Gate Report — {Stack}

| Gate     | Status  | Details                               |
|----------|---------|---------------------------------------|
| vet      | ✅ PASS | —                                     |
| lint     | ❌ FAIL | handler.go:42 — unhandled error       |
| coverage | ✅ PASS | 87.3% (≥ 85%)                        |

Overall: ❌ FAIL — 1 gate failed. Fix before handoff.
```

Full pass: `Overall: ✅ PASS — all gates green · {X}% coverage · {N} tests`

For common fixes per gate failure, see `references/quality-gate-reference.md`.
