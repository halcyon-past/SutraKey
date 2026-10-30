import React from "react";
import { Film, Music, Globe, FileText, CheckCircle2, Video, Share2, Sparkles } from "lucide-react";

const PLATFORMS = [
  {
    name: "YouTube & Shorts",
    category: "Video & Audio",
    specs: "4K, 1080p, 60fps MP4 or 320kbps MP3",
    description: "Download high-resolution video streams merged with AAC audio. Auto-formats into QuickTime-compatible MP4 with +faststart.",
    queryHint: "YouTube video downloader for macOS without ads",
    badge: "4K / 1080p",
  },
  {
    name: "Instagram",
    category: "Reels, Posts & Stories",
    specs: "Full MP4 Reels & Multi-Image Carousels",
    description: "Download public reels and posts instantly. Decrypt local browser cookies via Keychain to save private posts and 24h Stories.",
    queryHint: "Save Instagram Reels and Stories on Mac",
    badge: "Keychain Auth",
  },
  {
    name: "Twitter / X",
    category: "Video Clips & GIFs",
    specs: "Highest Bitrate MP4",
    description: "Grab high-definition clips and media shared in tweets with a single mouse drag or keyboard shortcut.",
    queryHint: "Download Twitter X video on Mac",
    badge: "Lossless",
  },
  {
    name: "Reddit",
    category: "Video & Sound",
    specs: "Synced Audio + Video MP4",
    description: "Solves Reddit's infamous split audio/video stream problem. Automatically merges video and sound into a single flawless file.",
    queryHint: "Download Reddit videos with sound Mac",
    badge: "Auto-Muxed",
  },
  {
    name: "TikTok & Shorts",
    category: "Vertical Video",
    specs: "Original Resolution MP4",
    description: "Save vertical clips and creative shorts directly to your Downloads folder without watermarks or browser popups.",
    queryHint: "Download TikTok videos on Mac",
    badge: "Clean MP4",
  },
  {
    name: "Web Articles & Blogs",
    category: "Ad-Free Vector PDF",
    specs: "Apple WebKit (WKWebView) Vector PDF",
    description: "Strip ads, banners, and cookie consent overlays from Substack, Medium, news, and technical documentation into searchable PDFs.",
    queryHint: "Convert web articles to clean PDF Mac",
    badge: "Reader Mode",
  },
  {
    name: "Vimeo & Twitch",
    category: "Creative Video & Streams",
    specs: "Original Master Streams",
    description: "Direct media extraction from filmmaker portfolios on Vimeo and broadcast clips on Twitch with zero compression loss.",
    queryHint: "Vimeo and Twitch downloader for Mac",
    badge: "Master Bitrate",
  },
  {
    name: "Soundcloud & Bandcamp",
    category: "Music & Podcasts",
    specs: "320kbps MP3 / Lossless M4A",
    description: "Extract pure audio with embedded cover artwork and ID3 metadata tags (Title, Artist, Album) straight into Apple Music.",
    queryHint: "Extract MP3 audio with artwork Mac",
    badge: "ID3 Metadata",
  },
];

export function PlatformMatrix() {
  return (
    <section id="platforms" className="py-16 md:py-24 px-4 max-w-5xl mx-auto">
      {/* Section Header */}
      <div className="text-center max-w-3xl mx-auto mb-12">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-pink-500/10 text-pink-600 dark:text-pink-400 mb-4 border border-pink-500/20">
          <span>Universal Source Compatibility</span>
        </div>
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-4">
          Download from any link. On any platform.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300 leading-relaxed">
          Engineered with an embedded, auto-updating <code className="font-mono text-xs px-1.5 py-0.5 rounded bg-black/5 dark:bg-white/10">yt-dlp</code> and <code className="font-mono text-xs px-1.5 py-0.5 rounded bg-black/5 dark:bg-white/10">ffmpeg</code> core by <strong className="font-semibold text-neutral-900 dark:text-white">Aritro Saha (halcyon-past)</strong>. Supports over 1,000 video hosts, audio networks, and article publishers.
        </p>
      </div>

      {/* Grid of Platforms */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {PLATFORMS.map((platform) => (
          <div
            key={platform.name}
            className="p-5 rounded-2xl bg-white/70 dark:bg-white/[0.03] border border-black/[0.06] dark:border-white/[0.08] backdrop-blur-sm shadow-sm flex flex-col justify-between hover:border-black/20 dark:hover:border-white/20 transition-all hover:-translate-y-0.5"
          >
            <div>
              <div className="flex items-center justify-between gap-2 mb-3">
                <span className="text-[11px] font-semibold text-neutral-400 dark:text-neutral-500 uppercase tracking-wider">
                  {platform.category}
                </span>
                <span className="text-[10px] font-medium px-2 py-0.5 rounded-full bg-black/[0.04] dark:bg-white/[0.08] text-neutral-700 dark:text-neutral-300 border border-black/[0.04] dark:border-white/[0.06]">
                  {platform.badge}
                </span>
              </div>
              <h3 className="text-lg font-semibold text-[#1d1d1f] dark:text-white mb-1.5">
                {platform.name}
              </h3>
              <p className="text-xs text-neutral-600 dark:text-neutral-400 leading-relaxed mb-4">
                {platform.description}
              </p>
            </div>

            <div className="pt-3 border-t border-black/[0.04] dark:border-white/[0.04] flex items-center justify-between text-[11px] text-neutral-500 dark:text-neutral-400">
              <span className="font-mono text-[10px] opacity-75">{platform.specs}</span>
              <CheckCircle2 size={13} className="text-emerald-500 shrink-0" />
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
