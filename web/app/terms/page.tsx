import type { Metadata } from "next";
import Link from "next/link";
import { Navbar } from "../components/Navbar";
import { Footer } from "../components/Footer";
import { LiquidGlass } from "../components/LiquidGlass";
import { SmoothScrollProvider } from "../components/SmoothScrollProvider";
import { FileText, Scale, CheckCircle2, AlertTriangle, ArrowLeft } from "lucide-react";

export const metadata: Metadata = {
  title: "Terms of Service — Open-Source License & Fair Use",
  description:
    "SutraKey Terms of Service and open-source MIT license conditions for the native macOS radial media and document downloader.",
  alternates: {
    canonical: "/terms",
  },
  openGraph: {
    title: "Terms of Service — SutraKey for macOS",
    description:
      "Open-source MIT license details and acceptable fair use guidelines for the SutraKey macOS utility.",
    url: "https://sutrakey.aritro.cloud/terms",
    images: ["/og-image.jpg"],
  },
};

export default function TermsPage() {
  return (
    <SmoothScrollProvider>
      <div className="relative min-h-screen flex flex-col bg-[#fafafc] text-[#1d1d1f] dark:bg-[#0b0b0f] dark:text-[#f5f5f7] transition-colors duration-400 overflow-x-hidden">
        {/* Ambient Glows */}
        <div className="pointer-events-none fixed inset-0 overflow-hidden z-0 contain-paint">
          <div className="absolute top-[10%] right-[-10%] w-[500px] h-[500px] rounded-full ambient-glow-pink opacity-40 dark:opacity-20" />
          <div className="absolute top-[50%] left-[-10%] w-[550px] h-[550px] rounded-full ambient-glow-green opacity-40 dark:opacity-15" />
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
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-blue-500/10 text-blue-600 dark:text-blue-400 border border-blue-500/20 mb-4">
              <Scale size={14} />
              Open-Source MIT License • Transparent &amp; Permissive
            </div>
            <h1 className="text-3xl sm:text-5xl font-bold tracking-tight text-neutral-900 dark:text-white mb-3">
              Terms of Service
            </h1>
            <p className="text-sm font-mono text-neutral-500 dark:text-neutral-400">
              Effective Date: October 21, 2026 • Version 1.0.0
            </p>
          </div>

          <LiquidGlass radius={28} depth={1.2} blur={10} className="p-8 sm:p-12 space-y-10">
            {/* Section 1 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                1. Acceptance of Terms
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                By downloading, compiling, or using SutraKey (&quot;the Software&quot;), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not install or use the Software.
              </p>
            </section>

            {/* Section 2 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                <FileText size={18} className="text-pink-500" />
                2. MIT License Grant
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                SutraKey is free, open-source software licensed under the terms of the MIT License. You are granted permission, free of charge, to use, copy, modify, merge, publish, distribute, and sublicense copies of the Software, subject to the condition that the copyright notice and license are retained in all substantial portions of the Software.
              </p>
            </section>

            {/* Section 3 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                <CheckCircle2 size={18} className="text-emerald-500" />
                3. Permitted &amp; Acceptable Use
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                SutraKey is designed as a productivity helper for personal media archiving, offline reading, and educational research. You agree to use SutraKey strictly in compliance with applicable local and international copyright and computer laws:
              </p>
              <ul className="list-disc pl-5 space-y-2 text-sm text-neutral-600 dark:text-neutral-300">
                <li>You may only download or convert media and documents that you own, have licensed, or have a legitimate right to access under fair use or public domain provisions.</li>
                <li>You may not use the Software to circumvent DRM systems, infringe intellectual property, or engage in malicious scraping against terms of service of third-party platforms.</li>
                <li>You are solely responsible for ensuring you have appropriate authorization for any session cookies loaded into the app.</li>
              </ul>
            </section>

            {/* Section 4 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                <AlertTriangle size={18} className="text-amber-500" />
                4. Disclaimer of Warranties &amp; Limitation of Liability
              </h2>
              <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05] text-xs leading-relaxed text-neutral-600 dark:text-neutral-300 font-mono">
                THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE.
              </div>
            </section>

            {/* Section 5 */}
            <section className="space-y-3">
              <h2 className="text-lg font-bold text-neutral-900 dark:text-white flex items-center gap-2">
                5. Contact Information
              </h2>
              <p className="text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                For questions regarding these Terms of Service:
              </p>
              <div className="p-4 rounded-xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.05] text-xs space-y-1 font-mono">
                <div><strong className="text-neutral-900 dark:text-white font-sans">Developer:</strong> Aritro Saha</div>
                <div><strong className="text-neutral-900 dark:text-white font-sans">Email:</strong> <a href="mailto:aritrosaha2025@gmail.com" className="text-pink-500 hover:underline">aritrosaha2025@gmail.com</a></div>
                <div><strong className="text-neutral-900 dark:text-white font-sans">Repository:</strong> <a href="https://github.com/halcyon-past/SutraKey" className="text-pink-500 hover:underline">https://github.com/halcyon-past/SutraKey</a></div>
              </div>
            </section>
          </LiquidGlass>
        </main>

        <Footer />
        </div>
      </div>
    </SmoothScrollProvider>
  );
}
