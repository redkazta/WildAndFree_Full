# Ticketing + Stripe + Torneos de Escritas

## 1. Aplicar migración

```bash
node run-migrations.cjs
```

O ejecutar en el SQL editor:

```
supabase/migrations/20260820_events_ticketing_sponsors_written.sql
```

Crea:

- `sponsors`, `event_sponsors`, `tournament_sponsors`
- columnas nuevas en `events`: `lineup`, `ticket_price`, `ticket_currency`, `capacity`, `venue_address`, `doors_open`
- `tickets` con `qr_code` único
- `written_submissions`
- columna `modality` en `versus_battles` (`freestyle` | `written`)
- RLS y RPC `validate_ticket(p_code)`
- bucket `written-submissions`

## 2. Variables de entorno

En Vercel (y en `.env` local):

```
PUBLIC_SUPABASE_URL=https://hepsyuwaymwlvyaddecs.supabase.co
PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_KEY=...          # solo servidor
STRIPE_SECRET_KEY=sk_live_...     # o sk_test_...
```

`SUPABASE_SERVICE_KEY` nunca debe exponerse al cliente ni llevar prefijo `PUBLIC_`.

## 3. Flujo de compra

1. El usuario entra a `/evento?id=<uuid>`.
2. `POST /api/ticket-checkout` valida sesión, evento y precio.
3. Si el evento es gratis, emite el boleto directo con la service key.
4. Si tiene precio y Stripe está configurado, crea una Checkout Session y redirige.
5. Stripe vuelve a `/evento?id=<uuid>&success=1&session_id=...`.
6. `POST /api/ticket-confirm` verifica el pago en Stripe y emite el boleto con QR.
7. El boleto aparece en "Mis boletos" con código QR.

Si `STRIPE_SECRET_KEY` no está configurada, la UI muestra un aviso y no emite boletos pagados.

## 4. Validación en puerta

`/erp/boletos` permite:

- Ver asistentes por evento.
- Ver ingresos, válidos y usados.
- Pegar o escanear el código QR y validarlo (RPC `validate_ticket`).

El RPC marca el boleto como `used` y rechaza duplicados.

## 5. Torneo de escritas

- Público: `/versus#torneo-escritas`.
- El formulario acepta texto largo y un archivo opcional (TXT/PDF/DOCX).
- Los archivos van al bucket `written-submissions`.
- ERP: `/erp/versus` → pestaña **Escritas** para ver, calificar y marcar ganador.

## 6. Sponsors

- Tabla `sponsors` con `tier` (`main` / `secondary`), `logo_url`, `website_url`, `is_active` y `sort_order`.
- Se muestran en Home, Eventos y Versus.
- Si la tabla está vacía o no existe, `Sponsors.astro` usa el fallback de `src/data/sponsorsData.ts`.
- Gestión: `/erp/patrocinadores`.
