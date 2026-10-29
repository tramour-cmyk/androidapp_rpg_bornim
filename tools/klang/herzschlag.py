"""
Herzschlag beim Hinterhalt (402, Chef 28.10., 22:2x: „für Hinterhalt ein besseres Herzklopfen. Das war bisher im alten Spiel sehr
schwach“; 23:0x: „wieder völlig unauffällig. Das muss einfach [bumm, bumm] richtig machen“): drei Schläge unter der schwarzen
Blende, tief, nah, schneller werdend, der letzte am lautesten; danach der Klang des Hinterhalts. Aus bart „Heartbeat sounds“
(heartbeat_slow_0.wav, OpenGameArt, CC0; QUELLEN.md `heartbeat`, Aufnahmen tools/klang/holen.sh).
Warum die erste Fassung unauffällig war (gemessen 29.10.): ihre Kraft lag unter 120 Hz, ein Handylautsprecher gibt erst ab etwa
350 Hz etwas wieder; dort lag sie 35–45 dB unter dem Gipfel, Ziege und Keuchen bei −17. Darum eine Mittelschicht: derselbe
Schlag stark angezerrt, nur im Mittenband, so drückt er auch aus dem kleinen Lautsprecher; der Bass bleibt für Kopfhörer.
Chef 29.10., 10:52 und 11:2x: im Spiel Fassung 2 (heartbeat_strong_1), Ultraschall verworfen; als Hörprobe Fassung 2 tiefer und
dumpfer (2a, 2b).

    python3 tools/klang/herzschlag.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben: Fassung 2, 2a, 2b
    python3 tools/klang/herzschlag.py <ordner mit den Aufnahmen> --spiel    # nach app/src/main/assets/sfx (heartbeat_strong_1)
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)
L = lambda f: load(os.path.join(D, f))

def grit(x, k=2.5, wet=0.35): return x * (1 - wet) + np.tanh(k * x / max(1e-9, np.max(np.abs(x)))) * np.max(np.abs(x)) * wet
# die Mittelschicht: der Schlag hart angezerrt (Obertöne des Basses), nur 200–1400 Hz, so laut wie der Schlag selbst mal MITTE
MITTE = 1.6
def mitte(x, k=48):
    p = max(1e-9, np.max(np.abs(x))); y = lowpass(highpass(np.tanh(k * x / p), 200, 4), 1400, 4)
    return y * p / max(1e-9, np.max(np.abs(y)))
# ein Schlag: tiefer, die Brust voller (unter 120 Hz +9 dB), oben dunkel, dazu die Mittelschicht für den Handylautsprecher
def schlag(x, semis, seed):
    b = grit(lowpass(shelf_low(pitch(x, semis), 9, 120), 2500, 2))
    return reverb(b + MITTE * mitte(b), 0.08, 0.5, seed=seed)
# dumpfer (Chef 29.10., 11:2x: „ein bisschen tiefer und dumpfer … Bum, bum, bum, dass man so einen leichten Beklemmungsgefühl
# bekommt, wie in so einem Scary-Movie“): tiefer gestimmt, oben früher zu, die Mittelschicht tiefer (150–[mhoch] Hz), etwas
# mehr Raum; so drückt er weiter aus dem Handylautsprecher, klingt aber wie durch die eigene Brust
def dumpf(x, semis, seed, lp, mhoch, hall):
    b = grit(lowpass(shelf_low(pitch(x, semis), 10, 110), lp, 3))
    p = max(1e-9, np.max(np.abs(b))); m = lowpass(highpass(np.tanh(48 * b / p), 150, 4), mhoch, 4)
    return reverb(b + 1.3 * m * p / max(1e-9, np.max(np.abs(m))), hall, 0.9, damp=1800, seed=seed)

langsam = L("heartbeat_slow_0.wav")
lubdub = cut(langsam, 0.0, 0.55, 0.002, 0.08)           # erster Schlag des langsamen Herzens: Lub und Dub
# drei Schläge, schneller werdend; die Blende steht beim Hinterhalt 1,2 s (InterludeClock AMBUSH), das Schwarz geht nach 1,75 s
S = {"heartbeat_strong": [
    mix((schlag(lubdub, -2, 1), 0.0, 0.75), (schlag(lubdub, -2, 2), 0.62, 0.88), (schlag(lubdub, -2, 3), 1.17, 1.0)),   # Fassung 2
    mix((dumpf(lubdub, -4, 1, 1100, 800, 0.14), 0.0, 0.75), (dumpf(lubdub, -4, 2, 1100, 800, 0.14), 0.66, 0.88),
        (dumpf(lubdub, -4, 3, 1100, 800, 0.14), 1.26, 1.0)),                        # 2a: zwei Halbtöne tiefer, dumpfer
    mix((dumpf(lubdub, -6, 1, 800, 600, 0.2), 0.0, 0.75), (dumpf(lubdub, -6, 2, 800, 600, 0.2), 0.72, 0.88),
        (dumpf(lubdub, -6, 3, 800, 600, 0.2), 1.36, 1.0)),                          # 2b: vier tiefer, ganz dumpf, langsamer
]}

def finish(x): return norm(trim(x, -60), -0.5, -15)

if OUT == "--spiel":
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in {"heartbeat_strong": [S["heartbeat_strong"][0]]}.items():   # vorerst nur Fassung 2 (Chef 29.10., 10:52)
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Herzschlag nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x))
print("Proben:", OUT)
