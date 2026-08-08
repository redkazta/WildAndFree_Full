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
    return `<a href="${escapeHtml(rawUrl)}" target="_blank" rel="noopener nofollow" class="content-embed content-embed--giphy"><img src="https://media.giphy.com/media/${id}/giphy.gif" alt="Giphy" class="content-embed-img" /></a>`;
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
