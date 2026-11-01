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
Chef 31.10., 21:07: Fassung 2b, aber als Paare: zwei kurze Schläge (Systole, Diastole), Pause, wieder zwei: „Bubum. Bubum. Bubum.
Bubum.“; die Hörprobe mit fünf einzelnen Schlägen „haut nicht hin“. Gemessen: in der Aufnahme liegen Lub und Dub 0,30 s
auseinander, tiefer gestimmt 0,42 s, fast so weit wie die Pause; so hörte man gleichmäßige Einzelschläge. Jetzt Lub und Dub
einzeln geschnitten und als Paar 0,17 s gesetzt, Dub leiser; vier Paare alle 0,5 s (120 Schläge in der Minute), lauter werdend,
das letzte endet, wenn das Schwarz der Blende geht (1,75 s).

    python3 tools/klang/herzschlag.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben: Fassung 2, 2a, 2b, 2b als Paare
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

# 402 Paare (Chef 31.10., 21:07): Lub 0,00–0,14 s, Dub 0,29–0,44 s der Aufnahme (segments: 0,000–0,125, 0,299–0,464), je in der
# Kette von 2b, weniger Raum, damit die Pause still bleibt; im Handyband (ab 350 Hz) gleich laut gemacht, Dub dann 0,8 so laut
# wie Lub. Die Blende des Hinterhalts geht nach 1,2 s, ihr Schwarz ist nach 1,67 s weg und mit ihr der Klang: drei Paare alle
# 0,55 s (110 Schläge in der Minute), Dub 0,16 s nach Lub, lauter werdend; das dritte klingt bei 1,6 s aus. Vier Paare passten
# nur mit 0,4 s Abstand, dann ist die Pause kaum länger als der Abstand im Paar.
lub, dub = cut(langsam, 0.0, 0.14, 0.002, 0.03), cut(langsam, 0.29, 0.44, 0.002, 0.06)
PAAR, ABSTAND, PAARE = 0.16, 0.55, 3
def handy(x): return np.max(np.abs(highpass(x, 350, 4)))
def paare(semis=-6, lp=800, mhoch=600, hall=0.1):
    l1 = [dumpf(lub, semis, 2 * i + 1, lp, mhoch, hall) for i in range(PAARE)]
    d1 = [dumpf(dub, semis, 2 * i + 2, lp, mhoch, hall) for i in range(PAARE)]
    k = handy(l1[0]) / max(1e-9, handy(d1[0]))
    lagen = []
    for i in range(PAARE):
        g = 0.75 + 0.25 * i / max(1, PAARE - 1)
        lagen += [(l1[i], i * ABSTAND, g), (d1[i] * k, i * ABSTAND + PAAR, 0.8 * g)]
    return mix(*lagen)
S["heartbeat_strong"].append(paare())                                                # 2b als Paare (im Spiel seit 31.10.)

def finish(x): return norm(trim(x, -60), -0.5, -15)

if OUT == "--spiel":
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in {"heartbeat_strong": [S["heartbeat_strong"][3]]}.items():   # 2b als Paare (Chef 31.10., 21:07)
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Herzschlag nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x))
print("Proben:", OUT)
