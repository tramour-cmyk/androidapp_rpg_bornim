"""
Der Fluss am Dorf (D6.4): drei nahtlose 12-s-Schleifen fließenden Wassers aus CC0-Aufnahmen (Quellen: QUELLEN.md),
gedämpft, damit es nach breitem, ruhigem Fluss klingt und nicht nach hellem Gebirgsbach oder nach Wind.

    tools/klang/holen.sh <ordner>                          # Aufnahmen laden (einmal)
    python3 tools/klang/fluss.py <ordner>                  # nach app/src/main/assets/sfx/river_{1,2,3}.ogg
    python3 tools/klang/fluss.py <ordner> --proben <ziel>  # Hörprobe: alle drei hintereinander, je zweimal
"""
import sys, os, subprocess, numpy as np, soundfile as sf
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D = sys.argv[1]
LEN, XF = 12.0, 1.5   # Länge der Schleife, Überblendung Ende -> Anfang

def loop(f, a, lp):
    x = lowpass(highpass(load(os.path.join(D, f)), 60), lp, 2)
    seg = x[int(a * SR): int((a + LEN + XF) * SR)]
    n, k = int(LEN * SR), int(XF * SR)
    y = seg[:n].copy()
    t = np.linspace(0, np.pi / 2, k)
    y[:k] = seg[:k] * np.sin(t) + seg[n:n + k] * np.cos(t)   # gleiche Leistung: das Ende läuft in den Anfang
    return norm(y, -1.0, -20)

TAKES = [
    loop("VistulaShort_0.mp3", 75.0, 2400),   # Wellen am Ufer eines breiten Flusses, ruhige Stelle
    loop("bsb_0864.mp3", 20.0, 1800),         # Bächlein, stark gedämpft: Gurgeln statt Rauschen
    loop("bsb_0823.mp3", 30.0, 1800),         # kleiner Bach, ebenso
]
proben = sys.argv[3] if len(sys.argv) > 3 and sys.argv[2] == "--proben" else None
out = proben or os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
if proben:
    gap = np.zeros(int(SR * 0.8))
    y = np.concatenate([np.concatenate([t, t, gap]) for t in TAKES])
    sf.write(os.path.join(out, "fluss_probe.wav"), np.clip(y, -1, 1), SR, subtype="PCM_16")
    sys.exit()
for i, y in enumerate(TAKES):
    tmp = os.path.join(out, "_tmp.wav"); sf.write(tmp, np.clip(y, -1, 1), SR, subtype="PCM_16")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                    "-map_metadata", "-1", os.path.join(out, f"river_{i + 1}.ogg")], check=True)
    os.remove(tmp)
    seam = abs(y[-1] - y[0]); typ = np.percentile(np.abs(np.diff(y)), 99.9)
    print(f"river_{i + 1}: {LEN:.0f} s, Naht {seam:.4f} (99,9 % der Schritte <= {typ:.4f})")
