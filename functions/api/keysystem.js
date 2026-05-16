// functions/api/keysystem.js
// Optimized to reduce KV writes and avoid "KV put() limit exceeded"

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

  // Use the correct binding name from your dashboard
  const KV = env.AC_KV_NEW;

  if (!KV) {
    return new Response(
      JSON.stringify({ 
        ok: false, 
        error: 'KV namespace not configured',
        debug: 'Binding AC_KV_NEW not found'
      }), 
      { status: 500, headers: cors }
    );
  }

  const action = url.searchParams.get('action');

  if (!action || !['gentoken', 'getkey', 'validate'].includes(action)) {
    return new Response(
      JSON.stringify({ ok: false, error: 'Invalid action' }), 
      { status: 400, headers: cors }
    );
  }

  const clientIP = request.headers.get('CF-Connecting-IP') || 'unknown';
  const now = Date.now();

  // ═══════════════════════════════════════════════════════════
  // OPTIMIZED RATE LIMITING
  // To save KV writes, we only rate limit 'gentoken'
  // ═══════════════════════════════════════════════════════════
  
  if (action === 'gentoken') {
    try {
      const rateLimitKey = \`rl:\${clientIP}\`;
      const rateLimitRaw = await KV.get(rateLimitKey);
      
      let rateLimitData = rateLimitRaw 
        ? JSON.parse(rateLimitRaw) 
        : { count: 0, resetAt: now + 600000 }; // 10 min window

      if (now > rateLimitData.resetAt) {
        rateLimitData = { count: 0, resetAt: now + 600000 };
      }

      if (rateLimitData.count >= 5) { // 5 requests per 10 mins
        const retryAfter = Math.ceil((rateLimitData.resetAt - now) / 1000);
        return new Response(
          JSON.stringify({ 
            ok: false, 
            error: 'Rate limit exceeded',
            retry_after: retryAfter 
          }),
          { status: 429, headers: cors }
        );
      }

      rateLimitData.count++;
      await KV.put(rateLimitKey, JSON.stringify(rateLimitData), {
        expirationTtl: 600
      });
    } catch (error) {
      // Ignore rate limit errors to keep service running
    }
  }

  // ── gentoken ────
  if (action === 'gentoken') {
    const secret = url.searchParams.get('secret');
    const expectedSecret = env.KEYSYSTEM_SECRET || 'carf1x66_22';
    
    if (secret !== expectedSecret) {
      return new Response(JSON.stringify({ ok: false, error: 'Forbidden' }), { status: 403, headers: cors });
    }

    try {
      const token = crypto.randomUUID().replace(/-/g, '');
      await KV.put('token_' + token, 'unused', { expirationTtl: 600 });
      return new Response(JSON.stringify({ ok: true, token }), { headers: cors });
    } catch (error) {
      return new Response(JSON.stringify({ ok: false, error: 'KV Error', debug: error.message }), { status: 500, headers: cors });
    }
  }

  // ── getkey ────
  if (action === 'getkey') {
    const token = url.searchParams.get('token');
    if (!token) return new Response(JSON.stringify({ ok: false, error: 'No token' }), { status: 400, headers: cors });

    try {
      const status = await KV.get('token_' + token);
      if (status !== 'unused') return new Response(JSON.stringify({ ok: false, error: 'Invalid token' }), { status: 403, headers: cors });

      // Mark used and create key
      await KV.put('token_' + token, 'used', { expirationTtl: 60 });
      
      const key = 'AudioCrafter-' + crypto.randomUUID().split('-')[0] + crypto.randomUUID().split('-')[1];
      const expiresAt = now + (24 * 60 * 60 * 1000);
      
      await KV.put('key_' + key, expiresAt.toString(), { expirationTtl: 86400 });

      return new Response(JSON.stringify({ ok: true, key, expiresAt }), { headers: cors });
    } catch (error) {
      return new Response(JSON.stringify({ ok: false, error: 'KV Error', debug: error.message }), { status: 500, headers: cors });
    }
  }

  // ── validate (Read-only, 0 writes) ────
  if (action === 'validate') {
    const key = url.searchParams.get('key');
    if (!key) return new Response(JSON.stringify({ ok: false, valid: false }), { status: 400, headers: cors });

    try {
      const expiresAt = await KV.get('key_' + key);
      if (!expiresAt || now > parseInt(expiresAt)) {
        return new Response(JSON.stringify({ ok: true, valid: false }), { headers: cors });
      }
      return new Response(JSON.stringify({ ok: true, valid: true, expiresAt: parseInt(expiresAt) }), { headers: cors });
    } catch (error) {
      return new Response(JSON.stringify({ ok: false, valid: false }), { status: 500, headers: cors });
    }
  }
}
