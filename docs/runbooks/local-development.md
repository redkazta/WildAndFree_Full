# Local Development

## Requirements

- Node.js 20+
- pnpm 9.15.9
- Go 1.23+
- PostgreSQL 15+ (or Supabase CLI)

## Quick start

```bash
# Install dependencies
pnpm install

# Run all services in parallel
pnpm dev
```

This starts:

- Astro frontend at `http://localhost:4321`
- API Gateway at `http://localhost:3000`
- Core Engine at `http://localhost:8080`

## Running services individually

```bash
# Frontend
pnpm --filter wild-and-free-web dev

# API Gateway
pnpm --filter api-gateway dev

# Core Engine
cd services/core-engine
go run .
```

## Environment variables

Copy the example files and fill them:

```bash
cp apps/wild-and-free-web/.env.example apps/wild-and-free-web/.env
```

Required variables:

- `PUBLIC_SUPABASE_URL`
- `PUBLIC_SUPABASE_ANON_KEY`
- `DATABASE_URL` (for Core Engine)
- `SPOTIFY_CLIENT_ID` (optional)
- `SPOTIFY_CLIENT_SECRET` (optional)

## Database

Apply migrations with Supabase CLI:

```bash
supabase db reset
supabase migration up
```

Or run the SQL files manually against your local Postgres.

## Default tenant

Local development uses `wild-and-free` as the default tenant.

Set `DEFAULT_TENANT_ID` to override:

```bash
DEFAULT_TENANT_ID=another-crew pnpm dev
```
