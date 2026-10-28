"""
Herzschlag beim Hinterhalt (402, Chef 28.10., 22:2x: „für Hinterhalt ein besseres Herzklopfen. Das war bisher im alten Spiel sehr
schwach“): drei schwere Schläge unter der schwarzen Blende, tief, nah, schneller werdend (0,62 s, dann 0,55 s), der letzte am
lautesten; danach der Klang des Hinterhalts. Drei Fassungen aus den Aufnahmen von 24.8 (QUELLEN.md, `heartbeat`). Alle CC0.

    python3 tools/klang/herzschlag.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben zum Anhören
    python3 tools/klang/herzschlag.py <ordner mit den Aufnahmen> --spiel    # nach app/src/main/assets/sfx (heartbeat_strong_1–3)

Aufnahmen (tools/klang/holen.sh): OpenGameArt bart „Heartbeat sounds“ (heartbeat_slow_0.wav), qubodup „Heartbeat single sound“
(heartbeat.mp3_.flac).
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)
L = lambda f: load(os.path.join(D, f))

def grit(x, k=2.5, wet=0.35): return x * (1 - wet) + np.tanh(k * x / max(1e-9, np.max(np.abs(x)))) * np.max(np.abs(x)) * wet
# ein Schlag: tiefer, die Brust voller (unter 120 Hz +9 dB), oben dunkel, etwas angezerrt, damit er auch im Handylautsprecher drückt
def schlag(x, semis, seed): return reverb(grit(lowpass(shelf_low(pitch(x, semis), 9, 120), 2500, 2)), 0.08, 0.5, seed=seed)

einzeln = cut(L("heartbeat.mp3_.flac"), 0.12, 0.85, 0.002, 0.12)     # nur der Schlag, ohne den langen Nachhall
paar = L("heartbeat_slow_0.wav")
lubdub = cut(paar, 0.0, 0.55, 0.002, 0.08)           # erster Schlag des langsamen Herzens: Lub und Dub
S = {"heartbeat_strong": [
    mix((schlag(einzeln, -3, 1), 0.0, 0.75), (schlag(einzeln, -3, 2), 0.62, 0.88), (schlag(einzeln, -3, 3), 1.17, 1.0)),
    mix((schlag(lubdub, -2, 1), 0.0, 0.75), (schlag(lubdub, -2, 2), 0.62, 0.88), (schlag(lubdub, -2, 3), 1.17, 1.0)),
    mix((schlag(einzeln, -4, 4), 0.0, 0.7), (schlag(lubdub, -3, 5), 0.60, 0.9), (schlag(einzeln, -4, 6), 1.12, 1.0)),
]}

def finish(x): return norm(trim(x, -60), -0.5, -15)

if OUT == "--spiel":
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Herzschlag nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x))
print("Proben:", OUT)
