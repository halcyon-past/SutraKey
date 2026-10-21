"use client";

import React, { useEffect, useState } from "react";
import { Star, GitFork } from "lucide-react";

interface GitHubStats {
  stars: number;
  forks: number;
}

export function GithubIcon({ size = 15, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" className={className}>
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
    </svg>
  );
}

export function GitHubBadge({ compact = false }: { compact?: boolean }) {
  const [stats, setStats] = useState<GitHubStats | null>(null);

  useEffect(() => {
    let isMounted = true;
    async function fetchStats() {
      try {
        const res = await fetch("https://api.github.com/repos/halcyon-past/SutraKey", {
          headers: { Accept: "application/vnd.github.v3+json" },
        });
        if (res.ok) {
          const data = await res.json();
          if (isMounted) {
            setStats({
              stars: data.stargazers_count ?? 0,
              forks: data.forks_count ?? 0,
            });
          }
        }
      } catch {
        // Graceful fallback if rate-limited or offline
      }
    }
    fetchStats();
    return () => {
      isMounted = false;
    };
  }, []);

  const starCount = stats ? stats.stars.toLocaleString() : "★";
  const forkCount = stats ? stats.forks.toLocaleString() : "⑂";

  if (compact) {
    return (
      <a
        href="https://github.com/halcyon-past/SutraKey"
        target="_blank"
        rel="noopener noreferrer"
        aria-label="GitHub repository with stars and forks"
        className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-black/[0.04] dark:bg-white/[0.06] hover:bg-black/[0.08] dark:hover:bg-white/[0.12] border border-black/[0.06] dark:border-white/[0.1] text-xs font-medium text-neutral-700 dark:text-neutral-200 transition-all duration-200 group whitespace-nowrap"
      >
        <GithubIcon size={14} className="group-hover:scale-110 transition-transform duration-200" />
        <span className="flex items-center gap-1 font-mono text-[11px]">
          <Star size={11} className="text-amber-500 fill-amber-500" />
          <span>{starCount}</span>
        </span>
        <span className="text-neutral-300 dark:text-neutral-600">•</span>
        <span className="flex items-center gap-1 font-mono text-[11px]">
          <GitFork size={11} className="text-neutral-500 dark:text-neutral-400" />
          <span>{forkCount}</span>
        </span>
      </a>
    );
  }

  return (
    <a
      href="https://github.com/halcyon-past/SutraKey"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="View SutraKey on GitHub with live stars and forks"
      className="inline-flex items-center gap-2.5 sm:gap-3 px-3.5 sm:px-4 py-2 rounded-full bg-white/70 dark:bg-white/[0.07] hover:bg-white/90 dark:hover:bg-white/[0.12] border border-black/[0.08] dark:border-white/[0.12] shadow-sm backdrop-blur-xl text-xs font-medium text-[#1d1d1f] dark:text-white transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0 group whitespace-nowrap"
    >
      <div className="flex items-center gap-2">
        <GithubIcon size={15} className="group-hover:scale-110 transition-transform duration-200 text-neutral-700 dark:text-neutral-200" />
        <span className="font-semibold tracking-tight">
          <span className="hidden sm:inline text-neutral-500 dark:text-neutral-400 font-normal">halcyon-past/</span>
          <span>SutraKey</span>
        </span>
      </div>

      <div className="h-3 w-px bg-black/[0.1] dark:bg-white/[0.15]" />

      <div className="flex items-center gap-1 text-neutral-600 dark:text-neutral-300 font-mono text-[11px]">
        <Star size={11} className="text-amber-500 fill-amber-500" />
        <span className="font-semibold text-neutral-800 dark:text-neutral-100">{starCount}</span>
      </div>

      <div className="h-3 w-px bg-black/[0.1] dark:bg-white/[0.15]" />

      <div className="flex items-center gap-1 text-neutral-600 dark:text-neutral-300 font-mono text-[11px]">
        <GitFork size={11} className="text-sky-500" />
        <span className="font-semibold text-neutral-800 dark:text-neutral-100">{forkCount}</span>
      </div>
    </a>
  );
}
