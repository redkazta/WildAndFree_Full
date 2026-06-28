# Module: Events

## Status

Not started

## Purpose

Event calendar and ticketing for tenant events.

## User Stories

- As a fan, I want to see upcoming events.
- As a fan, I want to buy tickets.
- As a tenant admin, I want to create and manage events.

## Data Model

- `events`
- `tickets`
- `orders`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/v1/events | List events |
| GET    | /api/v1/events/:id | Get event details |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /eventos | Events |

## Open Questions

- Do we sell tickets ourselves or integrate with Eventbrite?
- Online events, in-person, or both?
