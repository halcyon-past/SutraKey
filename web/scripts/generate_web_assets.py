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
    print("\n🖼️ Generating 1200x630 OpenGraph & Twitter Social Share Card...")
    width, height = 1200, 630

    # 1. Base dark obsidian canvas
    card = Image.new("RGBA", (width, height), (11, 11, 15, 255))

    # 2. Add subtle ambient glow gradients (Soft ambient glow matching SutraKey's iPad-inspired glass UI)
    glow_layer = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)

    # Top-right emerald/teal ambient glow
    glow_draw.ellipse([800, -100, 1300, 400], fill=(16, 185, 129, 35))
    glow_draw.ellipse([900, -50, 1250, 300], fill=(20, 184, 166, 40))

    # Bottom-left pink/iris ambient glow
    glow_draw.ellipse([-100, 350, 500, 750], fill=(236, 72, 153, 30))
    glow_draw.ellipse([-50, 400, 400, 700], fill=(168, 85, 247, 30))

    # Blur glow layer
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=80))
    card = Image.alpha_composite(card, glow_layer)

    # 3. Draw subtle grid or border highlight
    draw = ImageDraw.Draw(card)
    draw.rounded_rectangle([(16, 16), (width - 16, height - 16)], radius=24, outline=(255, 255, 255, 18), width=1)

    # 4. Prepare App Icon (220x220) with squircle mask and soft drop shadow
    icon_size = 220
    icon_src = Image.open(SOURCE_ICON).convert("RGBA").resize((icon_size, icon_size), Image.Resampling.LANCZOS)
    
    # Apple squircle mask (radius ~ 48px)
    mask = create_rounded_mask((icon_size, icon_size), radius=48)
    
    # Shadow for app icon
    icon_x, icon_y = 100, 140
    shadow = Image.new("RGBA", (icon_size + 40, icon_size + 40), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle([(20, 20), (icon_size + 20, icon_size + 20)], radius=48, fill=(0, 0, 0, 140))
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=15))
    card.paste(shadow, (icon_x - 20, icon_y - 10), shadow)

    # Composite icon with mask
    card.paste(icon_src, (icon_x, icon_y), mask)

    # Icon subtle border outline
    draw.rounded_rectangle([(icon_x, icon_y), (icon_x + icon_size, icon_y + icon_size)], radius=48, outline=(255, 255, 255, 50), width=2)

    # 5. Typography
    sf_font_bold = "/System/Library/Fonts/SFNS.ttf"
    sf_font_mono = "/System/Library/Fonts/SFNSMono.ttf"
    sf_font_rounded = "/System/Library/Fonts/SFNSRounded.ttf"

    def get_font(path, size):
        try:
            return ImageFont.truetype(path, size)
        except Exception:
            return ImageFont.load_default()

    font_title = get_font(sf_font_bold, 76)
    font_badge = get_font(sf_font_bold, 22)
    font_tagline = get_font(sf_font_rounded, 38)
    font_desc = get_font(sf_font_bold, 24)
    font_pill = get_font(sf_font_mono, 18)
    font_footer = get_font(sf_font_bold, 20)

    # Content origin X
    content_x = 360

    # Title: SutraKey (सूत्र)
    title_text = "SutraKey"
    draw.text((content_x, 145), title_text, font=font_title, fill=(255, 255, 255, 255))

    # Version / macOS Badge next to title
    badge_x = content_x + 340
    badge_y = 165
    draw.rounded_rectangle([(badge_x, badge_y), (badge_x + 140, badge_y + 42)], radius=21, fill=(255, 255, 255, 25), outline=(255, 255, 255, 45), width=1)
    draw.text((badge_x + 22, badge_y + 8), "macOS 15+", font=font_badge, fill=(220, 220, 230, 255))

    # Tagline
    tagline_text = "Hold Shift. Set media free."
    draw.text((content_x, 245), tagline_text, font=font_tagline, fill=(167, 243, 208, 255)) # mint emerald

    # Subtitle Description
    desc_line1 = "Instant radial media & document downloader for macOS."
    desc_line2 = "4K Video, Hi-Fi Audio, Subtitles & Vector PDF straight to ~/Downloads."
    draw.text((content_x, 305), desc_line1, font=font_desc, fill=(212, 212, 216, 255))
    draw.text((content_x, 342), desc_line2, font=font_desc, fill=(161, 161, 170, 255))

    # 6. Feature Pills Row
    pills = [
        ("⚡️ Zero Latency", (16, 185, 129, 35), (52, 211, 153)),
        ("⌘⇧S or Shift+Select", (244, 114, 182, 35), (244, 114, 182)),
        ("🔒 100% On-Device", (129, 140, 248, 35), (165, 180, 252)),
        ("📄 Vector PDF", (251, 191, 36, 35), (252, 211, 77)),
        ("🆓 Free & Open Source", (255, 255, 255, 20), (228, 228, 231)),
    ]

    pill_x = 100
    pill_y = 440
    for label, bg_color, text_color in pills:
        bbox = font_pill.getbbox(label)
        text_w = bbox[2] - bbox[0]
        pill_w = text_w + 32
        pill_h = 44
        draw.rounded_rectangle([(pill_x, pill_y), (pill_x + pill_w, pill_y + pill_h)], radius=22, fill=bg_color, outline=(255, 255, 255, 30), width=1)
        draw.text((pill_x + 16, pill_y + 11), label, font=font_pill, fill=text_color)
        pill_x += pill_w + 14

    # 7. Card Footer Line
    draw.line([(100, 525), (width - 100, 525)], fill=(255, 255, 255, 20), width=1)
    
    # Left footer: Domain
    draw.text((100, 550), "https://sutrakey.aritro.cloud", font=font_footer, fill=(255, 255, 255, 220))

    # Right footer: Author
    author_text = "Crafted with Swift 6 by Aritro Saha (halcyon-past)"
    author_bbox = font_footer.getbbox(author_text)
    author_w = author_bbox[2] - author_bbox[0]
    draw.text((width - 100 - author_w, 550), author_text, font=font_footer, fill=(161, 161, 170, 220))

    # Convert to RGB for JPEG
    card_rgb = card.convert("RGB")
    
    # Save og-image.jpg
    og_jpg = os.path.join(PUBLIC_DIR, "og-image.jpg")
    card_rgb.save(og_jpg, "JPEG", quality=92, optimize=True)
    print("  ✓ og-image.jpg (1200x630, ~JPEG)")

    # Save og-image.webp
    og_webp = os.path.join(PUBLIC_DIR, "og-image.webp")
    card_rgb.save(og_webp, "WEBP", quality=92)
    print("  ✓ og-image.webp (1200x630, ~WebP)")

    # Save banner-social.jpg
    banner_jpg = os.path.join(PUBLIC_DIR, "banner-social.jpg")
    card_rgb.save(banner_jpg, "JPEG", quality=92, optimize=True)
    print("  ✓ banner-social.jpg (1200x630)")


if __name__ == "__main__":
    generate_icons()
    generate_social_card()
    print("\n🎉 All SEO, PWA, and Social assets generated successfully!")
