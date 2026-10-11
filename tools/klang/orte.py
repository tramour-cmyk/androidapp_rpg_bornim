"""
Ortsklänge für die Blende (24.8, „Hören vor Sehen“): Wind und Halle im Tempel als nahtlose 10-s-Schleifen; knarrendes
Holz, Herzschlag und die Einzelklänge der Schänke (24.8.4: Becher, Einschenken, Wischen, Stuhl, Husten; kein
Stimmengewirr, Regel „Ortsklang nur von dem, was da ist“ in docs/STIL.md) als einzelne Klänge. Je drei Fassungen, alle aus CC0-Aufnahmen
(Quellen: QUELLEN.md). Schreibt nur diese Dateien, die übrigen Klänge bleiben unberührt.

    tools/klang/holen.sh <ordner>                          # Aufnahmen laden (einmal), dazu die Ortsaufnahmen unten
    python3 tools/klang/orte.py <ordner>                   # nach app/src/main/assets/sfx
    python3 tools/klang/orte.py <ordner> --proben <ziel>   # je Klang eine Hörprobe (alle Fassungen hintereinander)
"""
import sys, os, subprocess, numpy as np, soundfile as sf
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D = sys.argv[1]
_index = {}
for root, _, fs in os.walk(D):
    for f in fs: _index.setdefault(f, []).append(os.path.join(root, f))
def L(name): return load([p for p in _index[name] if "__MACOSX" not in p][0])

LEN, XF = 10.0, 1.0   # Länge der Schleife, Überblendung Ende -> Anfang

def loop(x, a):
    """10 s ab [a] s, das Ende gleitet mit gleicher Leistung in den Anfang: endlos ohne Naht."""
    seg = x[int(a * SR): int((a + LEN + XF) * SR)]
    n, k = int(LEN * SR), int(XF * SR)
    y = seg[:n].copy()
    t = np.linspace(0, np.pi / 2, k)
    y[:k] = seg[:k] * np.sin(t) + seg[n:n + k] * np.cos(t)
    return y

def room(x, wet=0.35, decay=1.4, seed=1): return reverb(x, wet, decay, damp=3500, seed=seed)

wind = highpass(L("wind background noise 2.wav"), 60)
park = highpass(L("park_ambience_wind.wav"), 60)
def hall(x, a, lp, seed=1):
    """Luft in einer hohen Halle ab [a] s: erst gedämpft und verhallt, dann zur nahtlosen 10-s-Schleife geschnitten."""
    seg = x[int((a - 4) * SR): int((a + LEN + XF + 1) * SR)]
    return loop(room(lowpass(seg, lp, 2), 0.6, 3.0, seed=seed), 4.0)

LOOPS = {
    # draußen (Dorf, Wald): Wind in Böen, mal hell, mal dumpf
    "wind": [loop(wind, 6.0), loop(lowpass(wind, 3000, 2), 52.0) if len(wind) > 63 * SR else loop(lowpass(wind, 3000, 2), 20.0),
             loop(park, 400.0 / 2)],
    # Tempel: Luft in einer hohen Halle, fast still
    # (Hall vor dem Schneiden, damit die Schleife 10 s bleibt: SoundPool kürzt Klänge über etwa 1 MB)
    "hall": [hall(wind, 20.0, 900), hall(park, 120.0, 800, 2), hall(wind, 30.0, 1100, 3)],
}
def ev(n, a, b, lp, semi=0):
    """Ein Einzelklang aus BigSoundBank-Aufnahme [n] von [a] bis [b] s, gedämpft, mit kleinem Raum."""
    x = highpass(lowpass(cut(L(f"bsb_{n}.mp3"), a, b, 0.005, 0.06), lp, 2), 80)
    return room(pitch(x, semi) if semi else x, 0.22, 0.9)

SHOTS = {
    # knarrendes Holz in Räumen (Dielen, Balken)
    "creak": [room(lowpass(trim(L("creak1.ogg")), 4500, 2), 0.2, 0.8), room(lowpass(pitch(trim(L("creak3.ogg")), -3), 4000, 2), 0.2, 0.8, seed=2),
              room(lowpass(cut(L("tree_creak.flac"), 0.3, 3.0, 0.05, 0.5), 3500, 2), 0.2, 0.8, seed=3)],
    # Schänke (24.8.4): Einzelklänge der Anwesenden, gedämpft wie in einer kleinen Stube; Gläser tiefer gestimmt
    "cup": [ev("0627", 1.48, 1.98, 4000), ev("1204", 3.15, 3.75, 3500, -3), ev("1205", 4.78, 5.25, 3500, -4)],
    "pour": [ev("1721", 1.25, 4.60, 6000), ev("1156", 0.60, 4.30, 6000), ev("1933", 0.40, 4.00, 6000)],
    "wipe": [ev("0689", 0.10, 2.20, 5000), ev("0689", 7.70, 9.80, 4500), ev("1104", 3.50, 6.10, 6000)],
    "chair": [ev("0666", 5.60, 6.35, 5000), ev("3053", 0.25, 1.20, 5000), ev("0518", 8.28, 8.75, 5000)],
    "cough": [ev("0488", 0.35, 1.30, 5000), ev("2183", 0.08, 0.48, 5000), ev("0207", 4.45, 5.00, 5000)],
    # Herzschlag für den Hinterhalt (24.8.3, später mit der Kampfblende)
    "heartbeat": [trim(L("heartbeat_slow_0.wav")), trim(L("heartbeat_fast_reverb.wav")),
                  shelf_low(pitch(trim(L("heartbeat.mp3_.flac")), -2), 4)],
}

def level(name, x):
    """Schleifen leise und ohne Spitzen (laufen unter allem), einzelne Klänge wie die übrigen."""
    return norm(x, -6.0, -26) if name in LOOPS else norm(trim(x, -55), -1.0, -17)

ALL = {**LOOPS, **SHOTS}
if "--proben" in sys.argv:
    out = sys.argv[sys.argv.index("--proben") + 1]; os.makedirs(out, exist_ok=True)
    for name, takes in ALL.items():
        gap = np.zeros(int(1.0 * SR))
        parts = []
        for x in takes:   # Schleifen zweimal hintereinander, damit die Naht hörbar wäre
            y = level(name, x); parts += ([y, y] if name in LOOPS else [y, gap, y]) + [gap, gap]
        tmp = os.path.join(out, "_tmp.wav"); sf.write(tmp, np.clip(np.concatenate(parts), -1, 1), SR, subtype="PCM_16")
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-c:a", "libmp3lame", "-q:a", "5", os.path.join(out, f"probe_{name}.mp3")], check=True)
        os.remove(tmp)
    print("Proben:", out)
else:
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in ALL.items():
        for i, x in enumerate(takes):
            y = level(name, x)
            tmp = os.path.join(out, "_tmp.wav"); sf.write(tmp, np.clip(y, -1, 1), SR, subtype="PCM_16")
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(out, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
            if name in LOOPS:
                seam = abs(y[-1] - y[0]); typ = np.percentile(np.abs(np.diff(y)), 99.9)
                print(f"{name}_{i + 1}: Naht {seam:.4f} (99,9 % der Schritte <= {typ:.4f})")
    print("fertig:", os.path.normpath(out))
