#!/usr/bin/env node
/**
 * Instant Search Engine Indexing via IndexNow API.
 * Submits all canonical SutraKey pages to both api.indexnow.org and www.bing.com.
 * Powers rapid discovery by Bing, Yahoo, DuckDuckGo, Yandex, Seznam, and AI search engines.
 */

import https from "node:https";

const INDEXNOW_KEY = "e89f41b9c7d0482591ae2f33c8b57a10";
const HOST = "sutrakey.aritro.cloud";
const KEY_LOCATION = `https://${HOST}/${INDEXNOW_KEY}.txt`;

export const URL_LIST = [
  `https://${HOST}/`,
  `https://${HOST}/support`,
  `https://${HOST}/privacy`,
  `https://${HOST}/terms`,
  `https://${HOST}/llms.txt`,
  `https://${HOST}/llms-full.txt`,
  `https://${HOST}/ai.txt`,
  `https://${HOST}/.well-known/ai.txt`,
  `https://${HOST}/.well-known/ai-catalog.json`,
  `https://${HOST}/sitemap.xml`,
];

const ENDPOINTS = [
  { hostname: "api.indexnow.org", path: "/indexnow", name: "IndexNow Central (Bing, Yandex, Seznam, Naver)" },
  { hostname: "www.bing.com", path: "/indexnow", name: "Microsoft Bing Direct" },
];

function submitToEndpoint(endpoint, payload) {
  return new Promise((resolve) => {
    const options = {
      hostname: endpoint.hostname,
      port: 443,
      path: endpoint.path,
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Content-Length": Buffer.byteLength(payload),
        "User-Agent": "SutraKey-IndexNow/1.0.6",
      },
      timeout: 10000,
    };

    const req = https.request(options, (res) => {
      let responseBody = "";
      res.on("data", (chunk) => {
        responseBody += chunk;
      });

      res.on("end", () => {
        const isSuccess = res.statusCode === 200 || res.statusCode === 202;
        if (isSuccess) {
          console.log(`✅ [${endpoint.name}] IndexNow Ping Successful! Status: ${res.statusCode} (URLs queued for indexing)`);
        } else {
          console.warn(`⚠️ [${endpoint.name}] IndexNow Ping returned status: ${res.statusCode}. Details: ${responseBody || "none"}`);
        }
        resolve({ endpoint: endpoint.hostname, status: res.statusCode, ok: isSuccess, body: responseBody });
      });
    });

    req.on("error", (err) => {
      console.error(`❌ [${endpoint.name}] Request Error: ${err.message}`);
      resolve({ endpoint: endpoint.hostname, ok: false, error: err.message });
    });

    req.on("timeout", () => {
      req.destroy();
      console.warn(`⏳ [${endpoint.name}] Request Timed Out.`);
      resolve({ endpoint: endpoint.hostname, ok: false, error: "timeout" });
    });

    req.write(payload);
    req.end();
  });
}

export async function pingIndexNow() {
  const payload = JSON.stringify({
    host: HOST,
    key: INDEXNOW_KEY,
    keyLocation: KEY_LOCATION,
    urlList: URL_LIST,
  });

  console.log(`📡 Submitting ${URL_LIST.length} canonical URLs to IndexNow network for ${HOST}...`);

  const results = await Promise.all(
    ENDPOINTS.map((endpoint) => submitToEndpoint(endpoint, payload))
  );

  return results;
}

// Auto-run if executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  pingIndexNow().then((results) => {
    const anySuccess = results.some((r) => r.ok);
    if (anySuccess) {
      console.log("✨ IndexNow submissions completed successfully.");
      process.exit(0);
    } else {
      console.warn("⚠️ IndexNow pings encountered warnings or errors.");
      process.exit(0);
    }
  });
}
