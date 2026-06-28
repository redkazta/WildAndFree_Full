# Wild Gvng Music Hub - Guía de Uso

## 🌐 Plataforma Web (wildgvng.com.mx)

### Login
1. Ir a `/login`
2. Ingresar email y contraseña
3. Click en "Iniciar Sesión"

### Módulos Públicos (sin login)
| Ruta | Módulo |
|------|--------|
| `/` | Inicio - Feed principal con actividad reciente |
| `/artistas` | Lista de artistas verificados |
| `/musica` | Explorar música (Spotify/YouTube embeds) |
| `/podcasts` | Podcasts del crew |
| `/radio` | Radio en vivo |
| `/eventos` | Próximos eventos |
| `/versus` | Mini-juego de freestylers |
| `/tienda` | Tienda de merch |
| `/wild-and-free-league` | Wild and Free League |
| `/wild-writings` | Wild Writings |
| `/ascension` | Ascension |

### Módulos Autenticados (requieren login)
| Ruta | Módulo |
|------|--------|
| `/perfil` | Mi perfil - Editar datos, ver tags |
| `/pedidos` | Mis pedidos de la tienda |
| `/configuracion` | Configuración de cuenta |
| `/gestionar-tags` | Gestión de tags (solo admin) |

### ERP Web (solo admin/staff)
| Ruta | Módulo | Permisos Requeridos |
|------|--------|---------------------|
| `/erp` | Dashboard - Stats y actividad | admin, staff_manager, staff, staff_marketing |
| `/erp/pedidos` | Gestión de pedidos | orders.view / orders.manage |
| `/erp/inventario` | Productos y variantes | inventory.view / inventory.manage |
| `/erp/contenido` | Aprobación de contenido | content.view / content.approve |
| `/erp/usuarios` | Gestión de usuarios y roles | users.view / users.manage |
| `/erp/tags` | Tags decorativos | tags.manage |
| `/erp/eventos` | Eventos del crew | events.manage |
| `/erp/versus` | Freestylers y batallas | versus.manage |
| `/erp/configuracion` | Configuración del sistema | config.manage |

---

## 📱 App Móvil ERP (Flutter)

### Instalación
1. Ir a GitHub Releases: `https://github.com/redkazta/WildAndFree_Full/releases`
2. Descargar el APK más reciente (`wild-erp-android.apk`)
3. Instalar en dispositivo Android
4. Si pide permisos de "Origen desconocido", aceptar

### Funcionalidades
La app móvil replica los mismos módulos del ERP web:
- **Dashboard** - Stats en tiempo real
- **Pedidos** - Gestionar pedidos con filtros y cambio de estado
- **Inventario** - CRUD de productos y variantes con manejo de stock
- **Contenido** - Cola de aprobación con aprobar/rechazar
- **Usuarios** - Gestión de usuarios, roles y tags
- **Eventos** - CRUD de eventos
- **Versus** - Freestylers con sliders de stats y batallas
- **Tags** - Categorías, tags y asignación a usuarios
- **Configuración** - Info del sistema y log de actividad

### Caché
La app usa caché en memoria con TTL de 5 minutos. Las consultas frecuentes se cachean automáticamente. Al hacer mutations (crear/editar/eliminar), se invalida el caché relevante.

---

## 👥 Usuarios y Credenciales

### Admin
| Campo | Valor |
|-------|-------|
| Email | admin@wildgvng.com.mx |
| Contraseña | Admin1122** |
| Username | kazta_admin |
| Rol | admin (acceso total) |
| Tags | FOUNDER, WILD, OG MEMBER, VERIFIED ARTIST, WILD PASS |

### Staff Senior (Staff Manager)
| Campo | Valor |
|-------|-------|
| Email | staff_manager@wildgvng.com.mx |
| Contraseña | Staff1122** |
| Username | roberto_staff |
| Rol | staff_manager |
| Permisos | Pedidos, Inventario, Contenido, Usuarios (ver), Reportes |

### Staff Marketing
| Campo | Valor |
|-------|-------|
| Email | marketing@wildgvng.com.mx |
| Contraseña | Marketing1122** |
| Username | sofia_marketing |
| Rol | staff_marketing |
| Permisos | Contenido (ver, crear crew) |

### Staff Básico
| Campo | Valor |
|-------|-------|
| Email | staff@wildgvng.com.mx |
| Contraseña | Staff1122** |
| Username | diego_staff |
| Rol | staff |
| Permisos | Pedidos (ver/gestionar), Inventario (ver), Contenido (ver/aprobar) |

### Artistas (verificados)
| Email | Contraseña | Username | Tags |
|-------|------------|----------|------|
| young_kazta@wildgvng.com.mx | Artist1122** | young_kazta | WILD, FREESTYLER, VERIFIED ARTIST |
| mc_delta@wildgvng.com.mx | Artist1122** | mc_delta | WILD, FREESTYLER, BATTLE CHAMPION |
| lil_fuego@wildgvng.com.mx | Artist1122** | lil_fuego | WILD, FREESTYLER, FIRST UPLOAD |

### Fans
| Email | Contraseña | Username | Tags |
|-------|------------|----------|------|
| fan_torreon@wildgvng.com.mx | Fan1122** | carlos_mx | WILD, HONOR FAN (50 tokens) |
| fan_mty@wildgvng.com.mx | Fan1122** | ana_reyes_mty | WILD |
| fan_cdmx@wildgvng.com.mx | Fan1122** | luis_garcia_cdmx | WILD, ASCENSION VIP |

---

## 🔧 Configuración de Vercel (Requerido)

Las environment variables deben configurarse en el Dashboard de Vercel:

1. Ir a `https://vercel.com/dashboard` → Seleccionar el proyecto
2. Settings → Environment Variables
3. Agregar:

| Variable | Valor | Environments |
|----------|-------|--------------|
| `PUBLIC_SUPABASE_URL` | `https://cfsqhbisrkqhbupyjrwz.supabase.co` | Production, Preview, Development |
| `PUBLIC_SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` | Production, Preview, Development |

4. Redeploy manual para que tome las variables

---

## 🚀 CI/CD Flutter (GitHub Actions)

### Auto-build
- Al hacer push a `Kazta_dev_main` con cambios en `apps/wild-erp-mobile/**`
- Build automático de APK Android
- Artifact subido a GitHub Actions

### Build manual con Release
1. Ir a Actions → "Flutter ERP Mobile Build"
2. Click "Run workflow"
3. Seleccionar "true" para crear Release
4. Se crea un Release en GitHub con el APK

### PR Check
- Al abrir PR contra `Kazta_dev_main` que toque `apps/wild-erp-mobile/**`
- Análisis estático + build debug automático

---

## 📊 Base de Datos (Supabase)

### Conexión
- URL: `https://cfsqhbisrkqhbupyjrwz.supabase.co`
- Dashboard: `https://supabase.com/dashboard/project/cfsqhbisrkqhbupyjrwz`

### Tablas Principales (33 tablas, 14 capas)
- **Auth**: `auth.users` (Supabase)
- **Perfiles**: `profiles`
- **Roles**: `roles`, `permissions`, `role_permissions`, `user_roles`
- **Social**: `wall_posts`, `wall_comments`, `wall_likes`, `wall_reposts`, `friendships`, `follows`
- **Mensajería**: `conversations`, `conversation_members`, `messages`, `message_read_status`, `message_requests`
- **Tags**: `tag_categories`, `tags`, `user_has_tags`
- **Tienda**: `store_products`, `product_variants`, `store_orders`, `store_order_items`, `cart_items`, `wishlist_items`
- **Tokens**: `user_tokens`, `token_purchases`, `token_transactions`
- **Contenido**: `exclusive_content`, `content_purchases`, `crew_posts`
- **Eventos**: `events`
- **Versus**: `freestylers`, `freestyler_stats`, `versus_battles`, `versus_votes`, `user_battle_votes`
- **Notificaciones**: `notifications`
- **Activity Log**: `activity_log`
- **Favoritos**: `favorites`

### Economía de Tokens
- 1 token = $0.10 MXN
- Límite: 10 tokens/día por IP
- Vigencia: 1 mes
- Se compran en `/wildgvngtokens` (mocked por ahora)
