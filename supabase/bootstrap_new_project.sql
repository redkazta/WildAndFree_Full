-- =====================================================
-- BOOTSTRAP COMPLETO PARA PROYECTO SUPABASE NUEVO
-- Proyecto: hepsyuwaymwlvyaddecs
-- Ejecutar TODO este archivo en el SQL Editor de Supabase.
-- Crea esquema base, roles, RLS, feed, tickets, sponsors,
-- torneos de escritas y radio.
-- =====================================================

-- =====================================================
-- WILD GNVG MUSIC HUB - COMPLETE DATABASE SCHEMA v3
-- =====================================================
-- Estructura en capas claras
-- Fecha: 2024-06-27 (v3: 2024-06-27)
-- Agregados: cart_items, wishlist_items, favorites, role 'name' alias
-- =====================================================

-- =====================================================
-- CAPA 1: AUTH (Supabase maneja esto)
-- auth.users ya existe con: id, email, password, metadata
-- No tocar esta tabla
-- =====================================================

-- =====================================================
-- CAPA 2: PROFILES (datos del usuario)
-- =====================================================

-- Tabla principal de perfiles (1:1 con auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,

  -- Datos básicos
  nombre TEXT,
  username TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  phone TEXT,
  birthdate DATE,
  ubicacion TEXT,

  -- Redes sociales
  website TEXT,
  spotify_url TEXT,
  youtube_url TEXT,
  instagram_url TEXT,
  twitter_url TEXT,
  tiktok_url TEXT,

  -- Verificación de artista
  is_verified_artist BOOLEAN DEFAULT FALSE,
  verification_status TEXT DEFAULT 'none' CHECK (verification_status IN ('none', 'pending', 'approved', 'rejected')),
  spotify_artist_id TEXT,

  -- Estado en línea
  is_online BOOLEAN DEFAULT FALSE,
  last_seen_at TIMESTAMPTZ,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CAPA 3: ROLES (quién es quién)
-- =====================================================

-- Catálogo de roles
CREATE TABLE IF NOT EXISTS public.roles (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  internal_name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Permisos
CREATE TABLE IF NOT EXISTS public.permissions (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  module TEXT NOT NULL
);

-- Relación rol → permisos
CREATE TABLE IF NOT EXISTS public.role_permissions (
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  permission_id INTEGER REFERENCES public.permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

-- Relación usuario → roles (un usuario puede tener varios roles)
CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by UUID REFERENCES public.profiles(id),
  PRIMARY KEY (user_id, role_id)
);

-- =====================================================
-- CAPA 4: SOCIAL (muro, amistad, seguimiento)
-- =====================================================

-- Posts del muro
CREATE TABLE IF NOT EXISTS public.wall_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Comentarios
CREATE TABLE IF NOT EXISTS public.wall_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.wall_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Likes
CREATE TABLE IF NOT EXISTS public.wall_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.wall_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Reposts
CREATE TABLE IF NOT EXISTS public.wall_reposts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.wall_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Solicitudes de amistad (miembro ↔ miembro)
CREATE TABLE IF NOT EXISTS public.friendships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  requester_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  addressee_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(requester_id, addressee_id)
);

-- Seguimientos (fan → artista)
CREATE TABLE IF NOT EXISTS public.follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  follower_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  following_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- =====================================================
-- CAPA 5: MESSAGING (chat)
-- =====================================================

-- Conversaciones
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT DEFAULT 'direct' CHECK (type IN ('direct', 'group')),
  name TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Miembros de conversación
CREATE TABLE IF NOT EXISTS public.conversation_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('member', 'admin')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  UNIQUE(conversation_id, user_id)
);

-- Mensajes
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  CHECK (content IS NOT NULL OR image_url IS NOT NULL)
);

-- Estado de lectura
CREATE TABLE IF NOT EXISTS public.message_read_status (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  message_id UUID REFERENCES public.messages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(message_id, user_id)
);

-- Solicitudes de mensajes (para artistas)
CREATE TABLE IF NOT EXISTS public.message_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CAPA 6: TAGS (badges decorativos)
-- =====================================================

-- Categorías de tags
CREATE TABLE IF NOT EXISTS public.tag_categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tags
CREATE TABLE IF NOT EXISTS public.tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  color VARCHAR(7) DEFAULT '#ffffff',
  animation VARCHAR(50) DEFAULT 'none',
  category_id INTEGER REFERENCES public.tag_categories(id),
  token_price INTEGER,
  is_purchasable BOOLEAN DEFAULT FALSE,
  achievement_key TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Relación usuario → tags
CREATE TABLE IF NOT EXISTS public.user_has_tags (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  tag_id INTEGER REFERENCES public.tags(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by UUID REFERENCES public.profiles(id),
  PRIMARY KEY (user_id, tag_id)
);

-- =====================================================
-- CAPA 7: SHOP (tienda)
-- =====================================================

-- Productos
CREATE TABLE IF NOT EXISTS public.store_products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  base_price NUMERIC(10,2) NOT NULL,
  image_url TEXT,
  category TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Variantes (talla, color)
CREATE TABLE IF NOT EXISTS public.product_variants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID REFERENCES public.store_products(id) ON DELETE CASCADE,
  size TEXT,
  color TEXT,
  stock INTEGER DEFAULT 0,
  sku TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Pedidos
CREATE TABLE IF NOT EXISTS public.store_orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled')),
  shipping_type TEXT CHECK (shipping_type IN ('pickup', 'local_delivery', 'carrier')),
  tracking_guide TEXT,
  shipping_address TEXT,
  delivery_schedule TIMESTAMPTZ,
  payment_method TEXT CHECK (payment_method IN ('transfer', 'cash', 'card', 'terminal')),
  total NUMERIC(10,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Items del pedido
CREATE TABLE IF NOT EXISTS public.store_order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES public.store_orders(id) ON DELETE CASCADE,
  variant_id UUID REFERENCES public.product_variants(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CAPA 8: TOKENS (economía interna)
-- =====================================================

-- Balance de tokens por usuario
CREATE TABLE IF NOT EXISTS public.user_tokens (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
  balance INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Historial de compras
CREATE TABLE IF NOT EXISTS public.token_purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  ip_address TEXT,
  amount INTEGER NOT NULL,
  price_mxn NUMERIC(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  stripe_payment_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transacciones (compra, gasto, ganancia)
CREATE TABLE IF NOT EXISTS public.token_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('purchase', 'earn', 'spend', 'refund', 'expire')),
  amount INTEGER NOT NULL,
  reference TEXT,
  reference_id UUID,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CAPA 9: CONTENT (contenido exclusivo)
-- =====================================================

-- Contenido exclusivo de artistas
CREATE TABLE IF NOT EXISTS public.exclusive_content (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  content_type TEXT NOT NULL CHECK (content_type IN ('video', 'audio', 'download')),
  file_url TEXT,
  preview_url TEXT,
  token_price INTEGER DEFAULT 0,
  real_price_mxn NUMERIC(10,2),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'published')),
  rejection_reason TEXT,
  approved_by UUID REFERENCES public.profiles(id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Compras de contenido
CREATE TABLE IF NOT EXISTS public.content_purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content_id UUID REFERENCES public.exclusive_content(id) ON DELETE CASCADE,
  payment_type TEXT CHECK (payment_type IN ('token', 'real')),
  tokens_spent INTEGER DEFAULT 0,
  real_amount_mxn NUMERIC(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, content_id)
);

-- Posts del crew (publicaciones generales)
CREATE TABLE IF NOT EXISTS public.crew_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT,
  content TEXT,
  image_url TEXT,
  post_type TEXT DEFAULT 'general' CHECK (post_type IN ('general', 'announcement', 'event', 'promotion')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'published', 'rejected')),
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CAPA 10: EVENTS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  event_type TEXT CHECK (event_type IN ('battle', 'concert', 'meet_greet', 'other')),
  event_date TIMESTAMPTZ NOT NULL,
  location TEXT,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CAPA 11: VERSUS (mini-juego de freestylers)
-- =====================================================

-- Freestylers
CREATE TABLE IF NOT EXISTS public.freestylers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stats de freestylers
CREATE TABLE IF NOT EXISTS public.freestyler_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  freestyler_id UUID REFERENCES public.freestylers(id) ON DELETE CASCADE,
  stat_name TEXT NOT NULL CHECK (stat_name IN ('flow', 'punchline', 'estructura', 'puesta_en_escena', 'doble_tempo', 'figuras_literarias')),
  stat_value INTEGER DEFAULT 50 CHECK (stat_value >= 0 AND stat_value <= 100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(freestyler_id, stat_name)
);

-- Batallas
CREATE TABLE IF NOT EXISTS public.versus_battles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  freestyler1_id UUID REFERENCES public.freestylers(id),
  freestyler2_id UUID REFERENCES public.freestylers(id),
  winner_id UUID REFERENCES public.freestylers(id),
  total_votes INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- Votos de fans
CREATE TABLE IF NOT EXISTS public.versus_votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  battle_id UUID REFERENCES public.versus_battles(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  voted_for UUID REFERENCES public.freestylers(id),
  tokens_earned INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(battle_id, user_id)
);

-- Control de votos diarios
CREATE TABLE IF NOT EXISTS public.user_battle_votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  vote_date DATE DEFAULT CURRENT_DATE,
  votes_today INTEGER DEFAULT 0,
  UNIQUE(user_id, vote_date)
);

-- =====================================================
-- CAPA 12: NOTIFICATIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('follow', 'like', 'comment', 'message', 'content_approved', 'content_rejected', 'order_update', 'verification', 'system')),
  title TEXT NOT NULL,
  body TEXT,
  reference_type TEXT,
  reference_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CAPA 13: ACTIVITY LOG (para reports)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id),
  action TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  metadata JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES
-- =====================================================

-- Profiles
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_verification ON public.profiles(verification_status);

-- Social
CREATE INDEX IF NOT EXISTS idx_wall_posts_user ON public.wall_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_wall_posts_created ON public.wall_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wall_comments_post ON public.wall_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_wall_likes_post ON public.wall_likes(post_id);

-- Friendship
CREATE INDEX IF NOT EXISTS idx_friendships_requester ON public.friendships(requester_id);
CREATE INDEX IF NOT EXISTS idx_friendships_addressee ON public.friendships(addressee_id);
CREATE INDEX IF NOT EXISTS idx_follows_follower ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON public.follows(following_id);

-- Messaging
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversation_members_user ON public.conversation_members(user_id);

-- Tokens
CREATE INDEX IF NOT EXISTS idx_token_purchases_user ON public.token_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_token_purchases_ip ON public.token_purchases(ip_address);
CREATE INDEX IF NOT EXISTS idx_token_transactions_user ON public.token_transactions(user_id);

-- Content
CREATE INDEX IF NOT EXISTS idx_exclusive_content_user ON public.exclusive_content(user_id);
CREATE INDEX IF NOT EXISTS idx_exclusive_content_status ON public.exclusive_content(status);

-- Shop
CREATE INDEX IF NOT EXISTS idx_store_orders_user ON public.store_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_store_orders_status ON public.store_orders(status);
CREATE INDEX IF NOT EXISTS idx_product_variants_product ON public.product_variants(product_id);

-- Versus
CREATE INDEX IF NOT EXISTS idx_freestyler_stats_freestyler ON public.freestyler_stats(freestyler_id);
CREATE INDEX IF NOT EXISTS idx_versus_battles_freestyler1 ON public.versus_battles(freestyler1_id);
CREATE INDEX IF NOT EXISTS idx_versus_battles_freestyler2 ON public.versus_battles(freestyler2_id);
CREATE INDEX IF NOT EXISTS idx_versus_votes_battle ON public.versus_votes(battle_id);
CREATE INDEX IF NOT EXISTS idx_versus_votes_user ON public.versus_votes(user_id);

-- Notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = FALSE;

-- Activity Log
CREATE INDEX IF NOT EXISTS idx_activity_log_user ON public.activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_created ON public.activity_log(created_at DESC);

-- =====================================================
-- RLS POLICIES
-- =====================================================

-- Profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Roles
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Roles are viewable by everyone" ON public.roles FOR SELECT USING (true);

-- Permissions
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Permissions are viewable by everyone" ON public.permissions FOR SELECT USING (true);

-- Role Permissions
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Role permissions are viewable by everyone" ON public.role_permissions FOR SELECT USING (true);

-- User Roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "User roles are viewable by everyone" ON public.user_roles FOR SELECT USING (true);

-- Wall Posts
ALTER TABLE public.wall_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Wall posts are viewable by everyone" ON public.wall_posts FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "Users can create own posts" ON public.wall_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own posts" ON public.wall_posts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own posts" ON public.wall_posts FOR DELETE USING (auth.uid() = user_id);

-- Wall Comments
ALTER TABLE public.wall_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Comments are viewable by everyone" ON public.wall_comments FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "Users can create comments" ON public.wall_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.wall_comments FOR DELETE USING (auth.uid() = user_id);

-- Wall Likes
ALTER TABLE public.wall_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Likes are viewable by everyone" ON public.wall_likes FOR SELECT USING (true);
CREATE POLICY "Users can like posts" ON public.wall_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike posts" ON public.wall_likes FOR DELETE USING (auth.uid() = user_id);

-- Wall Reposts
ALTER TABLE public.wall_reposts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Reposts are viewable by everyone" ON public.wall_reposts FOR SELECT USING (true);
CREATE POLICY "Users can repost" ON public.wall_reposts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can undo repost" ON public.wall_reposts FOR DELETE USING (auth.uid() = user_id);

-- Friendships
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own friendships" ON public.friendships FOR SELECT USING (auth.uid() = requester_id OR auth.uid() = addressee_id);
CREATE POLICY "Users can send friend requests" ON public.friendships FOR INSERT WITH CHECK (auth.uid() = requester_id);
CREATE POLICY "Users can update own friendships" ON public.friendships FOR UPDATE USING (auth.uid() = addressee_id);

-- Follows
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Follows are viewable by everyone" ON public.follows FOR SELECT USING (true);
CREATE POLICY "Users can follow others" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.follows FOR DELETE USING (auth.uid() = follower_id);

-- Conversations
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own conversations" ON public.conversations FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.conversation_members WHERE conversation_id = id AND user_id = auth.uid() AND left_at IS NULL)
);

-- Conversation Members
ALTER TABLE public.conversation_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can view conversation members" ON public.conversation_members FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.conversation_members cm WHERE cm.conversation_id = conversation_members.conversation_id AND cm.user_id = auth.uid() AND cm.left_at IS NULL)
);

-- Messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Members can view messages" ON public.messages FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.conversation_members WHERE conversation_id = messages.conversation_id AND user_id = auth.uid() AND left_at IS NULL)
);
CREATE POLICY "Members can send messages" ON public.messages FOR INSERT WITH CHECK (
  auth.uid() = sender_id AND
  EXISTS (SELECT 1 FROM public.conversation_members WHERE conversation_id = messages.conversation_id AND user_id = auth.uid() AND left_at IS NULL)
);

-- Message Read Status
ALTER TABLE public.message_read_status ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own read status" ON public.message_read_status FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can mark as read" ON public.message_read_status FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Message Requests
ALTER TABLE public.message_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own message requests" ON public.message_requests FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send message requests" ON public.message_requests FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Receivers can update request status" ON public.message_requests FOR UPDATE USING (auth.uid() = receiver_id);

-- Tags
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tags are viewable by everyone" ON public.tags FOR SELECT USING (true);

-- Tag Categories
ALTER TABLE public.tag_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Tag categories are viewable by everyone" ON public.tag_categories FOR SELECT USING (true);

-- User Has Tags
ALTER TABLE public.user_has_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "User tags are viewable by everyone" ON public.user_has_tags FOR SELECT USING (true);

-- Store Products
ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active products are viewable by everyone" ON public.store_products FOR SELECT USING (is_active = true);

-- Product Variants
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Variants are viewable by everyone" ON public.product_variants FOR SELECT USING (true);

-- Store Orders
ALTER TABLE public.store_orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own orders" ON public.store_orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create orders" ON public.store_orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Store Order Items
ALTER TABLE public.store_order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own order items" ON public.store_order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.store_orders WHERE id = order_id AND user_id = auth.uid())
);

-- User Tokens
ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own token balance" ON public.user_tokens FOR SELECT USING (auth.uid() = user_id);

-- Token Purchases
ALTER TABLE public.token_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own purchases" ON public.token_purchases FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create purchases" ON public.token_purchases FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Token Transactions
ALTER TABLE public.token_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own transactions" ON public.token_transactions FOR SELECT USING (auth.uid() = user_id);

-- Exclusive Content
ALTER TABLE public.exclusive_content ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Published content is viewable by everyone" ON public.exclusive_content FOR SELECT USING (status = 'published');
CREATE POLICY "Artists can view own content" ON public.exclusive_content FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Artists can create content" ON public.exclusive_content FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Artists can update own content" ON public.exclusive_content FOR UPDATE USING (auth.uid() = user_id);

-- Content Purchases
ALTER TABLE public.content_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own purchases" ON public.content_purchases FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create purchases" ON public.content_purchases FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Crew Posts
ALTER TABLE public.crew_posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Published crew posts are viewable by everyone" ON public.crew_posts FOR SELECT USING (status = 'published');

-- Events
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active events are viewable by everyone" ON public.events FOR SELECT USING (is_active = true);

-- Freestylers
ALTER TABLE public.freestylers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Active freestylers are viewable by everyone" ON public.freestylers FOR SELECT USING (is_active = true);

-- Freestyler Stats
ALTER TABLE public.freestyler_stats ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Stats are viewable by everyone" ON public.freestyler_stats FOR SELECT USING (true);

-- Versus Battles
ALTER TABLE public.versus_battles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Battles are viewable by everyone" ON public.versus_battles FOR SELECT USING (true);

-- Versus Votes
ALTER TABLE public.versus_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own votes" ON public.versus_votes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can vote" ON public.versus_votes FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User Battle Votes
ALTER TABLE public.user_battle_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own vote count" ON public.user_battle_votes FOR SELECT USING (auth.uid() = user_id);

-- Notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

-- Activity Log
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own activity" ON public.activity_log FOR SELECT USING (auth.uid() = user_id);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Actualizar balance de tokens después de compra
CREATE OR REPLACE FUNCTION update_token_balance()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'completed' THEN
    INSERT INTO public.user_tokens (user_id, balance, expires_at)
    VALUES (NEW.user_id, NEW.amount, NOW() + INTERVAL '1 month')
    ON CONFLICT (user_id) DO UPDATE SET
      balance = user_tokens.balance + NEW.amount,
      expires_at = GREATEST(user_tokens.expires_at, NOW() + INTERVAL '1 month'),
      updated_at = NOW();

    INSERT INTO public.token_transactions (user_id, type, amount, reference, description)
    VALUES (NEW.user_id, 'purchase', NEW.amount, 'token_purchase', 'Compra de tokens');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_token_purchase ON public.token_purchases;
CREATE TRIGGER on_token_purchase
  AFTER INSERT OR UPDATE ON public.token_purchases
  FOR EACH ROW
  EXECUTE FUNCTION update_token_balance();

-- Verificar límite de tokens por IP
CREATE OR REPLACE FUNCTION check_token_ip_limit(p_ip TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  total_today INTEGER;
BEGIN
  SELECT COALESCE(SUM(amount), 0) INTO total_today
  FROM public.token_purchases
  WHERE ip_address = p_ip
    AND created_at >= CURRENT_DATE
    AND status = 'completed';

  RETURN total_today < 10;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Contar votos diarios de versus
CREATE OR REPLACE FUNCTION check_battle_vote_limit(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  votes_today INTEGER;
BEGIN
  SELECT COALESCE(votes_today, 0) INTO votes_today
  FROM public.user_battle_votes
  WHERE user_id = p_user_id
    AND vote_date = CURRENT_DATE;

  RETURN votes_today;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Roles por defecto
INSERT INTO public.roles (name, internal_name, display_name, description, is_system) VALUES
  ('owner', 'owner', 'Dueño', 'Control total del crew', true),
  ('admin', 'admin', 'Admin', 'Gestión completa del sistema', true),
  ('staff_manager', 'staff_manager', 'Staff Senior', 'Gestión administrativa con privilegios extendidos', false),
  ('staff', 'staff', 'Staff', 'Operaciones básicas del sistema', false),
  ('staff_marketing', 'staff_marketing', 'Marketing', 'Publicación de contenido del crew', false),
  ('artist', 'artist', 'Artista', 'Perfil verificado, sube contenido', true),
  ('fan', 'fan', 'Miembro', 'Interactúa, compra, sigue artistas', true),
  ('guest', 'guest', 'Visitante', 'Solo ve contenido público', true)
ON CONFLICT (name) DO NOTHING;

-- Categorías de tags
INSERT INTO public.tag_categories (name, description) VALUES
  ('cosmetic', 'Tags decorativos cosméticos'),
  ('achievement', 'Tags ganados por logros'),
  ('purchasable', 'Tags comprables con tokens'),
  ('event', 'Tags de eventos especiales')
ON CONFLICT (name) DO NOTHING;

-- Permisos base
INSERT INTO public.permissions (name, description, module) VALUES
  ('orders.view', 'Ver pedidos', 'orders'),
  ('orders.manage', 'Gestionar pedidos', 'orders'),
  ('orders.ship', 'Marcar envíos', 'orders'),
  ('inventory.view', 'Ver inventario', 'inventory'),
  ('inventory.manage', 'Gestionar productos', 'inventory'),
  ('content.view', 'Ver contenido pendiente', 'content'),
  ('content.approve', 'Aprobar/rechazar contenido', 'content'),
  ('content.create_crew', 'Crear contenido del crew', 'content'),
  ('users.view', 'Ver usuarios', 'users'),
  ('users.manage', 'Gestionar usuarios y roles', 'users'),
  ('users.verify_artist', 'Aprobar verificación de artistas', 'users'),
  ('tags.manage', 'Gestionar tags', 'tags'),
  ('events.manage', 'Gestionar eventos', 'events'),
  ('versus.manage', 'Gestionar freestylers y stats', 'versus'),
  ('config.manage', 'Configurar el sistema', 'config'),
  ('reports.view', 'Ver reportes', 'reports')
ON CONFLICT (name) DO NOTHING;

-- Asignar permisos a roles
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff_manager'
AND p.name IN ('orders.view', 'orders.manage', 'orders.ship', 'inventory.view', 'inventory.manage', 'content.view', 'content.approve', 'users.view', 'reports.view')
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff'
AND p.name IN ('orders.view', 'orders.manage', 'inventory.view', 'content.view', 'content.approve')
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff_marketing'
AND p.name IN ('content.view', 'content.create_crew')
ON CONFLICT DO NOTHING;

-- =====================================================
-- CAPA 7B: CART & WISHLIST (compatibilidad con código existente)
-- =====================================================

-- Carrito de compras (staging antes de checkout)
CREATE TABLE IF NOT EXISTS public.cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Lista de deseos
CREATE TABLE IF NOT EXISTS public.wishlist_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- =====================================================
-- CAPA 14: FAVORITES (música favorita)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  track_id TEXT NOT NULL,
  track_data JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, track_id)
);

-- =====================================================
-- INDEXES CARrito & WISHLIST & FAVORITES
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_cart_items_user ON public.cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_wishlist_items_user ON public.wishlist_items(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites(user_id);

-- =====================================================
-- RLS: CART, WISHLIST, FAVORITES
-- =====================================================
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own cart" ON public.cart_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own cart" ON public.cart_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own cart" ON public.cart_items FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own cart" ON public.cart_items FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own wishlist" ON public.wishlist_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own wishlist" ON public.wishlist_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own wishlist" ON public.wishlist_items FOR DELETE USING (auth.uid() = user_id);

ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own favorites" ON public.favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own favorites" ON public.favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON public.favorites FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- SCHEMA COMPLETO - 33 TABLAS
-- =====================================================
-- Capa 1: auth.users (Supabase)
-- Capa 2: profiles
-- Capa 3: roles, permissions, role_permissions, user_roles
-- Capa 4: wall_posts, wall_comments, wall_likes, wall_reposts, friendships, follows
-- Capa 5: conversations, conversation_members, messages, message_read_status, message_requests
-- Capa 6: tag_categories, tags, user_has_tags
-- Capa 7: store_products, product_variants, store_orders, store_order_items
-- Capa 7b: cart_items, wishlist_items
-- Capa 8: user_tokens, token_purchases, token_transactions
-- Capa 9: exclusive_content, content_purchases, crew_posts
-- Capa 10: events
-- Capa 11: freestylers, freestyler_stats, versus_battles, versus_votes, user_battle_votes
-- Capa 12: notifications
-- Capa 13: activity_log
-- Capa 14: favorites
-- =====================================================
-- Add artist-specific fields to profiles
-- =====================================================
-- These columns are nullable — only filled when role = 'artista'
-- Fans ("La Jauría") leave them null

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS stage_name TEXT,
  ADD COLUMN IF NOT EXISTS genres TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS social_links TEXT,
  ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'fan' CHECK (role IN ('fan', 'artist', 'staff', 'admin'));

-- Index for filtering artists
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
-- Create cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Create wishlist_items table
CREATE TABLE IF NOT EXISTS wishlist_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Enable RLS
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlist_items ENABLE ROW LEVEL SECURITY;

-- Policies for cart_items
CREATE POLICY "Users can view their own cart items" ON cart_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cart items" ON cart_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cart items" ON cart_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cart items" ON cart_items
  FOR DELETE USING (auth.uid() = user_id);

-- Policies for wishlist_items
CREATE POLICY "Users can view their own wishlist items" ON wishlist_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own wishlist items" ON wishlist_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own wishlist items" ON wishlist_items
  FOR DELETE USING (auth.uid() = user_id);
-- ============================================================
-- MIGRACIÓN: user_settings + account_deletion_requests
-- Fecha: 2026-07-01
-- Descripción: Tablas para configuración de usuario y solicitudes de eliminación
-- ============================================================

-- ── TABLA: user_settings ──
-- Almacena todas las preferencias/configuraciones del usuario
CREATE TABLE IF NOT EXISTS user_settings (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  
  -- Apariencia
  theme TEXT NOT NULL DEFAULT 'dark' CHECK (theme IN ('dark', 'light')),
  font_size TEXT NOT NULL DEFAULT 'medium' CHECK (font_size IN ('small', 'medium', 'large')),
  animations BOOLEAN NOT NULL DEFAULT true,
  
  -- Idioma y ubicación
  locale TEXT NOT NULL DEFAULT 'es' CHECK (locale IN ('es', 'en')),
  ubicacion TEXT NOT NULL DEFAULT 'Torreón',
  
  -- Reproducción
  autoplay BOOLEAN NOT NULL DEFAULT true,
  crossfade BOOLEAN NOT NULL DEFAULT false,
  streaming_quality TEXT NOT NULL DEFAULT 'medium' CHECK (streaming_quality IN ('low', 'medium', 'high')),
  offline_mode BOOLEAN NOT NULL DEFAULT false,
  auto_radio_spotify_playlist TEXT,
  
  -- Notificaciones push
  push_events BOOLEAN NOT NULL DEFAULT true,
  push_posts BOOLEAN NOT NULL DEFAULT true,
  push_comments BOOLEAN NOT NULL DEFAULT true,
  push_followers BOOLEAN NOT NULL DEFAULT false,
  
  -- Notificaciones email
  email_weekly BOOLEAN NOT NULL DEFAULT false,
  email_promos BOOLEAN NOT NULL DEFAULT false,
  
  -- Privacidad
  profile_public BOOLEAN NOT NULL DEFAULT true,
  show_ranking BOOLEAN NOT NULL DEFAULT true,
  history_enabled BOOLEAN NOT NULL DEFAULT true,
  share_data BOOLEAN NOT NULL DEFAULT false,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_settings_theme ON user_settings(theme);
CREATE INDEX IF NOT EXISTS idx_user_settings_locale ON user_settings(locale);

-- RLS (Row Level Security)
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Usuarios pueden ver y editar su propia configuración
CREATE POLICY "Users can view own settings" ON user_settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON user_settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON user_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- Policy: Admins pueden ver toda la configuración (para el ERP)
CREATE POLICY "Admins can view all settings" ON user_settings
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_user_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_user_settings_updated_at
  BEFORE UPDATE ON user_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_user_settings_updated_at();

-- ── TABLA: account_deletion_requests ──
-- Almacena solicitudes de eliminación de cuenta para revisión del ERP
CREATE TABLE IF NOT EXISTS account_deletion_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reason TEXT,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed_at TIMESTAMPTZ,
  processed_by UUID REFERENCES profiles(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_deletion_requests_user ON account_deletion_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_deletion_requests_status ON account_deletion_requests(status);
CREATE INDEX IF NOT EXISTS idx_deletion_requests_requested ON account_deletion_requests(requested_at DESC);

-- RLS
ALTER TABLE account_deletion_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Usuarios pueden crear solicitudes para su propia cuenta
CREATE POLICY "Users can create own deletion request" ON account_deletion_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Usuarios pueden ver sus propias solicitudes
CREATE POLICY "Users can view own deletion requests" ON account_deletion_requests
  FOR SELECT USING (auth.uid() = user_id);

-- Policy: Admins pueden ver y gestionar todas las solicitudes (ERP)
CREATE POLICY "Admins can view all deletion requests" ON account_deletion_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );

CREATE POLICY "Admins can update deletion requests" ON account_deletion_requests
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_roles ur
      JOIN roles r ON ur.role_id = r.id
      WHERE ur.user_id = auth.uid() AND r.name = 'admin'
    )
  );

-- ── FUNCIÓN: Crear settings por defecto al registrar usuario ──
-- Trigger que crea user_settings cuando se crea un perfil
CREATE OR REPLACE FUNCTION create_default_user_settings()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_create_default_user_settings
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_default_user_settings();

-- ── COMENTARIOS ──
COMMENT ON TABLE user_settings IS 'Preferencias/configuración de cada usuario en la plataforma Wild Gvng';
COMMENT ON TABLE account_deletion_requests IS 'Solicitudes de eliminación de cuenta enviadas por usuarios, revisables desde el ERP';
COMMENT ON COLUMN user_settings.theme IS 'Tema de la interfaz: dark o light';
COMMENT ON COLUMN user_settings.streaming_quality IS 'Calidad de streaming: low (128kbps), medium (256kbps), high (320kbps)';
COMMENT ON COLUMN account_deletion_requests.status IS 'Estado: pending, approved, rejected';
-- =====================================================
-- Functions and views for the social feed
-- =====================================================

-- Get feed posts with real reaction counts
CREATE OR REPLACE FUNCTION public.get_feed_posts(
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0,
  p_user_id UUID DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  content TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ,
  likes_count BIGINT,
  comments_count BIGINT,
  reposts_count BIGINT,
  is_liked BOOLEAN,
  is_reposted BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    wp.id,
    wp.user_id,
    p.username,
    p.nombre,
    p.avatar_url,
    wp.content,
    wp.image_url,
    wp.created_at,
    COALESCE(l.likes_count, 0)::BIGINT AS likes_count,
    COALESCE(c.comments_count, 0)::BIGINT AS comments_count,
    COALESCE(r.reposts_count, 0)::BIGINT AS reposts_count,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_likes wl WHERE wl.post_id = wp.id AND wl.user_id = p_user_id)
    ELSE FALSE END AS is_liked,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_reposts wr WHERE wr.post_id = wp.id AND wr.user_id = p_user_id)
    ELSE FALSE END AS is_reposted
  FROM public.wall_posts wp
  LEFT JOIN public.profiles p ON p.id = wp.user_id
  LEFT JOIN (SELECT post_id, COUNT(*) AS likes_count FROM public.wall_likes GROUP BY post_id) l ON l.post_id = wp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS comments_count FROM public.wall_comments WHERE deleted_at IS NULL GROUP BY post_id) c ON c.post_id = wp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS reposts_count FROM public.wall_reposts GROUP BY post_id) r ON r.post_id = wp.id
  WHERE wp.deleted_at IS NULL
  ORDER BY wp.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Get crew posts (artist profile feed) with reaction counts
CREATE OR REPLACE FUNCTION public.get_crew_feed(
  p_author_id UUID,
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0,
  p_user_id UUID DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  author_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  title TEXT,
  content TEXT,
  image_url TEXT,
  post_type TEXT,
  published_at TIMESTAMPTZ,
  likes_count BIGINT,
  comments_count BIGINT,
  reposts_count BIGINT,
  is_liked BOOLEAN,
  is_reposted BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    cp.id,
    cp.author_id,
    p.username,
    p.nombre,
    p.avatar_url,
    cp.title,
    cp.content,
    cp.image_url,
    cp.post_type,
    cp.published_at,
    COALESCE(l.likes_count, 0)::BIGINT AS likes_count,
    COALESCE(c.comments_count, 0)::BIGINT AS comments_count,
    COALESCE(r.reposts_count, 0)::BIGINT AS reposts_count,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_likes wl WHERE wl.post_id = cp.id AND wl.user_id = p_user_id)
    ELSE FALSE END AS is_liked,
    CASE WHEN p_user_id IS NOT NULL THEN
      EXISTS (SELECT 1 FROM public.wall_reposts wr WHERE wr.post_id = cp.id AND wr.user_id = p_user_id)
    ELSE FALSE END AS is_reposted
  FROM public.crew_posts cp
  LEFT JOIN public.profiles p ON p.id = cp.author_id
  LEFT JOIN (SELECT post_id, COUNT(*) AS likes_count FROM public.wall_likes GROUP BY post_id) l ON l.post_id = cp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS comments_count FROM public.wall_comments WHERE deleted_at IS NULL GROUP BY post_id) c ON c.post_id = cp.id
  LEFT JOIN (SELECT post_id, COUNT(*) AS reposts_count FROM public.wall_reposts GROUP BY post_id) r ON r.post_id = cp.id
  WHERE cp.author_id = p_author_id
    AND cp.status = 'published'
  ORDER BY cp.published_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Get comments for a post with user profiles
CREATE OR REPLACE FUNCTION public.get_post_comments(p_post_id UUID)
RETURNS TABLE(
  id UUID,
  post_id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  content TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    wc.id,
    wc.post_id,
    wc.user_id,
    p.username,
    p.nombre,
    p.avatar_url,
    wc.content,
    wc.created_at
  FROM public.wall_comments wc
  LEFT JOIN public.profiles p ON p.id = wc.user_id
  WHERE wc.post_id = p_post_id
    AND wc.deleted_at IS NULL
  ORDER BY wc.created_at ASC;
END;
$$;

-- Toggle like (insert or delete)
CREATE OR REPLACE FUNCTION public.toggle_like(
  p_post_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id) INTO v_exists;
  
  IF v_exists THEN
    DELETE FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id;
    RETURN FALSE;
  ELSE
    INSERT INTO public.wall_likes (post_id, user_id) VALUES (p_post_id, p_user_id);
    RETURN TRUE;
  END IF;
END;
$$;

-- Toggle repost
CREATE OR REPLACE FUNCTION public.toggle_repost(
  p_post_id UUID,
  p_user_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_exists BOOLEAN;
BEGIN
  SELECT EXISTS(SELECT 1 FROM public.wall_reposts WHERE post_id = p_post_id AND user_id = p_user_id) INTO v_exists;
  
  IF v_exists THEN
    DELETE FROM public.wall_reposts WHERE post_id = p_post_id AND user_id = p_user_id;
    RETURN FALSE;
  ELSE
    INSERT INTO public.wall_reposts (post_id, user_id) VALUES (p_post_id, p_user_id);
    RETURN TRUE;
  END IF;
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_feed_posts TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_crew_feed TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_post_comments TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.toggle_like TO authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_repost TO authenticated;
-- =====================================================
-- Functions for token operations
-- =====================================================

-- Decrement user token balance
CREATE OR REPLACE FUNCTION public.decrement_tokens(p_user_id UUID, p_amount INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_balance INTEGER;
BEGIN
  UPDATE public.user_tokens
  SET balance = GREATEST(balance - p_amount, 0),
      updated_at = NOW()
  WHERE user_id = p_user_id
  RETURNING balance INTO v_balance;

  RETURN v_balance;
END;
$$;

-- Get user's token balance
CREATE OR REPLACE FUNCTION public.get_token_balance(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_balance INTEGER;
BEGIN
  SELECT balance INTO v_balance
  FROM public.user_tokens
  WHERE user_id = p_user_id;

  RETURN COALESCE(v_balance, 0);
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.decrement_tokens TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_token_balance TO authenticated;
-- =====================================================
-- RLS policies para crew_posts (admin/staff pueden gestionar)
-- =====================================================

-- Helper: ¿el usuario actual es admin o staff?
CREATE OR REPLACE FUNCTION public.is_staff_or_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid()
      AND r.name IN ('admin', 'staff')
  );
$$;

-- INSERT: solo admin/staff
CREATE POLICY "Staff can insert crew posts" ON public.crew_posts
  FOR INSERT
  WITH CHECK (public.is_staff_or_admin());

-- UPDATE: solo admin/staff
CREATE POLICY "Staff can update crew posts" ON public.crew_posts
  FOR UPDATE
  USING (public.is_staff_or_admin());

-- DELETE: solo admin/staff
CREATE POLICY "Staff can delete crew posts" ON public.crew_posts
  FOR DELETE
  USING (public.is_staff_or_admin());

GRANT EXECUTE ON FUNCTION public.is_staff_or_admin() TO authenticated;
-- =====================================================
-- Habilitar Realtime para crew_posts (feed en vivo)
-- =====================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.crew_posts;
-- =====================================================
-- Make reactions polymorphic: allow likes/comments/reposts
-- on both wall_posts AND crew_posts
-- We drop the FK so any UUID post can be referenced
-- =====================================================

-- Drop FK constraints on reactions to allow crew_posts ids
ALTER TABLE public.wall_likes DROP CONSTRAINT IF EXISTS wall_likes_post_id_fkey;
ALTER TABLE public.wall_comments DROP CONSTRAINT IF EXISTS wall_comments_post_id_fkey;
ALTER TABLE public.wall_reposts DROP CONSTRAINT IF EXISTS wall_reposts_post_id_fkey;

-- Add index on post_id for performance (was covered by FK before)
CREATE INDEX IF NOT EXISTS idx_wall_likes_post_id ON public.wall_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_wall_comments_post_id ON public.wall_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_wall_reposts_post_id ON public.wall_reposts(post_id);

-- Also ensure the seed crew_posts get some reactions
-- (add likes/comments for the crew posts we just inserted)
INSERT INTO public.wall_likes (post_id, user_id)
SELECT cp.id, p.id
FROM public.crew_posts cp
JOIN public.profiles p ON p.id = 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'
ON CONFLICT DO NOTHING;

INSERT INTO public.wall_likes (post_id, user_id)
SELECT cp.id, p.id
FROM public.crew_posts cp
JOIN public.profiles p ON p.id = 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'
WHERE cp.author_id = 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'
ON CONFLICT DO NOTHING;
-- =====================================================
-- Reaction Pool para The Wild Times
-- ---------------------------------------------
-- Documenta / crea el soporte del pool de reacciones
-- (👍 like · ❤️ love · 😂 haha · 😢 sad · 😡 angry).
--
-- Idempotente: usa DROP FUNCTION IF EXISTS + `drop
-- column` seguro para poder re-aplicarse en cualquier
-- entorno (productivo, staging, local). Las firmas
-- coinciden con lo que el frontend espera.
-- =====================================================

-- 1) Soporte de tipos de reaccion en wall_likes
ALTER TABLE public.wall_likes
  ADD COLUMN IF NOT EXISTS reaction_type TEXT NOT NULL DEFAULT 'like'
  CONSTRAINT wall_likes_reaction_type_check
  CHECK (reaction_type IN ('like', 'love', 'haha', 'sad', 'angry'));


-- 2) Toggle de reaccion (insert / cambiar / eliminar)
DROP FUNCTION IF EXISTS public.toggle_reaction(uuid, uuid, text);
CREATE OR REPLACE FUNCTION public.toggle_reaction(
  p_post_id UUID,
  p_user_id UUID,
  p_reaction_type TEXT DEFAULT 'like'::text
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  DECLARE
    v_existing text;
    v_active text;
    v_count int;
  BEGIN
    IF p_reaction_type NOT IN ('like','love','haha','sad','angry') THEN
      RAISE EXCEPTION 'Invalid reaction type %', p_reaction_type;
    END IF;

    SELECT reaction_type INTO v_existing
    FROM public.wall_likes
    WHERE post_id = p_post_id AND user_id = p_user_id
    LIMIT 1;

    IF v_existing IS NULL THEN
      INSERT INTO public.wall_likes (post_id, user_id, reaction_type)
      VALUES (p_post_id, p_user_id, p_reaction_type);
      v_active := p_reaction_type;
    ELSIF v_existing = p_reaction_type THEN
      DELETE FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id;
      v_active := NULL;
    ELSE
      UPDATE public.wall_likes
      SET reaction_type = p_reaction_type, created_at = now()
      WHERE post_id = p_post_id AND user_id = p_user_id;
      v_active := p_reaction_type;
    END IF;

    SELECT COUNT(*) INTO v_count FROM public.wall_likes WHERE post_id = p_post_id;
    RETURN json_build_object('active', v_active, 'count', v_count);
  END;
$$;


-- 3) Reacciones de un post (con perfil y tipo), con filtro opcional
DROP FUNCTION IF EXISTS public.get_post_likes(uuid, text);
CREATE OR REPLACE FUNCTION public.get_post_likes(p_post_id UUID, p_reaction_type TEXT DEFAULT NULL::text)
RETURNS TABLE(
  id UUID,
  post_id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  reaction_type TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  BEGIN
    RETURN QUERY
    SELECT wl.id, wl.post_id, wl.user_id, p.username, p.nombre, p.avatar_url, wl.reaction_type, wl.created_at
    FROM public.wall_likes wl
    LEFT JOIN public.profiles p ON p.id = wl.user_id
    WHERE wl.post_id = p_post_id
      AND (p_reaction_type IS NULL OR wl.reaction_type = p_reaction_type)
    ORDER BY wl.created_at DESC;
  END;
$$;


-- 4) Reposts de un post (con perfil)
DROP FUNCTION IF EXISTS public.get_post_reposts(uuid);
CREATE OR REPLACE FUNCTION public.get_post_reposts(p_post_id UUID)
RETURNS TABLE(
  id UUID,
  post_id UUID,
  user_id UUID,
  username TEXT,
  nombre TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT wr.id, wr.post_id, wr.user_id, p.username, p.nombre, p.avatar_url, wr.created_at
  FROM public.wall_reposts wr
  LEFT JOIN public.profiles p ON p.id = wr.user_id
  WHERE wr.post_id = p_post_id
  ORDER BY wr.created_at DESC;
END;
$$;


-- 5) Conteo por tipo (usado por el dialogo de reacciones)
DROP FUNCTION IF EXISTS public.get_post_reactions(uuid);
CREATE OR REPLACE FUNCTION public.get_post_reactions(p_post_id UUID)
RETURNS TABLE(reaction_type TEXT, count bigint)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  BEGIN
    RETURN QUERY
    SELECT wl.reaction_type, COUNT(*)::bigint
    FROM public.wall_likes wl
    WHERE wl.post_id = p_post_id
    GROUP BY wl.reaction_type;
  END;
$$;


-- 6) Reaccion del usuario logueado en un post
DROP FUNCTION IF EXISTS public.get_my_reaction(uuid, uuid);
CREATE OR REPLACE FUNCTION public.get_my_reaction(p_post_id UUID, p_user_id UUID)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
  BEGIN
    RETURN (SELECT reaction_type FROM public.wall_likes WHERE post_id = p_post_id AND user_id = p_user_id LIMIT 1);
  END;
$$;


-- Permisos
GRANT EXECUTE ON FUNCTION public.toggle_reaction TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_post_likes TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_post_reposts TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_post_reactions TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_my_reaction TO authenticated, anon;
-- =====================================================
-- EVENTOS + TICKETING + PATROCINADORES + TORNEOS DE ESCRITAS
-- Migración idempotente. Ejecutar con run-migrations.cjs o SQL editor.
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================
-- 0. TABLAS BASE (por si el esquema original no está aplicado)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.roles (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  internal_name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by UUID REFERENCES public.profiles(id),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS public.events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  event_type TEXT CHECK (event_type IN ('battle', 'concert', 'meet_greet', 'other')),
  event_date TIMESTAMPTZ NOT NULL,
  location TEXT,
  image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.freestylers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.versus_battles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  freestyler1_id UUID REFERENCES public.freestylers(id),
  freestyler2_id UUID REFERENCES public.freestylers(id),
  winner_id UUID REFERENCES public.freestylers(id),
  total_votes INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION public.is_staff_or_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid()
      AND r.name IN ('admin', 'staff')
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_staff_or_admin() TO authenticated;

-- =====================================================
-- 1. PATROCINADORES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.sponsors (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  description TEXT,
  logo_url TEXT,
  website_url TEXT,
  tier TEXT DEFAULT 'secondary' CHECK (tier IN ('main', 'secondary')),
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.sponsors (name, slug, description, logo_url, website_url, tier, sort_order)
VALUES
  ('Showlow Caps', 'showlow-caps',
   'Patrocinador oficial de la Liga de Freestyle y del colectivo. Apoyando el talento local desde el día uno.',
   NULL, 'https://showlowcaps.mx/', 'main', 1),
  ('WildForgeLabs', 'wildforgelabs',
   'Desarrollo tecnológico y estrategia digital detrás de WildGvng.',
   NULL, 'https://www.wildforgelabs.com/', 'secondary', 2),
  ('Díaz Design', 'diaz-design',
   'Dirección creativa y diseño gráfico del colectivo.',
   NULL, NULL, 'secondary', 3)
ON CONFLICT (slug) DO NOTHING;

-- Relación patrocinadores ↔ eventos
CREATE TABLE IF NOT EXISTS public.event_sponsors (
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  sponsor_id UUID REFERENCES public.sponsors(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, sponsor_id)
);

-- Relación patrocinadores ↔ torneos (versus_battles)
CREATE TABLE IF NOT EXISTS public.tournament_sponsors (
  battle_id UUID REFERENCES public.versus_battles(id) ON DELETE CASCADE,
  sponsor_id UUID REFERENCES public.sponsors(id) ON DELETE CASCADE,
  PRIMARY KEY (battle_id, sponsor_id)
);

-- =====================================================
-- 2. EVENTOS: CARTEL, PRECIO Y AFORO
-- =====================================================
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS slug TEXT;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS lineup JSONB DEFAULT '[]'::jsonb;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS ticket_price NUMERIC(10,2) DEFAULT 0;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS ticket_currency TEXT DEFAULT 'MXN';
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS capacity INTEGER;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS venue_address TEXT;
ALTER TABLE public.events ADD COLUMN IF NOT EXISTS doors_open TIMESTAMPTZ;

-- =====================================================
-- 3. TICKETS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tickets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id UUID NOT NULL REFERENCES public.events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  ticket_type TEXT DEFAULT 'general',
  price NUMERIC(10,2) DEFAULT 0,
  currency TEXT DEFAULT 'MXN',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'used', 'cancelled', 'refunded')),
  qr_code TEXT NOT NULL UNIQUE DEFAULT encode(gen_random_bytes(16), 'hex'),
  stripe_session_id TEXT UNIQUE,
  stripe_payment_intent_id TEXT,
  purchased_at TIMESTAMPTZ,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tickets_event ON public.tickets(event_id);
CREATE INDEX IF NOT EXISTS idx_tickets_user ON public.tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON public.tickets(status);

-- =====================================================
-- 4. TORNEOS DE ESCRITAS
-- =====================================================
ALTER TABLE public.versus_battles ADD COLUMN IF NOT EXISTS modality TEXT DEFAULT 'freestyle';
ALTER TABLE public.versus_battles ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE public.versus_battles ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.versus_battles ADD COLUMN IF NOT EXISTS submission_deadline TIMESTAMPTZ;
ALTER TABLE public.versus_battles ADD COLUMN IF NOT EXISTS event_id UUID REFERENCES public.events(id) ON DELETE SET NULL;

DO $$
BEGIN
  ALTER TABLE public.versus_battles
    ADD CONSTRAINT versus_battles_modality_check
    CHECK (modality IN ('freestyle', 'written'));
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS public.written_submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tournament_id UUID REFERENCES public.versus_battles(id) ON DELETE SET NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  file_url TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'winner', 'rejected')),
  score INTEGER CHECK (score >= 0 AND score <= 100),
  judge_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_written_tournament ON public.written_submissions(tournament_id);
CREATE INDEX IF NOT EXISTS idx_written_user ON public.written_submissions(user_id);

-- =====================================================
-- 5. RLS
-- =====================================================
ALTER TABLE public.sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.written_submissions ENABLE ROW LEVEL SECURITY;

-- Patrocinadores: lectura pública, gestión staff/admin
DROP POLICY IF EXISTS "Public can read active sponsors" ON public.sponsors;
CREATE POLICY "Public can read active sponsors" ON public.sponsors
  FOR SELECT USING (is_active = TRUE);

DROP POLICY IF EXISTS "Staff can read all sponsors" ON public.sponsors;
CREATE POLICY "Staff can read all sponsors" ON public.sponsors
  FOR SELECT USING (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Staff can manage sponsors" ON public.sponsors;
CREATE POLICY "Staff can manage sponsors" ON public.sponsors
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public can read event sponsors" ON public.event_sponsors;
CREATE POLICY "Public can read event sponsors" ON public.event_sponsors
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Staff can manage event sponsors" ON public.event_sponsors;
CREATE POLICY "Staff can manage event sponsors" ON public.event_sponsors
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public can read tournament sponsors" ON public.tournament_sponsors;
CREATE POLICY "Public can read tournament sponsors" ON public.tournament_sponsors
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Staff can manage tournament sponsors" ON public.tournament_sponsors;
CREATE POLICY "Staff can manage tournament sponsors" ON public.tournament_sponsors
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- Tickets: cada usuario ve los suyos; staff ve y valida todos.
-- La creación real ocurre vía service role en las API routes de Stripe.
DROP POLICY IF EXISTS "Users can read own tickets" ON public.tickets;
CREATE POLICY "Users can read own tickets" ON public.tickets
  FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Staff can manage tickets" ON public.tickets;
CREATE POLICY "Staff can manage tickets" ON public.tickets
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- Escritas: el autor ve y crea lo suyo; staff revisa y califica todo.
DROP POLICY IF EXISTS "Users can read own written submissions" ON public.written_submissions;
CREATE POLICY "Users can read own written submissions" ON public.written_submissions
  FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users can create written submissions" ON public.written_submissions;
CREATE POLICY "Users can create written submissions" ON public.written_submissions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Staff can manage written submissions" ON public.written_submissions;
CREATE POLICY "Staff can manage written submissions" ON public.written_submissions
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- =====================================================
-- 6. RPC: VALIDAR QR EN LA ENTRADA
-- =====================================================
CREATE OR REPLACE FUNCTION public.validate_ticket(p_code TEXT)
RETURNS TABLE (
  ticket_id UUID,
  event_id UUID,
  user_id UUID,
  status TEXT,
  valid BOOLEAN,
  message TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_ticket public.tickets%ROWTYPE;
BEGIN
  IF NOT public.is_staff_or_admin() THEN
    RETURN QUERY SELECT NULL::UUID, NULL::UUID, NULL::UUID, NULL::TEXT, FALSE, 'No autorizado';
    RETURN;
  END IF;

  SELECT * INTO v_ticket
  FROM public.tickets
  WHERE qr_code = p_code
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN QUERY SELECT NULL::UUID, NULL::UUID, NULL::UUID, NULL::TEXT, FALSE, 'Boleto no encontrado';
    RETURN;
  END IF;

  IF v_ticket.status = 'used' THEN
    RETURN QUERY SELECT v_ticket.id, v_ticket.event_id, v_ticket.user_id, v_ticket.status, FALSE, 'Boleto ya utilizado';
    RETURN;
  END IF;

  IF v_ticket.status <> 'paid' THEN
    RETURN QUERY SELECT v_ticket.id, v_ticket.event_id, v_ticket.user_id, v_ticket.status, FALSE, 'Boleto no pagado';
    RETURN;
  END IF;

  UPDATE public.tickets
  SET status = 'used', used_at = NOW()
  WHERE id = v_ticket.id;

  RETURN QUERY SELECT v_ticket.id, v_ticket.event_id, v_ticket.user_id, 'used'::TEXT, TRUE, 'Acceso válido';
END;
$$;

GRANT EXECUTE ON FUNCTION public.validate_ticket(TEXT) TO authenticated;

-- =====================================================
-- 7. STORAGE PARA ARCHIVOS DE ESCRITAS
-- =====================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('written-submissions', 'written-submissions', TRUE)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Written submissions upload" ON storage.objects;
CREATE POLICY "Written submissions upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'written-submissions');

DROP POLICY IF EXISTS "Written submissions read" ON storage.objects;
CREATE POLICY "Written submissions read" ON storage.objects
  FOR SELECT USING (bucket_id = 'written-submissions');
-- Radio config (singleton row)
CREATE TABLE IF NOT EXISTS public.radio_config (
  id SERIAL PRIMARY KEY,
  zeno_stream_url TEXT DEFAULT 'https://stream.zeno.fm/placeholder',
  zeno_embed_url TEXT DEFAULT 'https://zeno.fm/embed/placeholder',
  is_live BOOLEAN DEFAULT false,
  current_show TEXT DEFAULT 'Wild Gvng Radio',
  current_host TEXT DEFAULT 'KAZTA',
  whatsapp TEXT DEFAULT '+52 (871) 111-1111',
  auto_radio BOOLEAN DEFAULT false,
  auto_radio_spotify_playlist TEXT DEFAULT '',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto Radio track list (Spotify fallback)
CREATE TABLE IF NOT EXISTS public.radio_auto_tracks (
  id SERIAL PRIMARY KEY,
  spotify_track_url TEXT NOT NULL,
  spotify_embed_url TEXT NOT NULL,
  title TEXT,
  artist TEXT,
  cover_url TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Radio episodes (recorded mixes/sessions)
CREATE TABLE IF NOT EXISTS public.radio_episodes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  host TEXT DEFAULT 'KAZTA',
  audio_url TEXT NOT NULL,
  cover_url TEXT,
  duration TEXT,
  category TEXT DEFAULT 'mix' CHECK (category IN ('mix', 'entrevista', 'sesion', 'especial', 'live')),
  is_published BOOLEAN DEFAULT false,
  is_live BOOLEAN DEFAULT false,
  live_url TEXT,
  created_by UUID REFERENCES public.profiles(id),
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Radio schedule
CREATE TABLE IF NOT EXISTS public.radio_schedule (
  id SERIAL PRIMARY KEY,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  show_name TEXT NOT NULL,
  host TEXT DEFAULT 'KAZTA',
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.radio_episodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radio_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radio_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radio_auto_tracks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read published episodes" ON public.radio_episodes
FOR SELECT TO public USING (is_published = true OR is_live = true);
CREATE POLICY "Admins can manage episodes" ON public.radio_episodes
FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Anyone can read schedule" ON public.radio_schedule
FOR SELECT TO public USING (true);
CREATE POLICY "Admins can manage schedule" ON public.radio_schedule
FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Anyone can read config" ON public.radio_config
FOR SELECT TO public USING (true);
CREATE POLICY "Admins can manage config" ON public.radio_config
FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Anyone can read auto tracks" ON public.radio_auto_tracks
FOR SELECT TO public USING (true);
CREATE POLICY "Admins can manage auto tracks" ON public.radio_auto_tracks
FOR ALL TO authenticated USING (public.is_admin());

-- Default data
INSERT INTO public.radio_config (zeno_stream_url, zeno_embed_url) VALUES
  ('https://stream.zeno.fm/placeholder', 'https://zeno.fm/embed/placeholder')
ON CONFLICT DO NOTHING;

INSERT INTO public.radio_schedule (day_of_week, start_time, end_time, show_name, host, description) VALUES
  (5, '20:00', '22:00', 'Sesión Nocturna', 'KAZTA', 'Mezclando lo más sucio del underground'),
  (6, '18:00', '20:00', 'Wild Battle Hour', 'RALF DÍAZ', 'Repeticiones de batallas Wild And Free'),
  (0, '12:00', '14:00', 'Resaca Dominical', 'KAZTA', 'Lofi y beats para la cruda')
ON CONFLICT DO NOTHING;
create or replace function public.get_my_role()
returns text
language sql
security definer
set search_path = public
as $$
  select r.name
  from public.user_roles ur
  join public.roles r on r.id = ur.role_id
  where ur.user_id = auth.uid()
  order by case
    when lower(r.name) = 'admin' then 1
    when lower(r.name) = 'artist' then 2
    when lower(r.name) = 'fan' then 3
    else 100
  end
  limit 1
$$;
grant execute on function public.get_my_role() to anon, authenticated;
-- =====================================================
-- SEED: Roles, Permissions & Role-Permissions
-- =====================================================

-- Insert roles
INSERT INTO public.roles (name, internal_name, display_name, description, is_system) VALUES
  ('admin', 'admin', 'Administrador', 'Acceso total al sistema', TRUE),
  ('artist', 'artist', 'Artista', 'Creador de contenido y música', TRUE),
  ('staff', 'staff', 'Staff', 'Gestión operativa del día a día', TRUE),
  ('fan', 'fan', 'Fan', 'Usuario regular de la plataforma', TRUE)
ON CONFLICT (name) DO UPDATE SET
  internal_name = EXCLUDED.internal_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description;

-- Insert permissions
INSERT INTO public.permissions (name, description, module) VALUES
  -- Dashboard
  ('dashboard.view', 'Ver dashboard del ERP', 'dashboard'),
  -- Users
  ('users.view', 'Ver listado de usuarios', 'users'),
  ('users.manage', 'Editar/eliminar usuarios', 'users'),
  ('users.assign_roles', 'Asignar roles a usuarios', 'users'),
  ('users.verify_artists', 'Aprobar verificación de artistas', 'users'),
  -- Content
  ('content.view', 'Ver contenido exclusivo', 'content'),
  ('content.manage', 'Aprobar/rechazar contenido', 'content'),
  ('content.create', 'Crear contenido exclusivo', 'content'),
  -- Tags
  ('tags.view', 'Ver tags', 'tags'),
  ('tags.manage', 'Crear/editar/eliminar tags', 'tags'),
  ('tags.assign', 'Asignar tags a usuarios', 'tags'),
  -- Events
  ('events.view', 'Ver eventos', 'events'),
  ('events.manage', 'Crear/editar/eliminar eventos', 'events'),
  -- Orders
  ('orders.view', 'Ver pedidos', 'orders'),
  ('orders.manage', 'Actualizar estado de pedidos', 'orders'),
  -- Inventory
  ('inventory.view', 'Ver inventario', 'inventory'),
  ('inventory.manage', 'Editar inventario y variantes', 'inventory'),
  -- Versus
  ('versus.view', 'Ver versus', 'versus'),
  ('versus.manage', 'Gestionar batallas y freestylers', 'versus'),
  -- Radio
  ('radio.view', 'Ver radio', 'radio'),
  ('radio.manage', 'Gestionar radio, episodios y schedule', 'radio'),
  -- Configuration
  ('config.view', 'Ver configuración', 'config'),
  ('config.manage', 'Editar configuración del sistema', 'config'),
  -- Notifications
  ('notifications.send', 'Enviar notificaciones del sistema', 'notifications')
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  module = EXCLUDED.module;

-- Assign permissions to roles (admin = all, staff = operational, artist = own content, fan = basic)

-- Admin: everything (handled as wildcard '*' in code, no need to insert all)
-- But insert anyway for clarity / non-admin permissions list
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'admin'
  AND p.name IN (
    'dashboard.view',
    'users.view', 'users.manage', 'users.assign_roles', 'users.verify_artists',
    'content.view', 'content.manage',
    'tags.view', 'tags.manage', 'tags.assign',
    'events.view', 'events.manage',
    'orders.view', 'orders.manage',
    'inventory.view', 'inventory.manage',
    'versus.view', 'versus.manage',
    'radio.view', 'radio.manage',
    'config.view', 'config.manage',
    'notifications.send'
  )
ON CONFLICT DO NOTHING;

-- Staff: operational management
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'staff'
  AND p.name IN (
    'dashboard.view',
    'users.view', 'users.verify_artists',
    'content.view', 'content.manage',
    'tags.view', 'tags.manage', 'tags.assign',
    'events.view', 'events.manage',
    'orders.view', 'orders.manage',
    'inventory.view', 'inventory.manage',
    'versus.view',
    'radio.view',
    'config.view'
  )
ON CONFLICT DO NOTHING;

-- Artist: own content management
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'artist'
  AND p.name IN (
    'content.view', 'content.create',
    'tags.view',
    'events.view',
    'versus.view',
    'radio.view'
  )
ON CONFLICT DO NOTHING;

-- Fan: basic view permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'fan'
  AND p.name IN (
    'content.view',
    'tags.view',
    'events.view',
    'versus.view',
    'radio.view'
  )
ON CONFLICT DO NOTHING;
-- =====================================================
-- FIX: TODAS LAS RLS POLICIES (IDEMPOTENTE - seguro de ejecutar)
-- =====================================================
-- Este script usa DROP POLICY IF EXISTS antes de cada CREATE POLICY
-- para evitar el error "policy already exists"
-- Se puede ejecutar cuantas veces sea necesario

-- =====================================================
-- 1. Asegurar que los roles existen
-- =====================================================
INSERT INTO public.roles (name, internal_name, display_name, description, is_system) VALUES
  ('owner', 'owner', 'Dueño', 'Control total del crew', true),
  ('admin', 'admin', 'Admin', 'Gestión completa del sistema', true),
  ('staff_manager', 'staff_manager', 'Staff Senior', 'Gestión administrativa con privilegios extendidos', false),
  ('staff', 'staff', 'Staff', 'Operaciones básicas del sistema', false),
  ('staff_marketing', 'staff_marketing', 'Marketing', 'Publicación de contenido del crew', false),
  ('artist', 'artist', 'Artista', 'Perfil verificado, sube contenido', true),
  ('fan', 'fan', 'Miembro', 'Interactúa, compra, sigue artistas', true),
  ('guest', 'guest', 'Visitante', 'Solo ve contenido público', true)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 2. Asegurar que los permisos existen
-- =====================================================
INSERT INTO public.permissions (name, description, module) VALUES
  ('orders.view', 'Ver pedidos', 'orders'),
  ('orders.manage', 'Gestionar pedidos', 'orders'),
  ('orders.ship', 'Marcar envíos', 'orders'),
  ('inventory.view', 'Ver inventario', 'inventory'),
  ('inventory.manage', 'Gestionar productos', 'inventory'),
  ('content.view', 'Ver contenido pendiente', 'content'),
  ('content.approve', 'Aprobar/rechazar contenido', 'content'),
  ('content.create_crew', 'Crear contenido del crew', 'content'),
  ('users.view', 'Ver usuarios', 'users'),
  ('users.manage', 'Gestionar usuarios y roles', 'users'),
  ('users.verify_artist', 'Aprobar verificación de artistas', 'users'),
  ('tags.manage', 'Gestionar tags', 'tags'),
  ('events.manage', 'Gestionar eventos', 'events'),
  ('versus.manage', 'Gestionar freestylers y stats', 'versus'),
  ('config.manage', 'Configurar el sistema', 'config'),
  ('reports.view', 'Ver reportes', 'reports')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 3. Asignar TODOS los permisos a admin y owner
-- =====================================================
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name IN ('admin', 'owner')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. Asignar permisos específicos a staff
-- =====================================================
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff_manager'
AND p.name IN ('orders.view', 'orders.manage', 'orders.ship', 'inventory.view', 'inventory.manage', 'content.view', 'content.approve', 'users.view', 'reports.view')
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff'
AND p.name IN ('orders.view', 'orders.manage', 'inventory.view', 'content.view', 'content.approve')
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff_marketing'
AND p.name IN ('content.view', 'content.create_crew')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. RLS: profiles
-- =====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles
FOR SELECT TO authenticated
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles" ON public.profiles
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
FOR UPDATE TO authenticated
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;
CREATE POLICY "Admins can update any profile" ON public.profiles
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 6. RLS: user_roles
-- =====================================================
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
CREATE POLICY "Users can view their own roles" ON public.user_roles
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all user_roles" ON public.user_roles;
CREATE POLICY "Admins can view all user_roles" ON public.user_roles
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 7. RLS: roles (todos pueden leer)
-- =====================================================
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Roles are viewable by everyone" ON public.roles;
CREATE POLICY "Roles are viewable by everyone" ON public.roles
FOR SELECT TO public
USING (true);

-- =====================================================
-- 8. RLS: permissions (todos pueden leer)
-- =====================================================
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Permissions viewable by all" ON public.permissions;
CREATE POLICY "Permissions viewable by all" ON public.permissions
FOR SELECT TO authenticated
USING (true);

-- =====================================================
-- 9. RLS: role_permissions (admins pueden leer todo)
-- =====================================================
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view role_permissions" ON public.role_permissions;
CREATE POLICY "Admins can view role_permissions" ON public.role_permissions
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 10. RLS: store_orders
-- =====================================================
ALTER TABLE public.store_orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all orders" ON public.store_orders;
CREATE POLICY "Admins can view all orders" ON public.store_orders
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can update orders" ON public.store_orders;
CREATE POLICY "Admins can update orders" ON public.store_orders
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 11. RLS: store_products
-- =====================================================
ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all products" ON public.store_products;
CREATE POLICY "Admins can view all products" ON public.store_products
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can manage products" ON public.store_products;
CREATE POLICY "Admins can manage products" ON public.store_products
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 12. RLS: exclusive_content
-- =====================================================
ALTER TABLE public.exclusive_content ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all content" ON public.exclusive_content;
CREATE POLICY "Admins can view all content" ON public.exclusive_content
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can manage content" ON public.exclusive_content;
CREATE POLICY "Admins can manage content" ON public.exclusive_content
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 13. RLS: events
-- =====================================================
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
CREATE POLICY "Admins can view all events" ON public.events
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can manage events" ON public.events;
CREATE POLICY "Admins can manage events" ON public.events
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 14. RLS: user_tokens
-- =====================================================
ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own tokens" ON public.user_tokens;
CREATE POLICY "Users can view own tokens" ON public.user_tokens
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all tokens" ON public.user_tokens;
CREATE POLICY "Admins can view all tokens" ON public.user_tokens
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 15. RLS: tags y user_has_tags
-- =====================================================
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Tags are viewable by everyone" ON public.tags;
CREATE POLICY "Tags are viewable by everyone" ON public.tags
FOR SELECT TO public
USING (true);

ALTER TABLE public.user_has_tags ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own tags" ON public.user_has_tags;
CREATE POLICY "Users can view their own tags" ON public.user_has_tags
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all user_tags" ON public.user_has_tags;
CREATE POLICY "Admins can view all user_tags" ON public.user_has_tags
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 16. RLS: store_order_items
-- =====================================================
ALTER TABLE public.store_order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all order items" ON public.store_order_items;
CREATE POLICY "Admins can view all order items" ON public.store_order_items
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 17. RLS: product_variants
-- =====================================================
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all variants" ON public.product_variants;
CREATE POLICY "Admins can view all variants" ON public.product_variants
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 18. Asegurar que la función get_my_role funciona
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT r.name
  FROM public.user_roles ur
  JOIN public.roles r ON r.id = ur.role_id
  WHERE ur.user_id = auth.uid()
  ORDER BY CASE
    WHEN lower(r.name) = 'admin' THEN 1
    WHEN lower(r.name) = 'artist' THEN 2
    WHEN lower(r.name) = 'fan' THEN 3
    ELSE 100
  END
  LIMIT 1
$$;

GRANT EXECUTE ON FUNCTION public.get_my_role() TO anon, authenticated;

-- =====================================================
-- FIX: Infinite recursion in RLS policies
-- Las policies de admin usan subconsulta a user_roles
-- que a su vez tiene RLS, causando recursion infinita.
-- Solucion: crear funcion helper SECURITY DEFINER
-- que bypass RLS, y usarla en todas las policies
-- =====================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- Ahora reemplazar TODAS las policies que usan subconsulta directa
-- para que usen la funcion is_admin() en lugar

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles" ON public.profiles
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;
CREATE POLICY "Admins can update any profile" ON public.profiles
FOR UPDATE TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all user_roles" ON public.user_roles;
CREATE POLICY "Admins can view all user_roles" ON public.user_roles
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all orders" ON public.store_orders;
CREATE POLICY "Admins can view all orders" ON public.store_orders
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update orders" ON public.store_orders;
CREATE POLICY "Admins can update orders" ON public.store_orders
FOR UPDATE TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all products" ON public.store_products;
CREATE POLICY "Admins can view all products" ON public.store_products
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage products" ON public.store_products;
CREATE POLICY "Admins can manage products" ON public.store_products
FOR ALL TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all content" ON public.exclusive_content;
CREATE POLICY "Admins can view all content" ON public.exclusive_content
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage content" ON public.exclusive_content;
CREATE POLICY "Admins can manage content" ON public.exclusive_content
FOR UPDATE TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
CREATE POLICY "Admins can view all events" ON public.events
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage events" ON public.events;
CREATE POLICY "Admins can manage events" ON public.events
FOR ALL TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all tokens" ON public.user_tokens;
CREATE POLICY "Admins can view all tokens" ON public.user_tokens
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all user_tags" ON public.user_has_tags;
CREATE POLICY "Admins can view all user_tags" ON public.user_has_tags
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all order items" ON public.store_order_items;
CREATE POLICY "Admins can view all order items" ON public.store_order_items
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all variants" ON public.product_variants;
CREATE POLICY "Admins can view all variants" ON public.product_variants
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view role_permissions" ON public.role_permissions;
CREATE POLICY "Admins can view role_permissions" ON public.role_permissions
FOR SELECT TO authenticated
USING (public.is_admin());
