"use client";

import React, { useState, useEffect, useRef } from "react";
import Image from "next/image";
import {
  Film,
  Music,
  FileText,
  Image as ImageIcon,
  BookOpen,
  Download,
  Copy,
  Check,
  ShieldCheck,
  Terminal,
  Zap,
  Clock,
  Sparkles,
  ExternalLink,
  Layers,
  FolderDown,
  ChevronRight,
  EyeOff,
  Bell,
  CornerDownRight,
} from "lucide-react";

function GithubIcon({ size = 18, className = "" }: { size?: number; className?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="currentColor" className={className}>
      <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
    </svg>
  );
}

interface Slice {
  id: string;
  name: string;
  badge: string;
  color: string;
  icon: React.ComponentType<{ className?: string; size?: number }>;
  desc: string;
  format: string;
  top: string;
  left: string;
}

const SLICES: Slice[] = [
  {
    id: "video",
    name: "Video (MP4)",
    badge: "MP4",
    color: "#ff6b3d",
    icon: Film,
    desc: "Best quality video + audio merged via yt-dlp + ffmpeg",
    format: "4K / 1080p MP4",
    top: "28%",
    left: "78%",
  },
  {
    id: "audio",
    name: "Audio (MP3)",
    badge: "MP3",
    color: "#38bdf8",
    icon: Music,
    desc: "Best audio extracted to 320kbps MP3 with embedded artwork",
    format: "320kbps MP3",
    top: "74%",
    left: "72%",
  },
  {
    id: "subtitles",
    name: "Subtitles (SRT)",
    badge: "SRT",
    color: "#fbbf24",
    icon: FileText,
    desc: "Human or auto-generated subtitles extracted to clean SRT",
    format: "Clean .srt",
    top: "84%",
    left: "34%",
  },
  {
    id: "gallery",
    name: "Images / Gallery",
    badge: "IMG",
    color: "#c084fc",
    icon: ImageIcon,
    desc: "Highest resolution thumbnail or full photo gallery",
    format: "High-Res PNG / JPG",
    top: "48%",
    left: "18%",
  },
  {
    id: "pdf",
    name: "Clean PDF",
    badge: "PDF",
    color: "#34d399",
    icon: BookOpen,
    desc: "Web article rendered into an ad-free reader PDF via WKWebView",
    format: "Reader-Mode PDF",
    top: "20%",
    left: "40%",
  },
];

export default function HomePage() {
  const [copiedBrew, setCopiedBrew] = useState(false);
  const [activeSlice, setActiveSlice] = useState<Slice | null>(null);
  const [inDeadZone, setInDeadZone] = useState(false);
  const [shiftPressed, setShiftPressed] = useState(false);
  const [toastVisible, setToastVisible] = useState(false);
  const [toastProgress, setToastProgress] = useState(0);
  const [toastMessage, setToastMessage] = useState({
    title: "SutraKey Started",
    sub: "Converting to MP4 • youtube.com",
    color: "#ff6b3d",
  });

  const toastTimerRef = useRef<NodeJS.Timeout | null>(null);
  const progressTimerRef = useRef<NodeJS.Timeout | null>(null);

  // Monitor physical Shift key state
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Shift") {
        setShiftPressed(true);
      }
    };
    const handleKeyUp = (e: KeyboardEvent) => {
      if (e.key === "Shift") {
        setShiftPressed(false);
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);
    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      window.removeEventListener("keyup", handleKeyUp);
    };
  }, []);

  const copyBrew = () => {
    navigator.clipboard.writeText(
      "brew tap aritrosaha/sutrakey && brew install --cask sutrakey"
    );
    setCopiedBrew(true);
    setTimeout(() => setCopiedBrew(false), 2200);
  };

  const handleSliceHover = (slice: Slice) => {
    setInDeadZone(false);
    setActiveSlice(slice);

    // Trigger HUD Toast Simulation
    setToastMessage({
      title: `Converting to ${slice.name}`,
      sub: `${slice.desc} • ~/Downloads`,
      color: slice.color,
    });
    setToastVisible(true);
    setToastProgress(0);

    if (progressTimerRef.current) clearInterval(progressTimerRef.current);
    if (toastTimerRef.current) clearTimeout(toastTimerRef.current);

    let current = 0;
    progressTimerRef.current = setInterval(() => {
      current += 6;
      if (current >= 100) {
        clearInterval(progressTimerRef.current!);
        setToastProgress(100);
        setToastMessage({
          title: "Saved to ~/Downloads",
          sub: `SutraKey_Media.${slice.badge.toLowerCase()}`,
          color: slice.color,
        });

        toastTimerRef.current = setTimeout(() => {
          setToastVisible(false);
        }, 3200);
      } else {
        setToastProgress(current);
      }
    }, 45);
  };

  const handleCenterHover = () => {
    setActiveSlice(null);
    setInDeadZone(true);
  };

  const handleCenterLeave = () => {
    setInDeadZone(false);
  };

  return (
    <div className="radial-bg min-h-screen">
      {/* Navigation Header */}
      <header className="sticky top-0 z-50 border-b border-white/[0.08] bg-[#090a0d]/80 backdrop-blur-xl">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-[#14151a] border border-white/10 p-1 flex items-center justify-center shadow-lg">
              <Image
                src="/AppIcon-1024.png"
                alt="SutraKey Icon"
                width={30}
                height={30}
                className="rounded-lg"
              />
            </div>
            <div className="flex items-center gap-2">
              <span className="font-bold text-lg tracking-tight">SutraKey</span>
              <span className="text-[11px] font-mono bg-[#ff6b3d]/15 text-[#ff6b3d] px-2 py-0.5 rounded-full border border-[#ff6b3d]/30">
                v1.0.0
              </span>
            </div>
          </div>

          <nav className="flex items-center gap-6">
            <a
              href="#simulator"
              className="text-sm font-medium text-slate-400 hover:text-white transition-colors"
            >
              Interactive Wheel
            </a>
            <a
              href="#features"
              className="text-sm font-medium text-slate-400 hover:text-white transition-colors"
            >
              Features
            </a>
            <a
              href="#pipeline"
              className="text-sm font-medium text-slate-400 hover:text-white transition-colors"
            >
              Architecture
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey"
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-2 text-sm font-medium text-slate-300 hover:text-white bg-white/5 border border-white/10 px-3.5 py-1.5 rounded-lg transition-all hover:bg-white/10"
            >
              <GithubIcon size={16} />
              <span>GitHub</span>
            </a>
          </nav>
        </div>
      </header>

      {/* Hero Section */}
      <section className="pt-20 pb-16 px-6 text-center">
        <div className="max-w-4xl mx-auto">
          {/* OS Badge */}
          <div className="inline-flex items-center gap-2.5 px-4 py-1.5 rounded-full bg-white/[0.04] border border-white/10 text-xs text-slate-300 mb-8 backdrop-blur-md">
            <span className="w-2 h-2 rounded-full bg-emerald-400 shadow-[0_0_8px_rgba(52,211,153,0.8)]" />
            <span>macOS 14.0 Sonoma+ • Universal Binary (arm64 & x86_64)</span>
          </div>

          <h1 className="text-5xl sm:text-7xl font-extrabold tracking-tight leading-[1.08] mb-6">
            Hold <span className={`keycap ${shiftPressed ? "pressed" : ""}`}>⇧ Shift</span> + Select.
            <br />
            <span className="bg-gradient-to-r from-white via-slate-200 to-[#ff7a4d] bg-clip-text text-transparent">
              Zero-Latency Radial Actions.
            </span>
          </h1>

          <p className="text-lg sm:text-xl text-slate-400 max-w-2xl mx-auto mb-10 leading-relaxed font-normal">
            SutraKey is the invisible thread connecting your URL text selection to
            instant video, 320kbps audio, subtitles, or clean reader PDFs saved
            straight to <code className="text-slate-200 bg-white/5 px-2 py-0.5 rounded font-mono text-sm">~/Downloads</code>.
          </p>

          {/* Download & Copy Buttons */}
          <div className="flex flex-wrap items-center justify-center gap-4 mb-8">
            <a
              href="https://github.com/halcyon-past/SutraKey/releases"
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-2.5 px-7 py-3.5 rounded-xl bg-gradient-to-b from-[#ff7a4d] to-[#ff521d] text-white font-semibold text-[15px] shadow-[0_8px_24px_rgba(255,107,61,0.35)] hover:shadow-[0_12px_32px_rgba(255,107,61,0.5)] hover:-translate-y-0.5 transition-all"
            >
              <Download size={18} />
              <span>Download SutraKey (.dmg)</span>
            </a>

            <a
              href="https://github.com/halcyon-past/SutraKey"
              target="_blank"
              rel="noreferrer"
              className="flex items-center gap-2 px-6 py-3.5 rounded-xl bg-white/[0.05] border border-white/10 text-slate-200 font-semibold text-[15px] hover:bg-white/[0.09] hover:border-white/20 transition-all backdrop-blur-md"
            >
              <GithubIcon size={18} />
              <span>Star on GitHub</span>
            </a>
          </div>

          {/* One-Click Homebrew Box */}
          <div className="max-w-xl mx-auto bg-[#101115] border border-white/10 rounded-xl p-3 flex items-center justify-between gap-4 shadow-2xl">
            <div className="flex items-center gap-2 font-mono text-xs sm:text-sm text-sky-400 overflow-x-auto whitespace-nowrap pl-2">
              <span className="text-slate-500">$</span>
              <span>brew tap aritrosaha/sutrakey && brew install --cask sutrakey</span>
            </div>
            <button
              onClick={copyBrew}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium border transition-all shrink-0 ${
                copiedBrew
                  ? "bg-emerald-500/20 border-emerald-500/40 text-emerald-300"
                  : "bg-white/10 border-white/15 text-slate-200 hover:bg-white/15"
              }`}
            >
              {copiedBrew ? <Check size={14} /> : <Copy size={14} />}
              <span>{copiedBrew ? "Copied!" : "Copy"}</span>
            </button>
          </div>
        </div>
      </section>

      {/* Interactive Radial Simulator Section */}
      <section className="py-16 px-6" id="simulator">
        <div className="max-w-5xl mx-auto">
          <div className="glass-panel rounded-3xl p-8 sm:p-12 relative overflow-hidden shadow-2xl border-white/10">
            {/* Header info */}
            <div className="text-center max-w-xl mx-auto mb-10">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-[#ff6b3d]/10 text-[#ff6b3d] text-xs font-mono mb-3 border border-[#ff6b3d]/20">
                <Sparkles size={12} />
                <span>Live Browser Simulator</span>
              </div>
              <h2 className="text-3xl font-bold tracking-tight mb-2">
                Under-Cursor Radial HUD
              </h2>
              <p className="text-slate-400 text-sm">
                Hover over the 5 slices to test real-time action resolution, or center to
                test the <span className="text-amber-400 font-semibold">&lt; 28pt cancel dead-zone</span>.
              </p>
            </div>

            {/* Stage containing Radial Menu + Toast panel */}
            <div className="relative min-h-[460px] flex flex-col items-center justify-center">
              {/* Simulated Floating Toast HUD */}
              <div
                className={`absolute top-0 right-0 sm:right-6 w-80 glass-panel rounded-2xl p-3.5 flex gap-3 shadow-2xl border-white/15 transition-all duration-300 z-30 ${
                  toastVisible
                    ? "translate-x-0 opacity-100"
                    : "translate-x-12 opacity-0 pointer-events-none"
                }`}
              >
                <div
                  className="w-9 h-9 rounded-xl flex items-center justify-center shrink-0"
                  style={{
                    backgroundColor: `${toastMessage.color}20`,
                    color: toastMessage.color,
                  }}
                >
                  <FolderDown size={18} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-xs font-bold text-white truncate">
                    {toastMessage.title}
                  </div>
                  <div className="text-[11px] text-slate-400 truncate mt-0.5">
                    {toastMessage.sub}
                  </div>
                  <div className="w-full bg-white/10 h-1 rounded-full mt-2.5 overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-75"
                      style={{
                        width: `${toastProgress}%`,
                        backgroundColor: toastMessage.color,
                      }}
                    />
                  </div>
                </div>
              </div>

              {/* Radial Wheel */}
              <div className="relative w-80 h-80 select-none">
                {/* Circular Glass Disc */}
                <div className="w-full h-full rounded-full bg-[#16171e]/90 border border-white/15 shadow-[0_20px_60px_rgba(0,0,0,0.8)] backdrop-blur-2xl relative flex items-center justify-center">
                  {/* Center Dead Zone Hub (< 28pt) */}
                  <div
                    onMouseEnter={handleCenterHover}
                    onMouseLeave={handleCenterLeave}
                    className={`w-16 h-16 rounded-full border transition-all duration-200 flex flex-col items-center justify-center z-20 cursor-pointer shadow-lg ${
                      inDeadZone
                        ? "bg-red-500/20 border-red-500/60 text-red-400 scale-95"
                        : activeSlice
                        ? "bg-[#111216] border-white/30 text-white"
                        : "bg-[#14151a] border-white/15 text-slate-400"
                    }`}
                  >
                    {inDeadZone ? (
                      <span className="text-[9px] font-bold font-mono tracking-wider">
                        CANCEL
                      </span>
                    ) : activeSlice ? (
                      <activeSlice.icon size={16} />
                    ) : (
                      <span className="w-2.5 h-2.5 rounded-full bg-[#ff6b3d] shadow-[0_0_8px_#ff6b3d]" />
                    )}
                  </div>

                  {/* 5 Slices */}
                  {SLICES.map((slice) => {
                    const IconComponent = slice.icon;
                    const isActive = activeSlice?.id === slice.id;
                    return (
                      <button
                        key={slice.id}
                        onMouseEnter={() => handleSliceHover(slice)}
                        style={{
                          top: slice.top,
                          left: slice.left,
                          transform: `translate(-50%, -50%) ${
                            isActive ? "scale(1.18)" : "scale(1)"
                          }`,
                          color: isActive ? slice.color : "#94a3b8",
                        }}
                        className="absolute flex flex-col items-center gap-1.5 transition-all duration-200 focus:outline-none z-10 p-2"
                      >
                        <div
                          className={`p-2 rounded-xl transition-all ${
                            isActive
                              ? "bg-white/10 shadow-lg"
                              : "hover:bg-white/5"
                          }`}
                        >
                          <IconComponent size={22} />
                        </div>
                        <span
                          className={`text-[10px] font-bold font-mono px-1.5 py-0.5 rounded transition-all ${
                            isActive
                              ? "bg-white text-black font-extrabold"
                              : "bg-white/5 text-slate-400"
                          }`}
                        >
                          {slice.badge}
                        </span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Hardware Keyboard Shift Sensor */}
              <div className="mt-8 flex items-center gap-3 px-4 py-2 rounded-full bg-black/40 border border-white/10 backdrop-blur-md">
                <span
                  className={`w-2.5 h-2.5 rounded-full transition-all duration-200 ${
                    shiftPressed
                      ? "bg-[#ff6b3d] shadow-[0_0_12px_#ff6b3d]"
                      : "bg-slate-600"
                  }`}
                />
                <span className="text-xs text-slate-300 font-mono">
                  Hardware Shift Key:{" "}
                  <strong className={shiftPressed ? "text-[#ff6b3d]" : "text-slate-400"}>
                    {shiftPressed ? "PRESSED (ACTIVE)" : "IDLE"}
                  </strong>{" "}
                  — Press <span className="keycap text-[10px] py-0.5 px-1.5">⇧ Shift</span> on keyboard
                </span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Core Features Grid */}
      <section className="py-20 px-6" id="features">
        <div className="max-w-6xl mx-auto">
          <div className="text-center max-w-2xl mx-auto mb-16">
            <h2 className="text-4xl font-extrabold tracking-tight mb-4">
              Engineered for Zero Pollution & High Craft
            </h2>
            <p className="text-slate-400 text-base">
              Native Swift 6 architecture running with zero telemetry, zero paywalls,
              and 0% CPU consumption when idle.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {/* Feature 1 */}
            <div className="glass-panel glass-panel-hover rounded-2xl p-7">
              <div className="w-11 h-11 rounded-xl bg-orange-500/10 border border-orange-500/20 text-[#ff6b3d] flex items-center justify-center mb-5">
                <ShieldCheck size={22} />
              </div>
              <h3 className="text-lg font-bold mb-2">Zero Modifier Pollution</h3>
              <p className="text-sm text-slate-400 leading-relaxed">
                Bitwise checks on <code>deviceIndependentFlagsMask</code> enforce that
                only the Shift key triggers the HUD. If ⌘, ⌥, or ⌃ is pressed, SutraKey
                instantly dismisses.
              </p>
            </div>

            {/* Feature 2 */}
            <div className="glass-panel glass-panel-hover rounded-2xl p-7">
              <div className="w-11 h-11 rounded-xl bg-sky-500/10 border border-sky-500/20 text-sky-400 flex items-center justify-center mb-5">
                <EyeOff size={22} />
              </div>
              <h3 className="text-lg font-bold mb-2">Ephemeral Menu Bar</h3>
              <p className="text-sm text-slate-400 leading-relaxed">
                SutraKey has no Dock icon (<code>LSUIElement = YES</code>) and no menu
                bar icon when idle. It only appears during active jobs and vanishes 1.5s
                after completion.
              </p>
            </div>

            {/* Feature 3 */}
            <div className="glass-panel glass-panel-hover rounded-2xl p-7">
              <div className="w-11 h-11 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-400 flex items-center justify-center mb-5">
                <Bell size={22} />
              </div>
              <h3 className="text-lg font-bold mb-2">Frosted Glass Toast Panel</h3>
              <p className="text-sm text-slate-400 leading-relaxed">
                Custom floating <code>SutraToastPanel</code> in <code>.ultraThinMaterial</code>{" "}
                with one-click "Show in Finder" and "Copy Error Log" action buttons.
              </p>
            </div>

            {/* Feature 4 */}
            <div className="glass-panel glass-panel-hover rounded-2xl p-7">
              <div className="w-11 h-11 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 flex items-center justify-center mb-5">
                <FolderDown size={22} />
              </div>
              <h3 className="text-lg font-bold mb-2">Strict ~/Downloads Sandbox</h3>
              <p className="text-sm text-slate-400 leading-relaxed">
                Output routes exclusively to <code>~/Downloads</code>. Traversal attempts
                (<code>../</code>) and illegal filename characters are stripped with{" "}
                <code>--no-exec</code> protection.
              </p>
            </div>

            {/* Feature 5 */}
            <div className="glass-panel glass-panel-hover rounded-2xl p-7">
              <div className="w-11 h-11 rounded-xl bg-purple-500/10 border border-purple-500/20 text-purple-400 flex items-center justify-center mb-5">
                <BookOpen size={22} />
              </div>
              <h3 className="text-lg font-bold mb-2">Offscreen Web-to-PDF</h3>
              <p className="text-sm text-slate-400 leading-relaxed">
                An offscreen <code>WKWebView</code> engine strips intrusive ads, navigation bars,
                and cookie popups to generate pristine reader-mode PDFs.
              </p>
            </div>

            {/* Feature 6 */}
            <div className="glass-panel glass-panel-hover rounded-2xl p-7">
              <div className="w-11 h-11 rounded-xl bg-slate-500/10 border border-slate-500/20 text-slate-300 flex items-center justify-center mb-5">
                <Terminal size={22} />
              </div>
              <h3 className="text-lg font-bold mb-2">Binary Bootstrap Service</h3>
              <p className="text-sm text-slate-400 leading-relaxed">
                Auto-resolves <code>yt-dlp</code> and <code>ffmpeg</code> across bundled
                binaries, Homebrew, and local user paths with one-click self-updating.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Execution Pipeline Architecture */}
      <section className="py-16 px-6" id="pipeline">
        <div className="max-w-5xl mx-auto">
          <div className="bg-[#0e0f14] border border-white/10 rounded-2xl p-8 sm:p-10 shadow-2xl">
            <h3 className="text-xl font-bold tracking-tight mb-8 text-center">
              Zero-Latency Native Execution Pipeline
            </h3>

            <div className="flex flex-wrap items-center justify-center gap-3 text-xs font-mono">
              <div className="bg-[#181920] border border-white/10 px-3.5 py-2 rounded-lg text-slate-200">
                ⇧ Shift + Select
              </div>
              <ChevronRight size={16} className="text-slate-600" />
              <div className="bg-[#181920] border border-white/10 px-3.5 py-2 rounded-lg text-slate-200">
                CGEventTap
              </div>
              <ChevronRight size={16} className="text-slate-600" />
              <div className="bg-[#181920] border border-white/10 px-3.5 py-2 rounded-lg text-slate-200">
                ModifierExclusivity
              </div>
              <ChevronRight size={16} className="text-slate-600" />
              <div className="bg-[#ff6b3d]/15 border border-[#ff6b3d]/30 px-3.5 py-2 rounded-lg text-[#ff6b3d] font-bold">
                Radial HUD NSPanel
              </div>
              <ChevronRight size={16} className="text-slate-600" />
              <div className="bg-[#181920] border border-white/10 px-3.5 py-2 rounded-lg text-slate-200">
                ConversionTaskActor
              </div>
              <ChevronRight size={16} className="text-slate-600" />
              <div className="bg-emerald-500/15 border border-emerald-500/30 px-3.5 py-2 rounded-lg text-emerald-400 font-bold">
                ~/Downloads
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-white/[0.08] py-12 px-6 text-center text-xs text-slate-500">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <Image
              src="/AppIcon-1024.png"
              alt="SutraKey"
              width={20}
              height={20}
              className="rounded"
            />
            <span className="font-semibold text-slate-400">SutraKey (सूत्र)</span>
            <span>— 100% Free & Open Source macOS Utility</span>
          </div>

          <div className="flex items-center gap-6 text-slate-400">
            <a
              href="https://github.com/halcyon-past/SutraKey"
              target="_blank"
              rel="noreferrer"
              className="hover:text-white transition-colors"
            >
              GitHub
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey/blob/main/LICENSE"
              target="_blank"
              rel="noreferrer"
              className="hover:text-white transition-colors"
            >
              MIT License
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey/blob/main/CONTRIBUTING.md"
              target="_blank"
              rel="noreferrer"
              className="hover:text-white transition-colors"
            >
              Contributing
            </a>
            <a
              href="https://github.com/halcyon-past/SutraKey/blob/main/SECURITY.md"
              target="_blank"
              rel="noreferrer"
              className="hover:text-white transition-colors"
            >
              Security
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}
