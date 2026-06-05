---
name: performance-profiling
description: Use when investigating performance issues in Go services. Covers pprof setup, profile capture, analysis workflow, and common optimizations.
---

## Step 1 — Enable pprof Endpoint

Add to your service's HTTP setup (separate port, never expose on public port):

```go
import _ "net/http/pprof"
import "net/http"

// In main() or server setup — internal port only
go func() {
    if err := http.ListenAndServe("localhost:6060", nil); err != nil {
        logger.Error("pprof server failed", zap.Error(err))
    }
}()
```

Verify: `curl -s http://localhost:6060/debug/pprof/`

## Step 2 — Capture Profiles

```bash
# CPU profile — 30 seconds of CPU usage
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30

# Memory (heap) profile
go tool pprof http://localhost:6060/debug/pprof/heap

# Goroutine profile — detect goroutine leaks
go tool pprof http://localhost:6060/debug/pprof/goroutine

# Block profile — contention on mutexes/channels
go tool pprof http://localhost:6060/debug/pprof/block

# Mutex profile
go tool pprof http://localhost:6060/debug/pprof/mutex
```

## Step 3 — Analyse in pprof Interactive Shell

```
(pprof) top10          # top 10 functions by CPU/memory
(pprof) top10 -cum     # cumulative — includes callees
(pprof) list FuncName  # annotated source for a specific function
(pprof) web            # open flame graph in browser (requires graphviz)
(pprof) svg > out.svg  # export flame graph
```

Read the flame graph:
- Wide bars = time spent in that function
- Tall stacks = deep call chains
- Focus on the widest bars at the top of the flame

## Step 4 — Common Go Performance Issues and Fixes

| Symptom | Cause | Fix |
|---------|-------|-----|
| High allocs in `encoding/json` | Repeated marshal/unmarshal of large structs | Use `json.Encoder`/`Decoder` on streams; cache decoded structs |
| GC pressure (many small allocs) | Frequent `[]byte` or `string` allocations | Use `sync.Pool`; prefer `strings.Builder`; avoid `fmt.Sprintf` in hot path |
| Lock contention on mutex | Shared state under high concurrency | Shard the mutex; use `sync/atomic` for counters; use channels |
| Goroutine leak | goroutine started but never exits | Always use context cancellation; use `errgroup`; check goroutine profile |
| Slow DB queries | Missing index, N+1 queries | Add index; batch queries; use `EXPLAIN ANALYZE` |
| High `runtime.mallocgc` | Excessive heap allocations | Escape analysis: `go build -gcflags="-m" ./...` to see what escapes |

## Step 5 — Benchmark Before/After

Always write a benchmark to confirm improvement:

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

## Step 6 — Continuous Profiling (production)

For production visibility, consider [Pyroscope](https://pyroscope.io) (open source) or Google Cloud Profiler:

```go
import "github.com/grafana/pyroscope-go"

pyroscope.Start(pyroscope.Config{
    ApplicationName: "my-service",
    ServerAddress:   "http://pyroscope:4040",
    ProfileTypes: []pyroscope.ProfileType{
        pyroscope.ProfileCPU,
        pyroscope.ProfileAllocObjects,
        pyroscope.ProfileAllocSpace,
    },
})
```
