/**
 * Helpers de servidor para ticketing. No importar desde el cliente:
 * usa la service key de Supabase y la secret key de Stripe.
 */

const SUPABASE_URL =
  import.meta.env.SUPABASE_URL ||
  import.meta.env.PUBLIC_SUPABASE_URL ||
  '';

const SUPABASE_ANON_KEY =
  import.meta.env.PUBLIC_SUPABASE_ANON_KEY ||
  import.meta.env.SUPABASE_ANON_KEY ||
  '';

const SUPABASE_SERVICE_KEY =
  import.meta.env.SUPABASE_SERVICE_KEY ||
  import.meta.env.SUPABASE_SERVICE_ROLE_KEY ||
  '';

const STRIPE_SECRET_KEY = import.meta.env.STRIPE_SECRET_KEY || '';

export interface AuthUser {
  id: string
  email?: string
  user_metadata?: Record<string, any>
}

export function getServerConfig() {
  return {
    supabaseUrl: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
    serviceKey: SUPABASE_SERVICE_KEY,
    stripeKey: STRIPE_SECRET_KEY,
  };
}

export async function getAuthUser(request: Request): Promise<AuthUser | null> {
  const header = request.headers.get('authorization') || '';
  const token = header.toLowerCase().startsWith('bearer ') ? header.slice(7).trim() : '';
  if (!token || !SUPABASE_ANON_KEY || !SUPABASE_URL) return null;

  try {
    const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: {
        apikey: SUPABASE_ANON_KEY,
        Authorization: `Bearer ${token}`,
      },
    });
    if (!response.ok) return null;
    return (await response.json()) as AuthUser;
  } catch {
    return null;
  }
}

export async function supabaseRest<T = any>(path: string, init?: RequestInit): Promise<T> {
  if (!SUPABASE_SERVICE_KEY || !SUPABASE_URL) {
    throw new Error('Supabase no está configurado en el servidor');
  }

  const response = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...init,
    headers: {
      apikey: SUPABASE_SERVICE_KEY,
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      'Content-Type': 'application/json',
      ...(init?.headers || {}),
    },
  });

  const text = await response.text();
  const payload = text ? JSON.parse(text) : null;

  if (!response.ok) {
    const message = payload?.message || payload?.error_description || payload?.hint || 'Error de Supabase';
    throw new Error(message);
  }

  return payload as T;
}

export async function stripeRequest<T = any>(
  path: string,
  body?: Record<string, string>,
): Promise<T> {
  if (!STRIPE_SECRET_KEY) throw new Error('STRIPE_SECRET_KEY no configurada');

  const response = await fetch(`https://api.stripe.com/v1/${path}`, {
    method: body ? 'POST' : 'GET',
    headers: {
      Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: body ? new URLSearchParams(body).toString() : undefined,
  });

  const payload = await response.json();
  if (!response.ok) {
    throw new Error(payload?.error?.message || 'Error de Stripe');
  }
  return payload as T;
}

export function generateTicketCode(): string {
  const random = Math.random().toString(36).slice(2, 10);
  const time = Date.now().toString(36);
  return `WG-${time}-${random}`.toUpperCase();
}

export interface CreateTicketInput {
  eventId: string
  userId: string
  price: number
  currency: string
  sessionId?: string | null
  paymentIntentId?: string | null
}

export async function createPaidTicket(input: CreateTicketInput): Promise<any> {
  const payload = {
    event_id: input.eventId,
    user_id: input.userId,
    ticket_type: 'general',
    price: input.price,
    currency: input.currency,
    status: 'paid',
    qr_code: generateTicketCode(),
    stripe_session_id: input.sessionId || null,
    stripe_payment_intent_id: input.paymentIntentId || null,
    purchased_at: new Date().toISOString(),
  };

  const rows = await supabaseRest<any[]>('tickets', {
    method: 'POST',
    headers: { Prefer: 'return=representation' },
    body: JSON.stringify(payload),
  });

  return rows?.[0] ?? null;
}
