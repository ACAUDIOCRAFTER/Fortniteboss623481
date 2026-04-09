export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    const { action, job, user } = req.query;
    if (!job) return res.status(400).json([]);
    const url   = process.env.KV_REST_API_URL;
    const token = process.env.KV_REST_API_TOKEN;
    if (!url || !token) return res.status(500).json({ error: 'misconfigured' });
    const SECRET = process.env.AC_SECRET;
    if (SECRET && req.query.auth !== SECRET) return res.status(403).json({ error: 'Forbidden' });
    const key = 'ac2:' + job;
    const headers = { Authorization: 'Bearer ' + token };
    try {
        if (action === 'join' && user) {
            await fetch(`${url}/sadd/${key}/${encodeURIComponent(user)}`, { headers });
            await fetch(`${url}/expire/${key}/8`, { headers });
            return res.json({ ok: true });
        }
        if (action === 'list') {
            const r = await fetch(`${url}/smembers/${key}`, { headers });
            const data = await r.json();
            return res.json(data.result || []);
        }
        if (action === 'leave' && user) {
            await fetch(`${url}/srem/${key}/${encodeURIComponent(user)}`, { headers });
            return res.json({ ok: true });
        }
    } catch(e) { return res.status(500).json({ error: e.message }); }
    return res.status(400).json([]);
}
