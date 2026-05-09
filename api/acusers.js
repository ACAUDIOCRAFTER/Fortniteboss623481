export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);

  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  const kvUrl   = env.KV_REST_API_URL;
  const kvToken = env.KV_REST_API_TOKEN;
  const SECRET  = env.AC_SECRET;

  if (!kvUrl || !kvToken) {
    return new Response(JSON.stringify({ error: 'misconfigured' }), { status: 500, headers: corsHeaders });
  }

  const action = url.searchParams.get('action');
  const job    = url.searchParams.get('job');
  const user   = url.searchParams.get('user');

  if (!job) {
    return new Response(JSON.stringify([]), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (SECRET && url.searchParams.get('auth') !== SECRET) {
    return new Response(JSON.stringify({ error: 'Forbidden' }), { status: 403, headers: corsHeaders });
  }

  const hdrs = { Authorization: 'Bearer ' + kvToken };
  const key  = 'ac2:' + job;

  try {
    if (action === 'join' && user) {
      await fetch(`${kvUrl}/sadd/${encodeURIComponent(key)}/${encodeURIComponent(user)}`, { headers: hdrs });
      await fetch(`${kvUrl}/expire/${encodeURIComponent(key)}/8`, { headers: hdrs });
      return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    if (action === 'list') {
      const r = await fetch(`${kvUrl}/smembers/${encodeURIComponent(key)}`, { headers: hdrs });
      const d = await r.json();
      return new Response(JSON.stringify(d.result || []), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    if (action === 'leave' && user) {
      await fetch(`${kvUrl}/srem/${encodeURIComponent(key)}/${encodeURIComponent(user)}`, { headers: hdrs });
      return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    return new Response(JSON.stringify([]), { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }
}
