# PR Review Output & Posting Templates

## Step 1 — Fetch the PR diff

```bash
gh pr diff <PR_NUMBER>                                              # full diff
gh pr view <PR_NUMBER> --json title,body,baseRefName,headRefName    # metadata
gh pr checks <PR_NUMBER>                                            # CI status
gh pr list --state open                                            # if PR number unknown — pick current branch
```

## Finding line format

One finding per line: `path:line: <emoji> <SEVERITY>: [optional OWASP tag] message. Suggested fix.`

```text
path/to/file.go:42: 🔴 CRITICAL: [OWASP A03] SQL query built by string concat. Use parameterized query.
path/to/handler.go:17: 🟠 HIGH: Error returned without context wrap. Use fmt.Errorf("doing X: %w", err).
path/to/service.ts:88: 🟡 MEDIUM: No zod schema at HTTP boundary — raw req.body used directly.
path/to/util.go:5: 🔵 LOW: Commented-out code. Remove it.
```

Severity key: 🔴 CRITICAL · 🟠 HIGH · 🟡 MEDIUM · 🔵 LOW · ℹ️ INFO

## Posting a finding as an inline comment

```bash
gh pr review <PR_NUMBER> --comment --body "$(cat <<'EOF'
**[SEVERITY]** [description]

[explanation of why this is a problem]

Suggested fix:
\`\`\`go
// corrected code
\`\`\`
EOF
)"
```

## Setting the review verdict

```bash
# CRITICAL findings present:
gh pr review <PR_NUMBER> --request-changes --body "..."
# Non-blocking findings only:
gh pr review <PR_NUMBER> --comment --body "..."
# Clean PR:
gh pr review <PR_NUMBER> --approve --body "LGTM — no issues found."
```

## Summary block (printed last)

```text
PR #N Review Summary
CRITICAL: X  HIGH: Y  MEDIUM: Z  LOW: W
Action: [REQUEST CHANGES | APPROVED | COMMENTED]
```
