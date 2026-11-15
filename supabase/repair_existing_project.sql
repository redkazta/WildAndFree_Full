-- =====================================================
-- REPARACIÓN PARA PROYECTO SUPABASE EXISTENTE
-- Crea/ajusta profiles y roles para los auth.users actuales.
-- Idempotente: se puede ejecutar varias veces.
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1) profiles: crear si no existe
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  nombre TEXT,
  username TEXT,
  avatar_url TEXT,
  bio TEXT,
  phone TEXT,
  birthdate DATE,
  ubicacion TEXT,
  role TEXT DEFAULT 'fan',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2) profiles: agregar columnas faltantes
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS nombre TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS username TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS birthdate DATE;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS ubicacion TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'fan';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 3) Crear un profile para cada auth.user que no lo tenga
INSERT INTO public.profiles (id, nombre, username, avatar_url)
SELECT
  u.id,
  COALESCE(u.raw_user_meta_data->>'nombre', split_part(u.email, '@', 1)),
  COALESCE(u.raw_user_meta_data->>'username', split_part(u.email, '@', 1)),
  u.raw_user_meta_data->>'avatar_url'
FROM auth.users u
ON CONFLICT (id) DO NOTHING;

-- 4) roles y user_roles
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

INSERT INTO public.roles (name, internal_name, display_name, description, is_system) VALUES
  ('admin',  'admin',  'Admin',  'Acceso total al sistema', TRUE),
  ('staff',  'staff',  'Staff',  'Gestión operativa', TRUE),
  ('artist', 'artist', 'Artista','Perfil de artista', TRUE),
  ('fan',    'fan',    'Fan',    'Miembro de la comunidad', TRUE)
ON CONFLICT (name) DO NOTHING;

-- 5) redkazta@gmail.com como admin; el resto como fan
INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM auth.users u
JOIN public.roles r ON r.name = 'admin'
WHERE lower(u.email) = 'redkazta@gmail.com'
ON CONFLICT DO NOTHING;

INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM auth.users u
JOIN public.roles r ON r.name = 'fan'
WHERE lower(u.email) <> 'redkazta@gmail.com'
ON CONFLICT DO NOTHING;

-- 6) Verificación
SELECT
  u.email,
  p.nombre,
  p.username,
  p.role,
  r.name AS rol_asignado
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
LEFT JOIN public.user_roles ur ON ur.user_id = u.id
LEFT JOIN public.roles r ON r.id = ur.role_id
ORDER BY u.created_at DESC;
