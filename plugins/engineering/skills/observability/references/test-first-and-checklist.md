# Assert-First (RED) and Checklist

## Assert it first (RED)

Instrumentation is behaviour — test it before adding it. Write a failing test that asserts the log fields / span you are about to emit, using an in-memory sink so no real backend is needed. Run it (RED), then add the instrumentation (GREEN).

```go
// Go — zaptest/observer captures emitted log entries
core, logs := observer.New(zap.ErrorLevel)
logger := zap.New(core)
processOrder(ctxWith(requestID, traceID), logger, "order-123")   // RED until instrumented
entry := logs.All()[0]
require.Equal(t, "failed to process order", entry.Message)
require.Equal(t, requestID, entry.ContextMap()["request_id"])    // assert required fields present
require.NotContains(t, entry.ContextMap(), "password")           // assert no secret leaked

// Go — tracetest.NewInMemoryExporter() asserts a span was recorded with attributes
// TS — pino: pass a stream that collects lines; assert JSON has requestId/traceId, no PII
```

Assert the **contract** (fields exist, secrets absent, span created with the right name/attributes), not exact formatting. Only after RED do you instrument.

## Checklist

- [ ] A failing test asserting the log fields / span was written first (RED) before instrumenting
- [ ] Logger initialized once at startup, injected via context or constructor
- [ ] Every error log includes `request_id` + `trace_id`
- [ ] No PII/secrets/tokens in any log field
- [ ] Spans created for every external call (DB, HTTP, queue)
- [ ] `span.RecordError(err)` called before returning errors
- [ ] Context propagated through entire call chain without breaking
- [ ] `defer span.End()` called immediately after span creation
