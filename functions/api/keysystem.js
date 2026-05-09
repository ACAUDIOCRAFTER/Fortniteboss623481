// functions/api/keysystem.js
// Handles: generating keys, validating keys, checking tokens from Linkvertise

const KEY_PREFIX = 'AudioCrafter-';
const KEY_TTL_MS = 14 * 60 * 60 * 1000; // 14 hours
const TOKEN_TTL_MS = 10 * 60 * 1000;     // 10 min to use token after linkvertise

export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);

  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json',
  };

  if (request.method === 'OPTIONS') return new Response(null, { headers: cors });

  const kvUrl   = env.KV_REST_API_URL;
  const kvToken = env.KV_REST_API_TOKEN;
  const hdrs    = { Authorization: 'Bearer ' + kvToken };

  async function kvGet(key) {
    try {
      const r = await fetch(`${kvUrl}/get/${encodeURIComponent(key)}`, { headers: hdrs });
      const d = await r.json();
      return d.result ? JSON.parse(d.result) : null;
    } catch { return null; }
  }

  async function kvSet(key, value, ttlSeconds) {
    const enc = encodeURIComponent(JSON.stringify(value));
    const path = ttlSeconds
      ? `${kvUrl}/setex/${encodeURIComponent(key)}/${ttlSeconds}/${enc}`
      : `${kvUrl}/set/${encodeURIComponent(key)}/${enc}`;
    await fetch(path, { method: 'POST', headers: hdrs });
  }

  async function kvDel(key) {
    await fetch(`${kvUrl}/del/${encodeURIComponent(key)}`, { method: 'POST', headers: hdrs });
  }

  function generateKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let result = KEY_PREFIX;
    for (let i = 0; i < 14; i++) {
      result += chars[Math.floor(Math.random() * chars.length)];
    }
    return result;
  }

  const action = url.searchParams.get('action');

  // ── Generate a one-time token (called by your Linkvertise redirect) ─────────
  if (action === 'gentoken') {
    // Only allow if request comes with exec secret
    const secret = url.searchParams.get('secret');
    if (secret !== env.AC_EXEC_SECRET) {
      return new Response(JSON.stringify({ ok: false, error: 'Forbidden' }), { status: 403, headers: cors });
    }
    const token = crypto.randomUUID().replace(/-/g, '');
    await kvSet('ac_keytoken_' + token, { used: false, createdAt: Date.now() }, Math.floor(TOKEN_TTL_MS / 1000));
    return new Response(JSON.stringify({ ok: true, token }), { headers: cors });
  }

  // ── Get a key using a valid token (called by key.html) ───────────────────────
  if (action === 'getkey') {
    const token = url.searchParams.get('token');
    if (!token) {
      return new Response(JSON.stringify({ ok: false, error: 'No token' }), { status: 400, headers: cors });
    }

    const tokenData = await kvGet('ac_keytoken_' + token);
    if (!tokenData || tokenData.used) {
      return new Response(JSON.stringify({ ok: false, error: 'Invalid or used token' }), { status: 403, headers: cors });
    }

    // Mark token as used
    await kvSet('ac_keytoken_' + token, { used: true }, 60);

    // Generate and store the key
    const key = generateKey();
    const expiresAt = Date.now() + KEY_TTL_MS;
    await kvSet('ac_key_' + key, { valid: true, expiresAt }, Math.floor(KEY_TTL_MS / 1000));

    return new Response(JSON.stringify({ ok: true, key, expiresAt }), { headers: cors });
  }

  // ── Validate a key (called by your Lua script) ───────────────────────────────
  if (action === 'validate') {
    const key = url.searchParams.get('key');
    if (!key) {
      return new Response(JSON.stringify({ ok: false, valid: false }), { status: 400, headers: cors });
    }

    const keyData = await kvGet('ac_key_' + key);
    if (!keyData || !keyData.valid) {
      return new Response(JSON.stringify({ ok: true, valid: false, reason: 'Invalid key' }), { headers: cors });
    }

    if (Date.now() > keyData.expiresAt) {
      await kvDel('ac_key_' + key);
      return new Response(JSON.stringify({ ok: true, valid: false, reason: 'Expired' }), { headers: cors });
    }

    return new Response(JSON.stringify({ ok: true, valid: true, expiresAt: keyData.expiresAt }), { headers: cors });
  }

  return new Response(JSON.stringify({ ok: false, error: 'Unknown action' }), { status: 400, headers: cors });
}
