import type { Metadata } from "next";
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

export const metadata: Metadata = {
  metadataBase: new URL("https://sutrakey.aritro.cloud"),
  title: "SutraKey — Shift + Select Radial Media & Document Downloader for macOS",
  description:
    "Hold Shift + Select any URL to summon a zero-latency liquid radial wheel that downloads video, audio, subtitles, or clean PDFs straight to ~/Downloads. 100% Native, Free & Open Source.",
  icons: {
    icon: "/MenuBarIcon-Black@2x.png",
    apple: "/AppIcon-1024.png",
  },
  openGraph: {
    title: "SutraKey — macOS Radial Media & PDF Utility",
    description:
      "Hold Shift + Select any URL to summon a zero-latency liquid radial wheel. 100% Free & Open Source native macOS app.",
    url: "https://sutrakey.aritro.cloud",
    siteName: "SutraKey",
    images: [
      {
        url: "/AppIcon-1024.png",
        width: 1024,
        height: 1024,
        alt: "SutraKey App Icon",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "SutraKey — macOS Radial Media & PDF Utility",
    description:
      "Hold Shift + Select any URL to summon a zero-latency liquid radial wheel that downloads straight to ~/Downloads.",
    images: ["/AppIcon-1024.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark scroll-smooth">
      <body
        className={`${geistSans.variable} ${geistMono.variable} min-h-screen bg-[#0a0a0c] text-[#f5f5f7] antialiased font-sans selection:bg-pink-500/30 selection:text-pink-200`}
      >
        {children}
      </body>
    </html>
  );
}
