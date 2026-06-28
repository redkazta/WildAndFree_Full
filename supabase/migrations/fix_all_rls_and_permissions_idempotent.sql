-- =====================================================
-- FIX: TODAS LAS RLS POLICIES (IDEMPOTENTE - seguro de ejecutar)
-- =====================================================
-- Este script usa DROP POLICY IF EXISTS antes de cada CREATE POLICY
-- para evitar el error "policy already exists"
-- Se puede ejecutar cuantas veces sea necesario

-- =====================================================
-- 1. Asegurar que los roles existen
-- =====================================================
INSERT INTO public.roles (name, internal_name, display_name, description, is_system) VALUES
  ('owner', 'owner', 'Dueño', 'Control total del crew', true),
  ('admin', 'admin', 'Admin', 'Gestión completa del sistema', true),
  ('staff_manager', 'staff_manager', 'Staff Senior', 'Gestión administrativa con privilegios extendidos', false),
  ('staff', 'staff', 'Staff', 'Operaciones básicas del sistema', false),
  ('staff_marketing', 'staff_marketing', 'Marketing', 'Publicación de contenido del crew', false),
  ('artist', 'artist', 'Artista', 'Perfil verificado, sube contenido', true),
  ('fan', 'fan', 'Miembro', 'Interactúa, compra, sigue artistas', true),
  ('guest', 'guest', 'Visitante', 'Solo ve contenido público', true)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 2. Asegurar que los permisos existen
-- =====================================================
INSERT INTO public.permissions (name, description, module) VALUES
  ('orders.view', 'Ver pedidos', 'orders'),
  ('orders.manage', 'Gestionar pedidos', 'orders'),
  ('orders.ship', 'Marcar envíos', 'orders'),
  ('inventory.view', 'Ver inventario', 'inventory'),
  ('inventory.manage', 'Gestionar productos', 'inventory'),
  ('content.view', 'Ver contenido pendiente', 'content'),
  ('content.approve', 'Aprobar/rechazar contenido', 'content'),
  ('content.create_crew', 'Crear contenido del crew', 'content'),
  ('users.view', 'Ver usuarios', 'users'),
  ('users.manage', 'Gestionar usuarios y roles', 'users'),
  ('users.verify_artist', 'Aprobar verificación de artistas', 'users'),
  ('tags.manage', 'Gestionar tags', 'tags'),
  ('events.manage', 'Gestionar eventos', 'events'),
  ('versus.manage', 'Gestionar freestylers y stats', 'versus'),
  ('config.manage', 'Configurar el sistema', 'config'),
  ('reports.view', 'Ver reportes', 'reports')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 3. Asignar TODOS los permisos a admin y owner
-- =====================================================
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name IN ('admin', 'owner')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. Asignar permisos específicos a staff
-- =====================================================
INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff_manager'
AND p.name IN ('orders.view', 'orders.manage', 'orders.ship', 'inventory.view', 'inventory.manage', 'content.view', 'content.approve', 'users.view', 'reports.view')
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff'
AND p.name IN ('orders.view', 'orders.manage', 'inventory.view', 'content.view', 'content.approve')
ON CONFLICT DO NOTHING;

INSERT INTO public.role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM public.roles r, public.permissions p
WHERE r.internal_name = 'staff_marketing'
AND p.name IN ('content.view', 'content.create_crew')
ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. RLS: profiles
-- =====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles
FOR SELECT TO authenticated
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles" ON public.profiles
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
FOR UPDATE TO authenticated
USING (auth.uid() = id);

DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;
CREATE POLICY "Admins can update any profile" ON public.profiles
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 6. RLS: user_roles
-- =====================================================
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own roles" ON public.user_roles;
CREATE POLICY "Users can view their own roles" ON public.user_roles
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all user_roles" ON public.user_roles;
CREATE POLICY "Admins can view all user_roles" ON public.user_roles
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 7. RLS: roles (todos pueden leer)
-- =====================================================
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Roles are viewable by everyone" ON public.roles;
CREATE POLICY "Roles are viewable by everyone" ON public.roles
FOR SELECT TO public
USING (true);

-- =====================================================
-- 8. RLS: permissions (todos pueden leer)
-- =====================================================
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Permissions viewable by all" ON public.permissions;
CREATE POLICY "Permissions viewable by all" ON public.permissions
FOR SELECT TO authenticated
USING (true);

-- =====================================================
-- 9. RLS: role_permissions (admins pueden leer todo)
-- =====================================================
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view role_permissions" ON public.role_permissions;
CREATE POLICY "Admins can view role_permissions" ON public.role_permissions
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 10. RLS: store_orders
-- =====================================================
ALTER TABLE public.store_orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all orders" ON public.store_orders;
CREATE POLICY "Admins can view all orders" ON public.store_orders
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can update orders" ON public.store_orders;
CREATE POLICY "Admins can update orders" ON public.store_orders
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 11. RLS: store_products
-- =====================================================
ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all products" ON public.store_products;
CREATE POLICY "Admins can view all products" ON public.store_products
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can manage products" ON public.store_products;
CREATE POLICY "Admins can manage products" ON public.store_products
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 12. RLS: exclusive_content
-- =====================================================
ALTER TABLE public.exclusive_content ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all content" ON public.exclusive_content;
CREATE POLICY "Admins can view all content" ON public.exclusive_content
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can manage content" ON public.exclusive_content;
CREATE POLICY "Admins can manage content" ON public.exclusive_content
FOR UPDATE TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 13. RLS: events
-- =====================================================
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
CREATE POLICY "Admins can view all events" ON public.events
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can manage events" ON public.events;
CREATE POLICY "Admins can manage events" ON public.events
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 14. RLS: user_tokens
-- =====================================================
ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own tokens" ON public.user_tokens;
CREATE POLICY "Users can view own tokens" ON public.user_tokens
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all tokens" ON public.user_tokens;
CREATE POLICY "Admins can view all tokens" ON public.user_tokens
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 15. RLS: tags y user_has_tags
-- =====================================================
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Tags are viewable by everyone" ON public.tags;
CREATE POLICY "Tags are viewable by everyone" ON public.tags
FOR SELECT TO public
USING (true);

ALTER TABLE public.user_has_tags ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own tags" ON public.user_has_tags;
CREATE POLICY "Users can view their own tags" ON public.user_has_tags
FOR SELECT TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can view all user_tags" ON public.user_has_tags;
CREATE POLICY "Admins can view all user_tags" ON public.user_has_tags
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 16. RLS: store_order_items
-- =====================================================
ALTER TABLE public.store_order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all order items" ON public.store_order_items;
CREATE POLICY "Admins can view all order items" ON public.store_order_items
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 17. RLS: product_variants
-- =====================================================
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all variants" ON public.product_variants;
CREATE POLICY "Admins can view all variants" ON public.product_variants
FOR SELECT TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
);

-- =====================================================
-- 18. Asegurar que la función get_my_role funciona
-- =====================================================
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT r.name
  FROM public.user_roles ur
  JOIN public.roles r ON r.id = ur.role_id
  WHERE ur.user_id = auth.uid()
  ORDER BY CASE
    WHEN lower(r.name) = 'admin' THEN 1
    WHEN lower(r.name) = 'artist' THEN 2
    WHEN lower(r.name) = 'fan' THEN 3
    ELSE 100
  END
  LIMIT 1
$$;

GRANT EXECUTE ON FUNCTION public.get_my_role() TO anon, authenticated;

-- =====================================================
-- FIX: Infinite recursion in RLS policies
-- Las policies de admin usan subconsulta a user_roles
-- que a su vez tiene RLS, causando recursion infinita.
-- Solucion: crear funcion helper SECURITY DEFINER
-- que bypass RLS, y usarla en todas las policies
-- =====================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid() AND r.internal_name = 'admin'
  )
$$;

GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- Ahora reemplazar TODAS las policies que usan subconsulta directa
-- para que usen la funcion is_admin() en lugar

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles" ON public.profiles
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update any profile" ON public.profiles;
CREATE POLICY "Admins can update any profile" ON public.profiles
FOR UPDATE TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all user_roles" ON public.user_roles;
CREATE POLICY "Admins can view all user_roles" ON public.user_roles
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all orders" ON public.store_orders;
CREATE POLICY "Admins can view all orders" ON public.store_orders
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update orders" ON public.store_orders;
CREATE POLICY "Admins can update orders" ON public.store_orders
FOR UPDATE TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all products" ON public.store_products;
CREATE POLICY "Admins can view all products" ON public.store_products
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage products" ON public.store_products;
CREATE POLICY "Admins can manage products" ON public.store_products
FOR ALL TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all content" ON public.exclusive_content;
CREATE POLICY "Admins can view all content" ON public.exclusive_content
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage content" ON public.exclusive_content;
CREATE POLICY "Admins can manage content" ON public.exclusive_content
FOR UPDATE TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
CREATE POLICY "Admins can view all events" ON public.events
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can manage events" ON public.events;
CREATE POLICY "Admins can manage events" ON public.events
FOR ALL TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all tokens" ON public.user_tokens;
CREATE POLICY "Admins can view all tokens" ON public.user_tokens
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all user_tags" ON public.user_has_tags;
CREATE POLICY "Admins can view all user_tags" ON public.user_has_tags
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all order items" ON public.store_order_items;
CREATE POLICY "Admins can view all order items" ON public.store_order_items
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view all variants" ON public.product_variants;
CREATE POLICY "Admins can view all variants" ON public.product_variants
FOR SELECT TO authenticated
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can view role_permissions" ON public.role_permissions;
CREATE POLICY "Admins can view role_permissions" ON public.role_permissions
FOR SELECT TO authenticated
USING (public.is_admin());
