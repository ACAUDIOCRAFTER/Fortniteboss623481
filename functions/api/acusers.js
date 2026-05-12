// functions/api/acusers.js — uses Cloudflare native KV (AC_KV binding)

export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const KV = env.AC_KV;

  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json',
  };

  if (request.method === 'OPTIONS') return new Response(null, { headers: cors });

  const SECRET = env.AC_SECRET;
  const action = url.searchParams.get('action');
  const job    = url.searchParams.get('job');
  const user   = url.searchParams.get('user');

  if (!job) return new Response(JSON.stringify([]), { status: 400, headers: cors });
  if (SECRET && url.searchParams.get('auth') !== SECRET) {
    return new Response(JSON.stringify({ error: 'Forbidden' }), { status: 403, headers: cors });
  }

  const key = 'ac2_' + job;

  try {
    if (action === 'join' && user) {
      const members = JSON.parse((await KV.get(key)) || '[]');
      if (!members.includes(user)) members.push(user);
      await KV.put(key, JSON.stringify(members), { expirationTtl: 8 });
      return new Response(JSON.stringify({ ok: true }), { headers: cors });
    }

    if (action === 'list') {
      const members = JSON.parse((await KV.get(key)) || '[]');
      return new Response(JSON.stringify(members), { headers: cors });
    }

    if (action === 'leave' && user) {
      const members = JSON.parse((await KV.get(key)) || '[]').filter(u => u !== user);
      await KV.put(key, JSON.stringify(members), { expirationTtl: 8 });
      return new Response(JSON.stringify({ ok: true }), { headers: cors });
    }

    return new Response(JSON.stringify([]), { status: 400, headers: cors });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: cors });
  }
}
