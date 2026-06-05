#!/bin/bash
# PreToolUse hook: block reading .env / .envrc files
# Claude Code passes tool input as JSON via stdin
# Exit 2 blocks the tool call

input=$(cat)
file_path=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('file_path', '') or d.get('command', ''))
except Exception:
    print('')
" 2>/dev/null)

if echo "$file_path" | grep -qE '(^|/)\.(env)(rc|(\.[^/]+)?)?$'; then
    echo "BLOCKED: .env / .envrc files may contain production secrets — Claude must never read them."
    exit 2
fi
exit 0
