-- Trigger: auto-crear profile + rol fan + tokens al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  fan_role_id INTEGER;
BEGIN
  -- 1. Crear perfil
  INSERT INTO public.profiles (id, nombre, username, phone, ubicacion, birthdate)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'nombre', NEW.raw_user_meta_data->>'full_name'),
    NEW.raw_user_meta_data->>'username',
    NEW.raw_user_meta_data->>'phone',
    COALESCE(NEW.raw_user_meta_data->>'ubicacion', 'Torreón Coahuila'),
    NULLIF(NEW.raw_user_meta_data->>'birthdate', '')::DATE
  )
  ON CONFLICT (id) DO NOTHING;

  -- 2. Asignar rol fan por defecto
  SELECT id INTO fan_role_id FROM public.roles WHERE internal_name = 'fan' LIMIT 1;
  IF fan_role_id IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role_id)
    VALUES (NEW.id, fan_role_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- 3. Crear balance de tokens
  INSERT INTO public.user_tokens (user_id, balance)
  VALUES (NEW.id, 0)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
