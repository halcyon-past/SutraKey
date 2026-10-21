"use client";

import React from "react";
import { Vaso } from "vaso";

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
  depth = 1.0,
  blur = 6,
  dispersion = 0.5,
  specular = 0.5,
  radius = 24,
  tint = "default",
  interactive = false,
  ...props
}: LiquidGlassProps) {
  // Apple-inspired frosted pastel material tints
  const tintClasses = {
    default:
      "bg-white/65 dark:bg-[#121216]/65 border-white/80 dark:border-white/12 shadow-[0_8px_32px_rgba(0,0,0,0.04)] dark:shadow-[0_8px_32px_rgba(0,0,0,0.35)]",
    pink: "bg-pink-50/55 dark:bg-pink-950/25 border-pink-200/60 dark:border-pink-500/25 shadow-[0_8px_32px_rgba(244,114,182,0.07)]",
    green:
      "bg-emerald-50/55 dark:bg-emerald-950/25 border-emerald-200/60 dark:border-emerald-500/25 shadow-[0_8px_32px_rgba(16,185,129,0.07)]",
    mono: "bg-white/80 dark:bg-[#15151a]/80 border-white/90 dark:border-white/18 shadow-[0_8px_32px_rgba(0,0,0,0.06)] dark:shadow-[0_8px_32px_rgba(0,0,0,0.4)]",
  }[tint];

  return (
    <div
      className={`relative overflow-hidden border backdrop-blur-2xl transition-all duration-300 ${tintClasses} ${
        interactive
          ? "hover:shadow-[0_16px_40px_-8px_rgba(0,0,0,0.08)] dark:hover:shadow-[0_16px_40px_-8px_rgba(0,0,0,0.5)] hover:-translate-y-0.5 active:translate-y-0 cursor-pointer"
          : ""
      } ${className}`}
      style={{ borderRadius: radius }}
      {...props}
    >
      {/* Vaso Liquid Glass Physical Lens (Underlying refraction layer, never warps text) */}
      <div
        className="pointer-events-none absolute inset-0 overflow-hidden -z-10"
        style={{ borderRadius: radius }}
      >
        <Vaso
          depth={depth}
          blur={blur}
          dispersion={dispersion}
          specular={specular}
          radius={radius}
          className="w-full h-full opacity-60 dark:opacity-40"
        />
      </div>

      {/* Top Specular Rim Chamfer */}
      <div
        className="pointer-events-none absolute inset-x-0 top-0 h-[1px] bg-gradient-to-r from-transparent via-white/90 to-transparent dark:via-white/30 z-20"
        style={{ borderTopLeftRadius: radius, borderTopRightRadius: radius }}
      />

      {/* Direct in-flow children: preserves natural flex/grid layouts from className */}
      {children}
    </div>
  );
}
