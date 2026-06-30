---
name: observability
description: Add structured logging, metrics, or distributed tracing to a service, covering Go (zap + OpenTelemetry) and TypeScript (pino + OpenTelemetry) with enforced log-field standards and trace-context propagation. Trigger phrases — "logging", "metrics", "tracing", "observability", "instrument", "OpenTelemetry", "structured logs", "monitoring".
---

Instrumentation is behaviour: a failing test asserting the log fields or span comes first (RED), then the instrumentation. Every error log must carry `request_id` + `trace_id`, and PII, secrets, and tokens must never appear in any field.

## Contract
- Input: a Go or TypeScript service that needs logging, metrics, or tracing.
- Output: instrumentation plus a RED-first test, matching the field standards and code in `references/logging-and-tracing.md`.
- Tool boundary: the contract under test is field presence, absent secrets, and span name/attributes — never exact log formatting.
- Done when: the assert-first test passes and the checklist in `references/test-first-and-checklist.md` holds.

## Steps
1. Scope the work: logging only, or metrics + tracing too? Go or TypeScript (or both)? Greenfield, or extending existing instrumentation?
2. Assert it first (RED): a failing test for the intended fields/span against an in-memory sink, per `references/test-first-and-checklist.md`.
3. Add structured logging from `references/logging-and-tracing.md` — Go zap or TypeScript pino, with the required fields and the no-PII rules.
4. Add OpenTelemetry tracing from `references/logging-and-tracing.md` — a span around each outbound request, `RecordError` before returning, `defer span.End()`.
5. Propagate `context.Context` through the request chain (Go) per `references/logging-and-tracing.md`, then confirm the checklist.

## References
- `references/logging-and-tracing.md` — Go/TS logging, OpenTelemetry tracing, context propagation, field rules.
- `references/test-first-and-checklist.md` — the RED assert-first test and the completion checklist.
