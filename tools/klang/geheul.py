"""
Kampfgeheul (D3, mit 18): der Leitwolf heult im Kampf aus der Nähe, statt des erzeugten Heulens drei CC0-Aufnahmen.
Je Fassung eine andere Aufnahme (D1.14) und eine andere Stelle als das ferne Wolfsgeheul (umwelt.py).

    python3 tools/klang/geheul.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben zum Anhören
    python3 tools/klang/geheul.py <ordner mit den Aufnahmen> --spiel    # OGG nach app/src/main/assets/sfx

Aufnahmen (Freesound, Vorschau 128 kbit/s, alle CC0): 500646 betchkal „Cooper Creek … solitary wolf howl very clear“
(zweiter Heuler), 143568 ondrosik „wolfs“ (ein Heuler vor dem Chor), 651193 Borgory „Wolfes howl howling Wolf Pack
heulen“ (Harz, ein tiefer Heuler aus dem Rudel). Gekürzt auf die Länge der Kopfbewegung (etwa 2 s) mit langem Ausklang.
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)
L = lambda f: load(os.path.join(D, f))

# nah, aber draußen: unten frei von Wind und Rumpeln, oben etwas weicher, wenig Hall der Bäume
def near(x, seed): return reverb(lowpass(highpass(x, 160, 2), 7000, 2), 0.14, 1.1, 4000, seed, 0.02)
S = {"howl": [near(cut(L("fs_500646.mp3"), 11.4, 14.4, 0.06, 1.0), 1),
              near(cut(L("fs_143568.mp3"), 9.4, 12.4, 0.06, 1.0), 2),
              near(cut(L("fs_651193.mp3"), 67.15, 69.7, 0.08, 0.9), 3)]}
def finish(x): return norm(trim(x, -60), -1.0, -19)

if OUT == "--spiel":
    import subprocess
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Kampfgeheul nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x))
print("Proben:", OUT)
