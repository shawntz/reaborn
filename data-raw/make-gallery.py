"""Composite reaborn|seaborn side-by-side comparison images + a hero collage for
the pkgdown site. Run from the package root after rendering the fidelity images:

    /tmp/sbenv/bin/python data-raw/make-gallery.py
"""
import os
from PIL import Image, ImageDraw, ImageFont

SRC = "tests/fidelity/out"
DST = "man/figures"
os.makedirs(DST, exist_ok=True)

RB_BLUE = (76, 114, 176)
GRAY = (90, 90, 90)
DARK = (38, 38, 38)
LIGHT = (245, 246, 249)


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()


def fit_h(im, h):
    w = int(im.width * h / im.height)
    return im.resize((w, h), Image.LANCZOS)


def label_bar(width, left_text, right_text, h=46):
    bar = Image.new("RGB", (width, h), "white")
    d = ImageDraw.Draw(bar)
    f = font(26, bold=True)
    half = width // 2
    # left label (reaborn, brand blue) centered in left half
    lw = d.textlength(left_text, font=f)
    d.text((half / 2 - lw / 2, 8), left_text, fill=RB_BLUE, font=f)
    rw = d.textlength(right_text, font=f)
    d.text((half + half / 2 - rw / 2, 8), right_text, fill=GRAY, font=f)
    # divider
    d.line([(half, 6), (half, h - 6)], fill=(220, 220, 224), width=2)
    return bar


PAIRS = {
    "scatter": ("reaborn_scatter_hue.png", "seaborn_scatter.png"),
    "line": ("reaborn_line_hue.png", "seaborn_line_hue.png"),
    "hist": ("reaborn_hist.png", "seaborn_hist.png"),
    "histstack": ("reaborn_hist_stack.png", "seaborn_hist_stack.png"),
    "kde": ("reaborn_kde.png", "seaborn_kde.png"),
    "box": ("reaborn_box.png", "seaborn_box.png"),
    "boxhue": ("reaborn_box_hue.png", "seaborn_box_hue.png"),
    "boxen": ("reaborn_boxen.png", "seaborn_boxen.png"),
    "displot": ("reaborn_displot.png", "seaborn_displot.png"),
    "ecdf": ("reaborn_ecdf.png", "seaborn_ecdf.png"),
    "heatmap": ("reaborn_heatmap.png", "seaborn_heatmap.png"),
    "reg": ("reaborn_reg.png", "seaborn_reg.png"),
    "relplot": ("reaborn_relplot_line.png", "seaborn_relplot_line.png"),
    "violin": ("reaborn_violin.png", "seaborn_violin.png"),
}

PAD = 16
H = 430
for name, (rb, sb) in PAIRS.items():
    rp, sp = os.path.join(SRC, rb), os.path.join(SRC, sb)
    if not (os.path.exists(rp) and os.path.exists(sp)):
        print("skip", name)
        continue
    a = fit_h(Image.open(rp).convert("RGB"), H)
    b = fit_h(Image.open(sp).convert("RGB"), H)
    half = max(a.width, b.width) + PAD
    total_w = half * 2
    bar = label_bar(total_w, "reaborn", "seaborn")
    canvas = Image.new("RGB", (total_w, H + bar.height + PAD), "white")
    canvas.paste(bar, (0, 0))
    canvas.paste(a, (half // 2 - a.width // 2 + PAD // 2, bar.height + PAD // 2))
    canvas.paste(b, (half + half // 2 - b.width // 2 - PAD // 2, bar.height + PAD // 2))
    out = os.path.join(DST, f"compare-{name}.png")
    canvas.save(out)
    print("wrote", out, canvas.size)

# Hero collage: a tidy grid of reaborn showcase plots.
SHOW = ["reaborn_scatter_hue.png", "reaborn_violin.png", "reaborn_kde.png",
        "reaborn_heatmap.png", "reaborn_line_hue.png", "reaborn_boxen.png"]
cells = [fit_h(Image.open(os.path.join(SRC, s)).convert("RGB"), 300) for s in SHOW if os.path.exists(os.path.join(SRC, s))]
cols = 3
gap = 14
cw = max(c.width for c in cells)
rows = (len(cells) + cols - 1) // cols
hero = Image.new("RGB", (cols * cw + (cols + 1) * gap, rows * 300 + (rows + 1) * gap), "white")
for i, c in enumerate(cells):
    r, col = divmod(i, cols)
    x = gap + col * (cw + gap) + (cw - c.width) // 2
    y = gap + r * (300 + gap)
    hero.paste(c, (x, y))
hero.save(os.path.join(DST, "hero-collage.png"))
print("wrote hero-collage", hero.size)
print("DONE")
