"""
Hörproben der Schritte je Untergrund (74): Gras, Erde/Weg, Pflaster, Holzdielen, Stein (Höhle), je drei Fassungen,
dazu je Untergrund ein Gang von acht Schritten zum Anhören. Alle CC0 (QUELLEN.md, Runde 5).

    python3 tools/klang/schritte.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben und die Gänge
    python3 tools/klang/schritte.py <ordner mit den Aufnahmen> --spiel    # alle fünf (Nutzer 14.10., 20:4x) nach app/src/main/assets/sfx

Aufnahmen: Kenney „Impact Sounds“ (footstep_grass/concrete/wood_00x.ogg), BigSoundBank 3202 und 0606 (Erde, Pflaster), alle CC0,
aus den Paketen, die tools/klang/holen.sh lädt.
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)
L = lambda f: trim(load(os.path.join(D, f)))

S = {}
# Gras: weich, die Höhen gedämpft
S["gras"] = [lowpass(pitch(L(f"footstep_grass_00{i}.ogg"), -1), 6000, 2) for i in (0, 2, 4)]
C = lambda f, t, d: trim(cut(load(os.path.join(D, f)), t - 0.02, t + d + 0.12))
# Erde und Weg (zweite Runde, Nutzer 14.10.: klang wie Pflaster): weiches Knirschen auf festgetretenem Boden mit wenig Kies,
# BigSoundBank „Footsteps on Gravels #3“, Höhen stark gedämpft und etwas tiefer, damit es nach Erde statt Kies klingt
S["erde"] = [lowpass(pitch(C("bsb_3202.mp3", t, 0.25), -2), 2800, 2) for t in (2.81, 3.46, 4.84)]
# Pflaster (zweite Runde: war sehr stumpf): Ledersohle auf Stein, hell und kurz mit kleinem Nachklang zwischen Häusern,
# BigSoundBank „Step, Shoe on Stone Staircase“
S["pflaster"] = [reverb(highpass(C("bsb_0606.mp3", t, 0.18), 90, 2), 0.08, 0.35, seed=k + 1) for k, t in enumerate((1.15, 9.85, 10.7))]
# Holzdielen in den Häusern: hohl, tiefer, mit dem kleinen Hall eines Raumes
S["holz"] = [reverb(highpass(pitch(L(f"footstep_wood_00{i}.ogg"), -1), 110, 2), 0.1, 0.4, seed=i + 1) for i in (0, 2, 3)]
# Stein in der Höhle: tief, mit langem Nachhall
S["stein"] = [reverb(lowpass(pitch(L(f"footstep_concrete_00{i}.ogg"), -3), 4500, 2), 0.25, 0.9, seed=i + 1) for i in (1, 3, 4)]

def finish(x, rms=-24): return norm(trim(highpass(x, 40), -55), -1.0, rms)

# Gewählt vom Nutzer (74, 14.10., 20:4x): alle fünf Untergründe, je drei Fassungen
if OUT == "--spiel":
    import subprocess
    sfx = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    names = {"gras": "step_grass", "erde": "step_earth", "pflaster": "step_cobble", "holz": "step_wood", "stein": "step_stone"}
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(sfx, "_tmp.wav"); write(tmp, finish(x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(sfx, f"{names[name]}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
    print("Schritte nach", os.path.normpath(sfx)); sys.exit(0)
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
