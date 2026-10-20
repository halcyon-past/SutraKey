"use client";

import React from "react";
import { ShieldCheck, EyeOff, FolderDown, Zap } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";

const HIGHLIGHTS = [
  {
    icon: ShieldCheck,
    tag: "Modifier Exclusivity",
    title: "Zero modifier pollution.",
    description:
      "A strict bitwise evaluation monitors global events. If Command, Option, Control, or CapsLock is held alongside Shift, SutraKey immediately steps aside. Your muscular shortcuts remain pristine.",
    accent: "pink",
    detail: "Bitwise CGEventTap Guard",
  },
  {
    icon: EyeOff,
    tag: "Ephemeral Presence",
    title: "Invisible until needed.",
    description:
      "Consumes 0% CPU when idle with zero Dock presence. The menu bar icon appears strictly while an active task is running, updates live percentage, and vanishes after completion.",
    accent: "green",
    detail: "LSUIElement = YES",
  },
  {
    icon: FolderDown,
    tag: "Pure Local Destination",
    title: "Direct to ~/Downloads.",
    description:
      "Every video, audio track, subtitle, and PDF is saved straight to your native macOS Downloads directory. Zero cloud intermediaries, zero paywalls, zero telemetry.",
    accent: "default",
    detail: "No Cloud Proxies",
  },
  {
    icon: Zap,
    tag: "Native Architecture",
    title: "QuickTime-native H.264.",
    description:
      "Engineered with Swift 6 strict concurrency and custom FFmpeg H.264/AAC post-processing. Downloaded media opens seamlessly in QuickTime, Finder QuickLook, and iOS Photos with zero codec errors.",
    accent: "mono",
    detail: "Universal Binary",
  },
];

export function Highlights() {
  return (
    <section id="highlights" className="py-16 md:py-24 px-4 max-w-5xl mx-auto">
      {/* Apple-style Section Header */}
      <div className="mb-12 md:mb-16">
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-3">
          Get the highlights.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300 max-w-xl">
          Crafted to feel like an organic extension of macOS Sonoma and Sequoia.
        </p>
      </div>

      {/* Highlights Grid with Layered Depth & Liquid Glass */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {HIGHLIGHTS.map((item, index) => (
          <LiquidGlass
            key={item.title}
            radius={28}
            depth={1.4}
            blur={8}
            dispersion={0.6}
            specular={0.5}
            interactive
            tint={item.accent as "default" | "pink" | "green" | "mono"}
            className="p-8 sm:p-10 flex flex-col justify-between rounded-[28px] min-h-[280px]"
          >
            <div>
              <div className="flex items-center justify-between mb-6">
                <span className="text-xs font-semibold uppercase tracking-wider text-neutral-500 dark:text-neutral-400">
                  {item.tag}
                </span>
                <span className="font-mono text-xs text-neutral-400 dark:text-neutral-500">
                  0{index + 1}
                </span>
              </div>

              <h3 className="text-2xl sm:text-3xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-3">
                {item.title}
              </h3>
              <p className="text-sm sm:text-base text-neutral-600 dark:text-neutral-300 leading-relaxed font-normal">
                {item.description}
              </p>
            </div>

            <div className="mt-8 pt-4 border-t border-black/[0.04] dark:border-white/[0.08] flex items-center justify-between text-xs font-mono text-neutral-500 dark:text-neutral-400">
              <span>{item.detail}</span>
              <item.icon size={16} className="text-neutral-400 dark:text-neutral-500" />
            </div>
          </LiquidGlass>
        ))}
      </div>
    </section>
  );
}
