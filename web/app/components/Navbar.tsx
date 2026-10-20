"use client";

import React from "react";
import Image from "next/image";
import { Download, Sun, Moon } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";

function GithubIcon({ size = 18 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
    </svg>
  );
}

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
    () => document.documentElement.classList.contains("dark"),
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
        depth={1.5}
        blur={8}
        dispersion={0.8}
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
          {/* Theme Toggle Button */}
          <button
            onClick={toggleTheme}
            aria-label="Toggle theme"
            className="w-8 h-8 rounded-full flex items-center justify-center text-neutral-600 dark:text-neutral-300 hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
          >
            {isDark ? <Sun size={15} /> : <Moon size={15} />}
          </button>

          {/* GitHub Star Button */}
          <a
            href="https://github.com/halcyon-past/SutraKey"
            target="_blank"
            rel="noopener noreferrer"
            className="hidden sm:flex items-center gap-1.5 text-xs font-medium text-neutral-700 dark:text-neutral-200 px-3 py-1.5 rounded-full hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
          >
            <GithubIcon size={14} />
            <span>GitHub</span>
          </a>

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
