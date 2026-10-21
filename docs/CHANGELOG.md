# Changelog

All notable changes to **SutraKey** will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and follows the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

---

## [1.0.0] — 2026-10-21

### Added
- **Radial Selection HUD:**
  - Interactive zero-latency Apple-glass radial menu summoned via `Shift + Select` across any macOS application.
  - 4 quick conversion slots: Video (MP4), Audio (MP3/M4A), Subtitles (SRT/VTT), and Web to PDF.
  - Dynamic wedge expansion, subtle spring physics, and pointer tracking.
- **Conversion Engine:**
  - Swift 6 structured concurrency actor pipeline (`ConversionTaskActor`).
  - Native subprocess runner for `yt-dlp` and `ffmpeg` with security bounds (`--no-exec`, `--restrict-filenames`).
  - Real-time progress observation, download speed, ETA calculation, and stage notifications.
- **Web to PDF Service:**
  - Vector PDF generation powered directly by Apple WebKit (`WKWebView`).
  - Headless rendering with full DOM layout stabilization and link preservation.
- **Browser Keychain Cookie Integration:**
  - One-click Keychain cookie extraction for Brave, Chrome, Safari, Edge, and Arc.
  - Direct authentication support for Instagram Stories, private posts, and member-only streams.
- **Menu Bar & Global Preferences:**
  - Frosted-glass menu bar dropdown displaying active conversion tasks and recent history.
  - Preferences window with browser selection, Keychain test authorization, and destination folder selector.
  - Option to open Settings directly upon launching from `/Applications`.
- **Next.js 16 Web Showcase:**
  - Dark-glass landing page built with React 19, Tailwind CSS, and interactive SVG radial simulator.
  - Complete SEO and LLMO documentation endpoints (`/llms.txt`, `/llms-full.txt`, `/ai.txt`, `/robots.txt`, `/sitemap.xml`).
  - Production legal pages (`/privacy`, `/terms`, `/support`).
- **Workspace-Wide Hotkey Architecture:**
  - Global `⌘⇧S` (`Cmd + Shift + S`) and `⌥⇧S` (`Option + Shift + S`) hotkey triggers registered on `GetEventDispatcherTarget()`.
  - Works across Terminal, WhatsApp, Slack, Apple Notes, VS Code, and Electron workspaces.
  - Isolated synthetic keystroke dispatcher with Shift-UP to prevent physical modifier leakage (`Cmd + Shift + C`).
  - Enhanced selection parsing for `NSAttributedString`, `CFAttributedString`, and native `AXURL` attributes.
- **Persistent Code Signing & TCC Retention:**
  - Automated developer keychain provisioning for `SutraKey CodeSign`.
  - Stable designated requirement bound to certificate leaf, eliminating recurring macOS Accessibility prompts on rebuild.
- **Asset Optimization & Instant Search Engine Indexing:**
  - Next-gen WebP image pipeline (`logo.webp`, `icon-192x192.webp`, `icon-512x512.webp`, `AppIcon.webp`) yielding 97% asset weight reduction.
  - Multi-resolution icon suite (16, 32, 48, 180, 192, 512px) for iOS Safari, macOS, and PWA manifest.
  - High-resolution 1200x630 vector OpenGraph and Twitter social share cards (`og-image.jpg`, `banner-social.jpg`, `og-image.webp`).
  - Automated IndexNow protocol integration (`ping-indexnow.mjs`) for real-time Bing, Yandex, Seznam, and Naver crawling.
  - Dual-keyword SEO optimization targeting both `"SutraKey"` and `"Sutra Key"`.
