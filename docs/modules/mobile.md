# Module: Mobile

## Status

Not started

## Purpose

Native mobile apps for artists and team to manage their presence on the go.

## Two apps

### 1. Artist App

For crew artists to manage their profile and community.

**Features:**
- Update profile (bio, image, music, statuses)
- Post statuses (like Instagram stories)
- Manage messages and request inbox
- View followers and analytics
- Upload music

### 2. Team ERP App

For crew team to manage business operations.

**Features:**
- View and manage orders
- Update order status (paid, shipped, delivered)
- Add/edit products
- View sales reports
- Manage inventory

## Tech stack options

| Option | Pros | Cons |
|--------|------|------|
| React Native | Single codebase, large ecosystem | Learning curve, larger bundle |
| Flutter | Fast performance, hot reload | Dart language, smaller ecosystem |
| PWA (Astro) | No app store needed, web tech | Limited native features |
| Capacitor + Astro | Web tech + native access | Hybrid, some limitations |

## User Stories

- As an artist, I want to update my profile from my phone.
- As an artist, I want to post a status while backstage.
- As an artist, I want to manage my message requests.
- As a team member, I want to check orders while away from the computer.
- As a team member, I want to add a new product from my phone.

## Open Questions

- Which mobile framework? (React Native, Flutter, PWA)
- App store submission required?
- Push notifications needed?
- Offline support required?
