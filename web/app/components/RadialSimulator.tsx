"use client";

import React, { useState, useEffect } from "react";
import { Film, Music, FileText, Image as ImageIcon, BookOpen, Check, X } from "lucide-react";

interface Slice {
  id: string;
  name: string;
  badge: string;
  color: string;
  icon: React.ComponentType<{ size?: number; className?: string; style?: React.CSSProperties }>;
  description: string;
  format: string;
  angleDeg: number;
}

const SLICES: Slice[] = [
  {
    id: "video",
    name: "Video (MP4)",
    badge: "MP4",
    color: "#ff6b3d",
    icon: Film,
    description: "Best H.264 video + AAC audio merged via yt-dlp + ffmpeg",
    format: "4K / 1080p MP4",
    angleDeg: 36,
  },
  {
    id: "audio",
    name: "Audio (MP3)",
    badge: "MP3",
    color: "#38bdf8",
    icon: Music,
    description: "320kbps MP3 with embedded high-res album cover art",
    format: "320kbps MP3",
    angleDeg: 108,
  },
  {
    id: "subtitles",
    name: "Subtitles (SRT)",
    badge: "SRT",
    color: "#fbbf24",
    icon: FileText,
    description: "Auto-generated or creator subtitles extracted to clean SRT",
    format: "UTF-8 .srt",
    angleDeg: 180,
  },
  {
    id: "gallery",
    name: "Images / Gallery",
    badge: "IMG",
    color: "#c084fc",
    icon: ImageIcon,
    description: "Highest resolution thumbnail or full photo gallery album",
    format: "High-Res PNG / JPG",
    angleDeg: 252,
  },
  {
    id: "pdf",
    name: "Clean PDF",
    badge: "PDF",
    color: "#34d399",
    icon: BookOpen,
    description: "Ad-free reader mode PDF generated via offscreen WKWebView",
    format: "Reader Mode PDF",
    angleDeg: 324,
  },
];

const SAMPLE_URLS = [
  { label: "Instagram Reel", url: "https://www.instagram.com/reel/Dd88L1GvdGd/" },
  { label: "YouTube 4K", url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ" },
  { label: "Podcast MP3", url: "https://soundcloud.com/creators/deep-focus-mix" },
  { label: "Web Article", url: "https://news.ycombinator.com/item?id=389472" },
];

export function RadialSimulator() {
  const [selectedUrl, setSelectedUrl] = useState(SAMPLE_URLS[0].url);
  const [hoveredSlice, setHoveredSlice] = useState<Slice | null>(null);
  const [isCenterHovered, setIsCenterHovered] = useState(false);
  const [activeDownload, setActiveDownload] = useState<{
    slice: Slice;
    progress: number;
    completed: boolean;
  } | null>(null);

  // Simulated download loop
  useEffect(() => {
    if (!activeDownload || activeDownload.completed) return;

    const interval = setInterval(() => {
      setActiveDownload((prev) => {
        if (!prev) return null;
        if (prev.progress >= 100) {
          clearInterval(interval);
          return { ...prev, completed: true };
        }
        return { ...prev, progress: prev.progress + 20 };
      });
    }, 280);

    return () => clearInterval(interval);
  }, [activeDownload]);

  const handleSelectSlice = (slice: Slice) => {
    setActiveDownload({
      slice,
      progress: 0,
      completed: false,
    });
  };

  const handleCenterCancel = () => {
    setHoveredSlice(null);
    setIsCenterHovered(false);
  };

  return (
    <section id="simulator" className="py-16 md:py-24 px-4 max-w-5xl mx-auto">
      {/* Section Header */}
      <div className="text-center max-w-2xl mx-auto mb-12">
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-4">
          Experience the wheel.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300">
          Hold Shift and select any URL. The wheel appears instantly beneath your cursor. 
          Interact below to test the spring response and live downloads.
        </p>
      </div>

      {/* macOS Window Simulator Frame */}
      <div className="relative rounded-[28px] overflow-hidden border border-black/[0.08] dark:border-white/[0.1] bg-white/70 dark:bg-[#121217]/70 backdrop-blur-2xl shadow-[0_20px_50px_rgba(0,0,0,0.06)] dark:shadow-[0_20px_50px_rgba(0,0,0,0.4)]">
        {/* macOS Window Titlebar with Traffic Lights & Ephemeral Menu Bar Status */}
        <div className="h-11 px-5 flex items-center justify-between border-b border-black/[0.06] dark:border-white/[0.08] bg-black/[0.02] dark:bg-white/[0.02]">
          {/* Traffic Lights */}
          <div className="flex items-center gap-2">
            <span className="w-3 h-3 rounded-full bg-[#ff5f56] border border-[#e0443e]" />
            <span className="w-3 h-3 rounded-full bg-[#ffbd2e] border border-[#dea123]" />
            <span className="w-3 h-3 rounded-full bg-[#27c93f] border border-[#1aab29]" />
          </div>

          <div className="text-xs font-medium text-neutral-500 dark:text-neutral-400">
            SutraKey Desktop Live HUD
          </div>

          {/* Ephemeral Menu Bar Status (Appears strictly when downloading) */}
          <div className="flex items-center gap-2 min-w-[120px] justify-end">
            {activeDownload && (
              <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-black/5 dark:bg-white/10 text-[11px] font-mono animate-fadeIn">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping" />
                <span className="font-semibold text-neutral-800 dark:text-neutral-200">
                  {activeDownload.completed ? "Done" : `${activeDownload.progress}%`}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Mock Browser URL Bar & Selector */}
        <div className="p-4 sm:p-6 border-b border-black/[0.04] dark:border-white/[0.06]">
          <div className="flex flex-col sm:flex-row items-center gap-3">
            <div className="w-full flex-1 flex items-center gap-2 px-4 py-2.5 rounded-full bg-black/[0.03] dark:bg-white/[0.05] border border-black/[0.06] dark:border-white/[0.08] text-xs font-mono text-neutral-700 dark:text-neutral-300">
              <span className="text-emerald-500 font-bold select-none">https://</span>
              <span className="truncate">{selectedUrl.replace("https://", "")}</span>
              <span className="ml-auto text-[10px] uppercase font-bold text-neutral-400 tracking-wider">
                Shift Selected
              </span>
            </div>

            {/* Quick URL Switcher */}
            <div className="flex items-center gap-1.5 overflow-x-auto w-full sm:w-auto pb-1 sm:pb-0">
              {SAMPLE_URLS.map((sample) => (
                <button
                  key={sample.label}
                  onClick={() => {
                    setSelectedUrl(sample.url);
                    setActiveDownload(null);
                  }}
                  className={`px-3 py-1.5 text-xs font-medium rounded-full transition-all whitespace-nowrap ${
                    selectedUrl === sample.url
                      ? "bg-[#1d1d1f] text-white dark:bg-white dark:text-[#1d1d1f] shadow-sm"
                      : "bg-black/[0.03] dark:bg-white/[0.04] text-neutral-600 dark:text-neutral-400 hover:bg-black/5"
                  }`}
                >
                  {sample.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Radial Menu Playground Area */}
        <div className="relative h-[480px] flex items-center justify-center overflow-hidden p-6">
          {/* Subtle background ambient reflections */}
          <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
            <div className="w-[320px] h-[320px] rounded-full ambient-glow-pink blur-[80px] opacity-40 -z-10" />
            <div className="w-[320px] h-[320px] rounded-full ambient-glow-green blur-[90px] opacity-35 -z-10 translate-x-10 translate-y-10" />
          </div>

          {/* Interactive Liquid Glass Radial Menu */}
          <div className="relative w-[300px] h-[300px] flex items-center justify-center">
            {/* Outer Glass Ring Base */}
            <div className="absolute inset-0 rounded-full border border-black/[0.08] dark:border-white/[0.15] bg-white/40 dark:bg-black/30 backdrop-blur-xl shadow-2xl" />

            {/* 5 Distinct Interactive Slices */}
            {SLICES.map((slice) => {
              const isHovered = hoveredSlice?.id === slice.id;
              const rad = (slice.angleDeg * Math.PI) / 180;
              const r = 95; // radius distance
              const x = r * Math.cos(rad);
              const y = -r * Math.sin(rad);

              return (
                <button
                  key={slice.id}
                  onMouseEnter={() => {
                    setHoveredSlice(slice);
                    setIsCenterHovered(false);
                  }}
                  onMouseLeave={() => setHoveredSlice(null)}
                  onClick={() => handleSelectSlice(slice)}
                  style={{
                    transform: `translate(${x}px, ${y}px)`,
                    borderColor: isHovered ? slice.color : undefined,
                  }}
                  className={`absolute w-14 h-14 -ml-7 -mt-7 rounded-2xl flex flex-col items-center justify-center gap-1 transition-all duration-200 cursor-pointer ${
                    isHovered
                      ? "scale-115 shadow-lg bg-white/95 dark:bg-black/90 border-2"
                      : "bg-white/60 dark:bg-neutral-900/60 border border-black/[0.08] dark:border-white/10 hover:scale-105"
                  }`}
                >
                  <slice.icon
                    size={20}
                    className="transition-colors"
                    style={{ color: isHovered ? slice.color : "currentColor" }}
                  />
                  <span
                    className="text-[9px] font-bold tracking-tight"
                    style={{ color: isHovered ? slice.color : "currentColor" }}
                  >
                    {slice.badge}
                  </span>
                </button>
              );
            })}

            {/* Center Cancel Knot (< 28pt dead-zone) */}
            <button
              onMouseEnter={() => {
                setIsCenterHovered(true);
                setHoveredSlice(null);
              }}
              onMouseLeave={() => setIsCenterHovered(false)}
              onClick={handleCenterCancel}
              className={`w-14 h-14 rounded-full flex items-center justify-center transition-all duration-200 z-10 ${
                isCenterHovered
                  ? "scale-110 bg-red-500/20 text-red-500 border-2 border-red-500 shadow-md"
                  : hoveredSlice
                  ? "bg-black/[0.06] dark:bg-white/[0.08] text-neutral-400 border border-black/10 dark:border-white/20"
                  : "bg-black/5 dark:bg-white/10 text-neutral-400 border border-black/10 dark:border-white/15"
              }`}
            >
              {isCenterHovered ? (
                <X size={18} className="text-red-500" />
              ) : (
                <div
                  className="w-2.5 h-2.5 rounded-full transition-colors"
                  style={{
                    backgroundColor: hoveredSlice ? hoveredSlice.color : "#ff6b3d",
                  }}
                />
              )}
            </button>
          </div>

          {/* Floating Live Toast Notification (Apple Frosted Material) */}
          {activeDownload && (
            <div className="absolute bottom-6 right-6 max-w-sm w-full p-4 rounded-2xl bg-white/85 dark:bg-[#18181f]/85 backdrop-blur-2xl border border-black/[0.08] dark:border-white/[0.12] shadow-xl animate-slideUp">
              <div className="flex items-start gap-3">
                <div
                  className="w-8 h-8 rounded-xl flex items-center justify-center shrink-0"
                  style={{ backgroundColor: `${activeDownload.slice.color}20`, color: activeDownload.slice.color }}
                >
                  {activeDownload.completed ? <Check size={18} /> : <activeDownload.slice.icon size={18} />}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-semibold text-[#1d1d1f] dark:text-white">
                    {activeDownload.completed ? "Saved to Downloads" : "Converting..."}
                  </div>
                  <div className="text-[11px] text-neutral-500 dark:text-neutral-400 truncate">
                    {activeDownload.slice.name} • 100% QuickTime Native
                  </div>
                  {/* Mini Progress Bar */}
                  <div className="mt-2.5 w-full bg-black/5 dark:bg-white/10 rounded-full h-1 overflow-hidden">
                    <div
                      className="h-full transition-all duration-300 rounded-full"
                      style={{
                        width: `${activeDownload.progress}%`,
                        backgroundColor: activeDownload.slice.color,
                      }}
                    />
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Slice Descriptor Footer */}
        <div className="px-6 py-4 border-t border-black/[0.04] dark:border-white/[0.06] bg-black/[0.01] dark:bg-white/[0.01] flex items-center justify-between text-xs text-neutral-500 dark:text-neutral-400">
          <div>
            {hoveredSlice ? (
              <span className="font-medium text-neutral-900 dark:text-neutral-100">
                {hoveredSlice.name}: <span className="font-normal text-neutral-500">{hoveredSlice.description}</span>
              </span>
            ) : isCenterHovered ? (
              <span className="text-red-500 font-medium">Center Dead Zone (&lt; 28pt): Click or release to cancel</span>
            ) : (
              <span>Hover or click any slice to preview the media conversion pipeline</span>
            )}
          </div>
          <div className="font-mono text-[11px] text-neutral-400">
            {hoveredSlice ? hoveredSlice.format : "5 Actions • 72° Each"}
          </div>
        </div>
      </div>
    </section>
  );
}
