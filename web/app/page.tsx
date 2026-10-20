"use client";

import React from "react";
import { Navbar } from "./components/Navbar";
import { Hero } from "./components/Hero";
import { RadialSimulator } from "./components/RadialSimulator";
import { Highlights } from "./components/Highlights";
import { FormatShowcase } from "./components/FormatShowcase";
import { Installation } from "./components/Installation";
import { Footer } from "./components/Footer";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col bg-[#fbfbfd] text-[#1d1d1f] dark:bg-[#0a0a0c] dark:text-[#f5f5f7] transition-colors duration-300">
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
  );
}
