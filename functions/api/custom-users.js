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

  const kvUrl    = env.KV_REST_API_URL;
  const kvToken  = env.KV_REST_API_TOKEN;
  const ADMIN_PASS = env.AC_ADMIN_PASS;

  if (!kvUrl || !kvToken) {
    return new Response(JSON.stringify({ error: 'KV not configured' }), { status: 500, headers: corsHeaders });
  }
  if (!ADMIN_PASS) {
    return new Response(JSON.stringify({ error: 'AC_ADMIN_PASS not set' }), { status: 500, headers: corsHeaders });
  }

  const hdrs = { Authorization: 'Bearer ' + kvToken };
  const KEY  = 'ac_custom_users';

  async function getUsers() {
    try {
      const r = await fetch(`${kvUrl}/get/${KEY}`, { headers: hdrs });
      const d = await r.json();
      if (!d.result) return {};
      return JSON.parse(d.result);
    } catch { return {}; }
  }

  async function setUsers(data) {
    const encoded = encodeURIComponent(JSON.stringify(data));
    await fetch(`${kvUrl}/set/${KEY}/${encoded}`, { method: 'POST', headers: hdrs });
  }

  if (request.method === 'GET') {
    const action = url.searchParams.get('action');

    if (action === 'online') {
      try {
        const r = await fetch(`${kvUrl}/keys/ac_exec_*`, { headers: hdrs });
        const d = await r.json();
        const keys = d.result || [];
        const names = await Promise.all(keys.map(async k => {
          try {
            const r2 = await fetch(`${kvUrl}/get/${k}`, { headers: hdrs });
            const d2 = await r2.json();
            return d2.result || null;
          } catch { return null; }
        }));
        return new Response(JSON.stringify({ ok: true, users: names.filter(Boolean) }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      } catch {
        return new Response(JSON.stringify({ ok: true, users: [] }), {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }
    }

    const auth = url.searchParams.get('auth');
    if (auth !== undefined && auth !== ADMIN_PASS) {
      return new Response(JSON.stringify({ ok: false, error: 'Wrong password' }), { status: 401, headers: corsHeaders });
    }
    const users = await getUsers();
    return new Response(JSON.stringify({ ok: true, users }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  if (request.method === 'POST') {
    const action = url.searchParams.get('action');

    if (action === 'exec') {
      const key  = url.searchParams.get('key');
      const name = url.searchParams.get('name');
      if (key && name) {
        try {
          await fetch(`${kvUrl}/set/${key}/${encodeURIComponent(name)}`, { method: 'POST', headers: hdrs });
          await fetch(`${kvUrl}/expire/${key}/30`, { headers: hdrs });
        } catch {}
      }
      return new Response(JSON.stringify({ ok: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    let body = {};
    try { body = await request.json(); } catch {}

    const { auth, action: bodyAction, username, tag, pfpId, bgId, effects, animMeta } = body;
    if (auth !== ADMIN_PASS) {
      return new Response(JSON.stringify({ ok: false, error: 'Wrong password' }), { status: 401, headers: corsHeaders });
    }
    if (!username) {
      return new Response(JSON.stringify({ ok: false, error: 'username required' }), { status: 400, headers: corsHeaders });
    }

    const users = await getUsers();

    if (bodyAction === 'set') {
      if (!tag) return new Response(JSON.stringify({ ok: false, error: 'tag required' }), { status: 400, headers: corsHeaders });
      const record = { tag: tag.trim(), pfpId: (pfpId || '').trim(), bgId: (bgId || '').trim() };
      if (effects && typeof effects === 'object') record.effects = effects;
      if (animMeta && typeof animMeta === 'object') record.animMeta = animMeta;
      users[username] = record;
      await setUsers(users);
      return new Response(JSON.stringify({ ok: true, users }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    if (bodyAction === 'delete') {
      delete users[username];
      await setUsers(users);
      return new Response(JSON.stringify({ ok: true, users }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    return new Response(JSON.stringify({ ok: false, error: 'Unknown action' }), { status: 400, headers: corsHeaders });
  }

  return new Response(JSON.stringify({ ok: false, error: 'Method not allowed' }), { status: 405, headers: corsHeaders });
}
