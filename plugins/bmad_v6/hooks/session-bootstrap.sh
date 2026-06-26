#!/usr/bin/env bash
# SessionStart hook — Harness "Memory & Progress" component.
# Reconstructs cross-session context: prints PROGRESS.md so a new session boots
# with what was done, what failed, and the current state — instead of starting blind.
# This hook only injects context; it never blocks. Exit code is always 0.
set -u

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
progress="$root/PROGRESS.md"

if [ -f "$progress" ]; then
    echo "=== PROGRESS.md (resume context — written by pipelines/handoff last session) ==="
    cat "$progress"
    echo "=== end PROGRESS.md ==="
else
    echo "No PROGRESS.md at repo root — fresh start. Pipelines and /handoff will create it (see references/progress-file.md)."
fi

exit 0
