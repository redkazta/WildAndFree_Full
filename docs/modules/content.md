# Module: Content

## Status

Not started

## Purpose

Blog, podcasts, and writings managed by the tenant.

## User Stories

- As a tenant admin, I want to publish articles and podcasts.
- As a fan, I want to read and listen to exclusive content.

## Data Model

- `posts`
- `podcasts`
- `categories`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/v1/posts | List posts |
| GET    | /api/v1/posts/:slug | Get post |
| GET    | /api/v1/podcasts | List podcasts |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /wild-writings | Blog |
| /podcasts | Podcasts |

## Open Questions

- Do we build a CMS or use a headless one?
- Should content be free or gated?
