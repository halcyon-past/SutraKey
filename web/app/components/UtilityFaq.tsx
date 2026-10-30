import React from "react";
import { HelpCircle, ChevronDown } from "lucide-react";

const FAQ_ITEMS = [
  {
    q: "What is SutraKey and who created it?",
    a: "SutraKey (also written as Sutra Key) is an open-source, 100% on-device macOS utility created and engineered by Aritro Saha (known online as halcyon-past). It connects mouse text selection directly to high-speed media actions: holding Shift while selecting any link summons an under-cursor radial menu to download 4K video, extract 320kbps MP3 audio, pull subtitles (.srt), or convert web articles to clean ad-free vector PDFs directly to ~/Downloads.",
  },
  {
    q: "How do I download videos or extract MP3 audio on Mac without ads?",
    a: "With SutraKey running, hold the Shift key and highlight any video link (YouTube, Twitter/X, TikTok, Reddit, Vimeo) across Safari, Chrome, Slack, Notes, or Terminal. A liquid radial menu will instantly pop up at your cursor. Click or flick toward 'Video' for 4K/1080p MP4 or 'Audio' for 320kbps MP3 with embedded artwork. Alternatively, press the global hotkey ⌘⇧S (Command + Shift + S).",
  },
  {
    q: "How do I convert any web page or article into a clean vector PDF on Mac?",
    a: "Highlight the article URL while holding Shift, then release over the 'Clean PDF' slice on the radial menu. SutraKey launches Apple's native WebKit engine (WKWebView) in a headless vector pipeline, strips ads, cookie notices, and clutter, and generates a crisp, searchable, paginated vector PDF with active hyperlinks straight to your ~/Downloads folder.",
  },
  {
    q: "Can I download private Instagram Stories or member-only videos?",
    a: "Yes. SutraKey includes Keychain Browser Cookie Authentication. Open SutraKey Settings > Authentication, choose your preferred browser where you are logged in (Brave, Chrome, Safari, Edge, or Arc), and click 'Authorize & Test Keychain Access'. When macOS prompts for Keychain permission, click 'Always Allow'. SutraKey can then decrypt local session cookies in temporary RAM to download private Stories and member streams without logging your credentials.",
  },
  {
    q: "Why is a native Swift app better than web converters or browser extensions?",
    a: "Online downloader websites are notorious for popup ads, redirect chains, fake download buttons, malware threats, and 720p resolution caps. Browser extensions require broad permissions to read and modify all your tab data and constantly drain RAM. SutraKey runs 100% locally on your machine with 0% idle CPU, zero telemetry, and zero ads, giving you full 4K H.264/AAC MP4 files directly.",
  },
  {
    q: "How is SutraKey different from running yt-dlp in the Terminal?",
    a: "SutraKey bundles, maintains, and automatically updates embedded yt-dlp and ffmpeg binaries under the hood. Instead of having to open Terminal, navigate folders, copy-paste URLs, and type long command-line flag combinations, you get the full power of yt-dlp through an under-cursor radial gesture in less than half a second.",
  },
  {
    q: "Does SutraKey track my browsing history or collect telemetry?",
    a: "No. SutraKey operates with a strict 0% telemetry guarantee. Selected URLs are evaluated solely in volatile memory to trigger the local download and are never logged to disk or sent to external servers. All network requests connect directly between your Mac and the target media host.",
  },
  {
    q: "Is SutraKey completely free and open source?",
    a: "Yes. SutraKey is 100% free and open-source under the MIT License. The complete Swift 6 source code is publicly accessible on GitHub at https://github.com/halcyon-past/SutraKey.",
  },
];

export function UtilityFaq() {
  return (
    <section id="faq" className="py-16 md:py-24 px-4 max-w-4xl mx-auto">
      {/* Header */}
      <div className="text-center max-w-2xl mx-auto mb-12">
        <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 mb-4 border border-indigo-500/20">
          <HelpCircle size={13} />
          <span>Frequently Asked Questions</span>
        </div>
        <h2 className="text-3xl sm:text-4xl md:text-5xl font-semibold tracking-tight text-[#1d1d1f] dark:text-white mb-4">
          Everything you need to know.
        </h2>
        <p className="text-base sm:text-lg text-neutral-600 dark:text-neutral-300">
          Answers to common questions about downloading media, privacy, shortcuts, and setup on macOS.
        </p>
      </div>

      {/* Semantic Details / Summary Accordion for 100% Non-JS Crawler Readiness */}
      <div className="space-y-4">
        {FAQ_ITEMS.map((item, idx) => (
          <details
            key={idx}
            className="group rounded-2xl border border-black/[0.08] dark:border-white/[0.08] bg-white/60 dark:bg-white/[0.02] backdrop-blur-md p-5 sm:p-6 transition-all [&_summary::-webkit-details-marker]:hidden"
          >
            <summary className="flex items-center justify-between gap-4 font-semibold text-base sm:text-lg text-[#1d1d1f] dark:text-white cursor-pointer select-none">
              <span>{item.q}</span>
              <ChevronDown
                size={18}
                className="text-neutral-400 transition-transform duration-200 group-open:rotate-180 shrink-0"
              />
            </summary>
            <div className="mt-4 pt-4 border-t border-black/[0.04] dark:border-white/[0.04] text-sm sm:text-base text-neutral-600 dark:text-neutral-300 leading-relaxed font-normal">
              {item.a}
            </div>
          </details>
        ))}
      </div>
    </section>
  );
}
