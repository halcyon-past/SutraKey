# SutraKey Support & Documentation

**App:** SutraKey (सूत्र)  
**Developer:** Aritro Saha  
**Website:** [https://sutrakey.aritro.cloud/support](https://sutrakey.aritro.cloud/support)  
**Support Email:** [aritrosaha2025@gmail.com](mailto:aritrosaha2025@gmail.com)  
**GitHub Issues:** [https://github.com/halcyon-past/SutraKey/issues](https://github.com/halcyon-past/SutraKey/issues)

---

## 1. Quick Start

### What is SutraKey?
SutraKey is a native macOS productivity tool that turns text selection into action. Hold `Shift` and select any URL or media link in any macOS app (Safari, Chrome, Notes, Slack, Messages), and an interactive frosted-glass radial wheel appears instantly around your cursor with 4 quick conversion options:

1. **Video (MP4 / 4K / 1080p)**: Best quality video stream remuxed to MP4.
2. **Audio (MP3 / 320kbps / M4A)**: High-fidelity audio track extracted with album artwork.
3. **Subtitles (SRT / VTT)**: Multi-language subtitle tracks extracted directly.
4. **Web to PDF**: Clean vector PDF document paginated directly through Apple WebKit.

All files are saved straight to your `~/Downloads` folder.

---

## 2. System Requirements

- **Operating System:** macOS 14.0 (Sonoma) or macOS 15.0+ (Sequoia)
- **Architecture:** Apple Silicon (M1/M2/M3/M4) or Intel x86_64
- **Required Utilities:** `yt-dlp` and `ffmpeg` (automatically detected from Homebrew `/opt/homebrew/bin` or `/usr/local/bin`, or installed locally)

---

## 3. Installation Guide

### Option A: Homebrew Cask (Recommended)
```bash
brew tap halcyon-past/tap
brew install --cask sutrakey
```

### Option B: Direct Application Bundle / DMG
1. Download the latest `SutraKey.app.zip` or `.dmg` from the [GitHub Releases](https://github.com/halcyon-past/SutraKey/releases/latest) page.
2. Drag `SutraKey.app` to `/Applications`.
3. Launch `SutraKey` from Spotlight or Launchpad.

### Option C: Build from Source
```bash
git clone https://github.com/halcyon-past/SutraKey.git
cd SutraKey
./Scripts/package_and_install.sh
```

---

## 4. Permissions & Setup

### 4.1 Accessibility Permission (`AXIsProcessTrusted`)
SutraKey requires Accessibility permission so it can detect mouse drag selections and `Shift` key chords across any active app window.

**How to Grant Accessibility Permission:**
1. Open **System Settings** on your Mac.
2. Navigate to **Privacy & Security** → **Accessibility**.
3. Click the **+** button or toggle the switch next to **SutraKey** to **ON**.
4. If prompted, restart SutraKey.

> **Tip:** If the radial menu does not appear when holding Shift + dragging, check that the switch is toggled ON. In rare cases after updating the binary, remove SutraKey with the `-` button and add it again.

### 4.2 Browser Cookie Access (For Private or Authenticated Media)
Some platforms (such as Instagram Stories, YouTube private playlists, or subscription feeds) require session cookies.

**How to Configure Cookies in SutraKey:**
1. Click the SutraKey icon in your menu bar (or launch SutraKey from Applications).
2. Open **Settings** (or press `⌘ ,`).
3. Under **Authentication & Cookies**, select your active browser:
   - **Brave Browser**
   - **Google Chrome**
   - **Safari**
   - **Firefox / Arc / Edge**
4. Click **Authorize & Test Keychain Access**. When macOS asks for Keychain access, click **Always Allow**.
5. Alternatively, you can select an exported `cookies.txt` file directly.

---

## 5. Keyboard & Gesture Shortcuts

| Gesture / Shortcut | Action | Description |
|---|---|---|
| **Hold `Shift` + Mouse Drag** | Summon Radial Menu | Select any URL text in any app to spawn the interactive liquid wheel. |
| **`Esc`** | Dismiss Radial Menu | Instantly hides the active radial menu without executing any download. |
| **`⌘ ,`** | Open Preferences | Opens the SutraKey Settings window from the menu bar or active window. |
| **Click Menu Bar Icon** | Status & Menu | View active download tasks, download speed, and recent conversion history. |

---

## 6. Supported Media Sources

SutraKey leverages local `yt-dlp` integration supporting over 1,500+ domains, including:
- **YouTube** (Videos, Shorts, Playlists, Channels, Audio streams)
- **Instagram** (Reels, Posts, IGTV, Stories with browser cookies configured)
- **X / Twitter** (Video posts, media clips)
- **TikTok** (Watermark-free video clips)
- **Reddit** (v.redd.it videos with multiplexed audio)
- **Vimeo, Dailymotion, Twitch Clips**
- **Any Web Page** (Web to PDF generates vector printing via Apple WebKit)

---

## 7. Troubleshooting & FAQ

### Q1: The radial menu does not appear when I select text.
- Verify that you are holding the `Shift` key while selecting the text containing the URL.
- Make sure SutraKey has been granted Accessibility access in **System Settings → Privacy & Security → Accessibility**.
- Ensure the text you selected contains a valid URL beginning with `http://`, `https://`, or a well-formed domain.

### Q2: Instagram Stories or private posts fail to download.
- Instagram Stories require an active, logged-in session. Open **SutraKey Settings → Authentication**, choose the browser where you are logged into Instagram (e.g. Brave or Chrome), and authorize keychain access.
- Confirm that the story has not expired (24-hour limit) and that your account has permission to view the content.

### Q3: Where are my downloaded files saved?
- By default, all finished downloads are saved to `~/Downloads`. You can customize the download destination folder in SutraKey Settings.

### Q4: How does Web to PDF work?
- SutraKey instantiates an off-screen Apple WebKit rendering engine (`WKWebView`) that executes JavaScript, waits for page stabilization, and prints the full document directly to a paginated vector PDF with clickable links preserved.

---

## 8. Need More Help?

- **Open a Bug Report:** [https://github.com/halcyon-past/SutraKey/issues/new?template=bug_report.md](https://github.com/halcyon-past/SutraKey/issues/new?template=bug_report.md)
- **Request a Feature:** [https://github.com/halcyon-past/SutraKey/issues/new?template=feature_request.md](https://github.com/halcyon-past/SutraKey/issues/new?template=feature_request.md)
- **Email Developer:** [aritrosaha2025@gmail.com](mailto:aritrosaha2025@gmail.com)
