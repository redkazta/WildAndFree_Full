# Module: Music

## Status

Not started

## Purpose

Music catalog, radio, and integration with Spotify.

## User Stories

- As a fan, I want to listen to music from the collective.
- As an admin, I want to add tracks and albums.
- As a user, I want to discover music via Spotify search.

## Data Model

- `tracks`
- `albums`
- `artists`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/v1/artists | List artists |
| GET    | /api/v1/spotify/search | Search Spotify |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /musica | Music catalog |
| /radio | Radio |
| /artistas | Artists |

## Open Questions

- Do we host audio or embed from Spotify?
- Should we support playlists?
