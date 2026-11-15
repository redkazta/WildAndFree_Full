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

  if (!config.serviceKey) {
    return json({ error: 'supabase_not_configured' }, 503);
  }
  if (!config.stripeKey) {
    return json({ error: 'stripe_not_configured' }, 503);
  }

  const user = await getAuthUser(request);
  if (!user) {
    return json({ error: 'Inicia sesión para confirmar tu boleto.' }, 401);
  }

  let body: any;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'Cuerpo inválido.' }, 400);
  }

  const sessionId = String(body?.session_id || '').trim();
  if (!sessionId) return json({ error: 'session_id requerido.' }, 400);

  try {
    // Idempotencia: si ya se emitió el boleto, lo devolvemos.
    const existing = await supabaseRest<any[]>(
      `tickets?stripe_session_id=eq.${encodeURIComponent(sessionId)}&select=*&limit=1`,
    );
    if (existing?.length) {
      return json({ ticket: existing[0] });
    }

    const session = await stripeRequest<any>(
      `checkout/sessions/${encodeURIComponent(sessionId)}`,
    );

    if (session.payment_status !== 'paid') {
      return json({ error: 'El pago aún no se ha completado.' }, 400);
    }

    const metadata = session.metadata || {};
    if (!metadata.event_id || !metadata.user_id) {
      return json({ error: 'La sesión de pago no contiene los datos del boleto.' }, 400);
    }
    if (metadata.user_id !== user.id) {
      return json({ error: 'Esta sesión de pago no te pertenece.' }, 403);
    }

    const ticket = await createPaidTicket({
      eventId: metadata.event_id,
      userId: metadata.user_id,
      price: Number(session.amount_total ?? 0) / 100,
      currency: String(session.currency || 'mxn').toUpperCase(),
      sessionId,
      paymentIntentId: typeof session.payment_intent === 'string' ? session.payment_intent : null,
    });

    return json({ ticket });
  } catch (error: any) {
    console.error('[ticket-confirm]', error);
    return json({ error: 'No pudimos confirmar el pago. Contacta a soporte.' }, 500);
  }
};
