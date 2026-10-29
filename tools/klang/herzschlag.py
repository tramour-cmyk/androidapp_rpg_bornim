"""
Herzschlag beim Hinterhalt (402, Chef 28.10., 22:2x: „für Hinterhalt ein besseres Herzklopfen. Das war bisher im alten Spiel sehr
schwach“; 23:0x: „wieder völlig unauffällig. Das muss einfach [bumm, bumm] richtig machen“): drei Doppelschläge (bumm-bumm) unter
der schwarzen Blende, tief, nah, schneller werdend, der letzte am lautesten; danach der Klang des Hinterhalts. Drei Fassungen aus
den Aufnahmen von 24.8 (QUELLEN.md, `heartbeat`). Alle CC0.
Warum die erste Fassung unauffällig war (gemessen 29.10.): ihre Kraft lag unter 120 Hz, ein Handylautsprecher gibt erst ab etwa
350 Hz etwas wieder; dort lag sie 35–45 dB unter dem Gipfel, Ziege und Keuchen bei −17. Darum jetzt eine Mittelschicht: derselbe
Schlag stark angezerrt, nur 200–1400 Hz, so drückt er auch aus dem kleinen Lautsprecher; der Bass bleibt für Kopfhörer.

    python3 tools/klang/herzschlag.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben zum Anhören
    python3 tools/klang/herzschlag.py <ordner mit den Aufnahmen> --spiel    # nach app/src/main/assets/sfx (heartbeat_strong_1–3)

Aufnahmen (tools/klang/holen.sh): OpenGameArt bart „Heartbeat sounds“ (heartbeat_slow_0.wav), qubodup „Heartbeat single sound“
(heartbeat.mp3_.flac).
Chef 29.10., 10:52: „Da nehmen wir die Fassung 2 … Das Einfachste wäre nämlich so wie von einem Ultraschall … dumm, dumm, dumm“:
im Spiel vorerst nur Fassung 2 (heartbeat_strong_1); als Hörprobe drei Fassungen wie Ultraschall (ultraschall_1–3) aus zwei
Doppler-Aufnahmen (Freesound, CC0): SignatureSoundsOrg „Foetal Heartbeat Through Doppler Machine“ (fs_871122.mp3), TRP
„Ultrasound heartbeat fetus“ (fs_574849.mp3). Ein Doppler gibt den Schlag als Rauschen um 350–1500 Hz wieder, genau dort, wo der
Handylautsprecher spielt; tiefer gestimmt wird aus dem Kinderherz (140/min) ein erwachsenes, aufgeregtes (110–120/min).
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
# bumm-bumm: der zweite Schlag folgt nach 0,17 s, etwas leiser und heller (wie das Herz: Lub, Dub)
def paar(x, semis, seed, dub=0.17): return mix((schlag(x, semis, seed), 0.0, 1.0), (schlag(x, semis + 2, seed + 10), dub, 0.72))

einzeln = cut(L("heartbeat.mp3_.flac"), 0.12, 0.85, 0.002, 0.12)     # nur der Schlag, ohne den langen Nachhall
langsam = L("heartbeat_slow_0.wav")
lubdub = cut(langsam, 0.0, 0.55, 0.002, 0.08)           # erster Schlag des langsamen Herzens: Lub und Dub
# drei Doppelschläge, schneller werdend (0,62 s, dann 0,55 s); die Blende steht beim Hinterhalt 1,2 s (InterludeClock AMBUSH)
S = {"heartbeat_strong": [
    mix((paar(einzeln, -3, 1), 0.0, 0.75), (paar(einzeln, -3, 2), 0.62, 0.88), (paar(einzeln, -3, 3), 1.17, 1.0)),
    mix((schlag(lubdub, -2, 1), 0.0, 0.75), (schlag(lubdub, -2, 2), 0.62, 0.88), (schlag(lubdub, -2, 3), 1.17, 1.0)),
    mix((paar(einzeln, -4, 4), 0.0, 0.7), (schlag(lubdub, -3, 5), 0.60, 0.9), (paar(einzeln, -4, 6), 1.12, 1.0)),
]}

# Ultraschall: ein Stück der Aufnahme am Stück (der Doppler hat keinen einzelnen Schlag, jeder Schlag ist ein Doppelgeräusch der
# Klappen), tiefer gestimmt und damit langsamer; 1,6–1,8 s unter der Blende (AMBUSH 1,2 s), dann ausgeblendet
def doppler(f, a, semis, lang, bass=0.0):
    x = pitch(highpass(L(f), 120, 2)[int(a * SR):int((a + lang * 2 ** (semis / 12)) * SR) + SR // 10], semis)
    x = lowpass(x, 3200, 2)
    if bass: x = shelf_low(x, bass, 160)
    return cut(x, 0.0, lang, 0.03, 0.35)
U = {"ultraschall": [
    doppler("fs_871122.mp3", 5.75, 0, 1.6),            # wie aufgenommen, 140/min: dumm-dumm-dumm, hell
    doppler("fs_871122.mp3", 5.75, -4, 1.8, 6),        # 4 Halbtöne tiefer, 110/min, unten voller
    doppler("fs_574849.mp3", 3.85, -3, 1.8, 6),        # die andere Aufnahme: trockener, härter, 3 Halbtöne tiefer
]}

def finish(x): return norm(trim(x, -60), -0.5, -15)

if OUT == "--spiel":
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in {"heartbeat_strong": [S["heartbeat_strong"][1]]}.items():   # vorerst nur Fassung 2 (Chef 29.10., 10:52)
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Herzschlag nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in (S | U).items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x))
print("Proben:", OUT)
