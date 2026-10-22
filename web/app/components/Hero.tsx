"use client";

import React, { useState } from "react";
import { Download, Check, Copy, Sparkles } from "lucide-react";
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
        {/* GitHub Stars & Forks Badge Pill */}
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
          className="mb-6 inline-flex justify-center"
        >
          <GitHubBadge />
        </motion.div>

        {/* Hero Title (Apple iPad Air inspired typography with pastel sheen) */}
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

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
          className="text-base sm:text-lg md:text-xl text-neutral-600 dark:text-neutral-300 font-normal max-w-2xl mx-auto leading-relaxed mb-8"
        >
          <strong className="font-semibold text-neutral-900 dark:text-white">SutraKey</strong> (also known as <strong className="font-semibold text-neutral-900 dark:text-white">Sutra Key</strong>) is an invisible thread connecting any highlighted text or URL to instant local media. 
          Zero latency. Zero telemetry. Straight to{" "}
          <span className="font-mono text-xs sm:text-sm px-2 py-0.5 rounded-md bg-black/[0.04] dark:bg-white/[0.08] text-neutral-800 dark:text-neutral-200 border border-black/[0.06] dark:border-white/[0.1]">
            ~/Downloads
          </span>.
        </motion.p>

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
            <span className="text-[11px] font-normal opacity-70 ml-0.5">Universal</span>
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
          <span>+ Select any URL in any app to summon the wheel</span>
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
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">100% Native</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">Swift 6 Concurrency</div>
          </motion.div>

          <motion.div
            whileHover={{ y: -2 }}
            className="px-4 py-3.5 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm flex flex-col items-center justify-center text-center transition-shadow hover:shadow-md"
          >
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">Zero Telemetry</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">Never touches a cloud</div>
          </motion.div>

          <motion.div
            whileHover={{ y: -2 }}
            className="px-4 py-3.5 rounded-2xl bg-white/60 dark:bg-white/[0.03] border border-black/[0.05] dark:border-white/[0.07] backdrop-blur-md shadow-sm flex flex-col items-center justify-center text-center transition-shadow hover:shadow-md"
          >
            <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">QuickTime Native</div>
            <div className="text-[11px] text-neutral-500 dark:text-neutral-400 mt-0.5">H.264 / AAC MP4</div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
