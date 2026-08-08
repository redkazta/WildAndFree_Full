const URL_RE = /(https?:\/\/[^\s]+)/i;
const GIPHY_RE =
  /(?:giphy\.com\/gifs\/[^\s]+|media\.giphy\.com\/media\/([\w-]+)\/[^\s]+)/i;
const YOUTUBE_RE =
  /(?:youtube\.com\/watch\?(?:[^&]*&)*v=([\w-]{11})|youtu\.be\/([\w-]{11})|youtube\.com\/shorts\/([\w-]{11})|youtube\.com\/embed\/([\w-]{11}))/i;
const IMAGE_EXT_RE = /\.(jpe?g|png|gif|webp|avif)([?#].*)?$/i;

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function extractGiphyId(url: string): string {
  const mediaMatch = url.match(/media\.giphy\.com\/media\/([\w-]+)\//i);
  if (mediaMatch) return mediaMatch[1];
  const slug = url.split('/').filter(Boolean).pop() || '';
  const parts = slug.split('-');
  return parts[parts.length - 1] || '';
}

function renderToken(token: string): string {
  const m = token.match(URL_RE);
  const rawUrl = m ? m[1].replace(/[),.]+(?=\s|$)/g, '') : token;
  if (!rawUrl.startsWith('http')) return escapeHtml(token);

  if (GIPHY_RE.test(rawUrl)) {
    const id = extractGiphyId(rawUrl);
    // Tries media.giphy.com first; if broken, resolves the real URL via oEmbed
    return `<a href="${escapeHtml(rawUrl)}" target="_blank" rel="noopener nofollow" class="content-embed content-embed--giphy"><img src="https://media.giphy.com/media/${escapeHtml(id)}/giphy.gif" alt="Giphy" data-giphy-orig="${escapeHtml(rawUrl)}" onerror="window.__WG_resolveGiphy&&window.__WG_resolveGiphy(this)" loading="lazy" class="content-embed-img giphy-img" /></a>`;
  }

  const yt = rawUrl.match(YOUTUBE_RE);
  if (yt) {
    const id = yt[1] || yt[2] || yt[3] || yt[4];
    return `<div class="content-embed content-embed--video"><iframe src="https://www.youtube.com/embed/${id}" frameborder="0" allowfullscreen loading="lazy"></iframe></div>`;
  }

  if (IMAGE_EXT_RE.test(rawUrl)) {
    return `<a href="${escapeHtml(rawUrl)}" target="_blank" rel="noopener nofollow"><img src="${escapeHtml(rawUrl)}" alt="" class="content-embed-img" /></a>`;
  }

  const host = new URL(rawUrl).hostname.replace(/^www\./, '');
  return `<a href="${escapeHtml(rawUrl)}" target="_blank" rel="noopener nofollow" class="content-link">${escapeHtml(host)}</a>`;
}

export function renderRichContent(text: string): string {
  return text
    .split(/(\s+)/)
    .map((chunk) => (chunk.trim() ? renderToken(chunk) : chunk))
    .join('');
}

const giphyCache = new Map<string, string>();

/**
 * Fallback para GIFs de Giphy: si el dominio genérico (media.giphy.com)
 * no responde, resuelve la URL real vía oEmbed y actualiza el <img>.
 * Se registra en window para poder invocarlo desde el atributo onerror.
 */
export function initGiphyFallback(): void {
  (window as any).__WG_resolveGiphy = async function (el: HTMLImageElement) {
    const orig = el.getAttribute('data-giphy-orig');
    if (!orig) return;
    if (giphyCache.has(orig)) {
      el.src = giphyCache.get(orig)!;
      return;
    }
    try {
      const res = await fetch(`https://giphy.com/services/oembed?url=${encodeURIComponent(orig)}`);
      const data = await res.json();
      const real = data?.url;
      if (real && typeof real === 'string') {
        giphyCache.set(orig, real);
        el.src = real;
      }
    } catch {
      // fallo silencioso, deja el sobre del link visible
    }
  };
}
