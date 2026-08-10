import { createClient } from '@supabase/supabase-js';

// Cliente readonly para resolver en el servidor (build/SSR) el id completo de un post
// a partir del id corto de la URL. Se usa en las páginas de detalle on-demand.
function serverClient() {
  return createClient(
    import.meta.env.PUBLIC_SUPABASE_URL as string,
    import.meta.env.PUBLIC_SUPABASE_ANON_KEY as string
  );
}

// Devuelve el UUID completo del post cuyo id empieza por `shortId`, de un tipo dado.
// Si no existe (o no está publicado) devuelve null.
export async function resolvePostIdByShortId(
  shortId: string,
  postType: string
): Promise<string | null> {
  if (!shortId) return null;
  const supabase = serverClient();
  const { data } = await supabase
    .from('crew_posts')
    .select('id')
    .eq('post_type', postType)
    .eq('status', 'published')
    .like('id::text', `${shortId}%`)
    .limit(1)
    .maybeSingle();
  return data?.id || null;
}
