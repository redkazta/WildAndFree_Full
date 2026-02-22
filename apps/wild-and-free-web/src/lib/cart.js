import { supabase } from './supabase';

const GUEST_CART_KEY = 'wild_guest_cart';
const GUEST_WISHLIST_KEY = 'wild_guest_wishlist';

// Tipos básicos
export const CartEvents = {
  UPDATED: 'cart:updated',
  WISHLIST_UPDATED: 'wishlist:updated'
};

class CartStore {
  constructor() {
    this.cart = [];
    this.wishlist = [];
    this.user = null;
    this.initialized = false;
  }

  async init() {
    if (this.initialized) return;
    
    // Escuchar cambios de auth
    const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
      const prevUser = this.user;
      this.user = session?.user || null;

      if (event === 'SIGNED_IN' && this.user && !prevUser) {
        // Usuario acaba de iniciar sesión -> Sincronizar
        await this.syncGuestToUser();
        await this.loadUserCart();
        await this.loadUserWishlist();
      } else if (event === 'SIGNED_OUT') {
        // Usuario cerró sesión -> Limpiar estado local (volver a guest vacío o mantener lo que tenía antes de loguearse?)
        // El usuario pidió: "si hacen log out solo podrán ver lo que tuvieron de invitados"
        // Interpretación: Mostrar lo que haya en localStorage (que debería estar vacío si se limpió al hacer merge)
        this.cart = this.getGuestCart();
        this.wishlist = this.getGuestWishlist();
        this.notifyListeners();
      }
    });

    // Carga inicial
    const { data: { session } } = await supabase.auth.getSession();
    this.user = session?.user || null;

    if (this.user) {
      await this.loadUserCart();
      await this.loadUserWishlist();
    } else {
      this.cart = this.getGuestCart();
      this.wishlist = this.getGuestWishlist();
    }

    this.initialized = true;
    this.notifyListeners();
  }

  // --- Guest Logic ---

  getGuestCart() {
    if (typeof localStorage === 'undefined') return [];
    try {
      return JSON.parse(localStorage.getItem(GUEST_CART_KEY) || '[]');
    } catch { return []; }
  }

  saveGuestCart(cart) {
    if (typeof localStorage === 'undefined') return;
    localStorage.setItem(GUEST_CART_KEY, JSON.stringify(cart));
    this.cart = cart;
    this.notifyListeners();
  }

  getGuestWishlist() {
    if (typeof localStorage === 'undefined') return [];
    try {
      return JSON.parse(localStorage.getItem(GUEST_WISHLIST_KEY) || '[]');
    } catch { return []; }
  }

  saveGuestWishlist(list) {
    if (typeof localStorage === 'undefined') return;
    localStorage.setItem(GUEST_WISHLIST_KEY, JSON.stringify(list));
    this.wishlist = list;
    this.notifyListeners(CartEvents.WISHLIST_UPDATED);
  }

  // --- User Logic ---

  async loadUserCart() {
    if (!this.user) return;
    const { data, error } = await supabase.from('cart_items').select('*');
    if (!error && data) {
      // Transformar estructura DB a estructura local si es necesario
      // DB: { product_id, quantity }
      // Local: { id: product_id, quantity, ... }
      this.cart = data.map(item => ({ id: item.product_id, quantity: item.quantity }));
      this.notifyListeners();
    }
  }

  async loadUserWishlist() {
    if (!this.user) return;
    const { data, error } = await supabase.from('wishlist_items').select('*');
    if (!error && data) {
      this.wishlist = data.map(item => ({ id: item.product_id }));
      this.notifyListeners(CartEvents.WISHLIST_UPDATED);
    }
  }

  // --- Actions ---

  async addToCart(product, quantity = 1) {
    if (this.user) {
      // Optimistic UI
      const existingItem = this.cart.find(item => item.id == product.id);
      if (existingItem) {
        existingItem.quantity += quantity;
      } else {
        this.cart.push({ id: product.id, quantity, ...product });
      }
      this.notifyListeners();

      // DB Sync
      const { error } = await supabase.from('cart_items').upsert({
        user_id: this.user.id,
        product_id: String(product.id),
        quantity: existingItem ? existingItem.quantity : quantity
      }, { onConflict: 'user_id, product_id' });

      if (error) {
        console.error('Error adding to cart:', error);
        // Revertir optimistic UI si falla (opcional, por ahora simple log)
        await this.loadUserCart(); // Recargar estado real
      }

    } else {
      // Guest
      const currentCart = this.getGuestCart();
      const existingItem = currentCart.find(item => item.id == product.id);
      if (existingItem) {
        existingItem.quantity += quantity;
      } else {
        currentCart.push({ id: product.id, quantity, ...product });
      }
      this.saveGuestCart(currentCart);
    }
  }

  async removeFromCart(productId) {
    if (this.user) {
      // Optimistic
      this.cart = this.cart.filter(item => item.id != productId);
      this.notifyListeners();

      await supabase.from('cart_items').delete().match({ user_id: this.user.id, product_id: String(productId) });
    } else {
      const currentCart = this.getGuestCart().filter(item => item.id != productId);
      this.saveGuestCart(currentCart);
    }
  }

  async toggleWishlist(product) {
    const exists = this.wishlist.some(item => item.id == product.id);
    
    if (this.user) {
      if (exists) {
        this.wishlist = this.wishlist.filter(item => item.id != product.id);
        await supabase.from('wishlist_items').delete().match({ user_id: this.user.id, product_id: String(product.id) });
      } else {
        this.wishlist.push({ id: product.id, ...product });
        await supabase.from('wishlist_items').insert({ user_id: this.user.id, product_id: String(product.id) });
      }
    } else {
      let currentList = this.getGuestWishlist();
      if (exists) {
        currentList = currentList.filter(item => item.id != product.id);
      } else {
        currentList.push({ id: product.id, ...product });
      }
      this.saveGuestWishlist(currentList);
    }
    this.notifyListeners(CartEvents.WISHLIST_UPDATED);
    return !exists; // Retorna nuevo estado (true = agregado)
  }

  // --- Sync Logic ---

  async syncGuestToUser() {
    if (!this.user) return;
    
    const guestCart = this.getGuestCart();
    const guestWishlist = this.getGuestWishlist();

    if (guestCart.length > 0) {
      console.log('Syncing guest cart to user...', guestCart);
      // Para cada item, upsert en DB
      // Nota: Esto podría optimizarse con un bulk insert si Supabase lo soporta bien con onConflict
      for (const item of guestCart) {
        // Primero obtenemos si ya existe para sumar cantidad
        const { data: existing } = await supabase.from('cart_items')
          .select('quantity')
          .eq('user_id', this.user.id)
          .eq('product_id', String(item.id))
          .single();
        
        const newQuantity = existing ? existing.quantity + item.quantity : item.quantity;

        await supabase.from('cart_items').upsert({
          user_id: this.user.id,
          product_id: String(item.id),
          quantity: newQuantity
        }, { onConflict: 'user_id, product_id' });
      }
      // Limpiar guest cart tras sync exitoso
      localStorage.removeItem(GUEST_CART_KEY);
    }

    if (guestWishlist.length > 0) {
      console.log('Syncing guest wishlist...');
      const wishlistPayload = guestWishlist.map(item => ({
        user_id: this.user.id,
        product_id: String(item.id)
      }));
      // Ignore duplicates on insert
      await supabase.from('wishlist_items').upsert(wishlistPayload, { onConflict: 'user_id, product_id', ignoreDuplicates: true });
      localStorage.removeItem(GUEST_WISHLIST_KEY);
    }
  }

  // --- Utils ---
  
  notifyListeners(event = CartEvents.UPDATED) {
    window.dispatchEvent(new CustomEvent(event, { 
      detail: { 
        cart: this.cart, 
        wishlist: this.wishlist,
        count: this.cart.reduce((acc, item) => acc + item.quantity, 0)
      } 
    }));
  }

  isInCart(productId) {
    return this.cart.some(item => item.id == productId);
  }

  isInWishlist(productId) {
    return this.wishlist.some(item => item.id == productId);
  }
}

export const cartStore = new CartStore();
