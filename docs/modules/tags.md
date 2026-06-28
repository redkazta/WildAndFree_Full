# Module: Tags

## Status

In progress

## Purpose

Visual badges and role-like tags that users can display on their profiles.

## User Stories

- As an admin, I want to create tags so that users can identify themselves.
- As a user, I want to assign tags to my profile so that others see my role.
- As an admin, I want to assign/remove tags from users.

## Data Model

- `tags`
- `user_has_tags`
- `users.user_tags` (cache array)

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/v1/tags | List all tags |
| GET    | /api/v1/users/:id/tags | Get user tags |
| POST   | /api/v1/users/:id/tags/:tagId | Assign tag to user |
| DELETE | /api/v1/users/:id/tags/:tagId | Remove tag from user |
| POST   | /api/v1/tags | Create tag (admin) |
| DELETE | /api/v1/tags/:id | Delete tag (admin) |
| GET    | /api/v1/admin/users-with-tags | List users with tags (admin) |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /gestionar-tags | Admin tag management |

## Open Questions

- Are tags global or per-tenant?
- Should tag colors be limited to a palette?
