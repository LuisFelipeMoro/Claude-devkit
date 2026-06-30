# Scope Map and OWASP Checklists

## Step 1 — Scope map

- Entry points (HTTP endpoints, CLI, queue consumers, file uploads)
- Auth/authz boundaries
- External integrations (APIs, DBs, caches, queues)
- Secret usage (env vars, vault, credential handling)
- AI/LLM components present? → triggers the LLM Top 10 audit

## Step 2 — OWASP Web Top 10 (2025)

Emit PASS / FAIL / N/A with file:line evidence for each:

| ID | Check |
|----|-------|
| A01 Broken Access Control | All endpoints authenticated? IDOR? Privilege escalation? Admin routes guarded? |
| A02 Cryptographic Failures | Secrets in env/vault only? TLS enforced? No weak algorithms (MD5/SHA1/DES/RC4)? |
| A03 Injection | SQL parameterized? No exec with user input? Template injection? |
| A04 Insecure Design | Rate limiting? Business logic abuse paths? Threat model? |
| A05 Security Misconfiguration | Debug off? Stack traces hidden? CORS restrictive? Security headers present? |
| A06 Vulnerable Components | `govulncheck`/`npm audit` clean? Deps pinned? |
| A07 Auth Failures | Brute-force protection? Session fixation prevented? Token expiry? Refresh rotation? |
| A08 Software Integrity | Deps from trusted sources? CI tamper-resistant? |
| A09 Logging/Monitoring | Auth failures logged? No PII in logs? Anomaly detection? |
| A10 SSRF | Outbound URLs allowlisted? DNS rebinding protection? |

## Step 3 — OWASP LLM Top 10 (2025) — only when AI/LLM components are present

| ID | Check |
|----|-------|
| LLM01 Prompt Injection | User input sanitized before LLM? Instructions separated from data? Output validated before acting? |
| LLM02 Sensitive Info Disclosure | PII/secrets filterable from output? RAG corpus access-controlled? |
| LLM03 Supply Chain | Model provider audited? Version pinned? Fine-tuning data verified? |
| LLM04 Data/Model Poisoning | Fine-tuning dataset validated? Output drift monitored? |
| LLM05 Improper Output Handling | LLM output treated as untrusted? Sanitized before render/exec/SQL? |
| LLM06 Excessive Agency | Tool permissions scoped? Human-in-loop for irreversible? All actions logged? |
| LLM07 System Prompt Leakage | Security doesn't depend on prompt secrecy? Defence-in-depth applied? |
| LLM08 Vector/Embedding Weaknesses | Retrieval results validated? Access control on vector store? |
| LLM09 Misinformation | Human review gates for high-stakes? Grounded in verified sources? |
| LLM10 Unbounded Consumption | Rate limits per tenant? Token budgets enforced? Circuit breakers? |

## Step 4 — Secrets scan

Grep for hardcoded API keys, passwords, tokens, connection strings, private keys. `.env.example` must contain no real values.

## Step 5 — Auth/AuthZ deep dive

- Every authenticated route has a middleware guard?
- Authorization at resource level (not just route)?
- No IDOR — users cannot access other users' data?

## Step 6 — Input validation

- All external inputs validated before use (body, query, headers, files, path params)?
- Length limits enforced?
- Error responses safe (no stack traces, no internal paths, no raw DB errors)?
