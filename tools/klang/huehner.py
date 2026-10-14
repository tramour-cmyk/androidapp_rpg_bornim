"""
Hörproben der Hühner im Dorf (83c): Glucksen beim Picken, Scharren, aufgeregtes Gackern und Flügelschlag beim
Wegflattern. Alle CC0 (QUELLEN.md, Runde 5).

    python3 tools/klang/huehner.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben und eine Szene zum Anhören

Aufnahmen: BigSoundBank (Joseph Sardin, CC0) 1039 „Hens worried“, 0975 „Hen lays #1“, 1040 „Hen scared“,
0453 „Annoyed hen“, 0840 „Flight of a pigeon“, 2891/2894 „Flight bird“, 3202 (Schritte auf Erde, für das Scharren).
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
L = lambda n: load(os.path.join(D, f"bsb_{n}.mp3"))

def win(x, a, b, fi=0.02, fo=0.10): return cut(x, a, b, fi, fo)
# draußen im Dorf: etwas Abstand, wenig Hall, nichts Hartes oben
def yard(x, hz=7000, wet=0.12, seed=1): return reverb(lowpass(highpass(x, 180, 2), hz, 2), wet, 0.6, seed=seed)

worried, lays, scared, annoyed = L("1039"), L("0975"), L("1040"), L("0453")
S = {}
# leises Glucksen, ein paar Laute hintereinander (beim Picken und Scharren)
S["gluck"] = [yard(win(worried, 1.00, 2.65)), yard(win(worried, 3.20, 4.75), seed=2), yard(win(lays, 8.85, 11.40), seed=3)]
# aufgeregtes Gackern, wenn der Held kommt
S["gacker"] = [yard(win(scared, 0.08, 0.80)), yard(win(scared, 2.45, 3.05), seed=2), yard(win(scared, 5.15, 5.90), seed=3),
               yard(win(annoyed, 0.00, 0.80), seed=4)]
# Flügelschlag beim Auffliegen: eine echte Taube, dazu zwei Geräuschmacher-Aufnahmen; kleiner Vogel, also etwas höher
S["flattern"] = [yard(win(L("0840"), 0.05, 1.20), 9000), yard(pitch(win(L("2891"), 0.25, 1.70), 2), 9000, seed=2),
                 yard(pitch(win(L("2894"), 0.20, 1.40), 2), 9000, seed=3)]
# Scharren: kurze Schritte auf trockener Erde, höher und leiser, ein Rechen mit der Kralle
earth = L("3202")
def rake(a, b, seed): return yard(lowpass(highpass(pitch(win(earth, a, b, 0.005, 0.06), 5), 900, 2), 8000, 2), 9000, 0.08, seed)
S["scharren"] = [rake(0.14, 0.30, 1), rake(1.50, 1.68, 2), rake(9.58, 9.70, 3)]

def finish(x, rms=-22): return norm(trim(x, -55), -1.0, rms)
for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), finish(x, -26 if name == "scharren" else -22))

# Szene, 20 s: drei Hühner am Heuballen glucksen und scharren zu zufälligen Zeiten, bei 13 s kommt der Held:
# Gackern und Flügelschlag, danach Stille, bis das erste wieder leise gluckst
rnd = np.random.default_rng(5); n = int(20 * SR); out = np.zeros(n)
def put(x, t, g):
    i = int(t * SR); out[i:i + len(x)] += x[: max(0, n - i)] * g
t, last = 0.6, -1
while t < 12.5:
    kind = "gluck" if rnd.random() < 0.6 else "scharren"
    k = int(rnd.integers(len(S[kind])))
    if (kind, k) == last: continue
    put(finish(S[kind][k]), t, 0.35 + 0.3 * rnd.random()); last = (kind, k)
    t += 0.9 + rnd.random() * 1.8
put(finish(S["gacker"][0]), 13.0, 0.9); put(finish(S["flattern"][0]), 13.1, 0.7)
put(finish(S["gacker"][2]), 13.4, 0.7); put(finish(S["flattern"][1]), 13.5, 0.5)
put(finish(S["gacker"][3]), 14.1, 0.5)
put(finish(S["gluck"][1]), 18.2, 0.3)
write(os.path.join(OUT, "szene_huehner.wav"), norm(out, -1.0))
print("Proben:", OUT)
