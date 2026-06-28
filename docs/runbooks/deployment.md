# Deployment

## Current setup

- Frontend is deployed to **Vercel** via `vercel.json`.
- Backend is not yet deployed to production.

## Frontend (Vercel)

The build command in `vercel.json` builds the Astro app and copies the `dist` folder.

## Backend (pending)

The API Gateway and Core Engine need a production deployment target.

### Recommended options

- **API Gateway**: Railway, Render, Fly.io, or a VPS.
- **Core Engine**: Fly.io, Railway, or a VPS.

## Environment variables

All environment variables must be configured in the production platform.

## TODO

- [ ] Define production URLs for Gateway and Core Engine.
- [ ] Remove `localhost` hardcoded URLs from frontend.
- [ ] Add CI/CD pipeline for backend deployment.
- [ ] Add health checks for Gateway and Core Engine.
