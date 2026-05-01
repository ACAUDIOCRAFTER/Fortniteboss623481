export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    if (req.method === 'OPTIONS') return res.status(200).end();
    const url   = process.env.KV_REST_API_URL;
    const token = process.env.KV_REST_API_TOKEN;
    if (!url || !token) return res.status(500).json({ error: 'KV not configured' });
    const ADMIN_PASS = process.env.AC_ADMIN_PASS || 'melody2024';
    const headers    = { Authorization: 'Bearer ' + token };
    const KV_KEY     = 'ac_custom_users';
    async function getUsers() {
        try {
            const r = await fetch(`${url}/get/${KV_KEY}`, { headers });
            const d = await r.json();
            return d.result ? JSON.parse(d.result) : {};
        } catch { return {}; }
    }
    async function setUsers(data) {
        await fetch(`${url}/set/${KV_KEY}`, {
            method: 'POST',
            headers: { ...headers, 'Content-Type': 'application/json' },
            body: JSON.stringify({ value: JSON.stringify(data) })
        });
    }
    if (req.method === 'GET') {
        const auth = req.query.auth;
        if (auth !== undefined && auth !== ADMIN_PASS) {
            return res.status(401).json({ ok: false, error: 'Wrong password' });
        }
        const users = await getUsers();
        return res.status(200).json({ ok: true, users });
    }
    if (req.method === 'POST') {
        let body = req.body;
        if (typeof body === 'string') {
            try { body = JSON.parse(body); } catch {
                return res.status(400).json({ ok: false, error: 'Bad JSON' });
            }
        }
        const { auth, action, username, tag, pfpId, bgId } = body || {};
        if (auth !== ADMIN_PASS) return res.status(401).json({ ok: false, error: 'Wrong password' });
        if (!username) return res.status(400).json({ ok: false, error: 'username required' });
        const users = await getUsers();
        if (action === 'set') {
            if (!tag) return res.status(400).json({ ok: false, error: 'tag required' });
            users[username] = { tag: tag.trim(), pfpId: (pfpId||'').trim(), bgId: (bgId||'').trim() };
            await setUsers(users);
            return res.status(200).json({ ok: true, users });
        }
        if (action === 'delete') {
            delete users[username];
            await setUsers(users);
            return res.status(200).json({ ok: true, users });
        }
        return res.status(400).json({ ok: false, error: 'Unknown action' });
    }
    return res.status(405).json({ ok: false, error: 'Method not allowed' });
}
