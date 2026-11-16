"""
Klänge des Kerbensystems (1266; 1260 D, Chef 15.11., 10:07; DESIGN-GLUT.md 8 „Klang“): Holz und Klinge, kein Feuer (kein Knistern,
Fauchen, Zischen). Je drei Fassungen, der Systemklang der Goldkerbe einmal (DESIGN-STIL.md „Klang“). Quellen CC0 (QUELLEN.md):
rubberduck, „100 CC0 metal and wood SFX“ (wood_hit, wood_misc, wood_squeak, wood_close, tools), „80 CC0 RPG SFX“ (blade, item_wood),
„100 CC0 SFX“ (bell, wooden).

    python3 tools/klang/kerben.py <ordner mit den drei Paketen entpackt> <ziel>    # Hörprobe als WAV
    python3 tools/klang/kerben.py <ordner> --spiel                                 # nach godot/daten/klang/sfx

Die Pakete: https://opengameart.org/sites/default/files/100-CC0-wood-metal-SFX.zip, 80-CC0-RPG-SFX_0.zip, 100-CC0-SFX_0.zip
(tools/klang/holen.sh), entpackt in Unterordner gleichen Namens ohne .zip oder alle in einen Ordner.

- kerbe: eine Tat schlägt eine Kerbe: trockener Schnitt in Holz, der Biss der Klinge (kurzer heller Anriss aus „tools“) und der
  harte Holzschlag gleich danach; ohne Hall, kurz.
- kerbe_tief: Vertiefen: derselbe Schnitt tiefer gestimmt, mit Körper und einem zweiten Nachsetzen.
- kerbe_antwort: die Haltung antwortet: ein heller Schlag, Holz mit Klingenkante.
- kerbe_verstreichen: ungeschlagene Kerben verstreichen mit dem Zug (1265): leise, weich, Holz, das sich setzt.
- kerbe_gold: die Goldkerbe entsteht: Systemklang, eine kleine Glocke tief gestimmt über einem weichen Holzschlag.
- haltung_klinge, haltung_sehne, haltung_schild: Haltung setzen: Klinge in Stellung, Sehne gespannt (Holz knarrt unter Zug),
  Schild hoch (Holz und Leder).
- ring_daneben: der Ring geht daneben: ein dumpfer Treffer (tiefes Holz, Höhen weg).
"""
import sys, os, subprocess, glob, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)


def a(name, semis=0):
    """Aufnahme [name] (ohne Endung) aus einem der Pakete, beschnitten, gestimmt."""
    f = sorted(glob.glob(os.path.join(D, "**", name + ".ogg"), recursive=True))
    if not f:
        raise SystemExit("fehlt: " + name)
    return pitch(trim(load(f[0])), semis)


def kurz(x, s):
    return cut(x, 0, min(len(x) / SR, s), 0.001, min(0.04, s * 0.4))


def schnitt(biss, schlag, sb, ss, g_biss=0.45, seed=1):
    """Kerbe: Biss der Klinge [biss] (die ersten 70 ms), gleich darauf der Holzschlag [schlag]; Tiefen leicht gedämpft (kein Rumpeln)."""
    b = highpass(kurz(a(biss, sb), 0.07), 1800)
    h = highpass(kurz(a(schlag, ss), 0.22), 160)
    return norm(reverb(mix((b, 0.0, g_biss), (h, 0.006, 1.0)), 0.06, 0.25, 5000, seed), -1.0, -19)


def tief(biss, schlag, nach, sb, ss, seed=1):
    """Vertiefen: tiefer, mehr Körper, ein zweites kürzeres Nachsetzen."""
    b = highpass(kurz(a(biss, sb), 0.09), 1200)
    h = shelf_low(kurz(a(schlag, ss), 0.3), 3, 300)
    n = highpass(kurz(a(nach, ss + 1), 0.15), 200)
    return norm(reverb(mix((b, 0.0, 0.5), (h, 0.008, 1.0), (n, 0.11, 0.45)), 0.07, 0.3, 4500, seed), -1.0, -18)


def antwort(holz, kante, sh, sk, seed=1):
    k = highpass(kurz(a(kante, sk), 0.08), 2500)
    h = highpass(kurz(a(holz, sh), 0.2), 400)
    return norm(reverb(mix((h, 0.0, 1.0), (k, 0.0, 0.55)), 0.1, 0.35, 7000, seed), -1.0, -19)


def verstreichen(name, s, seed=1):
    x = lowpass(kurz(a(name, s), 0.35), 2200)
    x = x * np.linspace(1.0, 0.4, len(x))
    return norm(reverb(x, 0.12, 0.4, 2500, seed), -12.0, -31)


def gold():
    g = lowpass(kurz(a("bell_02", -7), 0.7), 6000)
    h = lowpass(kurz(a("wooden_01", -2), 0.25), 3000)
    return norm(reverb(mix((h, 0.0, 0.7), (g, 0.015, 0.8)), 0.2, 0.8, 5000, 3), -1.0, -21)


def klinge(name, s, seed=1):
    x = highpass(kurz(a(name, s), 0.3), 500)
    return norm(reverb(x, 0.08, 0.3, 6000, seed), -1.0, -22)


def sehne(name, s, dehnen, seed=1):
    x = a(name, s)
    x = cut(x, 0, min(len(x) / SR, 0.35 * dehnen), 0.02, 0.06)
    x = shelf_low(highpass(x, 250), 2, 400)
    return norm(reverb(x, 0.06, 0.3, 4000, seed), -1.0, -24)


def schild(holz, leder, sh, sl, seed=1):
    h = shelf_low(kurz(a(holz, sh), 0.25), 4, 250)
    l = lowpass(kurz(a(leder, sl), 0.2), 3500)
    return norm(reverb(mix((l, 0.0, 0.6), (h, 0.03, 1.0)), 0.08, 0.3, 4000, seed), -1.0, -20)


def daneben(name, s, seed=1):
    x = shelf_low(lowpass(kurz(a(name, s), 0.3), 900), 4, 180)
    return norm(reverb(x, 0.1, 0.35, 1500, seed), -1.0, -19)


S = {
    "kerbe": [schnitt("tools_07", "wood_hit_04", 0, 0, seed=1), schnitt("tools_08", "wood_hit_01", 1, -1, seed=2),
              schnitt("tools_12", "wood_hit_06", -1, 0, seed=3)],
    "kerbe_tief": [tief("tools_07", "wood_hit_03", "wood_hit_06", -2, -3, 1), tief("tools_08", "wood_hit_08", "wood_hit_01", -3, -3, 2),
                   tief("tools_12", "wood_hit_03", "wood_hit_04", -2, -4, 3)],
    "kerbe_antwort": [antwort("wood_01", "blade_01", 1, 2, 1), antwort("wood_04", "blade_03", 0, 1, 2),
                      antwort("wood_05", "blade_02", 1, 2, 3)],
    "kerbe_verstreichen": [verstreichen("wood_misc_05", -2, 1), verstreichen("item_wood_03", -3, 2), verstreichen("wood_misc_08", 0, 3)],
    "kerbe_gold": [gold()],
    "haltung_klinge": [klinge("blade_01", 0, 1), klinge("blade_02", -1, 2), klinge("blade_03", 0, 3)],
    "haltung_sehne": [sehne("wood_squeak_01", -3, 1.0, 1), sehne("wood_squeak_02", -4, 1.0, 2), sehne("wood_squeak_01", -5, 1.1, 3)],
    "haltung_schild": [schild("wood_close_01", "item_wood_02", -2, 0, 1), schild("wood_close_02", "item_wood_01", -3, -1, 2),
                       schild("wood_hammer_02", "item_wood_02", -1, -2, 3)],
    "ring_daneben": [daneben("wood_hit_05", -2, 1), daneben("wood_hit_07", -2, 2), daneben("wood_hit_09", -3, 3)],
}

if OUT == "--spiel":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "godot", "daten", "klang", "sfx")
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(out, "_tmp.wav"); write(tmp, x)
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(out, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
            print(f"{name}_{i + 1}: {len(x) / SR:.2f} s")
    print("fertig:", os.path.normpath(out))
else:
    for name, takes in S.items():
        for i, x in enumerate(takes): write(os.path.join(OUT, f"{name}_{i + 1}.wav"), x)
    print("fertig:", OUT)
