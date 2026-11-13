"""
Ketten fallen (1144; Chef 13.11., 14:49, Lyra in Graks Halle: „die Ketten fallen klirrend zu Boden. Da wäre vielleicht ein Geräusch
nicht das Schlechteste“): drei Fassungen von „chains“, je zwei Fesseln, die kurz nacheinander auf Stein fallen, mit dem Hall der
Höhle (nur dort zu hören; eine Raumfassung gibt es darum nicht). Quelle CC0 (QUELLEN.md): rubberduck, 80 CC0 RPG SFX, chain_01–03.

    python3 tools/klang/ketten.py <ordner mit 80-CC0-RPG-SFX_0.zip entpackt> <ziel>    # Hörprobe als WAV
    python3 tools/klang/ketten.py <ordner> --spiel                                      # nach godot/daten/klang/sfx (chains_1–3)

Die erste Fessel etwas tiefer und lauter (schwerer, näher), die zweite 0,2–0,35 s später, höher und leiser; Tiefen leicht angehoben
(Steinboden), Hall wie die Höhle (lang, dumpf).
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)

def kette(n, semis, g=1.0):
    """Eine Fessel: chain_0<n>, gestimmt um [semis] Halbtöne, Höhen gedämpft."""
    x = trim(load(os.path.join(D, f"chain_0{n}.ogg")))
    return shelf_low(lowpass(pitch(x, semis), 7000, 2), 3, 200) * g

def fallen(teile, seed):
    """[teile]: (Zeitpunkt s, Aufnahme, Halbtöne, Lautstärke)."""
    return norm(reverb(mix(*[(kette(n, s, g), t, 1.0) for t, n, s, g in teile]), 0.32, 1.5, 3000, seed), -1.0, -17)

S = {"chains": [
    fallen([(0.0, 1, -2, 1.0), (0.24, 2, 0, 0.7)], 1),
    fallen([(0.0, 2, -3, 1.0), (0.31, 3, -1, 0.65)], 2),
    fallen([(0.0, 3, -2, 1.0), (0.2, 1, 1, 0.6), (0.42, 2, 2, 0.35)], 3),
]}

if OUT == "--spiel":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "godot", "daten", "klang", "sfx")
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
