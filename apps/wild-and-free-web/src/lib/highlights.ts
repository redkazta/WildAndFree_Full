// Historias destacadas (tipo Instagram) para /perfil y /artista/[username].
// Uso: await initHighlights('highlights-row', userId)

import { supabase } from './supabase';
import { showToast } from './toast';

type Story = {
  id: string;
  user_id: string;
  media_url: string;
  caption?: string | null;
  created_at: string;
};

type Highlight = {
  id: string;
  user_id: string;
  title: string;
  cover_url: string | null;
};

const STYLE_ID = 'wg-hl-style';

let container: HTMLElement | null = null;
let targetUserId = '';
let isOwner = false;
let pendingTitle = '';
let modalRefs: Record<string, HTMLElement> | null = null;
let viewerUrls: string[] = [];
let viewerIndex = 0;

function esc(value: string): string {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function ensureStyles(): void {
  if (document.getElementById(STYLE_ID)) return;
  const style = document.createElement('style');
  style.id = STYLE_ID;
  style.textContent = `
.wg-highlights { margin: 18px 0 6px; }
.wg-hl-row {
  display: flex; gap: 18px; padding: 4px 2px 10px;
  overflow-x: auto; scrollbar-width: none; justify-content: safe center;
}
.wg-hl-row::-webkit-scrollbar { display: none; }
.wg-hl-item {
  flex: 0 0 auto; width: 84px; display: flex; flex-direction: column;
  align-items: center; gap: 8px; padding: 0; border: none; background: none;
  color: inherit; font: inherit; cursor: pointer;
}
.wg-hl-ring {
  width: 76px; height: 76px; border-radius: 50%; padding: 3px;
  background: linear-gradient(135deg, var(--primary, #C98300), var(--secondary, #8A0303));
  display: flex; align-items: center; justify-content: center;
}
.wg-hl-ring img {
  width: 100%; height: 100%; border-radius: 50%; object-fit: cover;
  border: 3px solid var(--bg, #000); display: block;
}
.wg-hl-placeholder {
  width: 100%; height: 100%; border-radius: 50%; border: 3px solid var(--bg, #000);
  background: var(--bg-card, #111); display: flex; align-items: center; justify-content: center;
  font-size: 20px; color: var(--text-muted, #888);
}
.wg-hl-new .wg-hl-ring {
  background: transparent; border: 2px dashed var(--border-muted, rgba(255,255,255,.25));
  font-size: 32px; font-weight: 300; color: var(--text-muted, #888);
}
.wg-hl-label {
  max-width: 84px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: .06em;
  color: var(--text-muted, #888);
}
.wg-hl-modal[hidden], .wg-hl-viewer[hidden] { display: none; }
.wg-hl-modal { position: fixed; inset: 0; z-index: 9998; display: flex; align-items: center; justify-content: center; padding: 16px; }
.wg-hl-backdrop { position: absolute; inset: 0; background: rgba(0,0,0,.78); backdrop-filter: blur(6px); }
.wg-hl-dialog {
  position: relative; width: min(460px, 100%); border-radius: 18px; overflow: hidden;
  background: var(--surface-solid-elev, #111); border: 1px solid var(--border-muted, rgba(255,255,255,.15));
  box-shadow: 0 30px 90px rgba(0,0,0,.6);
}
.wg-hl-head { position: relative; display: flex; align-items: center; justify-content: center; padding: 16px; border-bottom: 1px solid var(--border-faint, rgba(255,255,255,.06)); }
.wg-hl-head h3 { margin: 0; font-size: 15px; font-weight: 900; }
.wg-hl-x { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); padding: 6px 10px; border: none; background: none; color: var(--text, #fff); font-size: 20px; cursor: pointer; }
.wg-hl-body { padding: 18px; }
.wg-hl-input { width: 100%; padding: 12px 14px; border-radius: 10px; border: 1px solid var(--border-muted, rgba(255,255,255,.15)); background: var(--bg-card, #111); color: var(--text, #fff); font: inherit; font-size: 14px; outline: none; }
.wg-hl-input:focus { border-color: var(--primary, #C98300); }
.wg-hl-primary { width: 100%; margin-top: 14px; padding: 12px; border: none; border-radius: 10px; background: var(--primary, #C98300); color: #000; font-weight: 900; font-size: 13px; letter-spacing: .08em; text-transform: uppercase; cursor: pointer; }
.wg-hl-primary:disabled { opacity: .4; cursor: not-allowed; }
.wg-hl-secondary { padding: 7px 10px; border-radius: 8px; border: 1px solid var(--primary, #C98300); background: transparent; color: var(--primary, #C98300); font-weight: 900; font-size: 10px; letter-spacing: .06em; text-transform: uppercase; cursor: pointer; }
.wg-hl-picker-head { display: flex; align-items: center; justify-content: space-between; gap: 10px; margin-bottom: 12px; font-size: 11px; font-weight: 800; letter-spacing: .08em; text-transform: uppercase; color: var(--text-muted, #888); }
.wg-hl-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; max-height: 320px; overflow-y: auto; }
.wg-hl-thumb { position: relative; aspect-ratio: 1; padding: 0; border-radius: 10px; overflow: hidden; border: 1px solid var(--border-faint, rgba(255,255,255,.06)); background: var(--bg-card, #111); cursor: pointer; }
.wg-hl-thumb img { width: 100%; height: 100%; object-fit: cover; display: block; }
.wg-hl-thumb:hover { border-color: var(--primary, #C98300); }
.wg-hl-empty { grid-column: 1 / -1; padding: 22px 10px; text-align: center; font-size: 12px; font-style: italic; color: var(--text-muted, #888); }
.wg-hl-viewer { position: fixed; inset: 0; z-index: 9999; display: flex; align-items: center; justify-content: center; background: rgba(0,0,0,.93); }
.wg-hl-viewer img { max-width: min(520px, 92vw); max-height: 86vh; border-radius: 12px; object-fit: contain; cursor: pointer; }
.wg-hl-viewer-x { position: absolute; top: 16px; right: 16px; border: none; background: none; color: #fff; font-size: 28px; cursor: pointer; }
@media (max-width: 600px) {
  .wg-highlights { margin: 14px 0 4px; }
  .wg-hl-row { gap: 14px; }
  .wg-hl-item { width: 72px; }
  .wg-hl-ring { width: 64px; height: 64px; }
  .wg-hl-label { max-width: 72px; font-size: 9px; }
  .wg-hl-body { padding: 14px; }
  .wg-hl-head h3 { font-size: 13px; }
}
`;
  document.head.appendChild(style);
}

function ensureModal(): Record<string, HTMLElement> {
  if (modalRefs && document.body.contains(modalRefs.modal)) return modalRefs;
  modalRefs = null;

  const modal = document.createElement('div');
  modal.className = 'wg-hl-modal';
  modal.hidden = true;
  modal.innerHTML = `
    <div class="wg-hl-backdrop" data-hl-close></div>
    <div class="wg-hl-dialog" role="dialog" aria-modal="true" aria-labelledby="wg-hl-title">
      <div class="wg-hl-head">
        <button type="button" class="wg-hl-x" data-hl-close aria-label="Cerrar">✕</button>
        <h3 id="wg-hl-title">Nueva historia destacada</h3>
      </div>
      <div class="wg-hl-body">
        <div data-step="name">
          <input id="wg-hl-name" class="wg-hl-input" maxlength="30" placeholder="Nombre de la historia destacada" />
          <button id="wg-hl-next" class="wg-hl-primary" type="button" disabled>Siguiente</button>
        </div>
        <div data-step="picker" hidden>
          <div class="wg-hl-picker-head">
            <span>Elige una historia</span>
            <button id="wg-hl-upload" class="wg-hl-secondary" type="button">Subir nueva</button>
            <input id="wg-hl-file" type="file" accept="image/*" hidden />
          </div>
          <div id="wg-hl-grid" class="wg-hl-grid"></div>
        </div>
      </div>
    </div>`;
  document.body.appendChild(modal);

  const viewer = document.createElement('div');
  viewer.className = 'wg-hl-viewer';
  viewer.hidden = true;
  viewer.innerHTML = `
    <button type="button" class="wg-hl-viewer-x" data-hl-viewer-close aria-label="Cerrar">✕</button>
    <img alt="Historia" data-hl-viewer-img />`;
  document.body.appendChild(viewer);

  const refs: Record<string, HTMLElement> = {
    modal,
    viewer,
    nameInput: modal.querySelector('#wg-hl-name') as HTMLElement,
    nextBtn: modal.querySelector('#wg-hl-next') as HTMLElement,
    stepName: modal.querySelector('[data-step="name"]') as HTMLElement,
    stepPicker: modal.querySelector('[data-step="picker"]') as HTMLElement,
    grid: modal.querySelector('#wg-hl-grid') as HTMLElement,
    uploadBtn: modal.querySelector('#wg-hl-upload') as HTMLElement,
    fileInput: modal.querySelector('#wg-hl-file') as HTMLElement,
    viewerImg: viewer.querySelector('[data-hl-viewer-img]') as HTMLElement,
  };
  modalRefs = refs;

  modal.querySelectorAll('[data-hl-close]').forEach((el) => {
    el.addEventListener('click', closeModal);
  });
  viewer.querySelector('[data-hl-viewer-close]')?.addEventListener('click', closeViewer);
  viewer.addEventListener('click', (event) => {
    if (event.target === viewer) closeViewer();
    else if ((event.target as HTMLElement).tagName === 'IMG') showNextStory();
  });

  const input = refs.nameInput as HTMLInputElement;
  input.addEventListener('input', () => {
    const next = refs.nextBtn as HTMLButtonElement;
    next.disabled = input.value.trim().length === 0;
  });
  input.addEventListener('keydown', (event) => {
    if ((event as KeyboardEvent).key === 'Enter' && input.value.trim()) goToPicker();
  });

  refs.nextBtn.addEventListener('click', goToPicker);
  refs.uploadBtn.addEventListener('click', () => (refs.fileInput as HTMLInputElement).click());
  refs.fileInput.addEventListener('change', handleUpload);

  return refs;
}

function openModal(): void {
  const refs = ensureModal();
  pendingTitle = '';
  const input = refs.nameInput as HTMLInputElement;
  input.value = '';
  (refs.nextBtn as HTMLButtonElement).disabled = true;
  refs.stepName.hidden = false;
  refs.stepPicker.hidden = true;
  refs.grid.innerHTML = '';
  refs.modal.hidden = false;
  window.setTimeout(() => input.focus(), 60);
}

function closeModal(): void {
  if (modalRefs) modalRefs.modal.hidden = true;
}

async function goToPicker(): Promise<void> {
  const refs = ensureModal();
  const input = refs.nameInput as HTMLInputElement;
  const title = input.value.trim();
  if (!title) return;
  pendingTitle = title;
  refs.stepName.hidden = true;
  refs.stepPicker.hidden = false;
  await loadStoriesGrid();
}

async function loadStoriesGrid(): Promise<void> {
  const refs = ensureModal();
  refs.grid.innerHTML = '<div class="wg-hl-empty">Cargando historias…</div>';

  const { data, error } = await supabase
    .from('stories')
    .select('*')
    .eq('user_id', targetUserId)
    .order('created_at', { ascending: false })
    .limit(60);

  if (error) {
    refs.grid.innerHTML = '<div class="wg-hl-empty">No se pudieron cargar tus historias.</div>';
    return;
  }

  const stories = (data || []) as Story[];
  if (!stories.length) {
    refs.grid.innerHTML = '<div class="wg-hl-empty">Aún no tienes historias. Sube una nueva.</div>';
    return;
  }

  refs.grid.innerHTML = stories
    .map(
      (story) =>
        `<button type="button" class="wg-hl-thumb" data-story-id="${esc(story.id)}" data-story-url="${esc(story.media_url)}"><img src="${esc(story.media_url)}" alt="Historia" loading="lazy" /></button>`,
    )
    .join('');

  refs.grid.querySelectorAll('[data-story-id]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const id = btn.getAttribute('data-story-id') || '';
      const url = btn.getAttribute('data-story-url') || '';
      if (id && url) createHighlight({ id, user_id: targetUserId, media_url: url, created_at: '' });
    });
  });
}

async function handleUpload(event: Event): Promise<void> {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  input.value = '';
  if (!file) return;
  if (!file.type.startsWith('image/')) {
    showToast('Solo se aceptan imágenes', { type: 'error' });
    return;
  }
  if (file.size > 8 * 1024 * 1024) {
    showToast('La imagen no puede pasar de 8 MB', { type: 'error' });
    return;
  }

  const refs = ensureModal();
  const ext = (file.name.split('.').pop() || 'jpg').toLowerCase();
  const path = `${targetUserId}/${crypto.randomUUID()}.${ext}`;

  showToast('Subiendo historia…');
  const { error: uploadError } = await supabase.storage
    .from('stories')
    .upload(path, file, { contentType: file.type, upsert: false });

  if (uploadError) {
    showToast('No se pudo subir la imagen', { type: 'error' });
    return;
  }

  const { data: pub } = supabase.storage.from('stories').getPublicUrl(path);
  const publicUrl = pub?.publicUrl || '';
  if (!publicUrl) {
    showToast('No se pudo obtener la URL de la imagen', { type: 'error' });
    return;
  }

  const { data, error } = await supabase
    .from('stories')
    .insert({ user_id: targetUserId, media_url: publicUrl })
    .select()
    .single();

  if (error || !data) {
    showToast('No se pudo guardar la historia', { type: 'error' });
    return;
  }

  await loadStoriesGrid();
  void refs;
}

async function createHighlight(story: Story): Promise<void> {
  const refs = ensureModal();
  const { data, error } = await supabase
    .from('highlights')
    .insert({ user_id: targetUserId, title: pendingTitle, cover_url: story.media_url })
    .select()
    .single();

  if (error || !data) {
    showToast('No se pudo crear la historia destacada', { type: 'error' });
    return;
  }

  await supabase.from('highlight_stories').insert({
    highlight_id: data.id,
    story_id: story.id,
    position: 0,
  });

  closeModal();
  showToast('Historia destacada creada');
  await refreshRow();
  void refs;
}

async function loadHighlights(userId: string): Promise<Highlight[]> {
  const { data, error } = await supabase
    .from('highlights')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: true });

  if (error) return [];
  return (data || []) as Highlight[];
}

function renderRow(highlights: Highlight[]): void {
  if (!container) return;

  if (!isOwner && highlights.length === 0) {
    container.innerHTML = '';
    return;
  }

  const newButton = isOwner
    ? `<button type="button" class="wg-hl-item wg-hl-new" data-hl-new>
         <span class="wg-hl-ring">+</span>
         <span class="wg-hl-label">Nueva</span>
       </button>`
    : '';

  const items = highlights
    .map(
      (highlight) => `
      <button type="button" class="wg-hl-item" data-hl-open="${esc(highlight.id)}">
        <span class="wg-hl-ring">
          ${highlight.cover_url ? `<img src="${esc(highlight.cover_url)}" alt="${esc(highlight.title)}" loading="lazy" />` : '<span class="wg-hl-placeholder">★</span>'}
        </span>
        <span class="wg-hl-label">${esc(highlight.title)}</span>
      </button>`,
    )
    .join('');

  container.innerHTML = `<div class="wg-hl-row">${newButton}${items}</div>`;

  container.querySelector('[data-hl-new]')?.addEventListener('click', openModal);
  container.querySelectorAll('[data-hl-open]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const id = btn.getAttribute('data-hl-open') || '';
      if (id) openHighlight(id);
    });
  });
}

async function refreshRow(): Promise<void> {
  const highlights = await loadHighlights(targetUserId);
  renderRow(highlights);
}

async function openHighlight(highlightId: string): Promise<void> {
  const { data, error } = await supabase
    .from('highlight_stories')
    .select('position, stories:story_id(media_url)')
    .eq('highlight_id', highlightId)
    .order('position', { ascending: true });

  if (error) {
    showToast('No se pudo abrir la historia', { type: 'error' });
    return;
  }

  const urls = (data || [])
    .map((row: any) => row.stories?.media_url)
    .filter((url: unknown): url is string => typeof url === 'string' && url.length > 0);

  if (!urls.length) {
    showToast('Esta historia destacada está vacía');
    return;
  }

  viewerUrls = urls;
  viewerIndex = 0;
  const refs = ensureModal();
  const img = refs.viewerImg as HTMLImageElement;
  img.src = viewerUrls[0];
  refs.viewer.hidden = false;
}

function showNextStory(): void {
  if (!modalRefs || viewerUrls.length === 0) return;
  viewerIndex = (viewerIndex + 1) % viewerUrls.length;
  (modalRefs.viewerImg as HTMLImageElement).src = viewerUrls[viewerIndex];
}

function closeViewer(): void {
  if (!modalRefs) return;
  modalRefs.viewer.hidden = true;
  (modalRefs.viewerImg as HTMLImageElement).src = '';
}

export async function initHighlights(containerId: string, userId: string): Promise<void> {
  const el = document.getElementById(containerId);
  if (!el || !userId) return;

  container = el;
  targetUserId = userId;
  ensureStyles();
  ensureModal();

  const { data } = await supabase.auth.getSession();
  const me = data?.session?.user?.id || null;
  isOwner = Boolean(me && me === userId);

  await refreshRow();
}
