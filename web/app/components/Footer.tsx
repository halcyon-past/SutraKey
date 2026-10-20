"use client";

import React from "react";
import Image from "next/image";

export function Footer() {
  return (
    <footer className="pt-16 pb-12 px-4 border-t border-black/[0.06] dark:border-white/[0.08] text-xs text-neutral-500 dark:text-neutral-400">
      <div className="max-w-5xl mx-auto flex flex-col gap-8">
        {/* Brand & Etymology Row */}
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div className="flex items-center gap-3">
            <div className="relative w-6 h-6 rounded-[7px] overflow-hidden shadow-sm">
              <Image src="/AppIcon-1024.png" alt="SutraKey App Icon" fill className="object-cover" />
            </div>
            <span className="font-semibold text-neutral-800 dark:text-neutral-200">
              SutraKey (सूत्र)
            </span>
          </div>

          <p className="text-xs text-neutral-400 dark:text-neutral-500 italic max-w-md">
            &ldquo;Sutra&rdquo; (सूत्र) is Sanskrit for a thread holding pearls together. SutraKey is the thread connecting your selection to pure media.
          </p>
        </div>

        {/* Links Row */}
        <div className="flex flex-wrap items-center gap-x-6 gap-y-2 text-xs">
          <a
            href="https://github.com/halcyon-past/SutraKey"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-black dark:hover:text-white transition-colors"
          >
            GitHub Repository
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
            href="https://github.com/halcyon-past/SutraKey/issues/new?template=bug_report.md"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-black dark:hover:text-white transition-colors"
          >
            Report an Issue
          </a>
          <a
            href="https://github.com/halcyon-past/SutraKey/issues/new?template=feature_request.md"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-black dark:hover:text-white transition-colors"
          >
            Request a Format
          </a>
        </div>

        {/* Legal Disclaimer & Copyright */}
        <div className="pt-4 border-t border-black/[0.04] dark:border-white/[0.04] flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 text-[11px] text-neutral-400 dark:text-neutral-500">
          <div>
            Copyright © 2026 SutraKey Open Source Contributors. Licensed under MIT.
          </div>
          <div>
            Native macOS Utility • Apple Silicon &amp; Intel Universal
          </div>
        </div>
      </div>
    </footer>
  );
}
