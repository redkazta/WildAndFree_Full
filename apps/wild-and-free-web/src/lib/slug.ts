// Genera un slug legible y sencillo a partir del título de una publicación.
// Si no hay título, usa un id corto como identificación estable.
export function postSlug(pid: string, title?: string | null): string {
  if (title) {
    const base = String(title)
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // quita acentos
      .replace(/[^a-z0-9\s-]/g, '')     // solo letras, números, espacios y guiones
      .trim()
      .replace(/[\s_]+/g, '-')          // espacios -> guiones
      .replace(/-+/g, '-')
      .replace(/^-+|-+$/g, '');
    if (base) return base;
  }
  // Fallback estable: primeros 8 chars del UUID
  return (pid || '').replace(/-/g, '').slice(0, 8) || pid || 'post';
}
