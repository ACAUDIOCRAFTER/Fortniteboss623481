export default function handler(req, res) {
    const accept = req.headers.accept || "";

    if (accept.includes("text/html")) {
        res.writeHead(302, { Location: "/" });
        return res.end();
    }

    res.setHeader("Content-Type", "text/plain");

    res.send(`loadstring(game:HttpGet("https://audio-crafter.vercel.app/api/ac?key=ACMelody2024secretkey"))()`);
}
