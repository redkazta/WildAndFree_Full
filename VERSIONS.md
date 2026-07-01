# Wild Gvng — Pinned Versions

> **Última actualización:** 2026-07-01
> IMPORTANTE: No cambiar versiones sin verificar compatibilidad cruzada.

## Flutter ERP Mobile (`apps/wild-erp-mobile/`)

### Runtime
| Paquete | Versión (pubspec) | Versión resuelta (pubspec.lock) |
|---------|-------------------|---------------------------------|
| Flutter SDK | 3.44.4 | 3.44.4 |
| Dart SDK | >=3.0.0 <4.0.0 | — |
| supabase_flutter | ^2.8.0 | 2.15.2 |
| provider | ^6.1.1 | 6.1.5+1 |
| shared_preferences | ^2.2.2 | 2.5.5 |
| intl | ^0.19.0 | 0.19.0 |
| cupertino_icons | ^1.0.6 | 1.0.9 |
| url_launcher | ^6.2.0 | 6.3.2 |
| **file_picker** | **^8.3.7** | **8.3.7** |

### Dev
| Paquete | Versión (pubspec) | Versión resuelta |
|---------|-------------------|------------------|
| flutter_lints | ^5.0.0 | 5.0.0 |

### ⚠️ CRÍTICO — file_picker
- **Mínimo: ^8.3.7** (Flutter 3.44.4 requiere v2 embedding)
- **NO usar versiones < 8.0.0** → falla con `PluginRegistry.Registrar` (v1 embedding eliminado en Flutter 3.22+)
- Si el CI resuelve una versión vieja, ejecutar: `flutter pub cache clean --force && rm -f pubspec.lock && flutter pub get`

### Android Build
| Componente | Versión |
|------------|---------|
| Java (CI) | 17 (temurin) |
| Gradle | 9.1.0 |
| Android SDK Platform | 33 |
| Kotlin Gradle Plugin | ⚠️ Pendiente migración a Built-in Kotlin |

---

## Web Frontend (`apps/wild-and-free-web/`)

| Componente | Versión |
|------------|---------|
| Node | LTS (GitHub Actions default) |
| Astro | (ver package.json) |

---

## CI/CD

| Componente | Versión |
|------------|---------|
| `actions/checkout` | v4 |
| `actions/upload-artifact` | v4 |
| `actions/setup-java` | v4 |
| `subosito/flutter-action` | v2 |
| `softprops/action-gh-release` | v2 |
| Runner | ubuntu-latest |

---

## Supabase

| Campo | Valor |
|-------|-------|
| Project Ref | `cfsqhbisrkqhbupyjrwz` |
| URL | `https://cfsqhbisrkqhbupyjrwz.supabase.co` |
| SDK | supabase_flutter ^2.8.0 (usa PostgREST v12+) |

### DB Tables (43 total)
```
activity_log, cart_items, content_purchases, conversation_members,
conversations, crew_posts, events, exclusive_content, favorites,
follows, freestyler_stats, freestylers, friendships,
message_read_status, message_requests, messages, notifications,
permissions, product_variants, profiles, radio_auto_tracks,
radio_config, radio_episodes, radio_schedule, role_permissions,
roles, store_order_items, store_orders, store_products,
tag_categories, tags, token_purchases, token_transactions,
user_battle_votes, user_has_tags, user_roles, user_tokens,
versus_battles, versus_votes, wall_comments, wall_likes,
wall_posts, wall_reposts, wishlist_items
```

### ⚠️ SCHEMA NOTES — NO CAMBIAR
| Tabla | Columna real | ❌ NO usar |
|-------|-------------|-----------|
| profiles | `nombre` | ~~display_name~~ |
| profiles | `username` | ~~email~~ (email viene de auth.users) |
| store_orders | `store_orders` | ~~orders~~ |
| events | `event_date` | ~~start_date~~ |

---

## Perfiles de Admin

| Email | UUID | Rol |
|-------|------|-----|
| kazta@wildgvng.com.mx | `ec7ba40e-971a-4729-ad17-e83a0fdd42b5` | admin |
| ralfdiaz@wildgvng.com.mx | `cd2611f7-1ad1-4fff-8032-77f8ee616fbb` | admin |
| admin@wildgvng.com.mx | `ab563ebf-1396-4b0f-a4b7-8d1dec846790` | admin |
