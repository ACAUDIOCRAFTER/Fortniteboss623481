export default function handler(req, res) {
    const accept = req.headers.accept || "";

    if (accept.includes("text/html")) {
        res.writeHead(302, { Location: "/" });
        return res.end();
    }

    res.setHeader("Content-Type", "text/plain");

    res.send(`print("hello world")`);
}
