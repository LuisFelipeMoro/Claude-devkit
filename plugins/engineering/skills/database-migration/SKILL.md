---
name: database-migration
description: Write or review a database migration safely with additive-only forward changes, a mandatory reversible down migration, zero-downtime patterns for large tables, and lock-acquisition analysis. Trigger phrases — "migration", "schema change", "add column", "alter table", "add index", "backfill", "drop column", "rename column".
---

A migration must be additive-only in one file, must ship a down migration that fully reverses the up, and must never drop-and-replace or rename a column directly. Any DDL on a table over 1M rows must carry a lock strategy.

## Contract
- Input: a requested schema change against a known database.
- Output: an up/down migration pair plus a migration test, following the patterns in `references/migration-patterns.md`.
- Tool boundary: schema-only changes; expand-contract spreads risky changes across separate deploys, never one file.
- Done when: the migration test goes RED before the SQL exists, then GREEN, and the pre-handoff checklist passes.

## Steps
1. Classify the change against the risk table in `references/migration-patterns.md` to pick a strategy.
2. Write the migration test first and observe it RED — the column, index, or constraint does not exist yet. The four assertions and a worked example live in `references/test-and-checklist.md`.
3. Write the up/down SQL from the matching template in `references/migration-patterns.md`, then re-run the test to GREEN.
4. For large tables, apply `CONCURRENTLY` or an explicit session lock timeout per `references/migration-patterns.md`.
5. Confirm the pre-handoff checklist in `references/test-and-checklist.md` before handing off.

## References
- `references/migration-patterns.md` — principles, change-classification table, up/down templates, large-table and lock-timeout patterns.
- `references/test-and-checklist.md` — RED-first migration test, the four assertions, and the pre-handoff checklist.
