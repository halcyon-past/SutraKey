"use client";

import React from "react";
import Image from "next/image";
import { Download } from "lucide-react";
import { motion, useScroll, useSpring } from "motion/react";
import { LiquidGlass } from "./LiquidGlass";
import { GithubIcon } from "./GitHubBadge";

export function Navbar() {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 120,
    damping: 30,
    restDelta: 0.001,
  });

  return (
    <>
      {/* Top Reading Progress Bar (Hardware GPU accelerated) */}
      <motion.div
        style={{ scaleX }}
        className="fixed top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-emerald-400 via-pink-400 to-indigo-500 origin-left z-[100]"
      />

      <header className="sticky top-5 z-50 px-4 max-w-5xl mx-auto w-full">
        <LiquidGlass
          radius={9999}
          className="rounded-full px-6 py-2.5 flex items-center justify-between w-full"
        >
          {/* Brand Lockup */}
          <a href="/" className="flex items-center gap-2.5 group shrink-0">
            <div className="relative w-7 h-7 rounded-[8px] overflow-hidden shadow-sm group-hover:scale-105 transition-transform duration-200">
              <Image
                src="/logo.webp"
                alt="SutraKey App Icon"
                width={28}
                height={28}
                className="w-7 h-7 object-cover"
                priority
              />
            </div>
            <div className="flex items-center gap-1.5">
              <span className="font-semibold text-sm tracking-tight text-neutral-900 dark:text-white">
                SutraKey
              </span>
              <span className="text-[10px] font-medium tracking-wide text-neutral-500 dark:text-neutral-400 bg-black/[0.04] dark:bg-white/[0.08] px-1.5 py-0.5 rounded-full border border-black/[0.06] dark:border-white/[0.06]">
                v1.0
              </span>
            </div>
          </a>

          {/* Navigation Links */}
          <nav className="hidden md:flex items-center gap-6 lg:gap-8 text-[13px] font-medium text-neutral-600 dark:text-neutral-300">
            <a href="/#simulator" className="hover:text-black dark:hover:text-white transition-colors">
              Experience
            </a>
            <a href="/#highlights" className="hover:text-black dark:hover:text-white transition-colors">
              Highlights
            </a>
            <a href="/#formats" className="hover:text-black dark:hover:text-white transition-colors">
              Formats
            </a>
            <a href="/#platforms" className="hover:text-black dark:hover:text-white transition-colors">
              Platforms
            </a>
            <a href="/#compare" className="hover:text-black dark:hover:text-white transition-colors">
              Compare
            </a>
            <a href="/#faq" className="hover:text-black dark:hover:text-white transition-colors">
              FAQ
            </a>
            <a href="/#installation" className="hover:text-black dark:hover:text-white transition-colors">
              Install
            </a>
            <a href="/support" className="hover:text-black dark:hover:text-white transition-colors">
              Docs &amp; Support
            </a>
          </nav>

          {/* Action Controls */}
          <div className="flex items-center gap-3 shrink-0">
            {/* Minimal GitHub Link */}
            <motion.a
              whileHover={{ scale: 1.08 }}
              whileTap={{ scale: 0.94 }}
              href="https://github.com/halcyon-past/SutraKey"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="GitHub Repository"
              className="w-8 h-8 rounded-full flex items-center justify-center text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/10 transition-colors cursor-pointer"
            >
              <GithubIcon size={16} />
            </motion.a>

            {/* Primary Download Pill */}
            <motion.a
              whileHover={{ scale: 1.03 }}
              whileTap={{ scale: 0.97 }}
              href="https://github.com/halcyon-past/SutraKey/releases/latest/download/SutraKey.dmg"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 bg-[#1d1d1f] text-white dark:bg-white dark:text-[#0a0a0c] text-xs font-semibold px-4 py-2 rounded-full shadow-sm whitespace-nowrap cursor-pointer"
            >
              <Download size={13} />
              <span>Get SutraKey</span>
            </motion.a>
          </div>
        </LiquidGlass>
      </header>
    </>
  );
}
