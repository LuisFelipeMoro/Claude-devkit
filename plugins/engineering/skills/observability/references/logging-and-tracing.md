# Structured Logging and OpenTelemetry Tracing

## Structured logging — Go (zap)

```go
// Initialize once at startup; pass logger via context or dependency injection
logger, _ := zap.NewProduction()
defer logger.Sync()

// Required fields on every log entry at service boundary
logger.Error("failed to process order",
    zap.String("request_id", requestID),
    zap.String("trace_id", traceID),
    zap.String("order_id", orderID),
    zap.Error(err),
)
```

Rules:
- Production: `zap.NewProduction()` (JSON output)
- Never log PII, secrets, tokens, card data
- Always include `request_id` + `trace_id` on error entries
- Error level only in production paths — no `Info`/`Debug` in hot paths

## Structured logging — TypeScript (pino)

```typescript
import pino from 'pino'

const logger = pino({
  level: process.env.LOG_LEVEL ?? 'error',
  formatters: { level: (label) => ({ level: label }) },
})

logger.error({ requestId, traceId, orderId, err }, 'failed to process order')
```

## OpenTelemetry tracing — Go

```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
)

func ProcessOrder(ctx context.Context, orderID string) error {
    ctx, span := otel.Tracer("service-name").Start(ctx, "ProcessOrder")
    defer span.End()

    span.SetAttributes(attribute.String("order.id", orderID))

    if err := doWork(ctx); err != nil {
        span.RecordError(err)
        return fmt.Errorf("processing order %s: %w", orderID, err)
    }
    return nil
}
```

## OpenTelemetry tracing — TypeScript

```typescript
import { trace, SpanStatusCode } from '@opentelemetry/api'

const tracer = trace.getTracer('service-name')

async function processOrder(orderId: string): Promise<void> {
  return tracer.startActiveSpan('processOrder', async (span) => {
    span.setAttribute('order.id', orderId)
    try {
      await doWork()
    } catch (err) {
      span.recordException(err as Error)
      span.setStatus({ code: SpanStatusCode.ERROR })
      throw err
    } finally {
      span.end()
    }
  })
}
```

## Context propagation — Go

Thread `context.Context` through the call chain. Extract trace/request IDs from context for log fields:

```go
func requestIDFromContext(ctx context.Context) string {
    if id, ok := ctx.Value(requestIDKey{}).(string); ok {
        return id
    }
    return ""
}
```
