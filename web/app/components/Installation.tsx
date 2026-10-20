"use client";

import React, { useState } from "react";
import { Download, Copy, Check, Terminal, Shield, ExternalLink } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";

export function Installation() {
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null);

  const copyText = (text: string, index: number) => {
    navigator.clipboard.writeText(text);
    setCopiedIndex(index);
    setTimeout(() => setCopiedIndex(null), 2000);
  };

  return (
    <section id="installation" className="py-16 md:py-24 px-4 max-w-5xl mx-auto">
      {/* Section Header */}
      <div className="text-center max-w-2xl mx-auto mb-12">
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-3">
          Instant setup. Zero hassle.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300">
          Available via Homebrew or direct Universal DMG. 100% free, forever open source.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        {/* Method 1: Homebrew */}
        <LiquidGlass
          radius={24}
          depth={1.2}
          blur={6}
          dispersion={0.5}
          specular={0.4}
          tint="green"
          className="p-6 rounded-3xl flex flex-col justify-between"
        >
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 text-xs font-semibold mb-4">
              <Terminal size={12} />
              <span>Recommended</span>
            </div>
            <h3 className="text-xl font-semibold text-[#1d1d1f] dark:text-white mb-2">
              Homebrew Cask
            </h3>
            <p className="text-xs text-neutral-600 dark:text-neutral-300 mb-6 leading-relaxed">
              Automatic updates and seamless dependency management via Homebrew.
            </p>
          </div>

          <button
            onClick={() => copyText("brew install sutrakey", 1)}
            className="w-full flex items-center justify-between p-3 rounded-2xl bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.04] dark:border-white/[0.08] font-mono text-xs text-neutral-800 dark:text-neutral-200 hover:bg-black/[0.06] transition-colors cursor-pointer"
          >
            <span>brew install sutrakey</span>
            {copiedIndex === 1 ? <Check size={14} className="text-emerald-500" /> : <Copy size={14} className="text-neutral-400" />}
          </button>
        </LiquidGlass>

        {/* Method 2: Direct DMG */}
        <LiquidGlass
          radius={24}
          depth={1.2}
          blur={6}
          dispersion={0.5}
          specular={0.4}
          tint="pink"
          className="p-6 rounded-3xl flex flex-col justify-between"
        >
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-pink-500/10 text-pink-600 dark:text-pink-400 text-xs font-semibold mb-4">
              <Download size={12} />
              <span>Direct DMG</span>
            </div>
            <h3 className="text-xl font-semibold text-[#1d1d1f] dark:text-white mb-2">
              Universal Disk Image
            </h3>
            <p className="text-xs text-neutral-600 dark:text-neutral-300 mb-6 leading-relaxed">
              Standalone DMG bundle with embedded yt-dlp and ffmpeg binaries.
            </p>
          </div>

          <a
            href="https://github.com/halcyon-past/SutraKey/releases/latest"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full inline-flex items-center justify-center gap-2 py-3 rounded-2xl bg-[#1d1d1f] text-white dark:bg-white dark:text-[#1d1d1f] font-semibold text-xs shadow-sm hover:opacity-90 active:scale-95 transition-all"
          >
            <Download size={13} />
            <span>Download SutraKey.dmg</span>
          </a>
        </LiquidGlass>

        {/* Method 3: Build from Source */}
        <LiquidGlass
          radius={24}
          depth={1.2}
          blur={6}
          dispersion={0.5}
          specular={0.4}
          className="p-6 rounded-3xl flex flex-col justify-between"
        >
          <div>
            <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-black/5 dark:bg-white/10 text-neutral-700 dark:text-neutral-300 text-xs font-semibold mb-4">
              <Terminal size={12} />
              <span>Open Source</span>
            </div>
            <h3 className="text-xl font-semibold text-[#1d1d1f] dark:text-white mb-2">
              Swift 6 SPM Source
            </h3>
            <p className="text-xs text-neutral-600 dark:text-neutral-300 mb-6 leading-relaxed">
              Compile directly from source with zero external closed-source dependencies.
            </p>
          </div>

          <button
            onClick={() => copyText("git clone https://github.com/halcyon-past/SutraKey && cd SutraKey && swift build -c release", 2)}
            className="w-full flex items-center justify-between p-3 rounded-2xl bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.04] dark:border-white/[0.08] font-mono text-[11px] text-neutral-800 dark:text-neutral-200 hover:bg-black/[0.06] transition-colors cursor-pointer"
          >
            <span className="truncate">swift build -c release</span>
            {copiedIndex === 2 ? <Check size={14} className="text-emerald-500 shrink-0 ml-2" /> : <Copy size={14} className="text-neutral-400 shrink-0 ml-2" />}
          </button>
        </LiquidGlass>
      </div>

      {/* Permissions Transparency Note */}
      <div className="p-6 rounded-3xl bg-black/[0.02] dark:bg-white/[0.02] border border-black/[0.04] dark:border-white/[0.06] flex flex-col sm:flex-row items-start sm:items-center gap-4 text-xs text-neutral-600 dark:text-neutral-300">
        <div className="w-10 h-10 rounded-2xl bg-neutral-200/50 dark:bg-neutral-800/50 flex items-center justify-center shrink-0 text-neutral-700 dark:text-neutral-200">
          <Shield size={18} />
        </div>
        <div className="flex-1">
          <span className="font-semibold text-[#1d1d1f] dark:text-white">macOS Accessibility Notice: </span>
          SutraKey requests macOS Accessibility permission solely to read your active text highlight via Apple’s native AXUIElement API. It runs entirely on-device, never polls keystrokes, and never records your screen.
        </div>
        <a
          href="https://github.com/halcyon-past/SutraKey#accessibility"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-1 font-semibold text-neutral-900 dark:text-white hover:underline shrink-0"
        >
          <span>Read Audit</span>
          <ExternalLink size={12} />
        </a>
      </div>
    </section>
  );
}
