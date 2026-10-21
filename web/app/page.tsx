"use client";

import React from "react";
import { Navbar } from "./components/Navbar";
import { Hero } from "./components/Hero";
import { RadialSimulator } from "./components/RadialSimulator";
import { Highlights } from "./components/Highlights";
import { FormatShowcase } from "./components/FormatShowcase";
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
            <Installation />
          </main>
          <Footer />
        </div>
      </div>
    </SmoothScrollProvider>
  );
}
