# ADR-002: Monorepo and Stack

## Status

Proposed

## Context

We need a stack that is modern, scalable, and allows us to serve multiple tenants with a small team. We also want to sell the platform to collectives, so the product must look professional and be easy to deploy.

## Decision

We will use a monorepo managed by `pnpm` with the following stack:

- **Frontend**: Astro + Tailwind CSS
- **API Gateway**: NestJS + TypeScript
- **Core Engine**: Go
- **Database, Auth, and Storage**: Supabase

## Consequences

### Positive

- Astro gives fast static pages with islands of interactivity.
- NestJS provides a structured, testable gateway layer.
- Go gives a high-performance core engine for business logic.
- Supabase handles auth, Postgres, and file storage without building them from scratch.
- TypeScript types shared between frontend and gateway reduce contract drift.

### Negative

- Three runtimes (Node.js for frontend, Node.js for gateway, Go for core engine) increases operational complexity.
- Communication between gateway and core engine adds latency and failure modes.
- More tools to maintain and deploy.

## Alternatives considered

- **Single backend in NestJS or Go**: simpler, but we want a clean separation between gateway (API surface) and core engine (business logic).
- **Next.js full-stack**: could reduce stack size, but Astro is better for content-heavy sites.
- **Firebase instead of Supabase**: Supabase is open-source Postgres and more portable for tenant data.

## Notes

- The gateway is responsible for tenant resolution, authentication, and routing.
- The core engine is responsible for business logic, external integrations (Spotify), and database operations.
- We will evaluate whether to merge the gateway and core engine later if the operational cost becomes too high.
