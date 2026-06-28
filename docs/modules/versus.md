# Module: Versus

## Status

Not started

## Purpose

Competitions and leagues between artists or community members.

## User Stories

- As a collective, I want to organize battles and competitions.
- As a fan, I want to vote and follow rankings.
- As an artist, I want to participate in battles.

## Data Model

- `battles`
- `votes`
- `leagues`
- `rankings`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/v1/versus | List battles |
| POST   | /api/v1/versus/:id/vote | Vote |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /versus | Battles |
| /wild-and-free-league | League |

## Open Questions

- What types of competitions? (rap battles, beat contests, etc.)
- Voting by public, jury, or both?
