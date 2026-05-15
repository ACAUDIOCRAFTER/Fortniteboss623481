const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static(path.join(__dirname, 'public')));

// Store tokens in memory (use Redis or database in production)
const tokenStore = new Map();
const KEY_EXPIRY_HOURS = 24;
const TOKEN_EXPIRY_MINUTES = 5;

// Generate a secure random key
function generateKey() {
  return require('crypto').randomBytes(32).toString('hex');
}

// Generate a secure random token
function generateToken() {
  return require('crypto').randomBytes(24).toString('hex');
}

// API: Generate token (called from redirect.html)
app.post('/api/keysystem', (req, res) => {
  const { action, checkpoint_data } = req.body;

  if (action === 'gentoken') {
    // Validate checkpoint data server-side (you should verify actual completion)
    if (!checkpoint_data) {
      return res.status(400).json({ ok: false, error: 'Missing checkpoint data' });
    }

    const token = generateToken();
    const expiresAt = Date.now() + TOKEN_EXPIRY_MINUTES * 60 * 1000;

    tokenStore.set(token, {
      key: generateKey(),
      createdAt: Date.now(),
      expiresAt: Date.now() + KEY_EXPIRY_HOURS * 60 * 60 * 1000,
      used: false
    });

    res.json({ ok: true, token });
  } else if (action === 'getkey') {
    const { token } = req.body;

    if (!token || !tokenStore.has(token)) {
      return res.status(401).json({ ok: false, error: 'Invalid or expired token' });
    }

    const tokenData = tokenStore.get(token);

    // Check if token is expired
    if (Date.now() > tokenData.expiresAt) {
      tokenStore.delete(token);
      return res.status(401).json({ ok: false, error: 'Token expired' });
    }

    res.json({
      ok: true,
      key: tokenData.key,
      expiresAt: tokenData.expiresAt
    });

    // Delete token after use (one-time use)
    tokenStore.delete(token);
  } else {
    res.status(400).json({ ok: false, error: 'Unknown action' });
  }
});

// Cleanup expired tokens every 10 minutes
setInterval(() => {
  for (const [token, data] of tokenStore.entries()) {
    if (Date.now() > data.expiresAt) {
      tokenStore.delete(token);
    }
  }
}, 10 * 60 * 1000);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`AudioCrafter Key System running on port ${PORT}`);
});
