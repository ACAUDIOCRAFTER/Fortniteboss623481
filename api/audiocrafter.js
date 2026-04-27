import fs from "fs";
import path from "path";

export default function handler(req, res) {
  const accept = req.headers.accept || "";

  if (accept.includes("text/html")) {
    res.writeHead(302, { Location: "/" });
    return res.end();
  }

  const filePath = path.join(process.cwd(), "private", "ac.lua");
  const script = fs.readFileSync(filePath, "utf8");

  res.setHeader("Content-Type", "text/plain");
  res.send(script);
}
