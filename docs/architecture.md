# Architecture

## High-level diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        User Browser                         │
└──────────────────────┬────────────────────────────────────────┘
                       │
                       │ Domain / Subdomain
                       │ (e.g. wild-and-free.com)
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                    Vercel / Edge Network                      │
│              Astro frontend (wild-and-free-web)              │
│              - Resolves tenant by domain                     │
│              - Fetches config from API Gateway               │
└──────────────────────┬────────────────────────────────────────┘
                       │
                       │ HTTPS / REST
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                  API Gateway (NestJS)                         │
│              - Tenant resolution middleware                  │
│              - Auth / JWT validation                         │
│              - Routes to Core Engine                         │
└──────────────────────┬────────────────────────────────────────┘
                       │
                       │ Internal HTTP
                       │ X-Tenant-ID header
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                   Core Engine (Go)                          │
│              - Business logic                              │
│              - Spotify integration                         │
│              - Commerce (cart / wishlist)                  │
│              - Tag management                              │
└──────────────────────┬────────────────────────────────────────┘
                       │
                       │ PostgreSQL
                       │
┌──────────────────────▼────────────────────────────────────────┐
│                      Supabase (Postgres)                    │
│              - Tenants                                       │
│              - Users / Profiles / Roles / Tags               │
│              - Products / Events / Orders / Content          │
└─────────────────────────────────────────────────────────────┘
```

## Service boundaries

### Frontend (Astro)

- Renders public pages per tenant.
- Uses Supabase Auth for client-side auth.
- Talks to API Gateway for tenant-specific data.
- Can be static or use SSR/Edge functions for tenant resolution.

### API Gateway (NestJS)

- Resolves tenant from domain, header, or env variable.
- Validates JWT and attaches user context.
- Routes to Core Engine.
- Exposes typed endpoints to the frontend.

### Core Engine (Go)

- Receives `X-Tenant-ID` and `Authorization` headers.
- Applies business logic and filters all DB queries by tenant.
- Integrates with external APIs (Spotify, payment provider).
- Handles commerce, tags, events, and content management.

## Data flow

1. User visits `wild-and-free.com`.
2. Vercel serves the Astro app.
3. Astro resolves tenant via domain and calls `/gateway/config`.
4. Gateway reads tenant config and returns colors, modules, artists.
5. User logs in via Supabase Auth.
6. Frontend calls Gateway endpoints with JWT.
7. Gateway validates JWT and forwards with `X-Tenant-ID` to Core Engine.
8. Core Engine applies RLS/tenant filters and returns data.

## Tenant resolution

Resolution order:

1. `DEFAULT_TENANT_ID` env variable (for local dev).
2. `X-Tenant-ID` header.
3. Subdomain from `Host` header (`wild-and-free.musicianshub.com` → `wild-and-free`).
4. Full domain if mapped in `tenants` table.
5. Fallback to `wild-and-free`.

## Security rules

- Every tenant-scoped query must include `tenant_id = ?`.
- Supabase RLS policies must enforce tenant isolation.
- The frontend never connects directly to Core Engine; it always goes through Gateway.
- Commerce handlers must validate JWT, not just a Bearer token.
