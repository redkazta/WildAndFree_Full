# ADR-003: Authentication and Authorization Strategy

## Status

Proposed

## Context

The platform needs to identify users and enforce permissions. Each tenant has its own users, admins, and roles. Auth must work across the frontend (Astro), API Gateway (NestJS), and Core Engine (Go).

## Decision

We will use **Supabase Auth** for authentication and **JWT tokens** for authorization across services.

### Authentication flow

1. User signs up or logs in via Supabase Auth (frontend).
2. Supabase returns a JWT access token.
3. Frontend sends the JWT in the `Authorization` header to the API Gateway.
4. API Gateway validates the JWT with Supabase.
5. Gateway extracts the user ID and attaches it to the request to Core Engine.
6. Core Engine reads the user ID and tenant ID, then applies permissions and RLS.

### Roles and permissions

- Roles are stored in `roles` and linked to users via `user_has_roles`.
- Roles are per-tenant: a user can be `admin` in one tenant and `member` in another.
- Permissions are stored as JSONB in the `roles` table.
- Common roles: `admin`, `moderator`, `artist`, `member`, `fan`.

## Consequences

### Positive

- Supabase Auth handles email/password, OAuth, password reset, and email verification.
- JWT is standard and works across all services.
- Roles can be customized per tenant.

### Negative

- Requires an extra validation call or shared JWT secret between services.
- Supabase Auth ties the platform to Supabase unless we migrate later.
- Roles and permissions must be checked on every protected request.

## Alternatives considered

- **Custom JWT in Core Engine**: more control, but more code to maintain.
- **Auth0 / Clerk**: good alternatives, but add cost and vendor lock-in.
- **Session cookies**: simpler for monolith, harder for multi-service setup.

## Notes

- The Core Engine must never trust a raw user ID from a header without JWT validation.
- Commerce handlers currently use a placeholder `Bearer <uid>` and must be replaced with real JWT validation.
