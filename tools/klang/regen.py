"""
Regen und Donner (D3.10): drei nahtlose 12-s-Schleifen Regen und drei ferne Donner aus CC0-Aufnahmen (QUELLEN.md,
„Runde 10“). Der Donner bleibt fern wie bisher (10.10., 1c): kein Krachen, nur ein tiefes Rollen, das anschwillt und
verebbt.

    python3 tools/klang/regen.py <ordner mit den Aufnahmen>                  # nach app/src/main/assets/sfx
    python3 tools/klang/regen.py <ordner mit den Aufnahmen> --proben <ziel>  # Hörproben (WAV)

Aufnahmen (BigSoundBank, Joseph Sardin, CC0; laden: holen.sh): 0124 „Rain and storm“ (Starkregen, Gewitter erst am
Ende), 0740 „Rain and storm #2“ (Starkregen zwischen den Donnern), 1019 „Summer rain on terrace“ (Sommerregen, dicke
Tropfen); 3116 „Thunder #5“, 3182 „Thunder #9“, 3179 „Thunder #6“ (einzelne Donner ohne Regen).
"""
import sys, os, subprocess, numpy as np, soundfile as sf
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D = sys.argv[1]
L = lambda f: load(os.path.join(D, f))
LEN, XF = 12.0, 1.5   # Länge der Schleife, Überblendung Ende -> Anfang

def loop(x, a, lp, hp=150):
    """Rauschen des Regens ohne Dröhnen darunter (fernes Grollen, Wind am Mikrofon), oben etwas gedämpft."""
    x = lowpass(highpass(x, hp, 2), lp, 2)
    seg = x[int(a * SR): int((a + LEN + XF) * SR)]
    n, k = int(LEN * SR), int(XF * SR)
    y = seg[:n].copy()
    t = np.linspace(0, np.pi / 2, k)
    y[:k] = seg[:k] * np.sin(t) + seg[n:n + k] * np.cos(t)   # gleiche Leistung: das Ende läuft in den Anfang
    return norm(y, -1.0, -20)

def far(x, a, b, seed):
    """Ferner Donner: nur das Tiefe (unter 700 Hz), weich einsetzend, Hall der Landschaft, langsam verebbend."""
    y = cut(lowpass(highpass(x, 35, 2), 700, 4), a, b, 0.35, 2.5)
    return norm(reverb(y, 0.3, 2.5, 600, seed, 0.05), -1.0, -16)

RAIN = [loop(L("bsb_0124.mp3"), 2.0, 7000),    # Starkregen, gleichmäßig
        loop(L("bsb_0740.mp3"), 30.0, 6000),   # Starkregen, dichter und dunkler
        loop(L("bsb_1019.mp3"), 42.0, 8000)]   # Sommerregen, einzelne dicke Tropfen hörbar
THUNDER = [far(L("bsb_3116.mp3"), 0.4, 15.0, 1),   # ein Schlag, schwillt an und verebbt
           far(L("bsb_3182.mp3"), 0.3, 18.0, 2),   # rollt mehrmals
           far(L("bsb_3179.mp3"), 0.0, 11.0, 3)]   # kurz und dumpf

proben = sys.argv[3] if len(sys.argv) > 3 and sys.argv[2] == "--proben" else None
out = proben or os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
if proben:
    os.makedirs(out, exist_ok=True)
    gap = np.zeros(int(SR * 1.0))
    sf.write(os.path.join(out, "regen_probe.wav"), np.clip(np.concatenate([np.concatenate([t, t, gap]) for t in RAIN]), -1, 1), SR, subtype="PCM_16")
    sf.write(os.path.join(out, "donner_probe.wav"), np.clip(np.concatenate([np.concatenate([t, gap]) for t in THUNDER]), -1, 1), SR, subtype="PCM_16")
    # so im Spiel: Regen leise (wie RAIN_MAX), ein Donner darüber
    bed = np.concatenate([RAIN[0], RAIN[0]]) * 0.35
    th = THUNDER[1] * 0.8; bed[int(4 * SR): int(4 * SR) + len(th)] += th[: len(bed) - int(4 * SR)]
    sf.write(os.path.join(out, "gewitter_probe.wav"), np.clip(bed, -1, 1), SR, subtype="PCM_16")
    sys.exit()
for name, takes in (("rain", RAIN), ("thunder", THUNDER)):
    for i, y in enumerate(takes):
        tmp = os.path.join(out, "_tmp.wav"); sf.write(tmp, np.clip(y, -1, 1), SR, subtype="PCM_16")
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "3",
                        "-map_metadata", "-1", os.path.join(out, f"{name}_{i + 1}.ogg")], check=True)
        os.remove(tmp)
        print(f"{name}_{i + 1}: {len(y) / SR:.1f} s" + (f", Naht {abs(y[-1] - y[0]):.4f}" if name == "rain" else ""))
