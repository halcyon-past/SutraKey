"use client";

import React, { useState } from "react";
import { Download, Check, Copy } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";

export function Hero() {
  const [copied, setCopied] = useState(false);

  const copyHomebrew = () => {
    navigator.clipboard.writeText("brew install sutrakey");
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <section className="relative pt-20 pb-16 md:pt-28 md:pb-24 overflow-hidden px-4">
      {/* Soft Ambient Pastel Lighting Pools (Serene Pink & Mint) */}
      <div className="pointer-events-none absolute top-10 left-1/2 -translate-x-3/4 w-[480px] h-[360px] rounded-full ambient-glow-pink blur-[100px] -z-10" />
      <div className="pointer-events-none absolute top-24 left-1/2 -translate-x-1/4 w-[520px] h-[400px] rounded-full ambient-glow-green blur-[120px] -z-10" />

      <div className="max-w-4xl mx-auto text-center flex flex-col items-center">
        {/* Eyebrow Badge */}
        <div className="mb-6 inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.06] dark:border-white/[0.1] text-xs font-medium text-neutral-600 dark:text-neutral-300">
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
          <span>SutraKey for macOS</span>
          <span className="text-neutral-300 dark:text-neutral-600">•</span>
          <span>100% Free & Open Source</span>
        </div>

        {/* Hero Title (Apple iPad Air inspired typography) */}
        <h1 className="text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white leading-[1.06] mb-6">
          Hold Shift. <br />
          <span className="bg-gradient-to-r from-emerald-600 via-teal-500 to-pink-500 dark:from-emerald-400 dark:via-teal-300 dark:to-pink-400 bg-clip-text text-transparent">
            Set media free.
          </span>
        </h1>

        {/* Subtitle */}
        <p className="text-lg sm:text-xl text-neutral-600 dark:text-neutral-300 font-normal max-w-2xl leading-relaxed mb-10">
          An invisible thread connecting any text or URL selection to instant local media. 
          Zero latency. Zero telemetry. Straight to <span className="font-mono text-sm px-1.5 py-0.5 rounded bg-black/5 dark:bg-white/10 text-neutral-800 dark:text-neutral-200">~/Downloads</span>.
        </p>

        {/* Action Lockup: Direct DMG + Homebrew Command */}
        <div className="flex flex-col sm:flex-row items-center gap-3.5 mb-12">
          {/* Direct Download Button */}
          <a
            href="https://github.com/halcyon-past/SutraKey/releases/latest"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-full bg-[#1d1d1f] text-white dark:bg-white dark:text-[#1d1d1f] font-semibold text-sm shadow-md hover:scale-[1.02] active:scale-[0.98] transition-all"
          >
            <Download size={16} />
            <span>Download for macOS</span>
            <span className="text-[11px] font-normal opacity-70 ml-1">Universal</span>
          </a>

          {/* Copyable Homebrew Pill (Liquid Glass) */}
          <LiquidGlass
            radius={9999}
            depth={1.2}
            blur={5}
            dispersion={0.5}
            specular={0.4}
            interactive
            onClick={copyHomebrew}
            className="w-full sm:w-auto rounded-full px-5 py-3 flex items-center justify-between gap-3 cursor-pointer group"
          >
            <div className="flex items-center gap-2 font-mono text-xs text-neutral-700 dark:text-neutral-200">
              <span className="text-neutral-400 dark:text-neutral-500 select-none">$</span>
              <span>brew install sutrakey</span>
            </div>
            <div className="w-5 h-5 rounded-full flex items-center justify-center text-neutral-500 group-hover:text-black dark:group-hover:text-white transition-colors">
              {copied ? <Check size={13} className="text-emerald-500" /> : <Copy size={13} />}
            </div>
          </LiquidGlass>
        </div>

        {/* Feature Badges (Pristine, uncluttered specs) */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 max-w-2xl w-full text-center">
          <div className="px-3 py-2.5 rounded-2xl bg-black/[0.02] dark:bg-white/[0.03] border border-black/[0.04] dark:border-white/[0.06]">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">0% Idle CPU</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">Zero battery drain</div>
          </div>
          <div className="px-3 py-2.5 rounded-2xl bg-black/[0.02] dark:bg-white/[0.03] border border-black/[0.04] dark:border-white/[0.06]">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">100% Native</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">Swift 6 Concurrency</div>
          </div>
          <div className="px-3 py-2.5 rounded-2xl bg-black/[0.02] dark:bg-white/[0.03] border border-black/[0.04] dark:border-white/[0.06]">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">Zero Telemetry</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">Never touches a cloud</div>
          </div>
          <div className="px-3 py-2.5 rounded-2xl bg-black/[0.02] dark:bg-white/[0.03] border border-black/[0.04] dark:border-white/[0.06]">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">QuickTime Native</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">H.264 / AAC MP4</div>
          </div>
        </div>
      </div>
    </section>
  );
}
