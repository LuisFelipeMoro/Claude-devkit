# BMad v6 Artifact Schemas

Schema and handoff contracts for each BMad v6 planning artifact.

---

## Artifact Chain

```
product-brief.md → PRD.md                             ← /analysis produces up to here
     (Mary)          (John)
                       ↓
               architecture.md → [epic|task]-manifest  ← /planning produces up to here
                  (Winston)
                                         ↓
                              story-{slug}.md           ← pipeline skills produce this
                                  (Bob)
```

Coder receives only `story-{slug}.md` (architecture context embedded by Bob — see Rule 3). QA additionally receives the generated code.

---

## product-brief.md
Produced by: Mary | Consumed by: John

Required sections: Problem Statement · Target Users · Success Criteria · Scope (in/out) · Constraints & Dependencies (language/runtime) · Security Constraints (GDPR/PCI/HIPAA/SOC 2) · Key Risks & Unknowns (table: likelihood/impact) · Open Questions

---

## PRD.md
Produced by: John | Consumed by: Winston + all downstream agents

Required sections: Overview · Functional Requirements (FR-01…) · Non-Functional Requirements (table: ID, Category, Requirement, Target) · Security Acceptance Criteria (OWASP-aligned; ≥1 per epic with I/O or auth) · User Stories per epic · Out of Scope · Open Issues · Risks

Key rules: every FR ≥ 2 binary ACs · NFRs have measurable targets · ACs reference error/edge cases · security ACs mandatory for auth/input/external API epics

---

## architecture.md
Produced by: Winston | Consumed by: Bob (Scrum Master, once per epic) · Reviewer + Stress (indirectly via generated code)

Required sections: Overview · Tech Stack (table) · **Security Architecture** (threat model + OWASP Top 10 table + secrets strategy) · Component Design · Data Structures · Data Flow (show where auth checked + input validated) · API Contracts · ADRs · Edge Cases & Error Handling · NFR Notes · Implementation Checklist (TDD-friendly)

**Interface syntax by language** (use only the matching one):
| Language | Interface syntax |
|----------|-----------------|
| Java | `ReturnType methodName(ParamType p) throws DomainException;` in consumer-package interface |
| JS/TS | `methodName(p: ParamType): Promise<ReturnType>;` in `interface` block |
| PHP | `public function methodName(ParamType $p): ReturnType;` in `interface` |
| Go | `MethodName(ctx context.Context, p ParamType) (ReturnType, error)` in consumer-package interface |

**Type rules**: no `any`, no untyped `dict`, no raw `Object`. Java: `record`/final-field classes. PHP: typed properties (8+). Go: value types preferred.

---

## story-{slug}.md
Produced by: Bob | Consumed by: Amelia (PRIMARY INPUT)

Required sections: Context · Technical Context (components, interfaces in target language, types, NFR constraints, security mandates extracted from architecture) · Acceptance Criteria (PRD + technical + edge case + security ACs as checkboxes) · Implementation Notes (approach, security points, ordered steps, files, edge cases, do-nots) · Definition of Done (ACs · tests · coverage threshold · no sensitive data in logs/responses · lint clean · review ≥7 · stress ≥7)

---

## Artifact Passing Rules

1. **Within the analysis phase** (`/analysis`: Brief → PRD) and **planning phase** (`/planning`: Architecture → Manifest), each agent receives the **full text** of all prior artifacts — no summaries. The `/planning` skill reads all `/analysis` artifacts when they exist.
2. **At the Phase 1 → Phase 2 boundary**, planning artifacts are compressed into the Epic Manifest. The Manifest is the sole authoritative handoff contract for Phase 2. `architecture.md` is retained by the orchestrator and passed to the Scrum Master each epic; it is **never** passed to Coder, QA, Reviewer, or Stress. Brief and PRD are fully discarded after compression. The Manifest must carry all context downstream agents need, including the `Language` field.
3. **Within Phase 2** (per-epic loop), the story file is self-contained — the Coder receives only `story-{slug}.md`, not the full `architecture.md`. The story must embed all architecture context the Coder needs.
4. **Between epics**, code and stories are dropped. Only Architecture + Manifest + all scores are retained.
5. Story file is the **primary context** for Coder — must be self-contained.
6. Missing required section → receiving agent must flag and request before proceeding.
7. Requirement change mid-pipeline → restart from affected artifact stage.
8. Security Architecture missing from a story file → flag to the orchestrator; the Scrum Master is responsible for embedding security context. The Coder must not request architecture.md directly.
