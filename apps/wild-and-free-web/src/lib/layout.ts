import { supabase } from './supabase.js';
import { getRole, requireRole } from './role.js';
import { ensureProfile } from './profile.js';
import { cartStore, CartEvents } from './cart.js';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  image: string;
}

interface WishlistItem {
  id: string;
  name: string;
  price: number;
  image: string;
}

interface CartDetail {
  cart: CartItem[];
  wishlist: WishlistItem[];
  count: number;
}

// --- Sidebar Core Logic ---
const setupSidebar = () => {
  const body = document.body;
  const trigger = document.getElementById('sidebar-trigger');
  const closeBtn = document.getElementById('sidebar-close');
  const overlay = document.getElementById('sidebar-overlay');
  const sidebar = document.getElementById('sidebar');

  if (trigger) {
    trigger.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      body.classList.toggle('sidebar-open');
    });
  }

  if (closeBtn) {
    closeBtn.addEventListener('click', (e) => {
      e.preventDefault();
      e.stopPropagation();
      body.classList.remove('sidebar-open');
    });
  }

  if (overlay) {
    overlay.addEventListener('click', () => {
      body.classList.remove('sidebar-open');
    });
  }

  document.addEventListener('click', (e) => {
    if (body.classList.contains('sidebar-open')) {
      const target = e.target;
      if (target instanceof Node && !sidebar?.contains(target) && !trigger?.contains(target)) {
        body.classList.remove('sidebar-open');
      }
    }
  });
};

// --- Cart & Wishlist UI ---
const updateCartUI = (detail: CartDetail) => {
  const { cart, wishlist, count } = detail;

  const cartCountEl = document.querySelector('[data-target="cart-popover"] span');
  const wishlistCountEl = document.querySelector('[data-target="wishlist-popover"] span');

  if (cartCountEl) {
    cartCountEl.textContent = count.toString();
    cartCountEl.classList.toggle('hidden', count === 0);
    cartCountEl.parentElement?.classList.add('scale-110', 'text-wild-orange');
    setTimeout(() => cartCountEl.parentElement?.classList.remove('scale-110', 'text-wild-orange'), 200);
  }
  if (wishlistCountEl) {
    wishlistCountEl.textContent = wishlist.length.toString();
    wishlistCountEl.classList.toggle('hidden', wishlist.length === 0);
    wishlistCountEl.parentElement?.classList.add('scale-110', 'text-wild-orange');
    setTimeout(() => wishlistCountEl.parentElement?.classList.remove('scale-110', 'text-wild-orange'), 200);
  }

  const cartContent = document.querySelector('#cart-popover .auth-popover-content');
  if (cartContent) {
    if (cart.length === 0) {
      cartContent.innerHTML = '<p class="text-[10px] text-center text-gray-500 font-bold uppercase tracking-widest py-8">Tu carrito está vacío</p>';
    } else {
      const itemsHtml = cart.map(item => `
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-white/5 transition-colors group relative">
          <div class="w-12 h-12 rounded-md overflow-hidden bg-white/5 flex-shrink-0">
            <img src="${item.image}" width="48" height="48" class="w-full h-full object-cover" />
          </div>
          <div class="flex-1 min-w-0">
            <h4 class="text-[10px] font-black uppercase text-white truncate group-hover:text-[var(--primary)] transition-colors">${item.name}</h4>
            <div class="flex justify-between items-center mt-1">
              <p class="text-[9px] text-gray-500 font-bold uppercase tracking-wider">x${item.quantity}</p>
              <p class="text-[10px] font-black text-white">$${(item.price * item.quantity).toFixed(2)}</p>
            </div>
          </div>
          <button class="w-6 h-6 flex items-center justify-center text-gray-500 hover:text-red-500 transition-colors remove-cart-btn opacity-0 group-hover:opacity-100" data-id="${item.id}">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
          </button>
        </div>
      `).join('');

      const total = cart.reduce((acc, item) => acc + (item.price * item.quantity), 0);

      cartContent.innerHTML = `
        <div class="space-y-1 max-h-[300px] overflow-y-auto pr-1 custom-scrollbar">
          ${itemsHtml}
        </div>
        <div class="border-t border-white/10 pt-4 mt-2 space-y-4">
          <div class="flex justify-between items-center px-2">
            <span class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Total</span>
            <span class="text-sm font-black text-[var(--primary)]">$${total.toFixed(2)}</span>
          </div>
          <a href="/checkout" class="block w-full py-3 bg-white text-black text-center text-[10px] font-black uppercase tracking-[0.2em] rounded-xl hover:bg-[var(--primary)] hover:text-black transition-all shadow-lg transform hover:-translate-y-0.5">Finalizar Compra</a>
        </div>
      `;

      cartContent.querySelectorAll('.remove-cart-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
          e.stopPropagation();
          const target = e.currentTarget as HTMLElement;
          if (target && target.dataset.id) {
            cartStore.removeFromCart(target.dataset.id);
          }
        });
      });
    }
  }

  const wishlistContent = document.querySelector('#wishlist-popover .auth-popover-content');
  if (wishlistContent) {
    if (wishlist.length === 0) {
      wishlistContent.innerHTML = '<p class="text-[10px] text-center text-gray-500 font-bold uppercase tracking-widest py-8">Tu lista está vacía</p>';
    } else {
      const itemsHtml = wishlist.map(item => `
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-white/5 transition-colors group relative">
          <div class="w-10 h-10 rounded-md overflow-hidden bg-white/5 flex-shrink-0">
            <img src="${item.image}" width="40" height="40" class="w-full h-full object-cover" />
          </div>
          <div class="flex-1 min-w-0">
            <h4 class="text-[10px] font-black uppercase text-white truncate group-hover:text-[var(--primary)] transition-colors">${item.name}</h4>
            <p class="text-[10px] font-bold text-gray-400 mt-0.5">$${item.price}</p>
          </div>
          <button class="w-8 h-8 rounded-full bg-[var(--primary)] text-black flex items-center justify-center transform scale-0 group-hover:scale-100 transition-all duration-300 add-from-wishlist-btn shadow-[0_0_10px_var(--primary)] hover:bg-white" data-id="${item.id}">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M12 5v14M5 12h14"/></svg>
          </button>
        </div>
      `).join('');

      wishlistContent.innerHTML = `
        <div class="space-y-1 max-h-[300px] overflow-y-auto pr-1 custom-scrollbar">
          ${itemsHtml}
        </div>
        <a href="/perfil" class="block w-full py-2 bg-white/5 border border-white/10 text-white text-center text-[10px] font-black uppercase tracking-widest rounded-lg hover:bg-[var(--primary)] hover:text-black hover:border-[var(--primary)] transition-all mt-3">Ver Todos</a>
      `;

      wishlistContent.querySelectorAll('.add-from-wishlist-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
          e.stopPropagation();
          const target = e.currentTarget as HTMLElement;
          if (target && target.dataset.id) {
            const item = wishlist.find(i => i.id == target.dataset.id);
            if (item) cartStore.addToCart(item);
          }
        });
      });
    }
  }
};

// --- Auth & Session Logic ---
const updateAuthUI = async () => {
  const authContainer = document.querySelector('.auth-actions-container');
  const { data: { session } } = await supabase.auth.getSession();
  const { role } = await getRole();
  (window as any).__wildRole = role;
  (window as any).requireRole = requireRole;
  document.documentElement.setAttribute('data-role', role || '');

  if (session) {
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', session.user.id)
      .single();

    if (profileError) {
      await ensureProfile(session);
    }

    document.querySelectorAll('.unauth-popover-msg').forEach(el => el.classList.add('hidden'));
    document.querySelectorAll('.auth-popover-content').forEach(el => el.classList.remove('hidden'));

    if (authContainer) {
      authContainer.innerHTML = `
        <div class="relative group/pop">
          <a href="/perfil" class="flex items-center gap-3 px-4 py-2 bg-white/5 border border-white/10 rounded-2xl hover:bg-white/10 hover:border-[var(--primary)]/50 transition-all cursor-pointer group">
            <div class="w-8 h-8 rounded-full bg-gradient-to-br from-[var(--primary)] to-[var(--secondary)] flex items-center justify-center text-[10px] font-black uppercase text-white shadow-[0_0_10px_rgba(201,131,0,0.3)] group-hover:shadow-[0_0_15px_var(--primary)] transition-all">
              ${(profile as any)?.nombre?.substring(0, 2) || 'WG'}
            </div>
            <div class="hidden md:flex flex-col">
              <span class="text-[10px] font-black uppercase tracking-widest text-white group-hover:text-[var(--primary)] transition-colors leading-none mb-0.5">${(profile as any)?.nombre?.split(' ')[0] || 'Usuario'}</span>
              <span class="text-[8px] font-bold text-gray-500 uppercase tracking-wider">Miembro</span>
            </div>
          </a>
          <div class="popover w-64">
            <div class="popover-header">
              <span class="popover-title">Mi Cuenta</span>
              <span class="text-[9px] text-[var(--primary)] font-mono">${role === 'admin' ? 'ADMIN' : 'MEMBER'}</span>
            </div>
            <div class="popover-content space-y-2">
              <a href="/perfil" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-white/5 group transition-colors">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="text-gray-400 group-hover:text-white"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                <span class="text-[10px] font-bold uppercase tracking-widest text-gray-300 group-hover:text-white">Mi Perfil</span>
              </a>
              <a href="/pedidos" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-white/5 group transition-colors">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="text-gray-400 group-hover:text-white"><path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path><path d="M22 12A10 10 0 0 0 12 2v10z"></path></svg>
                <span class="text-[10px] font-bold uppercase tracking-widest text-gray-300 group-hover:text-white">Mis Pedidos</span>
              </a>
              <a href="/configuracion" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-white/5 group transition-colors">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="text-gray-400 group-hover:text-white"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                <span class="text-[10px] font-bold uppercase tracking-widest text-gray-300 group-hover:text-white">Configuración</span>
              </a>
              <div class="h-px bg-white/10 my-2"></div>
              <button id="logout-btn" class="w-full flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-red-500/10 group transition-colors text-left">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="text-red-500"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><polyline points="16 17 21 12 16 7"></polyline><line x1="21" y1="12" x2="9" y2="12"></line></svg>
                <span class="text-[10px] font-black uppercase tracking-widest text-red-500 group-hover:text-red-400">Cerrar Sesión</span>
              </button>
            </div>
          </div>
        </div>
      `;

      document.getElementById('logout-btn')?.addEventListener('click', async () => {
        await supabase.auth.signOut();
        window.location.reload();
      });
    }

    document.querySelectorAll('.unauth-popover-msg').forEach(el => el.classList.add('hidden'));
    document.querySelectorAll('.auth-popover-content').forEach(el => el.classList.remove('hidden'));
  } else {
    document.querySelectorAll('.unauth-popover-msg').forEach(el => el.classList.remove('hidden'));
    document.querySelectorAll('.auth-popover-content').forEach(el => el.classList.add('hidden'));
  }

  document.body.setAttribute('data-auth-loaded', 'true');
};


// --- Popover Logic ---
const initPopovers = () => {
  const triggers = document.querySelectorAll('.popover-trigger');
  const popovers = document.querySelectorAll('.popover');

  triggers.forEach(trigger => {
    trigger.addEventListener('click', (e) => {
      e.stopPropagation();
      const targetId = trigger.getAttribute('data-target');
      if (!targetId) return;
      const targetPopover = document.getElementById(targetId);
      const isActive = targetPopover?.classList.contains('active');
      popovers.forEach(p => p.classList.remove('active'));
      if (!isActive) targetPopover?.classList.add('active');
    });
  });

  document.addEventListener('click', (e) => {
    if (document.body.classList.contains('sidebar-open')) {
      const sidebar = document.getElementById('sidebar');
      const trigger = document.getElementById('sidebar-trigger');
      const target = e.target;
      if (target instanceof Node && !sidebar?.contains(target) && !trigger?.contains(target)) {
        document.body.classList.remove('sidebar-open');
      }
    }

    const el = e.target instanceof Element ? e.target : null;
    const isTrigger = el?.closest('.popover-trigger');
    const isPopover = el?.closest('.popover');
    if (!isTrigger && !isPopover) {
      popovers.forEach(p => p.classList.remove('active'));
    }
  });
};

// --- Main Init ---
const init = async () => {
  initPopovers();
  await updateAuthUI();
  cartStore.init();

  window.addEventListener(CartEvents.UPDATED, (e: Event) => updateCartUI((e as CustomEvent).detail));
  window.addEventListener(CartEvents.WISHLIST_UPDATED, (e: Event) => updateCartUI((e as CustomEvent).detail));

  updateCartUI({
    cart: cartStore.cart,
    wishlist: cartStore.wishlist,
    count: cartStore.cart.reduce((acc: number, item: CartItem) => acc + item.quantity, 0)
  });
};

// --- Header Scroll Effect ---
const setupHeaderScroll = () => {
  window.addEventListener('scroll', () => {
    const header = document.querySelector('header');
    if (window.scrollY > 50) {
      header?.classList.add('bg-black/95', 'py-2');
      header?.classList.remove('bg-black/90', 'py-0');
    } else {
      header?.classList.add('bg-black/90', 'py-0');
      header?.classList.remove('bg-black/95', 'py-2');
    }
  });
};

export function initLayout() {
  setupSidebar();
  setupHeaderScroll();
  init();
}
