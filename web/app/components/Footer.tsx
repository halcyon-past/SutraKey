"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";

export function Footer() {
  return (
    <footer className="pt-16 pb-12 px-4 border-t border-black/[0.06] dark:border-white/[0.08] text-xs text-neutral-500 dark:text-neutral-400">
      <div className="max-w-5xl mx-auto flex flex-col gap-10">
        {/* Brand & Etymology Row */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <Link href="/" className="flex items-center gap-3 group">
            <div className="relative w-7 h-7 rounded-[8px] overflow-hidden shadow-sm group-hover:scale-105 transition-transform">
              <Image
                src="/logo.webp"
                alt="SutraKey App Icon"
                width={28}
                height={28}
                className="w-7 h-7 object-cover"
                loading="lazy"
              />
            </div>
            <div>
              <span className="font-semibold text-neutral-900 dark:text-neutral-100 text-sm">
                SutraKey / Sutra Key (सूत्र)
              </span>
              <span className="block text-[11px] text-neutral-400 dark:text-neutral-500">
                macOS Radial Media &amp; PDF Utility
              </span>
            </div>
          </Link>

          <p className="text-xs text-neutral-500 dark:text-neutral-400 italic max-w-md">
            &ldquo;Sutra&rdquo; (सूत्र) is Sanskrit for a thread holding pearls together. SutraKey is the thread connecting your selection to pure media.
          </p>
        </div>

        {/* Link Columns */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-6 pt-2">
          {/* Column 1: Product & Docs */}
          <div className="flex flex-col gap-2">
            <span className="font-semibold text-neutral-900 dark:text-white text-xs uppercase tracking-wider">
              Product &amp; Help
            </span>
            <Link href="/support" className="hover:text-black dark:hover:text-white transition-colors">
              Support &amp; User Guide
            </Link>
            <Link href="/#simulator" className="hover:text-black dark:hover:text-white transition-colors">
              Interactive Simulator
            </Link>
            <Link href="/#formats" className="hover:text-black dark:hover:text-white transition-colors">
              Supported Formats
            </Link>
            <Link href="/#installation" className="hover:text-black dark:hover:text-white transition-colors">
              Installation Guide
            </Link>
          </div>

          {/* Column 2: Legal & Trust */}
          <div className="flex flex-col gap-2">
            <span className="font-semibold text-neutral-900 dark:text-white text-xs uppercase tracking-wider">
              Legal &amp; Trust
            </span>
            <Link href="/privacy" className="hover:text-black dark:hover:text-white transition-colors">
              Privacy Policy (0% Telemetry)
            </Link>
            <Link href="/terms" className="hover:text-black dark:hover:text-white transition-colors">
              Terms of Service
            </Link>
            <a
              href="https://github.com/halcyon-past/SutraKey/blob/main/SECURITY.md"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-black dark:hover:text-white transition-colors"
            >
              Security Policy
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey/blob/main/CODE_OF_CONDUCT.md"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-black dark:hover:text-white transition-colors"
            >
              Code of Conduct
            </a>
          </div>

          {/* Column 3: AI & Machine Endpoints */}
          <div className="flex flex-col gap-2">
            <span className="font-semibold text-neutral-900 dark:text-white text-xs uppercase tracking-wider">
              Machine Endpoints
            </span>
            <a href="/llms.txt" className="hover:text-black dark:hover:text-white font-mono text-[11px] transition-colors">
              llms.txt (LLM Summary)
            </a>
            <a href="/llms-full.txt" className="hover:text-black dark:hover:text-white font-mono text-[11px] transition-colors">
              llms-full.txt (Full KB)
            </a>
            <a href="/ai.txt" className="hover:text-black dark:hover:text-white font-mono text-[11px] transition-colors">
              ai.txt (Crawler Policy)
            </a>
            <a href="/sitemap.xml" className="hover:text-black dark:hover:text-white font-mono text-[11px] transition-colors">
              sitemap.xml
            </a>
          </div>

          {/* Column 4: Community & Source */}
          <div className="flex flex-col gap-2">
            <span className="font-semibold text-neutral-900 dark:text-white text-xs uppercase tracking-wider">
              Open Source
            </span>
            <a
              href="https://github.com/halcyon-past/SutraKey"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-black dark:hover:text-white transition-colors"
            >
              GitHub Repository
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey/releases/latest"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-black dark:hover:text-white transition-colors"
            >
              Release Downloads
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey/blob/main/LICENSE"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-black dark:hover:text-white transition-colors"
            >
              MIT License
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey/issues"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-black dark:hover:text-white transition-colors"
            >
              Issue Tracker
            </a>
          </div>
        </div>

        {/* Legal Disclaimer, Author Attribution & Copyright */}
        <div className="pt-6 border-t border-black/[0.04] dark:border-white/[0.04] flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 text-[11px] text-neutral-400 dark:text-neutral-500">
          <div>
            Created by{" "}
            <a
              href="https://www.aritro.cloud/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-neutral-700 dark:text-neutral-300 hover:text-black dark:hover:text-white font-medium underline transition-colors"
            >
              Aritro Saha
            </a>
            . Released under the MIT License.
          </div>
          <div>
            Native Swift 6 • Apple Silicon &amp; Intel Universal • macOS 14+
          </div>
        </div>
      </div>
    </footer>
  );
}
