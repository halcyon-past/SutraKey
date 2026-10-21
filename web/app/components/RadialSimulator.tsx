"use client";

import React, { useState, useEffect, useRef } from "react";
import { Film, Music, FileText, Image as ImageIcon, BookOpen, Check, X, ArrowUpRight } from "lucide-react";
import { motion } from "motion/react";

interface Slice {
  id: string;
  name: string;
  badge: string;
  color: string;
  icon: React.ComponentType<{ size?: number; className?: string; style?: React.CSSProperties }>;
  description: string;
  format: string;
  startDeg: number;
  endDeg: number;
  centerDeg: number;
}

const SLICES: Slice[] = [
  {
    id: "video",
    name: "Video (MP4)",
    badge: "MP4",
    color: "#ff6b3d",
    icon: Film,
    description: "Lossless H.264 video + AAC audio merged via yt-dlp + ffmpeg",
    format: "4K / 1080p QuickTime MP4",
    startDeg: 0,
    endDeg: 72,
    centerDeg: 36,
  },
  {
    id: "audio",
    name: "Audio (MP3)",
    badge: "MP3",
    color: "#38bdf8",
    icon: Music,
    description: "320kbps MP3 with embedded high-res album cover art & ID3 tags",
    format: "320kbps MP3 Audio",
    startDeg: 72,
    endDeg: 144,
    centerDeg: 108,
  },
  {
    id: "subtitles",
    name: "Subtitles (SRT)",
    badge: "SRT",
    color: "#fbbf24",
    icon: FileText,
    description: "Auto-generated or creator subtitles extracted to clean standard SRT",
    format: "UTF-8 SubRip (.srt)",
    startDeg: 144,
    endDeg: 216,
    centerDeg: 180,
  },
  {
    id: "gallery",
    name: "Images / Gallery",
    badge: "IMG",
    color: "#c084fc",
    icon: ImageIcon,
    description: "Highest resolution master thumbnail or full photo carousel gallery",
    format: "High-Res PNG / JPG",
    startDeg: 216,
    endDeg: 288,
    centerDeg: 252,
  },
  {
    id: "pdf",
    name: "Clean PDF",
    badge: "PDF",
    color: "#34d399",
    icon: BookOpen,
    description: "Ad-free reader mode PDF generated via offscreen headless WKWebView",
    format: "Reader Mode Vector PDF",
    startDeg: 288,
    endDeg: 360,
    centerDeg: 324,
  },
];

const SAMPLE_URLS = [
  { label: "Instagram Reel", url: "https://www.instagram.com/p/Dc_U1XRpWEI/?hl=en" },
  { label: "YouTube 4K", url: "https://www.youtube.com/watch?v=2u19wN1tDT4" },
  { label: "Tech Article", url: "https://news.ycombinator.com/item?id=389472" },
];

function polarToCartesian(cx: number, cy: number, r: number, angleDeg: number) {
  const rad = (angleDeg * Math.PI) / 180;
  return {
    x: Number((cx + r * Math.cos(rad)).toFixed(2)),
    y: Number((cy - r * Math.sin(rad)).toFixed(2)),
  };
}

function describeArcSector(
  cx: number,
  cy: number,
  rIn: number,
  rOut: number,
  startAngle: number,
  endAngle: number
) {
  const s = startAngle + 0.8;
  const e = endAngle - 0.8;
  const p1 = polarToCartesian(cx, cy, rOut, s);
  const p2 = polarToCartesian(cx, cy, rOut, e);
  const p3 = polarToCartesian(cx, cy, rIn, e);
  const p4 = polarToCartesian(cx, cy, rIn, s);

  return `M ${p1.x} ${p1.y} A ${rOut} ${rOut} 0 0 0 ${p2.x} ${p2.y} L ${p3.x} ${p3.y} A ${rIn} ${rIn} 0 0 1 ${p4.x} ${p4.y} Z`;
}

export function RadialSimulator() {
  const [selectedUrl, setSelectedUrl] = useState(SAMPLE_URLS[0].url);
  const [hoveredSlice, setHoveredSlice] = useState<Slice | null>(null);
  const [isCenterHovered, setIsCenterHovered] = useState(false);
  const [activeDownload, setActiveDownload] = useState<{
    slice: Slice;
    progress: number;
    stage: string;
    completed: boolean;
  } | null>(null);

  const svgRef = useRef<SVGSVGElement>(null);

  // Simulated download progress loop
  useEffect(() => {
    if (!activeDownload || activeDownload.completed) return;

    const interval = setInterval(() => {
      setActiveDownload((prev) => {
        if (!prev) return null;
        if (prev.progress >= 100) {
          clearInterval(interval);
          return {
            ...prev,
            progress: 100,
            stage: "Saved to ~/Downloads",
            completed: true,
          };
        }
        const nextProgress = prev.progress + 20;
        let nextStage = "Inspecting stream...";
        if (nextProgress >= 70) {
          nextStage = "Merging H.264 + AAC in MP4...";
        } else if (nextProgress >= 30) {
          nextStage = `Downloading payload (${nextProgress}%)...`;
        }
        return {
          ...prev,
          progress: nextProgress,
          stage: nextStage,
        };
      });
    }, 280);

    return () => clearInterval(interval);
  }, [activeDownload]);

  const handleSelectSlice = (slice: Slice) => {
    setActiveDownload({
      slice,
      progress: 5,
      stage: "Connecting to media stream...",
      completed: false,
    });
  };

  const handleCenterCancel = () => {
    setHoveredSlice(null);
    setIsCenterHovered(false);
  };

  // Cursor angle tracking over the radial dial (matching native macOS AppKit)
  const handleMouseMove = (e: React.MouseEvent<SVGSVGElement>) => {
    if (!svgRef.current) return;
    const rect = svgRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const cx = rect.width / 2;
    const cy = rect.height / 2;

    const dx = x - cx;
    const dy = cy - y; // Invert Y for Cartesian coordinates
    const distance = Math.hypot(dx, dy);

    // Inner dead-zone < 32pt
    if (distance < 32) {
      setIsCenterHovered(true);
      setHoveredSlice(null);
      return;
    }

    // Outside menu perimeter
    if (distance > 155) {
      setIsCenterHovered(false);
      setHoveredSlice(null);
      return;
    }

    setIsCenterHovered(false);

    // Calculate Cartesian angle [0, 360)
    let angle = (Math.atan2(dy, dx) * 180) / Math.PI;
    if (angle < 0) {
      angle += 360;
    }

    const matched = SLICES.find((s) => angle >= s.startDeg && angle < s.endDeg);
    if (matched) {
      setHoveredSlice(matched);
    }
  };

  const handleMouseLeave = () => {
    setHoveredSlice(null);
    setIsCenterHovered(false);
  };

  const cx = 160;
  const cy = 160;
  const rIn = 34;
  const rOut = 142;
  const rMid = 88;

  return (
    <motion.section
      id="simulator"
      initial={{ opacity: 0, y: 25 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
      className="py-16 md:py-24 px-4 max-w-5xl mx-auto"
    >
      {/* Section Header */}
      <div className="text-center max-w-2xl mx-auto mb-12">
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-4">
          Experience the wheel.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300">
          Hold Shift and select any link. The pie dial appears directly under your cursor.
          Interact below to feel the contiguous 72° wedge physics and live downloads.
        </p>
      </div>

      {/* macOS Window Simulator Frame */}
      <div className="relative rounded-[28px] overflow-hidden border border-black/[0.08] dark:border-white/[0.12] bg-white/75 dark:bg-[#121217]/75 backdrop-blur-2xl shadow-[0_24px_64px_rgba(0,0,0,0.06)] dark:shadow-[0_24px_64px_rgba(0,0,0,0.45)]">
        {/* macOS Window Titlebar with Traffic Lights & Ephemeral Menu Bar Status */}
        <div className="h-11 px-5 flex items-center justify-between border-b border-black/[0.06] dark:border-white/[0.08] bg-black/[0.02] dark:bg-white/[0.02]">
          {/* Traffic Lights */}
          <div className="flex items-center gap-2">
            <span className="w-3 h-3 rounded-full bg-[#ff5f56] border border-[#e0443e]" />
            <span className="w-3 h-3 rounded-full bg-[#ffbd2e] border border-[#dea123]" />
            <span className="w-3 h-3 rounded-full bg-[#27c93f] border border-[#1aab29]" />
          </div>

          <div className="text-xs font-semibold text-neutral-500 dark:text-neutral-400">
            SutraKey Desktop Live HUD
          </div>

          {/* Ephemeral Menu Bar Status (Appears strictly when task is active) */}
          <div className="flex items-center gap-2 min-w-[140px] justify-end">
            {activeDownload && (
              <div className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 text-[11px] font-mono border border-emerald-500/20">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
                <span className="font-semibold">
                  {activeDownload.completed ? "Done 100%" : `${activeDownload.progress}%`}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Mock Browser URL Bar & Selector */}
        <div className="p-4 sm:p-6 border-b border-black/[0.04] dark:border-white/[0.06] bg-black/[0.01] dark:bg-white/[0.01]">
          <div className="flex flex-col sm:flex-row items-center gap-3">
            <div className="w-full flex-1 flex items-center gap-2 px-4 py-2.5 rounded-full bg-black/[0.03] dark:bg-white/[0.05] border border-black/[0.06] dark:border-white/[0.08] text-xs font-mono text-neutral-700 dark:text-neutral-300">
              <span className="text-emerald-500 font-bold select-none">https://</span>
              <input
                type="text"
                value={selectedUrl.replace("https://", "")}
                onChange={(e) => {
                  setSelectedUrl(`https://${e.target.value.replace("https://", "")}`);
                  setActiveDownload(null);
                }}
                className="w-full bg-transparent outline-none truncate font-mono text-xs text-[#1d1d1f] dark:text-white"
                placeholder="Paste any Instagram, YouTube or web URL..."
              />
              <span className="ml-auto text-[10px] uppercase font-bold text-neutral-400 tracking-wider select-none shrink-0">
                Shift Highlighted
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
                  className={`px-3 py-1.5 text-xs font-medium rounded-full transition-all whitespace-nowrap cursor-pointer ${
                    selectedUrl === sample.url
                      ? "bg-[#1d1d1f] text-white dark:bg-white dark:text-[#1d1d1f] shadow-sm font-semibold"
                      : "bg-black/[0.03] dark:bg-white/[0.04] text-neutral-600 dark:text-neutral-400 hover:bg-black/5 dark:hover:bg-white/10"
                  }`}
                >
                  {sample.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Radial Menu Playground Area */}
        <div className="relative h-[480px] flex items-center justify-center overflow-hidden p-6 select-none">
          {/* Subtle background ambient reflections (hardware-isolated) */}
          <div className="pointer-events-none absolute inset-0 flex items-center justify-center contain-paint">
            <div className="w-[340px] h-[340px] rounded-full ambient-glow-pink opacity-50 dark:opacity-30 -z-10" />
            <div className="w-[340px] h-[340px] rounded-full ambient-glow-green opacity-45 dark:opacity-25 -z-10 translate-x-12 translate-y-10" />
          </div>

          {/* Genuine 360° Contiguous Radial Pie Wheel */}
          <div className="relative w-[320px] h-[320px] flex items-center justify-center">
            {/* Outer Circular Frosted Glass Backdrop Disc */}
            <div className="absolute inset-0 rounded-full border border-black/[0.08] dark:border-white/[0.15] bg-white/40 dark:bg-black/40 backdrop-blur-2xl shadow-[0_20px_50px_rgba(0,0,0,0.1)] dark:shadow-[0_20px_50px_rgba(0,0,0,0.6)]" />

            {/* Precision SVG Pie Dial */}
            <svg
              ref={svgRef}
              viewBox="0 0 320 320"
              className="absolute inset-0 w-full h-full cursor-pointer z-10"
              onMouseMove={handleMouseMove}
              onMouseLeave={handleMouseLeave}
            >
              <defs>
                <filter id="wedge-glow" x="-20%" y="-20%" width="140%" height="140%">
                  <feGaussianBlur stdDeviation="4" result="blur" />
                  <feComposite in="SourceGraphic" in2="blur" operator="over" />
                </filter>
              </defs>

              {/* 5 Contiguous Slices */}
              {SLICES.map((slice) => {
                const isHovered = hoveredSlice?.id === slice.id;
                const pathD = describeArcSector(cx, cy, rIn, rOut, slice.startDeg, slice.endDeg);

                // Wedge outward translation on hover (6px along radial center vector)
                const rad = (slice.centerDeg * Math.PI) / 180;
                const transX = isHovered ? Number((6 * Math.cos(rad)).toFixed(2)) : 0;
                const transY = isHovered ? Number((-6 * Math.sin(rad)).toFixed(2)) : 0;

                return (
                  <g
                    key={slice.id}
                    onClick={() => handleSelectSlice(slice)}
                    style={{
                      transform: `translate(${transX}px, ${transY}px)`,
                      transformOrigin: `${cx}px ${cy}px`,
                      transition: "all 0.22s cubic-bezier(0.16, 1, 0.3, 1)",
                    }}
                  >
                    {/* Pie Wedge Sector Path */}
                    <path
                      d={pathD}
                      fill={isHovered ? slice.color : "currentColor"}
                      fillOpacity={isHovered ? 0.32 : 0.05}
                      stroke={isHovered ? slice.color : "rgba(255, 255, 255, 0.25)"}
                      strokeWidth={isHovered ? 2.5 : 1}
                      strokeLinejoin="round"
                      filter={isHovered ? "url(#wedge-glow)" : undefined}
                      className="text-black/5 dark:text-white/10 transition-colors duration-200"
                    />
                  </g>
                );
              })}
            </svg>

            {/* Crisp Slice Content Overlay (Icons & Badges positioned at mid-radius) */}
            <div className="absolute inset-0 pointer-events-none z-20">
              {SLICES.map((slice) => {
                const isHovered = hoveredSlice?.id === slice.id;
                const pos = polarToCartesian(cx, cy, rMid, slice.centerDeg);

                const rad = (slice.centerDeg * Math.PI) / 180;
                const transX = isHovered ? 6 * Math.cos(rad) : 0;
                const transY = isHovered ? -6 * Math.sin(rad) : 0;

                return (
                  <div
                    key={slice.id}
                    style={{
                      left: `${pos.x}px`,
                      top: `${pos.y}px`,
                      transform: `translate(-50%, -50%) translate(${transX}px, ${transY}px) scale(${
                        isHovered ? 1.15 : 1.0
                      })`,
                      transition: "all 0.22s cubic-bezier(0.16, 1, 0.3, 1)",
                    }}
                    className="absolute flex flex-col items-center justify-center gap-1 select-none"
                  >
                    <slice.icon
                      size={20}
                      style={{
                        color: isHovered ? slice.color : undefined,
                      }}
                      className={`transition-colors duration-200 ${
                        isHovered ? "" : "text-neutral-700 dark:text-neutral-200"
                      }`}
                    />
                    <span
                      style={{
                        color: isHovered ? slice.color : undefined,
                      }}
                      className={`text-[10px] font-bold tracking-tight transition-colors duration-200 ${
                        isHovered ? "" : "text-neutral-700 dark:text-neutral-300"
                      }`}
                    >
                      {slice.badge}
                    </span>
                  </div>
                );
              })}
            </div>

            {/* Center Dead-Zone (< 32pt) Cancel Knot */}
            <button
              onClick={handleCenterCancel}
              aria-label="Cancel Selection"
              className={`w-14 h-14 rounded-full flex items-center justify-center transition-all duration-200 z-30 cursor-pointer ${
                isCenterHovered
                  ? "scale-110 bg-red-500/20 text-red-500 border-2 border-red-500 shadow-md"
                  : hoveredSlice
                  ? "bg-black/[0.08] dark:bg-white/[0.1] text-neutral-400 border border-black/15 dark:border-white/25 shadow-sm"
                  : "bg-white/80 dark:bg-[#1a1a20]/80 text-neutral-400 border border-black/10 dark:border-white/20 shadow-sm"
              }`}
            >
              {isCenterHovered ? (
                <X size={18} className="text-red-500" />
              ) : (
                <div
                  className="w-3 h-3 rounded-full transition-all duration-200"
                  style={{
                    backgroundColor: hoveredSlice ? hoveredSlice.color : "#ff6b3d",
                    boxShadow: hoveredSlice ? `0 0 10px ${hoveredSlice.color}` : "none",
                  }}
                />
              )}
            </button>
          </div>

          {/* Floating Live Toast Notification (macOS Native Frosted HUD) */}
          {activeDownload && (
            <div className="absolute bottom-6 right-6 max-w-sm w-full p-4 rounded-2xl bg-white/90 dark:bg-[#18181f]/90 backdrop-blur-2xl border border-black/[0.08] dark:border-white/[0.12] shadow-2xl transition-all duration-300">
              <div className="flex items-start gap-3">
                <div
                  className="w-9 h-9 rounded-xl flex items-center justify-center shrink-0"
                  style={{
                    backgroundColor: `${activeDownload.slice.color}20`,
                    color: activeDownload.slice.color,
                  }}
                >
                  {activeDownload.completed ? (
                    <Check size={18} />
                  ) : (
                    <activeDownload.slice.icon size={18} />
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-semibold text-[#1d1d1f] dark:text-white">
                      {activeDownload.completed ? "Saved to ~/Downloads" : "Processing Selection"}
                    </span>
                    <span className="font-mono text-[11px] font-semibold text-neutral-500">
                      {activeDownload.progress}%
                    </span>
                  </div>
                  <div className="text-[11px] text-neutral-500 dark:text-neutral-400 truncate mt-0.5">
                    {activeDownload.stage}
                  </div>
                  {/* Progress Bar */}
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
        <div className="px-6 py-4 border-t border-black/[0.04] dark:border-white/[0.06] bg-black/[0.01] dark:bg-white/[0.01] flex items-center justify-between text-xs text-neutral-600 dark:text-neutral-300">
          <div>
            {hoveredSlice ? (
              <span className="font-semibold text-neutral-900 dark:text-white">
                {hoveredSlice.name}:{" "}
                <span className="font-normal text-neutral-500 dark:text-neutral-400">
                  {hoveredSlice.description}
                </span>
              </span>
            ) : isCenterHovered ? (
              <span className="text-red-500 font-semibold">
                Center Dead Zone (&lt; 32pt): Release mouse to cancel without action
              </span>
            ) : (
              <span>Move mouse or hover over any slice to preview the media conversion pipeline</span>
            )}
          </div>
          <div className="hidden sm:flex items-center gap-2 font-mono text-[11px] text-neutral-400">
            <span>{hoveredSlice ? hoveredSlice.format : "5 Engine Slices • 72° Each"}</span>
            <ArrowUpRight size={12} />
          </div>
        </div>
      </div>
    </motion.section>
  );
}
