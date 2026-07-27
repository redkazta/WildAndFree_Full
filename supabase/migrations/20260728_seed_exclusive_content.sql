-- =====================================================
-- SEED: Exclusive Content for artist profiles
-- KAZTA: ec7ba40e-971a-4729-ad17-e83a0fdd42b5
-- Ralf: cd2611f7-1ad1-4fff-8032-77f8ee616fbb
-- =====================================================

INSERT INTO public.exclusive_content (id, user_id, title, description, content_type, file_url, preview_url, token_price, status) VALUES
  ('e1000000-0000-0000-0000-000000000001', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'BEHIND THE SCENES: WILD BATTLE VOL.12',
    'Acceso exclusivo al backstage de la última Wild Battle. Mira cómo se preparan los freestylers antes de salir al escenario, las estrategias de último minuto y las reacciones en caliente.',
    'video',
    'https://example.com/bts-wb12.mp4',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=600&q=80',
    50, 'published'),

  ('e1000000-0000-0000-0000-000000000002', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'SESIÓN DE FREESTYLE: VOL.7',
    'Grabación en vivo desde Wild Gvng Studios. 15 minutos de freestyle continuo, sin cortes, sin edición. Pura lírica del desierto.',
    'audio',
    'https://example.com/session-7.mp3',
    'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=600&q=80',
    30, 'published'),

  ('e1000000-0000-0000-0000-000000000003', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'MIX: MEJORES PUNCHLINES 2025',
    'Recopilación exclusiva de los mejores punchlines del año pasados por la crew. Solo para verdaderos seguidores.',
    'audio',
    'https://example.com/mix-punchlines.mp3',
    'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=600&q=80',
    40, 'published'),

  ('e1000000-0000-0000-0000-000000000004', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'WALLPAPER EXCLUSIVO: DESIERTO',
    'Fondo de pantalla oficial de Wild Gvng edición Desierto. 4K. Disponible en múltiples resoluciones.',
    'download',
    'https://example.com/wallpaper-deserto.zip',
    'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=600&q=80',
    0, 'published'),

  ('e1000000-0000-0000-0000-000000000005', 'cd2611f7-1ad1-4fff-8032-77f8ee616fbb',
    'ACOUSTIC FREESTYLE: RALF DÍAZ',
    'Versión acústica del freestyle más famoso de Ralf. Sin beat, solo voz y verdad. Letras que llegan al alma.',
    'audio',
    'https://example.com/ralf-acoustic.mp3',
    'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=600&q=80',
    25, 'published'),

  ('e1000000-0000-0000-0000-000000000006', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'COLAB: KAZTA x RALF DÍAZ',
    'Colaboración exclusiva que no saldrá en plataformas. Solo disponible aquí. Beat producido por KAZTA, letras de ambos.',
    'audio',
    'https://example.com/kazta-ralf-collab.mp3',
    'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=600&q=80',
    75, 'published'),

  ('e1000000-0000-0000-0000-000000000007', 'ec7ba40e-971a-4729-ad17-e83a0fdd42b5',
    'TUTORIAL: CÓMO HACER UN BEAT',
    'KAZTA te enseña paso a paso cómo producir un beat desde cero en FL Studio. 45 minutos de contenido exclusivo.',
    'video',
    'https://example.com/tutorial-beat.mp4',
    'https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=600&q=80',
    100, 'published')
ON CONFLICT (id) DO NOTHING;
