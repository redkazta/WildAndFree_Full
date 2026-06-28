# ADR-009: Single-Tenant Design

## Status

Accepted

## Context

The product is designed for established music crews with existing fanbases. Each deployment serves one crew at a time. While the platform could theoretically support multiple tenants, the primary design assumption is single-tenant.

## Decision

**Single-tenant by design.** The platform serves one crew per deployment.

- All data belongs to one crew.
- Artists are all from the same crew.
- Tags are crew-specific (not cross-tenant roles).
- The `tenant_id` column exists for future multi-tenant support but is not actively used.

## Consequences

### Positive

- Simpler queries (no need to filter by `tenant_id` everywhere).
- Simpler RLS policies.
- Easier to reason about data ownership.
- Better performance (no cross-tenant query overhead).
- Simpler ERP (one crew's orders, one crew's inventory).

### Negative

- Cannot serve multiple crews from the same deployment (by design).
- If we ever need multi-tenant, we'll need to add `tenant_id` filtering everywhere.

## Alternatives considered

- **Multi-tenant from day one**: adds complexity we don't need yet.
- **Database per crew**: overkill for single-tenant.

## Notes

- The existing `tenant_id` columns and ADR-001 remain valid for future multi-tenant support.
- If we ever need to serve multiple crews, we can enable `tenant_id` filtering without schema changes.
