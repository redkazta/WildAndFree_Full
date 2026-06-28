# ADR-007: Deployment Strategy

## Status

Proposed

## Context

The project has three deployable components: frontend (Astro), API Gateway (NestJS), and Core Engine (Go). We need a strategy for local development, staging, and production.

## Decision

### Current state

- Frontend is deployed to **Vercel**.
- API Gateway and Core Engine are not yet deployed to production.

### Target state

- **Frontend**: Vercel (same as now).
- **API Gateway**: Railway, Render, Fly.io, or a VPS.
- **Core Engine**: Railway, Render, Fly.io, or a VPS.
- **Database**: Supabase (same project for all tenants).
- **Cache**: Redis for tenant config and sessions.
- **Reverse proxy**: Caddy or Nginx for custom domains.

### Local development

- Use Docker Compose to run all services locally.
- Each developer uses a shared Supabase project or a local Supabase instance.

### Environments

- `development`: local Docker Compose.
- `staging`: Vercel preview + staging backend.
- `production`: Vercel production + production backend.

## Consequences

### Positive

- Vercel handles frontend scaling and preview deployments.
- Docker Compose simplifies onboarding.
- Redis improves performance for tenant config lookup.

### Negative

- Three services increase deployment complexity.
- Custom domain setup per tenant requires DNS management.
- Backend deploys are not yet automated.

## Alternatives considered

- **Deploy everything on Vercel (serverless functions)**: simpler, but Go backend is not natively supported.
- **Single VPS for all backend**: cheaper, but less scalable.
- **Kubernetes**: overkill at this stage.

## Notes

- CI/CD pipelines for backend deployment are a priority.
- Health checks and monitoring must be added before production.
