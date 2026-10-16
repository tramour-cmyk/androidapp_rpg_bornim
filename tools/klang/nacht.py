"""
Die Nacht unter dem Schwarzbild des Intros (69c.1, `[69.intro.5]`): fern und gedämpft, wie durch die Wände des Gasthauses,
eine Glocke (Schleife), Rufe und ein Schrei (je drei Fassungen) aus CC0-Aufnahmen (Quellen: QUELLEN.md).

    tools/klang/holen.sh <ordner>                          # Aufnahmen laden (einmal)
    python3 tools/klang/nacht.py <ordner>                  # nach app/src/main/assets/sfx/{alarm_bell,far_shout,far_scream}_{1,2,3}.ogg
    python3 tools/klang/nacht.py <ordner> --proben <ziel>  # Hörprobe: das Schwarzbild unter der Titelmusik, mit Messung
"""
import sys, os, glob, subprocess, numpy as np, soundfile as sf
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D = sys.argv[1]
HERE = os.path.dirname(os.path.abspath(__file__))
VOX = glob.glob(os.path.join(D, "x_Voice_Effects_Zombie-Skeleton-Monster_Human_Male", "*", ""))
VOX = VOX[0] if VOX else os.path.join(D, "x_Voice_Effects_Zombie-Skeleton-Monster_Human_Male")

def far(x, lp, wet, decay=1.6, damp=1500):
    """Fern und hinter Wänden: unten und oben beschnitten, viel Hall."""
    return reverb(lowpass(highpass(x, 110), lp, 2), wet=wet, decay=decay, damp=damp, seed=7)

def bell(f, a, length, xf=1.0):
    """Nahtlose Schleife: [length] s ab a (bei gleichmäßigem Läuten ein Vielfaches der Schlagfolge, dann passt die Naht)."""
    x = far(load(os.path.join(D, f)), 650, 0.35)
    n, k = int(length * SR), int(xf * SR)
    seg = x[int(a * SR): int(a * SR) + n + k]
    y = seg[:n].copy(); t = np.linspace(0, np.pi / 2, k)
    y[:k] = seg[:k] * np.sin(t) + seg[n:n + k] * np.cos(t)
    return norm(y, -3.0, -24)

def cry(f, lp):
    return norm(trim(far(load(f), lp, 0.45, decay=1.4, damp=1800), -50), -4.0, -20)

SWING = 2.132   # Schlagfolge der schwingenden Glocke in 0830 (Hin und Her), gemessen über 80 s
BELLS = [
    bell("bsb_0830.mp3", 0.1 + 9 * SWING + 1.2, 4 * SWING),   # eine schwingende Kirchenglocke: Sturmläuten
    bell("bsb_0135.mp3", 3.2, 8.0),                           # Einzelschläge alle 2 s
    bell("bsb_0829.mp3", 20.0, 8.5),                          # vier Glocken durcheinander
]
SHOUTS = [cry(os.path.join(VOX, f"humanYell{i}.wav"), 900) for i in (1, 2, 4)]
SCREAMS = [cry(os.path.join(VOX, "humanDeath1.wav"), 1100), cry(os.path.join(VOX, "humanDeath2.wav"), 1100),
           cry(os.path.join(D, "bsb_2361.mp3"), 1100)]

def ogg(y, path):
    tmp = path + ".wav"; sf.write(tmp, np.clip(y, -1, 1), SR, subtype="PCM_16")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                    "-map_metadata", "-1", path], check=True)
    os.remove(tmp)

def db(x): return 20 * np.log10(max(1e-9, np.sqrt(np.mean(x ** 2))))

proben = sys.argv[3] if len(sys.argv) > 3 and sys.argv[2] == "--proben" else None
if proben:
    # Wie im Spiel (IntroSound, MusicPlayer): Titelmusik ab Beginn des Schwarzbilds in 2 s auf 0,6; Glocke in 2,5 s auf
    # BELL; Rufe und Schrei zu den Zeiten aus IntroSound.night; nach 7,2 s blendet alles in 1,2 s aus. Je Glocke eine Probe.
    BELL, IN, STEP, END = 0.12, 2.5, 7.2, 1.2
    music = load(os.path.join(HERE, "..", "..", "app", "src", "main", "assets", "music", "titel_adventure_intro.ogg"))
    n = int((STEP + END + 0.5) * SR); t = np.arange(n) / SR
    out = np.clip(1 - (t - STEP) / END, 0, 1)
    m = music[:n] * 0.6 * np.clip(t / 2.0, 0, 1) * out
    cues = [(2.3, SHOUTS[0], 0.10), (3.6, SHOUTS[1], 0.08), (4.6, SHOUTS[2], 0.09), (5.7, SCREAMS[0], 0.12)]
    gap = np.zeros(int(SR * 1.0)); parts = []
    for i, b in enumerate(BELLS):
        s = np.zeros(n); k = np.clip(t / IN, 0, 1); k = k * k * (3 - 2 * k)
        s += np.resize(b, n) * BELL * k * out
        for at, c, v in cues:
            c = (SCREAMS[i] if c is SCREAMS[0] else c); j = int(at * SR); s[j:j + len(c)] += c[:n - j] * v
        hold = slice(int(3.0 * SR), int(7.0 * SR))
        print(f"Glocke {i + 1}: Musik {db(m[hold]):.1f} dB, Glocke {db(s[hold] - 0):.1f} dB (nur Glocke "
              f"{db((np.resize(b, n) * BELL)[hold]):.1f} dB) → {100 * 10 ** ((db((np.resize(b, n) * BELL)[hold]) - db(m[hold])) / 20):.0f} % der Musik")
        for at, c, v in cues:
            c = (SCREAMS[i] if c is SCREAMS[0] else c); w = slice(int(at * SR), int(at * SR) + len(c))
            print(f"   {at:.1f} s: {db(c * v):.1f} dB gegen Musik {db(m[w]):.1f} dB → {100 * 10 ** ((db(c * v) - db(m[w])) / 20):.0f} %")
        parts += [m + s, gap]
    y = np.concatenate(parts)
    sf.write(os.path.join(proben, "nacht_probe.wav"), np.clip(y, -1, 1), SR, subtype="PCM_16")
    sys.exit()
out = os.path.join(HERE, "..", "..", "app", "src", "main", "assets", "sfx")
for name, takes in (("alarm_bell", BELLS), ("far_shout", SHOUTS), ("far_scream", SCREAMS)):
    for i, y in enumerate(takes):
        ogg(y, os.path.join(out, f"{name}_{i + 1}.ogg"))
        print(f"{name}_{i + 1}: {len(y) / SR:.1f} s, {db(y):.1f} dB")
