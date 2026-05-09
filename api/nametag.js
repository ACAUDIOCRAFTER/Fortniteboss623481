export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);

  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': '*',
  };

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  const SECRET = env.ROBLOX_SECRET;
  const GITHUB_TOKEN = env.GITHUB_TOKEN;
  const OWNER = 'ACAUDIOCRAFTER';
  const REPO  = 'AUDIO-CRAFTER';
  const PATH  = 'userdata.json';

  const clientSecret = request.headers.get('x-secret') || request.headers.get('X-Secret') || url.searchParams.get('secret');
  if (!clientSecret || clientSecret !== SECRET) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401, headers: corsHeaders });
  }

  const ghHeaders = {
    Authorization: `Bearer ${GITHUB_TOKEN}`,
    Accept: 'application/vnd.github+json',
  };

  async function getFile() {
    try {
      const r = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/contents/${PATH}`, { headers: ghHeaders });
      if (r.status === 404) return { content: {}, sha: null };
      const data = await r.json();
      const content = JSON.parse(atob(data.content.replace(/\n/g, '')));
      return { content, sha: data.sha };
    } catch (err) {
      return { content: {}, sha: null };
    }
  }

  async function saveFile(content, sha) {
    const params = {
      message: 'Update userdata',
      content: btoa(JSON.stringify(content, null, 2)),
    };
    if (sha) params.sha = sha;
    await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/contents/${PATH}`, {
      method: 'PUT',
      headers: { ...ghHeaders, 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    });
  }

  if (request.method === 'GET') {
    const userId = url.searchParams.get('userId');
    const { content } = await getFile();
    if (!userId) return new Response(JSON.stringify({ nametags: content }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    return new Response(JSON.stringify({ nametag: content[userId] || null }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  if (request.method === 'POST') {
    let body = {};
    try { body = await request.json(); } catch {}

    const { userId, displayName, tag, executed, forceTag, pfpId: pfpIdRaw, bgId: bgIdRaw, pfp: pfpLegacy, bg: bgLegacy, glowColor, effects, animMeta } = body || {};
    if (!userId) return new Response(JSON.stringify({ error: 'Missing userId' }), { status: 400, headers: corsHeaders });

    const { content, sha } = await getFile();
    const existing = content[userId] || {};

    const newExecuted    = executed !== undefined ? executed : (existing.executed || false);
    const newTag         = (forceTag && tag) ? tag : (existing.tag || tag || 'AC USER');
    const newDisplayName = existing.displayName || displayName || userId;
    const incomingPfpId  = pfpIdRaw !== undefined ? pfpIdRaw : (pfpLegacy !== undefined ? pfpLegacy : undefined);
    const incomingBgId   = bgIdRaw  !== undefined ? bgIdRaw  : (bgLegacy  !== undefined ? bgLegacy  : undefined);
    const newPfpId       = incomingPfpId !== undefined ? incomingPfpId : (existing.pfpId || existing.pfp || null);
    const newBgId        = incomingBgId  !== undefined ? incomingBgId  : (existing.bgId  || existing.bg  || null);
    const newGlowColor   = glowColor !== undefined ? glowColor : (existing.glowColor || null);
    const newEffects     = effects   !== undefined ? effects   : (existing.effects   || null);
    const newAnimMeta    = animMeta  !== undefined ? animMeta  : (existing.animMeta  || null);

    const nothingChanged = existing
      && existing.executed    === newExecuted
      && existing.tag         === newTag
      && existing.displayName === newDisplayName
      && existing.pfpId       === newPfpId
      && existing.bgId        === newBgId
      && existing.glowColor   === newGlowColor;

    if (nothingChanged) {
      return new Response(JSON.stringify({ ok: true, skipped: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
    }

    content[userId] = {
      displayName: newDisplayName,
      tag: newTag,
      executed: newExecuted,
      pfpId: newPfpId,
      bgId: newBgId,
      glowColor: newGlowColor,
      effects: newEffects,
      animMeta: newAnimMeta,
      updatedAt: new Date().toISOString()
    };

    await saveFile(content, sha);
    return new Response(JSON.stringify({ ok: true }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  }

  return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405, headers: corsHeaders });
}
