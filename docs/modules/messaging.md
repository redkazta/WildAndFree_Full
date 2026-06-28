# Module: Messaging

## Status

Not started

## Purpose

1:1 and group messaging with artist request inbox.

## Messaging rules

| From | To | Condition |
|------|-----|-----------|
| Member | Member | Must be friends |
| Fan | Artist | Must follow, goes to request inbox |
| Artist | Anyone | Always allowed |
| Admin | Anyone | Always allowed |

## User Stories

- As a member, I want to chat 1:1 with my friends.
- As a member, I want to create group chats.
- As a fan, I want to message an artist (goes to request inbox).
- As an artist, I want a message request inbox to filter who contacts me.
- As an artist, I want to accept/reject message requests.
- As an artist, I want to block users.

## Data Model

- `conversations` (id, type: direct|group, created_at)
- `conversation_members` (conversation_id, user_id, joined_at)
- `messages` (id, conversation_id, sender_id, content, created_at)
- `message_requests` (id, sender_id, receiver_id, status: pending|accepted|rejected, created_at)

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/v1/messages/conversations | List my conversations |
| POST | /api/v1/messages/conversations | Create conversation |
| GET | /api/v1/messages/conversations/:id | Get conversation messages |
| POST | /api/v1/messages/conversations/:id/send | Send message |
| GET | /api/v1/messages/requests | Get message requests (artist) |
| POST | /api/v1/messages/requests/:id/accept | Accept request |
| POST | /api/v1/messages/requests/:id/reject | Reject request |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /mensajes | Conversations list |
| /mensajes/:id | Chat view |
| /mensajes/solicitudes | Message requests (artist) |

## Open Questions

- Real-time messaging via WebSockets or polling?
- Message read receipts?
- Media in messages (images, audio)?
