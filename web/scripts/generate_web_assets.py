#!/usr/bin/env python3
"""
Generate complete SEO, PWA, and social media image assets for SutraKey Web.
Includes:
- Favicons: .ico (16, 32, 48), .png (16x16, 32x32, 48x48)
- Apple Touch Icons: 180x180 .png
- PWA Icons: 192x192 (.png, .webp), 512x512 (.png, .webp)
- Component Logos: 128x128 (.png, .webp)
- High-res AppIcon: 1024x1024 (.webp)
- OpenGraph / Twitter Cards: 1200x630 (.jpg, .webp, banner-social.jpg)
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.dirname(SCRIPT_DIR)
PUBLIC_DIR = os.path.join(WEB_DIR, "public")
APP_DIR = os.path.join(WEB_DIR, "app")
SOURCE_ICON = os.path.join(PUBLIC_DIR, "AppIcon-1024.png")

def create_rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), size], radius=radius, fill=255)
    return mask

def generate_icons():
    print("🎨 Loading source icon:", SOURCE_ICON)
    base_img = Image.open(SOURCE_ICON).convert("RGBA")

    # 1. Favicon .ico (16, 32, 48)
    print("📦 Generating favicon.ico...")
    ico_sizes = [(16, 16), (32, 32), (48, 48)]
    base_img.save(os.path.join(PUBLIC_DIR, "favicon.ico"), format="ICO", sizes=ico_sizes)
    base_img.save(os.path.join(APP_DIR, "favicon.ico"), format="ICO", sizes=ico_sizes)

    # 2. PNG Favicons
    for size in [16, 32, 48]:
        resized = base_img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(os.path.join(PUBLIC_DIR, f"favicon-{size}x{size}.png"), "PNG")
        print(f"  ✓ favicon-{size}x{size}.png")

    # 3. Apple Touch Icons (180x180)
    apple_180 = base_img.resize((180, 180), Image.Resampling.LANCZOS)
    apple_180.save(os.path.join(PUBLIC_DIR, "apple-touch-icon.png"), "PNG")
    apple_180.save(os.path.join(PUBLIC_DIR, "apple-touch-icon-precomposed.png"), "PNG")
    print("  ✓ apple-touch-icon.png (180x180)")

    # 4. Standard PWA Icons (192x192 & 512x512 in PNG and WebP)
    for size in [192, 512]:
        resized = base_img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(os.path.join(PUBLIC_DIR, f"icon-{size}x{size}.png"), "PNG")
        resized.save(os.path.join(PUBLIC_DIR, f"icon-{size}x{size}.webp"), "WEBP", quality=90)
        print(f"  ✓ icon-{size}x{size}.png & .webp")

    # 5. UI Logo (128x128 in PNG and WebP for Navbar/Footer)
    logo_128 = base_img.resize((128, 128), Image.Resampling.LANCZOS)
    logo_128.save(os.path.join(PUBLIC_DIR, "logo.png"), "PNG")
    logo_128.save(os.path.join(PUBLIC_DIR, "logo.webp"), "WEBP", quality=92)
    print("  ✓ logo.png & logo.webp (128x128)")

    # 6. Master AppIcon WebP
    base_img.save(os.path.join(PUBLIC_DIR, "AppIcon.webp"), "WEBP", quality=92)
    print("  ✓ AppIcon.webp (1024x1024)")


def generate_social_card():
    import subprocess
    print("\n🖼️ Generating 1200x630 vector OpenGraph & Twitter Social Share Card via Sharp...")
    banner_script = os.path.join(SCRIPT_DIR, "generate-og-banner.mjs")
    res = subprocess.run(["node", banner_script], capture_output=True, text=True)
    if res.returncode != 0:
        print("❌ Error generating banner:", res.stderr)
    else:
        print(res.stdout)


if __name__ == "__main__":
    generate_icons()
    generate_social_card()
    print("\n🎉 All SEO, PWA, and Social assets generated successfully!")
