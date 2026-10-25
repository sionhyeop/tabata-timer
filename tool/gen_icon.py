"""Draws the app icon into assets/icon/ (SVG sources + 1024px PNGs).

Run from the project root, then regenerate the platform icons:
    python3 tool/gen_icon.py
    dart run flutter_launcher_icons

PNGs are rendered with headless Google Chrome (macOS path below, or set
CHROME=/path/to/chrome). The design: a white 8-segment ring — one segment
per Tabata round, the last two still to go — around a lightning bolt, on
an indigo → azure → aqua gradient.
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


def ring(scale, paint, cx=512, cy=512, r=300, width=66, gap_px=30):
    r *= scale
    width *= scale
    cap = math.degrees((width / 2) / r)
    gap = math.degrees((gap_px * scale) / r)
    span = 45 - gap - 2 * cap
    parts = []
    for i in range(8):
        start = -90 + i * 45 + gap / 2 + cap
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


def bolt(scale, paint, cx=512, cy=512):
    pts = [(572, 330), (410, 556), (490, 556), (450, 694), (614, 466), (540, 466)]
    pts = [(cx + (x - 512) * scale, cy + (y - 512) * scale) for x, y in pts]
    d = "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + " Z"
    return (
        f'<path d="{d}" fill="{paint}" stroke="{paint}" '
        f'stroke-width="{22 * scale:.1f}" stroke-linejoin="round"/>'
    )


def stops():
    return "\n".join(
        f'      <stop offset="{o}" stop-color="{c}"/>'
        for o, c in zip(("0", "0.5", "1"), GRADIENT)
    )


DEFS_BG = f"""
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
{stops()}
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
{stops()}
    </linearGradient>"""

BACKGROUND = (
    '<rect width="1024" height="1024" fill="url(#bg)"/>\n'
    '  <rect width="1024" height="1024" fill="url(#shine)"/>'
)


def symbol(scale, paint="#fff", shadow=True):
    attr = ' filter="url(#shadow)"' if shadow else ""
    return f"<g{attr}>\n    {ring(scale, paint)}\n    {bolt(scale, paint)}\n  </g>"


def svg(body, defs=""):
    return (
        '<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" '
        f'viewBox="0 0 1024 1024">\n  <defs>{defs}\n  </defs>\n  {body}\n</svg>\n'
    )


# Adaptive-icon layers keep the symbol inside Android's 66% safe zone.
ADAPTIVE = 0.82

FILES = {
    # iOS + legacy Android: full-bleed square, the OS applies the mask.
    "icon": svg(BACKGROUND + "\n  " + symbol(1.0), DEFS_BG + DEFS_SHADOW),
    "icon_background": svg(BACKGROUND, DEFS_BG),
    "icon_foreground": svg(symbol(ADAPTIVE), DEFS_SHADOW),
    # Android 13 themed icon: only alpha matters.
    "icon_monochrome": svg(symbol(ADAPTIVE, shadow=False)),
    # iOS 18 dark: gradient symbol on the system's dark plate.
    "icon_ios_dark": svg(symbol(1.0, "url(#fg)", shadow=False), DEFS_FG),
    # iOS 18 tinted: grayscale symbol, the system tints it.
    "icon_ios_tinted": svg(symbol(1.0, shadow=False)),
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


OUT.mkdir(parents=True, exist_ok=True)
for name, content in FILES.items():
    svg_path = OUT / f"{name}.svg"
    svg_path.write_text(content)
    render(svg_path, OUT / f"{name}.png")
print("wrote", ", ".join(f"{n}.svg/.png" for n in FILES))
