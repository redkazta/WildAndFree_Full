# Guía: Persistencia de Carrito y Wishlist (Guest → Auth → DB)

## Arquitectura General

```
┌─────────────────────────────────────────────────────────┐
│                    USUARIO NO LOGUEADO                   │
│                                                         │
│  localStorage (wild_guest_cart / wild_guest_wishlist)   │
│  ├── Cada cambio se guarda inmediatamente               │
│  ├── Datos persisten entre sesiones del navegador       │
│  └── Se pierden si el usuario limpia el cache            │
│                                                         │
└──────────────────────┬──────────────────────────────────┘
                       │
              LOGIN → SIGNED_IN event
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                  SINCRONIZACIÓN                          │
│                                                         │
│  1. Leer localStorage (guest cart/wishlist)              │
│  2. Para cada item: upsert en tabla Supabase             │
│     - Si el item ya existe en DB → sumar cantidades      │
│     - Si es nuevo → insertar                             │
│  3. Limpiar localStorage (removeItem)                   │
│  4. Cargar estado desde DB                               │
│                                                         │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                    USUARIO LOGUEADO                      │
│                                                         │
│  Supabase DB (cart_items / wishlist_items)               │
│  ├── Todas las operaciones van directo a DB             │
│  ├── Optimistic UI (actualizar UI antes de confirmar)    │
│  └── Si falla → recargar estado real desde DB           │
│                                                         │
└──────────────────────┬──────────────────────────────────┘
                       │
              LOGOUT → SIGNED_OUT event
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                  CIERRE DE SESIÓN                         │
│                                                         │
│  1. Borrar todo localStorage del dominio                 │
│  2. Estado vuelve a guest vacío (cart=[], wishlist=[])   │
│  3. El contenido en DB del usuario se conserva           │
│     (la próxima vez que entre, se restaura)              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Implementación Actual (`src/lib/cart.js`)

### Clase `CartStore`

Singleton que maneja todo el estado del carrito y wishlist.

```javascript
class CartStore {
  cart = [];           // Array de items en carrito
  wishlist = [];       // Array de items en wishlist
  user = null;         // Usuario de Supabase auth
  initialized = false; // Evitar doble init
}
```

### Flujo de Inicialización

```javascript
async init() {
  // 1. Escuchar cambios de auth
  supabase.auth.onAuthStateChange(async (event, session) => {
    if (event === 'SIGNED_IN') {
      await this.syncGuestToUser();   // Migrar localStorage → DB
      await this.loadUserCart();       // Cargar desde DB
      await this.loadUserWishlist();
    }
    if (event === 'SIGNED_OUT') {
      this.cart = [];                  // Limpiar estado
      this.wishlist = [];
      localStorage.removeItem('wild_guest_cart');
      localStorage.removeItem('wild_guest_wishlist');
    }
  });

  // 2. Carga inicial
  const { session } = await supabase.auth.getSession();
  if (session?.user) {
    await this.loadUserCart();         // Usuario logueado → DB
  } else {
    this.cart = getGuestCart();        // Guest → localStorage
  }
}
```

### Operaciones por Estado

| Operación | Guest (sin login) | User (logueado) |
|-----------|-------------------|-----------------|
| `addToCart` | Guarda en localStorage | Upsert en `cart_items` |
| `removeFromCart` | Filtra de localStorage | DELETE en `cart_items` |
| `toggleWishlist` | Guarda/borra de localStorage | INSERT/DELETE en `wishlist_items` |
| `isInCart` | Busca en localStorage array | Busca en `this.cart` (cargado de DB) |

### Tablas Supabase

```sql
-- Carrito
CREATE TABLE cart_items (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id text NOT NULL,
  quantity integer DEFAULT 1,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id)
);

-- Wishlist
CREATE TABLE wishlist_items (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id text NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, product_id)
);
```

### Sincronización Guest → User (`syncGuestToUser`)

```javascript
async syncGuestToUser() {
  const guestCart = JSON.parse(localStorage.getItem('wild_guest_cart') || '[]');
  
  for (const item of guestCart) {
    // Verificar si ya existe en DB
    const { data: existing } = await supabase
      .from('cart_items')
      .select('quantity')
      .eq('user_id', this.user.id)
      .eq('product_id', item.id)
      .single();
    
    // Sumar cantidades si ya existe
    const newQuantity = existing ? existing.quantity + item.quantity : item.quantity;
    
    await supabase.from('cart_items').upsert({
      user_id: this.user.id,
      product_id: item.id,
      quantity: newQuantity
    }, { onConflict: 'user_id, product_id' });
  }
  
  // Limpiar localStorage después de sync exitoso
  localStorage.removeItem('wild_guest_cart');
}
```

## RLS (Row Level Security)

```sql
-- Cart items: solo el dueño puede ver/modificar sus items
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cart" ON cart_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cart" ON cart_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart" ON cart_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cart" ON cart_items
  FOR DELETE USING (auth.uid() = user_id);

-- Mismo patrón para wishlist_items
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own wishlist" ON wishlist_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own wishlist" ON wishlist_items
  FOR ALL USING (auth.uid() = user_id);
```

## Eventos Custom

El cartStore emite eventos para que otros componentes se actualicen:

```javascript
// Escuchar cambios en el carrito
window.addEventListener('cart:updated', (e) => {
  const { cart, count } = e.detail;
  updateCartBadge(count);
});

// Escuchar cambios en wishlist
window.addEventListener('wishlist:updated', (e) => {
  const { wishlist } = e.detail;
  updateWishlistBadge(wishlist.length);
});
```

## Casos Edge

### 1. Login + ya tiene items en DB
- `syncGuestToUser()` suma las cantidades del guest con las de DB
- No se pierde nada

### 2. Login + guest vacío
- Solo carga desde DB
- No hay nada que sincronizar

### 3. Logout + items en DB
- Se borra localStorage
- Los items en DB se conservan
- La próxima vez que entre, se cargan desde DB

### 4. Múltiples navegadores
- Cada navegador tiene su propio localStorage
- Al loguearse, cada uno sincroniza independientemente
- Las cantidades se suman (merge)

### 5. Cerrar sesión + volver a entrar
- Estado vuelve a guest vacío
- Al loguearse de nuevo, se restaura desde DB
