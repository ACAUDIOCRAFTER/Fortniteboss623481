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

  const ADMIN_PASS = env.AC_ADMIN_PASS;
  const KV = env.AC_KV;

  if (!KV) {
    return new Response(JSON.stringify({ error: 'KV not configured' }), { status: 500, headers: corsHeaders });
  }
  if (!ADMIN_PASS) {
    return new Response(JSON.stringify({ error: 'AC_ADMIN_PASS not set' }), { status: 500, headers: corsHeaders });
  }

  const KEY = 'ac_custom_users';

  async function getUsers() {
    try {
      const data = await KV.get(KEY, { type: 'json' });
      return data || {};
    } catch { return {}; }
  }

  async function setUsers(data) {
    await KV.put(KEY, JSON.stringify(data));
  }

  if (request.method === 'GET') {
    const action = url.searchParams.get('action');

    if (action === 'online') {
      try {
        const list = await KV.list({ prefix: 'ac_exec_' });
        const names = await Promise.all(list.keys.map(async ({ name: k }) => {
          try {
            return await KV.get(k);
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
          await KV.put(key, name, { expirationTtl: 30 });
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
