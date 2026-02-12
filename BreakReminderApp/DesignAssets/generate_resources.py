#!/usr/bin/env python3
"""
Generate DesignAssets from reference images (v1.3.1).
Inputs:
- reference_bg/*.jpg
- reference_style/*.jpg
Outputs:
- hero.png
- bg_pattern.png
- bg_pattern_alt.png
- icon_clock.png
"""

from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageOps, ImageEnhance
import random

ASSETS_DIR = Path(__file__).resolve().parent
REF_BG = ASSETS_DIR / "reference_bg"
REF_STYLE = ASSETS_DIR / "reference_style"


def load_image(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def cover_crop(image: Image.Image, width: int, height: int) -> Image.Image:
    src_w, src_h = image.size
    src_ratio = src_w / src_h
    dst_ratio = width / height
    if src_ratio > dst_ratio:
        new_h = height
        new_w = int(new_h * src_ratio)
    else:
        new_w = width
        new_h = int(new_w / src_ratio)
    resized = image.resize((new_w, new_h), Image.Resampling.LANCZOS)
    left = (new_w - width) // 2
    top = (new_h - height) // 2
    return resized.crop((left, top, left + width, top + height))


def dominant_colors(image: Image.Image, count: int = 8) -> list[tuple[int, int, int]]:
    tiny = image.convert("RGB").resize((96, 96), Image.Resampling.LANCZOS)
    quant = tiny.quantize(colors=16, method=Image.Quantize.MEDIANCUT).convert("RGB")
    colors = quant.getcolors(maxcolors=96 * 96) or []
    colors.sort(key=lambda x: x[0], reverse=True)
    return [c for _, c in colors[:count]]


def build_hero() -> None:
    base = load_image(REF_BG / "04_sunset_horizon.jpg")
    city = load_image(REF_BG / "03_buildings_golden.jpg")

    hero = cover_crop(base, 880, 560)
    city = cover_crop(city, 880, 560)

    city = ImageEnhance.Contrast(city).enhance(1.15)
    city = ImageEnhance.Color(city).enhance(1.05)
    hero = Image.blend(hero, city, 0.24)

    # right-side dark vignette for text readability
    vignette = Image.new("RGBA", hero.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(vignette)
    w, h = hero.size
    for x in range(w):
        t = max(0.0, (x - w * 0.35) / (w * 0.65))
        alpha = int(110 * t)
        draw.line([(x, 0), (x, h)], fill=(5, 8, 14, alpha))

    hero = Image.alpha_composite(hero, vignette)
    hero = ImageEnhance.Sharpness(hero).enhance(1.08)
    hero.save(ASSETS_DIR / "hero.png")
    print("✅ hero.png generated from reference_bg/04 + 03")


def build_bg_pattern() -> None:
    src = load_image(REF_BG / "08_water_abstract.jpg")
    src = cover_crop(src, 512, 512)

    # Extract subtle texture and recolor to blue/orange palette.
    gray = ImageOps.grayscale(src)
    edges = gray.filter(ImageFilter.FIND_EDGES).filter(ImageFilter.GaussianBlur(0.8))
    edges = ImageEnhance.Contrast(edges).enhance(1.7)

    base = Image.new("RGBA", (512, 512), (14, 34, 62, 255))
    tint = ImageOps.colorize(edges, black="#0f2a4d", white="#f58b4a").convert("RGBA")
    tint.putalpha(60)

    # Add slight noise so tiled areas feel less flat.
    noise = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    noise_draw = ImageDraw.Draw(noise)
    random.seed(42)
    for _ in range(6000):
        x = random.randint(0, 511)
        y = random.randint(0, 511)
        a = random.randint(5, 16)
        noise_draw.point((x, y), fill=(255, 255, 255, a))

    out = Image.alpha_composite(base, tint)
    out = Image.alpha_composite(out, noise)
    out.save(ASSETS_DIR / "bg_pattern.png")
    print("✅ bg_pattern.png generated from reference_bg/08")


def build_bg_pattern_alt() -> None:
    src = load_image(REF_BG / "03_buildings_golden.jpg")
    src = cover_crop(src, 512, 512)
    gray = ImageOps.grayscale(src)

    # Line pattern from skyline image and directional strokes.
    lines = gray.filter(ImageFilter.CONTOUR).filter(ImageFilter.GaussianBlur(1.0))
    lines = ImageEnhance.Contrast(lines).enhance(1.8)
    tinted = ImageOps.colorize(lines, black="#132f57", white="#f58b4a").convert("RGBA")
    tinted.putalpha(78)

    base = Image.new("RGBA", (512, 512), (12, 28, 52, 255))
    draw = ImageDraw.Draw(base)
    for i in range(-512, 1024, 24):
        draw.line([(i, 0), (i + 512, 512)], fill=(245, 139, 74, 22), width=1)

    out = Image.alpha_composite(base, tinted)
    out.save(ASSETS_DIR / "bg_pattern_alt.png")
    print("✅ bg_pattern_alt.png generated from reference_bg/03")


def build_clock_icon() -> None:
    gia = load_image(REF_STYLE / "style_ref_01_gia.jpg")
    sunset = load_image(REF_BG / "01_office_sunset.jpg")

    palette = dominant_colors(Image.alpha_composite(cover_crop(gia, 256, 256), cover_crop(sunset, 256, 256)), 6)
    warm = next((c for c in palette if c[0] > c[2]), (245, 139, 74))
    dark = next((c for c in palette if sum(c) < 210), (14, 25, 45))

    size = 256
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    c = size // 2
    r = 102

    # soft halo
    halo = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halo)
    for step in range(10, 0, -1):
        alpha = int(7 * step)
        hd.ellipse((c - r - step, c - r - step, c + r + step, c + r + step), outline=(*warm, alpha), width=1)

    # dial gradient approximation
    for i in range(r, 0, -1):
        t = i / r
        rr = int(warm[0] * (1 - t * 0.3) + dark[0] * (t * 0.3))
        gg = int(warm[1] * (1 - t * 0.3) + dark[1] * (t * 0.3))
        bb = int(warm[2] * (1 - t * 0.3) + dark[2] * (t * 0.3))
        d.ellipse((c - i, c - i, c + i, c + i), fill=(rr, gg, bb, 255))

    # ring and hands
    d.ellipse((c - r, c - r, c + r, c + r), outline=(255, 255, 255, 120), width=3)
    d.line((c, c, c, c - 56), fill=(18, 20, 30, 235), width=7)  # minute hand
    d.line((c, c, c + 38, c + 14), fill=(18, 20, 30, 235), width=9)  # hour hand
    d.ellipse((c - 8, c - 8, c + 8, c + 8), fill=(18, 20, 30, 255))

    img = Image.alpha_composite(img, halo)
    img.save(ASSETS_DIR / "icon_clock.png")
    print("✅ icon_clock.png generated with clock semantics + reference palette")


def main() -> None:
    missing = []
    required = [
        REF_BG / "01_office_sunset.jpg",
        REF_BG / "03_buildings_golden.jpg",
        REF_BG / "04_sunset_horizon.jpg",
        REF_BG / "08_water_abstract.jpg",
        REF_STYLE / "style_ref_01_gia.jpg",
    ]
    for p in required:
        if not p.exists():
            missing.append(str(p))

    if missing:
        print("❌ Missing required references:")
        for m in missing:
            print("  -", m)
        raise SystemExit(1)

    print("🎨 Generating assets from 15 reference images...")
    build_hero()
    build_bg_pattern()
    build_bg_pattern_alt()
    build_clock_icon()
    print("✅ Done")


if __name__ == "__main__":
    main()
