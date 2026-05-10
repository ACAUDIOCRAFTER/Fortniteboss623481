// functions/api/spdown.js
const SD_BASE = "https://api.spotifydown.com";
const SD_HEADERS = {
  "origin": "https://spotifydown.com",
  "referer": "https://spotifydown.com/",
  "sec-fetch-site": "same-site",
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
};

async function resolveTrackUrl(trackId) {
  const res = await fetch(`${SD_BASE}/download/${trackId}`, { headers: SD_HEADERS });
  if (!res.ok) return null;
  const data = await res.json();
  return data.link || data.downloadLink || null;
}

export async function onRequest(context) {
  const { request } = context;

  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Content-Type': 'application/json',
    'Cache-Control': 'no-store',
  };

  if (request.method === 'OPTIONS') return new Response(null, { headers: cors });

  const url = new URL(request.url);
  const type = url.searchParams.get('type') || 'track';
  const id = url.searchParams.get('id');

  if (!id) {
    return new Response(JSON.stringify({ error: 'missing id' }), { status: 400, headers: cors });
  }

  try {
    const tracks = [];

    if (type === 'track') {
      const dlUrl = await resolveTrackUrl(id);
      if (dlUrl) {
        const meta = await fetch(`${SD_BASE}/track/${id}`, { headers: SD_HEADERS });
        const metaData = meta.ok ? await meta.json() : {};
        tracks.push({
          url: dlUrl,
          title: metaData.title || metaData.name || 'Track',
          artist: metaData.artists || metaData.artist || '',
          art: metaData.cover || metaData.image || '',
        });
      }
    } else {
      const listRes = await fetch(`${SD_BASE}/${type}/${id}`, { headers: SD_HEADERS });
      if (!listRes.ok) throw new Error('Failed to fetch track list');
      const listData = await listRes.json();
      const trackList = listData.trackList || listData.tracks || [];
      const limited = trackList.slice(0, 50);
      const resolved = await Promise.allSettled(
        limited.map(async (track) => {
          const tid = track.id || track.spotifyId;
          if (!tid) return null;
          const dlUrl = await resolveTrackUrl(tid);
          if (!dlUrl) return null;
          return {
            url: dlUrl,
            title: track.title || track.name || 'Track',
            artist: track.artists || track.artist || '',
            art: track.cover || track.image || '',
          };
        })
      );
      for (const r of resolved) {
        if (r.status === 'fulfilled' && r.value) tracks.push(r.value);
      }
    }

    return new Response(JSON.stringify({ tracks }), { status: 200, headers: cors });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message, tracks: [] }), { status: 500, headers: cors });
  }
}
