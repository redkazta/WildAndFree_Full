-- =====================================================
-- SEED: Roles, Permissions & Role-Permissions
-- =====================================================

-- Insert roles
INSERT INTO public.roles (name, internal_name, display_name, description, is_system) VALUES
  ('admin', 'admin', 'Administrador', 'Acceso total al sistema', TRUE),
  ('artist', 'artist', 'Artista', 'Creador de contenido y música', TRUE),
  ('staff', 'staff', 'Staff', 'Gestión operativa del día a día', TRUE),
  ('fan', 'fan', 'Fan', 'Usuario regular de la plataforma', TRUE)
ON CONFLICT (name) DO UPDATE SET
  internal_name = EXCLUDED.internal_name,
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description;

-- Insert permissions
INSERT INTO public.permissions (name, description, module) VALUES
  -- Dashboard
  ('dashboard.view', 'Ver dashboard del ERP', 'dashboard'),
  -- Users
  ('users.view', 'Ver listado de usuarios', 'users'),
  ('users.manage', 'Editar/eliminar usuarios', 'users'),
  ('users.assign_roles', 'Asignar roles a usuarios', 'users'),
  ('users.verify_artists', 'Aprobar verificación de artistas', 'users'),
  -- Content
  ('content.view', 'Ver contenido exclusivo', 'content'),
  ('content.manage', 'Aprobar/rechazar contenido', 'content'),
  ('content.create', 'Crear contenido exclusivo', 'content'),
  -- Tags
  ('tags.view', 'Ver tags', 'tags'),
  ('tags.manage', 'Crear/editar/eliminar tags', 'tags'),
  ('tags.assign', 'Asignar tags a usuarios', 'tags'),
  -- Events
  ('events.view', 'Ver eventos', 'events'),
  ('events.manage', 'Crear/editar/eliminar eventos', 'events'),
  -- Orders
  ('orders.view', 'Ver pedidos', 'orders'),
  ('orders.manage', 'Actualizar estado de pedidos', 'orders'),
  -- Inventory
  ('inventory.view', 'Ver inventario', 'inventory'),
  ('inventory.manage', 'Editar inventario y variantes', 'inventory'),
  -- Versus
  ('versus.view', 'Ver versus', 'versus'),
  ('versus.manage', 'Gestionar batallas y freestylers', 'versus'),
  -- Radio
  ('radio.view', 'Ver radio', 'radio'),
  ('radio.manage', 'Gestionar radio, episodios y schedule', 'radio'),
  -- Configuration
  ('config.view', 'Ver configuración', 'config'),
  ('config.manage', 'Editar configuración del sistema', 'config'),
  -- Notifications
  ('notifications.send', 'Enviar notificaciones del sistema', 'notifications')
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  module = EXCLUDED.module;

-- Assign permissions to roles (admin = all, staff = operational, artist = own content, fan = basic)

-- Admin: everything (handled as wildcard '*' in code, no need to insert all)
-- But insert anyway for clarity / non-admin permissions list
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'admin'
  AND p.name IN (
    'dashboard.view',
    'users.view', 'users.manage', 'users.assign_roles', 'users.verify_artists',
    'content.view', 'content.manage',
    'tags.view', 'tags.manage', 'tags.assign',
    'events.view', 'events.manage',
    'orders.view', 'orders.manage',
    'inventory.view', 'inventory.manage',
    'versus.view', 'versus.manage',
    'radio.view', 'radio.manage',
    'config.view', 'config.manage',
    'notifications.send'
  )
ON CONFLICT DO NOTHING;

-- Staff: operational management
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'staff'
  AND p.name IN (
    'dashboard.view',
    'users.view', 'users.verify_artists',
    'content.view', 'content.manage',
    'tags.view', 'tags.manage', 'tags.assign',
    'events.view', 'events.manage',
    'orders.view', 'orders.manage',
    'inventory.view', 'inventory.manage',
    'versus.view',
    'radio.view',
    'config.view'
  )
ON CONFLICT DO NOTHING;

-- Artist: own content management
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'artist'
  AND p.name IN (
    'content.view', 'content.create',
    'tags.view',
    'events.view',
    'versus.view',
    'radio.view'
  )
ON CONFLICT DO NOTHING;

-- Fan: basic view permissions
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.name = 'fan'
  AND p.name IN (
    'content.view',
    'tags.view',
    'events.view',
    'versus.view',
    'radio.view'
  )
ON CONFLICT DO NOTHING;
