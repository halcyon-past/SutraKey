import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap",
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
  display: "swap",
});

const SITE_URL = "https://sutrakey.aritro.cloud";
const PERSON_ID = "https://www.aritro.cloud/#person";

export const viewport: Viewport = {
  themeColor: "#0a0a0c",
  colorScheme: "dark",
  width: "device-width",
  initialScale: 1,
};

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "Free 4K Video Downloader, Audio Extractor & Web to PDF for Mac — SutraKey by Aritro Saha",
    template: "%s | SutraKey for macOS by Aritro Saha (halcyon-past)",
  },
  description:
    "Free, open-source macOS media downloader created by Aritro Saha (halcyon-past). Hold Shift and select any link to download 4K/1080p video (YouTube, Twitter/X, TikTok, Reddit), extract 320kbps MP3 audio with artwork, or save web articles as clean ad-free vector PDFs directly to ~/Downloads. 100% native Swift 6, zero telemetry.",
  applicationName: "SutraKey by Aritro Saha (halcyon-past)",
  authors: [{ name: "Aritro Saha (halcyon-past)", url: "https://www.aritro.cloud/" }],
  creator: "Aritro Saha (halcyon-past)",
  publisher: "Aritro Saha",
  category: "Utilities & Productivity",
  keywords: [
    "macOS media downloader",
    "mac video downloader no ads",
    "free mac video downloader",
    "download youtube video mac",
    "extract audio to mp3 mac",
    "convert webpage to clean pdf mac",
    "yt-dlp mac GUI",
    "save instagram stories mac",
    "download reddit video audio mac",
    "download twitter x video mac",
    "shift select download mac",
    "radial menu media downloader macos",
    "download subtitles srt mac",
    "open source mac video downloader",
    "native swift 6 mac utility",
    "4k 60fps youtube downloader mac",
    "web article to vector pdf mac",
    "zero telemetry mac app",
    "Aritro Saha",
    "halcyon-past",
    "Aritro Saha developer",
    "SutraKey",
    "Sutra Key",
    "SutraKey macOS",
    "Sutra Key macOS",
  ],
  alternates: {
    canonical: "/",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: SITE_URL,
    siteName: "SutraKey by Aritro Saha (halcyon-past)",
    title: "Free 4K Video Downloader, Audio Extractor & Web to PDF for Mac — SutraKey",
    description:
      "Free open-source macOS media downloader by Aritro Saha (halcyon-past). Hold Shift + Select any link to download 4K video, 320kbps MP3 audio, or clean vector PDFs straight to ~/Downloads. Native Swift 6, 0% telemetry.",
    images: [
      {
        url: "/og-image.jpg",
        width: 1200,
        height: 630,
        type: "image/jpeg",
        alt: "SutraKey — Free 4K Video Downloader, Audio Extractor & Web to PDF for macOS by Aritro Saha (halcyon-past)",
      },
      {
        url: "/og-image.webp",
        width: 1200,
        height: 630,
        type: "image/webp",
        alt: "SutraKey — Free 4K Video Downloader, Audio Extractor & Web to PDF for macOS by Aritro Saha (halcyon-past)",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Free 4K Video Downloader, Audio Extractor & Web to PDF for Mac — SutraKey",
    description:
      "Free open-source macOS media downloader by Aritro Saha (halcyon-past). Hold Shift + Select any URL to download 4K MP4, 320kbps MP3, or clean vector PDFs straight to ~/Downloads.",
    creator: "@halcyon_past",
    images: ["/og-image.jpg"],
  },
  icons: {
    icon: [
      { url: "/favicon.ico", sizes: "any" },
      { url: "/favicon-16x16.png", type: "image/png", sizes: "16x16" },
      { url: "/favicon-32x32.png", type: "image/png", sizes: "32x32" },
      { url: "/favicon-48x48.png", type: "image/png", sizes: "48x48" },
      { url: "/icon-192x192.png", type: "image/png", sizes: "192x192" },
      { url: "/icon-512x512.png", type: "image/png", sizes: "512x512" },
    ],
    apple: [
      { url: "/apple-touch-icon.png", sizes: "180x180", type: "image/png" },
      { url: "/apple-touch-icon-precomposed.png", sizes: "180x180", type: "image/png" },
    ],
    other: [
      {
        rel: "apple-touch-icon-precomposed",
        url: "/apple-touch-icon-precomposed.png",
      },
    ],
  },
  manifest: "/manifest.webmanifest",
};

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Person",
      "@id": PERSON_ID,
      name: "Aritro Saha",
      alternateName: ["halcyon-past", "Megh", "Aritro Saha (halcyon-past)"],
      url: "https://www.aritro.cloud/",
      jobTitle: "Software Engineer 1",
      worksFor: {
        "@type": "Organization",
        name: "Bristol Myers Squibb",
        alternateName: "BMS",
        url: "https://www.bms.com/",
      },
      alumniOf: {
        "@type": "CollegeOrUniversity",
        name: "Vellore Institute of Technology, Chennai",
      },
      sameAs: [
        "https://www.wikidata.org/wiki/Q141715213",
        "https://www.wikidata.org/entity/Q141715213",
        "https://orcid.org/0009-0007-0861-3978",
        "https://github.com/halcyon-past",
        "https://linkedin.com/in/aritro-saha",
        "https://dev.to/halcyonpast",
        "https://byakugan-scan.aritro.cloud/",
        "https://siliconsync.aritro.cloud/",
      ],
    },
    {
      "@type": ["SoftwareApplication", "SoftwareSourceCode"],
      "@id": `${SITE_URL}/#software`,
      name: "SutraKey",
      alternateName: [
        "Sutra Key",
        "SutraKey macOS",
        "Sutra Key macOS",
        "SutraKey App",
        "Sutra Key (सूत्र)",
      ],
      operatingSystem: "macOS 14.0 Sonoma, macOS 15.0+ Sequoia (Apple Silicon & Intel Universal)",
      applicationCategory: "UtilitiesApplication, MultimediaApplication",
      applicationSubCategory: "4K Video Downloader, Audio Extractor, Subtitle Grabber, and Web to PDF Converter",
      softwareVersion: "1.0.6",
      license: "https://opensource.org/licenses/MIT",
      url: SITE_URL,
      downloadUrl: "https://github.com/halcyon-past/SutraKey/releases/latest/download/SutraKey.dmg",
      codeRepository: "https://github.com/halcyon-past/SutraKey",
      programmingLanguage: "Swift 6.0",
      installUrl: `${SITE_URL}/#installation`,
      releaseNotes: "https://github.com/halcyon-past/SutraKey/releases/tag/v1.0.6",
      image: [
        `${SITE_URL}/og-image.jpg`,
        `${SITE_URL}/icon-512x512.png`,
        `${SITE_URL}/logo.webp`,
      ],
      screenshot: `${SITE_URL}/og-image.jpg`,
      description:
        "Free open-source macOS media downloader and web to PDF converter engineered by Aritro Saha (halcyon-past). Hold Shift + Select any URL to summon an under-cursor radial menu that downloads 4K video, extracts 320kbps MP3 audio, saves subtitles, or converts web articles into clean ad-free vector PDFs to ~/Downloads.",
      featureList: [
        "Shift + Select radial wheel HUD under the cursor",
        "Bitwise modifier exclusivity guard preventing system shortcut collisions",
        "5 native action slots: 4K Video, Hi-Fi 320kbps MP3 Audio, Subtitles (.SRT), Full-Res Thumbnails, and Web to PDF",
        "Headless WebKit vector PDF generation with link preservation and ad-stripping",
        "100% on-device processing with zero telemetry and zero cloud proxies",
        "One-click Keychain browser cookie authorization (Brave, Chrome, Safari, Edge, Arc) for private feeds & stories",
        "Ephemeral menu bar indicator displaying real-time speed (MB/s) and ETA",
        "Strict filesystem confinement to ~/Downloads with directory traversal defenses",
      ],
      offers: {
        "@type": "Offer",
        price: "0",
        priceCurrency: "USD",
        availability: "https://schema.org/InStock",
      },
      author: {
        "@id": PERSON_ID,
      },
      creator: {
        "@id": PERSON_ID,
      },
      publisher: {
        "@id": PERSON_ID,
      },
      maintainer: {
        "@id": PERSON_ID,
      },
      subjectOf: [
        {
          "@type": "CreativeWork",
          name: "SutraKey LLM Summary (llms.txt)",
          url: `${SITE_URL}/llms.txt`,
          encodingFormat: "text/plain",
        },
        {
          "@type": "CreativeWork",
          name: "SutraKey Full Technical Knowledge Base (llms-full.txt)",
          url: `${SITE_URL}/llms-full.txt`,
          encodingFormat: "text/plain",
        },
        {
          "@type": "CreativeWork",
          name: "SutraKey AI Scraper & Training Policy (ai.txt)",
          url: `${SITE_URL}/ai.txt`,
          encodingFormat: "text/plain",
        },
      ],
      sameAs: [
        "https://github.com/halcyon-past/SutraKey",
        "https://github.com/halcyon-past/homebrew-tap",
      ],
    },
    {
      "@type": "WebSite",
      "@id": `${SITE_URL}/#website`,
      url: SITE_URL,
      name: "SutraKey — Free 4K Video Downloader, Audio Extractor & Web to PDF for macOS",
      alternateName: [
        "SutraKey by Aritro Saha",
        "Sutra Key by Aritro Saha (halcyon-past)",
        "SutraKey Official Website",
      ],
      description:
        "Official website and documentation for SutraKey — the open-source Shift + Select radial media and document downloader for macOS engineered by Aritro Saha (halcyon-past).",
      author: {
        "@id": PERSON_ID,
      },
      creator: {
        "@id": PERSON_ID,
      },
      publisher: {
        "@id": PERSON_ID,
      },
    },
    {
      "@type": "BreadcrumbList",
      "@id": `${SITE_URL}/#breadcrumb`,
      itemListElement: [
        {
          "@type": "ListItem",
          position: 1,
          name: "Home",
          item: SITE_URL,
        },
        {
          "@type": "ListItem",
          position: 2,
          name: "Support & Docs",
          item: `${SITE_URL}/support`,
        },
        {
          "@type": "ListItem",
          position: 3,
          name: "Privacy Policy",
          item: `${SITE_URL}/privacy`,
        },
        {
          "@type": "ListItem",
          position: 4,
          name: "Terms of Service",
          item: `${SITE_URL}/terms`,
        },
      ],
    },
    {
      "@type": "HowTo",
      "@id": `${SITE_URL}/#howto-download-video`,
      name: "How to Download 4K Video or Extract MP3 Audio on Mac using Shift + Select",
      description:
        "Step-by-step guide to download high-resolution video or extract audio using SutraKey by Aritro Saha.",
      step: [
        {
          "@type": "HowToStep",
          name: "Highlight Any Link",
          text: "Hold down ONLY the Shift key on your Mac keyboard and click-and-drag your mouse over any URL or link in Safari, Chrome, Slack, Notes, or Terminal.",
        },
        {
          "@type": "HowToStep",
          name: "Select Format from Radial HUD",
          text: "Release over the 'Video' slice for 4K/1080p MP4 or 'Audio' slice for 320kbps MP3 with embedded artwork on the under-cursor radial wheel.",
        },
        {
          "@type": "HowToStep",
          name: "Access File in ~/Downloads",
          text: "SutraKey processes the media via yt-dlp and ffmpeg in the background and saves the finished file straight to your macOS Downloads folder.",
        },
      ],
    },
    {
      "@type": "HowTo",
      "@id": `${SITE_URL}/#howto-web-to-pdf`,
      name: "How to Convert Any Web Article or Documentation into a Clean Vector PDF on Mac",
      description:
        "Step-by-step guide to generate ad-free vector PDFs from web links using SutraKey.",
      step: [
        {
          "@type": "HowToStep",
          name: "Highlight Article Link",
          text: "Hold Shift and select the link to any web page, news article, or documentation.",
        },
        {
          "@type": "HowToStep",
          name: "Select Clean PDF",
          text: "Choose the 'Clean PDF' slice on the radial menu. SutraKey loads the page in headless WebKit, strips ads and cookie popups, and stabilizes fonts.",
        },
        {
          "@type": "HowToStep",
          name: "View Clean Vector PDF",
          text: "A searchable, paginated vector PDF with clickable links is saved immediately to your ~/Downloads folder.",
        },
      ],
    },
    {
      "@type": "FAQPage",
      "@id": `${SITE_URL}/#faq`,
      mainEntity: [
        {
          "@type": "Question",
          name: "What is SutraKey and who created it?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "SutraKey (also known as Sutra Key) is a free, open-source macOS utility created and engineered by Aritro Saha (known online as halcyon-past). It connects text selection directly to high-speed media actions: holding Shift and highlighting any URL summons an under-cursor radial pie menu to download 4K video, extract 320kbps MP3 audio, save subtitles (.srt), or convert web articles to clean ad-free vector PDFs.",
          },
        },
        {
          "@type": "Question",
          name: "How do I download videos or extract MP3 audio on Mac without ads?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "With SutraKey running, simply hold the Shift key while selecting any video URL (YouTube, Twitter/X, TikTok, Reddit, Vimeo) in any macOS app, or press Command+Shift+S. Select 'Video' or 'Audio' on the radial menu, and SutraKey will download the media directly to ~/Downloads without ads, popups, or cloud tracking.",
          },
        },
        {
          "@type": "Question",
          name: "How do I convert a web page or article into a clean vector PDF on Mac?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Hold Shift and select any webpage link, then choose 'Clean PDF' on the radial wheel. SutraKey launches a headless Apple WebKit instance (WKWebView), strips ads and cookie consent banners, and prints a crisp, searchable, paginated vector PDF with clickable hyperlinks directly into ~/Downloads.",
          },
        },
        {
          "@type": "Question",
          name: "Can SutraKey download private Instagram Stories or posts?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Yes. SutraKey includes Keychain Browser Cookie Authentication. In Settings > Authentication, select the browser where you are logged into Instagram (Brave, Chrome, Safari, Edge, Arc) and click 'Authorize & Test Keychain Access'. When prompted by macOS, choose 'Always Allow'. SutraKey securely decrypts local session cookies in volatile RAM to extract private Stories and posts.",
          },
        },
        {
          "@type": "Question",
          name: "Why is a native Mac app better than web video downloaders or browser extensions?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Online downloaders are filled with popups, fake download buttons, malware risks, and 720p limits. Browser extensions consume background RAM in every tab and often steal browsing history. SutraKey runs 100% locally on your Mac with 0% idle CPU, zero telemetry, and zero ads, saving 4K 60fps MP4 and 320kbps MP3 files straight to ~/Downloads.",
          },
        },
        {
          "@type": "Question",
          name: "How is SutraKey different from running yt-dlp in the Terminal?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "SutraKey bundles and manages yt-dlp and ffmpeg natively, providing a zero-latency radial GUI. Instead of opening Terminal, changing directories, copy-pasting URLs, and typing complex flags, you simply hold Shift and highlight the URL. You get full 4K H.264/AAC quality, embedded album art, and progress indicators without typing a single command.",
          },
        },
        {
          "@type": "Question",
          name: "Does SutraKey collect or track any user data?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "No. SutraKey operates with strict 0% telemetry and zero analytics. Selected URLs are evaluated solely in temporary RAM to trigger the local download and are never logged to disk or sent to external servers. All network traffic is strictly between your Mac and the target media host.",
          },
        },
        {
          "@type": "Question",
          name: "Is SutraKey free and open-source?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Yes. SutraKey is 100% free and open-source under the MIT License. The complete Swift 6 source code is available on GitHub at https://github.com/halcyon-past/SutraKey.",
          },
        },
      ],
    },
  ],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark scroll-smooth">
      <head>
        {/* Direct Favicon and Touch Icon Links */}
        <link rel="icon" type="image/x-icon" href="/favicon.ico" />
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />

        {/* Author Verification & Social Profiles */}
        <link rel="author" href="https://www.aritro.cloud/" />
        <link rel="me" href="https://www.aritro.cloud/" />
        <link rel="me" href="https://www.wikidata.org/wiki/Q141715213" />
        <link rel="me" href="https://github.com/halcyon-past" />
        <link rel="me" href="https://dev.to/halcyonpast" />
        <link rel="me" href="https://linkedin.com/in/aritro-saha" />

        {/* AI & Agent Discovery Standards */}
        <link rel="ai-catalog" href="/.well-known/ai-catalog.json" />
        <link rel="alternate" type="text/plain" href="/ai.txt" title="AI Scraper Policy" />
        <link rel="alternate" type="text/plain" href="/llms.txt" title="LLM Context Summary" />
        <link rel="alternate" type="text/plain" href="/llms-full.txt" title="LLM Full Knowledge Base" />
        <link rel="alternate" type="text/markdown" href="/llms.txt" title="Markdown Context" />

        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body
        className={`${geistSans.variable} ${geistMono.variable} min-h-screen bg-[#0a0a0c] text-[#f5f5f7] antialiased font-sans selection:bg-pink-500/30 selection:text-pink-200`}
      >
        {children}
      </body>
    </html>
  );
}
