# Documentation Policy

Every change that affects the system must keep the documentation in sync.

## Rule

If a code change, migration, configuration change, or architectural decision affects any of the following:

- Architecture
- API contracts
- Database schema
- Tenant behavior
- Auth / security
- Module behavior
- Deployment / infrastructure
- Local development setup

Then the relevant documentation must be updated in the same PR or commit.

## What to update

| Change affects | Update these docs |
|---|---|
| Database schema | `database/schema.md`, `database/migrations.md`, relevant module docs |
| Tenant model | `adr/ADR-001-multi-tenant-strategy.md`, `architecture.md`, `runbooks/tenant-onboarding.md` |
| Auth flow | `adr/ADR-003-auth-strategy.md`, `modules/auth.md`, `architecture.md` |
| API endpoints | `api/README.md`, `api/gateway.md`, `api/core-engine.md`, `shared-types` |
| Frontend pages | `frontend/pages.md`, `frontend/components.md` |
| Module behavior | `modules/<module>.md` |
| Deployment | `runbooks/deployment.md`, `vercel.json` comments |
| New ADR | `adr/README.md` index |
| Major decision | Create new ADR, update `adr/README.md` |

## Process

1. Make the code change.
2. Identify which docs are affected.
3. Update those docs before opening the PR.
4. Add a link to the relevant ADR if the change relates to an architectural decision.

## Immutable ADRs

ADRs are immutable once accepted. If a decision changes, create a new ADR that supersedes the old one. Never edit the body of an accepted ADR.

## New ADRs

Create an ADR for any decision that:

- Changes the architecture
- Adds a new technology
- Modifies the tenant model
- Changes the auth or security model
- Introduces a new integration
- Changes the deployment strategy

## Review checklist

Before merging any PR, verify:

- [ ] ADR index is updated if a new ADR was added.
- [ ] Module docs are updated if behavior changed.
- [ ] API docs are updated if endpoints changed.
- [ ] Database docs are updated if schema changed.
- [ ] Runbooks are updated if setup or deployment steps changed.
