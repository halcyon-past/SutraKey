"use client";

import React, { useState } from "react";
import { Download, Check, Copy } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";
import { GitHubBadge } from "./GitHubBadge";

export function Hero() {
  const [copied, setCopied] = useState(false);

  const copyHomebrew = () => {
    navigator.clipboard.writeText("brew install sutrakey");
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <section className="relative pt-16 pb-16 md:pt-24 md:pb-24 overflow-hidden px-4">
      {/* Dynamic Ambient Pastel Lighting Pools (Serene Pink & Mint Mesh - iPad Air aesthetic) */}
      <div className="pointer-events-none absolute -top-16 left-1/2 -translate-x-3/4 w-[540px] h-[440px] rounded-full ambient-glow-pink blur-[90px] opacity-70 dark:opacity-40 animate-float-slow -z-10" />
      <div className="pointer-events-none absolute top-10 left-1/2 -translate-x-1/4 w-[580px] h-[480px] rounded-full ambient-glow-green blur-[110px] opacity-65 dark:opacity-35 animate-float-reverse -z-10" />
      <div className="pointer-events-none absolute top-40 left-1/2 -translate-x-1/2 w-[620px] h-[340px] rounded-full ambient-glow-iris blur-[120px] opacity-50 dark:opacity-20 -z-10" />

      <div className="max-w-4xl mx-auto text-center flex flex-col items-center">
        {/* GitHub Stars & Forks Badge Pill */}
        <div className="mb-6">
          <GitHubBadge />
        </div>

        {/* Hero Title (Apple iPad Air inspired typography with pastel sheen) */}
        <h1 className="text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white leading-[1.05] mb-6">
          Hold Shift. <br />
          <span className="bg-gradient-to-r from-emerald-600 via-teal-500 to-pink-500 dark:from-emerald-300 dark:via-teal-200 dark:to-pink-300 bg-clip-text text-transparent">
            Set media free.
          </span>
        </h1>

        {/* Subtitle */}
        <p className="text-lg sm:text-xl text-neutral-600 dark:text-neutral-300 font-normal max-w-2xl leading-relaxed mb-8">
          An invisible thread connecting any highlighted text or URL to instant local media. 
          Zero latency. Zero telemetry. Straight to{" "}
          <span className="font-mono text-sm px-2 py-0.5 rounded-md bg-black/[0.04] dark:bg-white/[0.08] text-neutral-800 dark:text-neutral-200 border border-black/[0.06] dark:border-white/[0.1]">
            ~/Downloads
          </span>.
        </p>

        {/* Physical Apple Keycap Badge */}
        <div className="mb-10 inline-flex items-center gap-3 px-4 py-2 rounded-2xl bg-black/[0.03] dark:bg-white/[0.04] border border-black/[0.06] dark:border-white/[0.08] text-xs text-neutral-600 dark:text-neutral-300 shadow-inner">
          <kbd className="keycap-apple px-2.5 py-1 bg-white dark:bg-[#202026] text-neutral-800 dark:text-neutral-100 border border-black/[0.12] dark:border-white/[0.15] shadow-[0_2px_0_rgba(0,0,0,0.08)] dark:shadow-[0_2px_0_rgba(0,0,0,0.5)]">
            ⇧ Shift
          </kbd>
          <span className="text-neutral-400 dark:text-neutral-500">+</span>
          <span className="font-medium">Select any URL or link in any app</span>
        </div>

        {/* Action Lockup: Direct DMG + Homebrew Command */}
        <div className="flex flex-col sm:flex-row items-center gap-3.5 mb-14 w-full sm:w-auto">
          {/* Direct Download Button */}
          <a
            href="https://github.com/halcyon-past/SutraKey/releases/latest"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-6 py-3.5 rounded-full bg-[#1d1d1f] text-white dark:bg-white dark:text-[#1d1d1f] font-semibold text-sm shadow-md hover:scale-[1.02] active:scale-[0.98] transition-all cursor-pointer"
          >
            <Download size={16} />
            <span>Download for macOS</span>
            <span className="text-[11px] font-normal opacity-70 ml-0.5">Universal</span>
          </a>

          {/* Copyable Homebrew Pill (Liquid Glass) */}
          <LiquidGlass
            radius={9999}
            depth={1.2}
            blur={6}
            dispersion={0.5}
            specular={0.5}
            interactive
            onClick={copyHomebrew}
            className="w-full sm:w-auto rounded-full px-5 py-3 flex items-center justify-between gap-3 cursor-pointer group"
          >
            <div className="flex items-center gap-2 font-mono text-xs text-neutral-800 dark:text-neutral-200">
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
          <div className="px-4 py-3 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">0% Idle CPU</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">Zero background drain</div>
          </div>
          <div className="px-4 py-3 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">100% Native</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">Swift 6 Concurrency</div>
          </div>
          <div className="px-4 py-3 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">Zero Telemetry</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">Never touches a cloud</div>
          </div>
          <div className="px-4 py-3 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm">
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">QuickTime Native</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400">H.264 / AAC MP4</div>
          </div>
        </div>
      </div>
    </section>
  );
}
