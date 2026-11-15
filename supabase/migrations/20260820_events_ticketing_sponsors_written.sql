-- =====================================================
-- EVENTOS + TICKETING + PATROCINADORES + TORNEOS DE ESCRITAS
-- Migración idempotente. Ejecutar con run-migrations.cjs o SQL editor.
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
