-- =====================================================
-- TIENDA: esquema base + colecciones, tags y SEO
-- Autocontenida: se puede correr en una base nueva.
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Roles mínimos para las políticas de la tienda
CREATE TABLE IF NOT EXISTS public.roles (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  internal_name TEXT,
  display_name TEXT,
  description TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS internal_name TEXT;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS display_name TEXT;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.roles ADD COLUMN IF NOT EXISTS is_system BOOLEAN DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS public.user_roles (
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  assigned_by UUID REFERENCES public.profiles(id),
  PRIMARY KEY (user_id, role_id)
);

ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS assigned_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS assigned_by UUID REFERENCES public.profiles(id);

-- Helper de permisos (idempotente)
CREATE OR REPLACE FUNCTION public.is_staff_or_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.user_roles ur
    JOIN public.roles r ON r.id = ur.role_id
    WHERE ur.user_id = auth.uid()
      AND r.name IN ('admin', 'staff')
  );
$$;

-- =====================================================
-- Tablas base
-- =====================================================
CREATE TABLE IF NOT EXISTS public.store_products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  base_price NUMERIC(10,2) NOT NULL,
  image_url TEXT,
  category TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.product_variants (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID REFERENCES public.store_products(id) ON DELETE CASCADE,
  size TEXT,
  color TEXT,
  stock INTEGER DEFAULT 0,
  sku TEXT,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.store_orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled')),
  shipping_type TEXT CHECK (shipping_type IN ('pickup', 'local_delivery', 'carrier')),
  tracking_guide TEXT,
  shipping_address TEXT,
  delivery_schedule TIMESTAMPTZ,
  payment_method TEXT CHECK (payment_method IN ('transfer', 'cash', 'card', 'terminal')),
  total NUMERIC(10,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.store_order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES public.store_orders(id) ON DELETE CASCADE,
  variant_id UUID REFERENCES public.product_variants(id),
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- Columnas nuevas para la colección Wild Gang
-- =====================================================
ALTER TABLE public.store_products ADD COLUMN IF NOT EXISTS slug TEXT;
ALTER TABLE public.store_products ADD COLUMN IF NOT EXISTS collection TEXT;
ALTER TABLE public.store_products ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
ALTER TABLE public.store_products ADD COLUMN IF NOT EXISTS alt_text TEXT;
ALTER TABLE public.store_products ADD COLUMN IF NOT EXISTS seo_title TEXT;
ALTER TABLE public.store_products ADD COLUMN IF NOT EXISTS seo_description TEXT;
ALTER TABLE public.store_products ADD COLUMN IF NOT EXISTS gallery JSONB DEFAULT '[]'::jsonb;

CREATE UNIQUE INDEX IF NOT EXISTS store_products_slug_key ON public.store_products(slug);
CREATE UNIQUE INDEX IF NOT EXISTS product_variants_sku_key ON public.product_variants(sku);

-- =====================================================
-- RLS
-- =====================================================
ALTER TABLE public.store_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can read active products" ON public.store_products;
CREATE POLICY "Public can read active products" ON public.store_products
  FOR SELECT USING (is_active = TRUE);

DROP POLICY IF EXISTS "Staff can manage products" ON public.store_products;
CREATE POLICY "Staff can manage products" ON public.store_products
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Public can read variants" ON public.product_variants;
CREATE POLICY "Public can read variants" ON public.product_variants
  FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "Staff can manage variants" ON public.product_variants;
CREATE POLICY "Staff can manage variants" ON public.product_variants
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users can read own orders" ON public.store_orders;
CREATE POLICY "Users can read own orders" ON public.store_orders
  FOR SELECT USING (auth.uid() = user_id OR public.is_staff_or_admin());

DROP POLICY IF EXISTS "Staff can manage orders" ON public.store_orders;
CREATE POLICY "Staff can manage orders" ON public.store_orders
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

DROP POLICY IF EXISTS "Users can read own order items" ON public.store_order_items;
CREATE POLICY "Users can read own order items" ON public.store_order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.store_orders o
      WHERE o.id = store_order_items.order_id
        AND (o.user_id = auth.uid() OR public.is_staff_or_admin())
    )
  );

DROP POLICY IF EXISTS "Staff can manage order items" ON public.store_order_items;
CREATE POLICY "Staff can manage order items" ON public.store_order_items
  FOR ALL USING (public.is_staff_or_admin()) WITH CHECK (public.is_staff_or_admin());

GRANT EXECUTE ON FUNCTION public.is_staff_or_admin() TO authenticated;
