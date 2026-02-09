-- SIMPLE TAG SYSTEM SCHEMA (ROBUST & SECURE V3)
-- Run this directly in Supabase Dashboard → SQL Editor

-- 1. Tabla de tags visibles
CREATE TABLE IF NOT EXISTS public.tags (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  color VARCHAR(7) DEFAULT '#ffffff',
  animation VARCHAR(50) DEFAULT 'none',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Asegurar que columnas existan
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS color VARCHAR(7) DEFAULT '#ffffff';
ALTER TABLE public.tags ADD COLUMN IF NOT EXISTS animation VARCHAR(50) DEFAULT 'none';

-- 2. Tabla de relación usuario-tag
CREATE TABLE IF NOT EXISTS public.user_has_tags (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  tag_id INTEGER REFERENCES public.tags(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, tag_id)
);

-- 3. Columna user_tags en tabla profiles (cache para frontend)
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS user_tags INTEGER[] DEFAULT '{}';

-- 4. Tag FAN por defecto
INSERT INTO public.tags (name, color, animation) VALUES
  ('FAN', '#6366F1', 'member-shine')
ON CONFLICT (name) DO NOTHING;

-- 5. Trigger para mantener user_tags actualizado
CREATE OR REPLACE FUNCTION update_user_tags()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.profiles 
    SET user_tags = array_append(user_tags, NEW.tag_id)
    WHERE id = NEW.user_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.profiles 
    SET user_tags = array_remove(user_tags, OLD.tag_id)
    WHERE id = OLD.user_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 6. Crear triggers
DROP TRIGGER IF EXISTS update_user_tags_trigger ON public.user_has_tags;
CREATE TRIGGER update_user_tags_trigger
  AFTER INSERT OR DELETE ON public.user_has_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tags();

-- 7. SEGURIDAD (Row Level Security)
-- Habilitar RLS para forzar acceso solo vía Service Role (Backend)
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_has_tags ENABLE ROW LEVEL SECURITY;

-- No crear políticas para 'anon' o 'authenticated' asegura que SOLO el backend (service_role) pueda acceder.
-- Esto cumple con "nada debe de estar expuesto en el front".
