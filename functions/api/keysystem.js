// functions/api/keysystem.js
// Uses Cloudflare KV (AC_KV binding) — no Upstash needed

const KEY_PREFIX = 'AudioCrafter-';
const KEY_TTL_SEC = 14 * 60 * 60;   // 14 hours
const TOKEN_TTL_SEC = 10 * 60;       // 10 minutes to use token

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

  const KV = env.AC_KV;

  function generateKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let result = KEY_PREFIX;
    for (let i = 0; i < 14; i++) {
      result += chars[Math.floor(Math.random() * chars.length)];
    }
    return result;
  }

  const action = url.searchParams.get('action');

  // ── Generate a one-time token (called by redirect.html after Linkvertise) ────
  if (action === 'gentoken') {
    const secret = url.searchParams.get('secret');
    if (secret !== env.AC_EXEC_SECRET) {
      return new Response(JSON.stringify({ ok: false, error: 'Forbidden' }), { status: 403, headers: cors });
    }
    const token = crypto.randomUUID().replace(/-/g, '');
    await KV.put('token_' + token, JSON.stringify({ used: false, createdAt: Date.now() }), { expirationTtl: TOKEN_TTL_SEC });
    return new Response(JSON.stringify({ ok: true, token }), { headers: cors });
  }

  // ── Get a key using a valid token (called by key.html) ───────────────────────
  if (action === 'getkey') {
    const token = url.searchParams.get('token');
    if (!token) {
      return new Response(JSON.stringify({ ok: false, error: 'No token' }), { status: 400, headers: cors });
    }

    const raw = await KV.get('token_' + token);
    if (!raw) {
      return new Response(JSON.stringify({ ok: false, error: 'Invalid or expired token' }), { status: 403, headers: cors });
    }

    const tokenData = JSON.parse(raw);
    if (tokenData.used) {
      return new Response(JSON.stringify({ ok: false, error: 'Token already used' }), { status: 403, headers: cors });
    }

    // Mark token as used immediately
    await KV.put('token_' + token, JSON.stringify({ used: true }), { expirationTtl: 60 });

    // Generate and store the key
    const key = generateKey();
    const expiresAt = Date.now() + (KEY_TTL_SEC * 1000);
    await KV.put('key_' + key, JSON.stringify({ valid: true, expiresAt }), { expirationTtl: KEY_TTL_SEC });

    return new Response(JSON.stringify({ ok: true, key, expiresAt }), { headers: cors });
  }

  // ── Validate a key (called by your Lua script) ───────────────────────────────
  if (action === 'validate') {
    const key = url.searchParams.get('key');
    if (!key) {
      return new Response(JSON.stringify({ ok: false, valid: false }), { status: 400, headers: cors });
    }

    const raw = await KV.get('key_' + key);
    if (!raw) {
      return new Response(JSON.stringify({ ok: true, valid: false, reason: 'Invalid key' }), { headers: cors });
    }

    const keyData = JSON.parse(raw);
    if (Date.now() > keyData.expiresAt) {
      await KV.delete('key_' + key);
      return new Response(JSON.stringify({ ok: true, valid: false, reason: 'Expired' }), { headers: cors });
    }

    return new Response(JSON.stringify({ ok: true, valid: true, expiresAt: keyData.expiresAt }), { headers: cors });
  }

  return new Response(JSON.stringify({ ok: false, error: 'Unknown action' }), { status: 400, headers: cors });
}
