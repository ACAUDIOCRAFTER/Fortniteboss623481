// functions/api/upload-gif.js
const OWNER = "ACAUDIOCRAFTER";
const REPO = "Fortniteboss623481";
const BRANCH = "main";
const GIFS_FOLDER = "dm_gifs";
const LIST_PATH = `${GIFS_FOLDER}/list.json`;

export async function onRequest(context) {
  const { request, env } = context;

  const cors = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };

  if (request.method === 'OPTIONS') return new Response(null, { headers: cors });
  if (request.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405, headers: cors });
  }

  const GITHUB_TOKEN = env.GITHUB_TOKEN;
  const ghHeaders = {
    Authorization: `Bearer ${GITHUB_TOKEN}`,
    Accept: 'application/vnd.github+json',
    'Content-Type': 'application/json',
  };

  try {
    const formData = await request.formData();
    const file = formData.get('file');
    const label = formData.get('label') || '';

    if (!file) {
      return new Response(JSON.stringify({ error: 'No file uploaded' }), { status: 400, headers: cors });
    }

    const timestamp = Date.now();
    const ext = file.name ? '.' + file.name.split('.').pop() : '.gif';
    const newFilename = `gif_${timestamp}${ext}`;
    const githubPath = `${GIFS_FOLDER}/${newFilename}`;

    // Convert file to base64
    const arrayBuffer = await file.arrayBuffer();
    const bytes = new Uint8Array(arrayBuffer);
    let binary = '';
    for (let i = 0; i < bytes.length; i++) binary += String.fromCharCode(bytes[i]);
    const base64Content = btoa(binary);

    // Upload file to GitHub
    await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/contents/${githubPath}`, {
      method: 'PUT',
      headers: ghHeaders,
      body: JSON.stringify({
        message: `Add GIF: ${newFilename}`,
        content: base64Content,
        branch: BRANCH,
      }),
    });

    const rawUrl = `https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${githubPath}`;

    // Get current list
    let currentList = [];
    let listSha = undefined;
    try {
      const listRes = await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/contents/${LIST_PATH}?ref=${BRANCH}`, { headers: ghHeaders });
      if (listRes.ok) {
        const listData = await listRes.json();
        listSha = listData.sha;
        currentList = JSON.parse(atob(listData.content.replace(/\n/g, '')));
      }
    } catch {}

    currentList.push({ url: rawUrl, thumb: rawUrl, label });

    const updatedContent = btoa(JSON.stringify(currentList, null, 2));
    const listBody = { message: `Add GIF entry: ${newFilename}`, content: updatedContent, branch: BRANCH };
    if (listSha) listBody.sha = listSha;

    await fetch(`https://api.github.com/repos/${OWNER}/${REPO}/contents/${LIST_PATH}`, {
      method: 'PUT',
      headers: ghHeaders,
      body: JSON.stringify(listBody),
    });

    return new Response(JSON.stringify({ success: true, url: rawUrl }), {
      status: 200,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
}
