#!/usr/bin/env node
/**
 * Instant Search Engine Indexing via IndexNow API (Bing, Yandex, Seznam, Naver).
 * Submits all canonical SutraKey pages for rapid re-crawling.
 */

import https from "node:https";

const INDEXNOW_KEY = "e89f41b9c7d0482591ae2f33c8b57a10";
const HOST = "sutrakey.aritro.cloud";
const KEY_LOCATION = `https://${HOST}/${INDEXNOW_KEY}.txt`;

const URL_LIST = [
  `https://${HOST}/`,
  `https://${HOST}/support`,
  `https://${HOST}/privacy`,
  `https://${HOST}/terms`,
  `https://${HOST}/llms.txt`,
  `https://${HOST}/llms-full.txt`,
  `https://${HOST}/ai.txt`,
  `https://${HOST}/.well-known/ai.txt`,
  `https://${HOST}/sitemap.xml`,
];

export async function pingIndexNow() {
  const payload = JSON.stringify({
    host: HOST,
    key: INDEXNOW_KEY,
    keyLocation: KEY_LOCATION,
    urlList: URL_LIST,
  });

  const options = {
    hostname: "api.indexnow.org",
    port: 443,
    path: "/indexnow",
    method: "POST",
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Content-Length": Buffer.byteLength(payload),
    },
  };

  console.log(`📡 Submitting ${URL_LIST.length} URLs to IndexNow (${HOST})...`);

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let responseBody = "";
      res.on("data", (chunk) => {
        responseBody += chunk;
      });

      res.on("end", () => {
        if (res.statusCode === 200 || res.statusCode === 202) {
          console.log(`✅ IndexNow Ping Successful! Status: ${res.statusCode} (URLs queued for indexing)`);
          resolve({ status: res.statusCode, body: responseBody });
        } else {
          console.warn(`⚠️ IndexNow Ping returned status: ${res.statusCode}. Response: ${responseBody}`);
          resolve({ status: res.statusCode, body: responseBody });
        }
      });
    });

    req.on("error", (err) => {
      console.error(`❌ IndexNow Ping Error: ${err.message}`);
      resolve({ error: err.message });
    });

    req.write(payload);
    req.end();
  });
}

// Auto-run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  pingIndexNow();
}
