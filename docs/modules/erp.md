# Module: ERP

## Status

Not started

## Purpose

Server-side ERP for crew team to manage orders, payments, deliveries, and inventory. Mobile app for on-the-go management.

## User Stories

- As a team member, I want to view all orders and their status.
- As a team member, I want to mark orders as paid.
- As a team member, I want to mark orders as delivered.
- As a team member, I want to add new products to the catalog.
- As a team member, I want to manage inventory levels.
- As a team member, I want to view sales reports.
- As a team member, I want to manage everything from my phone.

## Order lifecycle

```
Pending → Paid → Processing → Shipped → Delivered
   ↓        ↓         ↓           ↓
 Cancelled Refunded  Cancelled  Returned
```

## Data Model

- `orders` (id, user_id, status, total, shipping_address, created_at)
- `order_items` (id, order_id, product_id, quantity, price)
- `products` (id, name, description, price, stock, type: physical|digital, image_url)
- `payments` (id, order_id, amount, method, status, created_at)

## API Endpoints

### ERP (admin/team)

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/v1/erp/orders | List all orders |
| GET | /api/v1/erp/orders/:id | Get order detail |
| PATCH | /api/v1/erp/orders/:id/status | Update order status |
| GET | /api/v1/erp/products | List products |
| POST | /api/v1/erp/products | Create product |
| PATCH | /api/v1/erp/products/:id | Update product |
| DELETE | /api/v1/erp/products/:id | Delete product |
| GET | /api/v1/erp/reports/sales | Sales report |

### Frontend (fan)

| Method | Path | Description |
|--------|------|-------------|
| GET | /api/v1/orders | My orders |
| GET | /api/v1/orders/:id | My order detail |

## Frontend Routes

### ERP (admin)

| Route | Description |
|-------|-------------|
| /admin/pedidos | Orders list |
| /admin/pedidos/:id | Order detail |
| /admin/productos | Product management |
| /admin/reportes | Sales reports |

### Fan

| Route | Description |
|-------|-------------|
| /pedidos | My orders |
| /pedidos/:id | Order detail |

## Mobile app

- **Team ERP app**: manage orders, products, inventory on the phone.
- **Artist app**: update profile, manage messages, view analytics.

## Open Questions

- Payment gateway integration (Stripe, MercadoPago)?
- Shipping tracking integration?
- Digital product delivery mechanism?
