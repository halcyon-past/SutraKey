#!/usr/bin/env python3
"""
Orchestrates the viral video recording of SutraKey:
1. Renders the clean presentation video directly from SwiftUI via AVAssetWriter (zero screen recording / no window interference).
2. Mixes in macOS native sound effects (Pop, Tink, Glass) at the exact timestamps.
3. Produces both Master MP4 (1080p 60fps / 1440p) and optimized companion GIF.
"""

import os
import subprocess
import sys
import time
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
DEMO_DIR = ROOT_DIR / "build" / "demo"
DEMO_APP = DEMO_DIR / "DemoApp"
RAW_VIDEO = DEMO_DIR / "raw_capture.mp4"
PROCESSED_VIDEO = DEMO_DIR / "sutrakey_viral_demo.mp4"
GIF_OUTPUT = DEMO_DIR / "sutrakey_viral_demo.gif"

DEMO_DIR.mkdir(parents=True, exist_ok=True)


def main():
    if not DEMO_APP.exists():
        print(f"❌ Error: {DEMO_APP} not found. Please compile it first.")
        sys.exit(1)

    RAW_VIDEO.unlink(missing_ok=True)

    print("🚀 Rendering demo showcase directly via Swift AVAssetWriter & SwiftUI ImageRenderer...")
    start_time = time.time()
    res = subprocess.run([str(DEMO_APP), "--render-offline", str(RAW_VIDEO)])
    if res.returncode != 0 or not RAW_VIDEO.exists() or RAW_VIDEO.stat().st_size < 10000:
        print(f"❌ Raw video export failed at {RAW_VIDEO}")
        sys.exit(1)

    elapsed = time.time() - start_time
    print(f"✅ Raw Retina video rendered in {elapsed:.1f}s ({RAW_VIDEO.stat().st_size / (1024*1024):.2f} MB)")

    # Post-Production Audio Mixing via ffmpeg
    print("🎨 Post-producing viral demo video with sound effects...")

    pop_sound = "/System/Library/Sounds/Pop.aiff"
    tink_sound = "/System/Library/Sounds/Tink.aiff"
    glass_sound = "/System/Library/Sounds/Glass.aiff"

    # Audio mixing filter graph:
    # Pop at 4.2s (radial bloom), Tink at 7.6s (click), Glass at 13.2s (download complete)
    af_str = (
        "[1:a]adelay=4200|4200[a1];"
        "[2:a]adelay=7600|7600[a2];"
        "[3:a]adelay=13200|13200[a3];"
        "[a1][a2][a3]amix=inputs=3:duration=first:dropout_transition=2[aout]"
    )

    ffmpeg_cmd = [
        "/opt/homebrew/bin/ffmpeg",
        "-y",
        "-i", str(RAW_VIDEO),
        "-i", pop_sound,
        "-i", tink_sound,
        "-i", glass_sound,
        "-filter_complex", f"[0:v]scale=1920:1080:flags=lanczos[vout];{af_str}",
        "-map", "[vout]",
        "-map", "[aout]",
        "-c:v", "libx264",
        "-preset", "slow",
        "-crf", "17",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "192k",
        "-movflags", "+faststart",
        str(PROCESSED_VIDEO),
    ]

    print("⚡ Running ffmpeg post-production audio mixing & 1080p encoding...")
    subprocess.run(ffmpeg_cmd, check=True)
    print(f"🎉 Master 1080p MP4 generated: {PROCESSED_VIDEO}")

    # Generate companion animated GIF for GitHub / Reddit
    print("🎞️ Generating optimized companion GIF...")
    palette_file = DEMO_DIR / "palette.png"
    subprocess.run([
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-ss", "0", "-t", "27",
        "-i", str(PROCESSED_VIDEO),
        "-vf", "fps=16,scale=800:-1:flags=lanczos,palettegen=max_colors=128",
        str(palette_file)
    ], check=True)

    subprocess.run([
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-ss", "0", "-t", "27",
        "-i", str(PROCESSED_VIDEO),
        "-i", str(palette_file),
        "-lavfi", "fps=16,scale=800:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3",
        str(GIF_OUTPUT)
    ], check=True)

    palette_file.unlink(missing_ok=True)
    print(f"🎉 Animated GIF generated: {GIF_OUTPUT}")
    print("\n=======================================================")
    print("🚀 VIRAL DEMO ASSETS COMPLETED SUCCESSFULLY!")
    print(f"   🎬 1080p MP4 Video: {PROCESSED_VIDEO} ({PROCESSED_VIDEO.stat().st_size / (1024*1024):.2f} MB)")
    print(f"   🎞️ High-res GIF:    {GIF_OUTPUT} ({GIF_OUTPUT.stat().st_size / (1024*1024):.2f} MB)")
    print("=======================================================")


if __name__ == "__main__":
    main()
