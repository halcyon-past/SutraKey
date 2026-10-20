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
  description: "Hold Shift + Select any URL to summon a zero-latency radial wheel that downloads video, audio, subtitles, or clean PDFs straight to ~/Downloads. Native Swift macOS utility. 100% Free & Open Source.",
  icons: {
    icon: "/MenuBarIcon-White@2x.png",
    apple: "/AppIcon-1024.png",
  },
  openGraph: {
    title: "SutraKey — macOS Radial Media & PDF Utility",
    description: "Hold Shift + Select any URL to summon a zero-latency radial wheel that downloads video, audio, subtitles, or clean PDFs straight to ~/Downloads.",
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
    description: "Hold Shift + Select any URL to summon a zero-latency radial wheel that downloads straight to ~/Downloads.",
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
        className={`${geistSans.variable} ${geistMono.variable} min-h-screen bg-[#090a0d] text-slate-100 antialiased font-sans selection:bg-[#ff6b3d]/30 selection:text-[#ff8359]`}
      >
        {children}
      </body>
    </html>
  );
}
