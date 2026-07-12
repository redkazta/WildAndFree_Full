# Wild Gvng HUB — UX/UI Directives

## Design Principles

### 1. Flat Colors, Zero Gray
- **Dark mode**: fondo `#000` puro, texto `#fff` puro, bordes `#fff` puro.
- **Light mode**: fondo `#fff` puro, texto `#000` puro, bordes `rgba(0,0,0,0.15)`.
- NUNCA uses grises (`#ccc`, `#888`, `#666`, `rgba(255,255,255,x)`) en texto o fondos principales.
- Para énfasis usa **bold** o **font-black**, no gris.

### 2. Nada de gradientes, patrones o texturas
- Fondos planos (solid). Sin `bg-gradient-*`, sin `bg-[url(...)]`, sin `backdrop-blur`.
- La única excepción: acentos decorativos mínimos con `var(--primary)`.

### 3. Preview antes de subir cualquier imagen
- Cuando el usuario selecciona un archivo, NO se sube inmediatamente.
- Mostrar un **dialog/modal** con preview de la imagen.
- El usuario debe poder confirmar o cancelar.
- Solo después de confirmar se dispara la subida.

### 4. Confirmación para acciones destructivas
- Eliminar posts, salir (en ciertos contextos), cambios irreversibles.
- Usar un modal de confirmación, no `confirm()` nativo del browser.

### 5. Estados de carga visibles
- Botones: estado `disabled` + texto cambiante ("Subiendo...", "Publicando...", "Guardando...").
- Overlays: para operaciones que bloquean la pantalla (logout, guardado global).
- Spinners: solo para operaciones que toman >1s.

### 6. Feedback inmediato
- ✅ Éxito: mensaje breve, color `var(--primary)` o `var(--success)`.
- ✗ Error: mensaje claro, color `var(--danger)`.
- El mensaje debe desaparecer automáticamente después de 3-4 segundos (o ser dismissable).

### 7. Botones consistentes
- `dash-submit` / `.btn-primary`: fondo `var(--primary)`, texto `var(--bg)`.
- `dash-btn` / `.btn-ghost`: borde `var(--border)`, sin fondo.
- `.btn-danger`: borde `var(--danger)`, texto `var(--danger)`.
- Todos los botones: `text-transform: uppercase`, `font-weight: 700`, `font-size: 9-11px`.

### 8. Layout responsive
- Sidebar (left): 25-32% del ancho, min-width 280px.
- Contenido principal: flex-1.
- En mobile (<768px): sidebar se colapsa arriba o se oculta.
- Grid dashboard: 2 columnas en desktop, 1 columna en mobile.

### 9. La tipografía manda
- Usar `font-black` para títulos, `font-bold` para énfasis.
- Texto normal: `font-medium` o `font-500`.
- Tracking (letter-spacing) mínimo: `0.02em-0.1em` según contexto.
- Tamaños: títulos 14-24px, cuerpo 12-13px, metadatos 9-11px.

### 10. El usuario necesita ver antes de actuar
- Subir imagen → preview dialog.
- Publicar → preview del post.
- Configurar → ver estado actual antes de editar.

## Patrones de Componentes

```
[Dialog] -> preview -> confirm -> upload -> feedback
[Button] -> loading state -> success/error state -> reset
[Input]  -> focus ring (var(--primary)) -> inline validation
[Nav]    -> active state (var(--primary)) -> hover state
```

## Recordatorios
- El ERP y el sitio público comparten el mismo sistema de theme (`wg-theme` key).
- Todos los estilos deben usar CSS variables definidas en `:root` y `[data-theme="light"]`.
- NO usar `!important` a menos que sea estrictamente necesario.
