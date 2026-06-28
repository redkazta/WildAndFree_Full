# Module: Auth

## Status

Not started

## Purpose

Authentication, authorization, roles, and permissions for tenants.

## User Stories

- As a user, I want to log in with email/password so that I can access my profile.
- As a tenant admin, I want to assign roles so that I can manage my team.

## Data Model

- `users`
- `profiles`
- `roles`
- `user_has_roles`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST   | /auth/login | Login with email/password |
| POST   | /auth/register | Register new user |
| POST   | /auth/logout | Logout |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /login | Login page |
| /registro | Register page |

## Open Questions

- Should we support OAuth providers?
- Should roles be global or per-tenant?
