# ADR-006: Frontend Rendering Strategy

## Status

Proposed

## Context

The frontend must serve branded pages for each tenant. Some pages are static content, others need user data. We need to decide when to render statically, server-side, or client-side.

## Decision

We will use **Astro with a hybrid approach**:

- **Static pages** for public content that is mostly tenant-specific but cacheable: home, artists, music, events, blog.
- **Server-side rendering (SSR)** for pages that need tenant config at request time and auth state: profile, admin dashboard, checkout.
- **Client-side islands** for interactive parts: cart, player, like buttons, filters.

### Tenant config

- Public config (colors, name, modules) is fetched at build time or SSR time.
- Tenant config is cached per request to avoid hitting the API Gateway repeatedly.
- Private data is fetched client-side after auth is established.

### Vercel considerations

- Vercel supports Astro SSR via Edge Functions.
- Tenant resolution by domain is done at the Edge.
- Static pages are revalidated when tenant config changes.

## Consequences

### Positive

- Astro's static generation gives fast pages and low hosting costs.
- SSR enables dynamic tenant branding without rebuilding per tenant.
- Client islands keep interactivity where needed.

### Negative

- Mixing rendering modes adds complexity.
- Caching tenant config at the edge requires careful invalidation.
- SSR increases function execution time compared to static pages.

## Alternatives considered

- **Pure static with build per tenant**: simple, but does not scale to many tenants.
- **Next.js full SSR**: more dynamic, but less efficient for content-heavy sites.
- **SPA with client-side rendering**: bad for SEO and initial load.

## Notes

- The frontend currently hardcodes `http://localhost:3000`. This must be replaced with environment variables.
