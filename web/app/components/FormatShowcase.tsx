"use client";

import React, { useState } from "react";
import { Film, Music, FileText, Image as ImageIcon, BookOpen, Terminal } from "lucide-react";
import { LiquidGlass } from "./LiquidGlass";

const FORMAT_TABS = [
  {
    id: "video",
    label: "Video (MP4)",
    icon: Film,
    accent: "#ff6b3d",
    headline: "Universal 4K & 1080p MP4.",
    subtitle: "Merged with native H.264 video and AAC audio for flawless playback in QuickTime and Apple Photos.",
    specs: [
      { label: "Video Codec", value: "H.264 (avc1) / 4K / 1080p / 60fps" },
      { label: "Audio Codec", value: "AAC (m4a) Stereo 48kHz" },
      { label: "Container", value: "Standard MP4 with +faststart" },
      { label: "Compatibility", value: "macOS QuickLook, iOS, AirDrop, Final Cut" },
    ],
    cli: "yt-dlp --format-sort vcodec:h264,res,acodec:m4a --merge-output-format mp4",
  },
  {
    id: "audio",
    label: "Audio (MP3)",
    icon: Music,
    accent: "#38bdf8",
    headline: "Crystal 320kbps MP3 with Artwork.",
    subtitle: "High-bitrate audio extraction with embedded ID3v2 metadata, title, artist, and album art.",
    specs: [
      { label: "Bitrate", value: "320 kbps Constant Bitrate (CBR)" },
      { label: "Metadata", value: "ID3v2 (Title, Artist, Album, Year)" },
      { label: "Artwork", value: "Embedded square album cover PNG" },
      { label: "Compatibility", value: "Apple Music, Podcasts, Car Audio" },
    ],
    cli: "yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata",
  },
  {
    id: "subtitles",
    label: "Subtitles (SRT)",
    icon: FileText,
    accent: "#fbbf24",
    headline: "Pure UTF-8 Subtitles.",
    subtitle: "Extracts human-curated or machine-generated captions into clean standard SRT format without video payload.",
    specs: [
      { label: "Format", value: "Standard SubRip (.srt)" },
      { label: "Encoding", value: "UTF-8 with millisecond timestamps" },
      { label: "Languages", value: "Auto-detected original + translation" },
      { label: "Payload", value: "Instant text download (~25 KB)" },
    ],
    cli: "yt-dlp --write-subs --write-auto-subs --sub-format srt --skip-download",
  },
  {
    id: "gallery",
    label: "Gallery / Images",
    icon: ImageIcon,
    accent: "#c084fc",
    headline: "Full-Resolution Artwork & Albums.",
    subtitle: "Fetches the uncompressed master thumbnail or carousel gallery without downloading video streams.",
    specs: [
      { label: "Resolution", value: "Original master resolution (up to 4K)" },
      { label: "Format", value: "Lossless PNG or maximum quality JPG" },
      { label: "Multi-Image", value: "Instagram carousels / multi-card sets" },
      { label: "Storage", value: "Direct to ~/Downloads with clean titles" },
    ],
    cli: "yt-dlp --write-thumbnail --skip-download",
  },
  {
    id: "pdf",
    label: "Clean PDF",
    icon: BookOpen,
    accent: "#34d399",
    headline: "Ad-Free Reader Mode PDF.",
    subtitle: "Renders web articles and long-form threads into a pristine, readable PDF via offscreen headless WKWebView.",
    specs: [
      { label: "Engine", value: "Offscreen Apple WebKit (WKWebView)" },
      { label: "Styling", value: "Reader Mode typography (San Francisco)" },
      { label: "Stripping", value: "Removes ads, cookie banners, tracking scripts" },
      { label: "Offline", value: "Fully self-contained vector PDF with selectable text" },
    ],
    cli: "WebToPDFService.shared.convertToPDF(url: targetURL)",
  },
];

export function FormatShowcase() {
  const [activeTab, setActiveTab] = useState(FORMAT_TABS[0]);

  return (
    <section id="formats" className="py-16 md:py-24 px-4 max-w-5xl mx-auto">
      {/* Apple-style Section Header */}
      <div className="text-center max-w-2xl mx-auto mb-10">
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-3">
          Take a closer look.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300">
          Five specialized media engines. Built directly into a single zero-latency pie menu.
        </p>
      </div>

      {/* Segmented Glass Tab Bar */}
      <div className="flex items-center justify-center mb-10 overflow-x-auto pb-2">
        <div className="p-1 rounded-full bg-black/[0.04] dark:bg-white/[0.06] border border-black/[0.06] dark:border-white/[0.1] backdrop-blur-xl flex items-center gap-1">
          {FORMAT_TABS.map((tab) => {
            const isActive = activeTab.id === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab)}
                className={`flex items-center gap-2 px-4 py-2 rounded-full text-xs font-semibold transition-all duration-200 whitespace-nowrap cursor-pointer ${
                  isActive
                    ? "bg-white dark:bg-[#1d1d24] text-[#1d1d1f] dark:text-white shadow-sm"
                    : "text-neutral-500 dark:text-neutral-400 hover:text-black dark:hover:text-white"
                }`}
              >
                <tab.icon size={14} style={{ color: isActive ? tab.accent : "currentColor" }} />
                <span>{tab.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Active Format Glass Card */}
      <LiquidGlass
        radius={28}
        depth={1.5}
        blur={10}
        dispersion={0.7}
        specular={0.6}
        className="p-8 sm:p-12 rounded-[28px]"
      >
        <div className="grid grid-cols-1 md:grid-cols-12 gap-8 items-center">
          {/* Left Column: Headline and Description */}
          <div className="md:col-span-7">
            <div
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-bold mb-4"
              style={{ backgroundColor: `${activeTab.accent}18`, color: activeTab.accent }}
            >
              <activeTab.icon size={14} />
              <span>{activeTab.label}</span>
            </div>

            <h3 className="text-2xl sm:text-3xl md:text-4xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-4">
              {activeTab.headline}
            </h3>

            <p className="text-base text-neutral-600 dark:text-neutral-300 leading-relaxed mb-6 font-normal">
              {activeTab.subtitle}
            </p>

            {/* Terminal Command Peek */}
            <div className="flex items-center gap-2 px-4 py-3 rounded-xl bg-black/[0.04] dark:bg-white/[0.05] border border-black/[0.04] dark:border-white/[0.08] font-mono text-xs text-neutral-600 dark:text-neutral-300">
              <Terminal size={14} className="shrink-0 text-neutral-400" />
              <span className="truncate">{activeTab.cli}</span>
            </div>
          </div>

          {/* Right Column: Spec Sheet */}
          <div className="md:col-span-5 bg-black/[0.02] dark:bg-white/[0.03] p-6 rounded-2xl border border-black/[0.04] dark:border-white/[0.06]">
            <h4 className="text-xs font-bold uppercase tracking-wider text-neutral-400 mb-4">
              Pipeline Specifications
            </h4>
            <div className="space-y-3">
              {activeTab.specs.map((spec) => (
                <div key={spec.label} className="flex flex-col text-xs pb-2.5 border-b border-black/[0.04] dark:border-white/[0.04] last:border-0 last:pb-0">
                  <span className="text-neutral-500 dark:text-neutral-400 mb-0.5">{spec.label}</span>
                  <span className="font-semibold text-[#1d1d1f] dark:text-neutral-100">{spec.value}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </LiquidGlass>
    </section>
  );
}
