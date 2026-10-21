"use client";

import React from "react";

interface LiquidGlassProps extends React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode;
  className?: string;
  depth?: number;
  blur?: number;
  dispersion?: number | false;
  specular?: number | false;
  radius?: number;
  tint?: "default" | "pink" | "green" | "mono";
  interactive?: boolean;
}

export function LiquidGlass({
  children,
  className = "",
  radius = 24,
  tint = "default",
  interactive = false,
  ...props
}: LiquidGlassProps) {
  // Apple-inspired frosted material tints with hardware-accelerated GPU backdrop filtering
  const tintClasses = {
    default:
      "bg-white/60 dark:bg-[#121216]/70 border-black/[0.08] dark:border-white/[0.12] shadow-[0_8px_32px_rgba(0,0,0,0.04)] dark:shadow-[0_8px_32px_rgba(0,0,0,0.4)]",
    pink: "bg-pink-50/50 dark:bg-pink-950/20 border-pink-200/50 dark:border-pink-500/25 shadow-[0_8px_32px_rgba(244,114,182,0.06)]",
    green:
      "bg-emerald-50/50 dark:bg-emerald-950/20 border-emerald-200/50 dark:border-emerald-500/25 shadow-[0_8px_32px_rgba(16,185,129,0.06)]",
    mono: "bg-white/75 dark:bg-[#15151a]/75 border-black/[0.08] dark:border-white/[0.15] shadow-[0_8px_32px_rgba(0,0,0,0.06)] dark:shadow-[0_8px_32px_rgba(0,0,0,0.45)]",
  }[tint];

  return (
    <div
      className={`relative overflow-hidden border backdrop-blur-2xl transform-gpu transition-all duration-300 ${tintClasses} ${
        interactive
          ? "hover:shadow-[0_16px_40px_-8px_rgba(0,0,0,0.08)] dark:hover:shadow-[0_16px_40px_-8px_rgba(0,0,0,0.55)] hover:-translate-y-1 active:translate-y-0 cursor-pointer"
          : ""
      } ${className}`}
      style={{ borderRadius: radius }}
      {...props}
    >
      {/* Delicate Satin Sheen Gradient (Simulates glass refraction without canvas DOM capture) */}
      <div
        className="pointer-events-none absolute inset-0 bg-gradient-to-br from-white/[0.12] via-transparent to-black/[0.04] dark:from-white/[0.06] dark:to-transparent -z-10"
        style={{ borderRadius: radius }}
      />

      {/* Top Specular Rim Chamfer */}
      <div
        className="pointer-events-none absolute inset-x-0 top-0 h-[1px] bg-gradient-to-r from-transparent via-white/80 to-transparent dark:via-white/30 z-20"
        style={{ borderTopLeftRadius: radius, borderTopRightRadius: radius }}
      />

      {/* Subtle Inner Rim Glow for Tactile Depth */}
      <div
        className="pointer-events-none absolute inset-0 rounded-[inherit] ring-1 ring-inset ring-white/[0.2] dark:ring-white/[0.05] z-10"
      />

      {/* Direct in-flow children */}
      {children}
    </div>
  );
}
