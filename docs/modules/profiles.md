# Module: Profiles

## Status

Not started

## Purpose

User identity and public profiles within a tenant.

## Roles

| Role | Description | Profile features |
|------|-------------|------------------|
| Admin | Crew management | Full access to ERP, moderate content |
| Artist | Crew member | Update profile, post statuses, manage messages, upload music |
| Fan/Member | Registered user | Follow artists, interact with members, buy merch |

## User Stories

- As an artist, I want to update my profile from my phone.
- As an artist, I want to post statuses (like Instagram stories).
- As an artist, I want to display my music on my profile.
- As a fan, I want to view artist profiles and follow them.
- As a fan, I want to edit my own profile.
- As a user, I want my wall to be public (like Metroflog).

## Data Model

- `profiles`
- `user_has_tags`
- `user_has_roles`
- `statuses` (artist stories/updates)

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /profiles/:id | Get profile by ID |
| PATCH  | /profiles/:id | Update own profile |
| POST   | /profiles/:id/status | Post status (artist only) |
| GET    | /profiles/:id/statuses | Get statuses |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /perfil | Own profile |
| /perfil/:id | Public profile |
| /perfil/:id/wall | User wall |

## Open Questions

- What fields are public vs private?
- How long do statuses last?
