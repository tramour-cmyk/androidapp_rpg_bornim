"""
Hörproben der Schritte je Untergrund (74): Gras, Erde/Weg, Pflaster, Holzdielen, Stein (Höhle), je drei Fassungen,
dazu je Untergrund ein Gang von acht Schritten zum Anhören. Alle CC0 (QUELLEN.md, Runde 5).

    python3 tools/klang/schritte.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben und die Gänge

Aufnahmen: Kenney „Impact Sounds“ (footstep_grass/concrete/wood_00x.ogg) und „RPG Audio“ (footstep0x.ogg), beide CC0,
aus den Paketen, die tools/klang/holen.sh lädt.
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
L = lambda f: trim(load(os.path.join(D, f)))

S = {}
# Gras: weich, die Höhen gedämpft
S["gras"] = [lowpass(pitch(L(f"footstep_grass_00{i}.ogg"), -1), 6000, 2) for i in (0, 2, 4)]
# Erde und Weg: Stiefel auf festgetretenem Boden mit etwas Kies
S["erde"] = [lowpass(L(f"footstep0{i}.ogg"), 5500, 2) for i in (1, 4, 7)]
# Pflaster: hart, kurz, ein wenig dunkler
S["pflaster"] = [lowpass(pitch(L(f"footstep_concrete_00{i}.ogg"), -1), 6500, 2) for i in (0, 2, 4)]
# Holzdielen in den Häusern: hohl, tiefer, mit dem kleinen Hall eines Raumes
S["holz"] = [reverb(highpass(pitch(L(f"footstep_wood_00{i}.ogg"), -1), 110, 2), 0.1, 0.4, seed=i + 1) for i in (0, 2, 3)]
# Stein in der Höhle: tief, mit langem Nachhall
S["stein"] = [reverb(lowpass(pitch(L(f"footstep_concrete_00{i}.ogg"), -3), 4500, 2), 0.25, 0.9, seed=i + 1) for i in (1, 3, 4)]

def finish(x, rms=-24): return norm(trim(highpass(x, 40), -55), -1.0, rms)

for name, takes in S.items():
    for i, x in enumerate(takes): write(os.path.join(OUT, f"schritt_{name}_{i + 1}.wav"), finish(x))
    # ein Gang: acht Schritte im Gehtempo (0,48 s), die Fassungen wechseln, nie zweimal dieselbe hintereinander, leicht ungleich laut
    rnd = np.random.default_rng(3); n = int(4.6 * SR); out = np.zeros(n); last = -1; t = 0.2
    for k in range(8):
        j = rnd.integers(len(takes))
        while j == last: j = rnd.integers(len(takes))
        x = finish(takes[j]) * (0.8 + 0.2 * rnd.random()); i = int(t * SR); out[i:i + len(x)] += x[: n - i]; last = j
        t += 0.48 + (rnd.random() - 0.5) * 0.04
    write(os.path.join(OUT, f"gang_{name}.wav"), norm(out, -3.0))
print("Proben:", OUT)
