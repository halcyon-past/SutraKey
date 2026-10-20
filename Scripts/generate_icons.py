#!/usr/bin/env python3
"""
SutraKey Icon Factory & Background Removal Pipeline
Generates:
  1. AppIcon (1024x1024 master + macOS iconset sizes) - Tactile minimalist dark keycap + Sutra thread
  2. MenuBarIcon-Black.png (18x18 @1x, 36x36 @2x) - Pure black minimalist glyph on transparent canvas
  3. MenuBarIcon-White.png (18x18 @1x, 36x36 @2x) - Pure white minimalist glyph on transparent canvas
  4. Runs automated background removal (rembg + alpha boundary matte verification).
  5. Places valid Contents.json and icons into Assets.xcassets and Assets_Generated.
"""

import io
import json
import math
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

try:
    from rembg import remove as rembg_remove
    HAS_REMBG = True
except ImportError:
    HAS_REMBG = False


def remove_background_strict(img: Image.Image, mode: str = "app_icon", target_rgb=(0, 0, 0)) -> Image.Image:
    """
    Removes background from rendered icons using rembg (if installed) combined with
    exact luminance/alpha matting so zero background artifacts or fringes remain.
    """
    img = img.convert("RGBA")

    if mode == "menubar":
        # Convert rendered luminance mask on solid background into pure transparent icon
        arr = np.array(img, dtype=np.float32)
        # Background is pure dark canvas; extract foreground intensity from red channel
        luminance = arr[:, :, 0]  # Intensity (0..255)
        out = np.zeros_like(arr, dtype=np.uint8)
        out[:, :, 0] = target_rgb[0]
        out[:, :, 1] = target_rgb[1]
        out[:, :, 2] = target_rgb[2]
        out[:, :, 3] = np.clip(luminance, 0, 255).astype(np.uint8)
        cleaned = Image.fromarray(out, mode="RGBA")
    else:
        # For App Icon: first apply rembg if available, then enforce exact squircle alpha mask
        if HAS_REMBG:
            buf = io.BytesIO()
            img.save(buf, format="PNG")
            stripped_bytes = rembg_remove(buf.getvalue())
            rembg_img = Image.open(io.BytesIO(stripped_bytes)).convert("RGBA")
            orig_alpha = np.array(img)[:, :, 3]
            rembg_alpha = np.array(rembg_img)[:, :, 3]
            combined_alpha = np.maximum(orig_alpha, rembg_alpha)
            arr = np.array(img)
            arr[:, :, 3] = np.where(orig_alpha > 0, combined_alpha, 0).astype(np.uint8)
            cleaned = Image.fromarray(arr, mode="RGBA")
        else:
            arr = np.array(img)
            # Strip any low-alpha background noise (< 4/255)
            arr[:, :, 3] = np.where(arr[:, :, 3] < 4, 0, arr[:, :, 3])
            cleaned = Image.fromarray(arr, mode="RGBA")

    # Verification: Assert all 4 corners are 100% transparent
    w, h = cleaned.size
    for cx, cy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        assert cleaned.getpixel((cx, cy))[3] == 0, f"Corner ({cx},{cy}) is not transparent! Alpha: {cleaned.getpixel((cx, cy))[3]}"

    return cleaned


def draw_superellipse_mask(size: int, margin: int, power: float = 4.5) -> Image.Image:
    """Generates a continuous-curvature Apple-style squircle mask."""
    y, x = np.ogrid[:size, :size]
    center = (size - 1) / 2.0
    radius = center - margin
    norm_x = np.abs((x - center) / radius) ** power
    norm_y = np.abs((y - center) / radius) ** power
    dist = (norm_x + norm_y) ** (1.0 / power)
    # Smooth 1.5px antialiasing at the boundary
    alpha = np.clip((1.0 - dist) * (radius / 1.5), 0.0, 1.0) * 255.0
    return Image.fromarray(alpha.astype(np.uint8), mode="L")


def generate_app_icon(size: int = 1024) -> Image.Image:
    """
    Renders the SutraKey App Icon with physical hardware minimalism:
    - Matte anodized graphite keycap with recessed concave dish
    - A single warm-ivory/amber silk thread ("Sutra") entering from bottom-left,
      passing through a central Shift-chevron aperture, and fanning into 3 clean rays.
    """
    ss = size * 2  # 2x supersampling for razor-sharp vector quality
    canvas = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))

    # 1. Outer Apple Squircle Base (Anodized Obsidian #141416 to #1E1F24)
    margin = int(ss * 0.088)
    outer_mask = draw_superellipse_mask(ss, margin, power=4.6)

    y, x = np.mgrid[:ss, :ss]
    grad = np.clip((y - margin) / (ss - 2 * margin), 0, 1)
    base_arr = np.zeros((ss, ss, 4), dtype=np.uint8)
    base_arr[:, :, 0] = (28 - grad * 12).astype(np.uint8)
    base_arr[:, :, 1] = (29 - grad * 12).astype(np.uint8)
    base_arr[:, :, 2] = (34 - grad * 12).astype(np.uint8)
    base_arr[:, :, 3] = np.array(outer_mask)
    canvas = Image.alpha_composite(canvas, Image.fromarray(base_arr))

    # 2. Inner Tactile Keycap Dish (Recessed concave well with top specular rim)
    dish_margin = int(ss * 0.175)
    dish_mask = draw_superellipse_mask(ss, dish_margin, power=4.3)
    cx, cy = ss / 2.0, ss / 2.0
    radial = np.sqrt((x - cx) ** 2 + (y - cy) ** 2) / (ss * 0.35)
    dish_arr = np.zeros((ss, ss, 4), dtype=np.uint8)
    dish_arr[:, :, 0] = np.clip(18 + radial * 14, 14, 38).astype(np.uint8)
    dish_arr[:, :, 1] = np.clip(19 + radial * 14, 15, 40).astype(np.uint8)
    dish_arr[:, :, 2] = np.clip(23 + radial * 16, 18, 46).astype(np.uint8)
    dish_arr[:, :, 3] = np.array(dish_mask)
    canvas = Image.alpha_composite(canvas, Image.fromarray(dish_arr))

    # 3. Draw Sutra Thread + Shift Aperture Geometry
    art = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
    draw = ImageDraw.Draw(art)

    # Subtle ambient glow behind the central node
    glow = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    r_glow = int(ss * 0.16)
    gdraw.ellipse((cx - r_glow, cy - r_glow, cx + r_glow, cy + r_glow), fill=(255, 122, 69, 48))
    glow = glow.filter(ImageFilter.GaussianBlur(radius=ss * 0.045))
    canvas = Image.alpha_composite(canvas, glow)

    # Outgoing 3 action threads (top-right fan representing multi-action radial menu)
    stroke_sub = int(ss * 0.022)
    targets = [
        (ss * 0.72, ss * 0.28),  # Top-right ray
        (ss * 0.76, ss * 0.46),  # Mid-right ray
        (ss * 0.54, ss * 0.24),  # Upper ray
    ]
    for tx, ty in targets:
        draw.line([(cx, cy), (tx, ty)], fill=(235, 238, 245, 230), width=stroke_sub, joint="curve")
        dot_r = int(ss * 0.018)
        draw.ellipse((tx - dot_r, ty - dot_r, tx + dot_r, ty + dot_r), fill=(255, 255, 255, 255))

    # Incoming main Sutra thread (Warm Vermilion/Amber #FF6B3D) from bottom-left
    stroke_main = int(ss * 0.030)
    start_pt = (ss * 0.27, ss * 0.73)
    draw.line([start_pt, (cx, cy)], fill=(255, 107, 61, 255), width=stroke_main)
    s_r = stroke_main // 2
    draw.ellipse((start_pt[0] - s_r, start_pt[1] - s_r, start_pt[0] + s_r, start_pt[1] + s_r), fill=(255, 107, 61, 255))

    # Central Shift-Key Chevron Ring (Precision geometric node)
    ring_r = int(ss * 0.075)
    ring_w = int(ss * 0.026)
    draw.ellipse(
        (cx - ring_r, cy - ring_r, cx + ring_r, cy + ring_r),
        fill=(22, 23, 28, 255),
        outline=(255, 255, 255, 255),
        width=ring_w,
    )
    inner_dot = int(ss * 0.022)
    draw.ellipse((cx - inner_dot, cy - inner_dot, cx + inner_dot, cy + inner_dot), fill=(255, 107, 61, 255))

    canvas = Image.alpha_composite(canvas, art)
    final_icon = canvas.resize((size, size), Image.Resampling.LANCZOS)
    return remove_background_strict(final_icon, mode="app_icon")


def generate_menubar_icon(size: int = 36, color_rgb=(0, 0, 0)) -> Image.Image:
    """
    Renders a crisp monochrome SutraKey glyph on a solid black mask canvas,
    then strips the background to pure transparency with exact target RGB color.
    """
    ss = size * 4  # 4x supersampling for pixel-perfect 18pt/36pt menu bar rendering
    mask_canvas = Image.new("RGB", (ss, ss), (0, 0, 0))
    draw = ImageDraw.Draw(mask_canvas)

    cx, cy = ss * 0.46, ss * 0.54
    stroke = max(int(ss * 0.085), 2)

    # Incoming Sutra thread (bottom-left to center)
    p1 = (ss * 0.16, ss * 0.84)
    draw.line([p1, (cx, cy)], fill=(255, 255, 255), width=stroke)

    # 3 Radial output spokes
    for tx, ty in [(ss * 0.84, ss * 0.16), (ss * 0.86, ss * 0.48), (ss * 0.52, ss * 0.14)]:
        draw.line([(cx, cy), (tx, ty)], fill=(255, 255, 255), width=int(stroke * 0.85))
        r_tip = int(stroke * 0.65)
        draw.ellipse((tx - r_tip, ty - r_tip, tx + r_tip, ty + r_tip), fill=(255, 255, 255))

    # Central Shift Node Ring
    r_node = int(ss * 0.16)
    draw.ellipse(
        (cx - r_node, cy - r_node, cx + r_node, cy + r_node),
        fill=(0, 0, 0),
        outline=(255, 255, 255),
        width=stroke,
    )

    downsampled = mask_canvas.resize((size, size), Image.Resampling.LANCZOS)
    return remove_background_strict(downsampled, mode="menubar", target_rgb=color_rgb)


def write_asset_catalogs(out_dir: Path, assets_dir: Path):
    """Writes Apple asset catalog JSON files and icons."""
    appicon_dir = assets_dir / "AppIcon.appiconset"
    menubar_dir = assets_dir / "MenuBarIcon.imageset"
    appicon_dir.mkdir(parents=True, exist_ok=True)
    menubar_dir.mkdir(parents=True, exist_ok=True)

    # 1. Master App Icon
    app_icon = generate_app_icon(1024)
    app_icon.save(out_dir / "AppIcon-1024.png")
    app_icon.save(appicon_dir / "icon_512x512@2x.png")

    # Generate standard macOS icon sizes
    sizes = [
        ("16x16", 16, 1),
        ("16x16", 32, 2),
        ("32x32", 32, 1),
        ("32x32", 64, 2),
        ("128x128", 128, 1),
        ("128x128", 256, 2),
        ("256x256", 256, 1),
        ("256x256", 512, 2),
        ("512x512", 512, 1),
        ("512x512", 1024, 2),
    ]

    images_entry = []
    for size_str, px, scale in sizes:
        filename = f"icon_{size_str}@{scale}x.png"
        icon_resized = app_icon.resize((px, px), Image.Resampling.LANCZOS)
        # Verify corner transparency
        for cx, cy in [(0, 0), (px - 1, 0), (0, px - 1), (px - 1, px - 1)]:
            assert icon_resized.getpixel((cx, cy))[3] == 0, f"Resize corner not transparent: {filename}"
        icon_resized.save(appicon_dir / filename)
        images_entry.append({
            "size": size_str,
            "idiom": "mac",
            "filename": filename,
            "scale": f"{scale}x"
        })

    appicon_contents = {
        "images": images_entry,
        "info": {
            "version": 1,
            "author": "xcode"
        }
    }
    with open(appicon_dir / "Contents.json", "w") as f:
        json.dump(appicon_contents, f, indent=2)

    # 2. Menu Bar Icons
    for label, rgb in [("Black", (0, 0, 0)), ("White", (255, 255, 255))]:
        icon_1x = generate_menubar_icon(18, color_rgb=rgb)
        icon_2x = generate_menubar_icon(36, color_rgb=rgb)
        icon_1x.save(out_dir / f"MenuBarIcon-{label}@1x.png")
        icon_2x.save(out_dir / f"MenuBarIcon-{label}@2x.png")
        if label == "Black":
            icon_1x.save(menubar_dir / "MenuBarIcon@1x.png")
            icon_2x.save(menubar_dir / "MenuBarIcon@2x.png")

    menubar_contents = {
        "images": [
            {
                "idiom": "mac",
                "scale": "1x",
                "filename": "MenuBarIcon@1x.png"
            },
            {
                "idiom": "mac",
                "scale": "2x",
                "filename": "MenuBarIcon@2x.png"
            }
        ],
        "info": {
            "version": 1,
            "author": "xcode"
        },
        "properties": {
            "template-rendering-intent": "template"
        }
    }
    with open(menubar_dir / "Contents.json", "w") as f:
        json.dump(menubar_contents, f, indent=2)


if __name__ == "__main__":
    out_dir = Path("Assets_Generated")
    out_dir.mkdir(parents=True, exist_ok=True)
    assets_dir = Path("Sources/SutraKey/Resources/Assets.xcassets")

    print("🎨 Generating SutraKey App Icons and Menu Bar icons...")
    write_asset_catalogs(out_dir, assets_dir)
    print(f"✅ Generated transparent SutraKey App Icon & Black/White Menu Bar icons in ./{out_dir}/ and {assets_dir}/")
