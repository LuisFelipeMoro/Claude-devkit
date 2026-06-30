# Migration Test (RED first) and Pre-Handoff Checklist

## Write the migration test first (RED)

Before writing any migration SQL, write a test that drives it. Run it — it must FAIL (the column/index/constraint does not exist yet). This is the RED step.

The test asserts, against a throwaway database seeded to production-like shape (Testcontainers, an ephemeral schema, or a transaction rolled back at teardown):

1. **Up applies**: after running the `up` migration, the new schema state exists (column/index/constraint present, type correct, nullability correct).
2. **Down reverses**: after running the `down` migration, the schema is byte-for-byte back to the prior state (no orphan objects).
3. **Idempotency**: running `up` twice does not error (the `IF NOT EXISTS` / `IF EXISTS` guards hold).
4. **Data safety** (when backfilling): existing rows get the expected values; no row is lost or corrupted.

```go
// migration_0042_test.go — written BEFORE 0042_add_external_ref.sql
func TestMigration0042_UpAddsColumn_DownRemovesIt(t *testing.T) {
    db := newEphemeralDB(t)            // Testcontainers / template DB
    require.NoError(t, migrateUp(db, 42))
    require.True(t, columnExists(db, "orders", "external_ref"))  // RED until SQL written
    require.NoError(t, migrateDown(db, 42))
    require.False(t, columnExists(db, "orders", "external_ref"))
}
```

Only once this test fails for the right reason do you write the SQL, then re-run to GREEN.

## Pre-handoff checklist

- [ ] Migration test was written first and observed RED before the SQL existed
- [ ] Down migration fully reverses the up migration
- [ ] No column drop and replacement in the same file
- [ ] Large table DDL uses `CONCURRENTLY` or explicit lock timeout
- [ ] Migration is idempotent (`IF NOT EXISTS` / `IF EXISTS` guards)
- [ ] Migration has been tested on a copy of prod data volume (or noted if not)
- [ ] App code is backward-compatible with both old and new schema during rollout
