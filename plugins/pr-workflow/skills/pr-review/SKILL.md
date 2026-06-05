---
name: pr-review
description: Use when asked to review a PR or when the post-push hook surfaces open PR comments. Produces structured review: severity-tagged findings, OWASP checklist, language-specific checks.
---

Run when: user asks to review a PR, or when `pr-review-responder.sh` hook output is present after a push.

## Step 1 — Fetch PR Diff

```bash
gh pr diff <PR_NUMBER>            # full diff
gh pr view <PR_NUMBER> --json title,body,baseRefName,headRefName
gh pr checks <PR_NUMBER>          # CI status
```

If PR number unknown: `gh pr list --state open` → pick current branch.

## Step 2 — Analyse

Check in this order:

### Security (OWASP Web Top 10 — fail any CRITICAL immediately)

> **Coverage note**: This review checks A01, A02, A03, A05, A07, A09. Missing: A04 (Insecure Design), A06 (Vulnerable Components), A08 (Software Integrity), A10 (SSRF). For a full 10-point audit run `/security-review`.
| Check | Look for |
|-------|---------|
| A01 Broken Access Control | missing authz checks, IDOR, path traversal |
| A02 Crypto Failures | hardcoded secrets, weak algorithms, HTTP not HTTPS |
| A03 Injection | SQL concat, shell exec with user data, eval() |
| A05 Security Misconfiguration | debug flags in prod, permissive CORS, missing security headers |
| A07 Auth Failures | insecure token storage, no rate limiting on auth endpoints |
| A09 Logging Failures | PII/secrets in logs, missing request_id/trace_id |

### Go Standards (if .go files changed)
- Error discards: `_ =` or `_ :=` on error returns → CRITICAL
- Bare `return err` without `fmt.Errorf` wrap → HIGH
- `panic` outside unrecoverable init → HIGH
- `interface{}` / `any` on public API → MEDIUM
- Missing `context.Context` as first param → MEDIUM
- Missing swaggo annotations on new HTTP handlers → MEDIUM

### TypeScript Standards (if .ts/.tsx files changed)
- `any` on public API or HTTP boundary → HIGH
- No zod/joi validation at HTTP boundary → HIGH
- `Math.random()` for security use → CRITICAL
- `innerHTML` with user data → CRITICAL
- Missing `@swagger`/`@ApiOperation` on new endpoints → MEDIUM

### General
- Missing tests for new code paths → HIGH
- Coverage regression (check CI checks output) → MEDIUM
- Commented-out code → LOW
- TODO/FIXME in production paths → LOW

## Step 3 — Output Format

One finding per line:

```
path/to/file.go:42: 🔴 CRITICAL: [OWASP A03] SQL query built by string concat. Use parameterized query.
path/to/handler.go:17: 🟠 HIGH: Error returned without context wrap. Use fmt.Errorf("doing X: %w", err).
path/to/service.ts:88: 🟡 MEDIUM: No zod schema at HTTP boundary — raw req.body used directly.
path/to/util.go:5: 🔵 LOW: Commented-out code. Remove it.
```

Severity key: 🔴 CRITICAL · 🟠 HIGH · 🟡 MEDIUM · 🔵 LOW · ℹ️ INFO

## Step 4 — Post Review Comments

For each finding, post as inline comment:
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

For CRITICAL findings: `gh pr review <PR_NUMBER> --request-changes --body "..."`
For findings only: `gh pr review <PR_NUMBER> --comment --body "..."`
For clean PR: `gh pr review <PR_NUMBER> --approve --body "LGTM — no issues found."`

## Step 5 — Summary

After posting comments, output:
```
PR #N Review Summary
CRITICAL: X  HIGH: Y  MEDIUM: Z  LOW: W
Action: [REQUEST CHANGES | APPROVED | COMMENTED]
```
