"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { Download, Menu, X } from "lucide-react";
import { motion, useScroll, useSpring, AnimatePresence } from "motion/react";
import { LiquidGlass } from "./LiquidGlass";
import { GithubIcon } from "./GitHubBadge";

const NAV_LINKS = [
  { label: "Features", href: "/#highlights" },
  { label: "Formats", href: "/#formats" },
  { label: "Platforms", href: "/#platforms" },
  { label: "Compare", href: "/#compare" },
  { label: "FAQ", href: "/#faq" },
  { label: "Install", href: "/#installation" },
  { label: "Docs", href: "/support" },
];

export function Navbar() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
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
        className="fixed top-0 left-0 right-0 h-[2.5px] bg-gradient-to-r from-emerald-400 via-pink-400 to-indigo-500 origin-left z-[100]"
      />

      <header className="sticky top-4 sm:top-6 z-50 px-4 sm:px-6 max-w-6xl mx-auto w-full transition-all duration-300">
        <LiquidGlass
          radius={9999}
          className="rounded-full px-5 sm:px-8 py-3 sm:py-3.5 flex items-center justify-between w-full shadow-[0_12px_40px_-12px_rgba(0,0,0,0.08)] dark:shadow-[0_16px_48px_-12px_rgba(0,0,0,0.6)] border-black/[0.08] dark:border-white/[0.14]"
        >
          {/* Brand Lockup (Spacious, prominent) */}
          <Link href="/" className="flex items-center gap-3 group shrink-0 py-0.5">
            <div className="relative w-8 h-8 sm:w-9 sm:h-9 rounded-[10px] overflow-hidden shadow-md group-hover:scale-105 transition-transform duration-200">
              <Image
                src="/logo.webp"
                alt="SutraKey App Icon"
                width={36}
                height={36}
                className="w-full h-full object-cover"
                priority
              />
            </div>
            <div className="flex items-center gap-2">
              <span className="font-semibold text-base sm:text-[17px] tracking-tight text-neutral-900 dark:text-white">
                SutraKey
              </span>
              <span className="text-[11px] font-medium tracking-wide text-neutral-500 dark:text-neutral-400 bg-black/[0.04] dark:bg-white/[0.08] px-2 py-0.5 rounded-full border border-black/[0.06] dark:border-white/[0.08]">
                v1.0
              </span>
            </div>
          </Link>

          {/* Desktop Navigation Links (Roomy, clear typography) */}
          <nav className="hidden lg:flex items-center gap-7 xl:gap-8 text-sm font-medium text-neutral-600 dark:text-neutral-300">
            {NAV_LINKS.map((link) => (
              <a
                key={link.label}
                href={link.href}
                className="hover:text-black dark:hover:text-white transition-colors duration-150 py-1"
              >
                {link.label}
              </a>
            ))}
          </nav>

          {/* Action Controls */}
          <div className="flex items-center gap-2.5 sm:gap-3.5 shrink-0">
            {/* GitHub Link */}
            <motion.a
              whileHover={{ scale: 1.06 }}
              whileTap={{ scale: 0.94 }}
              href="https://github.com/halcyon-past/SutraKey"
              target="_blank"
              rel="noopener noreferrer"
              aria-label="GitHub Repository"
              className="w-9 h-9 sm:w-10 sm:h-10 rounded-full flex items-center justify-center text-neutral-600 dark:text-neutral-300 hover:text-black dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/10 transition-colors cursor-pointer"
            >
              <GithubIcon size={18} />
            </motion.a>

            {/* Primary Download Pill (Generous touch target, easy to click) */}
            <motion.a
              whileHover={{ scale: 1.03 }}
              whileTap={{ scale: 0.97 }}
              href="https://github.com/halcyon-past/SutraKey/releases/latest/download/SutraKey.dmg"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 bg-[#1d1d1f] text-white dark:bg-white dark:text-[#0a0a0c] text-xs sm:text-sm font-semibold h-9 sm:h-10 px-4 sm:px-5 rounded-full shadow-sm hover:shadow-md transition-shadow whitespace-nowrap cursor-pointer"
            >
              <Download size={14} className="shrink-0" />
              <span>Get SutraKey</span>
            </motion.a>

            {/* Mobile Menu Toggle Button */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="lg:hidden w-9 h-9 rounded-full flex items-center justify-center text-neutral-600 dark:text-neutral-300 hover:text-black dark:hover:text-white hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
              aria-label="Toggle mobile menu"
            >
              {mobileMenuOpen ? <X size={20} /> : <Menu size={20} />}
            </button>
          </div>
        </LiquidGlass>

        {/* Mobile Dropdown Menu with Liquid Glass */}
        <AnimatePresence>
          {mobileMenuOpen && (
            <motion.div
              initial={{ opacity: 0, y: -10, scale: 0.98 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -10, scale: 0.98 }}
              transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
              className="lg:hidden mt-2.5 w-full"
            >
              <LiquidGlass
                radius={24}
                className="p-5 flex flex-col gap-3 shadow-xl border-black/[0.08] dark:border-white/[0.12]"
              >
                {NAV_LINKS.map((link) => (
                  <a
                    key={link.label}
                    href={link.href}
                    onClick={() => setMobileMenuOpen(false)}
                    className="px-3 py-2 rounded-xl text-sm font-medium text-neutral-700 dark:text-neutral-200 hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
                  >
                    {link.label}
                  </a>
                ))}
              </LiquidGlass>
            </motion.div>
          )}
        </AnimatePresence>
      </header>
    </>
  );
}
