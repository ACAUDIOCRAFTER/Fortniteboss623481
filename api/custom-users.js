// api/custom-users.js — AC AudioCrafter Tag Manager

export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    if (req.method === 'OPTIONS') return res.status(200).end();

    const url   = process.env.KV_REST_API_URL;
    const token = process.env.KV_REST_API_TOKEN;
    if (!url || !token) return res.status(500).json({ error: 'KV not configured' });

    const ADMIN_PASS = process.env.AC_ADMIN_PASS;
    if (!ADMIN_PASS) return res.status(500).json({ error: 'AC_ADMIN_PASS env var not set' });
    const hdrs = { Authorization: 'Bearer ' + token };
    const KEY  = 'ac_custom_users';

    // ── Read from KV ─────────────────────────────────────────────────────────
    async function getUsers() {
        try {
            const r = await fetch(`${url}/get/${KEY}`, { headers: hdrs });
            const d = await r.json();
            if (!d.result) return {};
            return JSON.parse(d.result);
        } catch { return {}; }
    }

    // ── Write to KV ───────────────────────────────────────────────────────────
    async function setUsers(data) {
        const encoded = encodeURIComponent(JSON.stringify(data));
        await fetch(`${url}/set/${KEY}/${encoded}`, {
            method: 'POST',
            headers: hdrs
        });
    }

    // ── GET ───────────────────────────────────────────────────────────────────
    if (req.method === 'GET') {
        // Live online users scan
        if (req.query.action === 'online') {
            try {
                const r = await fetch(`${url}/keys/ac_exec_*`, { headers: hdrs });
                const d = await r.json();
                const keys = d.result || [];
                const names = await Promise.all(keys.map(async k => {
                    try {
                        const r2 = await fetch(`${url}/get/${k}`, { headers: hdrs });
                        const d2 = await r2.json();
                        return d2.result || null;
                    } catch { return null; }
                }));
                return res.status(200).json({ ok: true, users: names.filter(Boolean) });
            } catch {
                return res.status(200).json({ ok: true, users: [] });
            }
        }

        // Normal user list — requires auth
        const auth = req.query.auth;
        if (auth !== undefined && auth !== ADMIN_PASS) {
            return res.status(401).json({ ok: false, error: 'Wrong password' });
        }
        const users = await getUsers();
        return res.status(200).json({ ok: true, users });
    }

    // ── POST ──────────────────────────────────────────────────────────────────
    if (req.method === 'POST') {
        // Script presence ping
        if (req.query.action === 'exec') {
            const key  = req.query.key;
            const name = req.query.name;
            if (key && name) {
                try {
                    await fetch(`${url}/set/${key}/${encodeURIComponent(name)}`, {
                        method: 'POST', headers: hdrs
                    });
                    await fetch(`${url}/expire/${key}/30`, { headers: hdrs });
                } catch {}
            }
            return res.status(200).json({ ok: true });
        }

        let body = req.body;
        if (typeof body === 'string') {
            try { body = JSON.parse(body); }
            catch { return res.status(400).json({ ok: false, error: 'Bad JSON' }); }
        }

        const { auth, action, username, tag, pfpId, bgId, effects, animMeta } = body || {};
        if (auth !== ADMIN_PASS) return res.status(401).json({ ok: false, error: 'Wrong password' });
        if (!username) return res.status(400).json({ ok: false, error: 'username required' });

        const users = await getUsers();

        if (action === 'set') {
            if (!tag) return res.status(400).json({ ok: false, error: 'tag required' });

            // ── Build user record — save ALL fields including effects + animMeta ──
            const record = {
                tag:   tag.trim(),
                pfpId: (pfpId || '').trim(),
                bgId:  (bgId  || '').trim(),
            };

            // Save effects (glitched, typewriter, animProfile, animBg, tagEffects, glowColor)
            if (effects && typeof effects === 'object') {
                record.effects = effects;
            }

            // Save animated sprite sheet metadata
            if (animMeta && typeof animMeta === 'object') {
                record.animMeta = animMeta;
            }

            users[username] = record;
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
