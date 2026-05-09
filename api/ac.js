export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);

  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (request.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  const key = url.searchParams.get('key');
  if (!key || key !== env.AC_SECRET_KEY) {
    return new Response('Forbidden', { status: 403, headers: corsHeaders });
  }

  // Fetch the lua script from GitHub raw
  const scriptUrl = 'https://raw.githubusercontent.com/ACAUDIOCRAFTER/AUDIO-CRAFTER/main/private/ac.lua';
  try {
    const res = await fetch(scriptUrl);
    const text = await res.text();
    return new Response(text, {
      status: 200,
      headers: {
        ...corsHeaders,
        'Content-Type': 'text/plain',
        'Cache-Control': 'no-store',
      },
    });
  } catch (err) {
    return new Response('Error fetching script', { status: 500, headers: corsHeaders });
  }
}
