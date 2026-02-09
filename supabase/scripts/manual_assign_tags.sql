-- SCRIPT PARA ASIGNACIÓN MANUAL DE TAGS
-- Usa este script en Supabase SQL Editor para gestionar tags sin usar el Admin Dashboard

-- 1. VERIFICAR USUARIOS Y SUS TAGS ACTUALES
SELECT 
    p.username, 
    p.email, 
    p.id as user_id, 
    p.user_tags as tag_ids,
    ARRAY_AGG(t.name) as tag_names
FROM public.profiles p
LEFT JOIN public.user_has_tags uht ON p.id = uht.user_id
LEFT JOIN public.tags t ON uht.tag_id = t.id
GROUP BY p.id, p.username, p.email, p.user_tags;

-- 2. VER TIPO DE TAGS DISPONIBLES
SELECT * FROM public.tags ORDER BY id;

-- 2.1 CREAR UN NUEVO TAG (Opcional)
-- INSERT INTO public.tags (name, color, animation, css_class)
-- VALUES ('BOSS', '#FF0000', 'pulse', 'role-owner');

-- 3. ASIGNAR TAG A UN USUARIO (Ejemplo: Asignar 'VIP' a ti mismo)
-- Reemplaza 'TU_EMAIL_AQUI' con tu email real
DO $$
DECLARE
    target_email TEXT := 'TU_EMAIL_AQUI'; -- <--- PON TU EMAIL AQUI
    tag_name_to_add TEXT := 'VIP';        -- <--- PON EL TAG AQUI (FAN, VIP, CREW, OG)
    
    target_user_id UUID;
    target_tag_id INTEGER;
BEGIN
    -- Buscar ID del usuario
    SELECT id INTO target_user_id FROM auth.users WHERE email = target_email;
    
    -- Buscar ID del tag
    SELECT id INTO target_tag_id FROM public.tags WHERE name = tag_name_to_add;
    
    IF target_user_id IS NOT NULL AND target_tag_id IS NOT NULL THEN
        -- Insertar relación
        INSERT INTO public.user_has_tags (user_id, tag_id)
        VALUES (target_user_id, target_tag_id)
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Tag % asignado a usuario %', tag_name_to_add, target_email;
    ELSE
        RAISE NOTICE 'Usuario o Tag no encontrado. Verifica los datos.';
    END IF;
END $$;

-- 5. ASIGNAR MÚLTIPLES TAGS A LA VEZ
DO $$
DECLARE
    target_email TEXT := 'TU_EMAIL_AQUI'; -- <--- PON TU EMAIL AQUI
    tags_to_add TEXT[] := ARRAY['VIP', 'CREW', 'OG']; -- <--- LISTA DE TAGS A AGREGAR
    
    target_user_id UUID;
BEGIN
    -- Buscar ID del usuario
    SELECT id INTO target_user_id FROM auth.users WHERE email = target_email;
    
    IF target_user_id IS NOT NULL THEN
        -- Insertar múltiples tags buscando sus IDs por nombre
        INSERT INTO public.user_has_tags (user_id, tag_id)
        SELECT target_user_id, id
        FROM public.tags
        WHERE name = ANY(tags_to_add)
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Tags % asignados a usuario %', tags_to_add, target_email;
    ELSE
        RAISE NOTICE 'Usuario no encontrado: %', target_email;
    END IF;
END $$;

-- 4. ELIMINAR TODOS LOS TAGS DE UN USUARIO (Reset)
-- DELETE FROM public.user_has_tags 
-- WHERE user_id = (SELECT id FROM auth.users WHERE email = 'TU_EMAIL_AQUI');
