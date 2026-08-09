// Identificador corto y estable para la URL pública de una publicación.
// El post se identifica por su UUID completo internamente, pero en la URL
// mostramos solo el prefijo corto (primeros 8 chars sin guiones): /the-wild-times/d8f3fde8
export function postShortId(pid: string | undefined | null): string {
  const clean = (pid || '').replace(/-/g, '').toLowerCase();
  return clean.slice(0, 8) || 'post';
}

// Slug legible a partir del título (para mantener compatibles las URLs viejas
// tipo /the-wild-times/bienvenidos-al-feed que aún puedan estar compartidas).
export function postSlug(pid: string, title?: string | null): string {
  if (title) {
    const base = String(title)
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9\s-]/g, '')
      .trim()
      .replace(/[\s_]+/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-+|-+$/g, '');
    if (base) return base;
  }
  return postShortId(pid);
}

// Base de ruta por tipo de post para la URL pública separada por tipo.
export function postTypePath(postType?: string | null): string {
  switch (postType) {
    case 'announcement': return '/anuncios';
    case 'event': return '/eventos';
    case 'promotion': return '/promos';
    case 'general':
    default: return '/noticias';
  }
}
