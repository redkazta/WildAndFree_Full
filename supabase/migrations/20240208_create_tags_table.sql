-- Crear tabla de tags para el sistema de etiquetas visuales
CREATE TABLE IF NOT EXISTS public.tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  color VARCHAR(7) DEFAULT '#ffffff',
  animation VARCHAR(50) DEFAULT 'none',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar tags iniciales basados en los roles anteriores
INSERT INTO public.tags (name, color, animation) VALUES
  ('CEO WildGvng', '#FFD700', 'golden-pulse'),
  ('Founder WildGvng', '#FFA500', 'golden-pulse'),
  ('Co-Founder WildGvng', '#FF8C00', 'golden-pulse'),
  ('Owner WildGvng', '#FF7F50', 'golden-pulse'),
  ('Director WildGvng', '#DC143C', 'golden-pulse'),
  ('Executive WildGvng', '#B22222', 'golden-pulse'),
  ('Lead WildGvng', '#8B0000', 'golden-pulse'),
  ('Head WildGvng', '#A0522D', 'golden-pulse'),
  ('Manager WildGvng', '#D2691E', 'golden-pulse'),
  ('Chief WildGvng', '#CD853F', 'golden-pulse'),
  ('President WildGvng', '#F4A460', 'golden-pulse'),
  ('Wild Gvng Origins', '#8A2BE2', 'origins-glow'),
  ('Wild And Free Origins', '#4B0082', 'origins-glow'),
  ('Wild Gvng Member', '#00BFFF', 'member-shine'),
  ('Wild Gvng Artist', '#FF1493', 'artist-sparkle'),
  ('Wild Gvng Media', '#FF4500', 'media-pulse'),
  ('Wild Gvng Developer', '#00FF00', 'developer-code'),
  ('Wild Gvng Visual Designer', '#FF69B4', 'designer-flow'),
  ('Wild Gvng Graphic Editor', '#FF8C00', 'editor-creative')
ON CONFLICT (name) DO NOTHING;

-- Crear tabla de relación usuario-tags
CREATE TABLE IF NOT EXISTS public.user_has_tags (
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  tag_id INTEGER REFERENCES public.tags(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, tag_id)
);

-- Agregar índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS idx_user_has_tags_user_id ON public.user_has_tags(user_id);
CREATE INDEX IF NOT EXISTS idx_user_has_tags_tag_id ON public.user_has_tags(tag_id);