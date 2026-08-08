# Wild Gvng — Contexto del Proyecto

> ⚠️ ESTE ARCHIVO DEBE PERMANECER ESTABLE.
> Es parte del prefijo del prompt en cada request del agente. Modificarlo frecuentemente rompe el prompt caching del modelo (DeepSeek) y aumenta el costo. Actualiza SOLO cuando cambie algo estructural real.

## Stack

- Monorepo **pnpm workspaces** (`apps/*`, `packages/*`, `services/*`)
- **Web**: Astro 5 + Tailwind (Vercel, estático) — `apps/wild-and-free-web`
- **Móvil**: Flutter — `apps/wild-erp-mobile`
- **Backend**: Supabase (PostgreSQL + RLS + Auth) — project ref `cfsqhbisrkqhbupyjrwz`
- **Servicios** (NO USAR por ahora, son placeholder): `services/api-gateway` (NestJS), `services/core-engine` (Go)

## Estructura clave (web)

- `src/pages/` — páginas Astro (publicas + `erp/` + `admin/`)
- `src/lib/` — módulos JS/TS: `supabase.js/ts`, `role.js` (getRole), `erp-permissions.ts` (permisos ERP), `wild-times-feed.ts` (feed público)
- `src/data/artists.ts` — fetch de artistas con fallback a mock
- `src/pages/erp/noticias.astro` — módulo ERP para publicar crew_posts (con permisos)
- `supabase/migrations/` — migraciones SQL (correr con `run-migrations.cjs` vía pg)
- `.env` en raíz: `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`

## Roles y permisos

| Rol | Acceso ERP | Notas |
|-----|-----------|-------|
| admin | ✅ Total | Wildcard `*` |
| staff | ✅ | `content.manage` para noticias |
| artist | ❌ | Solo su contenido |
| fan | ❌ | Nada |

- **Regla de oro**: publicar contenido (crew_posts) se hace SOLO desde el ERP (`/erp/noticias`). Las páginas públicas (`/the-wild-times`) solo MUESTRAN.
- Control de permisos ERP: `waitForPermissions()` en `lib/erp-permissions.ts` + check de `content.manage` / wildcard.

## Tablas clave (Supabase)

- `crew_posts` — noticias/publicaciones del feed (autor = `author_id`, tipos: announcement/event/promotion/general, `status` published/pending)
- `wall_posts`, `wall_comments`, `wall_likes`, `wall_reposts` — feed social. **FK de post_id es polimórfica** (acepta crew_posts o wall_posts) tras `20260729_polymorphic_reactions.sql`
- `profiles` — usuario: `nombre`, `username` (NO usar display_name/email), `role`, `avatar_url`
- `user_roles` + `roles` — asignación de roles (admin/staff/artist/fan)
- `tags` + `user_has_tags` — badges
- `exclusive_content` + `content_purchases` + `user_tokens` — contenido premium por tokens
- `store_orders`, `store_products`, `product_variants` — ecommerce (checkout con blocker, sin Stripe aún)
- `freestylers`, `freestyler_stats`, `versus_battles`, `versus_votes` — versus
- `events`, `radio_config`, `radio_episodes`, `radio_schedule`, `notifications`

## Funciones RPC importantes

- `get_feed_posts`, `get_crew_feed`, `get_post_comments` — feed con conteos
- `toggle_like`, `toggle_repost` — reacciones atómicas
- `decrement_tokens`, `get_token_balance` — tokens

## Convenciones

- Todo el texto de UI en español
- Estilo visual: brutalista/dark con `--primary: #C98300` (naranja), `var(--bg)` etc.
- `<style is:global>` en páginas cuyo contenido se renderiza por JS (si no, Astro escopea y no aplica)
- No tocar `VERSIONS.md` ni el schema sin verificar compatibilidad
- Checkout: NO generar órdenes hasta implementar Stripe
- Los scripts `run-migrations.cjs` y `seed-posts.cjs` usan `pg` global (`npm root -g`)

## Para correr migraciones

```bash
node run-migrations.cjs   # aplica migraciones SQL a Supabase remoto
```
