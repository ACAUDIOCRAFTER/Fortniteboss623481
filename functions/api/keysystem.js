// functions/api/keysystem.js
// Uses Cloudflare KV (AC_KV binding) and environment variable for secret

export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  
  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json',
  };

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: cors });
  }

  // ═══════════════════════════════════════════════════════════
  // MAINTENANCE MODE - ENABLED
  // Remove this block when ready to re-enable the key system
  // ═══════════════════════════════════════════════════════════
  return new Response(
    JSON.stringify({ 
      ok: false, 
      error: 'Key system temporarily offline for maintenance. Please check back in 24 hours.' 
    }), 
    { status: 503, headers: cors }
  );
  // ═══════════════════════════════════════════════════════════

  // DEBUG: Check if KV is available
  if (!env.AC_KV) {
    return new Response(
      JSON.stringify({ 
        ok: false, 
        error: 'KV namespace not configured',
        debug: 'AC_KV binding is missing'
      }), 
      { status: 500, headers: cors }
    );
  }

  const KV = env.AC_KV;
  
  function generateKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let result = 'AudioCrafter-';
    for (let i = 0; i < 14; i++) {
      result += chars[Math.floor(Math.random() * chars.length)];
    }
    return result;
  }

  const action = url.searchParams.get('action');

  // ── Generate a one-time token ────
  if (action === 'gentoken') {
    const secret = url.searchParams.get('secret');
    const expectedSecret = env.KEYSYSTEM_SECRET || 'carf1x66_22';
    
    if (secret !== expectedSecret) {
      return new Response(
        JSON.stringify({ ok: false, error: 'Forbidden' }), 
        { status: 403, headers: cors }
      );
    }

    try {
      const token = crypto.randomUUID().replace(/-/g, '');
      await KV.put(
        'token_' + token, 
        JSON.stringify({ used: false, createdAt: Date.now() }), 
        { expirationTtl: 600 }
      );

      return new Response(
        JSON.stringify({ ok: true, token }), 
        { headers: cors }
      );
    } catch (error) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: 'KV operation failed',
          debug: error.message 
        }), 
        { status: 500, headers: cors }
      );
    }
  }

  // ── Get a key using a valid token ───────────────────────
  if (action === 'getkey') {
    const token = url.searchParams.get('token');
    
    if (!token) {
      return new Response(
        JSON.stringify({ ok: false, error: 'No token' }), 
        { status: 400, headers: cors }
      );
    }

    try {
      const raw = await KV.get('token_' + token);
      
      if (!raw) {
        return new Response(
          JSON.stringify({ ok: false, error: 'Invalid or expired token' }), 
          { status: 403, headers: cors }
        );
      }

      const tokenData = JSON.parse(raw);
      
      if (tokenData.used) {
        return new Response(
          JSON.stringify({ ok: false, error: 'Token already used' }), 
          { status: 403, headers: cors }
        );
      }

      await KV.put(
        'token_' + token, 
        JSON.stringify({ used: true }), 
        { expirationTtl: 60 }
      );

      const key = generateKey();
      const expiresAt = Date.now() + (14 * 60 * 60 * 1000);
      
      await KV.put(
        'key_' + key, 
        JSON.stringify({ valid: true, expiresAt }), 
        { expirationTtl: 14 * 60 * 60 }
      );

      return new Response(
        JSON.stringify({ ok: true, key, expiresAt }), 
        { headers: cors }
      );
    } catch (error) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: 'Operation failed',
          debug: error.message 
        }), 
        { status: 500, headers: cors }
      );
    }
  }

  // ── Validate a key ───────────────────────────────
  if (action === 'validate') {
    const key = url.searchParams.get('key');
    
    if (!key) {
      return new Response(
        JSON.stringify({ ok: false, valid: false }), 
        { status: 400, headers: cors }
      );
    }

    try {
      const raw = await KV.get('key_' + key);
      
      if (!raw) {
        return new Response(
          JSON.stringify({ ok: true, valid: false, reason: 'Invalid key' }), 
          { headers: cors }
        );
      }

      const keyData = JSON.parse(raw);
      
      if (Date.now() > keyData.expiresAt) {
        await KV.delete('key_' + key);
        return new Response(
          JSON.stringify({ ok: true, valid: false, reason: 'Expired' }), 
          { headers: cors }
        );
      }

      return new Response(
        JSON.stringify({ ok: true, valid: true, expiresAt: keyData.expiresAt }), 
        { headers: cors }
      );
    } catch (error) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: 'Validation failed',
          debug: error.message 
        }), 
        { status: 500, headers: cors }
      );
    }
  }

  return new Response(
    JSON.stringify({ ok: false, error: 'Unknown action' }), 
    { status: 400, headers: cors }
  );
}
