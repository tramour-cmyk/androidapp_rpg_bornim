"""
Umweltklang (84, D3.15): fernes Wolfsgeheul im Tiefen Wald, fernes Grollen in der Höhle, Flügelschlag und Scharren
der pickenden Vögel auf der Wiese. Alle CC0 (QUELLEN.md, „84 Umweltklang“).

    python3 tools/klang/umwelt.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben zum Anhören
    python3 tools/klang/umwelt.py <ordner mit den Aufnahmen> --spiel    # OGG nach app/src/main/assets/sfx

Aufnahmen (Freesound, Vorschau 128 kbit/s): 500646 betchkal „Cooper Creek … solitary wolf howl very clear“ (ein Wolf im
Wrangell-St.-Elias-Nationalpark, vier Heuler); 389303 AlanCat „rockfall2a“, 381645 AlanCat „RockFall1b“, 675736
craigsmith „S24-18 Landslide“ (Steinschlag, tiefer gestimmt und mit Höhlenhall: Grollen im Berg).
BigSoundBank (Joseph Sardin): 2891/2894 „Flight bird“, 0840 „Flight of a pigeon“ (Flügel), 3202 (Schritte auf Erde, fürs Scharren).
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)
L = lambda f: load(os.path.join(D, f))
def win(x, a, b, fi=0.05, fo=0.4): return cut(x, a, b, fi, fo)

S = {}
# Wolf: drei der vier Heuler (der zweite folgt dem ersten zu dicht); weit weg im Wald: oben dumpf, etwas Hall der Bäume
wolf = L("fs_500646.mp3")
def far(x, seed): return reverb(lowpass(highpass(x, 220, 2), 2400, 2), 0.25, 1.6, 2500, seed, 0.03)
S["wolf_far"] = [far(win(wolf, 1.8, 11.2), 1), far(win(wolf, 29.2, 38.6), 2), far(win(wolf, 40.4, 49.6), 3)]

# Grollen: Steinschlag eine halbe Oktave und mehr tiefer, nur das Tiefe (bis 600 Hz, damit es auch aus dem Handy kommt),
# langer dunkler Höhlenhall
def rumble(x, semis, seed): return reverb(lowpass(highpass(pitch(x, semis), 60, 2), 600, 4), 0.55, 3.0, 900, seed, 0.06)
S["rumble"] = [rumble(win(L("fs_389303.mp3"), 0.0, 4.5, 0.3, 1.2), -7, 1),
               rumble(win(L("fs_675736.mp3"), 9.5, 12.5, 0.3, 1.0), -9, 2),
               rumble(win(L("fs_381645.mp3"), 27.9, 30.7, 0.1, 0.8), -6, 3)]

# kleine Vögel fliegen auf: Flügel einer Taube und zweier Vögel, höher und kürzer (Spatz statt Huhn), leise draußen
def yard(x, hz=9000, wet=0.10, seed=1): return reverb(lowpass(highpass(x, 400, 2), hz, 2), wet, 0.5, seed=seed)
S["bird_flap"] = [yard(pitch(win(L("bsb_2891.mp3"), 0.30, 1.10, 0.005, 0.15), 6)),
                  yard(pitch(win(L("bsb_2894.mp3"), 0.22, 0.95, 0.005, 0.15), 6), seed=2),
                  yard(pitch(win(L("bsb_0840.mp3"), 0.08, 0.70, 0.005, 0.15), 7), seed=3)]
# Scharren im Gras: ein winziger Rechen der Füße, viel höher und leiser als beim Huhn
earth = L("bsb_3202.mp3")
def rake(a, b, seed): return yard(lowpass(highpass(pitch(win(earth, a, b, 0.003, 0.04), 9), 1500, 2), 9000, 2), 10000, 0.06, seed)
S["bird_scratch"] = [rake(0.14, 0.26, 1), rake(1.50, 1.62, 2), rake(9.58, 9.68, 3)]

RMS = {"wolf_far": -22, "rumble": -20, "bird_flap": -24, "bird_scratch": -28}
def finish(x, name): return norm(trim(x, -60), -1.0, RMS[name])

if OUT == "--spiel":
    import subprocess
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x, name))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Umweltklänge nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x, name))
print("Proben:", OUT)
