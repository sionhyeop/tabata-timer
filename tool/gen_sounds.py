"""Synthesizes the app's cue sounds into assets/sounds/.

Run from the project root:  python3 tool/gen_sounds.py
"""

import math
import struct
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


def tone(freq, ms, volume=0.55, fade_ms=8):
    """A slightly bright tone (fundamental + soft odd harmonics)."""
    n = int(RATE * ms / 1000)
    fade = int(RATE * fade_ms / 1000)
    samples = []
    for i in range(n):
        t = i / RATE
        v = (
            math.sin(2 * math.pi * freq * t)
            + 0.25 * math.sin(2 * math.pi * freq * 3 * t)
            + 0.08 * math.sin(2 * math.pi * freq * 5 * t)
        ) / 1.33
        env = min(1.0, i / fade if fade else 1.0, (n - i) / fade if fade else 1.0)
        samples.append(v * env * volume)
    return samples


def silence(ms):
    return [0.0] * int(RATE * ms / 1000)


def write(name, samples):
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(
            b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32767)) for s in samples)
        )


# 3-2-1 countdown: short neutral beep.
write("countdown.wav", tone(1000, 120))

# Work starts: long, high, unmistakable.
write("work.wav", tone(1568, 500, volume=0.65, fade_ms=20))

# Rest starts: two descending notes.
write("rest.wav", tone(988, 160) + silence(40) + tone(659, 260, fade_ms=20))

# Workout complete: rising arpeggio (C6 E6 G6 C7).
write(
    "finish.wav",
    tone(1047, 130)
    + silence(20)
    + tone(1319, 130)
    + silence(20)
    + tone(1568, 130)
    + silence(20)
    + tone(2093, 520, volume=0.6, fade_ms=60),
)

print("wrote", sorted(p.name for p in OUT.glob("*.wav")))
