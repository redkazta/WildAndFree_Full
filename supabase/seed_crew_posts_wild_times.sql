-- =====================================================
-- SEED: publicaciones del crew para /the-wild-times
-- Proyecto: hepsyuwaymwlvyaddecs (proyecto nuevo)
--
-- Ejecutar en el SQL Editor de Supabase.
-- Es idempotente: si ya existen, no duplica.
-- El autor se resuelve solo (admin/staff o primer profile).
-- No siembra likes/comentarios para evitar FKs de usuarios viejos.
-- =====================================================

DO $$
DECLARE
  v_author UUID;
  v_inserted INTEGER;
BEGIN
  -- Autor: primero admin/staff, si no el primer profile disponible
  SELECT ur.user_id
    INTO v_author
  FROM public.user_roles ur
  JOIN public.roles r ON r.id = ur.role_id
  WHERE lower(r.name) IN ('admin', 'ceo wildgvng', 'staff')
  LIMIT 1;

  IF v_author IS NULL THEN
    SELECT id INTO v_author FROM public.profiles LIMIT 1;
  END IF;

  IF v_author IS NULL THEN
    RAISE NOTICE 'No hay profiles en el proyecto. Crea un usuario antes de sembrar crew_posts.';
    RETURN;
  END IF;

  INSERT INTO public.crew_posts
    (id, author_id, title, content, image_url, post_type, status, published_at, created_at)
  VALUES

    -- ANUNCIOS
    ('c9e10000-0000-4000-8000-000000000001', v_author,
     'Wild Gvng ya está en Spotify',
     'Toda la discografía de Wild Gvng ya está disponible en Spotify: 12 tracks, 3 EPs y un álbum completo.

🔗 Escúchalo aquí: https://open.spotify.com/artist/wildgvng

Agrégalo a tus playlists y compártelo con tu crew. Esto es apenas el comienzo.',
     NULL,
     'announcement', 'published', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'),

    ('c9e10000-0000-4000-8000-000000000002', v_author,
     'Convocatoria abierta: nuevos talentos',
     '¿Eres rapero, productor o beatmaker de Torreón y zona? Abrimos convocatoria para nuevos talentos.

Los seleccionados tendrán:
• 5 sesiones gratis en Wild Gvng Studios
• Producción y mezcla de un track profesional
• Distribución en todas las plataformas
• Foto de perfil profesional

Manda tu demo a crew@wildgvng.com. No importa tu nivel, importa tu hambre.',
     NULL,
     'announcement', 'published', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),

    ('c9e10000-0000-4000-8000-000000000003', v_author,
     'Wild Battle: la próxima edición',
     'Se viene una edición más del Wild Battle en el Foro Wild Gvng.

🏆 Premio en efectivo + merch exclusivo
🎤 16 competidores
📍 Torreón, Coahuila
⏰ 8:00 PM

Fecha e inscripciones: próximamente en wildgvng.com. Los mejores 16 freestylers de la región se enfrentan. ¿Quién se corona?',
     NULL,
     'announcement', 'published', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),

    -- PROMOCIONES
    ('c9e10000-0000-4000-8000-000000000004', v_author,
     'Drop Wild Gang: Anubis en árabe y chino',
     'Llegó la colección Wild Gang "Banda Salvaje": Anubis en árabe y en chino, en playera oversize y sudadera con capucha.

• Estampado de alta calidad
• Diseño exclusivo de la banda
• Disponibles ya en la tienda

Cuando se acaben, se acaban.',
     '/product-images/playera-anubis-arabe/vista-principal-anubis.jpg',
     'promotion', 'published', NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'),

    ('c9e10000-0000-4000-8000-000000000005', v_author,
     'Sudadera Banda Salvaje (mangas en chino)',
     'La sudadera negra de WILD GVNG con logo geométrico en el pecho y texto en chino en las mangas.

Diseño minimalista en la espalda, mensaje contundente en las mangas. Ya disponible en la tienda en línea.',
     '/product-images/hoodie-chino-mangas/vista-principal-frente.jpg',
     'promotion', 'published', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),

    -- EVENTOS
    ('c9e10000-0000-4000-8000-000000000006', v_author,
     'Noche de freestyle en el Centro Histórico',
     'Sesión de freestyle sorpresa en el centro de Torreón.

Punto de encuentro: Plaza Mayor, 8 PM.
Trae tu crew, tus rimas y tu hambre.

Vamos a hacer historia. El que no llega, pierde.',
     'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1200&q=80',
     'event', 'published', NOW() - INTERVAL '8 hours', NOW() - INTERVAL '8 hours'),

    -- GENERAL
    ('c9e10000-0000-4000-8000-000000000007', v_author,
     'Detrás del micrófono: así grabamos Fuego del Desierto',
     'Les compartimos el behind the scenes de la grabación de nuestro hit más reciente.

Producido por KAZTA, grabado en Wild Gvng Studios. El video completo ya está en nuestro canal.',
     'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=1200&q=80',
     'general', 'published', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),

    ('c9e10000-0000-4000-8000-000000000008', v_author,
     'Colaboración sorpresa en camino',
     'No podemos decir con quién todavía, pero la colaboración que viene va a romperla.

Grabando toda la semana en el estudio. Dos estilos, una visión.

Estén atentos 🔥',
     NULL,
     'general', 'published', NOW() - INTERVAL '10 hours', NOW() - INTERVAL '10 hours'),

    ('c9e10000-0000-4000-8000-000000000009', v_author,
     '5 tips de producción para beats underground',
     'KAZTA comparte 5 tips para mejorar tus beats desde casa:

1. Las percusiones lo son todo: layerear kicks y snares
2. Sample selection: busca texturas, no melodías obvias
3. Menos es más: un beat saturado pierde fuerza
4. El mixing empieza en la selección de sonidos
5. Sé original: no copies el sonido de moda

Artículo completo en Wild Writings.',
     'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=1200&q=80',
     'general', 'published', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),

    ('c9e10000-0000-4000-8000-000000000010', v_author,
     'Selección de tracks para el mixtape',
     'Seleccionando los tracks para el mixtape de temporada.

Van a escuchar cosas que nunca habíamos sacado: colaboraciones, freestyles y beats que guardamos por años.

Pronto. Esto se viene con todo 🔥🎶',
     'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=1200&q=80',
     'general', 'published', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days')

  ON CONFLICT (id) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  RAISE NOTICE 'crew_posts insertados: % (autor %)', v_inserted, v_author;
END $$;

-- Verificación: deberían salir 10 filas publicadas
SELECT status, post_type, count(*)
FROM public.crew_posts
GROUP BY 1, 2
ORDER BY 1, 2;

-- Para borrar este seed si ya no lo quieres:
-- DELETE FROM public.crew_posts WHERE id::text LIKE 'c9e10000-0000-4000-8000-%';
