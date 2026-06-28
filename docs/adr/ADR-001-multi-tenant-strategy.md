# ADR-001: Multi-tenant Strategy

## Status

Proposed

## Context

Wild And Free is designed to serve multiple music collectives, each with its own brand, artists, fans, and content. We need a strategy to isolate tenants while keeping operational complexity manageable.

## Decision

We will use a **shared database with `tenant_id` columns** (single database, shared schema).

Every table that contains tenant-specific data will have a `tenant_id` column. Every query must filter by `tenant_id`. Foreign keys that reference tenant-scoped tables must include `tenant_id` for extra safety.

## Consequences

### Positive

- Simplest operational model: one Supabase project, one backup, one migration pipeline.
- Cost-effective at early stage.
- Easy to add new tenants without provisioning new infrastructure.
- Can move to schema-per-tenant or DB-per-tenant later if needed.

### Negative

- All queries must include `tenant_id`. Missing it causes cross-tenant data leaks.
- Requires discipline in migrations, indexes, and RLS policies.
- Harder to offer tenant-level data export compared to schema-per-tenant.

## Alternatives considered

- **Schema per tenant**: better isolation, but migrations are harder to run at scale.
- **Database per tenant**: maximum isolation, but expensive and hard to manage.
- **Single-tenant first**: would not meet the product vision.

## Notes

- Supabase Row Level Security (RLS) policies will enforce `tenant_id` filtering.
- The `tenant_id` is resolved by the API Gateway and passed to the Core Engine via the `X-Tenant-ID` header.
