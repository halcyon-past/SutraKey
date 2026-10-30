import React from "react";
import { Check, X, ShieldAlert, Sparkles, Cpu, ShieldCheck } from "lucide-react";

const COMPARISONS = [
  {
    criterion: "Security & Safety",
    webDownloaders: "Ad popups, fake download buttons & malware redirects",
    extensions: "Broad permissions; reads and changes data on all websites",
    terminal: "Safe but requires CLI knowledge & manual configuration",
    sutrakey: "100% on-device Swift 6 binary, zero telemetry, MIT open-source",
    sutrakeyWin: true,
  },
  {
    criterion: "User Experience",
    webDownloaders: "Copy link, open new tab, paste, solve captchas, wait in queue",
    extensions: "Toolbar icon clutter; frequently broken by browser updates",
    terminal: "Open Terminal, cd directory, remember long flag combinations",
    sutrakey: "Hold Shift + Select any link under your cursor or press ⌘⇧S",
    sutrakeyWin: true,
  },
  {
    criterion: "Video Output Quality",
    webDownloaders: "Usually capped at 720p; 1080p/4K locked behind paid subscriptions",
    extensions: "Often forces compressed webm streams with desynced audio",
    terminal: "Full 4K/8K 60fps MP4 (requires ffmpeg manual install)",
    sutrakey: "Native 4K & 1080p 60fps MP4 with merged AAC audio & +faststart",
    sutrakeyWin: true,
  },
  {
    criterion: "Audio Extraction",
    webDownloaders: "Low bitrate 128kbps MP3 without metadata or cover art",
    extensions: "Basic re-encode; no ID3 tag preservation",
    terminal: "320kbps MP3 (requires multi-flag command strings)",
    sutrakey: "Crystal 320kbps MP3 with embedded album art & ID3v2 tags",
    sutrakeyWin: true,
  },
  {
    criterion: "Ad-Free Web to PDF",
    webDownloaders: "Not supported",
    extensions: "Basic browser print raster with banner ads and cookie banners",
    terminal: "Not supported natively",
    sutrakey: "Headless Apple WebKit vector PDF with active links & clean layout",
    sutrakeyWin: true,
  },
  {
    criterion: "Resource Footprint",
    webDownloaders: "Heavy browser tab memory consumption",
    extensions: "Persistent background RAM footprint across all active tabs",
    terminal: "Zero background footprint",
    sutrakey: "0% idle CPU, ephemeral menu bar that vanishes when idle",
    sutrakeyWin: true,
  },
];

export function ComparisonTable() {
  return (
    <section id="compare" className="py-16 md:py-24 px-4 max-w-5xl mx-auto">
      {/* Header */}
      <div className="text-center max-w-3xl mx-auto mb-12">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 mb-4 border border-emerald-500/20">
          <ShieldCheck size={13} />
          <span>Why Mac Users Switch</span>
        </div>
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-4">
          The clean alternative to shady downloader sites.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300 leading-relaxed">
          See why developers, designers, and creators replace browser extensions and scam-filled web converters with <strong className="font-semibold text-neutral-900 dark:text-white">SutraKey by Aritro Saha (halcyon-past)</strong>.
        </p>
      </div>

      {/* Responsive Comparison Table */}
      <div className="overflow-x-auto rounded-3xl border border-black/[0.08] dark:border-white/[0.08] bg-white/60 dark:bg-white/[0.02] backdrop-blur-md shadow-sm">
        <table className="w-full text-left border-collapse text-xs sm:text-sm">
          <thead>
            <tr className="border-b border-black/[0.06] dark:border-white/[0.06] bg-black/[0.02] dark:bg-white/[0.02]">
              <th className="py-4 px-4 sm:px-6 font-semibold text-neutral-700 dark:text-neutral-300 w-1/4">
                Capability
              </th>
              <th className="py-4 px-3 sm:px-4 font-normal text-neutral-500 dark:text-neutral-400 w-1/4">
                Online Web Converters
              </th>
              <th className="py-4 px-3 sm:px-4 font-normal text-neutral-500 dark:text-neutral-400 w-1/4">
                Browser Extensions
              </th>
              <th className="py-4 px-4 sm:px-6 font-semibold text-emerald-600 dark:text-emerald-400 bg-emerald-500/[0.04] dark:bg-emerald-500/[0.08] w-1/4">
                SutraKey (Native macOS)
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-black/[0.04] dark:divide-white/[0.04]">
            {COMPARISONS.map((row) => (
              <tr key={row.criterion} className="hover:bg-black/[0.01] dark:hover:bg-white/[0.01] transition-colors">
                <td className="py-4 px-4 sm:px-6 font-semibold text-[#1d1d1f] dark:text-white align-top">
                  {row.criterion}
                </td>
                <td className="py-4 px-3 sm:px-4 text-neutral-600 dark:text-neutral-400 align-top leading-relaxed">
                  <div className="flex items-start gap-1.5">
                    <X size={14} className="text-rose-500 shrink-0 mt-0.5" />
                    <span>{row.webDownloaders}</span>
                  </div>
                </td>
                <td className="py-4 px-3 sm:px-4 text-neutral-600 dark:text-neutral-400 align-top leading-relaxed">
                  <div className="flex items-start gap-1.5">
                    <X size={14} className="text-amber-500 shrink-0 mt-0.5" />
                    <span>{row.extensions}</span>
                  </div>
                </td>
                <td className="py-4 px-4 sm:px-6 font-medium text-neutral-900 dark:text-neutral-100 bg-emerald-500/[0.04] dark:bg-emerald-500/[0.08] align-top leading-relaxed">
                  <div className="flex items-start gap-1.5">
                    <Check size={14} className="text-emerald-500 shrink-0 mt-0.5 font-bold" />
                    <span>{row.sutrakey}</span>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
