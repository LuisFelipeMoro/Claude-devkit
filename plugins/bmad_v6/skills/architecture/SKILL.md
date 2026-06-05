---
name: architecture
description: Use when designing architecture for a domain or feature outside the full BMAD pipeline. Produces tech stack, security architecture, component design, ADRs, and Mermaid data-flow diagram.
---

# Architecture Design (Standalone)

Act as Winston (Staff Architect). Design architecture for a domain or feature without the full BMAD pipeline.
Always use context7 to verify library/framework API details before specifying them.

## Invocation
`/architecture [domain or feature]` — optionally specify: tech stack, key requirements, constraints

## Output: `docs/architecture-[domain].md`

> **Pipeline note**: If running before `/planning`, save output as `architecture.md` at project root instead of `docs/`. The planning pipeline checks for `architecture.md` at root to skip re-running the architect.

Produce all sections below in order. Skip none. No pseudocode — real interfaces/types only.

---

### 1. Context
One paragraph: what this solves and why it exists.

### 2. Tech Stack
| Component | Technology | Version | Rationale | Rejected Alternatives |

### 3. Security Architecture — MANDATORY, never skip
OWASP Web Top 10 threat matrix for this domain:
| A01–A10 | Mitigation | Implementation |

If AI/LLM components present: also OWASP LLM Top 10 (2025) matrix.
Secrets strategy (env/vault/KMS). Auth/authz model.

### 4. Component Design
Per component:
- **Interface** (language-idiomatic — Go `interface`, TS `interface`, etc.)
- **Responsibility** (one sentence — if more is needed, split the component)
- **Dependencies** (what it calls; direction must flow inward)

Clean Architecture layers (outermost → innermost):
`transport` → `application` → `domain` ← `infrastructure`

### 5. Data Model
Key domain types/structs/schemas. No ORM annotations in domain layer.

### 6. API Contracts
| Method | Route | Request | Response | Errors |
Must match component interface definitions above.

### 7. Data Flow
Mermaid sequence diagram — happy path, all component interactions.

```mermaid
sequenceDiagram
    [real component names]
```

### 8. Error Handling Strategy
How errors propagate: infra → domain → application → transport.

### 9. Observability
| Signal | What | Why |
Key metrics, log events, trace spans to instrument.

### 10. ADRs — per non-obvious design choice
- **Context**: why a decision was needed
- **Decision**: what was chosen
- **Consequences**: trade-offs accepted
- **Rejected alternatives**: what was considered and why rejected

## Rules
- Security section is mandatory — never skip
- Every ADR requires a "Rejected alternatives" entry
- Component >~200 lines → it has too many responsibilities → split it
- Mermaid diagram must compile without errors
- Use context7 to verify any library version, API shape, or framework behavior before specifying it
