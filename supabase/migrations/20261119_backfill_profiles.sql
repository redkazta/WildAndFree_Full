-- =====================================================
-- Perfiles: rellenar nombre/usuario/avatar desde auth.users
-- y mantener el perfil al día en registros nuevos.
--
-- Ejecutar en el SQL Editor de Supabase.
-- Idempotente.
-- =====================================================

-- 1) Backfill de perfiles incompletos
DO $$
DECLARE
  r RECORD;
  v_nombre TEXT;
  v_username TEXT;
BEGIN
  FOR r IN
    SELECT p.id, p.nombre, p.username, p.avatar_url, u.email, u.raw_user_meta_data AS meta
    FROM public.profiles p
    JOIN auth.users u ON u.id = p.id
    WHERE p.nombre IS NULL
       OR p.username IS NULL
       OR p.avatar_url IS NULL
  LOOP
    v_nombre := COALESCE(
      r.nombre,
      NULLIF(BTRIM(r.meta->>'nombre'), ''),
      NULLIF(BTRIM(r.meta->>'name'), ''),
      NULLIF(BTRIM(r.meta->>'full_name'), ''),
      NULLIF(split_part(COALESCE(r.email, ''), '@', 1), '')
    );

    v_username := COALESCE(
      r.username,
      NULLIF(BTRIM(r.meta->>'username'), ''),
      NULLIF(BTRIM(r.meta->>'user_name'), ''),
      NULLIF(split_part(COALESCE(r.email, ''), '@', 1), '')
    );
    v_username := lower(regexp_replace(COALESCE(v_username, ''), '[^a-zA-Z0-9._-]', '', 'g'));

    IF v_username = '' THEN
      v_username := 'user_' || left(r.id::text, 8);
    END IF;

    -- Evitar choque con un username existente
    WHILE EXISTS (
      SELECT 1
      FROM public.profiles
      WHERE id <> r.id
        AND lower(username) = v_username
    ) LOOP
      v_username := v_username || floor(random() * 10)::text;
    END LOOP;

    UPDATE public.profiles
    SET nombre = COALESCE(r.nombre, v_nombre),
        username = COALESCE(r.username, v_username),
        avatar_url = COALESCE(r.avatar_url, NULLIF(r.meta->>'avatar_url', ''))
    WHERE id = r.id;
  END LOOP;
END $$;

-- 2) Trigger de registro: nombre/usuario también desde el email
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  fan_role_id INTEGER;
  v_nombre TEXT;
  v_username TEXT;
BEGIN
  v_nombre := COALESCE(
    NULLIF(BTRIM(NEW.raw_user_meta_data->>'nombre'), ''),
    NULLIF(BTRIM(NEW.raw_user_meta_data->>'name'), ''),
    NULLIF(BTRIM(NEW.raw_user_meta_data->>'full_name'), ''),
    NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), '')
  );

  v_username := COALESCE(
    NULLIF(BTRIM(NEW.raw_user_meta_data->>'username'), ''),
    NULLIF(BTRIM(NEW.raw_user_meta_data->>'user_name'), ''),
    NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), '')
  );
  v_username := lower(regexp_replace(COALESCE(v_username, ''), '[^a-zA-Z0-9._-]', '', 'g'));

  IF v_username <> '' AND EXISTS (
    SELECT 1 FROM public.profiles WHERE lower(username) = v_username
  ) THEN
    v_username := v_username || '_' || left(NEW.id::text, 4);
  END IF;

  -- 1. Crear perfil (si ya existe, solo completa huecos)
  INSERT INTO public.profiles (id, nombre, username, phone, ubicacion, birthdate)
  VALUES (
    NEW.id,
    v_nombre,
    NULLIF(v_username, ''),
    NEW.raw_user_meta_data->>'phone',
    COALESCE(NEW.raw_user_meta_data->>'ubicacion', 'Torreón Coahuila'),
    NULLIF(NEW.raw_user_meta_data->>'birthdate', '')::DATE
  )
  ON CONFLICT (id) DO UPDATE
  SET nombre = COALESCE(profiles.nombre, EXCLUDED.nombre),
      username = COALESCE(profiles.username, EXCLUDED.username);

  -- 2. Rol fan por defecto
  SELECT id INTO fan_role_id FROM public.roles WHERE internal_name = 'fan' LIMIT 1;
  IF fan_role_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role_id)
    VALUES (NEW.id, fan_role_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- 3. Balance de tokens
  INSERT INTO public.user_tokens (user_id, balance)
  VALUES (NEW.id, 0)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- 3) Verificación
SELECT id, nombre, username, avatar_url
FROM public.profiles
ORDER BY created_at NULLS LAST;
