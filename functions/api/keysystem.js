// functions/api/keysystem.js
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

  // Check if KV is available
  if (!env.AC_KV) {
    return new Response(
      JSON.stringify({ 
        ok: false, 
        error: 'KV namespace not configured'
      }), 
      { status: 500, headers: cors }
    );
  }

  const KV = env.AC_KV;
  const action = url.searchParams.get('action');

  // Validate action first
  if (!action || !['gentoken', 'getkey', 'validate'].includes(action)) {
    return new Response(
      JSON.stringify({ ok: false, error: 'Invalid or missing action' }), 
      { status: 400, headers: cors }
    );
  }

  // Rate limiting - ONLY for valid actions
  const clientIP = request.headers.get('CF-Connecting-IP') || 'unknown';
  const now = Date.now();
  
  const RATE_LIMITS = {
    gentoken: { limit: 3, window: 600000 },      // 3 per 10 minutes
    getkey: { limit: 5, window: 600000 },        // 5 per 10 minutes
    validate: { limit: 20, window: 3600000 }     // 20 per hour
  };

  try {
    const rateLimitKey = `ratelimit:${action}:${clientIP}`;
    const rateLimitRaw = await KV.get(rateLimitKey);
    
    let rateLimitData = rateLimitRaw 
      ? JSON.parse(rateLimitRaw) 
      : { count: 0, resetAt: now + RATE_LIMITS[action].window };

    // Reset if window expired
    if (now > rateLimitData.resetAt) {
      rateLimitData = { count: 0, resetAt: now + RATE_LIMITS[action].window };
    }

    // Check limit
    if (rateLimitData.count >= RATE_LIMITS[action].limit) {
      const retryAfter = Math.ceil((rateLimitData.resetAt - now) / 1000);
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: 'Rate limit exceeded',
          retry_after_seconds: retryAfter 
        }),
        { 
          status: 429, 
          headers: { 
            ...cors, 
            'Retry-After': retryAfter.toString() 
          } 
        }
      );
    }

    // Increment and save
    rateLimitData.count++;
    await KV.put(rateLimitKey, JSON.stringify(rateLimitData), {
      expirationTtl: Math.ceil((rateLimitData.resetAt - now) / 1000)
    });
  } catch (error) {
    // If rate limiting fails, log but continue (don't break the whole system)
    console.error('Rate limit error:', error);
  }

  function generateKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    let result = 'AudioCrafter-';
    for (let i = 0; i < 14; i++) {
      result += chars[Math.floor(Math.random() * chars.length)];
    }
    return result;
  }

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
        JSON.stringify({ used: false, createdAt: now }), 
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
          error: 'Failed to generate token',
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
        JSON.stringify({ ok: false, error: 'No token provided' }), 
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

      // Mark token as used
      await KV.put(
        'token_' + token, 
        JSON.stringify({ used: true }), 
        { expirationTtl: 60 }
      );

      // Generate key
      const key = generateKey();
      const expiresAt = now + (14 * 60 * 60 * 1000);
      
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
          error: 'Failed to process token',
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
        JSON.stringify({ ok: false, valid: false, reason: 'No key provided' }), 
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
      
      if (now > keyData.expiresAt) {
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
          valid: false,
          error: 'Validation failed',
          debug: error.message 
        }), 
        { status: 500, headers: cors }
      );
    }
  }
}

