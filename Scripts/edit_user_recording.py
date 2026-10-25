#!/usr/bin/env python3
"""
Professional Master Video Producer for SutraKey:
1. Ingests the authentic screen recording (/Users/aritrosaha/Movies/VN/1792843815171455.mp4).
2. Performs precision speed-ramping on the background connecting delay (2.25x).
3. Renders full-bleed native 16:10 Retina screen (2560x1664) with ZERO sidebars or blur.
4. Floats a sleek Apple-style frosted glass badge for Instagram (Private Accounts via Keychain) without disrupting the UI.
5. Crossfades into an ultra-clean 2-second minimalist end tag with install instructions.
6. Layers tactile native macOS UI sound effects (Pop, Tink, Glass).
7. Exports both master 2.5K MP4 and companion GIF.
"""

import subprocess
import sys
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
DEMO_DIR = ROOT_DIR / "build" / "demo"
DEMO_DIR.mkdir(parents=True, exist_ok=True)

USER_VIDEO = "/Users/aritrosaha/Movies/VN/1792843815171455.mp4"
PRO_BADGE = "/tmp/pro_badge.png"
PRO_ENDTAG = "/tmp/pro_endtag.png"

OUT_MP4 = DEMO_DIR / "sutrakey_viral_demo.mp4"
OUT_GIF = DEMO_DIR / "sutrakey_viral_demo.gif"

POP = "/System/Library/Sounds/Pop.aiff"
TINK = "/System/Library/Sounds/Tink.aiff"
GLASS = "/System/Library/Sounds/Glass.aiff"


def main():
    if not Path(USER_VIDEO).exists():
        print(f"❌ Error: {USER_VIDEO} not found!")
        sys.exit(1)

    print("🚀 1. Generating 2.5s clean minimalist end tag clip...")
    subprocess.run([
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-loop", "1", "-t", "2.5",
        "-i", PRO_ENDTAG,
        "-c:v", "libx264", "-pix_fmt", "yuv420p", "-r", "24",
        "/tmp/clip_endtag.mp4"
    ], check=True)

    print("🚀 2. Processing full-bleed screen recording with speed ramp and floating badge...")
    screen_cmd = [
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-i", USER_VIDEO,
        "-loop", "1",
        "-i", PRO_BADGE,
        "-filter_complex", (
            # Precision speed ramp
            "[0:v]trim=start=0:end=9,setpts=PTS-STARTPTS[v1];"
            "[0:v]trim=start=9:end=13.5,setpts=0.444*(PTS-STARTPTS)[v2];"
            "[0:v]trim=start=13.5:end=18.0,setpts=PTS-STARTPTS[v3];"
            "[v1][v2][v3]concat=n=3:v=1:a=0[vraw];"
            # Full-bleed scale to 2560x1664 (16:10 Retina)
            "[vraw]scale=2560:1664:flags=lanczos[vscreen];"
            # Floating badge at bottom-center with smooth fade
            "[1:v]format=rgba,fade=t=in:st=11.5:d=0.3:alpha=1,fade=t=out:st=14.8:d=0.3:alpha=1[vbadge];"
            "[vscreen][vbadge]overlay=(W-w)/2:H-h-60:enable='between(t,11.5,15.2)'[vout]"
        ),
        "-map", "[vout]",
        "-c:v", "libx264", "-preset", "fast", "-crf", "17",
        "-t", "15.5",
        "/tmp/clip_screen_pro.mp4"
    ]
    subprocess.run(screen_cmd, check=True)

    print("🚀 3. Assembling Master Video with crossfade and tactile audio...")
    assemble_cmd = [
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-i", "/tmp/clip_screen_pro.mp4", # [0:v] 15.5s
        "-i", "/tmp/clip_endtag.mp4",     # [1:v] 2.5s
        "-i", POP,                        # [2:a]
        "-i", TINK,                       # [3:a]
        "-i", GLASS,                      # [4:a]
        "-filter_complex", (
            # Crossfade into end tag at 15.15s (duration 0.35s)
            "[0:v][1:v]xfade=transition=fade:duration=0.35:offset=15.15[vfade];"
            # Fade out to black at the end
            "[vfade]fade=t=out:st=17.0:d=0.4[vout];"
            
            # Tactile audio cues
            # 1. Pop on radial bloom at 3.3s
            "[2:a]adelay=3300|3300,volume=1.5[a_pop1];"
            # 2. Click on MP4 at 4.7s
            "[3:a]adelay=4700|4700,volume=1.8[a_click];"
            # 3. Pop on menu bar at 9.2s
            "[2:a]adelay=9200|9200,volume=1.3[a_pop2];"
            # 4. Apple Glass chime on Saved to Downloads at 13.8s
            "[4:a]adelay=13800|13800,volume=2.0[a_chime];"
            # 5. Subtle tick on end tag at 15.2s
            "[3:a]adelay=15200|15200,volume=1.0[a_tag];"
            
            # Mix audio tracks
            "[a_pop1][a_click][a_pop2][a_chime][a_tag]amix=inputs=5:duration=first:dropout_transition=2,afade=t=out:st=17.0:d=0.5[aout]"
        ),
        "-map", "[vout]",
        "-map", "[aout]",
        "-c:v", "libx264",
        "-preset", "slow",
        "-crf", "16",
        "-pix_fmt", "yuv420p",
        "-c:a", "aac",
        "-b:a", "192k",
        "-movflags", "+faststart",
        "-t", "17.4",
        str(OUT_MP4)
    ]
    subprocess.run(assemble_cmd, check=True)
    print(f"🎉 Master Video generated: {OUT_MP4}")

    print("🚀 4. Generating companion animated GIF...")
    palette_path = "/tmp/pro_palette.png"
    subprocess.run([
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-ss", "0", "-t", "17.4",
        "-i", str(OUT_MP4),
        "-vf", "fps=16,scale=800:-1:flags=lanczos,palettegen=max_colors=128",
        palette_path
    ], check=True)

    subprocess.run([
        "/opt/homebrew/bin/ffmpeg", "-y",
        "-ss", "0", "-t", "17.4",
        "-i", str(OUT_MP4),
        "-i", palette_path,
        "-lavfi", "fps=16,scale=800:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=3",
        str(OUT_GIF)
    ], check=True)

    print(f"🎉 Master GIF generated: {OUT_GIF}")
    print("\n=======================================================")
    print("🚀 MASTER PROFESSIONAL EDIT COMPLETE!")
    print(f"   🎬 Master 2.5K Retina MP4: {OUT_MP4} ({OUT_MP4.stat().st_size / (1024*1024):.2f} MB)")
    print(f"   🎞️ High-res GIF:           {OUT_GIF} ({OUT_GIF.stat().st_size / (1024*1024):.2f} MB)")
    print("=======================================================")


if __name__ == "__main__":
    main()
