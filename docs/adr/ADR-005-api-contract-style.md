# ADR-005: API Contract Style

## Status

Proposed

## Context

The frontend needs a stable way to communicate with the backend. The API Gateway and Core Engine must share a common contract style.

## Decision

We will use **REST with JSON** and **OpenAPI 3.0** for API documentation.

### Rules

- All public endpoints are exposed through the API Gateway.
- The Core Engine exposes internal endpoints consumed only by the Gateway.
- Endpoints are versioned: `/api/v1/...`.
- Request and response bodies are typed in `shared-types`.
- OpenAPI spec is generated from NestJS controllers.

### Naming

- Use nouns, not verbs: `/events`, `/products`, `/cart`.
- Use HTTP methods for actions: GET, POST, PATCH, DELETE.
- Use nested resources where clear: `/users/:id/tags`.

### Errors

- Use standard HTTP status codes.
- Return a consistent error body:

```json
{
  "statusCode": 400,
  "message": "Invalid request",
  "error": "Bad Request"
}
```

## Consequences

### Positive

- REST is familiar to most developers.
- OpenAPI enables auto-generated docs and client SDKs.
- `shared-types` keeps frontend and backend in sync.

### Negative

- REST can lead to many endpoints for complex queries.
- Versioning requires maintaining multiple versions during transitions.

## Alternatives considered

- **GraphQL**: flexible queries, but more complexity and caching challenges.
- **tRPC**: great for TypeScript monorepos, but less language-agnostic.
- **gRPC**: fast, but harder for frontend consumption.

## Notes

- The Core Engine currently uses Go's `http.ServeMux` with Go 1.22 path patterns.
- We will migrate to a more structured router (e.g., chi or gorilla/mux) as the API grows.
