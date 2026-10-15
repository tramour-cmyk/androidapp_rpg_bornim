"""
83c Scharren, zweiter Versuch (Nutzer 14.10., 23:2x: „Scharren passt nicht“): kurze Kratzer aus echten Aufnahmen statt
gepitchter Schritte. Alle CC0, BigSoundBank (Joseph Sardin): 0163 Strohbesen, 0137 Füße im Laub; zum Vergleich die
bisherige Fassung aus 3202 (Schritte auf Erde).

    python3 tools/klang/scharren.py <ordner mit bsb_0163.mp3, bsb_0137.mp3, bsb_3202.mp3> <ziel>   # Proben und Szenen
    python3 tools/klang/scharren.py <ordner> --spiel besen|laub                                    # gewählte Fassung ins Spiel
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
L = lambda n: load(os.path.join(D, f"bsb_{n}.mp3"))
def yard(x, hz=8000, wet=0.08, seed=1): return reverb(lowpass(highpass(x, 180, 2), hz, 2), wet, 0.6, seed=seed)
def finish(x, rms=-26): return norm(trim(x, -55), -1.0, rms)

# ein Huhn scharrt mit kurzen Rucken: zwei, drei Kratzer dicht hintereinander, klein und trocken, also etwas höher
def scrape(src, a, b, semis, hp, seed):
    return yard(lowpass(highpass(pitch(cut(src, a, b, 0.004, 0.05), semis), hp, 2), 7500, 2), 8500, 0.08, seed)
broom, leaves = L("0163"), L("0137")
S = {
    "besen": [scrape(broom, 2.00, 2.32, 3, 400, 1), scrape(broom, 2.73, 3.08, 4, 400, 2), scrape(broom, 3.67, 4.04, 3, 400, 3), scrape(broom, 8.28, 8.60, 4, 400, 4)],
    "laub": [scrape(leaves, 1.70, 2.14, 2, 300, 1), scrape(leaves, 3.53, 3.86, 2, 300, 2), scrape(leaves, 5.31, 5.61, 3, 300, 3)],
}
if os.path.exists(os.path.join(D, "bsb_3202.mp3")):
    earth = L("3202")
    def rake(a, b, seed): return yard(lowpass(highpass(pitch(cut(earth, a, b, 0.005, 0.06), 5), 900, 2), 8000, 2), 9000, 0.08, seed)
    S["bisher"] = [rake(0.14, 0.30, 1), rake(1.50, 1.68, 2), rake(9.58, 9.70, 3)]

if OUT == "--spiel":
    import subprocess
    pick = sys.argv[3]
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for f in os.listdir(sfx):
        if f.startswith("hen_scratch_"): os.remove(os.path.join(sfx, f))
    for i, x in enumerate(S[pick]):
        tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x))
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                        "-map_metadata", "-1", os.path.join(sfx, f"hen_scratch_{i + 1}.ogg")], check=True)
        os.remove(tmp)
    print("Scharren", pick, "nach", os.path.normpath(sfx)); sys.exit(0)

os.makedirs(OUT, exist_ok=True)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x))
    # 10 s: ein Huhn scharrt in kurzen Folgen, dazwischen Pausen
    rnd = np.random.default_rng(7); n = int(10 * SR); out = np.zeros(n); t = 0.5; last = -1
    while t < 9.0:
        for _ in range(int(rnd.integers(2, 4))):
            k = int(rnd.integers(len(takes)))
            if k == last: k = (k + 1) % len(takes)
            x = finish(takes[k]) * (0.5 + 0.3 * rnd.random()); i = int(t * SR); out[i:i + len(x)] += x[: max(0, n - i)]
            last = k; t += 0.22 + 0.12 * rnd.random()
        t += 0.8 + rnd.random() * 1.5
    write(os.path.join(OUT, f"szene_{name}.wav"), norm(out, -3.0))
print("Proben:", OUT)
