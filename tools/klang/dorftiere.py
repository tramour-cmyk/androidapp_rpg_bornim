"""
Laute der Dorftiere (401, Chef 28.10., 22:0x: „die Geräusche für alle Tiere, die jetzt hier rumstehen, auch mindestens 3“):
Ziege meckert und rupft Gras, Kaninchen knabbert und klopft mit dem Hinterlauf, wenn der Held kommt. Die Hühner haben ihre
Laute seit 83c (huehner.py). Alle CC0 (QUELLEN.md, 401).

    python3 tools/klang/dorftiere.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben zum Anhören
    python3 tools/klang/dorftiere.py <ordner mit den Aufnahmen> --spiel    # nach app/src/main/assets/sfx (goat_*, rabbit_*)

Aufnahmen (tools/klang/holen.sh): BigSoundBank (Joseph Sardin, CC0) 0279/0280 „Bleating goat #1/#2“, 1380/1381 „Goat #1/#2“,
0990 „Horse eating grass #2“, 1376 „Bunny hutch“, 0185 „Rat nibbling“.
"""
import sys, os, subprocess
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)
L = lambda n: load(os.path.join(D, f"bsb_{n}.mp3"))

def win(x, a, b, fi=0.02, fo=0.10): return cut(x, a, b, fi, fo)
# draußen im Dorf wie die Hühner: etwas Abstand, wenig Hall, nichts Hartes oben
def yard(x, hz=7000, wet=0.12, seed=1): return reverb(lowpass(highpass(x, 180, 2), hz, 2), wet, 0.6, seed=seed)

S = {}
# Meckern: vier Ziegen, je ein Ruf
S["goat_bleat"] = [yard(win(L("0279"), 0.16, 1.00)), yard(win(L("0280"), 0.18, 0.90), seed=2),
                   yard(win(L("1380"), 0.00, 1.22), seed=3), yard(win(L("1381"), 0.00, 1.45), seed=4)]
# Grasrupfen und Kauen: ein Pferd, ein wenig höher und dunkler (kleineres Maul, weiter weg)
graze = L("0990")
def rupf(a, b, seed): return yard(lowpass(pitch(win(graze, a, b, 0.03, 0.15), 3), 5000, 2), 6000, 0.10, seed)
S["goat_graze"] = [rupf(1.62, 2.90, 1), rupf(3.20, 4.20, 2), rupf(5.18, 6.35, 3)]
# Knabbern: eine Ratte am Korn, dunkler und leiser (Gras statt Korn)
nib = L("0185")
def knabber(a, b, seed): return yard(lowpass(win(nib, a, b, 0.02, 0.10), 3500, 2), 5000, 0.08, seed)
S["rabbit_munch"] = [knabber(9.45, 11.95, 1), knabber(24.75, 26.70, 2), knabber(29.45, 30.15, 3)]
# Klopfen: die tiefsten Tritte aus dem Stall, nur der dumpfe Schlag auf den Boden (ohne das Klappern des Stalls)
hutch = L("1376")
def tritt(t, seed): return yard(lowpass(win(hutch, t - 0.02, t + 0.30, 0.002, 0.12), 1200, 4), 3000, 0.06, seed)
S["rabbit_thump"] = [tritt(53.08, 1), tritt(45.10, 2), tritt(7.04, 3), tritt(60.40, 4)]

LEISE = {"goat_graze": -30, "rabbit_munch": -32, "rabbit_thump": -26}
def finish(name, x): return norm(trim(x, -55), -1.0, LEISE.get(name, -22))

if OUT == "--spiel":
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(name, x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(sfx, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Tierlaute nach", os.path.normpath(sfx)); sys.exit(0)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(name, x))
print("Proben:", OUT)
