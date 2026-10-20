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
  depth = 1.2,
  blur = 6,
  dispersion = 0.6,
  specular = 0.5,
  radius = 24,
  tint = "default",
  interactive = false,
  ...props
}: LiquidGlassProps) {
  // Pastel tint overlays
  const tintClasses = {
    default: "bg-white/70 dark:bg-[#121216]/70 border-white/80 dark:border-white/15",
    pink: "bg-pink-50/70 dark:bg-pink-950/20 border-pink-200/60 dark:border-pink-500/20",
    green: "bg-emerald-50/70 dark:bg-emerald-950/20 border-emerald-200/60 dark:border-emerald-500/20",
    mono: "bg-white/85 dark:bg-[#15151a]/85 border-white/90 dark:border-white/20",
  }[tint];

  return (
    <Vaso
      depth={depth}
      blur={blur}
      dispersion={dispersion}
      specular={specular}
      radius={radius}
      className={`relative backdrop-blur-2xl border transition-all duration-300 ${tintClasses} ${
        interactive
          ? "hover:shadow-[0_12px_36px_-8px_rgba(0,0,0,0.08)] dark:hover:shadow-[0_12px_36px_-8px_rgba(0,0,0,0.4)] hover:-translate-y-0.5 active:translate-y-0"
          : "shadow-[0_8px_28px_-6px_rgba(0,0,0,0.04)] dark:shadow-[0_8px_28px_-6px_rgba(0,0,0,0.3)]"
      } ${className}`}
      {...props}
    >
      {/* Specular hairline top rim highlight */}
      <div
        className="pointer-events-none absolute inset-x-0 top-0 h-[1px] bg-gradient-to-r from-transparent via-white/80 to-transparent dark:via-white/30"
        style={{ borderTopLeftRadius: radius, borderTopRightRadius: radius }}
      />
      {children}
    </Vaso>
  );
}
