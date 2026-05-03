import { Octokit } from "@octokit/rest";
const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const OWNER = "ACAUDIOCRAFTER";
const REPO  = "AUDIO-CRAFTER";
const PATH  = "userdata.json";
const SECRET = process.env.ROBLOX_SECRET;

let memoryCache = null;
let memorySha = null;
let lastGithubWrite = 0;
const WRITE_COOLDOWN = 30000;

async function getFile() {
    if (memoryCache && memorySha) {
        return { content: memoryCache, sha: memorySha };
    }
    try {
        const { data } = await octokit.repos.getContent({ owner: OWNER, repo: REPO, path: PATH });
        const content = JSON.parse(Buffer.from(data.content, "base64").toString());
        memoryCache = content;
        memorySha = data.sha;
        return { content, sha: data.sha };
    } catch (err) {
        if (err.status === 404) return { content: {}, sha: null };
        throw err;
    }
}

async function saveFile(content, sha) {
    const now = Date.now();
    if (now - lastGithubWrite < WRITE_COOLDOWN) {
        memoryCache = content;
        return;
    }
    const params = {
        owner: OWNER, repo: REPO, path: PATH,
        message: "Update userdata",
        content: Buffer.from(JSON.stringify(content, null, 2)).toString("base64"),
    };
    if (sha) params.sha = sha;
    const result = await octokit.repos.createOrUpdateFileContents(params);
    memoryCache = content;
    memorySha = result.data.content.sha;
    lastGithubWrite = now;
}

export default async function handler(req, res) {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "*");
    if (req.method === "OPTIONS") return res.status(200).end();

    try {
        const clientSecret = req.headers["x-secret"]
            || req.headers["X-Secret"]
            || req.query.secret;
        if (!clientSecret || clientSecret !== SECRET) {
            return res.status(401).json({ error: "Unauthorized" });
        }

        const { method } = req;

        if (method === "GET") {
            const { userId } = req.query;
            const { content } = await getFile();
            if (!userId) return res.json({ nametags: content });
            return res.json({ nametag: content[userId] || null });
        }

        if (method === "POST") {
            let body = req.body;
            if (typeof body === "string") { try { body = JSON.parse(body); } catch(e) {} }

            // Accept both pfpId/bgId (from admin.html) and pfp/bg (legacy) so nothing breaks
            const {
                userId, displayName, tag, executed, forceTag,
                pfpId: pfpIdRaw, bgId: bgIdRaw,
                pfp: pfpLegacy, bg: bgLegacy,
                glowColor, effects, animMeta
            } = body || {};

            if (!userId) return res.status(400).json({ error: "Missing userId" });

            const { content, sha } = await getFile();
            const existing = content[userId] || {};

            const newExecuted    = executed    !== undefined ? executed    : (existing.executed    || false);
            const newTag         = (forceTag && tag) ? tag : (existing.tag || tag || "AC USER");
            const newDisplayName = existing.displayName || displayName || userId;

            // Normalize: prefer pfpId/bgId, fall back to pfp/bg (legacy), then existing, then null
            const incomingPfpId = pfpIdRaw !== undefined ? pfpIdRaw : (pfpLegacy !== undefined ? pfpLegacy : undefined);
            const incomingBgId  = bgIdRaw  !== undefined ? bgIdRaw  : (bgLegacy  !== undefined ? bgLegacy  : undefined);

            const newPfpId      = incomingPfpId !== undefined ? incomingPfpId : (existing.pfpId || existing.pfp || null);
            const newBgId       = incomingBgId  !== undefined ? incomingBgId  : (existing.bgId  || existing.bg  || null);
            const newGlowColor  = glowColor  !== undefined ? glowColor  : (existing.glowColor  || null);
            const newEffects    = effects    !== undefined ? effects    : (existing.effects    || null);
            const newAnimMeta   = animMeta   !== undefined ? animMeta   : (existing.animMeta   || null);

            const nothingChanged = existing
                && existing.executed    === newExecuted
                && existing.tag         === newTag
                && existing.displayName === newDisplayName
                && existing.pfpId       === newPfpId
                && existing.bgId        === newBgId
                && existing.glowColor   === newGlowColor;

            if (nothingChanged) {
                return res.json({ ok: true, skipped: true });
            }

            content[userId] = {
                displayName: newDisplayName,
                tag:         newTag,
                executed:    newExecuted,
                pfpId:       newPfpId,   // ← consistent name used everywhere now
                bgId:        newBgId,    // ← consistent name used everywhere now
                glowColor:   newGlowColor,
                effects:     newEffects,
                animMeta:    newAnimMeta,
                updatedAt:   new Date().toISOString()
            };

            await saveFile(content, sha);
            return res.json({ ok: true });
        }

        return res.status(405).json({ error: "Method not allowed" });
    } catch (err) {
        return res.status(500).json({ error: err.message });
    }
}
