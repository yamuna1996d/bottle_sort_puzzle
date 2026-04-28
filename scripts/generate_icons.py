#!/usr/bin/env python3
"""Generate Bottle Sort Puzzle app icons for all platforms."""

import os
from PIL import Image, ImageDraw, ImageChops

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

RED = (235, 65,  80)
YEL = (255, 195, 40)
TEA = (40,  198, 182)
PUR = (155, 82,  232)


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def rr_mask(size, rect, radius):
    """Grayscale rounded-rectangle mask."""
    img = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(img)
    x0, y0, x1, y1 = rect
    r = radius
    d.rectangle([x0 + r, y0, x1 - r, y1], fill=255)
    d.rectangle([x0, y0 + r, x1, y1 - r], fill=255)
    d.ellipse([x0, y0, x0 + r*2, y0 + r*2], fill=255)
    d.ellipse([x1 - r*2, y0, x1, y0 + r*2], fill=255)
    d.ellipse([x0, y1 - r*2, x0 + r*2, y1], fill=255)
    d.ellipse([x1 - r*2, y1 - r*2, x1, y1], fill=255)
    return img


def tube_shape_mask(s, cx, top_y, bot_y, half_w):
    """U-shape (rectangle + bottom semicircle) mask."""
    mask = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(mask)
    circle_center_y = bot_y - half_w
    d.rectangle([cx - half_w, top_y, cx + half_w, circle_center_y], fill=255)
    d.ellipse([cx - half_w, circle_center_y - half_w,
               cx + half_w, circle_center_y + half_w], fill=255)
    return mask


def vgradient(draw, x0, y0, x1, y1, c_top, c_bot):
    for y in range(y0, y1 + 1):
        t = (y - y0) / max(y1 - y0, 1)
        draw.line([(x0, y), (x1, y)], fill=lerp_color(c_top, c_bot, t))


def composite(base, layer, mask=None):
    if mask is not None:
        tmp = Image.new("RGBA", base.size, (0, 0, 0, 0))
        tmp.paste(layer, (0, 0), mask)
        return Image.alpha_composite(base, tmp)
    return Image.alpha_composite(base, layer)


def draw_tube(img, cx, top_y, bot_y, ow, border, layers, sc):
    """Draw one test tube with colored liquid layers onto img."""
    s = img.size[0]
    half_ow = ow // 2
    half_iw = half_ow - border

    # --- Build masks ---
    outer_m = tube_shape_mask(s, cx, top_y, bot_y, half_ow)
    inner_m = tube_shape_mask(s, cx, top_y, bot_y, half_iw)
    border_m = ImageChops.subtract(outer_m, inner_m)

    # --- Liquid (draw top→bottom so layers[0]=bottom is last drawn) ---
    liq = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ld = ImageDraw.Draw(liq)
    n = len(layers)
    span = bot_y - top_y  # drawing span — mask clips the rounded bottom
    for i in range(n):
        color = layers[n - 1 - i]          # i=0 → top layer; i=n-1 → bottom
        ly0 = top_y + round(i * span / n)
        ly1 = top_y + round((i + 1) * span / n)
        if i == n - 1:
            ly1 = bot_y + ow              # overshoot so mask fills the circle
        ld.rectangle([cx - ow, ly0, cx + ow, ly1], fill=color + (255,))
        # subtle highlight band at each colour boundary
        hi = tuple(min(255, c + 55) for c in color)
        ld.line([(cx - half_iw, ly0), (cx + half_iw, ly0)], fill=hi + (120,))

    # --- Glass shine (left quarter, fading downward) ---
    shine = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sw = max(3, half_iw // 3)
    sx0 = cx - half_iw + 2
    sx1 = sx0 + sw
    h_shine = (bot_y - top_y) // 2
    for dy in range(h_shine):
        t = dy / max(h_shine - 1, 1)
        a = int(75 * (1 - t) ** 1.4)
        sd.line([(sx0, top_y + dy), (sx1, top_y + dy)], fill=(255, 255, 255, a))

    # --- Right-edge thin rim highlight ---
    sd.line([(cx + half_iw - 1, top_y), (cx + half_iw - 1, bot_y - half_ow)],
            fill=(255, 255, 255, 30))

    # --- Composite ---
    img = composite(img, liq, inner_m)
    border_img = Image.new("RGBA", (s, s), (18, 28, 72, 235))
    img = composite(img, border_img, border_m)
    img = composite(img, shine, inner_m)
    return img


def draw_neck(img, cx, top_y, nw, nh, border, sc):
    s = img.size[0]
    half_nw = nw // 2
    ny0 = top_y - nh
    ny1 = top_y
    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    # Border
    d.rectangle([cx - half_nw, ny0, cx + half_nw, ny1], fill=(18, 28, 72, 230))
    # Glass interior
    b = max(2, border - 1)
    d.rectangle([cx - half_nw + b, ny0, cx + half_nw - b, ny1],
                fill=(150, 190, 235, 170))
    # Shine strip
    d.rectangle([cx - half_nw + b, ny0, cx - half_nw + b + max(2, nw // 5), ny1],
                fill=(255, 255, 255, 55))
    return Image.alpha_composite(img, layer)


def draw_cap(img, cx, neck_top, nw, border, sc):
    s = img.size[0]
    cap_h = max(5, int(12 * sc))
    cap_r = max(2, cap_h // 2)
    cx0 = cx - nw // 2 - border
    cx1 = cx + nw // 2 + border
    cy0 = neck_top - cap_h
    cy1 = neck_top + border
    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    col = (28, 38, 88, 252)
    d.rectangle([cx0 + cap_r, cy0, cx1 - cap_r, cy1], fill=col)
    d.rectangle([cx0, cy0 + cap_r, cx1, cy1], fill=col)
    d.ellipse([cx0, cy0, cx0 + cap_r * 2, cy0 + cap_r * 2], fill=col)
    d.ellipse([cx1 - cap_r * 2, cy0, cx1, cy0 + cap_r * 2], fill=col)
    # cap shine
    d.rectangle([cx0 + cap_r, cy0 + 1, cx1 - cap_r, cy0 + max(2, cap_h // 3)],
                fill=(255, 255, 255, 35))
    return Image.alpha_composite(img, layer)


def draw_shadow(img, cx, bot_y, ow, sc):
    s = img.size[0]
    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    shy = bot_y + int(6 * sc)
    rx = int(ow * 0.48)
    ry = max(2, int(rx * 0.22))
    for step in range(rx, 0, -max(1, rx // 8)):
        a = int(48 * (1 - step / rx))
        ry2 = max(1, round(ry * step / rx))
        d.ellipse([cx - step, shy - ry2, cx + step, shy + ry2], fill=(0, 0, 0, a))
    return Image.alpha_composite(img, layer)


def draw_color_dots(img, s, sc):
    layer = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    dot_r = int(14 * sc)
    gap = int(38 * sc)
    palette = [RED, YEL, TEA, PUR]
    total_w = (len(palette) - 1) * gap
    x0 = s // 2 - total_w // 2
    dy = int(68 * sc)
    for i, col in enumerate(palette):
        dx = x0 + i * gap
        d.ellipse([dx - dot_r, dy - dot_r, dx + dot_r, dy + dot_r], fill=col + (255,))
        sr = max(2, dot_r // 3)
        d.ellipse([dx - dot_r + 2, dy - dot_r + 2,
                   dx - dot_r + 2 + sr, dy - dot_r + 2 + sr],
                  fill=(255, 255, 255, 200))
    return Image.alpha_composite(img, layer)


def make_icon(size):
    s = size
    sc = s / 1024.0
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))

    # ── Background gradient ──────────────────────────────────────────────────
    bg = Image.new("RGBA", (s, s), (0, 0, 0, 255))
    bgd = ImageDraw.Draw(bg)
    vgradient(bgd, 0, 0, s - 1, s - 1, (8, 14, 48), (30, 8, 80))
    bg_mask = rr_mask(s, (0, 0, s - 1, s - 1), int(s * 0.22))
    img.paste(bg, (0, 0), bg_mask)

    # ── Subtle radial glow ───────────────────────────────────────────────────
    glow = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    gcx, gcy = s // 2, int(s * 0.56)
    gr = int(s * 0.36)
    gd = ImageDraw.Draw(glow)
    for i in range(20, 0, -1):
        rn = round(gr * i / 20)
        a = int(16 * (1 - i / 20))
        gd.ellipse([gcx - rn, gcy - rn, gcx + rn, gcy + rn], fill=(90, 55, 215, a))
    img = Image.alpha_composite(img, glow)

    # ── Tube geometry ────────────────────────────────────────────────────────
    ow = int(118 * sc)           # outer width
    bdr = max(3, int(5 * sc))    # border thickness
    tube_h = int(500 * sc)
    neck_h = int(82 * sc)
    neck_w = int(48 * sc)
    spacing = int(195 * sc)

    cy = int(568 * sc)
    top_y = cy - tube_h // 2
    bot_y = cy + tube_h // 2

    centers = [s // 2 - spacing, s // 2, s // 2 + spacing]
    palettes = [
        [RED, TEA, YEL, PUR],    # mixed    (bottom → top)
        [YEL, YEL, TEA, TEA],    # half-sorted
        [RED, RED, RED, RED],     # sorted
    ]

    for cx, layers in zip(centers, palettes):
        img = draw_tube(img, cx, top_y, bot_y, ow, bdr, layers, sc)
        img = draw_neck(img, cx, top_y, neck_w, neck_h, bdr, sc)
        img = draw_cap(img, cx, top_y - neck_h, neck_w, bdr, sc)
        img = draw_shadow(img, cx, bot_y, ow, sc)

    # ── Colour dots ──────────────────────────────────────────────────────────
    img = draw_color_dots(img, s, sc)

    # ── Re-clip to rounded background ────────────────────────────────────────
    final = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    final.paste(img, (0, 0), bg_mask)
    return final


# ── Output helpers ────────────────────────────────────────────────────────────

def save(master, path, size):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    master.resize((size, size), Image.LANCZOS).save(path, "PNG")
    print(f"  {size:>4}×{size:<4}  {os.path.relpath(path, BASE)}")


def main():
    print("Rendering 1024×1024 master …")
    master = make_icon(1024)
    assets_dir = os.path.join(BASE, "assets")
    os.makedirs(assets_dir, exist_ok=True)
    master_path = os.path.join(assets_dir, "icon_master.png")
    master.save(master_path, "PNG")
    print(f"  master → {os.path.relpath(master_path, BASE)}\n")

    print("Android")
    for folder, px in [("mipmap-mdpi", 48), ("mipmap-hdpi", 72),
                        ("mipmap-xhdpi", 96), ("mipmap-xxhdpi", 144),
                        ("mipmap-xxxhdpi", 192)]:
        save(master, os.path.join(BASE, "android", "app", "src", "main",
                                  "res", folder, "ic_launcher.png"), px)

    print("\niOS")
    ios = os.path.join(BASE, "ios", "Runner", "Assets.xcassets",
                       "AppIcon.appiconset")
    for name, px in [
        ("Icon-App-20x20@1x.png",     20),  ("Icon-App-20x20@2x.png",     40),
        ("Icon-App-20x20@3x.png",     60),  ("Icon-App-29x29@1x.png",     29),
        ("Icon-App-29x29@2x.png",     58),  ("Icon-App-29x29@3x.png",     87),
        ("Icon-App-40x40@1x.png",     40),  ("Icon-App-40x40@2x.png",     80),
        ("Icon-App-40x40@3x.png",    120),  ("Icon-App-60x60@2x.png",    120),
        ("Icon-App-60x60@3x.png",    180),  ("Icon-App-76x76@1x.png",     76),
        ("Icon-App-76x76@2x.png",    152),  ("Icon-App-83.5x83.5@2x.png",167),
        ("Icon-App-1024x1024@1x.png",1024),
    ]:
        save(master, os.path.join(ios, name), px)

    print("\nmacOS")
    macos = os.path.join(BASE, "macos", "Runner", "Assets.xcassets",
                         "AppIcon.appiconset")
    for name, px in [
        ("app_icon_16.png", 16),   ("app_icon_32.png", 32),
        ("app_icon_64.png", 64),   ("app_icon_128.png", 128),
        ("app_icon_256.png", 256), ("app_icon_512.png", 512),
        ("app_icon_1024.png", 1024),
    ]:
        save(master, os.path.join(macos, name), px)

    print("\n✓  All icons generated.")


if __name__ == "__main__":
    main()
