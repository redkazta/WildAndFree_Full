# Wild Gvng Music Hub - Guía de Uso

## 🌐 Plataforma Web (wildgvng.com.mx)

### Login
1. Ir a `/login`
2. Ingresar email y contraseña
3. Click en "Iniciar Sesión"

### Flujo de Navegación por Rol

#### 👑 Admin (`admin@wildgvng.com.mx` / `Admin1122**`)
1. Login → Header muestra avatar con "ADMIN" en el popover
2. **Sitio público**: Navega cualquier módulo (artistas, versus, música, radio, eventos, tienda)
3. **ERP**: Ir a `/erp` → Dashboard con stats de pedidos, usuarios, contenido pendiente
4. **Gestión completa**: `/erp/pedidos`, `/erp/inventario`, `/erp/contenido`, `/erp/usuarios`, `/erp/tags`, `/erp/eventos`, `/erp/versus`, `/erp/configuracion`
5. **Muro**: Crea posts públicos desde `/` (feed principal)
6. **Tags**: Asigna tags a usuarios desde `/erp/tags` o `/gestionar-tags`
7. **Contenido**: Aprueba/rechaza contenido de artistas desde `/erp/contenido`
8. **Logout**: Click avatar → "Cerrar Sesión" en el popover

#### 👔 Staff Senior (`staff_manager@wildgvng.com.mx` / `Staff1122**`)
1. Login → Header muestra avatar con "MEMBER"
2. **ERP**: `/erp` → Dashboard, `/erp/pedidos`, `/erp/inventario`, `/erp/contenido`, `/erp/usuarios`
3. **Permisos**: Ve pedidos, gestiona inventario, aprueba contenido, ve usuarios (no admin)
4. **Reportes**: Acceso a reportes en `/erp`
5. **No puede**: Cambiar configuración del sistema, gestionar tags, versus

#### 📣 Staff Marketing (`marketing@wildgvng.com.mx` / `Marketing1122**`)
1. Login → Header muestra avatar con "MEMBER"
2. **ERP**: `/erp/contenido` → Ve contenido, aprueba/rechaza
3. **Crear contenido crew**: Puede publicar contenido en nombre del crew
4. **No puede**: Pedidos, inventario, usuarios, configuración

#### 📦 Staff Básico (`staff@wildgvng.com.mx` / `Staff1122**`)
1. Login → Header muestra avatar con "MEMBER"
2. **ERP**: `/erp/pedidos` (ve/gestiona), `/erp/inventario` (ve), `/erp/contenido` (ve/aprueba)
3. **No puede**: Usuarios, tags, eventos, versus, configuración, reportes

#### 🎤 Artista (`young_kazta@wildgvng.com.mx` / `Artist1122**`)
1. Login → Header muestra avatar con "MEMBER"
2. **Perfil público**: `/artista/young_kazta` → Música, bio, redes, estado
3. **Mi perfil**: `/perfil` → Editar bio, foto (sujeta a revisión), links sociales
4. **Subir contenido**: Publica en su muro (texto + imágenes) → Va a aprobación del ERP
5. **Música**: Desde perfil, vincula Spotify/YouTube links
6. **Social**: Sigue a otros, comenta posts, da likes
7. **Mensajería**: Chatea con fans (1:1) y en grupos (máx. 11)
8. **Tokens**: Compra en `/wildgvngtokens` (mocked)
9. **No puede**: ERP, gestión de tienda, configuración del crew

#### 🎵 Otros Artistas
- **mc_delta@wildgvng.com.mx** / `Artist1122**` → `/artista/mc_delta`
- **lil_fuego@wildgvng.com.mx** / `Artist1122**` → `/artista/lil_fuego`

#### 🙌 Fan (`fan_torreon@wildgvng.com.mx` / `Fan1122**`)
1. Login → Header muestra avatar con "MEMBER"
2. **Explorar**: Navega artistas, música, radio, eventos, tienda, versus
3. **Perfil**: `/perfil` → Editar nombre, bio, foto, links sociales
4. **Social**: Sigue artistas, comenta en muros, da likes, comparte posts
5. **Amistad**: Envía solicitudes a otros fans (desbloquea mensajes 1:1)
6. **Mensajería**: Chatea con amigos, crea grupos (máx. 11)
7. **Tienda**: Compra merch → `/pedidos` para ver estado
8. **Tokens**: Compra en `/wildgvngtokens` → Gasta en contenido exclusivo
9. **Versus**: Vota en batallas de freestylers (5/día, 1 token c/u)
10. **No puede**: ERP, subir contenido, moderar
11. **Solicitar verificación artista**: Botón "¿Eres artista? Solicita verificarte" en perfil → Envía petición a ERP

#### 🙌 Otros Fans
- **fan_mty@wildgvng.com.mx** / `Fan1122**`
- **fan_cdmx@wildgvng.com.mx** / `Fan1122**`

#### 👤 Visitante (sin login)
1. Navega módulos públicos: Inicio, Artistas, Música, Radio, Podcasts, Eventos, Versus, Tienda
2. No puede: Comentar, dar likes, seguir, chatear, comprar, votar
3. Botón "Iniciar Sesión" / "Unirse" en header
4. Redirige a `/login` o `/registro`

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

## 📱 App Móvil ERP (Flutter) — Flujo por Rol

### Admin
1. Login → Dashboard con stats de pedidos, usuarios, contenido pendiente
2. Tabs: Dashboard, Pedidos, Inventario, Contenido, Usuarios, Eventos, Versus, Tags, Config
3. Puede hacer todo: CRUD completo, cambiar estados, asignar roles, configurar sistema

### Staff Senior
1. Login → Dashboard
2. Tabs: Pedidos, Inventario, Contenido, Usuarios (solo vista)
3. Puede: Gestionar pedidos, asignar guías, ver reportes
4. No puede: Configuración, tags, versus

### Staff Marketing
1. Login → Dashboard
2. Tabs: Contenido
3. Puede: Ver/aprobar contenido, crear posts del crew

### Staff Básico
1. Login → Dashboard
2. Tabs: Pedidos, Inventario (solo vista), Contenido
3. Puede: Gestionar pedidos básicos

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
- Vigencia: 1 mes (configurable)
- Se compran en `/wildgvngtokens` (mocked por ahora)
- Se ganan participando en versus (mocked)

### UX Notas
- El header resuelve autenticación de forma async. El contenedor de auth aparece con fade-in cuando la sesión carga.
- Popover de carrito/favoritos muestra "Inicia sesión" si no hay sesión, contenido dinámico si la hay.
- Los artistas publican contenido → va a cola de aprobación en ERP → admin/staff aprueba/rechaza.
- La foto de perfil del artista se revisa manualmente antes de publicarse.
- La verificación de artista se solicita desde el perfil del fan → petición al ERP → admin aprueba.
