# Reference: Language Rules — Coding Standards + Review Flags

Shared reference for Coder (Amelia) and Reviewer. Load on demand. Do not pre-load.

> **TDD rule**: Amelia writes the failing test first, then the implementation that satisfies these rules. Amelia owns both test and implementation files; Quinn (QA) audits the tests but authors none. Coverage thresholds below are the floor, met by tests written test-first — never back-filled to hit a number.

> **context7 rule**: Before applying any rule that references a specific library, linter, annotation tool, or framework — fetch its current docs via context7. Rules in this file reflect known-good patterns; library APIs evolve and the current version may differ. Always verify import paths, method signatures, and config keys against live docs before writing code.

For quality gate commands, see `references/quality-gate-reference.md`.

---

## Go

### Coding Rules
`fmt.Errorf("ctx: %w", err)` — no bare `return err`; `context.Context` first param; interfaces in consumer package; no `panic` in library code; `crypto/rand` not `math/rand`; parameterized queries; `ReadTimeout`/`WriteTimeout` on `http.Server`; `defer` for cleanup; every HTTP handler must have complete `swaggo/swag` annotations (`@Summary`, `@Description`, `@Tags`, `@Accept`, `@Produce`, `@Param`, `@Success`, `@Failure`, `@Router`); request/response types must be fully-typed Go structs (no `any`, no `interface{}`); types consumed across packages must be behind an interface in the consumer package; run `swag init ./...` — zero errors before handoff.

### Linting Commands
`go vet ./...` · `staticcheck ./...` · `golangci-lint run` (with `gosec`, `errcheck`, `revive` enabled)

### Review Flags *(required linters: `go vet`, `staticcheck`, `golangci-lint` with `gosec`/`errcheck`)*
| Issue | Severity |
|-------|----------|
| `go vet` violations | MAJOR |
| bare `return err` without `fmt.Errorf("ctx: %w", err)` | MAJOR |
| `math/rand` for security randomness | CRITICAL |
| `http.Server` missing `ReadTimeout`/`WriteTimeout` | MAJOR |
| goroutine without documented owner or cancel mechanism | MAJOR |
| `panic` in library/service code | MAJOR |
| DB rows / response bodies not closed | MAJOR |
| HTTP handler missing `swaggo/swag` annotations | MAJOR |
| Swagger annotation references a type with `any` / `interface{}` field | MAJOR |
| `swag init` fails to compile (broken annotations) | BLOCK |
| New or modified endpoint not reflected in swagger docs (stale) | MAJOR |
| Cross-package request/response type not behind an interface in consumer package | MAJOR |
| `staticcheck` error | MAJOR |
| `golangci-lint` `gosec` finding | MAJOR |
| `errcheck` violation: unchecked error return | MAJOR |
| coverage < 85% | BLOCK (score ≤ 5) |

---

## Java

### Coding Rules
`record`/immutable value objects; Bean Validation (`@NotNull`, `@Size`) on inputs; JPA named params or `PreparedStatement` — no SQL concat; `Optional<T>` for nullable returns; `BCrypt`/`Argon2` for passwords; `@PreAuthorize` for authz; `try-with-resources`; `SecureRandom` not `Random`; every HTTP endpoint must have Springdoc OpenAPI annotations (`@Operation`, `@ApiResponse`, `@Parameter`, `@Tag`); request/response types as `record`/final-field classes (no raw `Object` in schema); verify `swagger-ui` renders at `/swagger-ui.html` without errors.

### Linting Commands
`checkstyle` · `SpotBugs` · `PMD` (all three must pass with zero violations at configured severity)

### Review Flags *(required linters: `checkstyle`, `SpotBugs`, `PMD`)*
| Issue | Severity |
|-------|----------|
| SQL string concatenation (not `PreparedStatement`/JPA) | CRITICAL |
| MD5/SHA1/plain text passwords | CRITICAL |
| `Random` for tokens/nonces | CRITICAL |
| Missing `@PreAuthorize` / security check on protected endpoint | CRITICAL |
| `ObjectInputStream` on untrusted data | CRITICAL |
| `catch (Exception e) {}` without rethrow or meaningful log | MAJOR |
| Missing null check / `Optional<T>` on public API | MAJOR |
| Public mutable fields on domain objects | MAJOR |
| `Closeable` not in `try-with-resources` | MAJOR |
| HTTP endpoint missing Springdoc `@Operation` / `@ApiResponse` annotations | MAJOR |
| Request/response schema uses raw `Object` instead of typed `record`/class | MAJOR |
| New or modified endpoint not reflected in swagger docs (stale) | MAJOR |
| `swagger-ui` fails to render (broken annotations or missing `springdoc` dependency) | BLOCK |
| `SpotBugs` high-severity finding | MAJOR |
| `checkstyle` violation at configured severity | MINOR |
| `PMD` violation (priority ≤ 2) | MAJOR |
| coverage < 85% | BLOCK (score ≤ 5) |

---

## JavaScript / TypeScript

### Coding Rules
`const` > `let`, never `var`; async/await; no `any`; schema-validate inputs (zod/joi/yup); no `eval()`/`innerHTML` with user data; `crypto.randomBytes` not `Math.random()` for secrets; `helmet` for HTTP headers; `httpOnly`+`secure`+`sameSite` on cookies; every HTTP handler must have OpenAPI annotations — `swagger-jsdoc` JSDoc `@swagger` blocks for Express/Fastify, or `@nestjs/swagger` decorators for NestJS; request/response types must be fully typed interfaces/classes (no `any`); run doc generation — must succeed with zero errors before handoff.

### Linting Commands
`eslint --max-warnings 0` (with `@typescript-eslint` + `eslint-plugin-security`) · `prettier --check`

### Review Flags *(required linters: `eslint` with `@typescript-eslint` + `eslint-plugin-security`, `prettier`)*
| Issue | Severity |
|-------|----------|
| `eval()` / `Function()` / `new Function()` with any input | CRITICAL |
| `innerHTML` / `document.write` / `dangerouslySetInnerHTML` with user data | CRITICAL |
| `Math.random()` for security-sensitive values | CRITICAL |
| User-controlled `require()`/`import()` path | CRITICAL |
| `unserialize` equivalent on untrusted data | CRITICAL |
| `any` on public API surface | MAJOR |
| Unhandled `Promise` rejections | MAJOR |
| Prototype pollution: deep merge / `Object.assign` on untrusted nested input | MAJOR |
| `as T` type assertion without runtime validation | MAJOR |
| Missing `httpOnly` + `secure` + `sameSite` on auth cookies | MAJOR |
| No schema validation (zod/joi/yup/class-validator) at HTTP boundary | MAJOR |
| HTTP handler missing OpenAPI annotation | MAJOR |
| `any` type used in request/response schema definition | MAJOR |
| New or modified endpoint not reflected in swagger docs (stale) | MAJOR |
| Swagger doc generation fails | BLOCK |
| `eslint` error with `@typescript-eslint` rules | MAJOR |
| `eslint-plugin-security` finding | MAJOR |
| `prettier --check` fails | MINOR |
| coverage < 85% | BLOCK (score ≤ 5) |

---

## PHP

### Coding Rules
`declare(strict_types=1)` in every file; typed properties (PHP 8+); PDO prepared statements — no `$_GET`/`$_POST` in queries; no `eval()`/`exec()`/`shell_exec()` with user data; `password_hash(PASSWORD_BCRYPT)` or `ARGON2ID`; `htmlspecialchars($v, ENT_QUOTES, 'UTF-8')` for output; `realpath()`+`open_basedir` for file paths; `random_bytes()` not `rand()`; every HTTP endpoint must have `zircote/swagger-php` PHP 8 attributes (`#[OA\Get]`/`#[OA\Post]`/etc., `#[OA\Response]`, `#[OA\Parameter]`, `#[OA\RequestBody]`); request/response schemas as typed classes (no `mixed`, no untyped `array`); run `vendor/bin/openapi src/ -o docs/openapi.yaml` — zero errors.

### Linting Commands
`phpstan analyse --level 8` · `phpcs` (PSR-12) · `php-cs-fixer check`

### Review Flags *(required linters: `phpstan` level 8, `phpcs` PSR-12, `php-cs-fixer`)*
| Issue | Severity |
|-------|----------|
| `eval()` / `system()` / `exec()` / `shell_exec()` with user input | CRITICAL |
| SQL string interpolation / concatenation instead of PDO | CRITICAL |
| `unserialize()` on untrusted input | CRITICAL |
| MD5/SHA1/plain passwords | CRITICAL |
| File path without `realpath()` + `open_basedir` check | CRITICAL |
| `rand()` / `mt_rand()` for tokens | CRITICAL |
| Missing `htmlspecialchars($v, ENT_QUOTES, 'UTF-8')` for HTML output | MAJOR |
| PHP errors exposed to client | MAJOR |
| Suppression operator `@` hiding errors | MAJOR |
| Missing `declare(strict_types=1)` | MINOR |
| Missing type declarations on public API (PHP 8+) | MINOR |
| HTTP endpoint missing `zircote/swagger-php` attributes | MAJOR |
| Request/response schema uses `mixed` or untyped `array` | MAJOR |
| New or modified endpoint not reflected in swagger docs (stale) | MAJOR |
| `vendor/bin/openapi` fails to compile | BLOCK |
| `phpstan` error at level 8 | MAJOR |
| `phpcs` PSR-12 violation | MINOR |
| `php-cs-fixer check` fails | MINOR |
| coverage < 80% | BLOCK (score ≤ 5) |

---

## Rust

### Coding Rules
No `unwrap()` in prod — use `?` or `match`; ownership over clone; `thiserror` for domain errors; every HTTP handler must have `utoipa` annotations (`#[utoipa::path(...)]`); request/response types must derive `#[derive(utoipa::ToSchema)]`; the `#[derive(OpenApi)]` struct must compile and `openapi().to_pretty_json()` must succeed.

### Linting Commands
`cargo clippy -- -D warnings` · `cargo fmt --check` · `cargo audit`

### Review Flags *(required linters: `cargo clippy -- -D warnings`, `cargo fmt --check`, `cargo audit`)*
| Issue | Severity |
|-------|----------|
| `unwrap()` / `expect()` in production code (not tests) | MAJOR |
| `panic!()` in library code | MAJOR |
| `clone()` where ownership transfer is possible | MINOR |
| Missing `thiserror` — plain strings or `Box<dyn Error>` for domain errors | MAJOR |
| HTTP handler missing `#[utoipa::path(...)]` annotation | MAJOR |
| Request/response type missing `#[derive(utoipa::ToSchema)]` | MAJOR |
| `#[derive(OpenApi)]` fails to compile or `openapi().to_pretty_json()` errors | BLOCK |
| New or modified endpoint not reflected in swagger docs (stale) | MAJOR |
| `cargo clippy -- -D warnings` finding | MAJOR |
| `cargo audit` — known CVE in dependency | MAJOR |
| `cargo fmt --check` fails | MINOR |
| coverage < 85% | BLOCK (score ≤ 5) |

---

## React

### Coding Rules
Functional components + hooks only; `eslint-plugin-react-hooks` zero violations; `@testing-library/react` for tests (no Enzyme); `eslint-plugin-jsx-a11y` zero warnings; no `dangerouslySetInnerHTML` with user data — sanitize via `DOMPurify`; Tailwind utility classes if `tailwind.config.*` present; `memo`/`useCallback`/`useMemo` only when profiled; `crypto.randomUUID()` not `Math.random()` for IDs.

### Linting Commands
`eslint --max-warnings 0` (with `eslint-plugin-react-hooks`, `eslint-plugin-jsx-a11y`, `eslint-plugin-tailwindcss` if Tailwind present) · `prettier --check` · `tsc --noEmit`

### Review Flags *(required linters: `eslint-plugin-react-hooks`, `eslint-plugin-jsx-a11y`, `prettier`, `tsc --noEmit`)*
| Issue | Severity |
|-------|----------|
| `dangerouslySetInnerHTML` with user data — no `DOMPurify` | CRITICAL |
| `eslint-plugin-react-hooks` violations (missing deps, conditional hooks) | MAJOR |
| State mutation — direct array push or object property assignment | MAJOR |
| Missing error boundary around async/suspense subtrees | MAJOR |
| `Math.random()` for keys or IDs — use `crypto.randomUUID()` | MAJOR |
| Class components in new code | MINOR |
| Missing `eslint-plugin-jsx-a11y` zero-warning requirement | MINOR |
| Non-semantic HTML (`div onClick` instead of `button`) | MINOR |
| `useMemo`/`useCallback`/`memo` added without profiling evidence | MINOR |
| Tailwind arbitrary values (e.g. `w-[347px]`) without justification | MINOR |
| Missing loading/error state for async data | MINOR |
| coverage < 85% | BLOCK (score ≤ 5) |

---

## Flutter

### Coding Rules
Dart 3+ sound null safety — no `!` operator; `const` constructors everywhere possible; no `BuildContext` across async gaps (check `mounted`); Riverpod/BLoC/Provider — document choice; `flutter analyze` zero errors; `dart format --set-exit-if-changed`; no hardcoded secrets; `flutter_secure_storage` for sensitive data; `flutter test` unit + widget; `integration_test` for E2E.

### Linting Commands
`flutter analyze` (zero errors/warnings) · `dart format --set-exit-if-changed`

### Review Flags *(required linters: `flutter analyze`, `dart format --set-exit-if-changed`)*
| Issue | Severity |
|-------|----------|
| Hardcoded API keys or secrets in Dart source or assets | CRITICAL |
| `BuildContext` used after `await` without `mounted` check | CRITICAL |
| `flutter_secure_storage` not used for tokens/passwords | MAJOR |
| `!` (null-check operator) without flow-proven justification | MAJOR |
| Expensive computation inside `build()` method | MAJOR |
| Stateful logic in UI layer (should be in ViewModel/BLoC/Provider) | MAJOR |
| Missing `flutter analyze` passing (zero errors/warnings) | MAJOR |
| Missing `const` on constructors/widgets that could be const | MINOR |
| Missing `integration_test` for at least one user-facing flow | MINOR |
| coverage < 80% | BLOCK (score ≤ 5) |

---

## HTMX

### Coding Rules
Server returns HTML fragments not JSON; CSRF verified server-side via `HX-Request` header; all server-rendered user content HTML-encoded; strict CSP (no `unsafe-inline`); semantic HTML only — no div-soup; no inline `<script>` or `onclick`; ARIA live regions for dynamic swap targets; Tailwind utility classes if `tailwind.config.*` present.

### Review Flags
| Issue | Severity |
|-------|----------|
| Server-rendered user content not HTML-encoded | CRITICAL |
| Missing `HX-Request` header check server-side (CSRF vector) | CRITICAL |
| Inline `<script>` or `onclick` handler (CSP violation) | MAJOR |
| Non-semantic HTML (div-soup, missing landmarks) | MINOR |
| Missing ARIA live region on `hx-swap` target | MINOR |
| `hx-trigger` without debounce/throttle on high-frequency events | MINOR |
| Missing `hx-indicator` on slow server responses | MINOR |

---

## Kotlin Android

### Coding Rules
No `!!` operator; no `GlobalScope` — use `viewModelScope`/`lifecycleScope`; MVVM or MVI architecture; no logic in Activity/Fragment; JUnit5 + MockK for unit tests; `detekt` + `ktlint` + Android Lint zero warnings; no hardcoded secrets; `EncryptedSharedPreferences` for sensitive data; `build.gradle.kts` only (Kotlin DSL); version catalog (`libs.versions.toml`).

### Linting Commands
`./gradlew detekt` (zero violations) · `ktlint --reporter plain` (zero) · `./gradlew lint` (zero errors)

### Review Flags *(required linters: `detekt`, `ktlint`, `./gradlew lint`)*
| Issue | Severity |
|-------|----------|
| `GlobalScope` usage — use `viewModelScope`/`lifecycleScope` | CRITICAL |
| Blocking main thread (`runBlocking` on UI thread) | CRITICAL |
| Hardcoded credentials in `strings.xml` or Kotlin source | CRITICAL |
| `!!` operator without documented justification | MAJOR |
| Business logic in Activity/Fragment (should be in ViewModel) | MAJOR |
| Missing `EncryptedSharedPreferences` for sensitive local storage | MAJOR |
| `SharedPreferences` for auth tokens | MAJOR |
| Missing `detekt` passing (zero violations) | MAJOR |
| Groovy DSL in `build.gradle` (use Kotlin DSL `.kts`) | MINOR |
| Missing version catalog (`libs.versions.toml`) | MINOR |
| coverage < 85% | BLOCK (score ≤ 5) |

---

## HTML / CSS

### Coding Rules
Semantic HTML — `<section>`, `<article>`, `<nav>`, `<main>`, `<header>`, `<footer>`, `<aside>`; `lang` on `<html>`; `alt` on every `<img>`; `<label>` for every `<input>`; no `style=""` attributes; **Tailwind preferred** — utility classes with `eslint-plugin-tailwindcss` class-order; no arbitrary values without justification; if vanilla CSS: BEM or CSS Modules; CSS custom properties for tokens; no `!important`; max 3 nesting levels; animations only `transform`/`opacity`; mobile-first responsive (`min-width` breakpoints); `stylelint` zero warnings; HTML passes `htmlhint` zero errors.

### Linting Commands
`htmlhint` (zero errors) · `stylelint --config stylelint-config-standard` (zero warnings) · `eslint-plugin-tailwindcss` (if Tailwind present)

### Review Flags *(required linters: `htmlhint`, `stylelint`; `eslint-plugin-tailwindcss` if Tailwind present)*
| Issue | Severity |
|-------|----------|
| Non-semantic HTML (div-soup, missing landmark elements) | MAJOR |
| Missing `alt` on `<img>` element | MAJOR |
| Missing `<label>` for `<input>` element | MAJOR |
| Missing `lang` attribute on `<html>` element | MINOR |
| Inline `style=""` attribute (use utility classes or stylesheet) | MINOR |
| `!important` in CSS without documented justification | MINOR |
| CSS nesting deeper than 3 levels | MINOR |
| Tailwind arbitrary value (e.g. `w-[347px]`) without justification | MINOR |
| Animation on layout-triggering property (use `transform`/`opacity`) | MINOR |
| Fixed-width layout — not responsive (`min-width` breakpoints required) | MAJOR |
| `htmlhint` error | MAJOR |
| `stylelint` warning | MINOR |
