// api/manage.js — AC AudioCrafter manage API
// Handles: ban, whitelist, live executing users

import { kv } from "@vercel/kv";   // or swap for your storage — see bottom of file

const ADMIN_PASS  = process.env.AC_ADMIN_PASS  || "changeme";
const EXEC_TTL_MS = 60_000;   // user dropped from live list after 60s no ping

// ── helpers ──────────────────────────────────────────────────────────────────

async function getBans()      { return (await kv.get("ac:banned"))    || []; }
async function getWhitelist() { return (await kv.get("ac:whitelist")) || []; }

// executing list: { username: lastSeenMs }
async function getExecMap()   { return (await kv.get("ac:executing")) || {}; }
async function setExecMap(m)  { await kv.set("ac:executing", m); }

function liveUsers(execMap) {
  const now = Date.now();
  return Object.entries(execMap)
    .filter(([, t]) => now - t < EXEC_TTL_MS)
    .map(([u]) => u);
}

// ── handler ──────────────────────────────────────────────────────────────────

export default async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  if (req.method === "OPTIONS") return res.status(200).end();

  const { action, user, auth } = req.query;

  // ── Script ping: POST /api/manage?action=exec&user=USERNAME
  // No auth needed — this is called from the Roblox executor
  if (req.method === "POST" && action === "exec" && user) {
    const map = await getExecMap();
    map[user] = Date.now();
    // Clean up stale entries while we're here
    const now = Date.now();
    for (const [u, t] of Object.entries(map)) {
      if (now - t >= EXEC_TTL_MS) delete map[u];
    }
    await setExecMap(map);
    return res.json({ ok: true });
  }

  // ── Script ban/whitelist check: GET /api/manage?action=check&user=USERNAME
  if (req.method === "GET" && action === "check" && user) {
    const [bans, wl] = await Promise.all([getBans(), getWhitelist()]);
    return res.json({
      ok:          true,
      banned:      bans.includes(user),
      whitelisted: wl.includes(user),
    });
  }

  // ── All admin actions below require auth ─────────────────────────────────
  if (auth !== ADMIN_PASS) {
    return res.status(401).json({ ok: false, error: "Unauthorized" });
  }

  // ── GET /api/manage?auth=... — dashboard data poll ───────────────────────
  if (req.method === "GET") {
    const [bans, wl, execMap] = await Promise.all([
      getBans(), getWhitelist(), getExecMap()
    ]);
    return res.json({
      ok:        true,
      banned:    bans,
      whitelist: wl,
      executing: liveUsers(execMap),   // ← this is what the website reads
    });
  }

  // ── POST /api/manage — admin mutations ───────────────────────────────────
  if (req.method === "POST") {
    let body = {};
    try { body = typeof req.body === "string" ? JSON.parse(req.body) : (req.body || {}); } catch {}
    const username = body.username || "";
    const act      = body.action   || "";

    // Ban
    if (act === "ban_add" && username) {
      const bans = await getBans();
      if (!bans.includes(username)) bans.push(username);
      await kv.set("ac:banned", bans);
      // Also remove from executing list if they're live
      const map = await getExecMap();
      delete map[username];
      await setExecMap(map);
      return res.json({ ok: true, banned: bans });
    }
    if (act === "ban_remove" && username) {
      const bans = (await getBans()).filter(u => u !== username);
      await kv.set("ac:banned", bans);
      return res.json({ ok: true, banned: bans });
    }

    // Whitelist
    if (act === "whitelist_add" && username) {
      const wl = await getWhitelist();
      if (!wl.includes(username)) wl.push(username);
      await kv.set("ac:whitelist", wl);
      return res.json({ ok: true, whitelist: wl });
    }
    if (act === "whitelist_remove" && username) {
      const wl = (await getWhitelist()).filter(u => u !== username);
      await kv.set("ac:whitelist", wl);
      return res.json({ ok: true, whitelist: wl });
    }

    return res.status(400).json({ ok: false, error: "Unknown action" });
  }

  return res.status(405).json({ ok: false, error: "Method not allowed" });
}

/*
  ════════════════════════════════════════════════════════════════
  IF YOU'RE NOT USING @vercel/kv  — swap the storage at the top:
  ════════════════════════════════════════════════════════════════

  OPTION A — Vercel KV (recommended, free tier available):
    npm install @vercel/kv
    Add KV_REST_API_URL + KV_REST_API_TOKEN to your Vercel env vars

  OPTION B — Simple file/JSON store (if you use a VPS not Vercel):
    Replace kv calls with fs.readFileSync / fs.writeFileSync on a JSON file:

    import fs from "fs";
    const DB_FILE = "./data/manage.json";
    function readDB() {
      try { return JSON.parse(fs.readFileSync(DB_FILE, "utf8")); } catch { return {}; }
    }
    function writeDB(d) { fs.writeFileSync(DB_FILE, JSON.stringify(d)); }

    Then replace:
      kv.get("ac:banned")      → readDB().banned    || []
      kv.set("ac:banned", v)   → writeDB({...readDB(), banned: v})
      etc.

  OPTION C — Already have your own DB setup:
    Just replace the getBans/getWhitelist/getExecMap/setExecMap
    functions with your own storage calls.
  ════════════════════════════════════════════════════════════════
*/
