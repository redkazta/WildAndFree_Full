export async function withLoadingState<T>(
  btn: HTMLButtonElement | null,
  loadingText: string,
  fn: () => Promise<T>
): Promise<T> {
  const originalText = btn?.textContent || ''
  if (btn) {
    btn.disabled = true
    btn.textContent = loadingText
    btn.style.opacity = '0.5'
  }

  try {
    return await fn()
  } finally {
    if (btn) {
      btn.disabled = false
      btn.textContent = originalText
      btn.style.opacity = '1'
    }
  }
}

export function getInputValue(id: string): string {
  const el = document.getElementById(id)
  return el instanceof HTMLInputElement ? el.value : ''
}
