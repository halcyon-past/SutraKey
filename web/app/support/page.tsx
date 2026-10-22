import type { Metadata } from "next";
import Link from "next/link";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { LiquidGlass } from "../components/LiquidGlass";
import { SmoothScrollProvider } from "../components/SmoothScrollProvider";
import {
  HelpCircle,
  Keyboard,
  ShieldCheck,
  KeyRound,
  FileDown,
  FileText,
  Video,
  Music,
  Languages,
  CheckCircle2,
  Terminal,
  ExternalLink,
  ArrowLeft,
  Settings,
  AlertCircle,
} from "lucide-react";

export const metadata: Metadata = {
  title: "Support & Documentation — SutraKey (Sutra Key) for macOS",
  description:
    "Complete documentation, setup instructions, Accessibility permissions, browser cookie authentication, and troubleshooting for SutraKey (Sutra Key) on macOS.",
  alternates: {
    canonical: "/support",
  },
  openGraph: {
    title: "Support & Documentation — SutraKey (Sutra Key) for macOS",
    description:
      "SutraKey (Sutra Key): Master the Shift+Select radial gesture, grant Accessibility permissions, configure browser cookies for private media, and troubleshoot downloads.",
    url: "https://sutrakey.aritro.cloud/support",
    images: ["/og-image.jpg"],
  },
};

const SHORTCUTS = [
  {
    action: "Summon Radial Wheel",
    keys: ["Hold ⇧ Shift", "+ Mouse Drag"],
    badge: "Primary Gesture",
    description: "Highlight any text with a URL in any macOS app to spawn the interactive liquid wheel directly at your cursor.",
  },
  {
    action: "Dismiss Radial Wheel",
    keys: ["Esc"],
    badge: "Quick Dismiss",
    description: "Instantly closes the radial HUD without triggering any download action.",
  },
  {
    action: "Toggle App Shortcuts",
    keys: ["⌘", "⇧", "0"],
    badge: "Quick Pause / Resume",
    description: "Instantly pause or re-enable all SutraKey global hotkeys and mouse selection gestures from anywhere in macOS.",
  },
  {
    action: "Hotkey Radial Summon",
    keys: ["⌘", "⇧", "S"],
    badge: "Keyboard Trigger",
    description: "Directly summons the radial wheel under the cursor or using the system clipboard URL without dragging.",
  },
  {
    action: "Open Settings / Preferences",
    keys: ["⌘", ","],
    badge: "Configuration",
    description: "Configure cookie browser (Brave, Chrome, Safari), Keychain authorization, speed limits, and output path.",
  },
  {
    action: "Inspect Active Workloads",
    keys: ["Click Menu Bar Icon"],
    badge: "Menu Bar",
    description: "View real-time transfer speeds (MB/s), active download progress, ETA, and job cancellation.",
  },
];

const FAQS = [
  {
    q: "Why doesn't the radial wheel appear when I select text?",
    a: "Make sure you are holding ONLY the Shift key while dragging your mouse over the text. SutraKey includes strict modifier exclusivity guardrails: if you hold Command, Option, or Control at the same time, the menu is intentionally suppressed to prevent conflicts with other system shortcuts. Also ensure SutraKey has been granted Accessibility permissions in System Settings.",
  },
  {
    q: "How do I open Settings when the app is running in the background?",
    a: "You can click the SutraKey menu bar icon and select 'Settings...', press ⌘ , while the menu bar popover is active, or simply re-launch SutraKey from your /Applications folder to bring the Settings panel forward directly.",
  },
  {
    q: "Why do Instagram Stories or private posts fail to download?",
    a: "Instagram Stories require active authentication cookies because they are restricted to logged-in accounts and expire after 24 hours. Open SutraKey Settings → Authentication, select the browser where you are logged into Instagram (such as Brave or Chrome), and click 'Authorize & Test Keychain Access'. When macOS prompts for Keychain access, choose 'Always Allow'.",
  },
  {
    q: "How does the 'Web to PDF' option work?",
    a: "SutraKey utilizes Apple's native WebKit rendering engine (WKWebView) in a headless vector pipeline. When selected, it renders the full webpage, awaits DOM layout stabilization, and produces a crisp, searchable, paginated vector PDF with functional hyperlinks straight to ~/Downloads.",
  },
  {
    q: "Where are downloaded files saved?",
    a: "By default, files are saved directly to ~/Downloads. You can choose any custom directory on your internal or external drive in SutraKey Settings > General.",
  },
  {
    q: "Is SutraKey completely free and open-source?",
    a: "Yes! SutraKey is 100% free and open-source under the MIT License, with zero ads, zero telemetry, and zero paywalls.",
  },
];

export default function SupportPage() {
  return (
    <SmoothScrollProvider>
      <div className="relative min-h-screen flex flex-col bg-[#fafafc] text-[#1d1d1f] dark:bg-[#0b0b0f] dark:text-[#f5f5f7] transition-colors duration-400 overflow-x-hidden">
        {/* Ambient Glows */}
        <div className="pointer-events-none fixed inset-0 overflow-hidden z-0 contain-paint">
          <div className="absolute top-[10%] right-[-10%] w-[500px] h-[500px] rounded-full ambient-glow-pink opacity-40 dark:opacity-20" />
          <div className="absolute top-[45%] left-[-10%] w-[550px] h-[550px] rounded-full ambient-glow-green opacity-40 dark:opacity-15" />
          <div className="absolute top-[80%] right-[10%] w-[600px] h-[600px] rounded-full ambient-glow-iris opacity-30 dark:opacity-10" />
        </div>

        <div className="relative z-10 flex flex-col min-h-screen">
          <Navbar />

          <main className="flex-1 max-w-5xl mx-auto px-6 pt-12 pb-24 w-full">
          {/* Back link */}
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-xs font-medium text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white transition-colors mb-8 group"
          >
            <ArrowLeft size={14} className="group-hover:-translate-x-1 transition-transform" />
            Back to Overview
          </Link>

          {/* Header */}
          <div className="mb-12">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-pink-500/10 text-pink-600 dark:text-pink-400 border border-pink-500/20 mb-4">
              <HelpCircle size={14} />
              Help &amp; Documentation Center
            </div>
            <h1 className="text-3xl sm:text-5xl font-bold tracking-tight text-neutral-900 dark:text-white mb-3">
              Support &amp; Setup Guide
            </h1>
            <p className="text-sm sm:text-base text-neutral-600 dark:text-neutral-400 max-w-2xl">
              Everything you need to master SutraKey on macOS: gestures, system permissions, keychain browser authentication, and troubleshooting.
            </p>
          </div>

          <div className="space-y-12">
            {/* Gesture & Shortcut Cheat Sheet */}
            <section className="space-y-4">
              <div className="flex items-center gap-2.5">
                <Keyboard className="w-5 h-5 text-pink-500" />
                <h2 className="text-xl font-bold text-neutral-900 dark:text-white">
                  Gestures &amp; Shortcuts
                </h2>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {SHORTCUTS.map((item, idx) => (
                  <LiquidGlass key={idx} radius={20} depth={1.0} blur={8} className="p-5 flex flex-col justify-between">
                    <div>
                      <div className="flex items-center justify-between mb-3">
                        <span className="text-xs font-semibold text-neutral-500 dark:text-neutral-400 uppercase tracking-wider">
                          {item.action}
                        </span>
                        <span className="text-[10px] font-medium bg-black/[0.04] dark:bg-white/[0.08] px-2 py-0.5 rounded-full text-neutral-600 dark:text-neutral-300">
                          {item.badge}
                        </span>
                      </div>
                      <p className="text-xs text-neutral-600 dark:text-neutral-400 leading-relaxed mb-4">
                        {item.description}
                      </p>
                    </div>
                    <div className="flex items-center gap-1.5 pt-2 border-t border-black/[0.04] dark:border-white/[0.06]">
                      {item.keys.map((k, kIdx) => (
                        <kbd
                          key={kIdx}
                          className="px-2.5 py-1 text-xs font-mono font-semibold rounded-lg bg-black/[0.05] dark:bg-white/[0.1] text-neutral-800 dark:text-neutral-100 border border-black/[0.08] dark:border-white/[0.1] shadow-xs"
                        >
                          {k}
                        </kbd>
                      ))}
                    </div>
                  </LiquidGlass>
                ))}
              </div>
            </section>

            {/* Accessibility Permissions Guide */}
            <section id="accessibility" className="space-y-4 scroll-mt-24">
              <div className="flex items-center gap-2.5">
                <ShieldCheck className="w-5 h-5 text-emerald-500" />
                <h2 className="text-xl font-bold text-neutral-900 dark:text-white">
                  Accessibility Permission Setup
                </h2>
              </div>

              <LiquidGlass radius={24} depth={1.2} blur={10} className="p-6 sm:p-8 space-y-4">
                <p className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
                  SutraKey uses the macOS Accessibility API via <code className="font-mono text-xs bg-black/[0.05] dark:bg-white/[0.08] px-1.5 py-0.5 rounded">CGEventTap</code> to detect when you hold the Shift key while selecting text in any application. It does not monitor typing or read credentials.
                </p>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-2">
                  <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.06]">
                    <span className="text-xs font-bold text-pink-500 font-mono">STEP 01</span>
                    <h4 className="text-sm font-semibold text-neutral-900 dark:text-white mt-1 mb-1">Open Settings</h4>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400">
                      Open <strong>System Settings</strong> → <strong>Privacy &amp; Security</strong> → <strong>Accessibility</strong>.
                    </p>
                  </div>

                  <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.06]">
                    <span className="text-xs font-bold text-pink-500 font-mono">STEP 02</span>
                    <h4 className="text-sm font-semibold text-neutral-900 dark:text-white mt-1 mb-1">Toggle SutraKey</h4>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400">
                      Locate <strong>SutraKey</strong> in the list and toggle the switch to <strong>ON</strong>.
                    </p>
                  </div>

                  <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.06]">
                    <span className="text-xs font-bold text-pink-500 font-mono">STEP 03</span>
                    <h4 className="text-sm font-semibold text-neutral-900 dark:text-white mt-1 mb-1">Ready to Use</h4>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400">
                      Hold <strong>Shift</strong> and drag-select any URL in Safari, Chrome, or Notes. The wheel appears!
                    </p>
                  </div>
                </div>
              </LiquidGlass>
            </section>

            {/* Authentication & Browser Keychain Guide */}
            <section className="space-y-4">
              <div className="flex items-center gap-2.5">
                <KeyRound className="w-5 h-5 text-amber-500" />
                <h2 className="text-xl font-bold text-neutral-900 dark:text-white">
                  Browser Cookies &amp; Keychain Access
                </h2>
              </div>

              <LiquidGlass radius={24} depth={1.2} blur={10} className="p-6 sm:p-8 space-y-4">
                <p className="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
                  Certain platforms (e.g. <strong>Instagram Stories</strong>, private feeds, or YouTube age-gated videos) require an active session. SutraKey can read cookies directly from your local browser without requiring manual export:
                </p>

                <div className="space-y-3 text-xs leading-relaxed text-neutral-600 dark:text-neutral-300">
                  <div className="flex items-start gap-3 p-3.5 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05]">
                    <CheckCircle2 size={16} className="text-emerald-500 shrink-0 mt-0.5" />
                    <div>
                      <strong className="text-neutral-900 dark:text-white">Configure Your Active Browser:</strong> In SutraKey Settings → Authentication, pick Brave, Chrome, Safari, Edge, or Arc.
                    </div>
                  </div>

                  <div className="flex items-start gap-3 p-3.5 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05]">
                    <CheckCircle2 size={16} className="text-emerald-500 shrink-0 mt-0.5" />
                    <div>
                      <strong className="text-neutral-900 dark:text-white">One-Time Keychain Authorization:</strong> Click &quot;Authorize &amp; Test Keychain Access&quot;. When macOS displays the system prompt, choose <strong>&quot;Always Allow&quot;</strong> so you don&apos;t have to type your password repeatedly.
                    </div>
                  </div>

                  <div className="flex items-start gap-3 p-3.5 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05]">
                    <CheckCircle2 size={16} className="text-emerald-500 shrink-0 mt-0.5" />
                    <div>
                      <strong className="text-neutral-900 dark:text-white">cookies.txt Fallback:</strong> If you prefer not using Keychain, you can point SutraKey to an exported cookies.txt file at any time.
                    </div>
                  </div>
                </div>
              </LiquidGlass>
            </section>

            {/* Output Formats Guide */}
            <section className="space-y-4">
              <div className="flex items-center gap-2.5">
                <FileDown className="w-5 h-5 text-blue-500" />
                <h2 className="text-xl font-bold text-neutral-900 dark:text-white">
                  Conversion Engine Formats
                </h2>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <LiquidGlass radius={20} depth={1.0} blur={8} className="p-5">
                  <Video className="w-6 h-6 text-pink-500 mb-2" />
                  <h4 className="text-sm font-semibold text-neutral-900 dark:text-white">Video (MP4)</h4>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                    Extracts highest resolution (up to 4K/8K 60fps) with audio streams multiplexed via ffmpeg.
                  </p>
                </LiquidGlass>

                <LiquidGlass radius={20} depth={1.0} blur={8} className="p-5">
                  <Music className="w-6 h-6 text-emerald-500 mb-2" />
                  <h4 className="text-sm font-semibold text-neutral-900 dark:text-white">Audio (MP3 / M4A)</h4>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                    Converts stream audio to 320kbps MP3 or lossless M4A with ID3 tags and album cover art embedded.
                  </p>
                </LiquidGlass>

                <LiquidGlass radius={20} depth={1.0} blur={8} className="p-5">
                  <Languages className="w-6 h-6 text-amber-500 mb-2" />
                  <h4 className="text-sm font-semibold text-neutral-900 dark:text-white">Subtitles (SRT/VTT)</h4>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                    Pulls clean closed captions or automated subtitle transcripts in your preferred language.
                  </p>
                </LiquidGlass>

                <LiquidGlass radius={20} depth={1.0} blur={8} className="p-5">
                  <FileText className="w-6 h-6 text-indigo-500 mb-2" />
                  <h4 className="text-sm font-semibold text-neutral-900 dark:text-white">Web to PDF</h4>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400 mt-1">
                    Uses Apple WebKit to capture the target page into a searchable, print-optimized vector PDF.
                  </p>
                </LiquidGlass>
              </div>
            </section>

            {/* FAQ Accordion / Grid */}
            <section className="space-y-4">
              <div className="flex items-center gap-2.5">
                <HelpCircle className="w-5 h-5 text-pink-500" />
                <h2 className="text-xl font-bold text-neutral-900 dark:text-white">
                  Frequently Asked Questions
                </h2>
              </div>

              <div className="space-y-3">
                {FAQS.map((faq, idx) => (
                  <LiquidGlass key={idx} radius={18} depth={1.0} blur={8} className="p-6">
                    <h3 className="text-sm font-bold text-neutral-900 dark:text-white mb-2">
                      {faq.q}
                    </h3>
                    <p className="text-xs sm:text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
                      {faq.a}
                    </p>
                  </LiquidGlass>
                ))}
              </div>
            </section>

            {/* Community & Assistance Banner */}
            <LiquidGlass radius={24} depth={1.4} blur={12} className="p-8 text-center space-y-4">
              <h3 className="text-lg font-bold text-neutral-900 dark:text-white">
                Still have questions or found a bug?
              </h3>
              <p className="text-xs sm:text-sm text-neutral-600 dark:text-neutral-300 max-w-lg mx-auto">
                SutraKey is actively maintained and continually tested across macOS releases. Open an issue on GitHub or reach out to the developer directly.
              </p>
              <div className="flex flex-wrap items-center justify-center gap-3 pt-2">
                <a
                  href="https://github.com/halcyon-past/SutraKey/issues"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-semibold bg-neutral-900 text-white dark:bg-white dark:text-neutral-900 hover:scale-105 transition-transform"
                >
                  GitHub Issues <ExternalLink size={12} />
                </a>
                <a
                  href="mailto:aritrosaha2025@gmail.com"
                  className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full text-xs font-semibold bg-black/[0.05] dark:bg-white/[0.08] text-neutral-800 dark:text-neutral-200 hover:bg-black/[0.08] dark:hover:bg-white/[0.12] transition-colors"
                >
                  Email Support
                </a>
              </div>
            </LiquidGlass>
          </div>
        </main>

        <Footer />
        </div>
      </div>
    </SmoothScrollProvider>
  );
}
