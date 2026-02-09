-- Agregar columna user_tags a la tabla users para referencia rápida
-- Esta columna contendrá los IDs de tags como array para fácil acceso
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS user_tags INTEGER[] DEFAULT '{}';

-- Crear función para actualizar user_tags cuando se modifiquen los tags
CREATE OR REPLACE FUNCTION update_user_tags_column()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    -- Actualizar la columna user_tags con los IDs de tags del usuario
    UPDATE public.users 
    SET user_tags = (
      SELECT COALESCE(array_agg(tag_id ORDER BY tag_id), '{}')
      FROM public.user_has_tags 
      WHERE user_id = NEW.user_id
    )
    WHERE id = NEW.user_id;
    
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    -- Actualizar la columna user_tags después de eliminar
    UPDATE public.users 
    SET user_tags = (
      SELECT COALESCE(array_agg(tag_id ORDER BY tag_id), '{}')
      FROM public.user_has_tags 
      WHERE user_id = OLD.user_id
    )
    WHERE id = OLD.user_id;
    
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Crear triggers para mantener user_tags sincronizado
DROP TRIGGER IF EXISTS update_user_tags_after_insert ON public.user_has_tags;
DROP TRIGGER IF EXISTS update_user_tags_after_update ON public.user_has_tags;
DROP TRIGGER IF EXISTS update_user_tags_after_delete ON public.user_has_tags;

CREATE TRIGGER update_user_tags_after_insert
  AFTER INSERT ON public.user_has_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tags_column();

CREATE TRIGGER update_user_tags_after_update
  AFTER UPDATE ON public.user_has_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tags_column();

CREATE TRIGGER update_user_tags_after_delete
  AFTER DELETE ON public.user_has_tags
  FOR EACH ROW
  EXECUTE FUNCTION update_user_tags_column();

-- Actualizar todos los usuarios existentes con sus tags actuales
UPDATE public.users 
SET user_tags = (
  SELECT COALESCE(array_agg(uht.tag_id ORDER BY uht.tag_id), '{}')
  FROM public.user_has_tags uht
  WHERE uht.user_id = users.id
)
WHERE EXISTS (
  SELECT 1 
  FROM public.user_has_tags uht2 
  WHERE uht2.user_id = users.id
);