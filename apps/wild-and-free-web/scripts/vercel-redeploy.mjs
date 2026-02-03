const hookUrl = process.env.VERCEL_DEPLOY_HOOK_URL;

if (!hookUrl) {
  console.error('Missing env var: VERCEL_DEPLOY_HOOK_URL');
  process.exit(1);
}

const res = await fetch(hookUrl, { method: 'POST' });
if (!res.ok) {
  const text = await res.text().catch(() => '');
  console.error(`Vercel redeploy failed: ${res.status} ${res.statusText}${text ? `\n${text}` : ''}`);
  process.exit(1);
}

console.log('Vercel redeploy triggered successfully.');
