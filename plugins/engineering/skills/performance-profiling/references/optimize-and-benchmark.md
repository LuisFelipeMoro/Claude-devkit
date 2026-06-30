# Characterization Test, Common Fixes, Benchmark

## Lock behaviour first (characterization test, RED-safe)

Optimization must not change behaviour. Before touching any code, ensure a test pins the current observable output for the hot path — if one doesn't exist, write it (it passes against current code; it goes RED the moment an optimization breaks correctness). Then add the benchmark below as the *performance* assertion. Only optimize with both in place; the characterization test stays GREEN through every change.

```go
func TestProcessOrder_BehaviourUnchanged(t *testing.T) {
    got := ProcessOrder(ctx, "order-123")     // locks correct output
    require.Equal(t, wantResult, got)          // must stay GREEN through the optimization
}
```

## Common Go performance issues and fixes

| Symptom | Cause | Fix |
|---------|-------|-----|
| High allocs in `encoding/json` | Repeated marshal/unmarshal of large structs | Use `json.Encoder`/`Decoder` on streams; cache decoded structs |
| GC pressure (many small allocs) | Frequent `[]byte` or `string` allocations | Use `sync.Pool`; prefer `strings.Builder`; avoid `fmt.Sprintf` in hot path |
| Lock contention on mutex | Shared state under high concurrency | Shard the mutex; use `sync/atomic` for counters; use channels |
| Goroutine leak | goroutine started but never exits | Always use context cancellation; use `errgroup`; check goroutine profile |
| Slow DB queries | Missing index, N+1 queries | Add index; batch queries; use `EXPLAIN ANALYZE` |
| High `runtime.mallocgc` | Excessive heap allocations | Escape analysis: `go build -gcflags="-m" ./...` to see what escapes |

## Benchmark before/after

The benchmark is the performance assertion that pairs with the characterization test. Always write it to confirm improvement (and guard against regression):

```go
func BenchmarkProcessOrder(b *testing.B) {
    // setup
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        ProcessOrder(ctx, "order-123")
    }
}
```

```bash
go test -bench=BenchmarkProcessOrder -benchmem -count=5 ./...
# Before: ns/op, B/op, allocs/op
# After:  ns/op, B/op, allocs/op
```

Report: include before/after numbers in the PR description.
