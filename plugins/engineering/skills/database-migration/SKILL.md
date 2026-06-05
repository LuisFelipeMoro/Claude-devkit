---
name: database-migration
description: Use when writing or reviewing a database migration. Enforces additive-only forward migrations, mandatory down migrations, zero-downtime patterns for large tables, and lock acquisition analysis.
---

## Principles (non-negotiable)

1. **Additive only in one file** — never drop a column and add its replacement in the same migration. Use expand-contract over multiple deployments.
2. **Always include a down migration** — every `up` block needs a corresponding `down` that fully reverses it.
3. **Never rename a column directly** — add new column → backfill → switch app → drop old (3 separate migrations, 3 deployments).
4. **Large tables need lock analysis** — any DDL on a table >1M rows must include a lock strategy.

## Step 1 — Classify the Change

| Change type | Risk | Strategy |
|-------------|------|----------|
| Add nullable column | Low | Direct ALTER TABLE |
| Add NOT NULL column | Medium | Add nullable → backfill → add constraint |
| Add index | Medium | `CREATE INDEX CONCURRENTLY` (PostgreSQL) |
| Drop column | High | Expand-contract — remove from app first |
| Rename column | High | Expand-contract — add + migrate + drop |
| Change column type | High | Expand-contract |
| Add foreign key | Medium | Add index first; then constraint WITH NOVALIDATE |

## Step 2 — Write the Migration

### Template (Go migrate / golang-migrate format)

```sql
-- +migrate Up
-- [description: what this migration does and why]

-- Safe: adding nullable column, no lock held
ALTER TABLE orders ADD COLUMN IF NOT EXISTS external_ref VARCHAR(64);

-- +migrate Down
ALTER TABLE orders DROP COLUMN IF EXISTS external_ref;
```

### For large tables (PostgreSQL)

```sql
-- +migrate Up
-- Add index without holding table lock
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_external_ref
  ON orders (external_ref)
  WHERE external_ref IS NOT NULL;

-- +migrate Down
DROP INDEX CONCURRENTLY IF EXISTS idx_orders_external_ref;
```

### For NOT NULL columns

```sql
-- Migration 1 of 3: add nullable
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Migration 2 of 3 (separate deploy): backfill + add default
UPDATE users SET phone = '' WHERE phone IS NULL;
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
ALTER TABLE users ALTER COLUMN phone SET DEFAULT '';

-- Migration 3 of 3 (after old code removed): drop default if unwanted
ALTER TABLE users ALTER COLUMN phone DROP DEFAULT;
```

## Step 3 — Checklist Before Handing Off

- [ ] Down migration fully reverses the up migration
- [ ] No column drop and replacement in the same file
- [ ] Large table DDL uses `CONCURRENTLY` or explicit lock timeout
- [ ] Migration is idempotent (`IF NOT EXISTS` / `IF EXISTS` guards)
- [ ] Migration has been tested on a copy of prod data volume (or noted if not)
- [ ] App code is backward-compatible with both old and new schema during rollout

## Step 4 — Lock Timeout (production safety)

Always set at the session level for non-CONCURRENTLY DDL on large tables:

```sql
SET lock_timeout = '3s';
SET statement_timeout = '60s';
ALTER TABLE large_table ADD COLUMN new_col INT;
```

If lock cannot be acquired in 3s, migration fails fast rather than blocking all queries.
