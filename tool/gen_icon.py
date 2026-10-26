"""Draws the app icon into assets/icon/ (SVG sources + 1024px PNGs).

Run from the project root, then regenerate the platform icons:
    python3 tool/gen_icon.py
    dart run flutter_launcher_icons

PNGs are rendered with headless Google Chrome (macOS path below, or set
CHROME=/path/to/chrome).

The design, on an indigo → azure → aqua gradient: a horseshoe of 8 rounded
segments — one per Tabata round, the last two still to go — whose open top
is closed by a TIMER wordmark, with a seven-segment "0:20" (Tabata's 20 s)
in the middle. Letters and digits are drawn as strokes, so no font is used.
"""

import math
import os
import subprocess
import tempfile
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "assets" / "icon"
CHROME = os.environ.get(
    "CHROME", "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
)

GRADIENT = ("#5457FF", "#3D7BFF", "#1FC7E9")
SHADOW = "#0B1E66"

# All geometry on a 1024 canvas, before any adaptive-icon scaling.
LAYOUT = {
    "cx": 512,
    "cy": 456,  # ring center; puts the whole mark's box at the canvas center
    "ring_r": 320,
    "ring_w": 58,
    "gap_deg": 112,  # opening at the top, closed by the wordmark
    "seg_gap": 26,  # visible space between ring segments
    "skew": -9,  # degrees of forward lean for text and digits
    "word_h": 84,
    "word_stroke": 30,
    "word_widths": {"T": 62, "I": 0, "M": 78, "E": 52, "R": 56},
    "word_space": 42,
    "digit_w": 92,
    "digit_h": 176,
    "digit_gap": 26,
    "digit_stroke": 32,
    "digit_dy": 36,  # digits center below the ring center
    "text": "0:20",
}


def ring(paint, L=LAYOUT):
    r, width, cx, cy = L["ring_r"], L["ring_w"], L["cx"], L["cy"]
    cap = math.degrees((width / 2) / r)
    gap = math.degrees(L["seg_gap"] / r)
    seg = (360 - L["gap_deg"]) / 8
    span = seg - gap - 2 * cap
    first = -90 + L["gap_deg"] / 2
    parts = []
    for i in range(8):
        start = first + i * seg + gap / 2 + cap
        a0, a1 = math.radians(start), math.radians(start + span)
        x0, y0 = cx + r * math.cos(a0), cy + r * math.sin(a0)
        x1, y1 = cx + r * math.cos(a1), cy + r * math.sin(a1)
        opacity = 1 if i < 6 else 0.38
        parts.append(
            f'<path d="M{x0:.1f} {y0:.1f} A{r:.1f} {r:.1f} 0 0 1 {x1:.1f} {y1:.1f}" '
            f'stroke="{paint}" stroke-opacity="{opacity}" stroke-width="{width:.1f}" '
            f'stroke-linecap="round" fill="none"/>'
        )
    return "\n    ".join(parts)


def _skewed(content, cx, cy, skew):
    return (
        f'<g transform="translate({cx} {cy}) skewX({skew}) translate({-cx} {-cy})">'
        f"{content}</g>"
    )


def _seven_segment(digit, x, y, w, h, g):
    m = y + h / 2
    seg = {
        "a": ((x + g, y), (x + w - g, y)),
        "b": ((x + w, y + g), (x + w, m - g)),
        "c": ((x + w, m + g), (x + w, y + h - g)),
        "d": ((x + g, y + h), (x + w - g, y + h)),
        "e": ((x, m + g), (x, y + h - g)),
        "f": ((x, y + g), (x, m - g)),
        "g": ((x + g, m), (x + w - g, m)),
    }
    on = {"0": "abcdef", "1": "bc", "2": "abged", "3": "abgcd"}[digit]
    return "".join(
        f"M{x0:.1f} {y0:.1f} L{x1:.1f} {y1:.1f} "
        for (x0, y0), (x1, y1) in (seg[k] for k in on)
    )


def digits(paint, L=LAYOUT):
    w, h, gap, s = L["digit_w"], L["digit_h"], L["digit_gap"], L["digit_stroke"]
    colon = s * 0.9
    g = s / 2 + 6  # leaves a visible break between segments
    widths = [colon if ch == ":" else w for ch in L["text"]]
    total = sum(widths) + gap * (len(widths) - 1)
    x = L["cx"] - total / 2
    cy = L["cy"] + L["digit_dy"]
    y = cy - h / 2
    d, dots = "", ""
    for ch, cw in zip(L["text"], widths):
        if ch == ":":
            for fy in (0.3, 0.7):
                dots += (
                    f'<circle cx="{x + cw / 2:.1f}" cy="{y + h * fy:.1f}" '
                    f'r="{s * 0.6:.1f}" fill="{paint}"/>'
                )
        else:
            d += _seven_segment(ch, x, y, w, h, g)
        x += cw + gap
    body = (
        f'<path d="{d}" stroke="{paint}" stroke-width="{s}" stroke-linecap="round" '
        f'fill="none"/>{dots}'
    )
    return _skewed(body, L["cx"], cy, L["skew"])


def wordmark(paint, L=LAYOUT):
    """TIMER in rounded monoline letters, closing the ring's opening."""
    h, sp, widths = L["word_h"], L["word_space"], L["word_widths"]
    total = sum(widths[c] for c in "TIMER") + sp * 4
    x = L["cx"] - total / 2
    # Sit on the chord between the ring's two open ends.
    cy = L["cy"] - L["ring_r"] * math.cos(math.radians(L["gap_deg"] / 2))
    top, b = cy - h / 2, cy + h / 2
    paths = []
    for ch in "TIMER":
        w = widths[ch]
        if ch == "T":
            paths.append(f"M{x} {top} L{x + w} {top} M{x + w / 2} {top} L{x + w / 2} {b}")
        elif ch == "I":
            paths.append(f"M{x} {top} L{x} {b}")
        elif ch == "M":
            paths.append(
                f"M{x} {b} L{x} {top} L{x + w / 2} {top + h * 0.6} L{x + w} {top} L{x + w} {b}"
            )
        elif ch == "E":
            paths.append(
                f"M{x + w} {top} L{x} {top} L{x} {b} L{x + w} {b} "
                f"M{x} {cy} L{x + w * 0.82} {cy}"
            )
        elif ch == "R":
            bowl = h * 0.54
            rr = bowl / 2
            paths.append(
                f"M{x} {b} L{x} {top} L{x + w - rr} {top} "
                f"A{rr} {rr} 0 0 1 {x + w - rr} {top + bowl} L{x} {top + bowl} "
                f"M{x + w - rr - 4} {top + bowl} L{x + w} {b}"
            )
        x += w + sp
    body = (
        f'<path d="{" ".join(paths)}" stroke="{paint}" stroke-width="{L["word_stroke"]}" '
        f'stroke-linecap="round" stroke-linejoin="round" fill="none"/>'
    )
    return _skewed(body, L["cx"], cy, L["skew"])


def _stops():
    return "\n".join(
        f'      <stop offset="{o}" stop-color="{c}"/>'
        for o, c in zip(("0", "0.5", "1"), GRADIENT)
    )


DEFS_BG = f"""
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
{_stops()}
    </linearGradient>
    <radialGradient id="shine" cx="0.22" cy="0.12" r="0.75">
      <stop offset="0" stop-color="#fff" stop-opacity="0.28"/>
      <stop offset="0.6" stop-color="#fff" stop-opacity="0"/>
    </radialGradient>"""

DEFS_SHADOW = f"""
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="10" stdDeviation="14" flood-color="{SHADOW}" flood-opacity="0.35"/>
    </filter>"""

DEFS_FG = f"""
    <linearGradient id="fg" x1="0" y1="0" x2="1024" y2="1024" gradientUnits="userSpaceOnUse">
{_stops()}
    </linearGradient>"""

BACKGROUND = (
    '<rect width="1024" height="1024" fill="url(#bg)"/>\n'
    '  <rect width="1024" height="1024" fill="url(#shine)"/>'
)


def symbol(scale, paint="#fff", shadow=True, L=LAYOUT):
    attr = ' filter="url(#shadow)"' if shadow else ""
    t = f"translate(512 512) scale({scale}) translate(-512 -512)"
    return (
        f'<g{attr}><g transform="{t}">\n    {ring(paint, L)}\n'
        f"    {wordmark(paint, L)}{digits(paint, L)}\n  </g></g>"
    )


def svg(body, defs=""):
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" '
        f'viewBox="0 0 1024 1024">\n  <defs>{defs}\n  </defs>\n  {body}\n</svg>\n'
    )


# Adaptive-icon layers keep the mark inside Android's 66% safe zone.
ADAPTIVE = 0.8


def files(L=LAYOUT):
    return {
        # iOS + legacy Android: full-bleed square, the OS applies the mask.
        "icon": svg(BACKGROUND + "\n  " + symbol(1.0, L=L), DEFS_BG + DEFS_SHADOW),
        "icon_background": svg(BACKGROUND, DEFS_BG),
        "icon_foreground": svg(symbol(ADAPTIVE, L=L), DEFS_SHADOW),
        # Android 13 themed icon: only alpha matters.
        "icon_monochrome": svg(symbol(ADAPTIVE, shadow=False, L=L)),
        # iOS 18 dark: gradient mark on the system's dark plate.
        "icon_ios_dark": svg(symbol(1.0, "url(#fg)", shadow=False, L=L), DEFS_FG),
        # iOS 18 tinted: grayscale mark, the system tints it.
        "icon_ios_tinted": svg(symbol(1.0, shadow=False, L=L)),
    }


def render(svg_path, png_path):
    with tempfile.TemporaryDirectory() as profile:
        subprocess.run(
            [
                CHROME,
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                "--force-device-scale-factor=1",
                "--default-background-color=00000000",
                "--window-size=1024,1024",
                f"--user-data-dir={profile}",
                f"--screenshot={png_path}",
                svg_path.as_uri(),
            ],
            check=True,
            capture_output=True,
        )


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    for name, content in files().items():
        svg_path = OUT / f"{name}.svg"
        svg_path.write_text(content)
        render(svg_path, OUT / f"{name}.png")
    print("wrote", ", ".join(f"{n}.svg/.png" for n in files()))
