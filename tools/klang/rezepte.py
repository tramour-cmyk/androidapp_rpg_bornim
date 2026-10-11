"""
Klänge aus CC0-Aufnahmen (Thema 18): schneiden, tiefer stimmen, filtern, Hall, Lautstärke angleichen.

    tools/klang/holen.sh <ordner>                      # Aufnahmen laden (einmal)
    python3 tools/klang/rezepte.py <ordner>            # Klänge fürs Spiel nach app/src/main/assets/sfx (OGG)
    python3 tools/klang/rezepte.py <ordner> --proben <ziel>   # alle Fassungen als WAV zum Anhören

Systemklänge (Stufenaufstieg, Klick, epische Beute) gibt es im Spiel nur einmal (STIL.md, Klang); welche Fassung,
steht in GEWAEHLT. Quellen und Lizenzen: QUELLEN.md.
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D = sys.argv[1]
_index = {}
for root, _, fs in os.walk(D):
    for f in fs: _index.setdefault(f, []).append(os.path.join(root, f))

def L(name, folder=None):
    """Eine Aufnahme nach Dateinamen (eindeutig; sonst mit Teil des Ordnernamens)."""
    hits = [p for p in _index.get(name, []) if "__MACOSX" not in p and (folder is None or folder in p)]
    if not hits: raise FileNotFoundError(name)
    if len({os.path.getsize(p) for p in hits}) > 1 and folder is None: raise ValueError(f"{name} mehrdeutig: {hits}")
    return load(hits[0])

def T(f, *a): return trim(L(f)) if not a else cut(L(f), *a)
def grit(x, k=3.0, wet=0.45): return x * (1 - wet) + np.tanh(k * x / max(1e-9, np.max(np.abs(x)))) * np.max(np.abs(x)) * wet
def darken(x, hz=5000): return lowpass(x, hz, 2)
def rattle(ids, step=0.045, g=1.0): return mix(*[(trim(L(f"{i}.ogg", "x_bones_rattle")), k * step, g) for k, i in enumerate(ids)])

S = {}
# ---- Runde 1 (Oberfläche und Welt)
S["click"] = [darken(T("beltHandle1.ogg", 0.06, 0.17), 6000), darken(T("bookPlace1.ogg", 0.035, 0.16), 5000), darken(T("metalClick.ogg", 0.075, 0.17), 6000)]
S["loot"] = [T("handleSmallLeather.ogg"), T("dropLeather.ogg"), mix((T("cloth1.ogg"), 0, 1.0), (darken(T("metalClick.ogg", 0.075, 0.2), 5000), 0.08, 0.5))]
S["loot_epic"] = [
    reverb(mix((pitch(T("impactBell_heavy_000.ogg"), -3), 0.05, 0.8), (T("dropLeather.ogg"), 0, 0.9)), 0.3, 1.6),
    reverb(mix((pitch(T("gong_01.ogg"), -5), 0.06, 0.7), (T("handleSmallLeather.ogg"), 0, 1.0)), 0.3, 1.8, seed=2),
    reverb(mix((T("chain_01.ogg"), 0, 0.8), (pitch(T("impactBell_heavy_002.ogg"), -5), 0.1, 0.8)), 0.3, 1.6, seed=3)]
S["coins"] = [T("handleCoins.ogg"), T("handleCoins2.ogg"), T("coin_drop.ogg", 0.42, 1.15)]
S["chest"] = [mix((T("metalLatch.ogg"), 0, 0.8), (darken(T("creak1.ogg"), 4500), 0.12, 0.9)),
    T("wooded_box_open.ogg"),
    mix((T("keyhole-lockbox-unlock-01.wav"), 0, 0.8), (darken(T("wood_squeak_01.ogg"), 5000), 0.25, 0.8))]
S["door"] = [reverb(T("qubodup-DoorOpen03.flac"), 0.15, 0.8), reverb(T("doorOpen_1.ogg"), 0.15, 0.8, seed=2), reverb(T("qubodup-DoorOpen07.flac"), 0.15, 0.8, seed=3)]
S["level_up"] = [
    reverb(mix((pitch(T("gong_01.ogg"), -7), 0, 1.0)), 0.45, 2.4),
    reverb(mix((pitch(T("impactBell_heavy_000.ogg"), -2), 0, 0.9), (pitch(T("gong_02.ogg"), -9), 0.0, 0.6)), 0.4, 2.2, seed=2),
    reverb(mix((pitch(T("gong_02.ogg"), -5), 0, 0.9), (pitch(T("impactBell_heavy_002.ogg"), -7), 0.25, 0.6)), 0.45, 2.4, seed=3)]
S["enemy_down"] = [
    reverb(mix((shelf_low(pitch(T("wet_towel_on_floor-01.flac"), -5), 4), 0, 1.0), (T("chain_01.ogg"), 0.03, 0.35)), 0.15, 0.7),
    reverb(mix((shelf_low(pitch(T("wet_towel_on_floor-05.flac"), -6), 4), 0, 1.0), (T("dropLeather.ogg"), 0.02, 0.6)), 0.15, 0.7, seed=2),
    reverb(mix((shelf_low(pitch(T("wet_towel_on_floor-07.flac"), -4), 4), 0, 1.0), (T("bfh1_wood_falling_02.ogg"), 0.12, 0.5)), 0.15, 0.7, seed=3)]
# ---- Monster-Laute
sad = lambda a, b: lowpass(cut(L("Sad Dog.wav"), a, b, 0.004, 0.06), 3800, 4)
S["monster_wolf_angriff"] = [reverb(pitch(T("dog-snarl.flac"), -2), 0.12, 0.6), reverb(pitch(T("dog-growl.flac"), -3), 0.12, 0.6, seed=2),
    reverb(pitch(T("dog-growl.ogg"), -2), 0.12, 0.6, seed=3)]
S["monster_wolf_schmerz"] = [reverb(pitch(sad(0.10, 0.42), -1), 0.12, 0.6), reverb(pitch(sad(2.83, 3.12), -1), 0.12, 0.6, seed=2),
    reverb(pitch(T("dog-frieda-grunt-96khz-01.flac"), -3), 0.12, 0.6, seed=3)]
S["monster_wolf_tod"] = [reverb(cut(pitch(sad(0.72, 1.62), -3), 0, None, 0.004, 0.5), 0.2, 1.0),
    reverb(cut(pitch(T("dog-grumble.flac"), -5), 0, None, 0.01, 0.4), 0.2, 1.0, seed=2),
    reverb(mix((cut(pitch(sad(3.15, 3.78), -3), 0, None, 0.004, 0.3), 0, 1.0), (darken(pitch(T("breath.ogg"), -4), 2500), 0.45, 0.5)), 0.2, 1.0, seed=3)]
S["monster_goblin_angriff"] = [reverb(grit(pitch(T("goblin-12.wav"), -3)), 0.12, 0.6), reverb(grit(pitch(T("zombieYell1.wav"), 3)), 0.12, 0.6, seed=2),
    reverb(grit(pitch(T("goblin-3.wav"), -3)), 0.12, 0.6, seed=3)]
S["monster_goblin_schmerz"] = [reverb(grit(pitch(T("goblin-8.wav"), -2)), 0.12, 0.6), reverb(grit(pitch(T("goblin-1.wav"), -2)), 0.12, 0.6, seed=2),
    reverb(grit(pitch(T("goblin-10.wav"), -2)), 0.12, 0.6, seed=3)]
S["monster_goblin_tod"] = [reverb(grit(cut(pitch(T("goblin-15.wav"), -3), 0, None, 0.004, 0.2)), 0.18, 0.9),
    reverb(grit(pitch(T("zombieDeath1.wav"), 2)), 0.18, 0.9, seed=2), reverb(grit(cut(pitch(T("goblin-9.wav"), -4), 0, None, 0.004, 0.25)), 0.18, 0.9, seed=3)]
hiss = lambda: highpass(pitch(T("breath.ogg"), -4), 1200)
S["monster_skeleton_angriff"] = [
    reverb(mix((rattle([0, 2, 6, 9]), 0, 1.0), (pitch(T("wood_hit_01.ogg"), 5), 0.22, 0.6), (hiss(), 0.0, 0.35)), 0.15, 0.8),
    reverb(mix((rattle([1, 4, 8, 3, 5], 0.035), 0, 1.0), (hiss(), 0.05, 0.4)), 0.15, 0.8, seed=2),
    reverb(mix((pitch(T("wood_hit_03.ogg"), 4), 0, 0.6), (rattle([7, 2, 6], 0.05), 0.05, 1.0), (pitch(T("wood_hit_03.ogg"), 4), 0.24, 0.5)), 0.15, 0.8, seed=3)]
S["monster_skeleton_schmerz"] = [
    reverb(mix((T("wood_cracking_01.ogg"), 0, 0.8), (rattle([3, 7]), 0.05, 0.9)), 0.15, 0.8),
    reverb(mix((T("wood_cracking_02.ogg"), 0, 0.8), (rattle([0, 5]), 0.06, 0.9)), 0.15, 0.8, seed=2),
    reverb(mix((pitch(T("wood_hit_05.ogg"), 3), 0, 0.7), (rattle([9, 1, 6], 0.04), 0.03, 0.9)), 0.15, 0.8, seed=3)]
S["monster_skeleton_tod"] = [
    reverb(mix((rattle([0, 2, 4, 6, 8], 0.05), 0, 0.9), (T("bfh1_wood_falling_01.ogg"), 0.18, 0.8)), 0.2, 1.0),
    reverb(mix((T("bfh1_wood_falling_02.ogg"), 0, 0.8), (rattle([1, 3, 5, 7, 9], 0.06), 0.12, 0.8), (shelf_low(pitch(T("wet_towel_on_floor-03.flac"), -5), 3), 0.5, 0.4)), 0.2, 1.0, seed=2),
    reverb(mix((T("wood_falling_01.ogg"), 0, 0.8), (rattle([2, 6, 0, 8], 0.07), 0.1, 0.8)), 0.2, 1.0, seed=3)]

# Systemklänge: nur diese Fassung kommt ins Spiel (Stufenaufstieg Nr. 1 gewählt vom Nutzer 11.10.)
GEWAEHLT = {"level_up": 0, "click": 1, "loot_epic": 0}

def finish(name, x):
    return norm(trim(highpass(x, 35), -55), -1.0, -20 if name == "click" else -17)

if "--proben" in sys.argv:
    out = sys.argv[sys.argv.index("--proben") + 1]; os.makedirs(out, exist_ok=True)
    for name, takes in S.items():
        for i, x in enumerate(takes): write(os.path.join(out, f"neu_{name}_{i + 1}.wav"), finish(name, x))
    print("Proben:", out)
else:
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    os.makedirs(out, exist_ok=True)
    for f in os.listdir(out):
        if f.endswith(".ogg"): os.remove(os.path.join(out, f))
    n = 0
    for name, takes in S.items():
        chosen = [takes[GEWAEHLT[name]]] if name in GEWAEHLT else takes
        for i, x in enumerate(chosen):
            tmp = os.path.join(out, "_tmp.wav"); write(tmp, finish(name, x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(out, f"{name.removeprefix('monster_')}_{i + 1}.ogg")], check=True)
            os.remove(tmp); n += 1
    print(f"{n} Klänge nach {os.path.normpath(out)}")
