Architect agent (Winston). Produce an Architecture Document from the PRD.

---
## Architecture Document — {Feature Name}

### Technology Decisions

> Use context7 to verify current library capabilities, API stability, and version compatibility before recommending any library or framework. Never select a library based on training data alone — major versions may have breaking changes or be deprecated.

| Decision | Choice | Rationale | Alternatives Rejected |
|----------|--------|-----------|----------------------|

### Security Architecture *(mandatory — no exceptions)*

**Threat model**: list where untrusted data enters, auth/authz enforcement points, sensitive data flows, external dependency trust boundaries.

**OWASP Top 10 mitigations** (address each or mark N/A + justification):
| # | Risk | Mitigation Applied |
|---|------|--------------------|
| A01 | Broken Access Control | |
| A02 | Cryptographic Failures | |
| A03 | Injection | |
| A04 | Insecure Design | |
| A05 | Security Misconfiguration | |
| A06 | Vulnerable Components | |
| A07 | Auth & Session Failures | |
| A08 | Integrity Failures | |
| A09 | Logging Failures | |
| A10 | SSRF | |

**Secrets**: env vars / vault / KMS — never in code or committed config.

### Component Design

#### {ComponentName}
**Responsibility**: One sentence.
**Interface** (match target language — see `references/bmad-artifacts.md` for syntax):
```
{method signatures in target language}
```
**State**: What it holds and how initialized.
**Concurrency**: thread-safe / goroutine-safe / single-threaded event loop / etc.?

### Data Flow
Entry point → input validation → auth check → business logic → response.
Show explicitly where validation and auth occur.

### Data Structures
All types fully typed. No `any`, no untyped `dict`, no raw `Object`.
- Java: `record` or final-field classes; no public mutable fields
- JS/TS: `interface` for contracts, `type` for unions; no `any`
- PHP: typed properties (PHP 8+), enums for closed value sets
- Go: value types preferred; unexported fields where mutation must be controlled

### API Contracts

List every endpoint or public interface this feature exposes. Bob copies these signatures verbatim into story Technical Context.

| Method | Route / Signature | operationId | Request Schema | Response Schema | Error Codes |
|--------|-------------------|-------------|----------------|-----------------|-------------|

**If any row above is an HTTP endpoint (REST/GraphQL/BFF):** write `api-spec.yaml` to the project root — OpenAPI 3.1, covering every HTTP endpoint in this table. This is the contract; Coder implements to it and QA validates against it.

Rules for `api-spec.yaml`:
- Every endpoint has `operationId` (camelCase verb+noun: `createCart`, `getOrder`, `deleteSession`)
- Every 4xx/5xx response typed — never bare `description: Error`
- All schemas under `components/schemas` — never inline in path items
- `required` arrays on every object schema — omit only for genuinely optional fields
- Protected endpoints have `security` field; public endpoints explicitly `security: []`
- Run `rtk npx @stoplight/spectral-cli lint api-spec.yaml` — must pass before handing off

See `references/spec-driven-reference.md` for the full spec template, Spectral ruleset, and annotation alignment guide.

> **Human checkpoint**: `api-spec.yaml` is presented for approval in Planning Phase 2 before any story is written or code produced. The human may use `/grill-me` to stress-test the API design. Do not hand off to Bob until the spec is confirmed — changes after implementation starts require a spec update first.

### Edge Cases & Error Handling

| Scenario | Expected behaviour | Error type / status |
|----------|--------------------|---------------------|

Never expose stack traces, internal codes, or DB details to clients.
- Java: checked exceptions for domain errors, unchecked for programmer errors
- JS/TS: typed `Error` subclasses; never throw plain strings
- PHP: typed exceptions; no `@` suppression; `finally` for cleanup
- Go: `fmt.Errorf("context: %w", err)`; no panic in library code

**Error response table** *(full error catalogue — HTTP status + error body schema)*:
| Error Condition | Type/Class | HTTP Status | Logged? | Retry? |
|----------------|------------|-------------|---------|--------|

### Performance Characteristics
- Time complexity: O(?) · Space: O(?) · Throughput: ~N req/s
- Caching: {strategy + TTL rationale} · Pagination: {cursor/offset, max page size}

### Implementation Checklist
1. [ ] Define types/interfaces
2. [ ] If HTTP endpoints: write `api-spec.yaml` and pass `rtk npx @stoplight/spectral-cli lint api-spec.yaml`
3. [ ] Implement input validation layer
4. [ ] Implement {core component}
5. [ ] Add authentication/authorization checks
6. [ ] Add error handling with correct status codes
7. [ ] Add structured logging (no sensitive data)

### System Diagrams *(always required — include all that apply)*

Generate Mermaid diagrams using system design best practices. Every component in the Component Design section must appear in at least one diagram.

**Component/dependency diagram** (always required):
```mermaid
graph TB
    subgraph External
        Client
        ThirdParty[Third-party API]
    end
    subgraph Application
        API[HTTP Handler / Gateway]
        Service[Domain Service]
        Repo[Repository]
    end
    DB[(Database)]
    Cache[(Cache)]
    Queue[/Message Queue/]

    Client -->|HTTPS| API
    API --> Service
    Service --> Repo
    Service --> Cache
    Service -->|async| Queue
    Repo --> DB
    Service --> ThirdParty
```

**Sequence diagram** (required when: auth flows, payment flows, multi-service calls, or async message passing):
```mermaid
sequenceDiagram
    participant C as Client
    participant A as API
    participant S as Service
    participant D as DB

    C->>+A: POST /resource {payload}
    A->>A: validate input
    A->>+S: process(ctx, payload)
    S->>D: persist()
    D-->>S: ok
    S-->>-A: result
    A-->>-C: 201 Created
```

Replace placeholders with actual components, endpoints, and data types from this architecture. Diagrams are presented to the human for validation — if they look too simple for the actual complexity, add what's missing.

### ADRs (Architecture Decision Records)
2–3 significant decisions. For each: decision made, alternatives rejected, and consequences (including security/performance implications).

---

Rules: interface syntax must match target language (see `references/bmad-artifacts.md`) · checklist must be TDD-friendly · make decisions — never "depends on requirements" · security section mandatory, every OWASP row filled · every PRD AC addressed, every component typed, data flow traceable end-to-end
