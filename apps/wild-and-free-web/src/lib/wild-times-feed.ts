import { supabase } from './supabase';
import { renderRichContent, initGiphyFallback } from './linkify';
import { getRole } from './role';

const typeLabels: Record<string, { label: string; color: string }> = {
  announcement: { label: '📢 Anuncio', color: 'var(--primary)' },
  event: { label: '🎤 Evento', color: '#00bfff' },
  promotion: { label: '🏷️ Promo', color: '#ff6b6b' },
  general: { label: '📝 Noticia', color: '#888' },
};

function getTimeAgo(date: Date): string {
  const seconds = Math.floor((Date.now() - date.getTime()) / 1000);
  if (seconds < 60) return 'Ahora';
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `Hace ${minutes}m`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `Hace ${hours}h`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `Hace ${days}d`;
  return date.toLocaleDateString('es-MX');
}

function authorLink(author: any, name: string): string {
  const slug = author.username || '';
  if (slug) {
    return `<a href="/artista/${slug}" class="author-name-link">${name}</a>`;
  }
  return `<span class="author-name-link">${name}</span>`;
}

// ─── SIDEBAR: ANNOUNCEMENTS ───
export async function loadNewsSidebar(): Promise<void> {
  const el = document.getElementById('news-list');
  const countEl = document.getElementById('news-count');
  if (!el) return;

  try {
    const { data: posts, error } = await supabase
      .from('crew_posts')
      .select('*, author:author_id(nombre, username, avatar_url)')
      .eq('status', 'published')
      .eq('post_type', 'announcement')
      .order('published_at', { ascending: false })
      .limit(6);

    if (error || !posts?.length) {
      el.innerHTML = '<p class="text-xs text-[var(--text-muted)] italic">Próximamente anuncios.</p>';
      return;
    }

    if (countEl) countEl.textContent = String(posts.length);

    el.innerHTML = posts.map((p: any) => {
      const author = (p as any).author || {};
      const initials = (author.nombre || author.username || 'WG').substring(0, 2).toUpperCase();
      return `<article class="news-item group flex gap-3 p-3 rounded-xl border border-[var(--border-faint)] hover:border-[var(--primary)] hover:bg-[var(--bg-card)] transition-all cursor-pointer" data-news-id="${p.id}">
        <div class="news-item-avatar">${initials}</div>
        <div class="flex-1 min-w-0">
          <h4 class="text-xs font-black uppercase leading-tight group-hover:text-[var(--primary)] transition-colors">${p.title || ''}</h4>
          <div class="flex items-center gap-2 mt-1 text-[8px] text-[var(--text-faint)]">
            <a href="/artista/${author.username || ''}" class="author-name-link">${author.nombre || author.username || 'Crew'}</a>
            <span>·</span>
            <time>${new Date(p.published_at).toLocaleDateString('es-MX', { day: 'numeric', month: 'short' })}</time>
            ${p.image_url ? '<span>· 🖼️</span>' : ''}
          </div>
        </div>
      </article>`;
    }).join('');

    el.querySelectorAll('.news-item').forEach((item: any) => {
      item.addEventListener('click', () => {
        const id = item.getAttribute('data-news-id');
        const post = posts.find((p: any) => p.id === id);
        if (post) showFeaturedArticle(post);
      });
    });
  } catch (e) {
    el.innerHTML = '<p class="text-xs text-[var(--text-muted)] italic">Error.</p>';
  }
}

// ─── FEATURED ARTICLE ───
function showFeaturedArticle(post: any): void {
  const container = document.getElementById('featured-article');
  if (!container) return;

  const author = post.author || {};
  const typeInfo = typeLabels[post.post_type] || { label: '📝', color: '#888' };

  container.classList.remove('hidden');
  container.innerHTML = `
    <div class="featured-card bg-[var(--bg)] border-2 border-[var(--primary)] rounded-2xl overflow-hidden shadow-[0_0_40px_rgba(201,131,0,0.08)]">
      ${post.image_url ? `
      <div class="featured-img-wrap">
        <img src="${post.image_url}" class="featured-img" alt="${post.title || ''}" />
      </div>` : ''}
      <div class="featured-body">
        <div class="flex items-start justify-between gap-4 mb-5">
          <div class="flex items-center gap-3">
            <span class="featured-badge" style="background:${typeInfo.color}20;color:${typeInfo.color}">${typeInfo.label}</span>
            <span class="text-[10px] text-[var(--text-muted)] font-mono">${new Date(post.published_at).toLocaleDateString('es-MX', { day: 'numeric', month: 'long', year: 'numeric' })}</span>
          </div>
          <button class="featured-close" title="Cerrar">✕</button>
        </div>
        <h2 class="featured-title">${post.title || ''}</h2>
        <div class="featured-author-row">
          <div class="featured-author-avatar">${(author.nombre || author.username || 'C').substring(0, 2).toUpperCase()}</div>
          <div>
            <a href="/artista/${author.username || ''}" class="author-name-link featured-author-name">${author.nombre || author.username || 'Wild Gvng Crew'}</a>
            <div class="featured-author-role">Staff</div>
          </div>
        </div>
        <div class="featured-divider"></div>
        <div class="featured-content">${renderRichContent(post.content || '')}</div>
      </div>
    </div>`;

  const closeBtn = container.querySelector('.featured-close');
  if (closeBtn) closeBtn.addEventListener('click', closeFeaturedArticle);

  container.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

function closeFeaturedArticle(): void {
  const container = document.getElementById('featured-article');
  if (container) {
    container.classList.add('hidden');
    container.innerHTML = '';
  }
}

// ─── CREW FEED ───
let currentFilter = 'all';

export async function loadCrewFeed(filter = 'all'): Promise<void> {
  currentFilter = filter;
  const container = document.getElementById('posts-container');
  if (!container) return;

  try {
    const { data: { session } } = await supabase.auth.getSession();

    const { data: posts, error } = await supabase
      .from('crew_posts')
      .select('*, author:author_id(nombre, username, avatar_url)')
      .eq('status', 'published')
      .order('published_at', { ascending: false })
      .limit(30);

    if (error || !posts?.length) {
      container.innerHTML = '<p class="text-sm text-[var(--text-muted)] italic text-center py-12">No hay publicaciones del crew aún.</p>';
      return;
    }

    const postIds = posts.map((p: any) => p.id);
    const [likesData, commentsData, repostsData] = await Promise.all([
      supabase.from('wall_likes').select('post_id', { count: 'exact' }).in('post_id', postIds),
      supabase.from('wall_comments').select('post_id', { count: 'exact' }).in('post_id', postIds).is('deleted_at', null),
      supabase.from('wall_reposts').select('post_id', { count: 'exact' }).in('post_id', postIds),
    ]);

    let userLikes = new Set<string>();
    let userReposts = new Set<string>();
    if (session?.user?.id) {
      const { data: myLikes } = await supabase.from('wall_likes').select('post_id').in('post_id', postIds).eq('user_id', session.user.id);
      const { data: myReposts } = await supabase.from('wall_reposts').select('post_id').in('post_id', postIds).eq('user_id', session.user.id);
      if (myLikes) myLikes.forEach((l: any) => userLikes.add(l.post_id));
      if (myReposts) myReposts.forEach((r: any) => userReposts.add(r.post_id));
    }

    const likeCounts: Record<string, number> = {};
    const commentCounts: Record<string, number> = {};
    const repostCounts: Record<string, number> = {};
    (likesData.data || []).forEach((l: any) => { likeCounts[l.post_id] = (likeCounts[l.post_id] || 0) + 1; });
    (commentsData.data || []).forEach((c: any) => { commentCounts[c.post_id] = (commentCounts[c.post_id] || 0) + 1; });
    (repostsData.data || []).forEach((r: any) => { repostCounts[r.post_id] = (repostCounts[r.post_id] || 0) + 1; });

    let filtered = posts;
    if (filter !== 'all') {
      filtered = posts.filter((p: any) => p.post_type === filter);
    }

    if (filtered.length === 0) {
      container.innerHTML = `<p class="text-sm text-[var(--text-muted)] italic text-center py-12">No hay publicaciones con este filtro.</p>`;
      return;
    }

    initGiphyFallback();
    const { role } = await getRole();
    const canViewReactions = role === 'admin' || role === 'staff';

    container.innerHTML = filtered.map((p: any) => renderCrewPost(p, {
      likes: likeCounts[p.id] || 0,
      comments: commentCounts[p.id] || 0,
      reposts: repostCounts[p.id] || 0,
      isLiked: userLikes.has(p.id),
      isReposted: userReposts.has(p.id),
      canViewReactions,
    })).join('');

    attachHandlers(posts as any[]);
  } catch (e) {
    console.error('Feed error:', e);
    container.innerHTML = '<p class="text-sm text-[var(--text-muted)] italic text-center py-12">Error al cargar feed.</p>';
  }
}

function renderCrewPost(p: any, meta: { likes: number; comments: number; reposts: number; isLiked: boolean; isReposted: boolean; canViewReactions: boolean }): string {
  const author = p.author || {};
  const avatar = author.avatar_url || '';
  const name = author.nombre || author.username || 'Crew';
  const initials = name.substring(0, 2).toUpperCase();
  const timeAgo = getTimeAgo(new Date(p.published_at));
  const typeInfo = typeLabels[p.post_type] || { label: '📝', color: '#888' };

  let imageHtml = '';
  if (p.image_url) {
    imageHtml = `<div class="feed-img-wrap"><img src="${p.image_url}" class="feed-img" loading="lazy" /></div>`;
  }

  return `<article class="feed-card" data-post-id="${p.id}">
    <div class="feed-card-header">
      <div class="feed-card-author">
        <div class="feed-card-avatar" style="${avatar ? `background-image:url('${avatar}')` : ''}">${avatar ? '' : initials}</div>
        <div>
          <a href="/artista/${author.username || ''}" class="author-name-link feed-card-name">${name}</a>
          <div class="feed-card-meta">
            <span class="feed-card-type" style="background:${typeInfo.color}15;color:${typeInfo.color}">${typeInfo.label}</span>
            <span>${timeAgo}</span>
          </div>
        </div>
      </div>
      ${p.title ? `<h3 class="feed-card-title">${p.title}</h3>` : ''}
    </div>
    <div class="feed-card-body">
      <p class="feed-card-text">${renderRichContent(p.content || '')}</p>
      ${imageHtml}
    </div>
    <div class="feed-card-actions">
      <button class="action-btn ${meta.isLiked ? 'action-btn--active' : ''}" data-action="like">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="${meta.isLiked ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2.5"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
        <span>${meta.likes}</span>
      </button>
      <button class="action-btn" data-action="comment">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        <span>${meta.comments}</span>
      </button>
      <button class="action-btn ${meta.isReposted ? 'action-btn--active' : ''}" data-action="repost">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="${meta.isReposted ? 'currentColor' : 'none'}" stroke="currentColor" stroke-width="2.5"><path d="M17 1l4 4-4 4"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><path d="M7 23l-4-4 4-4"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>
        <span>${meta.reposts}</span>
      </button>
      ${meta.canViewReactions ? `<button class="action-btn" data-action="opinions" title="Ver quién reaccionó">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
        <span>${meta.likes + meta.comments + meta.reposts}</span>
      </button>` : ''}
      <button class="action-btn ml-auto" data-action="share">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" y1="13.51" x2="15.42" y2="17.49"/><line x1="15.41" y1="6.51" x2="8.59" y2="10.49"/></svg>
      </button>
    </div>
    <div class="comments-section hidden" data-post-id="${p.id}">
      <div class="comments-list"></div>
      <div class="comment-form-row">
        <input type="text" class="comment-input" placeholder="Escribe un comentario..." />
        <button class="comment-send">Enviar</button>
      </div>
    </div>
  </article>`;
}

let allPostsCache: any[] = [];

function attachHandlers(posts: any[]): void {
  allPostsCache = posts;
  document.querySelectorAll('.action-btn').forEach(btn => {
    btn.removeEventListener('click', handleAction);
    btn.addEventListener('click', handleAction);
  });
  document.querySelectorAll('.comment-send').forEach(btn => {
    btn.removeEventListener('click', handleCommentSend);
    btn.addEventListener('click', handleCommentSend);
  });
}

async function handleAction(e: Event): Promise<void> {
  const btn = e.currentTarget as HTMLElement;
  const postEl = btn.closest('.feed-card') as HTMLElement;
  const postId = postEl?.dataset.postId;
  const action = btn.dataset.action;
  if (!postId || !action) return;

  const { data: { session } } = await supabase.auth.getSession();
  if (!session?.user) { alert('Inicia sesión para interactuar'); return; }

  if (action === 'like') {
    const { data: liked } = await supabase.rpc('toggle_like', { p_post_id: postId, p_user_id: session.user.id });
    const countEl = btn.querySelector('span');
    const c = parseInt(countEl?.textContent || '0');
    btn.classList.toggle('action-btn--active', !!liked);
    btn.querySelector('svg')?.setAttribute('fill', liked ? 'currentColor' : 'none');
    if (countEl) countEl.textContent = String(liked ? c + 1 : Math.max(0, c - 1));
  } else if (action === 'repost') {
    const { data: reposted } = await supabase.rpc('toggle_repost', { p_post_id: postId, p_user_id: session.user.id });
    const countEl = btn.querySelector('span');
    const c = parseInt(countEl?.textContent || '0');
    btn.classList.toggle('action-btn--active', !!reposted);
    btn.querySelector('svg')?.setAttribute('fill', reposted ? 'currentColor' : 'none');
    if (countEl) countEl.textContent = String(reposted ? c + 1 : Math.max(0, c - 1));
  } else if (action === 'comment') {
    const section = postEl.querySelector('.comments-section');
    if (section) {
      (section as HTMLElement).classList.toggle('hidden');
      if (!(section as HTMLElement).classList.contains('hidden')) loadPostComments(postId, section as HTMLElement);
    }
  } else if (action === 'opinions') {
    const postTitle = postEl.querySelector('.feed-card-title')?.textContent || 'Publicación';
    await openReactionsDialog(postId, postTitle);
  } else if (action === 'share') {
    await navigator.clipboard.writeText(window.location.href);
    btn.style.color = 'var(--primary)';
    setTimeout(() => btn.style.color = '', 1200);
  }
}

async function loadPostComments(postId: string, section: HTMLElement): Promise<void> {
  const list = section.querySelector('.comments-list');
  if (!list) return;
  try {
    const { data: comments } = await supabase.rpc('get_post_comments', { p_post_id: postId });
    if (!comments?.length) {
      list.innerHTML = '<p class="text-[10px] text-[var(--text-muted)] italic">Sin comentarios aún.</p>';
      return;
    }
    list.innerHTML = comments.map((c: any) => {
      const avatar = c.avatar_url || '';
      const name = c.nombre || c.username || 'Anónimo';
      const initials = name.substring(0, 2).toUpperCase();
      return `<div class="comment-item">
        <div class="comment-avatar" style="${avatar ? `background-image:url('${avatar}')` : ''}">${avatar ? '' : initials}</div>
        <div>
          <div class="comment-author">${name} <span class="comment-time">${getTimeAgo(new Date(c.created_at))}</span></div>
          <div class="comment-text">${c.content}</div>
        </div>
      </div>`;
    }).join('');
  } catch (e) {
    list.innerHTML = '<p class="text-[10px] text-[var(--text-muted)] italic">Error.</p>';
  }
}

async function handleCommentSend(e: Event): Promise<void> {
  const btn = e.currentTarget as HTMLElement;
  const section = btn.closest('.comments-section') as HTMLElement;
  const input = section?.querySelector('.comment-input') as HTMLInputElement;
  const postId = section?.dataset.postId;
  if (!input || !postId || !input.value.trim()) return;

  const { data: { session } } = await supabase.auth.getSession();
  if (!session?.user) { alert('Inicia sesión'); return; }

  await supabase.from('wall_comments').insert({
    post_id: postId, user_id: session.user.id, content: input.value.trim()
  });
  input.value = '';
  loadPostComments(postId, section);
  const commentBtn = section.closest('.feed-card')?.querySelector('[data-action="comment"] span');
  if (commentBtn) commentBtn.textContent = String(parseInt(commentBtn.textContent || '0') + 1);
}

// ─── FILTERS ───
export function initFilters(): void {
  document.getElementById('feed-filters')?.addEventListener('click', (e) => {
    const btn = (e.target as HTMLElement).closest('.filter-btn') as HTMLElement;
    if (!btn) return;
    document.querySelectorAll('.filter-btn').forEach(b => {
      b.classList.remove('active', 'bg-[var(--primary)]', 'text-[var(--bg)]');
      b.classList.add('text-[var(--text-secondary)]', 'border-[var(--border)]');
    });
    btn.classList.add('active', 'bg-[var(--primary)]', 'text-[var(--bg)]');
    btn.classList.remove('text-[var(--text-secondary)]', 'border-[var(--border)]');
    loadCrewFeed(btn.getAttribute('data-filter') || 'all');
  });
}

// ─── REALTIME: actualiza el feed sin recargar ───
let realtimeInit = false;

export function initRealtime(): void {
  if (realtimeInit) return;
  realtimeInit = true;

  try {
    const channel = supabase
      .channel('crew-posts-feed')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'crew_posts' }, () => refreshFeed())
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'crew_posts' }, () => refreshFeed())
      .on('postgres_changes', { event: 'DELETE', schema: 'public', table: 'crew_posts' }, () => refreshFeed())
      .subscribe();

    // Guardar el canal para poder limpiarlo si hace falta
    (window as any).__crewFeedChannel = channel;
  } catch (e) {
    console.warn('Realtime no disponible:', e);
  }
}

// Debounce para no spamear requests si llegan varios cambios seguidos
let refreshTimer: ReturnType<typeof setTimeout> | null = null;
function refreshFeed(): void {
  if (refreshTimer) clearTimeout(refreshTimer);
  refreshTimer = setTimeout(() => {
    loadCrewFeed(currentFilter);
    loadNewsSidebar();
  }, 400);
}

// ─── DIALOG DE REACCIONES (ojito, admin/staff) ───
let reactionDialog: HTMLDialogElement | null = null;

function ensureReactionDialog(): HTMLDialogElement {
  if (reactionDialog && document.body.contains(reactionDialog)) return reactionDialog;
  reactionDialog = document.createElement('dialog');
  reactionDialog.className = 'reactions-dialog';
  reactionDialog.innerHTML = `
    <div class="reactions-dialog-inner">
      <div class="reactions-dialog-head">
        <h3 class="reactions-dialog-title">Reacciones</h3>
        <button class="reactions-dialog-close" data-close title="Cerrar">✕</button>
      </div>
      <div class="reactions-tabs" role="tablist">
        <button class="reactions-tab active" data-reaction-tab="likes">❤️ Likes</button>
        <button class="reactions-tab" data-reaction-tab="comments">💬 Comentarios</button>
        <button class="reactions-tab" data-reaction-tab="reposts">🔁 Reposts</button>
      </div>
      <div class="reactions-body">
        <p class="reactions-loading">Cargando...</p>
      </div>
    </div>
  `;
  document.body.appendChild(reactionDialog);
  reactionDialog.querySelector('.reactions-dialog-close')?.addEventListener('click', () => reactionDialog!.close());
  reactionDialog.addEventListener('click', (ev) => {
    const target = ev.target as HTMLElement;
    if (target === reactionDialog) reactionDialog!.close();
  });
  reactionDialog.querySelectorAll('.reactions-tab').forEach((tab) => {
    tab.addEventListener('click', () => {
      reactionDialog!.querySelectorAll('.reactions-tab').forEach((t) => t.classList.remove('active'));
      tab.classList.add('active');
      const type = (tab as HTMLElement).dataset.reactionTab;
      if (type) loadReactionTab(type as 'likes' | 'comments' | 'reposts');
    });
  });
  return reactionDialog;
}

let currentReactionPostId = '';

async function openReactionsDialog(postId: string, title: string): Promise<void> {
  const dialog = ensureReactionDialog();
  dialog.querySelector('.reactions-dialog-title')!.textContent = `Reacciones · ${title}`;
  (dialog.querySelector('.reactions-tab.active') as HTMLElement).classList.remove('active');
  (dialog.querySelector('[data-reaction-tab="likes"]') as HTMLElement).classList.add('active');
  currentReactionPostId = postId;
  await loadReactionTab('likes');
  if (!dialog.open) dialog.showModal();
}

function userRowHtml(u: any, extra: string): string {
  const avatar = u.avatar_url || '';
  const name = u.nombre || u.username || 'Anónimo';
  const initials = name.substring(0, 2).toUpperCase();
  return `<div class="reaction-user">
    <div class="reaction-user-avatar" style="${avatar ? `background-image:url('${avatar}')` : ''}">${avatar ? '' : initials}</div>
    <div class="reaction-user-info">
      <a href="/artista/${u.username || ''}" class="reaction-user-name">${name}</a>
      <span class="reaction-user-meta">${extra}</span>
    </div>
  </div>`;
}

async function loadReactionTab(type: 'likes' | 'comments' | 'reposts'): Promise<void> {
  const dialog = ensureReactionDialog();
  const body = dialog.querySelector('.reactions-body') as HTMLElement;
  if (!body) return;
  body.innerHTML = '<p class="reactions-loading">Cargando...</p>';

  try {
    if (type === 'comments') {
      const { data } = await supabase.rpc('get_post_comments', { p_post_id: currentReactionPostId });
      body.innerHTML = (data && data.length)
        ? (data as any[]).map((c) => userRowHtml(c, `comentó · ${getTimeAgo(new Date(c.created_at))}`) + `<div class="reaction-comment">${c.content}</div>`).join('')
        : '<p class="reactions-empty">Sin comentarios.</p>';
    } else {
      const fn = type === 'likes' ? 'get_post_likes' : 'get_post_reposts';
      const verb = type === 'likes' ? 'reaccionó' : 'recompartió';
      const { data } = await supabase.rpc(fn, { p_post_id: currentReactionPostId });
      body.innerHTML = (data && data.length)
        ? (data as any[]).map((u) => userRowHtml(u, `${verb} · ${getTimeAgo(new Date(u.created_at))}`)).join('')
        : `<p class="reactions-empty">Sin ${type === 'likes' ? 'reacciones' : 'reposts'}.</p>`;
    }
  } catch (e) {
    body.innerHTML = '<p class="reactions-empty">Error al cargar.</p>';
  }
}
