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

  const kvUrl      = env.KV_REST_API_URL;
  const kvTok      = env.KV_REST_API_TOKEN;
  const ADMIN_PASS  = env.AC_ADMIN_PASS;
  const EXEC_SECRET = env.AC_EXEC_SECRET;
  const EXEC_TTL    = 45;
  const GC_MAX      = 200;
  const hdrs        = { Authorization: 'Bearer ' + kvTok };

  if (!kvUrl || !kvTok || !ADMIN_PASS || !EXEC_SECRET) {
    return new Response(JSON.stringify({ error: 'Env vars not set' }), { status: 500, headers: corsHeaders });
  }

  async function kvGet(key) {
    try {
      const r = await fetch(`${kvUrl}/get/${encodeURIComponent(key)}`, { headers: hdrs });
      const d = await r.json();
      return d.result ? JSON.parse(d.result) : null;
    } catch { return null; }
  }

  async function kvSet(key, value) {
    const enc = encodeURIComponent(JSON.stringify(value));
    await fetch(`${kvUrl}/set/${encodeURIComponent(key)}/${enc}`, { method: 'POST', headers: hdrs });
  }

  const q = Object.fromEntries(url.searchParams);
  let bod = {};
  try { bod = await request.clone().json(); } catch {}

  const action = q.action || bod.action;
  const secret = q.secret || bod.secret;

  if (action === 'exec_list') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: corsHeaders });
    const map = (await kvGet('ac_executing')) || {};
    const now = Date.now();
    return new Response(JSON.stringify({
      ok: true,
      executing: Object.entries(map).filter(([, t]) => now - t < EXEC_TTL * 1000).map(([u]) => u)
    }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (action === 'exec') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: corsHeaders });
    const username = q.user, userId = q.uid || '', displayName = q.dn || q.user;
    if (!username) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: corsHeaders });
    const now = Date.now();
    const map = (await kvGet('ac_executing')) || {};
    map[username] = now;
    for (const [u, t] of Object.entries(map)) if (now - t >= EXEC_TTL * 1000) delete map[u];
    await kvSet('ac_executing', map);
    const all = (await kvGet('ac_all_users')) || {};
    if (!all[username]) all[username] = { userId, displayName, firstSeen: now, lastSeen: now };
    else { all[username].lastSeen = now; if (userId) all[username].userId = userId; if (displayName) all[username].displayName = displayName; }
    await kvSet('ac_all_users', all);
    return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (action === 'dm_send') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: corsHeaders });
    const from = bod.from || q.from, fromId = bod.fromId || q.fromId, toId = bod.toId || q.toId, text = bod.text || q.text, ts = Number(bod.ts || q.ts || Date.now());
    if (!from || !fromId || !toId || !text) return new Response(JSON.stringify({ ok: false, error: 'Missing fields' }), { status: 400, headers: corsHeaders });
    const key = `ac_dm_inbox_${toId}`;
    const inbox = (await kvGet(key)) || [];
    inbox.push({ from, fromId, text, ts });
    await kvSet(key, inbox);
    return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (action === 'dm_poll') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: corsHeaders });
    const toId = q.toId || bod.toId;
    if (!toId) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: corsHeaders });
    const inbox = (await kvGet(`ac_dm_inbox_${toId}`)) || [];
    const typing = (await kvGet(`ac_dm_typing_${toId}`)) || [];
    const now = Date.now();
    return new Response(JSON.stringify({ ok: true, messages: inbox, typing: typing.filter(t => now - t.ts < 5000) }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  if (action === 'gc_send') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: corsHeaders });
    const from = bod.from || q.from, fromId = bod.fromId || q.fromId, text = bod.text || q.text, ts = Number(bod.ts || q.ts || Date.now());
    if (!from || !text) return new Response(JSON.stringify({ ok: false, error: 'Missing fields' }), { status: 400, headers: corsHeaders });
    const msgs = (await kvGet('ac_global_chat')) || [];
    msgs.push({ from, fromId, text, ts });
    if (msgs.length > GC_MAX) msgs.splice(0, msgs.length - GC_MAX);
    await kvSet('ac_global_chat', msgs);
    return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (action === 'gc_poll') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: corsHeaders });
    const since = Number(q.since || 0);
    const msgs = (await kvGet('ac_global_chat')) || [];
    const gcTyping = (await kvGet('ac_gc_typing')) || [];
    const gcNow = Date.now();
    return new Response(JSON.stringify({
      ok: true,
      messages: msgs.filter(m => m.ts > since),
      typing: gcTyping.filter(t => gcNow - t.ts < 5000)
    }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (action === 'dm_typing') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false }), { status: 403, headers: corsHeaders });
    const from = q.from, fromId = q.fromId, toId = q.toId;
    if (!from || !fromId || !toId) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: corsHeaders });
    const key = `ac_dm_typing_${toId}`;
    const typing = (await kvGet(key)) || [];
    const now = Date.now();
    const filtered = typing.filter(t => t.fromId !== fromId && now - t.ts < 5000);
    filtered.push({ from, fromId, ts: now });
    await kvSet(key, filtered);
    return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (action === 'gc_typing') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false }), { status: 403, headers: corsHeaders });
    const from = q.from || bod.from, fromId = q.fromId || bod.fromId;
    if (!from) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: corsHeaders });
    const typing = (await kvGet('ac_gc_typing')) || [];
    const now = Date.now();
    const filtered = typing.filter(t => t.fromId !== fromId && now - t.ts < 5000);
    filtered.push({ from, fromId, ts: now });
    await kvSet('ac_gc_typing', filtered);
    return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (action === 'check') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: corsHeaders });
    const username = q.user;
    const [bans, wl] = await Promise.all([kvGet('ac_banned'), kvGet('ac_whitelist')]);
    return new Response(JSON.stringify({ ok: true, banned: (bans || []).includes(username), whitelisted: (wl || []).includes(username) }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }

  // Admin routes
  const auth = q.auth || bod.auth;
  if (auth !== ADMIN_PASS) return new Response(JSON.stringify({ ok: false, error: 'Unauthorized' }), { status: 401, headers: corsHeaders });

  if (request.method === 'GET') {
    const [bans, wl, execMap, allUsers] = await Promise.all([kvGet('ac_banned'), kvGet('ac_whitelist'), kvGet('ac_executing'), kvGet('ac_all_users')]);
    const now = Date.now();
    return new Response(JSON.stringify({
      ok: true, banned: bans || [], whitelist: wl || [],
      executing: Object.entries(execMap || {}).filter(([, t]) => now - t < EXEC_TTL * 1000).map(([u]) => u),
      allUsers: allUsers || {}
    }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (request.method === 'POST') {
    const { action: a, username: u } = bod;
    if (!u) return new Response(JSON.stringify({ ok: false, error: 'username required' }), { status: 400, headers: corsHeaders });
    if (a === 'ban_add') { const bans = (await kvGet('ac_banned')) || []; if (!bans.includes(u)) bans.push(u); await kvSet('ac_banned', bans); const m = (await kvGet('ac_executing')) || {}; delete m[u]; await kvSet('ac_executing', m); return new Response(JSON.stringify({ ok: true, banned: bans }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }); }
    if (a === 'ban_remove') { const bans = ((await kvGet('ac_banned')) || []).filter(x => x !== u); await kvSet('ac_banned', bans); return new Response(JSON.stringify({ ok: true, banned: bans }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }); }
    if (a === 'whitelist_add') { const wl = (await kvGet('ac_whitelist')) || []; if (!wl.includes(u)) wl.push(u); await kvSet('ac_whitelist', wl); return new Response(JSON.stringify({ ok: true, whitelist: wl }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }); }
    if (a === 'whitelist_remove') { const wl = ((await kvGet('ac_whitelist')) || []).filter(x => x !== u); await kvSet('ac_whitelist', wl); return new Response(JSON.stringify({ ok: true, whitelist: wl }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }); }
    return new Response(JSON.stringify({ ok: false, error: 'Unknown action' }), { status: 400, headers: corsHeaders });
  }

  return new Response(JSON.stringify({ ok: false, error: 'Method not allowed' }), { status: 405, headers: corsHeaders });
}
