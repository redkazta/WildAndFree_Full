// Toast propio del sitio: reemplaza los alert() nativos del navegador.
// Uso: showToast('Mensaje', { type: 'error', action: { label: 'Entrar', href: '/login' } })

export type ToastType = 'info' | 'error' | 'success';

export type ToastOptions = {
  type?: ToastType;
  action?: { label: string; href: string };
  duration?: number;
};

const STYLE_ID = 'wg-toast-style';
const ROOT_ID = 'wg-toast-root';

const TOAST_CSS = `
.wg-toast-root {
  position: fixed;
  left: 50%;
  bottom: 24px;
  transform: translateX(-50%);
  z-index: 9999;
  display: flex;
  flex-direction: column;
  align-items: stretch;
  gap: 8px;
  width: min(420px, calc(100vw - 24px));
  pointer-events: none;
}
.wg-toast {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 14px;
  border: 1px solid var(--border-muted, rgba(255,255,255,0.18));
  border-left: 3px solid var(--primary, #C98300);
  border-radius: 12px;
  background: var(--surface-solid-elev, #111111);
  color: var(--text, #ffffff);
  font-size: 13px;
  font-weight: 700;
  line-height: 1.4;
  box-shadow: 0 18px 50px rgba(0, 0, 0, 0.55);
  opacity: 0;
  transform: translateY(10px);
  transition: opacity 0.2s ease, transform 0.2s ease;
  pointer-events: auto;
}
.wg-toast.is-visible {
  opacity: 1;
  transform: translateY(0);
}
.wg-toast--error { border-left-color: #ff3b3b; }
.wg-toast--success { border-left-color: #37d67a; }
.wg-toast-text {
  flex: 1;
  min-width: 0;
}
.wg-toast-action {
  flex-shrink: 0;
  padding: 6px 10px;
  border-radius: 8px;
  background: var(--primary, #C98300);
  color: #000;
  font-size: 10px;
  font-weight: 900;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  text-decoration: none;
  white-space: nowrap;
}
.wg-toast-action:hover { filter: brightness(1.1); }
.wg-toast-close {
  flex-shrink: 0;
  padding: 0 2px;
  border: none;
  background: none;
  color: rgba(255, 255, 255, 0.5);
  font-size: 18px;
  line-height: 1;
  cursor: pointer;
}
.wg-toast-close:hover { color: #fff; }

@media (max-width: 480px) {
  .wg-toast-root {
    bottom: 16px;
    width: calc(100vw - 20px);
  }
  .wg-toast { font-size: 12px; padding: 11px 12px; }
}
`;

function ensureStyle(): void {
  if (document.getElementById(STYLE_ID)) return;
  const style = document.createElement('style');
  style.id = STYLE_ID;
  style.textContent = TOAST_CSS;
  document.head.appendChild(style);
}

function ensureRoot(): HTMLElement {
  const existing = document.getElementById(ROOT_ID);
  if (existing) return existing;
  const root = document.createElement('div');
  root.id = ROOT_ID;
  root.className = 'wg-toast-root';
  document.body.appendChild(root);
  return root;
}

function dismiss(el: HTMLElement): void {
  el.classList.remove('is-visible');
  window.setTimeout(() => el.remove(), 220);
}

export function showToast(message: string, options: ToastOptions = {}): void {
  if (typeof document === 'undefined') return;

  ensureStyle();
  const root = ensureRoot();

  const toast = document.createElement('div');
  toast.className = `wg-toast wg-toast--${options.type || 'info'}`;
  toast.setAttribute('role', 'status');
  toast.setAttribute('aria-live', 'polite');

  const text = document.createElement('span');
  text.className = 'wg-toast-text';
  text.textContent = message;
  toast.appendChild(text);

  if (options.action) {
    const link = document.createElement('a');
    link.className = 'wg-toast-action';
    link.href = options.action.href;
    link.textContent = options.action.label;
    toast.appendChild(link);
  }

  const close = document.createElement('button');
  close.type = 'button';
  close.className = 'wg-toast-close';
  close.setAttribute('aria-label', 'Cerrar');
  close.textContent = '×';
  close.addEventListener('click', () => dismiss(toast));
  toast.appendChild(close);

  root.appendChild(toast);
  requestAnimationFrame(() => toast.classList.add('is-visible'));

  window.setTimeout(() => dismiss(toast), options.duration ?? 4200);
}
