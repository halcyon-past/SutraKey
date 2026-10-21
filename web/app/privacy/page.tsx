import type { Metadata } from "next";
import Link from "next/link";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { LiquidGlass } from "../components/LiquidGlass";
import { ShieldCheck, Lock, EyeOff, HardDrive, KeyRound, Globe, ArrowLeft } from "lucide-react";

export const metadata: Metadata = {
  title: "Privacy Policy — Zero-Telemetry On-Device Media Processing",
  description:
    "SutraKey Privacy Policy. 100% on-device media and document conversion on macOS with zero telemetry, zero analytics, zero external proxies, and strict local sandboxing.",
  alternates: {
    canonical: "/privacy",
  },
  openGraph: {
    title: "Privacy Policy — SutraKey for macOS",
    description:
      "100% on-device media and document conversion. Zero telemetry, zero analytics, and zero external proxy servers.",
    url: "https://sutrakey.aritro.cloud/privacy",
  },
};

export default function PrivacyPage() {
  return (
    <div className="relative min-h-screen flex flex-col bg-[#fafafc] text-[#1d1d1f] dark:bg-[#0b0b0f] dark:text-[#f5f5f7] transition-colors duration-400 overflow-x-hidden">
      {/* Ambient Glows */}
      <div className="pointer-events-none fixed inset-0 overflow-hidden z-0">
        <div className="absolute top-[10%] right-[-10%] w-[500px] h-[500px] rounded-full ambient-glow-pink blur-[120px] opacity-40 dark:opacity-20 animate-float-slow" />
        <div className="absolute top-[50%] left-[-10%] w-[550px] h-[550px] rounded-full ambient-glow-green blur-[130px] opacity-40 dark:opacity-15 animate-float-reverse" />
      </div>

      <div className="relative z-10 flex flex-col min-h-screen">
        <Navbar />

        <main className="flex-1 max-w-4xl mx-auto px-6 pt-12 pb-24 w-full">
          {/* Back link */}
          <Link
            href="/"
            className="inline-flex items-center gap-2 text-xs font-medium text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white transition-colors mb-8 group"
          >
            <ArrowLeft size={14} className="group-hover:-translate-x-1 transition-transform" />
            Back to Overview
          </Link>

          {/* Header */}
          <div className="mb-10">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20 mb-4">
              <ShieldCheck size={14} />
              100% Local &amp; Private • Zero Telemetry
            </div>
            <h1 className="text-3xl sm:text-5xl font-bold tracking-tight text-neutral-900 dark:text-white mb-3">
              Privacy Policy
            </h1>
            <p className="text-sm font-mono text-neutral-500 dark:text-neutral-400">
              Effective Date: October 21, 2026 • Version 1.0.0
            </p>
          </div>

          <LiquidGlass radius={28} depth={1.2} blur={10} className="p-8 sm:p-12 space-y-10">
            {/* Highlights Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pb-4 border-b border-black/[0.06] dark:border-white/[0.08]">
              <div className="p-4 rounded-2xl bg-black/[0.02] dark:bg-white/[0.03] border border-black/[0.04] dark:border-white/[0.06]">
                <EyeOff className="w-5 h-5 text-pink-500 mb-2" />
                <h4 className="text-sm font-semibold text-neutral-900 dark:text-white mb-1">Zero Telemetry</h4>
                <p className="text-xs text-neutral-600 dark:text-neutral-400 leading-relaxed">
                  No analytics SDKs, tracking pixels, or diagnostic pings are embedded in the binary.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/[0.02] dark:bg-white/[0.03] border border-black/[0.04] dark:border-white/[0.06]">
                <HardDrive className="w-5 h-5 text-emerald-500 mb-2" />
                <h4 className="text-sm font-semibold text-neutral-900 dark:text-white mb-1">Local Sandboxing</h4>
                <p className="text-xs text-neutral-600 dark:text-neutral-400 leading-relaxed">
                  Downloads and WebKit renders stay inside your user account and standard Downloads directory.
                </p>
              </div>

              <div className="p-4 rounded-2xl bg-black/[0.02] dark:bg-white/[0.03] border border-black/[0.04] dark:border-white/[0.06]">
                <Lock className="w-5 h-5 text-blue-500 mb-2" />
                <h4 className="text-sm font-semibold text-neutral-900 dark:text-white mb-1">No Cloud Relays</h4>
                <p className="text-xs text-neutral-600 dark:text-neutral-400 leading-relaxed">
                  Your network requests connect straight to the source media server without any proxy middleman.
                </p>
              </div>
            </div>

            {/* Section 1 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                1. Overview &amp; Philosophy
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                SutraKey is developed by Aritro Saha. We believe privacy is a fundamental human right. SutraKey is engineered to operate strictly on-device without telemetry, user tracking, or cloud processing. The app operates as an invisible helper on your Mac, intercepting your Shift+Select gesture to summon the radial menu without ever logging your browsing history.
              </p>
            </section>

            {/* Section 2 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                2. Information We Do NOT Collect
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                We do not collect, transmit, log, or sell any personal data:
              </p>
              <ul className="list-disc pl-5 space-y-2 text-sm text-neutral-600 dark:text-neutral-300">
                <li><strong className="text-neutral-900 dark:text-white">No Selected URLs or Text:</strong> When you select text with Shift held down, the URL is sanitized and evaluated strictly in volatile RAM to show available download options. It is discarded immediately.</li>
                <li><strong className="text-neutral-900 dark:text-white">No Content Inspection:</strong> Videos, audio streams, and web pages are downloaded directly via your Mac&apos;s connection to your chosen destination folder.</li>
                <li><strong className="text-neutral-900 dark:text-white">No Analytics:</strong> There are zero telemetry endpoints, Google Analytics tags, crash reporters, or device identifiers.</li>
                <li><strong className="text-neutral-900 dark:text-white">No Network Relays:</strong> SutraKey operates with direct client sockets. No network traffic is routed through our servers.</li>
              </ul>
            </section>

            {/* Section 3 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                <KeyRound size={18} className="text-amber-500" />
                3. Permissions &amp; System Access
              </h2>
              <div className="space-y-4 text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05]">
                  <h3 className="font-semibold text-neutral-900 dark:text-white mb-1">
                    Accessibility Permission (CGEventTap)
                  </h3>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400">
                    SutraKey uses macOS Accessibility APIs exclusively to listen for mouse selection coordinates and verify that the Shift modifier key is held. It does not record keystrokes, intercept passwords, or monitor other applications.
                  </p>
                </div>

                <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05]">
                  <h3 className="font-semibold text-neutral-900 dark:text-white mb-1">
                    Browser Keychain Access (Optional for Private Streams)
                  </h3>
                  <p className="text-xs text-neutral-500 dark:text-neutral-400">
                    To download authenticated content (like Instagram Stories or subscriber playlists) from your active browser session, SutraKey interfaces with the macOS Keychain to read your browser&apos;s local cookie decryption key. These keys remain strictly on your device and are never exported.
                  </p>
                </div>
              </div>
            </section>

            {/* Section 4 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                <HardDrive size={18} className="text-indigo-500" />
                4. Local Storage
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                All data created by the app resides locally within your macOS user account:
              </p>
              <div className="overflow-x-auto text-xs">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-black/[0.08] dark:border-white/[0.1] text-neutral-900 dark:text-white">
                      <th className="py-2 pr-4 font-semibold">Data</th>
                      <th className="py-2 pr-4 font-semibold">Location</th>
                      <th className="py-2 font-semibold">Lifespan</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-black/[0.04] dark:divide-white/[0.06] text-neutral-600 dark:text-neutral-300 font-mono">
                    <tr>
                      <td className="py-2.5 pr-4 font-sans font-medium text-neutral-900 dark:text-white">Downloaded Files</td>
                      <td className="py-2.5 pr-4">~/Downloads</td>
                      <td className="py-2.5 font-sans">Until moved or deleted by you</td>
                    </tr>
                    <tr>
                      <td className="py-2.5 pr-4 font-sans font-medium text-neutral-900 dark:text-white">User Preferences</td>
                      <td className="py-2.5 pr-4">~/Library/Preferences/com.sutrakey.macos.plist</td>
                      <td className="py-2.5 font-sans">Persistent until reset</td>
                    </tr>
                    <tr>
                      <td className="py-2.5 pr-4 font-sans font-medium text-neutral-900 dark:text-white">Task History</td>
                      <td className="py-2.5 pr-4">~/Library/Application Support/SutraKey/</td>
                      <td className="py-2.5 font-sans">Clearable from Settings</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </section>

            {/* Section 5 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                <Globe size={18} className="text-emerald-500" />
                5. Contact &amp; Security
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                For questions or security concerns regarding this Privacy Policy, please contact:
              </p>
              <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05] text-xs space-y-1 font-mono">
                <div><strong className="text-neutral-900 dark:text-white font-sans">Developer:</strong> Aritro Saha</div>
                <div><strong className="text-neutral-900 dark:text-white font-sans">Security Inquiries:</strong> <a href="mailto:security@sutrakey.aritro.cloud" className="text-pink-500 hover:underline">security@sutrakey.aritro.cloud</a></div>
                <div><strong className="text-neutral-900 dark:text-white font-sans">Personal:</strong> <a href="mailto:aritrosaha2025@gmail.com" className="text-pink-500 hover:underline">aritrosaha2025@gmail.com</a></div>
                <div><strong className="text-neutral-900 dark:text-white font-sans">Website:</strong> <a href="https://sutrakey.aritro.cloud" className="text-pink-500 hover:underline">https://sutrakey.aritro.cloud</a></div>
              </div>
            </section>
          </LiquidGlass>
        </main>

        <Footer />
      </div>
    </div>
  );
}
