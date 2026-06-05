#!/bin/bash
# PostToolUse hook: after git push, surface open PR review comments for Claude to address.
# Exits silently (0) if command is not a push or no open PR exists for this branch.

input=$(cat)
command=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('command', '') or d.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" <<< "$input" 2>/dev/null)

if ! echo "$command" | grep -qE '(git push|rtk git push)'; then
    exit 0
fi

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && exit 0

pr_number=$(gh pr list --head "$branch" --state open --json number --jq '.[0].number' 2>/dev/null)
[ -z "$pr_number" ] && exit 0

echo "=== PR #$pr_number open on branch '$branch' — unresolved review comments ==="
echo ""

gh pr view "$pr_number" --comments 2>/dev/null | head -100

echo ""
echo "=== Inline code review comments ==="

gh api "repos/{owner}/{repo}/pulls/$pr_number/comments" \
  --jq '.[] | select(.in_reply_to_id == null) | "[\(.path):\(.line // .original_line // "?")] @\(.user.login): \(.body)"' \
  2>/dev/null

echo ""
echo "=== ACTION REQUIRED: For each comment, fix real issues and reply, or reply explaining why no change is needed. ==="
echo "    Use: gh pr comment $pr_number --body \"...\""
