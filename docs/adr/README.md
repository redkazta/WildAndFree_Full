# Architecture Decision Records (ADRs)

All significant technical decisions are recorded here.

## Format

Each ADR follows the [Nygard format](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions):

- Title
- Status (proposed, accepted, deprecated, superseded)
- Context
- Decision
- Consequences
- Alternatives considered

## Rules

- One decision per file.
- Files are numbered sequentially.
- Once accepted, an ADR is immutable. If it changes, it is superseded by a new ADR.
- ADRs are stored in version control alongside the code.

## Index

| # | Decision | Status |
|---|----------|--------|
| 001 | [Multi-tenant strategy](./ADR-001-multi-tenant-strategy.md) | Proposed |
| 002 | [Monorepo and stack](./ADR-002-monorepo-stack.md) | Proposed |
| 003 | [Auth and authorization](./ADR-003-auth-strategy.md) | Proposed |
| 004 | [Database schema conventions](./ADR-004-database-schema-conventions.md) | Proposed |
| 005 | [API contract style](./ADR-005-api-contract-style.md) | Proposed |
| 006 | [Frontend rendering strategy](./ADR-006-frontend-rendering-strategy.md) | Proposed |
| 007 | [Deployment strategy](./ADR-007-deployment-strategy.md) | Proposed |
| 008 | [Module system](./ADR-008-module-system.md) | Proposed |
