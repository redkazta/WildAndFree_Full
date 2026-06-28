# Module: Social

## Status

Not started

## Purpose

Wall, friendship, and follow system for community interaction.

## User Stories

- As a user, I want my own public wall (like Metroflog).
- As a user, I want to post content to my wall.
- As a fan, I want to follow artists.
- As a member, I want to send friendship requests to other members.
- As a member, I want to accept/reject friendship requests.
- As a user, I want to see posts from people I follow on my feed.

## Friendship rules

| From | To | Action | Effect |
|------|-----|--------|--------|
| Member | Member | Friend request | Mutual acceptance required, unlocks messaging |
| Fan | Artist | Follow | One-way, no messaging |
| Anyone | Anyone | View wall | Always public |

## Data Model

- `wall_posts` (user_id, content, media_url, created_at)
- `wall_comments` (post_id, user_id, content, created_at)
- `wall_likes` (post_id, user_id)
- `friendships` (user_id, friend_id, status: pending|accepted|rejected)
- `follows` (follower_id, following_id)

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/v1/wall/:userId | Get user wall posts |
| POST | /api/v1/wall/post | Create wall post |
| DELETE | /api/v1/wall/post/:postId | Delete own post |
| POST | /api/v1/wall/post/:postId/comment | Add comment |
| POST | /api/v1/wall/post/:postId/like | Like post |
| POST | /api/v1/friendship/request | Send friend request |
| POST | /api/v1/friendship/accept/:requestId | Accept request |
| POST | /api/v1/friendship/reject/:requestId | Reject request |
| GET | /api/v1/friendship/requests | Get pending requests |
| POST | /api/v1/follow/:userId | Follow user |
| DELETE | /api/v1/follow/:userId | Unfollow user |
| GET | /api/v1/feed | Get feed (followed users' posts) |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /perfil/:id/wall | User wall |
| /feed | Main feed (posts from followed users) |
| /solicitudes | Friendship requests |

## Open Questions

- Can members unfriend?
- Is there a limit to wall posts?
- Do wall posts support media (images, audio)?
