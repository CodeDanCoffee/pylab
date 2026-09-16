#!/usr/bin/env python3
"""Composite raw simulator screenshots into App Store marketing shots.

Reads raw simulator captures from screenshots/ and writes branded, framed,
App-Store-sized marketing images to template/.

App Store iPhone screenshot spec (6.9" / 6.7" — accepted for all modern iPhones):
    portrait 1290 x 2796 px.
"""

import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path

HERE = Path(__file__).parent
SRC = HERE / "screenshots"
OUT = HERE / "template"
OUT.mkdir(exist_ok=True)

# App Store required canvas (6.7"/6.9" portrait — universally accepted)
W, H = 1290, 2796

# Brand palette (matches PyTheme accent in the app)
BG_TOP    = (17, 10, 28)     # near-black, faint purple cast
BG_BOTTOM = (5, 4, 10)
ACCENT    = (250, 76, 140)   # pink
ACCENT2   = (170, 70, 220)   # purple
WHITE     = (255, 255, 255)

FONT_PATH = "/Users/israa/Library/Fonts/FiraCode-VariableFont_wght.ttf"


def font(size: int, weight: str = "Bold") -> ImageFont.FreeTypeFont:
    """Load Fira Code at the requested named weight."""
    f = ImageFont.truetype(FONT_PATH, size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f


# ----------------------------------------------------------------------------
# Background
# ----------------------------------------------------------------------------
def background() -> Image.Image:
    """Dark vertical gradient with a soft pink/purple glow behind the device."""
    img = Image.new("RGB", (W, H), BG_BOTTOM)
    px = img.load()
    for y in range(H):
        t = y / H
        row = (
            int(BG_TOP[0] * (1 - t) + BG_BOTTOM[0] * t),
            int(BG_TOP[1] * (1 - t) + BG_BOTTOM[1] * t),
            int(BG_TOP[2] * (1 - t) + BG_BOTTOM[2] * t),
        )
        for x in range(W):
            px[x, y] = row

    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    cx, cy = W // 2, int(H * 0.60)
    for radius in range(900, 0, -40):
        alpha = int(22 * (1 - radius / 900))
        gd.ellipse([cx - radius, cy - radius, cx + radius, cy + radius],
                   fill=(ACCENT[0], ACCENT[1], ACCENT[2], alpha))
    glow = glow.filter(ImageFilter.GaussianBlur(60))
    return Image.alpha_composite(img.convert("RGBA"), glow).convert("RGB")


def blobs(img: Image.Image):
    """Soft decorative blobs in the corners, brand-coloured."""
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    specs = [
        (int(W * 0.92), int(H * 0.10), 150, ACCENT2, 90),
        (int(W * 0.82), int(H * 0.155), 95, ACCENT2, 80),
        (int(W * 0.08), int(H * 0.30), 130, ACCENT, 70),
        (int(W * 0.16), int(H * 0.355), 80, ACCENT, 60),
        (int(W * 0.90), int(H * 0.66), 140, ACCENT2, 70),
        (int(W * 0.07), int(H * 0.88), 120, ACCENT, 65),
    ]
    for cx, cy, r, c, a in specs:
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(c[0], c[1], c[2], a))
    layer = layer.filter(ImageFilter.GaussianBlur(8))
    img.alpha_composite(layer)


# ----------------------------------------------------------------------------
# Tagline
# ----------------------------------------------------------------------------
def _wrap(draw, text, fnt, maxw):
    """Greedy word-wrap `text` to fit within `maxw` pixels."""
    words, lines, cur = text.split(), [], ""
    for w in words:
        trial = (cur + " " + w).strip()
        if draw.textlength(trial, font=fnt) <= maxw or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def draw_tagline(img: Image.Image, title: str, subtitle: str = ""):
    draw = ImageDraw.Draw(img)
    maxw = W - 150

    # Title: honour explicit line breaks, then shrink to fit width.
    size = 92
    while size > 48:
        title_font = font(size, "Bold")
        lines = title.upper().split("\n")
        if all(draw.textlength(ln, font=title_font) <= maxw for ln in lines):
            break
        size -= 4
    line_h = int(size * 1.13)
    y = 165
    for i, line in enumerate(lines):
        x = (W - draw.textlength(line, font=title_font)) // 2
        draw.text((x, y + i * line_h), line, font=title_font, fill=WHITE)

    if subtitle:
        sub_font = font(40, "Medium")
        sy = y + line_h * len(lines) + 26
        for sline in _wrap(draw, subtitle, sub_font, maxw):
            sx = (W - draw.textlength(sline, font=sub_font)) // 2
            draw.text((sx, sy), sline, font=sub_font, fill=(214, 206, 224))
            sy += 56


# ----------------------------------------------------------------------------
# Laurel rating badges
# ----------------------------------------------------------------------------
def _leaf_sprite(length, width, color):
    """A single white-ish laurel leaf as an RGBA sprite."""
    spr = Image.new("RGBA", (length, width), (0, 0, 0, 0))
    ImageDraw.Draw(spr).ellipse([0, 0, length - 1, width - 1], fill=color)
    return spr


def draw_laurel(img: Image.Image, cx, cy, radius, lines, boxed=False):
    """Draw a laurel wreath (open at the top) with centred text."""
    color = (238, 241, 248, 255)
    n = 11                      # leaves per branch
    leaf_len = int(radius * 0.42)
    leaf_w = int(radius * 0.20)
    sprite = _leaf_sprite(leaf_len, leaf_w, color)

    # Branch arcs (screen coords: y grows downward, bottom = 90°).
    # Left branch sweeps from bottom up the left; right branch mirrors.
    left = [90 + i * (140 / (n - 1)) for i in range(n)]      # 90 -> 230
    right = [90 - i * (140 / (n - 1)) for i in range(n)]     # 90 -> -50

    for side, angles in (("L", left), ("R", right)):
        for i, a in enumerate(angles):
            ar = math.radians(a)
            # leaves sit slightly inside the rim and grow toward the top
            rr = radius * (0.80 + 0.012 * i)
            x = cx + rr * math.cos(ar)
            y = cy + rr * math.sin(ar)
            # orient leaf tangent to the circle, pointing up the branch
            rot = -(a + 90) if side == "L" else -(a - 90)
            s = sprite.rotate(rot, expand=True, resample=Image.BICUBIC)
            img.alpha_composite(s, (int(x - s.width / 2), int(y - s.height / 2)))

    # centred text
    d = ImageDraw.Draw(img)
    big = font(int(radius * 0.34), "Bold")
    small = font(int(radius * 0.26), "Medium")
    fonts = [big] + [small] * (len(lines) - 1)
    heights = []
    for ln, fn in zip(lines, fonts):
        b = d.textbbox((0, 0), ln, font=fn)
        heights.append(b[3] - b[1])
    gap = int(radius * 0.06)
    total = sum(heights) + gap * (len(lines) - 1)
    ty = cy - total // 2 - int(radius * 0.05)
    text_boxes = []
    for ln, fn, hh in zip(lines, fonts, heights):
        b = d.textbbox((0, 0), ln, font=fn)
        tx = cx - (b[2] - b[0]) // 2
        text_boxes.append((tx + b[0], ty, tx + b[2], ty + hh))
        d.text((tx - b[0], ty - b[1]), ln, font=fn, fill=WHITE)
        ty += hh + gap

    if boxed and text_boxes:
        x0 = min(t[0] for t in text_boxes) - int(radius * 0.12)
        x1 = max(t[2] for t in text_boxes) + int(radius * 0.12)
        y0 = text_boxes[0][1] - int(radius * 0.10)
        y1 = text_boxes[-1][3] + int(radius * 0.10)
        d.rounded_rectangle([x0, y0, x1, y1], radius=int(radius * 0.08),
                            outline=(120, 190, 255, 255), width=3)


def rating_badges(img: Image.Image, cy=705):
    draw_laurel(img, int(W * 0.30), cy, 135, ["5.0", "Rating"], boxed=True)
    draw_laurel(img, int(W * 0.70), cy, 135, ["Editors", "choice"], boxed=False)


# ----------------------------------------------------------------------------
# Device frame
# ----------------------------------------------------------------------------
def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size[0], size[1]],
                                           radius=radius, fill=255)
    return mask


def device_frame(screenshot_path: Path) -> Image.Image:
    """Wrap a screenshot in an iPhone-style bezel with a dynamic island."""
    shot = Image.open(screenshot_path).convert("RGB")
    sw, sh = shot.size

    bezel = int(sw * 0.028)
    screen_radius = int(sw * 0.095)

    fw, fh = sw + bezel * 2, sh + bezel * 2
    frame_radius = screen_radius + bezel

    frame = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    fd = ImageDraw.Draw(frame)
    fd.rounded_rectangle([0, 0, fw, fh], radius=frame_radius, fill=(12, 12, 15, 255))
    fd.rounded_rectangle([2, 2, fw - 2, fh - 2], radius=frame_radius - 2,
                         outline=(70, 70, 82, 220), width=3)

    shot_rounded = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    shot_rounded.paste(shot, (0, 0), rounded_mask((sw, sh), screen_radius))
    frame.paste(shot_rounded, (bezel, bezel), shot_rounded)

    island_w = int(sw * 0.30)
    island_h = int(island_w * 0.30)
    ix = bezel + (sw - island_w) // 2
    iy = bezel + int(sh * 0.018)
    fd.rounded_rectangle([ix, iy, ix + island_w, iy + island_h],
                         radius=island_h // 2, fill=(0, 0, 0, 255))
    return frame


# ----------------------------------------------------------------------------
# 3D perspective tilt
# ----------------------------------------------------------------------------
def _solve(A, b):
    """Gauss-Jordan solve of A x = b for small dense systems (no numpy)."""
    n = len(A)
    M = [row[:] + [b[i]] for i, row in enumerate(A)]
    for col in range(n):
        piv = max(range(col, n), key=lambda r: abs(M[r][col]))
        M[col], M[piv] = M[piv], M[col]
        pv = M[col][col]
        M[col] = [v / pv for v in M[col]]
        for r in range(n):
            if r != col and M[r][col]:
                f = M[r][col]
                M[r] = [a - f * c for a, c in zip(M[r], M[col])]
    return [M[i][n] for i in range(n)]


def _find_coeffs(dst, src):
    """Perspective coefficients mapping output `dst` quad to input `src` quad."""
    A, b = [], []
    for (dx, dy), (sx, sy) in zip(dst, src):
        A.append([dx, dy, 1, 0, 0, 0, -sx * dx, -sx * dy])
        b.append(sx)
        A.append([0, 0, 0, dx, dy, 1, -sy * dx, -sy * dy])
        b.append(sy)
    return _solve(A, b)


def tilt_3d(frame: Image.Image, strength=0.12, lean=-7) -> Image.Image:
    """Rotate the device around its vertical axis (left edge closer), then lean."""
    w, h = frame.size
    src = [(0, 0), (w, 0), (w, h), (0, h)]
    dy = h * strength
    dst = [(0, 0), (w, dy), (w, h - dy), (0, h)]   # right edge recedes
    coeffs = _find_coeffs(dst, src)
    tilted = frame.transform((w, h), Image.PERSPECTIVE, coeffs,
                             resample=Image.BICUBIC)
    if lean:
        tilted = tilted.rotate(lean, expand=True, resample=Image.BICUBIC)
    return tilted


# ----------------------------------------------------------------------------
# Compose
# ----------------------------------------------------------------------------
def drop_shadow(layer, blur=60, offset=(0, 30), color=(0, 0, 0, 210)):
    w, h = layer.size
    pad = blur * 2
    shadow = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    base = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    base.paste(color, mask=layer.split()[-1])
    shadow.paste(base, (pad + offset[0], pad + offset[1]))
    return shadow.filter(ImageFilter.GaussianBlur(blur))


def compose(src_name, out_name, title, subtitle="", hero=False, tilt=False):
    bg = background().convert("RGBA")
    blobs(bg)
    draw_tagline(bg, title, subtitle)

    frame = device_frame(SRC / src_name)
    if tilt:
        frame = tilt_3d(frame)

    target_w = int(W * 0.78)
    scale = target_w / frame.width
    frame_scaled = frame.resize(
        (int(frame.width * scale), int(frame.height * scale)), Image.LANCZOS)

    fx = (W - frame_scaled.width) // 2
    fy = int(H * 0.355)
    if fy + frame_scaled.height > H - 50:
        fy = H - 50 - frame_scaled.height

    sh = drop_shadow(frame_scaled, offset=(20, 35))
    bg.alpha_composite(sh, (fx - 120, fy - 90))
    bg.alpha_composite(frame_scaled, (fx, fy))

    out_path = OUT / out_name
    bg.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"wrote {out_path}  ({W}x{H})")


# raw filename -> (output name, title, subtitle, hero)
SHOTS = [
    ("Simulator Screenshot - iPhone 17 - 2026-06-23 at 04.07.30.png",
     "01_learn.png", "Bite-sized\ncode snippets",
     "Short, focused snippets you can finish in a minute "
     "without getting overwhelmed.", False),
    ("Simulator Screenshot - iPhone 17 - 2026-06-23 at 04.07.46.png",
     "02_handson.png", "From data structures\nto real-world\nimplementations",
     "Strengthen the fundamentals, then see how real web apps "
     "and packages are actually built.", False),
    ("Simulator Screenshot - iPhone 17 - 2026-06-23 at 04.07.53.png",
     "03_paths.png", "Connect\nthe dots",
     "Each snippet is curated so every piece connects to the next.", False),
    ("Simulator Screenshot - iPhone 17 - 2026-06-23 at 04.08.08.png",
     "04_code.png", "Enterprise\nStandard Code",
     "Learn the conventions, structure, and best practices "
     "used in production codebases.", False),
    ("Simulator Screenshot - iPhone 17 - 2026-06-23 at 04.13.59.png",
     "05_pro.png", "Go Pro,\nunlock it all",
     "Every topic. Every lesson. Custom themes.", False),
]


if __name__ == "__main__":
    for src, out, title, sub, hero in SHOTS:
        compose(src, out, title, sub, hero=hero)
    print("\nDone. App Store-ready 1290x2796 shots are in template/")
