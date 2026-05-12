// functions/api/manage.js — uses Cloudflare native KV (AC_KV binding)

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

  const ADMIN_PASS  = env.AC_ADMIN_PASS;
  const EXEC_SECRET = env.AC_EXEC_SECRET;
  const EXEC_TTL    = 45;
  const GC_MAX      = 200;

  if (!ADMIN_PASS || !EXEC_SECRET) {
    return new Response(JSON.stringify({ error: 'Env vars not set' }), { status: 500, headers: cors });
  }

  async function kvGet(key) {
    try {
      const val = await KV.get(key);
      return val ? JSON.parse(val) : null;
    } catch { return null; }
  }

  async function kvSet(key, value, ttl) {
    const opts = ttl ? { expirationTtl: ttl } : {};
    await KV.put(key, JSON.stringify(value), opts);
  }

  async function kvDel(key) {
    await KV.delete(key);
  }

  const q = Object.fromEntries(url.searchParams);
  let bod = {};
  try { bod = await request.clone().json(); } catch {}

  const action = q.action || bod.action;
  const secret = q.secret || bod.secret;

  if (action === 'exec_list') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: cors });
    const map = (await kvGet('ac_executing')) || {};
    const now = Date.now();
    return new Response(JSON.stringify({
      ok: true,
      executing: Object.entries(map).filter(([, t]) => now - t < EXEC_TTL * 1000).map(([u]) => u)
    }), { headers: cors });
  }

  if (action === 'exec') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: cors });
    const username = q.user, userId = q.uid || '', displayName = q.dn || q.user;
    if (!username) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: cors });
    const now = Date.now();
    const map = (await kvGet('ac_executing')) || {};
    map[username] = now;
    for (const [u, t] of Object.entries(map)) if (now - t >= EXEC_TTL * 1000) delete map[u];
    await kvSet('ac_executing', map);
    const all = (await kvGet('ac_all_users')) || {};
    if (!all[username]) all[username] = { userId, displayName, firstSeen: now, lastSeen: now };
    else { all[username].lastSeen = now; if (userId) all[username].userId = userId; if (displayName) all[username].displayName = displayName; }
    await kvSet('ac_all_users', all);
    return new Response(JSON.stringify({ ok: true }), { headers: cors });
  }

  if (action === 'dm_send') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: cors });
    const from = bod.from || q.from, fromId = bod.fromId || q.fromId, toId = bod.toId || q.toId, text = bod.text || q.text, ts = Number(bod.ts || q.ts || Date.now());
    if (!from || !fromId || !toId || !text) return new Response(JSON.stringify({ ok: false, error: 'Missing fields' }), { status: 400, headers: cors });
    const inbox = (await kvGet(`ac_dm_inbox_${toId}`)) || [];
    inbox.push({ from, fromId, text, ts });
    await kvSet(`ac_dm_inbox_${toId}`, inbox);
    return new Response(JSON.stringify({ ok: true }), { headers: cors });
  }

  if (action === 'dm_poll') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: cors });
    const toId = q.toId || bod.toId;
    if (!toId) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: cors });
    const inbox = (await kvGet(`ac_dm_inbox_${toId}`)) || [];
    const typing = (await kvGet(`ac_dm_typing_${toId}`)) || [];
    const now = Date.now();
    return new Response(JSON.stringify({ ok: true, messages: inbox, typing: typing.filter(t => now - t.ts < 5000) }), { headers: cors });
  }

  if (action === 'gc_send') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: cors });
    const from = bod.from || q.from, fromId = bod.fromId || q.fromId, text = bod.text || q.text, ts = Number(bod.ts || q.ts || Date.now());
    if (!from || !text) return new Response(JSON.stringify({ ok: false, error: 'Missing fields' }), { status: 400, headers: cors });
    const msgs = (await kvGet('ac_global_chat')) || [];
    msgs.push({ from, fromId, text, ts });
    if (msgs.length > GC_MAX) msgs.splice(0, msgs.length - GC_MAX);
    await kvSet('ac_global_chat', msgs);
    return new Response(JSON.stringify({ ok: true }), { headers: cors });
  }

  if (action === 'gc_poll') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: cors });
    const since = Number(q.since || 0);
    const msgs = (await kvGet('ac_global_chat')) || [];
    const gcTyping = (await kvGet('ac_gc_typing')) || [];
    const gcNow = Date.now();
    return new Response(JSON.stringify({
      ok: true,
      messages: msgs.filter(m => m.ts > since),
      typing: gcTyping.filter(t => gcNow - t.ts < 5000)
    }), { headers: cors });
  }

  if (action === 'dm_typing') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false }), { status: 403, headers: cors });
    const from = q.from, fromId = q.fromId, toId = q.toId;
    if (!from || !fromId || !toId) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: cors });
    const typing = (await kvGet(`ac_dm_typing_${toId}`)) || [];
    const now = Date.now();
    const filtered = typing.filter(t => t.fromId !== fromId && now - t.ts < 5000);
    filtered.push({ from, fromId, ts: now });
    await kvSet(`ac_dm_typing_${toId}`, filtered);
    return new Response(JSON.stringify({ ok: true }), { headers: cors });
  }

  if (action === 'gc_typing') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false }), { status: 403, headers: cors });
    const from = q.from || bod.from, fromId = q.fromId || bod.fromId;
    if (!from) return new Response(JSON.stringify({ ok: false }), { status: 400, headers: cors });
    const typing = (await kvGet('ac_gc_typing')) || [];
    const now = Date.now();
    const filtered = typing.filter(t => t.fromId !== fromId && now - t.ts < 5000);
    filtered.push({ from, fromId, ts: now });
    await kvSet('ac_gc_typing', filtered);
    return new Response(JSON.stringify({ ok: true }), { headers: cors });
  }

  if (action === 'check') {
    if (secret !== EXEC_SECRET) return new Response(JSON.stringify({ ok: false, error: 'Invalid secret' }), { status: 403, headers: cors });
    const username = q.user;
    const [bans, wl] = await Promise.all([kvGet('ac_banned'), kvGet('ac_whitelist')]);
    return new Response(JSON.stringify({ ok: true, banned: (bans || []).includes(username), whitelisted: (wl || []).includes(username) }), { headers: cors });
  }

  // Admin routes
  const auth = q.auth || bod.auth;
  if (auth !== ADMIN_PASS) return new Response(JSON.stringify({ ok: false, error: 'Unauthorized' }), { status: 401, headers: cors });

  if (request.method === 'GET') {
    const [bans, wl, execMap, allUsers] = await Promise.all([kvGet('ac_banned'), kvGet('ac_whitelist'), kvGet('ac_executing'), kvGet('ac_all_users')]);
    const now = Date.now();
    return new Response(JSON.stringify({
      ok: true, banned: bans || [], whitelist: wl || [],
      executing: Object.entries(execMap || {}).filter(([, t]) => now - t < EXEC_TTL * 1000).map(([u]) => u),
      allUsers: allUsers || {}
    }), { headers: cors });
  }

  if (request.method === 'POST') {
    const { action: a, username: u } = bod;
    if (!u) return new Response(JSON.stringify({ ok: false, error: 'username required' }), { status: 400, headers: cors });
    if (a === 'ban_add') { const bans = (await kvGet('ac_banned')) || []; if (!bans.includes(u)) bans.push(u); await kvSet('ac_banned', bans); const m = (await kvGet('ac_executing')) || {}; delete m[u]; await kvSet('ac_executing', m); return new Response(JSON.stringify({ ok: true, banned: bans }), { headers: cors }); }
    if (a === 'ban_remove') { const bans = ((await kvGet('ac_banned')) || []).filter(x => x !== u); await kvSet('ac_banned', bans); return new Response(JSON.stringify({ ok: true, banned: bans }), { headers: cors }); }
    if (a === 'whitelist_add') { const wl = (await kvGet('ac_whitelist')) || []; if (!wl.includes(u)) wl.push(u); await kvSet('ac_whitelist', wl); return new Response(JSON.stringify({ ok: true, whitelist: wl }), { headers: cors }); }
    if (a === 'whitelist_remove') { const wl = ((await kvGet('ac_whitelist')) || []).filter(x => x !== u); await kvSet('ac_whitelist', wl); return new Response(JSON.stringify({ ok: true, whitelist: wl }), { headers: cors }); }
    return new Response(JSON.stringify({ ok: false, error: 'Unknown action' }), { status: 400, headers: cors });
  }

  return new Response(JSON.stringify({ ok: false, error: 'Method not allowed' }), { status: 405, headers: cors });
}
