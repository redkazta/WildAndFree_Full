import type { APIRoute } from 'astro';
import {
  getServerConfig,
  getAuthUser,
  supabaseRest,
  stripeRequest,
  createPaidTicket,
} from '../../lib/tickets-server';

function json(body: any, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

export const POST: APIRoute = async ({ request }) => {
  const config = getServerConfig();

  if (!config.serviceKey || !config.supabaseUrl) {
    return json({ error: 'supabase_not_configured' }, 503);
  }

  const user = await getAuthUser(request);
  if (!user) {
    return json({ error: 'Inicia sesión para comprar tu boleto.' }, 401);
  }

  let body: any;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'Cuerpo inválido.' }, 400);
  }

  const eventId = String(body?.event_id || '').trim();
  if (!eventId) return json({ error: 'event_id requerido.' }, 400);

  try {
    const events = await supabaseRest<any[]>(
      `events?id=eq.${encodeURIComponent(eventId)}&select=*&limit=1`,
    );
    const event = events?.[0];

    if (!event || event.is_active === false) {
      return json({ error: 'Este evento no está disponible.' }, 404);
    }

    const price = Number(event.ticket_price ?? 0);
    const currency = String(event.ticket_currency || 'MXN').toUpperCase();

    // Si el usuario ya tiene un boleto pagado para este evento, lo reutilizamos.
    const existing = await supabaseRest<any[]>(
      `tickets?event_id=eq.${encodeURIComponent(eventId)}&user_id=eq.${encodeURIComponent(user.id)}&status=eq.paid&select=*&limit=1`,
    );
    if (existing?.length) {
      return json({ ticket: existing[0], already_purchased: true });
    }

    // Evento gratuito: el boleto se emite directamente con la service key.
    if (price <= 0) {
      const ticket = await createPaidTicket({
        eventId,
        userId: user.id,
        price: 0,
        currency,
      });
      return json({ free: true, ticket });
    }

    if (!config.stripeKey) {
      return json({ error: 'stripe_not_configured' }, 503);
    }

    const origin = new URL(request.url).origin;
    const params: Record<string, string> = {
      mode: 'payment',
      'line_items[0][quantity]': '1',
      'line_items[0][price_data][currency]': currency.toLowerCase(),
      'line_items[0][price_data][unit_amount]': String(Math.round(price * 100)),
      'line_items[0][price_data][product_data][name]': `${event.name} — Boleto general`,
      'metadata[event_id]': eventId,
      'metadata[user_id]': user.id,
      'metadata[ticket_type]': 'general',
      success_url: `${origin}/evento?id=${encodeURIComponent(eventId)}&success=1&session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${origin}/evento?id=${encodeURIComponent(eventId)}&canceled=1`,
      allow_promotion_codes: 'true',
    };

    if (user.email) params.customer_email = user.email;

    const session = await stripeRequest<any>('checkout/sessions', params);
    return json({ url: session.url });
  } catch (error: any) {
    console.error('[ticket-checkout]', error);
    return json({ error: 'No pudimos iniciar el pago. Intenta de nuevo.' }, 500);
  }
};
