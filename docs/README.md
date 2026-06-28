# Wild And Free — Documentation Hub

> Single source of truth for architecture, decisions, modules, and operational guides.

This document is the master index. If you are looking for something, start here.

---

## 1. Project Overview

- **[PROJECT.md](./PROJECT.md)** — What it is, who it is for, and the business pitch.
- **[adr/ADR-001-multi-tenant-strategy.md](./adr/ADR-001-multi-tenant-strategy.md)** — Why this is a multi-tenant platform and how it works.
- **[adr/ADR-002-monorepo-stack.md](./adr/ADR-002-monorepo-stack.md)** — Why this stack (Astro, NestJS, Go, Supabase) was chosen.

## 2. Repository Structure

Monorepo managed with `pnpm` workspaces.

```
├── apps/
│   └── wild-and-free-web/          # Astro frontend
│       ├── src/pages/              # Site routes
│       ├── src/components/         # UI components
│       ├── src/lib/                # Client-side utilities (auth, cart, tags)
│       └── README.md               # Astro-specific docs
├── packages/
│   ├── shared-types/               # Shared TypeScript definitions
│   │   ├── index.ts                # Core API types
│   │   └── tenant-config.json      # Static tenant config (to be migrated to DB)
│   └── design-system/              # UI tokens (WIP)
├── services/
│   ├── api-gateway/                # NestJS gateway
│   │   ├── src/tenant/             # Tenant resolution middleware
│   │   ├── src/tags/               # Tag module
│   │   └── README.md               # NestJS-specific docs
│   └── core-engine/                # Go core engine
│       ├── internal/tenant/          # Tenant init logic
│       ├── internal/commerce/        # Cart and wishlist handlers
│       ├── internal/spotify/         # Spotify integration
│       ├── database/schema.sql       # Database schema
│       └── main.go                   # HTTP server
└── supabase/
    └── migrations/                   # SQL migrations
```

## 3. Architecture

- **[architecture.md](./architecture.md)** — High-level diagram, data flow, and service boundaries.
- **[api/README.md](./api/README.md)** — API contracts and endpoints (gateway + core-engine).
- **[database/README.md](./database/README.md)** — Schema conventions and migration rules.
- **[frontend/README.md](./frontend/README.md)** — Frontend conventions, routing, and state.

## 4. Product Modules

Each module has its own document. We create them one at a time.

- **[modules/README.md](./modules/README.md)** — Module index and status.
- **[modules/auth.md](./modules/auth.md)** — Authentication, roles, and permissions.
- **[modules/profiles.md](./modules/profiles.md)** — User profiles and identity.
- **[modules/social.md](./modules/social.md)** — Wall, friendship, follow system.
- **[modules/messaging.md](./modules/messaging.md)** — 1:1 chat, group chat, artist request inbox.
- **[modules/tags.md](./modules/tags.md)** — Tag system, VIP tiers, and user assignment.
- **[modules/music.md](./modules/music.md)** — Music catalog, radio, and Spotify.
- **[modules/shop.md](./modules/shop.md)** — Store, cart, wishlist, and payments.
- **[modules/erp.md](./modules/erp.md)** — Orders, payments, deliveries, inventory management.
- **[modules/events.md](./modules/events.md)** — Events and ticketing.
- **[modules/content.md](./modules/content.md)** — Blog, podcasts, and writings.
- **[modules/versus.md](./modules/versus.md)** — Competitions and leagues.
- **[modules/mobile.md](./modules/mobile.md)** — Artist profile app + team ERP app.

## 5. Development & Operations

- **[runbooks/local-development.md](./runbooks/local-development.md)** — How to run the project locally.
- **[runbooks/deployment.md](./runbooks/deployment.md)** — Deploy to Vercel and beyond.
- **[runbooks/tenant-onboarding.md](./runbooks/tenant-onboarding.md)** — How to onboard a new collective.

## 6. Decision Log

All architecturally significant decisions are recorded as ADRs in [./adr](./adr).

| # | Decision | Status |
|---|----------|--------|
| 001 | Multi-tenant strategy: shared database + `tenant_id` | Proposed |
| 002 | Monorepo stack: Astro + NestJS + Go + Supabase | Proposed |
| 003 | Auth and authorization: Supabase + JWT | Proposed |
| 004 | Database schema conventions | Proposed |
| 005 | API contract style: REST + OpenAPI | Proposed |
| 006 | Frontend rendering: Astro hybrid | Proposed |
| 007 | Deployment strategy: Vercel + backend services | Proposed |
| 008 | Module system: per-tenant feature flags | Proposed |
| 009 | Single-tenant design: one crew per deployment | Accepted |

## 7. Documentation Policy

See [documentation-policy.md](./documentation-policy.md) for the rules on keeping docs in sync with code changes.

---

## Quick Start

```bash
# Install dependencies
pnpm install

# Run all services in parallel
pnpm dev
```

See [runbooks/local-development.md](./runbooks/local-development.md) for full instructions.
