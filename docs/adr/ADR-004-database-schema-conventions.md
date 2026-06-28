# ADR-004: Database Schema Conventions

## Status

Proposed

## Context

We need consistent rules for how tables, columns, indexes, and relationships are defined in the multi-tenant database.

## Decision

We follow these conventions:

### Table names

- Use plural, snake_case names: `users`, `profiles`, `tags`, `cart_items`.
- Junction tables use `has`: `user_has_tags`, `user_has_roles`.

### Required columns

Every tenant-scoped table must include:

- `id`: primary key (UUID or serial, depending on table).
- `tenant_id`: UUID or text referencing `tenants.id`.
- `created_at`: TIMESTAMPTZ DEFAULT NOW().
- `updated_at`: TIMESTAMPTZ DEFAULT NOW().

### Tenant isolation

- Every tenant-scoped table must have a `tenant_id` column.
- Every query must filter by `tenant_id`.
- Foreign keys to tenant-scoped tables must include `tenant_id`.
- Supabase RLS policies must enforce `tenant_id` filtering.

### Indexes

- Index every foreign key.
- Index every column used in `WHERE`, `ORDER BY`, or `JOIN`.
- Index `tenant_id` on every tenant-scoped table.

### Soft deletes

- Use `deleted_at` columns for soft deletes where history matters.
- Hard deletes are allowed only for lookup tables or admin operations.

### Migrations

- All schema changes are SQL migrations in `supabase/migrations/`.
- Migrations are immutable and numbered by date.
- Migrations must be reversible where possible.

## Consequences

### Positive

- Consistent schema makes the codebase easier to understand.
- Tenant isolation is enforced by convention.
- RLS policies are simpler to write and review.

### Negative

- Every new table requires adding `tenant_id` and indexes.
- Multi-column foreign keys (including `tenant_id`) add complexity.

## Alternatives considered

- **Schema per tenant**: better isolation, but harder migrations.
- **No strict conventions**: faster at first, but leads to inconsistency.

## Notes

- Audit tables (logs, events) may also need `tenant_id` for filtering.
- The `tenants` table itself is global and does not have a `tenant_id`.
