# Changelog

All notable changes to **SutraKey** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.0.4] - 2026-10-25

### Fixed
- **App Reopen & Foreground Activation (`LSUIElement = 1`):** Resolved an issue where double-clicking the app in Finder/Spotlight or clicking [Quit & Reopen] in macOS System Settings after granting permissions produced no visual response. Implemented `applicationShouldHandleReopen(_:hasVisibleWindows:)` and `applicationOpenUntitledFile(_:)` in `AppDelegate` to summon and bring the Settings window to the front via `orderFrontRegardless()` and `NSApp.activate(ignoringOtherApps: true)`.
- **First-Launch & Permission Guidance Window:** Ensured users receive immediate visual cues and setup instructions on first launch or when Accessibility permissions are not yet granted (`AXIsProcessTrusted() == false`), automatically presenting the configuration window instead of running purely invisibly.
- **Menu Bar Icon Bounds & Notch Overflow Prevention:** Enforced fixed `18×18` point bounds across all menu bar icon representations (`MenuBarIcon.templateImage`, custom assets, and SF Symbols) to prevent status item clipping or hiding behind MacBook camera notches. Pinned idle menu item width strictly to `NSStatusItem.squareLength` (switching to variable length only while actively rendering download progress).
- **Safe Event Dispatch & Native Menu Popups:** Replaced deprecated menu assignment and simulated clicks in `EphemeralStatusBarController` with native `NSMenu.popUp(positioning:at:in:)` and wrapped `NSApp.currentEvent` safely to eliminate force-unwrap crashes.
- **Shortcut Recorder Event Monitor Leak Fix:** Refactored shortcut recording from SwiftUI struct view `@State` into a centralized `@MainActor final class` reference coordinator (`ShortcutRecorderCoordinator`), eliminating local `NSEvent` monitor memory leaks on view re-renders. Added clean monitor lifecycle teardown in `SettingsView.onDisappear`.
- **Carbon Global HotKey Concurrency:** Added thread-safe `NSLock` synchronization around Carbon hotkey registration and unregistration in `GlobalHotKeyManager`, preventing race conditions during hotkey reloading.

### Added
- **Configurable Global Radial Shortcut:** Added full support for customizing the system-wide radial trigger shortcut (defaulting to `⌘⇧S`) in Settings → General with an interactive key recorder, error validation, and reset-to-default button.
- **Space & Special Key Parsing:** Added support for recording Space (`kVK_Space`, key code 49), Return, Tab, and Arrow keys with human-friendly glyph formatting.
- **Modifier Key Validation:** Strictly required at least one modifier key (`⌘`, `⌥`, `⌃`, `⇧`) for custom shortcuts, rejecting bare alphanumeric or symbol keys to protect system typing.
- **Automated Test Suite:** Added unit test suite `ShortcutRecorderAndReopenTests.swift` validating shortcut recording, key code formatting, modifier persistence, and window reuse.

---

## [1.0.3] - 2026-10-24

### Fixed
- **Menu Bar Right-Click Context Menu Enablement:** Resolved a critical issue where right-clicking the SutraKey menu bar status item rendered all menu options ("Settings...", "Check for Updates...", "Open Downloads Folder", "Quit SutraKey") disabled/grayed out. Because SutraKey operates as an accessory background daemon (`LSUIElement = 1`), AppKit's autoenabling responder chain failed to resolve target selectors without explicit assignments. Explicitly wired `item.target = self`, disabled `autoenablesItems`, conformed `EphemeralStatusBarController` to `NSMenuItemValidation`, and guaranteed `quitApp(_:)` terminates the process cleanly with fallback protection.
- **Control-Click Context Menu Support:** Added full secondary-click gesture support (`Control + Left Click`) alongside standard right-clicks (`.rightMouseUp`) to summon the status bar context menu reliably across all trackpad and mouse configurations.

### Added
- **Direct Popover Quit Control:** Added an intuitive Power / Quit button directly in the popover header next to the Settings gear in `ProgressPopoverView`, providing users with an immediate one-click method to exit the application from both left-click and right-click interactions.
- **Menu Item Automated Test Suite:** Added unit test `testContextMenuItemsEnabled` in `EphemeralMenuBarStateTests.swift` validating that all right-click menu items remain enabled, valid, and bound to actionable target selectors.

---

## [1.0.2] - 2026-10-23

### Added
- **Application Shortcuts Toggle in Settings:** Added a dedicated "Application Shortcuts" toggle in Settings → General allowing users to turn global shortcuts, gestures, and selection menus ON or OFF at any time without quitting the app.
- **Global Master Hotkey (`⌘⇧0` / `Cmd + Shift + 0`):** Added a system-wide hotkey (`kVK_ANSI_0` with `cmdKey | shiftKey`, plus `⌥⇧0` fallback) that instantly pauses or resumes all SutraKey shortcuts and gesture monitors from any macOS application.
- **System HUD Toast Notifications:** Integrated HUD toast feedback via `SutraToastController` displaying an immediate visual status badge (*"Shortcuts Enabled"* / *"Shortcuts Paused"*) whenever shortcuts are toggled via hotkey, settings, or menu bar.
- **Menu Bar & Popover Status Indicators:** Added active shortcut state display and quick-toggle action directly in the menu bar right-click context menu and the Progress Popover header.
- **In-App & Web Documentation:** Updated support documentation table in both the web support portal (`/support`) and documentation with the new `⌘⇧0` master toggle shortcut.

### Fixed
- **Menu Bar Icon Visibility on Launch:** Resolved an issue where the menu bar icon could fail to display or render as an empty placeholder on cold application start. Ensured that `MenuBarIcon.templateImage` is properly initialized as a template image with fixed dimensions (18x18pt) before binding to `NSStatusBar.system.statusItem`.

### Changed
- **Packaging Script Flexibility:** Added `--no-launch` flag support to `package_and_install.sh` to allow rebuilding and deploying local application updates without forcibly launching the application process.
- **Automated Test Coverage:** Added unit test suite `testShortcutsEnabledToggle` in `PreferencesAndUpdateTests.swift` validating setting toggle logic, persistence, and state flipping.

---

## [1.0.1] - 2026-10-22

### Fixed
- **Web-to-PDF Engine:** Resolved blank and dark background PDF generation on single-page apps and complex dynamic documentation sites (e.g. GitHub). In background daemons (`LSUIElement = 1`), WebKit's WebContent process was throttled by macOS `RunningBoardServices`. We now host `WKWebView` in an offscreen `NSWindow` to retain active display links, dynamically measure full DOM scroll height via JavaScript (`measureAndCapture()`), apply standard desktop Safari user-agent, and clip CoreGraphics A4 pagination cleanly.
- **Frontend Footer Cleanup:** Removed the "Machine Endpoints" column from the human-facing footer layout while preserving all crawler discovery files (`/llms.txt`, `/llms-full.txt`, `/ai.txt`, `/sitemap.xml`) for AI agents and search bots.

### Added
- **Automated Release Workflow:** Release pipeline now automatically validates version increments against existing GitHub releases and verifies `CHANGELOG.md` documentation before publishing DMGs and syncing the Homebrew tap.
- **Account Sponsorship:** Enabled repository and organization-wide GitHub Sponsors support (`.github/FUNDING.yml`).

### Changed
- **CI/CD Workflows:** Upgraded GitHub Actions to `actions/checkout@v7`, `actions/setup-python@v7`, and `actions/setup-node@v7`.
- **Branch Governance Policy:** Whitelisted `dependabot/*` branches in branch-guard CI checks and pre-push hooks to permit automated dependency updates.
- **Dependencies:** Grouped and bumped `react` & `react-dom` to `19.3.1`, `@types/node` to `26.6.5`, and pinned TypeScript/ESLint for Next.js 16 tooling stability.

---

## [1.0.0] - 2026-10-21

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
