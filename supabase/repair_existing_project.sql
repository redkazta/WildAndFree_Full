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
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = u.id
);

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

-- roles: agregar columnas faltantes en tablas viejas
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS internal_name TEXT;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS display_name TEXT;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS is_system BOOLEAN DEFAULT FALSE;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- rellenar las columnas nuevas a partir de name
UPDATE public.roles SET internal_name = name WHERE internal_name IS NULL;
UPDATE public.roles SET display_name = name WHERE display_name IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS roles_name_key ON public.roles(name);
CREATE UNIQUE INDEX IF NOT EXISTS roles_internal_name_key ON public.roles(internal_name);

CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by UUID REFERENCES public.profiles(id),
  PRIMARY KEY (user_id, role_id)
);

ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS assigned_by UUID REFERENCES public.profiles(id);

INSERT INTO public.roles (name, internal_name, display_name, description, is_system)
SELECT v.name, v.internal_name, v.display_name, v.description, v.is_system
FROM (VALUES
  ('admin',  'admin',  'Admin',  'Acceso total al sistema', TRUE),
  ('staff',  'staff',  'Staff',  'Gestión operativa', TRUE),
  ('artist', 'artist', 'Artista','Perfil de artista', TRUE),
  ('fan',    'fan',    'Fan',    'Miembro de la comunidad', TRUE)
) AS v(name, internal_name, display_name, description, is_system)
WHERE NOT EXISTS (
  SELECT 1 FROM public.roles r WHERE r.name = v.name
);

-- 5) redkazta@gmail.com como admin; el resto como fan
INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM auth.users u
JOIN public.roles r ON r.name = 'admin'
WHERE lower(u.email) = 'redkazta@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM public.user_roles ur
    WHERE ur.user_id = u.id AND ur.role_id = r.id
  );

INSERT INTO public.user_roles (user_id, role_id)
SELECT u.id, r.id
FROM auth.users u
JOIN public.roles r ON r.name = 'fan'
WHERE lower(u.email) <> 'redkazta@gmail.com'
  AND NOT EXISTS (
    SELECT 1 FROM public.user_roles ur
    WHERE ur.user_id = u.id AND ur.role_id = r.id
  );

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
