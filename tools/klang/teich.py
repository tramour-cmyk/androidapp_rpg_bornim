"""
Hörproben am Waldweiher (27j): Froschrufe, Froschchor als Schleife, Flügelschlag der Libellen. Alle CC0 (QUELLEN.md, Runde 4).

    python3 tools/klang/teich.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben und eine Szene zum Anhören
    python3 tools/klang/teich.py <ordner mit den Aufnahmen> --spiel    # die gewählten (27k) nach app/src/main/assets/sfx

Aufnahmen: Freesound 710246 (Sahand.Zangeneh, Frösche am Wasser), 426462 (musicbrain, frogs_01), 240549 (jaegrover,
Libelle im Netz), 511326 (onehugeeye, Insect wings); OpenGameArt „Frog Croaks“ (croak_03.mp3).
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)
L = lambda f: load(os.path.join(D, f))

def win(x, a, b, fi=0.03, fo=0.12): return cut(x, a, b, fi, fo)
def far(x, hz=6000, wet=0.25, decay=1.0, seed=1): return reverb(lowpass(x, hz, 2), wet, decay, seed=seed)

frogs = highpass(L("fs_710246.mp3"), 250, 2)
chorus = highpass(L("fs_426462.mp3"), 200, 2)
wings = L("fs_240549.mp3")
wings2 = L("fs_511326.mp3")

S = {}
# einzelne Rufe (Wasserfrosch, knarrende Pulse um 2 kHz), drei aus der langen Aufnahme, einer tiefer aus OGA
S["frosch"] = [far(win(frogs, 0.35, 2.15)), far(win(frogs, 5.40, 6.40), seed=2), far(win(frogs, 21.95, 23.30), seed=3),
               far(trim(L("croak_03.mp3")), 5000, 0.3, seed=4)]
# Chor als Schleife (abends und nachts, leise unter den Einzelrufen); weiche Enden, damit sie im Kreis läuft
def loop(x, a, n=8.0, xf=0.6):
    y = x[int(a * SR): int((a + n + xf) * SR)].copy(); k = int(xf * SR)
    head, tail = y[:k], y[-k:]
    t = np.linspace(0, 1, k)
    y[:k] = head * np.sqrt(t) + tail * np.sqrt(1 - t)
    return y[:-k]
S["froschchor"] = [lowpass(loop(chorus, 40.0), 5000, 2), lowpass(loop(frogs, 9.5), 5000, 2)]
# Libelle: kurzes Schwirren, wenn sie dicht vorbeischießt; leise und weich, kein Summen wie bei Wespen
def whirr(x, a, b, hz=1800): return reverb(lowpass(highpass(win(x, a, b, 0.08, 0.25), 120, 2), hz, 4), 0.12, 0.6)
S["libelle"] = [whirr(wings, 2.85, 3.75), whirr(wings, 9.75, 10.55), whirr(wings2, 1.55, 2.45, 3000)]

def finish(x, rms=-20): return norm(trim(x, -55), -1.0, rms)

# Gewählt vom Nutzer (27k, 12.10.): Frosch 1–3, Chor 2, Libelle 1–2
if OUT == "--spiel":
    import subprocess
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    chosen = {"frog": S["frosch"][:3], "frog_chorus": [S["froschchor"][1]], "dragonfly": S["libelle"][:2]}
    for name, takes in chosen.items():
        for i, x in enumerate(takes):
            # the chorus loops: no trim, so its seam stays where the crossfade put it
            y = norm(x, -1.0, -22) if name == "frog_chorus" else finish(x)
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, y)
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Weiher-Klänge nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x, -22 if name == "froschchor" else -20))

# Szene, 24 s: Held nähert sich dem Weiher (Chor schwillt an), Rufe zu zufälligen Zeiten, zwei Libellen schwirren vorbei,
# zuletzt steht er am Ufer: die Frösche springen ins Wasser und schweigen, nur der ferne Chor bleibt
rnd = np.random.default_rng(7); n = int(24 * SR); out = np.zeros(n)
bed = np.tile(finish(S["froschchor"][0], -22), 4)[:n]
env = np.interp(np.arange(n) / SR, [0, 10, 17, 19, 24], [0.15, 0.7, 0.7, 0.35, 0.35])
out += bed * env * 0.6
t, last = 1.0, -1
while t < 17:
    k = rnd.integers(len(S["frosch"]))
    if k == last: continue
    x = finish(S["frosch"][k]); g = float(np.interp(t, [0, 10, 17], [0.2, 0.8, 0.8]))
    i = int(t * SR); out[i:i + len(x)] += x[: n - i] * g; last = k
    t += 1.2 + rnd.random() * 2.5
for t, k in [(6.0, 0), (13.5, 1)]:
    x = finish(S["libelle"][k]); i = int(t * SR); out[i:i + len(x)] += x[: n - i] * 0.3
write(os.path.join(OUT, "szene_weiher.wav"), norm(out, -1.0))
print("Proben:", OUT)
