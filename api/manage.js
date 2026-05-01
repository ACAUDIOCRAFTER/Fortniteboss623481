// api/manage.js — AC AudioCrafter ban/whitelist/admin management

export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    if (req.method === 'OPTIONS') return res.status(200).end();

    const url   = process.env.KV_REST_API_URL;
    const token = process.env.KV_REST_API_TOKEN;
    if (!url || !token) return res.status(500).json({ error: 'KV not configured' });

    const ADMIN_PASS = process.env.AC_ADMIN_PASS || 'ACMelodyScoper';
    const hdrs = { Authorization: 'Bearer ' + token };

    async function getList(key) {
        try {
            const r = await fetch(`${url}/get/${key}`, { headers: hdrs });
            const d = await r.json();
            return d.result ? JSON.parse(d.result) : [];
        } catch { return []; }
    }
    async function setList(key, data) {
        const encoded = encodeURIComponent(JSON.stringify(data));
        await fetch(`${url}/set/${key}/${encoded}`, { method: 'POST', headers: hdrs });
    }

    // ── GET: script checks if user is banned/whitelisted
    if (req.method === 'GET') {
        if (req.query.action === 'check') {
            const user = req.query.user;
            if (!user) return res.status(400).json({ ok: false });
            const [banned, whitelisted, admins] = await Promise.all([
                getList('ac_banned'),
                getList('ac_whitelist'),
                getList('ac_admins')
            ]);
            return res.status(200).json({
                ok: true,
                banned:      banned.includes(user),
                whitelisted: whitelisted.includes(user),
                isAdmin:     admins.includes(user)
            });
        }
        // Admin panel — get all lists
        const auth = req.query.auth;
        if (auth !== ADMIN_PASS) return res.status(401).json({ ok: false, error: 'Wrong password' });
        const [banned, whitelist, admins, executing] = await Promise.all([
            getList('ac_banned'),
            getList('ac_whitelist'),
            getList('ac_admins'),
            getList('ac_executing')
        ]);
        return res.status(200).json({ ok: true, banned, whitelist, admins, executing });
    }

    // ── POST: admin actions
    if (req.method === 'POST') {
        // Script reports itself as executing
        if (req.query.action === 'exec') {
            const user = req.query.user;
            if (user) {
                const executing = await getList('ac_executing');
                if (!executing.includes(user)) { executing.push(user); await setList('ac_executing', executing); }
                // TTL via separate key
                await fetch(`${url}/set/ac_exec_ttl_${encodeURIComponent(user)}/1`, { method: 'POST', headers: hdrs });
                await fetch(`${url}/expire/ac_exec_ttl_${encodeURIComponent(user)}/30`, { headers: hdrs });
            }
            return res.status(200).json({ ok: true });
        }

        let body = req.body;
        if (typeof body === 'string') { try { body = JSON.parse(body); } catch { return res.status(400).json({ ok: false }); } }
        const { auth, action, username } = body || {};
        if (auth !== ADMIN_PASS) return res.status(401).json({ ok: false, error: 'Wrong password' });
        if (!username) return res.status(400).json({ ok: false, error: 'username required' });

        const listKey = action.startsWith('ban') ? 'ac_banned' : action.startsWith('whitelist') ? 'ac_whitelist' : action.startsWith('admin') ? 'ac_admins' : null;
        if (!listKey) return res.status(400).json({ ok: false, error: 'Unknown action' });

        const list = await getList(listKey);
        if (action.endsWith('_add')) {
            if (!list.includes(username)) { list.push(username); await setList(listKey, list); }
        } else if (action.endsWith('_remove')) {
            const idx = list.indexOf(username);
            if (idx !== -1) { list.splice(idx, 1); await setList(listKey, list); }
        }
        // Return all lists
        const [banned, whitelist, admins] = await Promise.all([getList('ac_banned'), getList('ac_whitelist'), getList('ac_admins')]);
        return res.status(200).json({ ok: true, banned, whitelist, admins });
    }
    return res.status(405).json({ ok: false });
}
