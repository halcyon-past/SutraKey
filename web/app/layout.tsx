import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
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
    default: "SutraKey — Shift + Select Radial Media & Document Downloader for macOS",
    template: "%s | SutraKey for macOS",
  },
  description:
    "Hold Shift + Select any URL to summon a zero-latency liquid radial wheel that downloads video (4K/1080p MP4), audio (320kbps MP3/M4A), subtitles (SRT/VTT), or clean vector PDFs straight to ~/Downloads. 100% Native Swift 6, Free & Open Source.",
  applicationName: "SutraKey",
  authors: [{ name: "Aritro Saha", url: "https://www.aritro.cloud/" }],
  creator: "Aritro Saha",
  publisher: "Aritro Saha",
  category: "Developer Tools & Productivity",
  keywords: [
    "SutraKey",
    "Aritro Saha",
    "halcyon-past",
    "Q141715213",
    "macOS media downloader",
    "macOS radial menu",
    "Shift select downloader Mac",
    "video downloader macOS",
    "audio extractor macOS",
    "web to pdf macOS",
    "yt-dlp macOS GUI",
    "native Swift 6 macOS utility",
    "Instagram stories downloader Mac",
    "zero telemetry Mac app",
    "free open source macOS software",
    "WebKit vector PDF Mac",
    "Apple Silicon universal utility",
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
    siteName: "SutraKey",
    title: "SutraKey — Shift + Select Radial Media & Document Downloader for macOS",
    description:
      "Hold Shift + Select any URL to summon a zero-latency liquid radial wheel. Downloads video, audio, subtitles, or clean PDFs straight to ~/Downloads. 100% Native, Free & Open Source.",
    images: [
      {
        url: "/AppIcon-1024.png",
        width: 1024,
        height: 1024,
        alt: "SutraKey App Icon",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "SutraKey — Shift + Select Radial Media & Document Downloader for macOS",
    description:
      "Hold Shift + Select any URL to summon a zero-latency liquid radial wheel that downloads straight to ~/Downloads. 100% Native Swift 6.",
    creator: "@halcyon_past",
    images: ["/AppIcon-1024.png"],
  },
  icons: {
    icon: [
      { url: "/MenuBarIcon-Black@2x.png", type: "image/png" },
    ],
    apple: [
      { url: "/AppIcon-1024.png", type: "image/png" },
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
      alternateName: ["Megh", "halcyon-past"],
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
      alternateName: "SutraKey macOS",
      operatingSystem: "macOS 14.0 or later",
      applicationCategory: "UtilitiesApplication",
      applicationSubCategory: "Media Downloader, Audio Extractor, and Web PDF Converter",
      softwareVersion: "1.0.0",
      license: "https://opensource.org/licenses/MIT",
      url: SITE_URL,
      downloadUrl: "https://github.com/halcyon-past/SutraKey/releases/latest",
      codeRepository: "https://github.com/halcyon-past/SutraKey",
      programmingLanguage: "Swift 6.0",
      installUrl: `${SITE_URL}/#installation`,
      releaseNotes: "https://github.com/halcyon-past/SutraKey/blob/main/docs/CHANGELOG.md",
      image: `${SITE_URL}/AppIcon-1024.png`,
      description:
        "Hold Shift + Select any URL to summon a zero-latency liquid radial wheel that downloads video (4K/1080p MP4), audio (320kbps MP3/M4A), subtitles (SRT/VTT), or clean vector PDFs directly to ~/Downloads. 100% Native Swift 6, Free & Open Source.",
      featureList: [
        "Exclusive Shift + Select radial wheel HUD under the cursor",
        "Bitwise modifier exclusivity guard preventing system shortcut collisions",
        "4 native action slots: 4K Video, Hi-Fi Audio, Subtitles, and Web to PDF",
        "Headless WebKit vector PDF generation with link preservation",
        "100% on-device processing with zero telemetry and zero cloud proxies",
        "One-click Keychain browser cookie authorization (Brave, Chrome, Safari) for private feeds & stories",
        "Ephemeral menu bar indicator displaying real-time speed (MB/s) and ETA",
        "Strict filesystem confinement to ~/Downloads with traversal defenses",
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
      ],
    },
    {
      "@type": "WebSite",
      "@id": `${SITE_URL}/#website`,
      url: SITE_URL,
      name: "SutraKey",
      description:
        "Official website and documentation for SutraKey — the open-source Shift + Select radial media and document downloader for macOS by Aritro Saha.",
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
      "@type": "FAQPage",
      "@id": `${SITE_URL}/#faq`,
      mainEntity: [
        {
          "@type": "Question",
          name: "How do I summon the SutraKey radial menu?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Hold down the Shift key and click-and-drag your mouse to select any URL or text containing a link across any macOS application. The radial menu will instantly appear centered under your cursor.",
          },
        },
        {
          "@type": "Question",
          name: "Does SutraKey collect my browsing history or clipboard data?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "No. SutraKey operates with 0% telemetry and 100% on-device processing. Selected URLs are evaluated strictly in volatile RAM to display download options and are never sent to external servers or logged to disk.",
          },
        },
        {
          "@type": "Question",
          name: "How do I download Instagram Stories or private media?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "Open SutraKey Settings > Authentication, select your active browser (Brave, Chrome, Safari, Edge, or Arc), and click 'Authorize & Test Keychain Access'. When macOS prompts for Keychain access, select 'Always Allow' to securely decrypt local session cookies.",
          },
        },
        {
          "@type": "Question",
          name: "How does the Web to PDF option work?",
          acceptedAnswer: {
            "@type": "Answer",
            text: "SutraKey uses Apple's native WebKit framework (WKWebView) in a headless vector pipeline to render the webpage, wait for DOM stabilization, and print a clean, paginated vector PDF with active hyperlinks straight to your ~/Downloads folder.",
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
        <link rel="author" href="https://www.aritro.cloud/" />
        <link rel="me" href="https://www.aritro.cloud/" />
        <link rel="me" href="https://www.wikidata.org/wiki/Q141715213" />
        <link rel="me" href="https://github.com/halcyon-past" />
        <link rel="me" href="https://dev.to/halcyonpast" />
        <link rel="me" href="https://linkedin.com/in/aritro-saha" />
        <link rel="alternate" type="text/plain" href="/ai.txt" title="AI Scraper Policy" />
        <link rel="alternate" type="text/plain" href="/llms.txt" title="LLM Context Summary" />
        <link rel="alternate" type="text/plain" href="/llms-full.txt" title="LLM Full Knowledge Base (llms-full.txt)" />
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
