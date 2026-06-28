# Module: Shop

## Status

Not started

## Purpose

Merchandise and digital product store with cart, wishlist, and ERP integration.

## Product types

- **Physical**: merch (shirts, vinyl, posters, etc.)
- **Digital**: exclusive content (beats, stems, behind the scenes, etc.)

## User Stories

- As a fan, I want to buy merch so that I can support the collective.
- As a user, I want to save items to a wishlist.
- As a user, I want to buy digital content (beats, exclusives).
- As a tenant admin, I want to manage products from ERP.
- As a team member, I want to manage orders from mobile.

## Data Model

- `products` (type: physical | digital)
- `cart_items`
- `wishlist_items`
- `orders`
- `order_items`

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET    | /api/v1/cart | Get cart |
| POST   | /api/v1/cart/add | Add to cart |
| DELETE | /api/v1/cart/remove | Remove from cart |
| GET    | /api/v1/wishlist | Get wishlist |
| POST   | /api/v1/wishlist/add | Add to wishlist |
| DELETE | /api/v1/wishlist/remove | Remove from wishlist |
| GET    | /api/v1/shop/products | List products |
| POST   | /api/v1/shop/checkout | Process checkout |

## Frontend Routes

| Route | Description |
|-------|-------------|
| /tienda | Shop |
| /tienda/:id | Product detail |
| /checkout | Checkout |
| /pedidos | My orders |

## Open Questions

- Which payment processor? (Stripe, MercadoPago, etc.)
- How are digital products delivered after purchase?
