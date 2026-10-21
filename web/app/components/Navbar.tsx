"use client";

import React from "react";
import Image from "next/image";
import { Download } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";
import { GithubIcon } from "./GitHubBadge";

export function Navbar() {
  return (
    <header className="sticky top-5 z-50 px-4 max-w-5xl mx-auto w-full">
      <LiquidGlass
        radius={9999}
        depth={1.4}
        blur={8}
        dispersion={0.6}
        specular={0.7}
        className="rounded-full px-6 py-2.5 flex items-center justify-between w-full"
      >
        {/* Brand Lockup */}
        <a href="/" className="flex items-center gap-2.5 group shrink-0">
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
            <span className="font-semibold text-sm tracking-tight text-white">
              SutraKey
            </span>
            <span className="text-[10px] font-medium tracking-wide text-neutral-400 bg-white/[0.08] px-1.5 py-0.5 rounded-full border border-white/[0.06]">
              v1.0
            </span>
          </div>
        </a>

        {/* Navigation Links (Evenly spaced, clean Apple layout) */}
        <nav className="hidden md:flex items-center gap-6 lg:gap-8 text-[13px] font-medium text-neutral-300">
          <a href="/#simulator" className="hover:text-white transition-colors">
            Experience
          </a>
          <a href="/#highlights" className="hover:text-white transition-colors">
            Highlights
          </a>
          <a href="/#formats" className="hover:text-white transition-colors">
            Formats
          </a>
          <a href="/#installation" className="hover:text-white transition-colors">
            Install
          </a>
          <a href="/support" className="hover:text-white transition-colors">
            Docs &amp; Support
          </a>
        </nav>

        {/* Action Controls */}
        <div className="flex items-center gap-3 shrink-0">
          {/* Minimal GitHub Link */}
          <a
            href="https://github.com/halcyon-past/SutraKey"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="GitHub Repository"
            className="w-8 h-8 rounded-full flex items-center justify-center text-neutral-400 hover:text-white hover:bg-white/10 transition-colors cursor-pointer"
          >
            <GithubIcon size={16} />
          </a>

          {/* Primary Download Pill */}
          <a
            href="https://github.com/halcyon-past/SutraKey/releases/latest"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 bg-white text-[#0a0a0c] text-xs font-semibold px-4 py-2 rounded-full shadow-sm hover:scale-[1.02] active:scale-[0.98] transition-all whitespace-nowrap cursor-pointer"
          >
            <Download size={13} />
            <span>Get SutraKey</span>
          </a>
        </div>
      </LiquidGlass>
    </header>
  );
}
