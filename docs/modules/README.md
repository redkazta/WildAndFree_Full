# Product Modules

This directory contains one document per product module. Each module document defines:

- Purpose and scope
- User stories
- Data model
- API endpoints
- Frontend routes
- Status (not started, designing, in progress, done)

## Module Index

| Module | Status | Description |
|--------|--------|-------------|
| [Auth](./auth.md) | Not started | Authentication, roles, and permissions |
| [Profiles](./profiles.md) | Not started | User profiles and identity |
| [Social](./social.md) | Not started | Wall, friendship, follow system |
| [Messaging](./messaging.md) | Not started | 1:1 chat, group chat, artist request inbox |
| [Tags](./tags.md) | In progress | Tag system, VIP tiers, and user assignment |
| [Music](./music.md) | Not started | Music catalog, radio, and Spotify integration |
| [Shop](./shop.md) | Not started | Store, cart, wishlist, and payments |
| [ERP](./erp.md) | Not started | Orders, payments, deliveries, inventory management |
| [Events](./events.md) | Not started | Events and ticketing |
| [Content](./content.md) | Not started | Blog, podcasts, and writings |
| [Versus](./versus.md) | Not started | Competitions and leagues |
| [Mobile](./mobile.md) | Not started | Artist profile app + team ERP app |

## How to add a module

1. Create a new file in this directory.
2. Fill in the template below.
3. Update the index table.

## Module Template

```markdown
# Module: <Name>

## Status

Not started

## Purpose

What problem does this module solve?

## User Stories

- As a [user], I want [goal] so that [benefit].

## Data Model

Tables, columns, and relationships.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|

## Frontend Routes

| Route | Description |
|-------|-------------|

## Open Questions

- Question 1
- Question 2
```
