"use client";

import React from "react";
import Image from "next/image";
import { Download, Sun, Moon } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";
import { GitHubBadge } from "./GitHubBadge";

function useIsDarkMode() {
  return React.useSyncExternalStore(
    (callback) => {
      const media = window.matchMedia("(prefers-color-scheme: dark)");
      media.addEventListener("change", callback);
      const observer = new MutationObserver(callback);
      observer.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
      return () => {
        media.removeEventListener("change", callback);
        observer.disconnect();
      };
    },
    () => (typeof document !== "undefined" ? document.documentElement.classList.contains("dark") : false),
    () => false
  );
}

export function Navbar() {
  const isDark = useIsDarkMode();

  const toggleTheme = () => {
    if (document.documentElement.classList.contains("dark")) {
      document.documentElement.classList.remove("dark");
    } else {
      document.documentElement.classList.add("dark");
    }
  };

  return (
    <header className="sticky top-5 z-50 px-4 max-w-5xl mx-auto">
      <LiquidGlass
        radius={9999}
        depth={1.4}
        blur={8}
        dispersion={0.6}
        specular={0.7}
        className="rounded-full px-5 py-2.5 flex items-center justify-between"
      >
        {/* Brand Lockup */}
        <a href="#" className="flex items-center gap-2.5 group">
          <div className="relative w-7 h-7 rounded-[8px] overflow-hidden shadow-sm group-hover:scale-105 transition-transform duration-200">
            <Image
              src="/AppIcon-1024.png"
              alt="SutraKey App Icon"
              fill
              className="object-cover"
              priority
            />
          </div>
          <div className="flex items-center gap-1.5">
            <span className="font-semibold text-sm tracking-tight text-[#1d1d1f] dark:text-white">
              SutraKey
            </span>
            <span className="text-[10px] font-medium tracking-wide text-neutral-500 dark:text-neutral-400 bg-neutral-200/50 dark:bg-neutral-800/60 px-1.5 py-0.5 rounded-full">
              v1.0
            </span>
          </div>
        </a>

        {/* Navigation Links */}
        <nav className="hidden md:flex items-center gap-6 text-[13px] font-medium text-neutral-600 dark:text-neutral-300">
          <a href="#simulator" className="hover:text-black dark:hover:text-white transition-colors">
            Experience
          </a>
          <a href="#highlights" className="hover:text-black dark:hover:text-white transition-colors">
            Highlights
          </a>
          <a href="#formats" className="hover:text-black dark:hover:text-white transition-colors">
            Formats
          </a>
          <a href="#installation" className="hover:text-black dark:hover:text-white transition-colors">
            Install
          </a>
        </nav>

        {/* Action Controls */}
        <div className="flex items-center gap-2">
          {/* GitHub Star & Fork Badge */}
          <div className="hidden sm:flex">
            <GitHubBadge compact />
          </div>

          {/* Theme Toggle Button */}
          <button
            onClick={toggleTheme}
            aria-label="Toggle theme"
            className="w-8 h-8 rounded-full flex items-center justify-center text-neutral-600 dark:text-neutral-300 hover:bg-black/5 dark:hover:bg-white/10 transition-colors cursor-pointer"
          >
            {isDark ? <Sun size={15} /> : <Moon size={15} />}
          </button>

          {/* Primary Download Pill */}
          <a
            href="#installation"
            className="flex items-center gap-1.5 bg-[#1d1d1f] text-white dark:bg-white dark:text-[#1d1d1f] text-xs font-semibold px-4 py-1.5 rounded-full shadow-sm hover:opacity-90 active:scale-95 transition-all"
          >
            <Download size={13} />
            <span>Get SutraKey</span>
          </a>
        </div>
      </LiquidGlass>
    </header>
  );
}
