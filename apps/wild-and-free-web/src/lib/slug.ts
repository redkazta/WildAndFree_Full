// Identificador corto y estable para la URL pública de una publicación.
// El post se identifica por su UUID completo internamente, pero en la URL
// mostramos solo el prefijo corto (primeros 8 chars sin guiones) para que
// sea legible y corto: /the-wild-times/d8f3fde8
export function postShortId(pid: string | undefined | null): string {
  const clean = (pid || '').replace(/-/g, '').toLowerCase();
  return (clean.slice(0, 8) || 'post');
}
