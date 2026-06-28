# ADR-008: Module System

## Status

Proposed

## Context

Each tenant may need different features. Some collectives want music and events; others want a shop and blog. We need a way to enable or disable features per tenant.

## Decision

We will implement a **module system** where each tenant can enable or disable features.

### Module configuration

- Modules are defined in `tenants.config.modules` as a JSON object.
- Each module is a boolean: `true` to enable, `false` to disable.
- Example modules: `music`, `shop`, `events`, `content`, `versus`, `wallet`.

### Frontend behavior

- The frontend reads the tenant config and hides routes/links for disabled modules.
- Attempting to access a disabled module route returns a 404 or a "not available" page.

### Backend behavior

- The API Gateway checks if the module is enabled for the tenant before routing to the Core Engine.
- Core Engine endpoints assume the Gateway has validated module access.

### Database

- Module data tables are always present in the schema.
- Data for disabled modules is simply not exposed through the API.

## Consequences

### Positive

- Each tenant gets a tailored experience.
- Easier to add new modules without affecting existing tenants.
- Supports tiered pricing based on enabled modules.

### Negative

- Every module must check if it is enabled before executing.
- UI must handle missing modules gracefully.

## Alternatives considered

- **Hardcoded features per tenant**: simple, but not scalable.
- **Plugin architecture with separate code**: more flexible, but much more complex.

## Notes

- Module flags are a starting point. Later we may add per-module configuration (e.g., event categories, product types).
