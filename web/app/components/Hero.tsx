"use client";

import React, { useState } from "react";
import { Download, Check, Copy, Sparkles, UserCheck } from "lucide-react";
import { motion } from "motion/react";
import { LiquidGlass } from "./LiquidGlass";
import { GitHubBadge } from "./GitHubBadge";

export function Hero() {
  const [copied, setCopied] = useState(false);

  const copyHomebrew = () => {
    navigator.clipboard.writeText("brew install --cask halcyon-past/tap/sutrakey");
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <section className="relative pt-10 pb-8 md:pt-16 md:pb-12 overflow-hidden px-4">
      <div className="max-w-4xl mx-auto text-center flex flex-col items-center">
        {/* Top Badges Row: GitHub Stars + Developer Attribution */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
          className="mb-6 flex flex-wrap items-center justify-center gap-3"
        >
          <GitHubBadge />
          <a
            href="https://www.aritro.cloud/"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium bg-black/[0.04] dark:bg-white/[0.06] text-neutral-600 dark:text-neutral-300 border border-black/[0.06] dark:border-white/[0.08] hover:bg-black/[0.08] dark:hover:bg-white/[0.12] transition-colors"
          >
            <UserCheck size={12} className="text-pink-500" />
            <span>Built by <strong className="font-semibold text-neutral-900 dark:text-white">Aritro Saha (halcyon-past)</strong></span>
          </a>
        </motion.div>

        {/* Hero Title with Utility Keywords */}
        <motion.h1
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
          className="text-4xl sm:text-6xl md:text-7xl lg:text-8xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white leading-[1.08] mb-6 max-w-4xl mx-auto"
        >
          Hold Shift. <br className="hidden sm:inline" />
          <span className="bg-gradient-to-r from-emerald-600 via-teal-500 to-pink-500 dark:from-emerald-300 dark:via-teal-200 dark:to-pink-300 bg-clip-text text-transparent">
            Set media free.
          </span>
        </motion.h1>

        {/* Subtitle Addressing Core User Problem & Utility */}
        <motion.p
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
          className="text-base sm:text-lg md:text-xl text-neutral-600 dark:text-neutral-300 font-normal max-w-2xl mx-auto leading-relaxed mb-6"
        >
          Stop pasting links into sketchy, ad-filled download sites. <strong className="font-semibold text-neutral-900 dark:text-white">SutraKey</strong> is a free, open-source macOS utility by <a href="https://www.aritro.cloud/" target="_blank" rel="noopener noreferrer" className="underline hover:text-black dark:hover:text-white">Aritro Saha (halcyon-past)</a> that downloads 4K video, extracts 320kbps MP3 audio, or converts web articles to clean vector PDFs straight to{" "}
          <span className="font-mono text-xs sm:text-sm px-2 py-0.5 rounded-md bg-black/[0.04] dark:bg-white/[0.08] text-neutral-800 dark:text-neutral-200 border border-black/[0.06] dark:border-white/[0.1]">
            ~/Downloads
          </span>.
        </motion.p>

        {/* Utility Keywords Pills */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.25 }}
          className="flex flex-wrap items-center justify-center gap-2 mb-8 max-w-xl"
        >
          {["4K 60fps MP4", "320kbps MP3 + Artwork", "Subtitles (.SRT)", "Clean Web to PDF", "No Ads & Zero Telemetry"].map((badge) => (
            <span
              key={badge}
              className="text-[11px] font-medium px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-700 dark:text-emerald-300 border border-emerald-500/20"
            >
              {badge}
            </span>
          ))}
        </motion.div>

        {/* Action Lockup: Direct DMG + Homebrew Command */}
        <motion.div
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
          className="flex flex-col sm:flex-row items-center justify-center gap-3.5 w-full sm:w-auto mb-5"
        >
          {/* Direct Download Button */}
          <motion.a
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            href="https://github.com/halcyon-past/SutraKey/releases/latest/download/SutraKey.dmg"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto h-12 px-6 rounded-full bg-[#1d1d1f] text-white dark:bg-white dark:text-[#1d1d1f] font-semibold text-sm shadow-md flex items-center justify-center gap-2.5 cursor-pointer whitespace-nowrap"
          >
            <Download size={16} />
            <span>Download for macOS</span>
            <span className="text-[11px] font-normal opacity-70 ml-0.5">Universal (Apple Silicon &amp; Intel)</span>
          </motion.a>

          {/* Copyable Homebrew Pill (Liquid Glass) */}
          <motion.div whileHover={{ scale: 1.01 }} whileTap={{ scale: 0.99 }}>
            <LiquidGlass
              radius={9999}
              interactive
              onClick={copyHomebrew}
              className="w-full sm:w-auto h-12 rounded-full px-5 flex items-center justify-between gap-3.5 cursor-pointer group whitespace-nowrap"
            >
              <div className="flex items-center gap-2 font-mono text-xs text-neutral-800 dark:text-neutral-200">
                <span className="text-neutral-400 dark:text-neutral-500 select-none">$</span>
                <span>brew install --cask halcyon-past/tap/sutrakey</span>
              </div>
              <div className="w-5 h-5 rounded-full flex items-center justify-center text-neutral-500 group-hover:text-black dark:group-hover:text-white transition-colors shrink-0">
                {copied ? <Check size={13} className="text-emerald-500" /> : <Copy size={13} />}
              </div>
            </LiquidGlass>
          </motion.div>
        </motion.div>

        {/* Physical Apple Keycap Hint */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="inline-flex items-center justify-center gap-2.5 text-xs text-neutral-500 dark:text-neutral-400 mb-10"
        >
          <kbd className="keycap-apple px-2.5 py-1 bg-white dark:bg-[#1f1f26] text-neutral-800 dark:text-neutral-100 border border-black/10 dark:border-white/15 shadow-sm text-[11px] animate-pulse">
            ⇧ Shift
          </kbd>
          <span>+ Select any URL in any app to summon the wheel (or press ⌘⇧S)</span>
        </motion.div>

        {/* Feature Badges (Pristine, balanced specs grid with hover elevation) */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.5, ease: [0.16, 1, 0.3, 1] }}
          className="grid grid-cols-2 md:grid-cols-4 gap-3 max-w-3xl w-full mx-auto"
        >
          <motion.div
            whileHover={{ y: -2 }}
            className="px-4 py-3.5 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm flex flex-col items-center justify-center text-center transition-shadow hover:shadow-md"
          >
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">0% Idle CPU</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">Zero background drain</div>
          </motion.div>

          <motion.div
            whileHover={{ y: -2 }}
            className="px-4 py-3.5 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm flex flex-col items-center justify-center text-center transition-shadow hover:shadow-md"
          >
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">100% Native Swift 6</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">Engineered by Aritro Saha</div>
          </motion.div>

          <motion.div
            whileHover={{ y: -2 }}
            className="px-4 py-3.5 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm flex flex-col items-center justify-center text-center transition-shadow hover:shadow-md"
          >
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">Zero Telemetry</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">100% local, no trackers</div>
          </motion.div>

          <motion.div
            whileHover={{ y: -2 }}
            className="px-4 py-3.5 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm flex flex-col items-center justify-center text-center transition-shadow hover:shadow-md"
          >
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">QuickTime Ready</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">H.264 / AAC MP4</div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
