# Privacy Policy

**App:** SutraKey  
**Developer:** Aritro Saha  
**Website:** [https://sutrakey.aritro.cloud](https://sutrakey.aritro.cloud)  
**Effective Date:** October 21, 2026  
**Contact:** [security@sutrakey.aritro.cloud](mailto:security@sutrakey.aritro.cloud) | [aritrosaha2025@gmail.com](mailto:aritrosaha2025@gmail.com)

---

## 1. Overview

Thank you for choosing **SutraKey**. We believe that personal privacy and local data sovereignty are fundamental rights. SutraKey is engineered from the ground up to operate completely on your device without telemetry, tracking, cloud proxies, or user analytics.

**The Short Version:** SutraKey never transmits your clipboard content, selected URLs, downloaded media, browser cookies, or system credentials to external servers. Everything happens 100% locally on your Mac.

This policy applies to the SutraKey macOS application and its companion documentation website at `https://sutrakey.aritro.cloud`.

---

## 2. Information We Do NOT Collect

We do not collect, transmit, store, monetize, or sell any personal data. Specifically:

- **No URL or Clipboard Tracking:** When you hold `Shift` and select a link, the URL is inspected entirely in memory to render the radial menu. It is never logged to an external database, analytics provider, or tracking beacon.
- **No Analytics or Telemetry:** There are no analytics SDKs, Google Analytics, telemetry pings, crash log reporters, or third-party trackers bundled with SutraKey.
- **No Cloud Relay or Proxy Servers:** Downloads and webpage captures happen directly between your Mac and the target media host via standard local sockets. Your requests never pass through a SutraKey proxy server.
- **No Plaintext Credential Logging:** When authenticated sessions are enabled for video hosts, cookie values extracted from your browser's local store are passed directly to the local subprocess in volatile memory and are never written to unencrypted log files.

---

## 3. Permissions Used & Why They Are Required

SutraKey requests macOS system permissions solely to deliver its core functionality:

### 3.1 Accessibility Permission (`Accessibility API` & `CGEventTap`)
- **Purpose:** To detect when you hold down the `Shift` modifier key while making a mouse text selection across any application (Safari, Chrome, Slack, Notes, etc.).
- **Scope:** The event tap only checks modifier flags (`NSEvent.ModifierFlags.shift`) and standard mouse button up/down states. It does not record keystrokes, passwords, or personal messaging data.
- **Revocation:** You can revoke this permission at any time in **System Settings → Privacy & Security → Accessibility**. Doing so will disable the radial selection trigger; you can still trigger downloads manually via the menu bar icon.

### 3.2 Apple Keychain Access (Optional for Authenticated Downloads)
- **Purpose:** For downloading age-restricted, subscriber-only, or private content that you have authorized in your browser (e.g. Brave, Chrome, Safari), SutraKey uses native macOS security APIs to access the browser's local cookie decryption key stored in your macOS Keychain.
- **Scope:** This access is strictly bounded to the specific browser cookie database on your local disk. At no point are your credentials exported, uploaded, or accessible to external parties.

### 3.3 Network Client Access
- **Purpose:** To connect directly to the media server or webpage specified in the selected URL in order to stream video packets, audio tracks, or webpage assets.
- **Scope:** Connections are initiated only when you click an action in the radial menu (Video, Audio, Subtitles, or PDF).

---

## 4. Local Storage & File Management

All data created or managed by SutraKey resides entirely within your local macOS user account:

| Data Type | Purpose | Local Storage Location | Persistence |
|---|---|---|---|
| **Downloaded Media** | Saved videos, audio files, and PDFs | `~/Downloads` (or your configured custom destination) | Until you delete or move the file |
| **App Preferences** | Shortcuts, speed limits, default formats, and browser choice | `~/Library/Preferences/com.sutrakey.macos.plist` via `UserDefaults` | Until reset or uninstalled |
| **Download History** | Fast search and status tracking of recent conversions | `~/Library/Application Support/SutraKey/` | Local only; clearable at any time |
| **Temporary Conversion Buffers** | Active chunk downloads before muxing | `~/Library/Caches/com.sutrakey.macos/` | Discarded automatically upon completion |

---

## 5. Third-Party Dependencies & Subprocesses

SutraKey utilizes vetted, industry-standard open-source command-line tools:
- **`yt-dlp`**: Executes locally on your Mac to extract media streams. SutraKey invokes `yt-dlp` with strict security arguments (`--no-exec`, `--restrict-filenames`) to prevent arbitrary code execution from malicious playlists.
- **`ffmpeg`**: Handles local video/audio remuxing, codec conversion, and thumbnail extraction entirely offline.
- **WebKit (`WKWebView`)**: Generates vector PDFs locally on your Mac without remote rendering services.

None of these local tools contain remote surveillance backdoors in their distributed builds.

---

## 6. Children's Privacy

SutraKey is a general-audience productivity utility. It does not solicit or collect personal information from individuals of any age, including children under the age of 13.

---

## 7. Changes to This Privacy Policy

If we modify this Privacy Policy, the revised version will be published here with an updated "Effective Date". Because SutraKey does not collect user contact information, we encourage users to check this page or the project repository periodically.

---

## 8. Contact & Security Inquiries

If you have questions, feedback, or security vulnerability reports regarding this Privacy Policy, please contact:

- **Developer:** Aritro Saha
- **Security Inquiries:** [security@sutrakey.aritro.cloud](mailto:security@sutrakey.aritro.cloud)
- **Personal Email:** [aritrosaha2025@gmail.com](mailto:aritrosaha2025@gmail.com)
- **Project Repository:** [https://github.com/halcyon-past/SutraKey](https://github.com/halcyon-past/SutraKey)
