# pprof Setup, Capture, and Analysis

## Enable the pprof endpoint

Add to the service's HTTP setup on a separate internal port — never expose it on a public port:

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

## Capture profiles

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

## Analyse in the pprof interactive shell

```text
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

## Continuous profiling (production)

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
