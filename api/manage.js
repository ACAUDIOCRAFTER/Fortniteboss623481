// api/manage.js — AC AudioCrafter manage API
export default async function handler(req, res) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');
    if (req.method === 'OPTIONS') return res.status(200).end();

    const url   = process.env.KV_REST_API_URL;
    const token = process.env.KV_REST_API_TOKEN;
    if (!url || !token) return res.status(500).json({ error: 'KV not configured' });

    const ADMIN_PASS  = process.env.AC_ADMIN_PASS;
    const EXEC_SECRET = process.env.AC_EXEC_SECRET;
    const EXEC_TTL    = 45;
    const hdrs        = { Authorization: 'Bearer ' + token };

    if (!ADMIN_PASS)  return res.status(500).json({ error: 'AC_ADMIN_PASS not set' });
    if (!EXEC_SECRET) return res.status(500).json({ error: 'AC_EXEC_SECRET not set' });

    async function kvGet(key) {
        try {
            const r = await fetch(`${url}/get/${key}`, { headers: hdrs });
            const d = await r.json();
            if (!d.result) return null;
            return JSON.parse(d.result);
        } catch { return null; }
    }

    async function kvSet(key, value) {
        const encoded = encodeURIComponent(JSON.stringify(value));
        await fetch(`${url}/set/${key}/${encoded}`, { method: 'POST', headers: hdrs });
    }

    async function getBans()      { return (await kvGet('ac_banned'))     || []; }
    async function getWl()        { return (await kvGet('ac_whitelist'))  || []; }
    async function getExecMap()   { return (await kvGet('ac_executing'))  || {}; }
    async function getAllUsers()   { return (await kvGet('ac_all_users'))  || {}; }
    async function setExecMap(m)  { await kvSet('ac_executing', m); }
    async function setAllUsers(m) { await kvSet('ac_all_users', m); }

    function liveUsers(map) {
        const now = Date.now();
        return Object.entries(map)
            .filter(([, t]) => now - t < EXEC_TTL * 1000)
            .map(([u]) => u);
    }

    // ── Exec ping — accepts GET and POST so game:HttpGet works as fallback ────
    if (req.query.action === 'exec') {
        if (req.query.secret !== EXEC_SECRET)
            return res.status(403).json({ ok: false, error: 'Invalid secret' });

        const username    = req.query.user;
        const userId      = req.query.uid   || '';
        const displayName = req.query.dn    || username;
        if (!username) return res.status(400).json({ ok: false });

        const now = Date.now();

        // Update live exec map
        const map = await getExecMap();
        map[username] = now;
        for (const [u, t] of Object.entries(map))
            if (now - t >= EXEC_TTL * 1000) delete map[u];
        await setExecMap(map);

        // Update persistent all-time user record
        const allUsers = await getAllUsers();
        if (!allUsers[username]) {
            allUsers[username] = { userId, displayName, firstSeen: now, lastSeen: now };
        } else {
            allUsers[username].lastSeen = now;
            if (userId)      allUsers[username].userId      = userId;
            if (displayName) allUsers[username].displayName = displayName;
        }
        await setAllUsers(allUsers);

        return res.status(200).json({ ok: true });
    }

    // ── Ban/whitelist check ───────────────────────────────────────────────────
    if (req.method === 'GET' && req.query.action === 'check') {
        if (req.query.secret !== EXEC_SECRET)
            return res.status(403).json({ ok: false, error: 'Invalid secret' });

        const username = req.query.user;
        if (!username) return res.status(400).json({ ok: false });

        const [bans, wl] = await Promise.all([getBans(), getWl()]);
        return res.status(200).json({
            ok:          true,
            banned:      bans.includes(username),
            whitelisted: wl.includes(username),
        });
    }

    // ── Admin routes ──────────────────────────────────────────────────────────
    const auth = req.query.auth || (req.body && req.body.auth);
    if (auth !== ADMIN_PASS)
        return res.status(401).json({ ok: false, error: 'Unauthorized' });

    if (req.method === 'GET') {
        const [bans, wl, execMap, allUsers] = await Promise.all([
            getBans(), getWl(), getExecMap(), getAllUsers()
        ]);
        return res.status(200).json({
            ok:        true,
            banned:    bans,
            whitelist: wl,
            executing: liveUsers(execMap),
            allUsers,               // persistent list for Script Users page
        });
    }

    if (req.method === 'POST') {
        let body = req.body || {};
        if (typeof body === 'string') {
            try { body = JSON.parse(body); } catch {
                return res.status(400).json({ ok: false, error: 'Bad JSON' });
            }
        }
        const { action, username } = body;
        if (!username) return res.status(400).json({ ok: false, error: 'username required' });

        if (action === 'ban_add') {
            const bans = await getBans();
            if (!bans.includes(username)) bans.push(username);
            await kvSet('ac_banned', bans);
            const map = await getExecMap();
            delete map[username];
            await setExecMap(map);
            return res.status(200).json({ ok: true, banned: bans });
        }
        if (action === 'ban_remove') {
            const bans = (await getBans()).filter(u => u !== username);
            await kvSet('ac_banned', bans);
            return res.status(200).json({ ok: true, banned: bans });
        }
        if (action === 'whitelist_add') {
            const wl = await getWl();
            if (!wl.includes(username)) wl.push(username);
            await kvSet('ac_whitelist', wl);
            return res.status(200).json({ ok: true, whitelist: wl });
        }
        if (action === 'whitelist_remove') {
            const wl = (await getWl()).filter(u => u !== username);
            await kvSet('ac_whitelist', wl);
            return res.status(200).json({ ok: true, whitelist: wl });
        }
        return res.status(400).json({ ok: false, error: 'Unknown action: ' + action });
    }

    return res.status(405).json({ ok: false, error: 'Method not allowed' });
}
