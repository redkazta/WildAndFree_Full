-- =====================================================
-- SEED FINAL: Crew posts + reacciones para The Wild Times
-- Autores: KAZTA (ec7ba40e-971a-4729-ad17-e83a0fdd42b5),
--          Ralf Díaz (cd2611f7-1ad1-4fff-8032-77f8ee616fbb)
-- =====================================================

-- Crew posts (fuente única para sidebar announcements + feed)
INSERT INTO public.crew_posts (id, author_id, title, content, image_url, post_type, status, published_at) VALUES

  -- ANNOUNCEMENTS (aparecen en sidebar)
  ('cp300000-0000-0000-0000-000000000001', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Wild Gvng llega a Spotify',
    'Después de meses de negociaciones, toda la discografía de Wild Gvng ya está disponible en Spotify. 12 tracks, 3 EPs y un álbum completo. Escúchalo ahora y agrégalo a tus playlists.

    🔗 Enlace directo: https://open.spotify.com/artist/wildgvng

    Esto es apenas el comienzo. Pronto más sorpresas.',
    'https://images.unsplash.com/photo-1611339555312-e607c8352fd7?w=1200&q=80',
    'announcement', 'published', NOW() - INTERVAL '2 hours'),

  ('cp300000-0000-0000-0000-000000000002', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Convocatoria: Nuevos Talentos 2026',
    '¿Eres rapero, productor o beatmaker de Torreón y zona?

    Abrimos convocatoria para nuevos talentos. Los seleccionados tendrán:
    • 5 sesiones gratis en Wild Gvng Studios
    • Producción y mezcla de un track profesional
    • Distribución en todas las plataformas
    • Foto de perfil profesional

    Manda tu demo a crew@wildgvng.com antes del 30 de septiembre.

    No importa tu nivel, importa tu hambre.',
    'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=1200&q=80',
    'announcement', 'published', NOW() - INTERVAL '1 day'),

  ('cp300000-0000-0000-0000-000000000003', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Wild Battle Vol. 13 — Fecha confirmada',
    'La próxima edición del Wild Battle será el 30 de agosto en el Foro Wild Gvng.

    🏆 Premio: $8,000 MXN + merch exclusivo
    🎤 16 competidores
    📍 Foro Wild Gvng, Torreón
    ⏰ 8:00 PM

    Inscripciones abiertas hasta el 25 de agosto en wildgvng.com/battle

    Los mejores 16 freestylers de la región se enfrentan. ¿Quién se corona?',
    'https://images.unsplash.com/photo-1460723237483-7a6dc9d0b212?w=1200&q=80',
    'announcement', 'published', NOW() - INTERVAL '3 days'),

  ('cp300000-0000-0000-0000-000000000004', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Nueva sudadera edición limitada',
    'Acaba de llegar la sudadera Wild Gvng edición "Desierto".

    • 50 unidades solamente
    • Diseño exclusivo
    • Parche bordado
    • Estampado de alta calidad

    Disponible en la tienda. Cuando se acaben, se acaban.

    🏷️ $650 MXN',
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=1200&q=80',
    'announcement', 'published', NOW() - INTERVAL '5 days'),

  -- EVENT POSTS
  ('cp300000-0000-0000-0000-000000000005', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Noche de Freestyle en el Centro Histórico',
    'Este sábado 10 de agosto, sesión de freestyle sorpresa en el centro de Torreón.

    Punto de encuentro: Plaza Mayor a las 8 PM.
    Trae tu crew, tus rimas y tu hambre.

    Vamos a hacer historia. El que no llega, pierde.',
    'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1200&q=80',
    'event', 'published', NOW() - INTERVAL '8 hours'),

  -- GENERAL POSTS
  ('cp300000-0000-0000-0000-000000000006', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Detrás del micrófono: Así grabamos Fuego del Desierto',
    'Les compartimos el behind the scenes de la grabación de nuestro hit más reciente.

    Producido por KAZTA, grabado en Wild Gvng Studios.
    El video completo ya está en nuestro canal de YouTube.

    Enlace: https://youtube.com/wildgvng',
    'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=1200&q=80',
    'general', 'published', NOW() - INTERVAL '1 day'),

  ('cp300000-0000-0000-0000-000000000007', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Colaboración sorpresa en camino',
    'No podemos decir con quién todavía, pero la colaboración que viene va a romperla.

    Grabando toda la semana en el estudio. Esta colaboración es historia pura.
    Dos estilos, una visión.

    Estén atentos 🔥',
    NULL,
    'general', 'published', NOW() - INTERVAL '6 hours'),

  ('cp300000-0000-0000-0000-000000000008', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Tips de producción para beats underground',
    'KAZTA comparte 5 tips para mejorar tus beats desde casa:

    1. Las percusiones lo son todo — layerear kicks y snares
    2. Sample selection: busca texturas, no melodías obvias
    3. Menos es más — un beat saturado pierde fuerza
    4. El mixing empieza en la selección de sonidos
    5. Sé original — no copies el sonido de moda

    Artículo completo en Wild Writings.',
    'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=1200&q=80',
    'general', 'published', NOW() - INTERVAL '2 days'),

  ('cp300000-0000-0000-0000-000000000009', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Haciendo selección de tracks para el mixtape',
    'Seleccionando los tracks para el mixtape de verano.

    Van a escuchar cosas que nunca habíamos sacado. Colaboraciones, freestyles, beats que guardamos por años.

    Aparten el 15 de agosto. Esto se viene con todo 🔥🎶',
    'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=1200&q=80',
    'general', 'published', NOW() - INTERVAL '3 days'),

  -- PROMOTION POSTS
  ('cp300000-0000-0000-0000-000000000010', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Merch preview: Diseño Desierto',
    'Nuevo merch preview 🔥

    Diseño "Desierto" — edición limitada.
    Pronto disponibles en la tienda.

    ¿Qué les parece el diseño? Los leemos.',
    'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=1200&q=80',
    'promotion', 'published', NOW() - INTERVAL '5 days')

ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- REACCIONES en crew_posts
-- =====================================================

-- Likes
INSERT INTO public.wall_likes (post_id, user_id) VALUES
  ('cp300000-0000-0000-0000-000000000001', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('cp300000-0000-0000-0000-000000000002', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000003', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('cp300000-0000-0000-0000-000000000004', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'),
  ('cp300000-0000-0000-0000-000000000006', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000006', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('cp300000-0000-0000-0000-000000000007', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000008', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('cp300000-0000-0000-0000-000000000009', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'),
  ('cp300000-0000-0000-0000-000000000010', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000010', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5')
ON CONFLICT DO NOTHING;

-- Comentarios
INSERT INTO public.wall_comments (id, post_id, user_id, content, created_at) VALUES
  ('c3000000-0000-0000-0000-000000000001', 'cp300000-0000-0000-0000-000000000001', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Ya lo estoy escuchando en repeat! Esto era lo que necesitábamos 🔥', NOW() - INTERVAL '1 hour'),
  ('c3000000-0000-0000-0000-000000000002', 'cp300000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790',
    'Llevábamos años esperando esto. Por fin en todas las plataformas 💪', NOW() - INTERVAL '50 minutes'),
  ('c3000000-0000-0000-0000-000000000003', 'cp300000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Este Wild Battle va a ser histórico. El nivel de los competidores cada vez más alto.', NOW() - INTERVAL '2 days'),
  ('c3000000-0000-0000-0000-000000000004', 'cp300000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Ahí estaremos Ralf! Plaza Mayor va a temblar 🔥', NOW() - INTERVAL '7 hours'),
  ('c3000000-0000-0000-0000-000000000005', 'cp300000-0000-0000-0000-000000000006', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'El BTS quedó brutal. Se ve el trabajazo que le metieron 🎬', NOW() - INTERVAL '20 hours'),
  ('c3000000-0000-0000-0000-000000000006', 'cp300000-0000-0000-0000-000000000008', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'Tip #4 es la neta. El mixing empieza desde la selección de sonidos, no al final.', NOW() - INTERVAL '1 day'),
  ('c3000000-0000-0000-0000-000000000007', 'cp300000-0000-0000-0000-000000000010', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Ese diseño está brutal. Me apunto una sudadera talla M!', NOW() - INTERVAL '4 days'),
  ('c3000000-0000-0000-0000-000000000008', 'cp300000-0000-0000-0000-000000000009', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'Ese mixtape va a estar épico, Ralf. Cuenta conmigo para una colaboración 🎤', NOW() - INTERVAL '2 days')
ON CONFLICT (id) DO NOTHING;

-- Reposts
INSERT INTO public.wall_reposts (post_id, user_id) VALUES
  ('cp300000-0000-0000-0000-000000000001', 'ab563ebf-1396-4b0f-a4b7-8d1dec846790'),
  ('cp300000-0000-0000-0000-000000000003', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb'),
  ('cp300000-0000-0000-0000-000000000005', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5'),
  ('cp300000-0000-0000-0000-000000000010', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb')
ON CONFLICT DO NOTHING;
