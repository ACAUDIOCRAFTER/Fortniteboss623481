import { Octokit } from "@octokit/rest";
import formidable from "formidable";
import fs from "fs";
import path from "path";

export const config = { api: { bodyParser: false } };

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });
const OWNER = "ACAUDIOCRAFTER";
const REPO = "AUDIO-CRAFTER";
const BRANCH = "main";
const GIFS_FOLDER = "dm_gifs";
const LIST_PATH = `${GIFS_FOLDER}/list.json`;

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  try {
    const form = formidable({ multiples: false, keepExtensions: true });
    const [fields, files] = await form.parse(req);
    const uploadedFile = files.file?.[0];
    if (!uploadedFile) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    const ext = path.extname(uploadedFile.originalFilename);
    const timestamp = Date.now();
    const newFilename = `gif_${timestamp}${ext}`;
    const githubPath = `${GIFS_FOLDER}/${newFilename}`;

    const fileBuffer = fs.readFileSync(uploadedFile.filepath);
    const base64Content = fileBuffer.toString("base64");

    await octokit.repos.createOrUpdateFileContents({
      owner: OWNER,
      repo: REPO,
      path: githubPath,
      message: `Add GIF: ${newFilename}`,
      content: base64Content,
      branch: BRANCH,
    });

    const rawUrl = `https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}/${githubPath}`;

    let currentList = [];
    try {
      const { data } = await octokit.repos.getContent({
        owner: OWNER,
        repo: REPO,
        path: LIST_PATH,
        ref: BRANCH,
      });
      const content = Buffer.from(data.content, "base64").toString("utf-8");
      currentList = JSON.parse(content);
    } catch (err) {
      if (err.status !== 404) throw err;
    }

    const label = fields.label?.[0] || "";
    currentList.push({
      url: rawUrl,
      thumb: rawUrl,
      label: label,
    });

    const updatedContent = JSON.stringify(currentList, null, 2);
    const listBase64 = Buffer.from(updatedContent).toString("base64");

    let listSha = undefined;
    try {
      const { data } = await octokit.repos.getContent({
        owner: OWNER,
        repo: REPO,
        path: LIST_PATH,
        ref: BRANCH,
      });
      listSha = data.sha;
    } catch (err) {}

    await octokit.repos.createOrUpdateFileContents({
      owner: OWNER,
      repo: REPO,
      path: LIST_PATH,
      message: `Add GIF entry: ${newFilename}`,
      content: listBase64,
      sha: listSha,
      branch: BRANCH,
    });

    res.status(200).json({ success: true, url: rawUrl });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
}
