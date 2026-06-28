-- =====================================================
-- WILD GNVG MUSIC HUB - COMPLETE DATABASE SCHEMA
-- =====================================================
-- Basado en brainstorm completo del proyecto
-- Fecha: 2024-06-27
-- =====================================================

-- =====================================================
-- 1. AUTH & PROFILES
-- =====================================================

-- Profiles (extender tabla existente)
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS website TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS spotify_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS youtube_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS instagram_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS twitter_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tiktok_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_verified_artist BOOLEAN DEFAULT FALSE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS verification_status TEXT DEFAULT 'none' CHECK (verification_status IN ('none', 'pending', 'approved', 'rejected'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS spotify_artist_id TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT FALSE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ;

-- Roles dinámicos
CREATE TABLE IF NOT EXISTS public.roles (
  id SERIAL PRIMARY KEY,
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

-- Relación rol-permisos
CREATE TABLE IF NOT EXISTS public.role_permissions (
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  permission_id INTEGER REFERENCES public.permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

-- Relación usuario-roles
CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by UUID REFERENCES auth.users(id),
  PRIMARY KEY (user_id, role_id)
);

-- =====================================================
-- 2. SOCIAL (WALL)
-- =====================================================

-- Posts del muro
CREATE TABLE IF NOT EXISTS public.wall_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
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
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Likes
CREATE TABLE IF NOT EXISTS public.wall_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.wall_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Reposts
CREATE TABLE IF NOT EXISTS public.wall_reposts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID REFERENCES public.wall_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- =====================================================
-- 3. FRIENDSHIP / FOLLOW
-- =====================================================

-- Solicitudes de amistad
CREATE TABLE IF NOT EXISTS public.friendships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  requester_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  addressee_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(requester_id, addressee_id)
);

-- Seguimientos (fan → artista)
CREATE TABLE IF NOT EXISTS public.follows (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  follower_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  following_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(follower_id, following_id)
);

-- =====================================================
-- 4. MESSAGING
-- =====================================================

-- Conversaciones
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT DEFAULT 'direct' CHECK (type IN ('direct', 'group')),
  name TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Miembros de conversación
CREATE TABLE IF NOT EXISTS public.conversation_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member' CHECK (role IN ('member', 'admin')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  left_at TIMESTAMPTZ,
  UNIQUE(conversation_id, user_id)
);

-- Mensajes
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
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
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(message_id, user_id)
);

-- Solicitudes de mensajes (para artistas)
CREATE TABLE IF NOT EXISTS public.message_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 5. TAGS
-- =====================================================

-- Categorías de tags
CREATE TABLE IF NOT EXISTS public.tag_categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tags (extender tabla existente)
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS category_id INTEGER REFERENCES public.tag_categories(id);
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS token_price INTEGER;
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS is_purchasable BOOLEAN DEFAULT FALSE;
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS achievement_key TEXT;

-- =====================================================
-- 6. SHOP / E-COMMERCE
-- =====================================================

-- Productos de la tienda
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

-- Variantes de producto (talla, color)
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
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
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
-- 7. TOKENS
-- =====================================================

-- Balance de tokens por usuario
CREATE TABLE IF NOT EXISTS public.user_tokens (
  user_id UUID REFERENCES auth.users(id) ON DELETE PRIMARY KEY,
  balance INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Historial de compras de tokens
CREATE TABLE IF NOT EXISTS public.token_purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ip_address TEXT,
  amount INTEGER NOT NULL,
  price_mxn NUMERIC(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  stripe_payment_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transacciones de tokens (compra, gasto, ganancia)
CREATE TABLE IF NOT EXISTS public.token_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('purchase', 'earn', 'spend', 'refund', 'expire')),
  amount INTEGER NOT NULL,
  reference TEXT,
  reference_id UUID,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 8. CONTENT (EXCLUSIVO)
-- =====================================================

-- Contenido exclusivo de artistas
CREATE TABLE IF NOT EXISTS public.exclusive_content (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  content_type TEXT NOT NULL CHECK (content_type IN ('video', 'audio', 'download')),
  file_url TEXT,
  preview_url TEXT,
  token_price INTEGER DEFAULT 0,
  real_price_mxn NUMERIC(10,2),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'published')),
  rejection_reason TEXT,
  approved_by UUID REFERENCES auth.users(id),
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Quién compró contenido
CREATE TABLE IF NOT EXISTS public.content_purchases (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
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
  author_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
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
-- 9. EVENTS
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
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 10. VERSUS / LEAGUE
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
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  voted_for UUID REFERENCES public.freestylers(id),
  tokens_earned INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(battle_id, user_id)
);

-- Historial de batallas por usuario (para límite diario)
CREATE TABLE IF NOT EXISTS public.user_battle_votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  vote_date DATE DEFAULT CURRENT_DATE,
  votes_today INTEGER DEFAULT 0,
  UNIQUE(user_id, vote_date)
);

-- =====================================================
-- 11. NOTIFICATIONS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('follow', 'like', 'comment', 'message', 'content_approved', 'content_rejected', 'order_update', 'verification', 'system')),
  title TEXT NOT NULL,
  body TEXT,
  reference_type TEXT,
  reference_id UUID,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 12. ACTIVITY LOG (para ERP reports)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
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

-- Profiles: público para lectura, solo propio para escritura
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Wall Posts: público para lectura, solo autor para escritura
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

-- Message Requests
ALTER TABLE public.message_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own message requests" ON public.message_requests FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send message requests" ON public.message_requests FOR INSERT WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "Receivers can update request status" ON public.message_requests FOR UPDATE USING (auth.uid() = receiver_id);

-- Tokens
ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own token balance" ON public.user_tokens FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can update token balance" ON public.user_tokens FOR UPDATE USING (true);

ALTER TABLE public.token_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own purchases" ON public.token_purchases FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create purchases" ON public.token_purchases FOR INSERT WITH CHECK (auth.uid() = user_id);

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

-- Notifications
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Roles por defecto
INSERT INTO public.roles (internal_name, display_name, description, is_system) VALUES
  ('owner', 'Dueño', 'Control total del crew', true),
  ('admin', 'Admin', 'Gestión completa del sistema', true),
  ('staff_manager', 'Staff Senior', 'Gestión administrativa con privilegios extendidos', false),
  ('staff', 'Staff', 'Operaciones básicas del sistema', false),
  ('staff_marketing', 'Marketing', 'Publicación de contenido del crew', false),
  ('artist', 'Artista', 'Perfil verificado, sube contenido', true),
  ('fan', 'Miembro', 'Interactúa, compra, sigue artistas', true),
  ('guest', 'Visitante', 'Solo ve contenido público', true)
ON CONFLICT (internal_name) DO NOTHING;

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
-- FUNCTIONS
-- =====================================================

-- Función para actualizar balance de tokens
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

-- Trigger para actualizar tokens después de compra
DROP TRIGGER IF EXISTS on_token_purchase ON public.token_purchases;
CREATE TRIGGER on_token_purchase
  AFTER INSERT OR UPDATE ON public.token_purchases
  FOR EACH ROW
  EXECUTE FUNCTION update_token_balance();

-- Función para verificar límite de tokens por IP
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

-- Función para contar votos de versus por usuario hoy
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
