"""
Klänge aus CC0-Aufnahmen (Thema 18): schneiden, tiefer stimmen, filtern, Hall, Lautstärke angleichen.

    tools/klang/holen.sh <ordner>                      # Aufnahmen laden (einmal)
    python3 tools/klang/rezepte.py <ordner>            # Klänge fürs Spiel nach app/src/main/assets/sfx (OGG)
    python3 tools/klang/schleifen.py <ordner>          # danach: Feuerknistern als Schleifen (18k)
    python3 tools/klang/rezepte.py <ordner> --proben <ziel> [--nur a,b]   # Fassungen als WAV zum Anhören (--nur: nur diese Klänge)

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

# ---- Runde 2 (Welt, Zauber, Tränke, Umgebung): erst Hörproben, ins Spiel erst nach Wahl des Nutzers (R2_FREI)
R2_START = len(S)
def win(f, a, b, fo=0.25): return cut(L(f), a, b, 0.08, fo)          # Ausschnitt aus einer langen Aufnahme, weich ein und aus
def far(x, hz=3500, wet=0.3, decay=1.2, seed=1): return reverb(lowpass(x, hz, 2), wet, decay, seed=seed)   # aus der Ferne
cave = lambda x, seed=1: reverb(x, 0.45, 1.8, 3500, seed)
# Kampfbeginn (Systemklang, eine Fassung wird gewählt): Klinge aus der Scheide, darunter ein tiefer Schlag
S["encounter"] = [
    reverb(mix((T("drawKnife1.ogg"), 0, 0.9), (shelf_low(pitch(T("gong_01.ogg"), -12), 4), 0.05, 0.8)), 0.3, 1.6),
    reverb(mix((shelf_low(pitch(T("impactMetal_heavy_000.ogg"), -5), 3), 0, 0.9), (T("drawKnife2.ogg"), 0.18, 0.8), (pitch(T("impactWood_heavy_001.ogg"), -6), 0, 0.6)), 0.3, 1.4, seed=2),
    reverb(mix((T("drawKnife3.ogg"), 0, 0.8), (pitch(T("impactBell_heavy_003.ogg"), -10), 0.08, 0.8), (T("chain_02.ogg"), 0.1, 0.3)), 0.35, 1.8, seed=3)]
# Ein Gegner bemerkt den Helden: ein Zweig knackt, Schritte stocken, Steinchen rollen
S["alert"] = [
    reverb(mix((T("wood_cracking_03.ogg"), 0, 0.9), (darken(T("cloth2.ogg"), 4000), 0.15, 0.5)), 0.15, 0.8),
    reverb(mix((T("footstep_grass_000.ogg"), 0, 0.7), (T("footstep_grass_003.ogg"), 0.2, 0.5), (T("drawKnife2.ogg"), 0.45, 0.6)), 0.15, 0.8, seed=2),
    reverb(darken(T("stones_01.ogg"), 5000), 0.2, 1.0, seed=3)]
# Hinterhalt: es bricht durchs Gebüsch, ein Satz, Stahl
S["ambush"] = [
    reverb(mix((T("bfh1_wood_breaking_01.ogg"), 0, 0.8), (T("drawKnife1.ogg"), 0.2, 0.8), (pitch(T("impactPunch_heavy_000.ogg"), -3), 0.35, 0.6)), 0.15, 0.8),
    reverb(mix((T("footstep_grass_001.ogg"), 0, 0.7), (T("footstep_grass_002.ogg"), 0.11, 0.7), (T("footstep_grass_004.ogg"), 0.21, 0.8), (T("metal_hit_02.ogg"), 0.33, 0.6)), 0.15, 0.8, seed=2),
    reverb(mix((T("wood_breaking_02.ogg"), 0, 0.7), (grit(pitch(T("creature_roar_01.ogg"), -4)), 0.12, 0.6)), 0.2, 1.0, seed=3)]
# Der Held fällt (Umwelt im Kampf, drei Fassungen; 18f): Laut, Körper auf dem Boden, die Waffe fällt; Nr. 3 ohne Stimme (passt zu jedem Helden)
S["hero_down"] = [
    reverb(mix((T("humanDeath1.wav"), 0, 0.8), (shelf_low(pitch(T("wet_towel_on_floor-02.flac"), -5), 4), 0.35, 1.0), (T("bfh1_metal_falling_01.ogg"), 0.5, 0.5)), 0.3, 1.6),
    reverb(mix((pitch(T("humanDeath2.wav"), -2), 0, 0.8), (shelf_low(pitch(T("wet_towel_on_floor-04.flac"), -5), 4), 0.4, 1.0), (T("chain_03.ogg"), 0.45, 0.35)), 0.3, 1.6, seed=2),
    reverb(mix((shelf_low(pitch(T("wet_towel_on_floor-06.flac"), -6), 4), 0, 1.0), (T("bfh1_metal_falling_02.ogg"), 0.12, 0.6), (darken(pitch(T("breath.ogg"), -5), 2200), 0.5, 0.6)), 0.35, 1.8, seed=3)]
# Feuerzauber: Fauchen und Prasseln
S["fire"] = [
    reverb(mix((T("spell_fire_02.ogg"), 0, 1.0), (win("fs_181563.mp3", 3.0, 3.8), 0.2, 0.4)), 0.15, 0.8),
    reverb(mix((shelf_low(T("flame_0.ogg"), 3), 0, 1.0), (T("LEGIT_FIR_Fire_Staff 1-Audio.wav"), 0.02, 0.6)), 0.15, 0.8, seed=2),
    reverb(darken(T("spell_fire_05.ogg"), 6000), 0.2, 0.9, seed=3)]
# Arkane Magie (Geschosse, Rüstung, Lähmung, Fluch): Schimmern, dunkles Ziehen
S["magic"] = [reverb(T("magical_1_0.ogg"), 0.25, 1.2), reverb(darken(T("fout-02.flac"), 7000), 0.25, 1.2, seed=2),
    reverb(cut(pitch(T("qubodup-PowerDrain.flac"), -2), 0, 1.4, 0.005, 0.4), 0.25, 1.2, seed=3)]
# Heiliges (heilige Flamme, Wächter, Untote vertreiben): tiefe Glocke, ferner Gesang
S["holy"] = [
    reverb(mix((pitch(T("impactBell_heavy_001.ogg"), -7), 0, 0.9), (lowpass(win("ethereal_chant_Subclip 01_01.wav", 0, 1.8, 0.6), 3000), 0.05, 0.5)), 0.45, 2.2),
    reverb(mix((pitch(T("gong_02.ogg"), -3), 0, 0.8), (pitch(T("bell_01.ogg"), -5), 0.0, 0.5)), 0.4, 2.2, seed=2),
    reverb(mix((lowpass(win("ethereal_chant_Subclip 05_05.wav", 0, 2.2, 0.7), 3500), 0, 0.8), (pitch(T("magical_3.ogg"), -3), 0.1, 0.35)), 0.45, 2.2, seed=3)]
# Heilung: weiches Aufsteigen (drei Stellen einer Aufnahme)
S["heal"] = [reverb(win("healing.ogg", 11.4, 12.7, 0.4), 0.3, 1.6), reverb(win("healing.ogg", 14.4, 15.8, 0.4), 0.3, 1.6, seed=2),
    reverb(win("healing.ogg", 19.95, 21.6, 0.4), 0.3, 1.6, seed=3)]
# Stärkung (Segen): heller Schimmer über einer leisen Glocke
S["buff"] = [
    reverb(mix((T("magical_5.ogg"), 0, 0.9), (pitch(T("impactBell_heavy_004.ogg"), -9), 0.05, 0.5)), 0.35, 1.8),
    reverb(T("magical_7_0.ogg"), 0.3, 1.6, seed=2),
    reverb(mix((T("magical_6_0.ogg"), 0, 0.8), (lowpass(win("ethereal_chant_Subclip 08_08.wav", 0, 1.6, 0.6), 3000), 0.1, 0.4)), 0.35, 1.8, seed=3)]
# Gift und Säure: Blubbern, Zischen, Schleim
S["poison"] = [reverb(darken(T("burble_01.ogg"), 5000), 0.15, 0.8),
    reverb(mix((T("bubble_02.ogg"), 0, 0.8), (T("spit_01.ogg"), 0.15, 0.6)), 0.15, 0.8, seed=2),
    reverb(mix((T("slime_03.ogg"), 0, 0.8), (win("loop_bubbles_1.ogg", 0.5, 1.3, 0.3), 0.05, 0.5)), 0.15, 0.8, seed=3)]
# Trank: Korken, Glas, Flüssigkeit
S["potion"] = [
    mix((T("vial-glass-round-uncork-01.wav"), 0, 0.9), (T("bubble_03.ogg"), 0.35, 0.5)),
    mix((T("bottle-clay-uncork-02.wav"), 0, 0.9), (win("loop_water_01.ogg", 0.3, 1.0, 0.25), 0.3, 0.4)),
    mix((T("bottle-glass-uncork-03.wav"), 0, 0.9), (T("vial-glass-small-drop-02.wav"), 0.4, 0.5))]
# Wurf (Brandflasche, Weihwasser): Glas zerbricht
S["throw"] = [reverb(T("bfh1_glass_breaking_01.ogg"), 0.15, 0.8),
    reverb(mix((T("impactGlass_heavy_000.ogg"), 0, 0.8), (T("glass_02.ogg"), 0.03, 0.7)), 0.15, 0.8, seed=2),
    reverb(mix((T("bfh1_glass_breaking_04.ogg"), 0, 0.8), (trim(L("splash_02.ogg", "x_water-splash")), 0.05, 0.5)), 0.15, 0.8, seed=3)]
# Umgebung (leise, alle 5–13 s): Vögel am Tag, Grillen und Eule nachts, Tropfen und Knistern in der Höhle
# Vögel: echte Rufe (absteigende Pfiffe), das Brummen der Aufnahme unter 900 Hz weg
bird = lambda f, a, b: highpass(win(f, a, b), 900, 4)
S["bird"] = [far(bird("Forest Birds 1.wav", 0.8, 2.73), 12000, 0.2), far(bird("Forest Birds 4.wav", 0, 2.6), 12000, 0.2, seed=2),
    far(bird("Forest Birds 6.wav", 0, 1.73), 12000, 0.2, seed=3)]
# Grillen: nur das Zirpen, das Rauschen der Nacht darunter weg
cri = lambda f, a, b: highpass(win(f, a, b, 0.4), 2000, 4)
S["cricket"] = [far(cri("fs_522299.mp3", 1.0, 3.6), 7000, 0.15), far(cri("fs_522299.mp3", 7.0, 9.6), 7000, 0.15, seed=2),
    far(cri("cricketsounds090613.wav", 3.0, 5.2), 7000, 0.15, seed=3)]
S["owl"] = [far(win("fs_465697.mp3", 0.15, 4.2, 0.4), 2500, 0.35, 1.6), far(win("fs_558396.mp3", 0.6, 2.9, 0.4), 2500, 0.35, 1.6, seed=2),
    far(win("fs_558398.mp3", 1.4, 3.4, 0.4), 2500, 0.35, 1.6, seed=3)]
S["drip"] = [cave(win("atmosbasement.mp3_.flac", 1.1, 1.8, 0.1)), cave(win("fs_696438.mp3", 1.3, 1.7, 0.1), 2),
    cave(mix((T("fs_348022.mp3"), 0, 0.9), (pitch(T("fs_349873.mp3"), -2), 0.9, 0.6)), 3)]
def even(x, k=4.0): return np.tanh(k * x / max(1e-9, np.max(np.abs(x))))   # einzelne laute Knacker zähmen, damit das Prasseln hörbar bleibt
S["crackle"] = [even(win("fs_181563.mp3", 5.7, 8.2, 0.5)), even(win("fs_370938.mp3", 6.0, 8.5, 0.5)), win("fire-1.wav", 0.2, 2.7, 0.5)]
# Ersatz (18f): Magie 1 klang nach Harfe, Stärkung 2 nicht gut; je drei Vorschläge, einer wird gewählt
S["magic_ersatz"] = [reverb(darken(cut(T("fout-01.flac"), 0, 2.0, 0.005, 0.6), 6000), 0.25, 1.2),
    reverb(mix((darken(cut(T("ghostbreath.flac"), 0, 2.0, 0.1, 0.6), 4000), 0, 0.9), (cut(pitch(T("qubodup-PowerDrain.flac"), -5), 0, 1.2, 0.005, 0.5), 0.3, 0.5)), 0.3, 1.4, seed=2),
    reverb(lowpass(cut(T("fout-03.flac"), 0, 2.0, 0.005, 0.5), 4500, 2), 0.25, 1.2, seed=3)]
S["buff_ersatz"] = [
    reverb(mix((pitch(T("gong_02.ogg"), -8), 0, 0.7), (darken(cut(T("ghostbreath.flac"), 0, 1.6, 0.2, 0.5), 5000), 0.1, 0.6)), 0.35, 1.8),
    reverb(mix((lowpass(win("ethereal_chant_Subclip 13_13.wav", 0, 1.8, 0.6), 3000), 0, 0.8), (pitch(T("impactBell_heavy_004.ogg"), -5), 0.05, 0.6)), 0.4, 2.0, seed=2),
    reverb(mix((pitch(T("impactBell_heavy_002.ogg"), -9), 0, 0.8), (darken(T("cloth3.ogg"), 4000), 0.0, 0.5), (pitch(T("magical_6_0.ogg"), -5), 0.15, 0.3)), 0.4, 2.0, seed=3)]
# Gewählt (18g): Magie 1 durch Ersatz 2, Stärkung 2 durch Ersatz 2
S["magic"] = [S["magic_ersatz"][1]] + S["magic"][1:]
S["buff"] = [S["buff"][0], S["buff_ersatz"][1], S["buff"][2]]
R2 = list(S)[R2_START:]
R2_FREI = {"encounter", "alert", "ambush", "hero_down", "fire", "holy", "heal", "poison", "potion", "throw", "bird", "cricket", "owl", "drip", "magic", "buff"}   # gewählt (18f, 18g, 11.10.); nur diese kommen ins Spiel; Knistern seit 18k als Schleife aus schleifen.py

# Systemklänge: nur diese Fassung kommt ins Spiel (Stufenaufstieg Nr. 1 gewählt vom Nutzer 11.10., Kampfbeginn Nr. 3 18f)
GEWAEHLT = {"level_up": 0, "click": 1, "loot_epic": 0, "encounter": 2}   # Kampfbeginn neu 3 (18f)

def finish(name, x):
    return norm(trim(highpass(x, 35), -55), -1.0, -20 if name == "click" else -17)

if "--proben" in sys.argv:
    out = sys.argv[sys.argv.index("--proben") + 1]; os.makedirs(out, exist_ok=True)
    nur = sys.argv[sys.argv.index("--nur") + 1].split(",") if "--nur" in sys.argv else list(S)
    for name, takes in S.items():
        if name not in nur: continue
        for i, x in enumerate(takes): write(os.path.join(out, f"neu_{name}_{i + 1}.wav"), finish(name, x))
    print("Proben:", out)
else:
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    os.makedirs(out, exist_ok=True)
    for f in os.listdir(out):
        if f.endswith(".ogg"): os.remove(os.path.join(out, f))
    n = 0
    for name, takes in S.items():
        if name in R2 and name not in R2_FREI: continue
        chosen = [takes[GEWAEHLT[name]]] if name in GEWAEHLT else takes
        for i, x in enumerate(chosen):
            tmp = os.path.join(out, "_tmp.wav"); write(tmp, finish(name, x))
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(out, f"{name.removeprefix('monster_')}_{i + 1}.ogg")], check=True)
            os.remove(tmp); n += 1
    print(f"{n} Klänge nach {os.path.normpath(out)}")
