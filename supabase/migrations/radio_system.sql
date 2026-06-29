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
