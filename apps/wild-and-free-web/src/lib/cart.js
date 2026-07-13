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
    const { data: { subscription: _subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
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
      var raw = JSON.parse(localStorage.getItem(GUEST_CART_KEY) || '[]');
      return raw.map(function(item) {
        return {
          id: item.id,
          cart_key: item.cart_key || (item.variant_id ? item.id + '_' + item.variant_id : String(item.id)),
          name: item.name || 'Producto',
          price: Number(item.price) || 0,
          image: (item.image && item.image !== '') ? item.image : '',
          variant_id: item.variant_id || null,
          size: item.size || null,
          color: item.color || null,
          sku: item.sku || null,
          quantity: item.quantity || 1
        };
      });
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
      var raw = JSON.parse(localStorage.getItem(GUEST_WISHLIST_KEY) || '[]');
      return raw.map(function(item) {
        return {
          id: item.id,
          name: item.name || 'Producto',
          price: Number(item.price) || 0,
          image: item.image || ''
        };
      });
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
      this.cart = data.map(item => ({
        id: item.product_id,
        cart_key: item.variant_id ? `${item.product_id}_${item.variant_id}` : String(item.product_id),
        name: item.product_name || 'Producto',
        price: Number(item.product_price) || 0,
        image: item.product_image || '',
        variant_id: item.variant_id,
        size: item.variant_size || null,
        color: item.variant_color || null,
        sku: item.variant_sku || null,
        quantity: item.quantity
      }));
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
    // Build a clean cart item with all required fields explicitly
    var name = product.name || 'Producto';
    var price = Number(product.price) || 0;
    var image = product.image || '';
    var cartKey = product.variant_id ? product.id + '_' + product.variant_id : String(product.id);
    
    if (this.user) {
      // Optimistic UI
      var existingItem = this.cart.find(function(i) { return i.cart_key == cartKey; });
      if (existingItem) {
        existingItem.quantity += quantity;
        existingItem.name = name;
        existingItem.price = price;
        existingItem.image = image;
      } else {
        this.cart.push({
          id: product.id,
          cart_key: cartKey,
          name: name,
          price: price,
          image: image,
          variant_id: product.variant_id || null,
          size: product.size || null,
          color: product.color || null,
          sku: product.sku || null,
          quantity: quantity
        });
      }
      this.notifyListeners();

      // DB Sync
      var payload = {
        user_id: this.user.id,
        product_id: String(product.id),
        quantity: existingItem ? existingItem.quantity : quantity,
        product_name: name,
        product_price: price,
        product_image: image
      };
      if (product.variant_id) {
        payload.variant_id = product.variant_id;
        payload.variant_size = product.size || null;
        payload.variant_color = product.color || null;
        payload.variant_sku = product.sku || null;
      }

      var { error } = await supabase.from('cart_items').upsert(payload, { 
        onConflict: product.variant_id ? 'user_id, product_id, variant_id' : 'user_id, product_id' 
      });

      if (error) {
        console.error('Error adding to cart:', error);
        await this.loadUserCart();
      }

    } else {
      // Guest
      var currentCart = this.getGuestCart();
      var existingItem = currentCart.find(function(i) { return i.cart_key == cartKey; });
      if (existingItem) {
        existingItem.quantity += quantity;
        existingItem.name = name;
        existingItem.price = price;
        existingItem.image = image;
      } else {
        currentCart.push({
          id: product.id,
          cart_key: cartKey,
          name: name,
          price: price,
          image: image,
          variant_id: product.variant_id || null,
          size: product.size || null,
          color: product.color || null,
          sku: product.sku || null,
          quantity: quantity
        });
      }
      this.saveGuestCart(currentCart);
    }
  }

  async removeFromCart(cartKey) {
    if (this.user) {
      // Optimistic
      const item = this.cart.find(i => i.cart_key == cartKey || i.id == cartKey);
      this.cart = this.cart.filter(i => i.cart_key != cartKey && i.id != cartKey);
      this.notifyListeners();

      var match = { user_id: this.user.id, product_id: String(item?.id || cartKey) };
      if (item?.variant_id) match.variant_id = item.variant_id;
      await supabase.from('cart_items').delete().match(match);
    } else {
      const currentCart = this.getGuestCart().filter(i => i.cart_key != cartKey && i.id != cartKey);
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
        this.wishlist.push({ id: product.id, name: product.name || 'Producto', price: Number(product.price) || 0, image: (product.image && product.image !== '') ? product.image : '' });
        await supabase.from('wishlist_items').insert({ user_id: this.user.id, product_id: String(product.id) });
      }
    } else {
      let currentList = this.getGuestWishlist();
      if (exists) {
        currentList = currentList.filter(item => item.id != product.id);
      } else {
        currentList.push({ id: product.id, name: product.name || 'Producto', price: Number(product.price) || 0, image: (product.image && product.image !== '') ? product.image : '' });
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
      for (const item of guestCart) {
        var matchFilter = { user_id: this.user.id, product_id: String(item.id) };
        if (item.variant_id) matchFilter.variant_id = item.variant_id;

        const { data: existing } = await supabase.from('cart_items')
          .select('quantity')
          .match(matchFilter)
          .single();
        
        const newQuantity = existing ? existing.quantity + item.quantity : item.quantity;

        var syncPayload = {
          user_id: this.user.id,
          product_id: String(item.id),
          quantity: newQuantity
        };
        syncPayload.product_name = item.name || null;
        syncPayload.product_price = item.price || null;
        syncPayload.product_image = item.image || null;
        if (item.variant_id) {
          syncPayload.variant_id = item.variant_id;
          syncPayload.variant_size = item.size || null;
          syncPayload.variant_color = item.color || null;
          syncPayload.variant_sku = item.sku || null;
        }

        await supabase.from('cart_items').upsert(syncPayload, { 
          onConflict: item.variant_id ? 'user_id, product_id, variant_id' : 'user_id, product_id' 
        });
      }
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
