#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import sharp from "sharp";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = path.resolve(__dirname, "..");
const PUBLIC_DIR = path.join(ROOT_DIR, "public");
const APP_DIR = path.join(ROOT_DIR, "app");

const ICON_PATH = path.join(PUBLIC_DIR, "AppIcon-1024.png");
const iconBase64 = fs.readFileSync(ICON_PATH).toString("base64");

// Canvas configuration
const WIDTH = 1200;
const HEIGHT = 630;

// Wheel configuration
const cx = 920;
const cy = 300;
const R = 158;
const r = 62;
const midR = (R + r) / 2;

// 5 slices
const slices = [
  { name: "Video", badge: "4K MP4", color: "#ff6b3d", centerDeg: -90 },
  { name: "Audio", badge: "320k MP3", color: "#38bdf8", centerDeg: -18 },
  { name: "Subtitles", badge: "SRT", color: "#fbbf24", centerDeg: 54 },
  { name: "Gallery", badge: "IMG", color: "#c084fc", centerDeg: 126 },
  { name: "Vector PDF", badge: "PDF", color: "#34d399", centerDeg: 198 },
];

function degToRad(deg) {
  return (deg * Math.PI) / 180;
}

function makeSlicePath(centerDeg, spanDeg = 68) {
  const halfSpan = spanDeg / 2;
  const a1 = degToRad(centerDeg - halfSpan);
  const a2 = degToRad(centerDeg + halfSpan);

  const x1 = cx + R * Math.cos(a1);
  const y1 = cy + R * Math.sin(a1);
  const x2 = cx + R * Math.cos(a2);
  const y2 = cy + R * Math.sin(a2);

  const x3 = cx + r * Math.cos(a2);
  const y3 = cy + r * Math.sin(a2);
  const x4 = cx + r * Math.cos(a1);
  const y4 = cy + r * Math.sin(a1);

  return `M ${x1.toFixed(2)} ${y1.toFixed(2)} A ${R} ${R} 0 0 1 ${x2.toFixed(2)} ${y2.toFixed(2)} L ${x3.toFixed(2)} ${y3.toFixed(2)} A ${r} ${r} 0 0 0 ${x4.toFixed(2)} ${y4.toFixed(2)} Z`;
}

// Generate slice SVG elements
const sliceElements = slices
  .map((s) => {
    const pathData = makeSlicePath(s.centerDeg, 68);
    const rad = degToRad(s.centerDeg);
    const lx = cx + midR * Math.cos(rad);
    const ly = cy + midR * Math.sin(rad);

    return `
    <g>
      <!-- Slice background glass -->
      <path d="${pathData}" fill="${s.color}" fill-opacity="0.18" stroke="${s.color}" stroke-opacity="0.55" stroke-width="1.5"/>
      <!-- Inner subtle glow -->
      <path d="${pathData}" fill="${s.color}" fill-opacity="0.08"/>
      <!-- Badge Text -->
      <text x="${lx.toFixed(1)}" y="${(ly - 6).toFixed(1)}" 
            fill="#ffffff" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif" 
            font-size="13" font-weight="800" text-anchor="middle" dominant-baseline="middle" letter-spacing="0.5">
        ${s.badge}
      </text>
      <!-- Name Text -->
      <text x="${lx.toFixed(1)}" y="${(ly + 10).toFixed(1)}" 
            fill="${s.color}" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" 
            font-size="11" font-weight="600" text-anchor="middle" dominant-baseline="middle" opacity="0.95">
        ${s.name}
      </text>
    </g>`;
  })
  .join("\n");

const svg = `
<svg width="${WIDTH}" height="${HEIGHT}" viewBox="0 0 ${WIDTH} ${HEIGHT}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Background Radial Gradients -->
    <radialGradient id="topGlow" cx="20%" cy="15%" r="45%">
      <stop offset="0%" stop-color="#10b981" stop-opacity="0.22"/>
      <stop offset="50%" stop-color="#06b6d4" stop-opacity="0.10"/>
      <stop offset="100%" stop-color="#09090b" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="wheelGlow" cx="77%" cy="48%" r="35%">
      <stop offset="0%" stop-color="#a855f7" stop-opacity="0.20"/>
      <stop offset="45%" stop-color="#ec4899" stop-opacity="0.12"/>
      <stop offset="100%" stop-color="#09090b" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="bottomPinkGlow" cx="10%" cy="85%" r="40%">
      <stop offset="0%" stop-color="#f43f5e" stop-opacity="0.15"/>
      <stop offset="60%" stop-color="#09090b" stop-opacity="0"/>
    </radialGradient>

    <!-- Title Gradient -->
    <linearGradient id="headlineGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#34d399"/>
      <stop offset="45%" stop-color="#2dd4bf"/>
      <stop offset="100%" stop-color="#f472b6"/>
    </linearGradient>

    <!-- Card Inner Glass Border Gradient -->
    <linearGradient id="borderGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.22"/>
      <stop offset="50%" stop-color="#ffffff" stop-opacity="0.05"/>
      <stop offset="100%" stop-color="#ffffff" stop-opacity="0.15"/>
    </linearGradient>

    <!-- App Icon Squircle Clip -->
    <clipPath id="iconSquircle">
      <rect x="80" y="70" width="76" height="76" rx="18" ry="18"/>
    </clipPath>

    <!-- Drop Shadow Filter -->
    <filter id="hubShadow" x="-30%" y="-30%" width="160%" height="160%">
      <feDropShadow dx="0" dy="6" stdDeviation="12" flood-color="#000000" flood-opacity="0.6"/>
    </filter>
    <filter id="iconShadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="8" stdDeviation="10" flood-color="#000000" flood-opacity="0.5"/>
    </filter>
  </defs>

  <!-- Deep Obsidian Canvas Background -->
  <rect width="${WIDTH}" height="${HEIGHT}" fill="#09090c"/>

  <!-- Atmospheric Lighting Glow Pools -->
  <rect width="${WIDTH}" height="${HEIGHT}" fill="url(#topGlow)"/>
  <rect width="${WIDTH}" height="${HEIGHT}" fill="url(#wheelGlow)"/>
  <rect width="${WIDTH}" height="${HEIGHT}" fill="url(#bottomPinkGlow)"/>

  <!-- Subtle Outer Hairline Inset Border -->
  <rect x="20" y="20" width="${WIDTH - 40}" height="${HEIGHT - 40}" rx="24" fill="none" stroke="url(#borderGrad)" stroke-width="1.2"/>

  <!-- ================= LEFT COLUMN CONTENT ================= -->

  <!-- 1. Brand Lockup: Master Icon + Title + Version Badge -->
  <!-- Shadow behind icon -->
  <rect x="80" y="70" width="76" height="76" rx="18" fill="#000000" filter="url(#iconShadow)"/>
  <!-- App Icon Image -->
  <image href="data:image/png;base64,${iconBase64}" x="80" y="70" width="76" height="76" clip-path="url(#iconSquircle)"/>
  <!-- Icon Glass Border -->
  <rect x="80" y="70" width="76" height="76" rx="18" fill="none" stroke="#ffffff" stroke-opacity="0.25" stroke-width="1.5"/>

  <!-- Product Name & Badges -->
  <text x="174" y="103" fill="#ffffff" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif" font-size="32" font-weight="700" letter-spacing="-0.5">
    SutraKey
  </text>
  <text x="318" y="103" fill="#9ca3af" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="16" font-weight="500">
    / Sutra Key
  </text>

  <!-- Platform Badge Pill -->
  <rect x="435" y="82" width="94" height="28" rx="14" fill="#ffffff" fill-opacity="0.08" stroke="#ffffff" stroke-opacity="0.14" stroke-width="1"/>
  <text x="482" y="100" fill="#e5e7eb" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="12" font-weight="600" text-anchor="middle">
    macOS 15+
  </text>

  <!-- Sub-header metadata -->
  <text x="175" y="132" fill="#9ca3af" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="13" font-weight="500">
    Native Swift 6.0 • Universal Apple Silicon &amp; Intel • Free &amp; Open Source
  </text>

  <!-- 2. Hero Headline -->
  <text x="80" y="215" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif" font-size="52" font-weight="700" letter-spacing="-1.2">
    <tspan fill="#ffffff">Hold Shift. </tspan>
    <tspan fill="url(#headlineGrad)">Set media free.</tspan>
  </text>

  <!-- 3. Subtitle / Product Proposition -->
  <text x="80" y="270" fill="#d1d5db" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="20" font-weight="400" letter-spacing="-0.2">
    Zero-latency radial menu for instant media &amp; document extraction.
  </text>
  <text x="80" y="302" fill="#9ca3af" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="400" letter-spacing="-0.2">
    Highlight any URL across macOS to download straight to <tspan fill="#f3f4f6" font-family="'SF Mono', Menlo, monospace" font-size="16">~/Downloads</tspan>.
  </text>

  <!-- 4. Feature Badges (Two Clean Rows, Zero Overflow Guaranteed) -->
  <!-- Row 1: Gestures & Core Engines (y=370) -->
  <!-- Pill 1: Shortcut -->
  <g transform="translate(80, 362)">
    <rect width="186" height="38" rx="19" fill="#ec4899" fill-opacity="0.14" stroke="#ec4899" stroke-opacity="0.45" stroke-width="1"/>
    <circle cx="22" cy="19" r="5" fill="#f472b6"/>
    <text x="36" y="24" fill="#fbcfe8" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="13.5" font-weight="600">
      ⌘⇧S / Shift + Drag
    </text>
  </g>

  <!-- Pill 2: Video & Audio -->
  <g transform="translate(278, 362)">
    <rect width="194" height="38" rx="19" fill="#38bdf8" fill-opacity="0.14" stroke="#38bdf8" stroke-opacity="0.45" stroke-width="1"/>
    <circle cx="22" cy="19" r="5" fill="#38bdf8"/>
    <text x="36" y="24" fill="#bae6fd" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="13.5" font-weight="600">
      4K Video &amp; Hi-Fi Audio
    </text>
  </g>

  <!-- Pill 3: Vector PDF -->
  <g transform="translate(484, 362)">
    <rect width="176" height="38" rx="19" fill="#34d399" fill-opacity="0.14" stroke="#34d399" stroke-opacity="0.45" stroke-width="1"/>
    <circle cx="22" cy="19" r="5" fill="#34d399"/>
    <text x="36" y="24" fill="#a7f3d0" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="13.5" font-weight="600">
      WebKit Vector PDF
    </text>
  </g>

  <!-- Row 2: Privacy & Architecture (y=418) -->
  <!-- Pill 4: 100% On-Device -->
  <g transform="translate(80, 416)">
    <rect width="268" height="38" rx="19" fill="#10b981" fill-opacity="0.14" stroke="#10b981" stroke-opacity="0.45" stroke-width="1"/>
    <circle cx="22" cy="19" r="5" fill="#10b981"/>
    <text x="36" y="24" fill="#6ee7b7" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="13.5" font-weight="600">
      100% On-Device • Zero Telemetry
    </text>
  </g>

  <!-- Pill 5: Browser Keychain Auth -->
  <g transform="translate(360, 416)">
    <rect width="254" height="38" rx="19" fill="#fbbf24" fill-opacity="0.14" stroke="#fbbf24" stroke-opacity="0.45" stroke-width="1"/>
    <circle cx="22" cy="19" r="5" fill="#fbbf24"/>
    <text x="36" y="24" fill="#fde68a" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="13.5" font-weight="600">
      Keychain Cookie Auth
    </text>
  </g>

  <!-- 5. Bottom Card Divider & Attribution -->
  <line x1="80" y1="510" x2="1120" y2="510" stroke="#ffffff" stroke-opacity="0.12" stroke-width="1"/>

  <!-- Canonical URL Link -->
  <text x="80" y="548" fill="#ffffff" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="18" font-weight="600" letter-spacing="-0.3">
    https://sutrakey.aritro.cloud
  </text>
  <text x="375" y="548" fill="#6b7280" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="16">
    •
  </text>
  <text x="395" y="548" fill="#9ca3af" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="15" font-weight="400">
    Crafted by <tspan fill="#e5e7eb" font-weight="600">Aritro Saha</tspan> (halcyon-past)
  </text>

  <!-- GitHub Repo Pill on far right of footer -->
  <g transform="translate(930, 528)">
    <rect width="190" height="32" rx="16" fill="#ffffff" fill-opacity="0.08" stroke="#ffffff" stroke-opacity="0.16" stroke-width="1"/>
    <text x="95" y="21" fill="#f3f4f6" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="13" font-weight="500" text-anchor="middle">
      github.com/halcyon-past
    </text>
  </g>

  <!-- ================= RIGHT COLUMN: SUTRAKEY RADIAL WHEEL ================= -->

  <!-- Outer Ambient Radial Ring Shadow -->
  <circle cx="${cx}" cy="${cy}" r="${R + 12}" fill="#000000" fill-opacity="0.4" filter="url(#hubShadow)"/>

  <!-- Radial Guide Outer Ring -->
  <circle cx="${cx}" cy="${cy}" r="${R}" fill="none" stroke="#ffffff" stroke-opacity="0.15" stroke-width="1"/>
  <!-- Radial Guide Inner Ring -->
  <circle cx="${cx}" cy="${cy}" r="${r}" fill="none" stroke="#ffffff" stroke-opacity="0.18" stroke-width="1"/>

  <!-- The 5 Slices -->
  ${sliceElements}

  <!-- Center Hub Glass -->
  <circle cx="${cx}" cy="${cy}" r="${r - 6}" fill="#111116" fill-opacity="0.88" stroke="#ffffff" stroke-opacity="0.25" stroke-width="1.5" filter="url(#hubShadow)"/>
  <circle cx="${cx}" cy="${cy}" r="${r - 14}" fill="#181820" fill-opacity="0.9" stroke="#ffffff" stroke-opacity="0.10" stroke-width="1"/>

  <!-- Shift Key Symbol in Hub -->
  <text x="${cx}" y="${cy - 8}" fill="#ffffff" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif" font-size="22" font-weight="700" text-anchor="middle" dominant-baseline="middle">
    ⇧
  </text>
  <text x="${cx}" y="${cy + 14}" fill="#9ca3af" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="10" font-weight="600" text-anchor="middle" dominant-baseline="middle" letter-spacing="1">
    SHIFT
  </text>

  <!-- Radial HUD Label Tag at Wheel Top -->
  <g transform="translate(${cx - 70}, ${cy - R - 32})">
    <rect width="140" height="24" rx="12" fill="#000000" fill-opacity="0.65" stroke="#ffffff" stroke-opacity="0.15" stroke-width="1"/>
    <text x="70" y="16" fill="#d1d5db" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', 'Segoe UI', Roboto, sans-serif" font-size="10.5" font-weight="600" text-anchor="middle" letter-spacing="0.8">
      RADIAL MENU HUD
    </text>
  </g>
</svg>`;

async function renderBanner() {
  console.log("🎨 Rendering high-res vector social banner via sharp...");
  const svgBuffer = Buffer.from(svg);

  // 1. og-image.jpg (High Quality JPEG, 1200x630)
  const ogJpgPath = path.join(PUBLIC_DIR, "og-image.jpg");
  await sharp(svgBuffer)
    .jpeg({ quality: 95, chromaSubsampling: "4:4:4" })
    .toFile(ogJpgPath);
  console.log("  ✓ Created:", ogJpgPath);

  // 2. banner-social.jpg (Duplicate for full backwards compatibility)
  const bannerJpgPath = path.join(PUBLIC_DIR, "banner-social.jpg");
  fs.copyFileSync(ogJpgPath, bannerJpgPath);
  console.log("  ✓ Created:", bannerJpgPath);

  // 3. og-image.webp (Next-Gen WebP, 1200x630)
  const ogWebpPath = path.join(PUBLIC_DIR, "og-image.webp");
  await sharp(svgBuffer)
    .webp({ quality: 95 })
    .toFile(ogWebpPath);
  console.log("  ✓ Created:", ogWebpPath);

  // Copy to brain for user inspection
  const brainPath = "/Users/aritrosaha/.gemini/antigravity/brain/2ae79e16-9cab-49d5-b5f5-78442f8b8061/og-image-v2.jpg";
  fs.copyFileSync(ogJpgPath, brainPath);
  console.log("  ✓ Copied preview to:", brainPath);
}

renderBanner().catch((err) => {
  console.error("❌ Error generating banner:", err);
  process.exit(1);
});
