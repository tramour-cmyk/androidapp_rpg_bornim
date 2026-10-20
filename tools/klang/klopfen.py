"""
Klopfen an einer verschlossenen Tür (215.1; Chef 20.10., 06:42: „Klopfgeräusch an Tür“): drei Fassungen, je zwei bis drei
Schläge der Fingerknöchel auf eine Holztür. Alle CC0 (QUELLEN.md): Kenney, Impact Sounds, impactWood_light und _medium.

    python3 tools/klang/klopfen.py <ordner mit kenney_impact.zip entpackt> <ziel>    # Hörprobe als WAV
    python3 tools/klang/klopfen.py <ordner> --spiel                                   # nach app/src/main/assets/sfx (knock_1–3)

Ein Schlag ist der Anfang einer Holzaufnahme, etwas höher gestimmt (Knöchel statt Hammer), die Tiefen etwas mehr (Tür
mit Körper), wenig Raum (draußen vor dem Haus). 215.2 (Chef 20.10., t45: „Klopfen an Türen ist sehr leise“): um etwa 6 dB
lauter, die Spitzen weich begrenzt.
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)

def rap(kind, n, semis, g=1.0):
    """Ein Schlag: die ersten 0,12 s von impactWood_<kind>_00<n>, gestimmt um [semis] Halbtöne."""
    x = cut(trim(load(os.path.join(D, "Audio", f"impactWood_{kind}_00{n}.ogg"))), 0, 0.12, 0.001, 0.05)
    return shelf_low(lowpass(pitch(x, semis), 6500, 2), 3, 220) * g

def knock(raps, wet, seed):
    """[raps]: (Zeitpunkt s, Art, Aufnahme, Halbtöne, Lautstärke)."""
    return drive(norm(reverb(mix(*[(rap(k, n, s, g), t, 1.0) for t, k, n, s, g in raps]), wet, 0.6, 3500, seed), -1.0, -12), 3.0)

def drive(x, k):
    """215.2: die Spitzen der Schläge weich gestaucht, der Klang dahinter kommt nach vorn (um [k] lauter, Spitze -1 dB)."""
    p = np.max(np.abs(x))
    return np.tanh(x / p * k) / np.tanh(k) * 10 ** (-1 / 20)

S = {"knock": [
    # zweimal rasch, dann einmal kräftiger: tok-tok … tok
    knock([(0.0, "light", 0, 2, 0.8), (0.17, "light", 1, 2, 0.75), (0.52, "medium", 2, 1, 1.0)], 0.12, 1),
    # drei gleichmäßige Schläge
    knock([(0.0, "medium", 0, 2, 0.9), (0.26, "medium", 1, 2, 0.85), (0.52, "medium", 3, 2, 0.9)], 0.12, 2),
    # zwei feste Schläge
    knock([(0.0, "medium", 4, 1, 1.0), (0.3, "light", 3, 1, 0.9)], 0.12, 3),
]}

if OUT == "--spiel":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(out, "_tmp.wav"); write(tmp, x)
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(out, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
            print(f"{name}_{i + 1}: {len(x) / SR:.2f} s")
    print("fertig:", os.path.normpath(out))
else:
    for name, takes in S.items():
        for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), x)
    print("fertig:", OUT)
