-- =====================================================
-- Tienda: soporte para colecciones, tags y SEO
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
