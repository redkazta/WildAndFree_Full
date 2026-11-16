-- =====================================================
-- CREAR TABLAS FALTANTES (proyecto Supabase parcial)
-- Idempotente: solo crea lo que falta.
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

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

-- =====================================================
-- TAGS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tag_categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.tag_categories (name, description) VALUES
  ('cosmetic', 'Tags cosméticos'),
  ('achievement', 'Logros'),
  ('purchasable', 'Tags comprables'),
  ('event', 'Tags de eventos')
ON CONFLICT (name) DO NOTHING;

ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS category_id INTEGER REFERENCES public.tag_categories(id);
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS animation VARCHAR(50) DEFAULT 'none';
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS token_price INTEGER;
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS is_purchasable BOOLEAN DEFAULT FALSE;
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS achievement_key TEXT;

-- =====================================================
-- FEED SOCIAL
-- =====================================================
CREATE TABLE IF NOT EXISTS public.wall_posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.wall_comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.wall_likes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  reaction_type TEXT NOT NULL DEFAULT 'like'
    CHECK (reaction_type IN ('like', 'love', 'haha', 'sad', 'angry')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.wall_reposts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  post_id UUID NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_wall_posts_user ON public.wall_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_wall_posts_created ON public.wall_posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wall_comments_post ON public.wall_comments(post_id);
CREATE INDEX IF NOT EXISTS idx_wall_likes_post ON public.wall_likes(post_id);
CREATE INDEX IF NOT EXISTS idx_wall_reposts_post ON public.wall_reposts(post_id);

ALTER TABLE public.wall_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wall_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wall_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wall_reposts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read wall posts" ON public.wall_posts;
CREATE POLICY "Public can read wall posts" ON public.wall_posts FOR SELECT USING (deleted_at IS NULL);
DROP POLICY IF EXISTS "Users can create wall posts" ON public.wall_posts;
CREATE POLICY "Users can create wall posts" ON public.wall_posts FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can update own wall posts" ON public.wall_posts;
CREATE POLICY "Users can update own wall posts" ON public.wall_posts FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own wall posts" ON public.wall_posts;
CREATE POLICY "Users can delete own wall posts" ON public.wall_posts FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public can read wall comments" ON public.wall_comments;
CREATE POLICY "Public can read wall comments" ON public.wall_comments FOR SELECT USING (deleted_at IS NULL);
DROP POLICY IF EXISTS "Users can create wall comments" ON public.wall_comments;
CREATE POLICY "Users can create wall comments" ON public.wall_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can delete own wall comments" ON public.wall_comments;
CREATE POLICY "Users can delete own wall comments" ON public.wall_comments FOR DELETE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public can read wall likes" ON public.wall_likes;
CREATE POLICY "Public can read wall likes" ON public.wall_likes FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Users can manage own wall likes" ON public.wall_likes;
CREATE POLICY "Users can manage own wall likes" ON public.wall_likes FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public can read wall reposts" ON public.wall_reposts;
CREATE POLICY "Public can read wall reposts" ON public.wall_reposts FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Users can manage own wall reposts" ON public.wall_reposts;
CREATE POLICY "Users can manage own wall reposts" ON public.wall_reposts FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- FAVORITOS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  track_id TEXT NOT NULL,
  track_data JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, track_id)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user ON public.favorites(user_id);
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own favorites" ON public.favorites;
CREATE POLICY "Users can view own favorites" ON public.favorites FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users can manage own favorites" ON public.favorites;
CREATE POLICY "Users can manage own favorites" ON public.favorites FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- VERSUS / TORNEOS
-- =====================================================
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

CREATE TABLE IF NOT EXISTS public.freestyler_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  freestyler_id UUID REFERENCES public.freestylers(id) ON DELETE CASCADE,
  stat_name TEXT NOT NULL CHECK (stat_name IN ('flow', 'punchline', 'estructura', 'puesta_en_escena', 'doble_tempo', 'figuras_literarias')),
  stat_value INTEGER DEFAULT 50 CHECK (stat_value >= 0 AND stat_value <= 100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(freestyler_id, stat_name)
);

CREATE TABLE IF NOT EXISTS public.versus_battles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  freestyler1_id UUID REFERENCES public.freestylers(id),
  freestyler2_id UUID REFERENCES public.freestylers(id),
  winner_id UUID REFERENCES public.freestylers(id),
  total_votes INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed')),
  modality TEXT DEFAULT 'freestyle' CHECK (modality IN ('freestyle', 'written')),
  title TEXT,
  description TEXT,
  submission_deadline TIMESTAMPTZ,
  event_id UUID REFERENCES public.events(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.versus_votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  battle_id UUID REFERENCES public.versus_battles(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  voted_for UUID REFERENCES public.freestylers(id),
  tokens_earned INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(battle_id, user_id)
);

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

CREATE INDEX IF NOT EXISTS idx_freestyler_stats_freestyler ON public.freestyler_stats(freestyler_id);
CREATE INDEX IF NOT EXISTS idx_versus_battles_f1 ON public.versus_battles(freestyler1_id);
CREATE INDEX IF NOT EXISTS idx_versus_battles_f2 ON public.versus_battles(freestyler2_id);
CREATE INDEX IF NOT EXISTS idx_versus_votes_battle ON public.versus_votes(battle_id);
CREATE INDEX IF NOT EXISTS idx_written_tournament ON public.written_submissions(tournament_id);
CREATE INDEX IF NOT EXISTS idx_written_user ON public.written_submissions(user_id);

ALTER TABLE public.freestylers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.freestyler_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.versus_battles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.versus_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.written_submissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read freestylers" ON public.freestylers;
CREATE POLICY "Public can read freestylers" ON public.freestylers FOR SELECT USING (is_active = TRUE);
DROP POLICY IF EXISTS "Staff manage freestylers" ON public.freestylers;
CREATE POLICY "Staff manage freestylers" ON public.freestylers FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public can read stats" ON public.freestyler_stats;
CREATE POLICY "Public can read stats" ON public.freestyler_stats FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Staff manage stats" ON public.freestyler_stats;
CREATE POLICY "Staff manage stats" ON public.freestyler_stats FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public can read battles" ON public.versus_battles;
CREATE POLICY "Public can read battles" ON public.versus_battles FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Staff manage battles" ON public.versus_battles;
CREATE POLICY "Staff manage battles" ON public.versus_battles FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public can read votes" ON public.versus_votes;
CREATE POLICY "Public can read votes" ON public.versus_votes FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Users manage own votes" ON public.versus_votes;
CREATE POLICY "Users manage own votes" ON public.versus_votes FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users read own written submissions" ON public.written_submissions;
CREATE POLICY "Users read own written submissions" ON public.written_submissions
  FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Users create written submissions" ON public.written_submissions;
CREATE POLICY "Users create written submissions" ON public.written_submissions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Staff manage written submissions" ON public.written_submissions;
CREATE POLICY "Staff manage written submissions" ON public.written_submissions
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- =====================================================
-- TOKENS / CONTENIDO EXCLUSIVO
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_tokens (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE PRIMARY KEY,
  balance INTEGER DEFAULT 0,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

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

CREATE INDEX IF NOT EXISTS idx_token_purchases_user ON public.token_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_token_transactions_user ON public.token_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_exclusive_content_user ON public.exclusive_content(user_id);
CREATE INDEX IF NOT EXISTS idx_exclusive_content_status ON public.exclusive_content(status);

ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.token_purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.token_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exclusive_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_purchases ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own tokens" ON public.user_tokens;
CREATE POLICY "Users read own tokens" ON public.user_tokens FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage tokens" ON public.user_tokens;
CREATE POLICY "Staff manage tokens" ON public.user_tokens FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users read own token purchases" ON public.token_purchases;
CREATE POLICY "Users read own token purchases" ON public.token_purchases FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage token purchases" ON public.token_purchases;
CREATE POLICY "Staff manage token purchases" ON public.token_purchases FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users read own token transactions" ON public.token_transactions;
CREATE POLICY "Users read own token transactions" ON public.token_transactions FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage token transactions" ON public.token_transactions;
CREATE POLICY "Staff manage token transactions" ON public.token_transactions FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public read published content" ON public.exclusive_content;
CREATE POLICY "Public read published content" ON public.exclusive_content FOR SELECT USING (status = 'published' OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage content" ON public.exclusive_content;
CREATE POLICY "Staff manage content" ON public.exclusive_content FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users read own content purchases" ON public.content_purchases;
CREATE POLICY "Users read own content purchases" ON public.content_purchases FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage content purchases" ON public.content_purchases;
CREATE POLICY "Staff manage content purchases" ON public.content_purchases FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- =====================================================
-- NOTIFICACIONES
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

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = FALSE;

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users read own notifications" ON public.notifications;
CREATE POLICY "Users read own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Users update own notifications" ON public.notifications;
CREATE POLICY "Users update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "Staff manage notifications" ON public.notifications;
CREATE POLICY "Staff manage notifications" ON public.notifications FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- =====================================================
-- CONFIGURACIÓN / ELIMINACIÓN DE CUENTA
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_settings (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  theme TEXT NOT NULL DEFAULT 'dark' CHECK (theme IN ('dark', 'light')),
  font_size TEXT NOT NULL DEFAULT 'medium' CHECK (font_size IN ('small', 'medium', 'large')),
  animations BOOLEAN NOT NULL DEFAULT TRUE,
  locale TEXT NOT NULL DEFAULT 'es' CHECK (locale IN ('es', 'en')),
  ubicacion TEXT NOT NULL DEFAULT 'Torreón',
  autoplay BOOLEAN NOT NULL DEFAULT TRUE,
  crossfade BOOLEAN NOT NULL DEFAULT FALSE,
  streaming_quality TEXT NOT NULL DEFAULT 'medium' CHECK (streaming_quality IN ('low', 'medium', 'high')),
  offline_mode BOOLEAN NOT NULL DEFAULT FALSE,
  auto_radio_spotify_playlist TEXT,
  push_events BOOLEAN NOT NULL DEFAULT TRUE,
  push_posts BOOLEAN NOT NULL DEFAULT TRUE,
  push_comments BOOLEAN NOT NULL DEFAULT TRUE,
  push_followers BOOLEAN NOT NULL DEFAULT FALSE,
  email_weekly BOOLEAN NOT NULL DEFAULT FALSE,
  email_promos BOOLEAN NOT NULL DEFAULT FALSE,
  profile_public BOOLEAN NOT NULL DEFAULT TRUE,
  show_ranking BOOLEAN NOT NULL DEFAULT TRUE,
  history_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  share_data BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.account_deletion_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reason TEXT,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed_at TIMESTAMPTZ,
  processed_by UUID REFERENCES public.profiles(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_deletion_requests_user ON public.account_deletion_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_deletion_requests_status ON public.account_deletion_requests(status);

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account_deletion_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users manage own settings" ON public.user_settings;
CREATE POLICY "Users manage own settings" ON public.user_settings FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Staff manage settings" ON public.user_settings;
CREATE POLICY "Staff manage settings" ON public.user_settings FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users create own deletion request" ON public.account_deletion_requests;
CREATE POLICY "Users create own deletion request" ON public.account_deletion_requests FOR INSERT WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "Users read own deletion requests" ON public.account_deletion_requests;
CREATE POLICY "Users read own deletion requests" ON public.account_deletion_requests FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage deletion requests" ON public.account_deletion_requests;
CREATE POLICY "Staff manage deletion requests" ON public.account_deletion_requests FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- =====================================================
-- SPONSORS / TICKETS
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

INSERT INTO public.sponsors (name, slug, description, website_url, tier, sort_order) VALUES
  ('Showlow Caps', 'showlow-caps', 'Patrocinador oficial de la Liga de Freestyle y del colectivo.', 'https://showlowcaps.mx/', 'main', 1),
  ('WildForgeLabs', 'wildforgelabs', 'Desarrollo tecnológico y estrategia digital detrás de WildGvng.', 'https://www.wildforgelabs.com/', 'secondary', 2),
  ('Díaz Design', 'diaz-design', 'Dirección creativa y diseño gráfico del colectivo.', NULL, 'secondary', 3)
ON CONFLICT (slug) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.event_sponsors (
  event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
  sponsor_id UUID REFERENCES public.sponsors(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, sponsor_id)
);

CREATE TABLE IF NOT EXISTS public.tournament_sponsors (
  battle_id UUID REFERENCES public.versus_battles(id) ON DELETE CASCADE,
  sponsor_id UUID REFERENCES public.sponsors(id) ON DELETE CASCADE,
  PRIMARY KEY (battle_id, sponsor_id)
);

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

ALTER TABLE public.sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read active sponsors" ON public.sponsors;
CREATE POLICY "Public read active sponsors" ON public.sponsors FOR SELECT USING (is_active = TRUE);
DROP POLICY IF EXISTS "Staff manage sponsors" ON public.sponsors;
CREATE POLICY "Staff manage sponsors" ON public.sponsors FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public read event sponsors" ON public.event_sponsors;
CREATE POLICY "Public read event sponsors" ON public.event_sponsors FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Staff manage event sponsors" ON public.event_sponsors;
CREATE POLICY "Staff manage event sponsors" ON public.event_sponsors FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public read tournament sponsors" ON public.tournament_sponsors;
CREATE POLICY "Public read tournament sponsors" ON public.tournament_sponsors FOR SELECT USING (TRUE);
DROP POLICY IF EXISTS "Staff manage tournament sponsors" ON public.tournament_sponsors;
CREATE POLICY "Staff manage tournament sponsors" ON public.tournament_sponsors FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users read own tickets" ON public.tickets;
CREATE POLICY "Users read own tickets" ON public.tickets FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage tickets" ON public.tickets;
CREATE POLICY "Staff manage tickets" ON public.tickets FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

CREATE OR REPLACE FUNCTION public.validate_ticket(p_code TEXT)
RETURNS TABLE (ticket_id UUID, event_id UUID, user_id UUID, status TEXT, valid BOOLEAN, message TEXT)
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

  SELECT * INTO v_ticket FROM public.tickets WHERE qr_code = p_code LIMIT 1;
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

  UPDATE public.tickets SET status = 'used', used_at = NOW() WHERE id = v_ticket.id;
  RETURN QUERY SELECT v_ticket.id, v_ticket.event_id, v_ticket.user_id, 'used'::TEXT, TRUE, 'Acceso válido';
END;
$$;

GRANT EXECUTE ON FUNCTION public.validate_ticket(TEXT) TO authenticated;

-- =====================================================
-- RADIO
-- =====================================================
CREATE TABLE IF NOT EXISTS public.radio_episodes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  host TEXT DEFAULT 'KAZTA',
  audio_url TEXT NOT NULL,
  cover_url TEXT,
  duration TEXT,
  category TEXT DEFAULT 'mix' CHECK (category IN ('mix', 'entrevista', 'sesion', 'especial', 'live')),
  is_published BOOLEAN DEFAULT FALSE,
  is_live BOOLEAN DEFAULT FALSE,
  live_url TEXT,
  created_by UUID REFERENCES public.profiles(id),
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.radio_schedule (
  id SERIAL PRIMARY KEY,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  show_name TEXT NOT NULL,
  host TEXT DEFAULT 'KAZTA',
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.radio_auto_tracks (
  id SERIAL PRIMARY KEY,
  spotify_track_url TEXT NOT NULL,
  spotify_embed_url TEXT NOT NULL,
  title TEXT,
  artist TEXT,
  cover_url TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

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

ALTER TABLE public.radio_episodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radio_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.radio_auto_tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public read published episodes" ON public.radio_episodes;
CREATE POLICY "Public read published episodes" ON public.radio_episodes FOR SELECT USING (is_published = TRUE OR is_live = TRUE);
DROP POLICY IF EXISTS "Staff manage episodes" ON public.radio_episodes;
CREATE POLICY "Staff manage episodes" ON public.radio_episodes FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public read schedule" ON public.radio_schedule;
CREATE POLICY "Public read schedule" ON public.radio_schedule FOR SELECT USING (is_active = TRUE);
DROP POLICY IF EXISTS "Staff manage schedule" ON public.radio_schedule;
CREATE POLICY "Staff manage schedule" ON public.radio_schedule FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public read auto tracks" ON public.radio_auto_tracks;
CREATE POLICY "Public read auto tracks" ON public.radio_auto_tracks FOR SELECT USING (is_active = TRUE);
DROP POLICY IF EXISTS "Staff manage auto tracks" ON public.radio_auto_tracks;
CREATE POLICY "Staff manage auto tracks" ON public.radio_auto_tracks FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Staff read activity log" ON public.activity_log;
CREATE POLICY "Staff read activity log" ON public.activity_log FOR SELECT USING (public.is_staff_or_admin());
DROP POLICY IF EXISTS "Staff manage activity log" ON public.activity_log;
CREATE POLICY "Staff manage activity log" ON public.activity_log FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

-- =====================================================
-- ALIAS DE ORDER ITEMS (compatibilidad con el inventario)
-- =====================================================
DO $$
BEGIN
  IF to_regclass('public.store_order_items') IS NOT NULL THEN
    EXECUTE 'CREATE OR REPLACE VIEW public.order_items AS SELECT * FROM public.store_order_items';
  END IF;
END $$;
