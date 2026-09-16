#!/usr/bin/env python3
"""Composite raw simulator screenshots into App Store 6.7" marketing shots."""

from PIL import Image, ImageDraw, ImageFilter, ImageFont
from pathlib import Path

HERE = Path(__file__).parent
RAW = HERE / "raw"
OUT = HERE / "out"
OUT.mkdir(exist_ok=True)

# App Store 6.7" required canvas
W, H = 1290, 2796

# Brand colors
BG_TOP    = (15, 9, 24)      # near-black with purple cast
BG_BOTTOM = (4, 3, 8)
ACCENT    = (250, 76, 140)   # PyTheme.accent
ACCENT2   = (200, 46, 158)
WHITE     = (255, 255, 255)
SUBTITLE  = (255, 255, 255, 180)


def font(size: int, weight: str = "Bold") -> ImageFont.FreeTypeFont:
    candidates = [
        f"/System/Library/Fonts/SFCompactRounded-{weight}.otf",
        f"/System/Library/Fonts/SF-Pro-Rounded-{weight}.otf",
        f"/System/Library/Fonts/SFNS{weight}.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for c in candidates:
        if Path(c).exists():
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()


def background() -> Image.Image:
    """Dark vertical gradient with a soft pink glow near the device."""
    img = Image.new("RGB", (W, H), BG_BOTTOM)
    px = img.load()
    for y in range(H):
        t = y / H
        r = int(BG_TOP[0] * (1 - t) + BG_BOTTOM[0] * t)
        g = int(BG_TOP[1] * (1 - t) + BG_BOTTOM[1] * t)
        b = int(BG_TOP[2] * (1 - t) + BG_BOTTOM[2] * t)
        for x in range(W):
            px[x, y] = (r, g, b)

    # Pink radial glow centered behind the device
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    cx, cy = W // 2, int(H * 0.62)
    for radius in range(900, 0, -40):
        alpha = int(20 * (1 - radius / 900))
        gdraw.ellipse(
            [cx - radius, cy - radius, cx + radius, cy + radius],
            fill=(ACCENT[0], ACCENT[1], ACCENT[2], alpha)
        )
    glow = glow.filter(ImageFilter.GaussianBlur(60))
    img = Image.alpha_composite(img.convert("RGBA"), glow).convert("RGB")
    return img


def draw_tagline(img: Image.Image, title: str, subtitle: str = ""):
    draw = ImageDraw.Draw(img)
    title_font = font(118, "Bold")
    sub_font = font(48, "Regular")

    # measure title
    lines = title.split("\n")
    line_h = 130
    total_h = line_h * len(lines)
    y = 200
    for i, line in enumerate(lines):
        bbox = draw.textbbox((0, 0), line, font=title_font)
        line_w = bbox[2] - bbox[0]
        x = (W - line_w) // 2
        draw.text((x, y + i * line_h), line, font=title_font, fill=WHITE)

    if subtitle:
        sy = y + total_h + 24
        bbox = draw.textbbox((0, 0), subtitle, font=sub_font)
        sw = bbox[2] - bbox[0]
        sx = (W - sw) // 2
        draw.text((sx, sy), subtitle, font=sub_font, fill=(255, 255, 255, 200))


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size[0], size[1]],
                                            radius=radius, fill=255)
    return mask


def device_frame(screenshot_path: Path) -> Image.Image:
    """Wrap the screenshot in an iPhone-style bezel."""
    shot = Image.open(screenshot_path).convert("RGB")
    sw, sh = shot.size

    # Bezel sizing — relative to the screenshot
    bezel = int(sw * 0.025)
    screen_radius = int(sw * 0.075)  # screen corner radius

    # Outer dims include bezel + a tiny extra for the body shadow ring
    fw = sw + bezel * 2
    fh = sh + bezel * 2
    frame_radius = screen_radius + bezel

    # Build the frame body (black with subtle border highlight)
    frame = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    fd = ImageDraw.Draw(frame)
    fd.rounded_rectangle([0, 0, fw, fh], radius=frame_radius, fill=(15, 15, 18, 255))

    # Inner highlight ring to suggest the metal rail
    fd.rounded_rectangle([2, 2, fw - 2, fh - 2],
                         radius=frame_radius - 2, outline=(60, 60, 70, 200), width=2)

    # Inset the screenshot with rounded corners
    shot_rounded = Image.new("RGBA", (sw, sh), (0, 0, 0, 0))
    shot_rounded.paste(shot, (0, 0), rounded_mask((sw, sh), screen_radius))
    frame.paste(shot_rounded, (bezel, bezel), shot_rounded)

    # Dynamic Island overlay (sits over the status bar)
    island_w = int(sw * 0.32)
    island_h = int(island_w * 0.30)
    island_x = bezel + (sw - island_w) // 2
    island_y = bezel + int(sh * 0.022)
    fd.rounded_rectangle(
        [island_x, island_y, island_x + island_w, island_y + island_h],
        radius=island_h // 2, fill=(0, 0, 0, 255)
    )

    return frame


def drop_shadow(layer: Image.Image, blur: int = 40, offset=(0, 20),
                 color=(0, 0, 0, 180)) -> Image.Image:
    w, h = layer.size
    pad = blur * 2
    shadow = Image.new("RGBA", (w + pad * 2, h + pad * 2), (0, 0, 0, 0))
    base = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    base.paste(color, mask=layer.split()[-1])
    shadow.paste(base, (pad + offset[0], pad + offset[1]))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    return shadow


def compose(raw_name: str, out_name: str, title: str, subtitle: str = ""):
    bg = background().convert("RGBA")
    draw_tagline(bg, title, subtitle)

    frame = device_frame(RAW / raw_name)

    # Scale frame to fit the lower 60% of canvas, ~85% canvas width max
    target_w = int(W * 0.78)
    scale = target_w / frame.width
    new_size = (int(frame.width * scale), int(frame.height * scale))
    frame_scaled = frame.resize(new_size, Image.LANCZOS)

    # Position centered horizontally, below the tagline
    fx = (W - frame_scaled.width) // 2
    fy = int(H * 0.30)
    # If too tall, push up
    if fy + frame_scaled.height > H - 80:
        fy = H - 80 - frame_scaled.height

    # Drop shadow first
    sh = drop_shadow(frame_scaled, blur=60, offset=(0, 30),
                     color=(0, 0, 0, 200))
    bg.paste(sh, (fx - 120, fy - 90), sh)
    bg.paste(frame_scaled, (fx, fy), frame_scaled)

    final = bg.convert("RGB")
    out_path = OUT / out_name
    final.save(out_path, "PNG", optimize=True)
    print(f"wrote {out_path} ({final.size[0]}x{final.size[1]})")


if __name__ == "__main__":
    compose(
        raw_name="home.png",
        out_name="01_home.png",
        title="Master Python,\none card at a time",
        subtitle="Bite-sized lessons. Crystal-clear examples.",
    )
    compose(
        raw_name="card.png",
        out_name="02_lesson.png",
        title="Real code.\nReal output.\nRight away.",
        subtitle="Syntax and result, side by side.",
    )
