const { Client } = require('pg');
const crypto = require('crypto');

const CONNECTION = 'postgresql://postgres:Pedrito1122**@db.cfsqhbisrkqhbupyjrwz.supabase.co:5432/postgres';

// Generate UUID v4
function uuidv4() {
  return crypto.randomUUID();
}

// Hash password for auth.users (Supabase uses pgcrypto)
function hashPassword(password) {
  // We'll use Supabase's auth API via RPC or direct insert
  return password;
}

async function run() {
  const c = new Client({ connectionString: CONNECTION });
  await c.connect();

  try {
    // 1. Verify artists
    console.log('=== Verifying artists ===');
    await c.query(`
      UPDATE public.profiles SET
        is_verified_artist = true,
        verification_status = 'approved'
      WHERE username IN ('young_kazta', 'mc_delta', 'lil_fuego')
    `);
    console.log('Artists verified: young_kazta, mc_delta, lil_fuego');

    // 2. Create staff_manager user
    console.log('\n=== Creating staff_manager user ===');
    const staffMgrId = uuidv4();
    await c.query(`
      INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_user_meta_data, created_at, updated_at,
        confirmation_token, email_change_token_new, recovery_token
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        $1, 'authenticated', 'authenticated',
        'staff_manager@wildgvng.com.mx',
        crypt('Staff1122**', gen_salt('bf')),
        NOW(),
        '{"nombre": "Roberto Méndez", "username": "roberto_staff", "phone": "+528711112222", "ubicacion": "Torreón Coahuila"}'::jsonb,
        NOW(), NOW(), '', '', ''
      )
      ON CONFLICT (id) DO NOTHING
    `, [staffMgrId]);
    await c.query(`INSERT INTO public.profiles (id, nombre, username, phone, ubicacion) VALUES ($1, 'Roberto Méndez', 'roberto_staff', '+528711112222', 'Torreón Coahuila') ON CONFLICT (id) DO NOTHING`, [staffMgrId]);
    await c.query(`INSERT INTO public.user_roles (user_id, role_id) VALUES ($1, 3) ON CONFLICT DO NOTHING`, [staffMgrId]);
    await c.query(`INSERT INTO public.user_tokens (user_id, balance) VALUES ($1, 0) ON CONFLICT DO NOTHING`, [staffMgrId]);
    console.log('staff_manager@wildgvng.com.mx / Staff1122**');

    // 3. Create staff_marketing user
    console.log('\n=== Creating staff_marketing user ===');
    const staffMktId = uuidv4();
    await c.query(`
      INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_user_meta_data, created_at, updated_at,
        confirmation_token, email_change_token_new, recovery_token
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        $1, 'authenticated', 'authenticated',
        'marketing@wildgvng.com.mx',
        crypt('Marketing1122**', gen_salt('bf')),
        NOW(),
        '{"nombre": "Sofía López", "username": "sofia_marketing", "phone": "+528722223333", "ubicacion": "Torreón Coahuila"}'::jsonb,
        NOW(), NOW(), '', '', ''
      )
      ON CONFLICT (id) DO NOTHING
    `, [staffMktId]);
    await c.query(`INSERT INTO public.profiles (id, nombre, username, phone, ubicacion) VALUES ($1, 'Sofía López', 'sofia_marketing', '+528722223333', 'Torreón Coahuila') ON CONFLICT (id) DO NOTHING`, [staffMktId]);
    await c.query(`INSERT INTO public.user_roles (user_id, role_id) VALUES ($1, 5) ON CONFLICT DO NOTHING`, [staffMktId]);
    await c.query(`INSERT INTO public.user_tokens (user_id, balance) VALUES ($1, 0) ON CONFLICT DO NOTHING`, [staffMktId]);
    console.log('marketing@wildgvng.com.mx / Marketing1122**');

    // 4. Create staff (basic) user
    console.log('\n=== Creating staff user ===');
    const staffId = uuidv4();
    await c.query(`
      INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, raw_user_meta_data, created_at, updated_at,
        confirmation_token, email_change_token_new, recovery_token
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        $1, 'authenticated', 'authenticated',
        'staff@wildgvng.com.mx',
        crypt('Staff1122**', gen_salt('bf')),
        NOW(),
        '{"nombre": "Diego Torres", "username": "diego_staff", "phone": "+528733334444", "ubicacion": "Torreón Coahuila"}'::jsonb,
        NOW(), NOW(), '', '', ''
      )
      ON CONFLICT (id) DO NOTHING
    `, [staffId]);
    await c.query(`INSERT INTO public.profiles (id, nombre, username, phone, ubicacion) VALUES ($1, 'Diego Torres', 'diego_staff', '+528733334444', 'Torreón Coahuila') ON CONFLICT (id) DO NOTHING`, [staffId]);
    await c.query(`INSERT INTO public.user_roles (user_id, role_id) VALUES ($1, 4) ON CONFLICT DO NOTHING`, [staffId]);
    await c.query(`INSERT INTO public.user_tokens (user_id, balance) VALUES ($1, 0) ON CONFLICT DO NOTHING`, [staffId]);
    console.log('staff@wildgvng.com.mx / Staff1122**');

    // 5. Assign tags to users
    console.log('\n=== Assigning tags ===');
    // Admin already has tags (FOUNDER, WILD, OG MEMBER, VERIFIED ARTIST, WILD PASS)
    // Artists: WILD, FREESTYLER, VERIFIED ARTIST (already have WILD, FREESTYLER)
    await c.query(`INSERT INTO public.user_has_tags (user_id, tag_id) VALUES ($1, 4) ON CONFLICT DO NOTHING`, ['66fd9133-87bc-43eb-9095-23b11f44de5c']); // young_kazta VERIFIED
    await c.query(`INSERT INTO public.user_has_tags (user_id, tag_id) VALUES ($1, 4) ON CONFLICT DO NOTHING`, ['2406328b-ad5b-4271-a923-36af6b9c5a29']); // mc_delta VERIFIED
    await c.query(`INSERT INTO public.user_has_tags (user_id, tag_id) VALUES ($1, 4) ON CONFLICT DO NOTHING`, ['1a2eac9c-50e9-48d1-9026-54286147c149']); // lil_fuego VERIFIED

    // Give artists some token balance for testing
    console.log('\n=== Setting token balances ===');
    await c.query(`UPDATE public.user_tokens SET balance = 50 WHERE user_id = '66fd9133-87bc-43eb-9095-23b11f44de5c'`); // young_kazta
    await c.query(`UPDATE public.user_tokens SET balance = 30 WHERE user_id = '2406328b-ad5b-4271-a923-36af6b9c5a29'`); // mc_delta
    await c.query(`UPDATE public.user_tokens SET balance = 10 WHERE user_id = '85fce31c-2cc1-48d9-8bd2-5692daf74162'`); // carlos_mx

    // 6. Verify the fix worked
    console.log('\n=== Verification ===');
    const users = await c.query(`
      SELECT u.email, p.username, p.nombre, p.is_verified_artist, p.verification_status,
        (SELECT array_agg(r.name) FROM public.user_roles ur JOIN public.roles r ON r.id = ur.role_id WHERE ur.user_id = u.id) as roles
      FROM auth.users u
      JOIN public.profiles p ON p.id = u.id
      ORDER BY u.created_at
    `);
    console.table(users.rows.map(r => ({
      email: r.email,
      username: r.username,
      nombre: r.nombre,
      verified: r.is_verified_artist,
      roles: r.roles?.join(', ') || 'none'
    })));

    console.log('\n=== DONE ===');
  } catch (e) {
    console.error('ERROR:', e.message);
  } finally {
    await c.end();
  }
}

run();
