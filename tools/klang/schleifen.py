"""
Schleifen fürs Feuerknistern (18k): je 10 s aus einer CC0-Aufnahme, Ende weich in den Anfang geblendet, damit die
Fassung ohne Naht und ohne Pause endlos läuft. Ersetzt die kurzen crackle_*.ogg aus rezepte.py.

    tools/klang/holen.sh <ordner>                      # Aufnahmen laden (einmal)
    python3 tools/klang/schleifen.py <ordner>          # nach app/src/main/assets/sfx/crackle_{1,2,3}.ogg
"""
import sys, os, subprocess, numpy as np, soundfile as sf
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D = sys.argv[1]
LEN, XF = 10.0, 0.6   # Länge der Schleife, Überblendung Ende -> Anfang

def even(x, k=4.0): return np.tanh(k * x / max(1e-9, np.max(np.abs(x))))   # einzelne laute Knacker zähmen (wie rezepte.py)

def loop(f, a):
    x = highpass(load(os.path.join(D, f)), 35)
    seg = even(x[int(a * SR): int((a + LEN + XF) * SR)])
    n, k = int(LEN * SR), int(XF * SR)
    y = seg[:n].copy()
    t = np.linspace(0, np.pi / 2, k)
    y[:k] = seg[:k] * np.sin(t) + seg[n:n + k] * np.cos(t)   # gleiche Leistung: das Ende läuft in den Anfang
    return norm(y, -1.0, -20)

TAKES = [loop("fs_181563.mp3", 8.0), loop("fs_370938.mp3", 1.5), loop("fs_370938.mp3", 13.0)]
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
for i, y in enumerate(TAKES):
    tmp = os.path.join(out, "_tmp.wav"); sf.write(tmp, np.clip(y, -1, 1), SR, subtype="PCM_16")   # ohne Ausblenden am Ende
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                    "-map_metadata", "-1", os.path.join(out, f"crackle_{i + 1}.ogg")], check=True)
    os.remove(tmp)
    # Naht prüfen: Sprung zwischen letztem und erstem Wert nicht größer als zwischen Nachbarn sonst
    seam = abs(y[-1] - y[0]); typ = np.percentile(np.abs(np.diff(y)), 99.9)
    print(f"crackle_{i + 1}: {LEN:.0f} s, Naht {seam:.4f} (99,9 % der Schritte <= {typ:.4f})")
