import React from "react";
import { Navbar } from "./components/Navbar";
import { Hero } from "./components/Hero";
import { RadialSimulator } from "./components/RadialSimulator";
import { Highlights } from "./components/Highlights";
import { FormatShowcase } from "./components/FormatShowcase";
import { PlatformMatrix } from "./components/PlatformMatrix";
import { ComparisonTable } from "./components/ComparisonTable";
import { UtilityFaq } from "./components/UtilityFaq";
import { Installation } from "./components/Installation";
import { Footer } from "./components/Footer";
import { SmoothScrollProvider } from "./components/SmoothScrollProvider";

export default function Home() {
  return (
    <SmoothScrollProvider>
      <div className="relative min-h-screen flex flex-col bg-[#fafafc] text-[#1d1d1f] dark:bg-[#0b0b0f] dark:text-[#f5f5f7] transition-colors duration-400 overflow-x-hidden">
        {/* Hardware-Isolated Ambient Chromatic Lighting Background Pools */}
        <div className="pointer-events-none fixed inset-0 overflow-hidden z-0 contain-paint">
          {/* Top-right pastel pink ambient glow */}
          <div className="absolute top-[10%] right-[-10%] w-[600px] h-[600px] rounded-full ambient-glow-pink opacity-50 dark:opacity-25" />
          {/* Mid-left pastel mint ambient glow */}
          <div className="absolute top-[45%] left-[-10%] w-[650px] h-[650px] rounded-full ambient-glow-green opacity-40 dark:opacity-20" />
          {/* Lower-center subtle iris ambient glow */}
          <div className="absolute top-[75%] left-[25%] w-[700px] h-[700px] rounded-full ambient-glow-iris opacity-35 dark:opacity-15" />
        </div>

        <div className="relative z-10 flex flex-col min-h-screen">
          <Navbar />
          <main className="flex-1">
            <Hero />
            <RadialSimulator />
            <Highlights />
            <FormatShowcase />
            <PlatformMatrix />
            <ComparisonTable />
            <UtilityFaq />
            <Installation />
          </main>
          <Footer />

          {/* Non-JS Crawler & Accessibility Semantic Fallback */}
          <noscript>
            <div className="p-8 bg-[#0a0a0c] text-white max-w-4xl mx-auto my-8 rounded-2xl border border-white/10">
              <h2 className="text-2xl font-bold mb-4">SutraKey for macOS — Free 4K Media Downloader &amp; Web to PDF</h2>
              <p className="mb-4">
                Engineered by <strong>Aritro Saha (halcyon-past)</strong>. SutraKey is an open-source macOS utility. Hold Shift and select any URL across macOS to summon an under-cursor radial menu that downloads 4K/1080p video (MP4), extracts 320kbps MP3 audio with album art, downloads subtitles (.srt), or converts web articles into clean ad-free vector PDFs directly to ~/Downloads.
              </p>
              <h3 className="text-lg font-semibold mb-2">Supported Platforms &amp; Formats</h3>
              <ul className="list-disc pl-5 mb-4 space-y-1">
                <li><strong>YouTube:</strong> 4K, 1080p, 60fps MP4, Shorts, Playlists, Chapters.</li>
                <li><strong>Instagram:</strong> Reels, Posts, Carousels, and Stories via Keychain browser cookie authorization.</li>
                <li><strong>Twitter / X &amp; TikTok:</strong> High-definition video clips without browser watermarks.</li>
                <li><strong>Reddit:</strong> Automatically merges split video and audio streams into standard MP4.</li>
                <li><strong>Audio:</strong> 320kbps MP3 with embedded album art and ID3 metadata.</li>
                <li><strong>Clean Web to PDF:</strong> Ad-free, print-formatted vector PDF with active links via headless Apple WebKit.</li>
              </ul>
              <h3 className="text-lg font-semibold mb-2">Install via Homebrew</h3>
              <pre className="bg-white/10 p-3 rounded mb-4 font-mono text-sm">brew install --cask halcyon-past/tap/sutrakey</pre>
              <p>
                Direct DMG Download: <a href="https://github.com/halcyon-past/SutraKey/releases/latest/download/SutraKey.dmg" className="underline text-emerald-400">Download SutraKey.dmg</a> | GitHub Repository: <a href="https://github.com/halcyon-past/SutraKey" className="underline text-emerald-400">halcyon-past/SutraKey</a> | Developer: <a href="https://www.aritro.cloud/" className="underline text-emerald-400">Aritro Saha</a>
              </p>
            </div>
          </noscript>
        </div>
      </div>
    </SmoothScrollProvider>
  );
}
