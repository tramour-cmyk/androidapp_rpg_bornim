"""
Hörproben der Stimmen der übrigen Gegner (18): Angriff, Schmerz, Tod, je drei Fassungen, aus CC0-Aufnahmen
(QUELLEN.md, „Gegnerstimmen“). Noch nicht im Spiel; ins Spiel erst nach Wahl des Nutzers.

    python3 tools/klang/stimmen.py <ordner mit den Aufnahmen> <ziel>              # alle Gegner
    python3 tools/klang/stimmen.py <ordner> <ziel> --nur bugbear,boar             # nur diese

Je Gegner WAV-Dateien <gegner>_<ruf>_<n>.wav und eine Probe probe_<gegner>.mp3 (Angriff 1–3, Schmerz 1–3, Tod 1–3,
mit Pausen dazwischen). Aufnahmen: tools/klang/holen.sh („Gegnerstimmen“).
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
NUR = sys.argv[sys.argv.index("--nur") + 1].split(",") if "--nur" in sys.argv else None
os.makedirs(OUT, exist_ok=True)

_index = {}
for root, _, fs in os.walk(D):
    for f in fs:
        if "__MACOSX" not in root: _index.setdefault(f, []).append(os.path.join(root, f))
_cache = {}
def L(name):
    if name not in _cache: _cache[name] = load(_index[name][0])
    return _cache[name]
def B(n, a=None, b=None, fo=0.04):
    """BigSoundBank-Aufnahme n, ganz oder als Ausschnitt a–b (s)."""
    x = L(f"bsb_{n}.mp3")
    return trim(x) if a is None else cut(x, a, b, 0.004, fo)
def T(f): return trim(L(f))
def grit(x, k=3.0, wet=0.45): return x * (1 - wet) + np.tanh(k * x / max(1e-9, np.max(np.abs(x)))) * np.max(np.abs(x)) * wet
def tail(x, fo): return cut(x, 0, None, 0.004, fo)                  # weich ausklingen lassen
def cave(x, wet=0.16, decay=0.8, seed=1): return reverb(highpass(x, 60), wet, decay, seed=seed)
def fall(n, g=0.8): return (shelf_low(B(n), 3), g)                  # Körper fällt (BigSoundBank Body Fall)
def lay(*parts):
    """parts: (signal, start_s, gain) oder ((signal, gain), start_s)"""
    return mix(*[(p[0][0], p[1], p[0][1]) if isinstance(p[0], tuple) else p for p in parts])

S = {}
# Krogg (Grottenschrat, Vorboss der Höhle): groß und schwer, tief und rau; Brüllen, Grunzen, Röcheln
S["bugbear"] = {
    "angriff": [cave(grit(pitch(T("troll_01.ogg"), -5))), cave(grit(pitch(T("roar_02.ogg"), -4)), seed=2),
                cave(grit(tail(pitch(B("0486", 5.72, 6.50), -4), 0.15)), seed=3)],
    "schmerz": [cave(grit(pitch(B("0486", 0.06, 0.73), -4))), cave(grit(pitch(T("troll_03.ogg"), -4)), seed=2),
                cave(grit(pitch(T("grunt_02.ogg"), -3)), seed=3)],
    "tod": [cave(lay((tail(grit(pitch(T("monster_04.ogg"), -2)), 0.4), 0, 1.0), (fall("2454"), 0.95)), 0.2, 1.0),
            cave(lay((tail(grit(pitch(T("monster_07.ogg"), -3)), 0.3), 0, 1.0), (fall("2452"), 0.85)), 0.2, 1.0, seed=2),
            cave(lay((tail(pitch(B("0486", 8.35, 10.2), -5), 0.6), 0, 1.0), (fall("2456"), 1.3)), 0.2, 1.0, seed=3)],
}
# Grak (Hauptmann der Grottenkrieger): ein Krieger mit Stimme, kehlig, kürzer und härter als Krogg
S["hobgoblin_captain"] = {
    "angriff": [cave(grit(pitch(T("humanYell4.wav"), -3))), cave(grit(pitch(T("humanYell1.wav"), -4)), seed=2),
                cave(grit(pitch(T("humanYell2.wav"), -3)), seed=3)],
    "schmerz": [cave(grit(pitch(B("2361"), -3))), cave(grit(pitch(T("humanYell3.wav"), -3)), seed=2),
                cave(grit(pitch(T("hurt_04.ogg"), -2)), seed=3)],
    "tod": [cave(lay((tail(grit(pitch(T("humanDeath1.wav"), -3)), 0.3), 0, 1.0), (fall("2453"), 0.55)), 0.2, 1.0),
            cave(lay((tail(grit(pitch(T("humanDeath2.wav"), -4)), 0.3), 0, 1.0), (fall("2455"), 0.6)), 0.2, 1.0, seed=2),
            cave(lay((tail(grit(pitch(T("hurt_03.ogg"), -4)), 0.2), 0, 1.0), (lowpass(pitch(T("breath.ogg"), -5), 2500), 0.3, 0.6),
                     (fall("2454"), 0.7)), 0.2, 1.0, seed=3)],
}
# Keiler: Grunzen und Schnauben, dazu tiefes Knurren; Quieken bei Schmerz; im Tod ein letztes Grunzen und Röcheln
pig = lambda a, b, s: pitch(B("1659", a, b), s)
S["boar"] = {
    "angriff": [cave(pitch(B("1658", 0.61, 1.52), -3)), cave(lay((pig(1.96, 2.56, -4), 0, 1.0), (pitch(B("1886", 0.17, 0.9, 0.2), -8), 0.05, 0.6)), seed=2),
                cave(lay((pitch(B("1888", 0.11, 0.9, 0.25), -7), 0, 0.8), (pitch(B("1658", 1.74, 2.26), -3), 0.45, 1.0)), seed=3)],
    "schmerz": [cave(pig(2.91, 3.11, -1)), cave(grit(pitch(T("hurt_05.ogg"), -3)), seed=2),
                cave(lay((pitch(B("0459", 9.90, 10.0), -12), 0, 0.7), (pitch(B("1658", 0.07, 0.21), -2), 0.08, 1.0)), seed=3)],
    "tod": [cave(lay((tail(pig(5.42, 5.97, -5), 0.3), 0, 1.0), (fall("2454"), 0.6)), 0.2, 1.0),
            cave(lay((tail(pitch(B("1658", 2.63, 3.17), -5), 0.3), 0, 1.0), (pitch(B("3177", 0.25, 1.29, 0.4), -2), 0.45, 0.6),
                     (fall("2452"), 0.9)), 0.2, 1.0, seed=2),
            cave(lay((pig(0.07, 0.32, -3), 0, 1.0), (tail(lowpass(pitch(T("snore.ogg"), -5), 3000), 0.3), 0.3, 0.8), (fall("2456"), 0.75)), 0.2, 1.0, seed=3)],
}
# Riesenspinne: keine Stimme, sondern Fauchen, Klicken der Kiefer, Zischen; im Tod Knacken und ein nasses Zusammensacken
click = lambda f, s=-2: pitch(T(f), s)
S["giant_spider"] = {
    "angriff": [cave(lay((pitch(B("1881"), -3), 0, 1.0), (click("bug_02.ogg"), 0.05, 0.7))),
                cave(pitch(B("1882"), -5), seed=2),
                cave(lay((pitch(T("spit_02.ogg"), -2), 0, 1.0), (click("bug_04.ogg", -3), 0.3, 0.8)), seed=3)],
    "schmerz": [cave(lay((pitch(T("alien_03.ogg"), -3), 0, 0.8), (click("bug_01.ogg"), 0, 0.7))),
                cave(lay((click("bug_03.ogg", -4), 0, 1.0), (click("bug_03.ogg", -5), 0.12, 0.8)), seed=2),
                cave(pitch(B("1883"), -2), seed=3)],
    "tod": [cave(lay((B("1409"), 0, 0.8), (tail(pitch(B("1884"), -6), 0.4), 0.05, 1.0), (B("2583", 0.27, 1.10), 0.4, 0.7)), 0.2, 1.0),
            cave(lay((tail(pitch(T("burble_02.ogg"), -4), 0.2), 0, 1.0), (B("2594"), 0.25, 0.8), (click("bug_02.ogg", -6), 0.5, 0.5)), 0.2, 1.0, seed=2),
            cave(lay((click("bug_04.ogg", -5), 0, 0.8), (click("bug_01.ogg", -6), 0.2, 0.6), (click("bug_03.ogg", -7), 0.42, 0.45),
                     (B("2587", 0.17, 0.61), 0.55, 0.6)), 0.2, 1.0, seed=3)],
}
# Riesenfledermaus: echte Fledermausrufe, eine Oktave und mehr tiefer gestimmt (großes Tier); Schmerz schrill; Tod ein sinkendes Fiepen
bat = lambda a, b, s: lowpass(pitch(B("0458", a, b, 0.02), s - 6), 9000, 2)
S["giant_bat"] = {
    "angriff": [cave(tail(bat(9.10, 9.75, -5), 0.15)), cave(lowpass(pitch(T("alien_06.ogg"), -6), 9000, 2), seed=2), cave(lay((bat(1.80, 2.12, -6), 0, 1.0), (bat(3.05, 3.40, -6), 0.25, 0.8)), seed=3)],
    "schmerz": [cave(bat(3.05, 3.40, -3)), cave(pitch(B("0459", 2.15, 2.24), -9), seed=2), cave(pitch(T("alien_05.ogg"), -4), seed=3)],
    "tod": [cave(lay((tail(pitch(B("0459", 9.90, 10.0), -12), 0.1), 0, 1.0), (highpass(B("2455"), 200), 0.3, 0.35)), 0.2, 1.0),
            cave(lay((tail(bat(12.70, 13.65, -8), 0.4), 0, 1.0), (highpass(B("2453"), 200), 0.6, 0.3)), 0.2, 1.0, seed=2),
            cave(lay((pitch(T("alien_05.ogg"), -6), 0, 1.0), (tail(bat(11.0, 11.8, -9), 0.4), 0.2, 0.8)), 0.2, 1.0, seed=3)],
}
# Kobold: klein, kläffend und zischend (Igelruf als Grundlage, etwas tiefer); Tod ein Japsen und leiser Fall
hog = lambda a, b, s: pitch(B("0941", a, b), s)
S["kobold"] = {
    "angriff": [cave(hog(5.15, 5.83, -4)), cave(grit(pitch(T("misc_06.ogg"), -2)), seed=2), cave(hog(11.37, 11.90, -3), seed=3)],
    "schmerz": [cave(hog(4.54, 4.98, -2)), cave(grit(pitch(T("hurt_01.ogg"), -1)), seed=2), cave(grit(pitch(T("misc_01.ogg"), -2)), seed=3)],
    "tod": [cave(lay((tail(hog(9.81, 10.22, -5), 0.2), 0, 1.0), (fall("2455", 0.4), 0.35)), 0.2, 1.0),
            cave(lay((tail(pitch(T("weird_02.ogg"), -3), 0.15), 0, 1.0), (fall("2453", 0.35), 0.3)), 0.2, 1.0, seed=2),
            cave(lay((pitch(T("hurt_02.ogg"), -5), 0, 1.0), (pitch(B("1281"), 2), 0.25, 0.5), (fall("2454", 0.35), 0.45)), 0.2, 1.0, seed=3)],
}
# Riesenratte: Mausschreie und Siebenschläfer, fast eine Oktave tiefer (Ratte von Hundegröße); Biss mit Kauen
S["giant_rat"] = {
    "angriff": [cave(pitch(B("1073", 0.53, 1.09), -10)), cave(lay((pitch(B("1073", 2.46, 2.89), -11), 0, 1.0), (T("eat_02.ogg"), 0.3, 0.6)), seed=2),
                cave(pitch(B("0459", 3.57, 3.74), -12), seed=3)],
    "schmerz": [cave(pitch(B("0459", 0.59, 0.79), -10)), cave(pitch(B("0459", 4.83, 4.92), -11), seed=2), cave(pitch(B("1073", 0.10, 0.39), -10), seed=3)],
    "tod": [cave(lay((tail(pitch(B("0459", 9.90, 10.0), -14), 0.1), 0, 1.0), (fall("2455", 0.3), 0.3)), 0.2, 1.0),
            cave(tail(pitch(B("1073", 13.42, 13.99), -12), 0.3), 0.2, 1.0, seed=2),
            cave(lay((pitch(B("0459", 2.15, 2.24), -12), 0, 1.0), (pitch(B("0459", 6.35, 6.49), -14), 0.25, 0.6), (fall("2453", 0.3), 0.45)), 0.2, 1.0, seed=3)],
}
# Stirge (Blutsauger): Surren der Flügel (Fliegen, sehr tief), schrilles Fiepen, beim Angriff ein Saugen
buzz = lambda a, b, s=-12: cut(pitch(B("0822", a, b), s), 0, None, 0.05, 0.15)
S["stirge"] = {
    "angriff": [cave(lay((buzz(10.0, 10.5), 0, 0.8), (pitch(T("alien_01.ogg"), -2), 0.25, 1.0))),
                cave(lay((buzz(20.0, 20.5), 0, 0.7), (T("eat_01.ogg"), 0.3, 1.0)), seed=2),
                cave(lay((buzz(30.0, 30.4, -10), 0, 0.8), (pitch(T("alien_04.ogg"), -2), 0.2, 0.9)), seed=3)],
    "schmerz": [cave(pitch(T("alien_05.ogg"), -1)), cave(pitch(T("alien_02.ogg"), -1), seed=2), cave(pitch(B("0459", 0.59, 0.79), -3), seed=3)],
    "tod": [cave(lay((tail(pitch(B("0822", 40.0, 40.3), -14), 0.4), 0, 0.8), (pitch(T("alien_02.ogg"), -5), 0, 0.8), (B("2594"), 0.6, 0.6)), 0.2, 1.0),
            cave(lay((tail(pitch(T("alien_04.ogg"), -6), 0.2), 0, 1.0), (B("2587", 0.17, 0.61), 0.35, 0.5)), 0.2, 1.0, seed=2),
            cave(lay((tail(buzz(50.0, 50.6, -15), 0.4), 0, 0.8), (pitch(T("alien_01.ogg"), -5), 0.1, 0.7)), 0.2, 1.0, seed=3)],
}
# Riesenhundertfüßer: Klicken und Rasseln vieler Glieder, Zischen; im Tod zuckendes Klicken, das langsamer wird
def legs(f, n, step, s0, ds, g0=1.0):
    return lay(*[(pitch(T(f), s0 - k * ds), k * step * (1 + 0.15 * k), g0 * (0.85 ** k)) for k in range(n)])
S["giant_centipede"] = {
    "angriff": [cave(lay((legs("bug_02.ogg", 4, 0.07, -3, 0), 0, 1.0), (pitch(B("1882"), -3), 0.15, 0.6))),
                cave(lay((pitch(T("spit_01.ogg"), -3), 0, 1.0), (legs("bug_04.ogg", 3, 0.06, -4, 0), 0.1, 0.8)), seed=2),
                cave(lay((pitch(B("1881"), -4), 0, 0.8), (legs("bug_01.ogg", 5, 0.05, -2, 0), 0.0, 0.8)), seed=3)],
    "schmerz": [cave(legs("bug_03.ogg", 3, 0.05, -2, 0.5)), cave(lay((pitch(T("spit_03.ogg"), -3), 0, 1.0), (pitch(T("bug_01.ogg"), -3), 0.05, 0.8)), seed=2),
                cave(lay((B("1408"), 0, 0.6), (legs("bug_02.ogg", 2, 0.06, -3, 0), 0.03, 0.9)), seed=3)],
    "tod": [cave(lay((B("1409"), 0, 0.7), (legs("bug_02.ogg", 6, 0.12, -4, 0.6, 0.9), 0.1, 1.0)), 0.2, 1.0),
            cave(lay((B("2594"), 0, 0.7), (legs("bug_04.ogg", 5, 0.14, -5, 0.7, 0.8), 0.15, 1.0)), 0.2, 1.0, seed=2),
            cave(lay((tail(pitch(B("1883"), -7), 0.3), 0, 0.8), (legs("bug_01.ogg", 6, 0.1, -4, 0.5, 0.8), 0.1, 1.0)), 0.2, 1.0, seed=3)],
}
# Zombie: Stöhnen und Grollen aus einer toten Kehle (BigSoundBank Zombie 1–7, kaum verändert)
S["zombie"] = {
    "angriff": [cave(grit(B("2107", 0.03, 1.11))), cave(grit(tail(B("2110", 0.03, 1.40), 0.2)), seed=2), cave(grit(B("2108", 3.77, 4.99)), seed=3)],
    "schmerz": [cave(grit(B("2111"))), cave(grit(B("2108", 5.26, 5.76)), seed=2), cave(grit(B("2106", 2.65, 3.33)), seed=3)],
    "tod": [cave(lay((tail(grit(B("2109", 0.02, 1.9)), 0.6), 0, 1.0), (fall("2452"), 1.4)), 0.2, 1.0),
            cave(lay((tail(grit(B("2112")), 0.3), 0, 1.0), (fall("2456"), 0.7)), 0.2, 1.0, seed=2),
            cave(lay((tail(grit(pitch(B("2107", 7.94, 10.11), -1)), 0.6), 0, 1.0), (fall("2454"), 1.6)), 0.2, 1.0, seed=3)],
}
# Ghul: wie ein Zombie, aber gierig und schneller; kehliges Lachen, Fauchen, ein heiseres Kreischen
S["ghoul"] = {
    "angriff": [cave(grit(tail(pitch(B("0475", 0.07, 1.10), -4), 0.2))), cave(lay((pitch(B("1882"), -2), 0, 0.7), (grit(pitch(B("2106", 6.20, 7.55), 1)), 0.1, 1.0)), seed=2),
                cave(grit(pitch(T("weird_01.ogg"), -2)), seed=3)],
    "schmerz": [cave(grit(pitch(B("2106", 8.87, 9.38), 2))), cave(grit(tail(pitch(T("scream_01.ogg"), -4), 0.15)), seed=2), cave(pitch(B("1883"), -1), seed=3)],
    "tod": [cave(lay((tail(grit(pitch(B("2106", 10.65, 12.84), -2)), 0.6), 0, 1.0), (fall("2453"), 1.9)), 0.2, 1.0),
            cave(lay((tail(grit(pitch(B("0475", 1.60, 3.19), -6)), 0.6), 0, 1.0), (fall("2455"), 1.4)), 0.2, 1.0, seed=2),
            cave(lay((pitch(B("3177", 0.25, 1.29, 0.3), -3), 0, 0.9), (grit(pitch(T("zombieDeath3.wav"), -3)), 0.1, 0.9), (fall("2454"), 0.8)), 0.2, 1.0, seed=3)],
}
# Ockergallerte: kein Mund, keine Stimme; Schmatzen, Gluckern, Blubbern; im Tod zerfließt sie
S["ochre_jelly"] = {
    "angriff": [cave(lay((B("2587", 0.17, 0.61), 0, 1.0), (pitch(T("burble_01.ogg"), -4), 0.1, 0.8))),
                cave(lay((pitch(B("1280", 0.17, 0.82), -3), 0, 1.0), (B("2583", 0.27, 1.10), 0.15, 0.7)), seed=2),
                cave(lay((pitch(T("eat_04.ogg"), -5), 0, 1.0), (pitch(T("burble_02.ogg"), -5), 0.1, 0.8)), seed=3)],
    "schmerz": [cave(pitch(B("1281"), -2)), cave(B("2594"), seed=2), cave(pitch(T("burble_02.ogg"), -3), seed=3)],
    "tod": [cave(lay((tail(pitch(B("3177", 0.25, 2.37), -4), 0.5), 0, 1.0), (B("2583", 0.27, 1.10), 0.3, 0.6)), 0.25, 1.2),
            cave(lay((B("0334"), 0, 1.0), (tail(pitch(T("burble_01.ogg"), -7), 0.4), 0.4, 0.8)), 0.25, 1.2, seed=2),
            cave(lay((pitch(B("2587", 0.17, 0.61), -3), 0, 0.9), (tail(pitch(B("1280", 0.17, 1.45), -6), 0.4), 0.2, 1.0)), 0.25, 1.2, seed=3)],
}

RUFE = ["angriff", "schmerz", "tod"]
def finish(x): return norm(trim(highpass(x, 35), -55), -1.0, -17)

for mon, cues in S.items():
    if NUR and mon not in NUR: continue
    probe = []
    for cue in RUFE:
        for i, x in enumerate(cues[cue]):
            y = finish(x); write(os.path.join(OUT, f"{mon}_{cue}_{i + 1}.wav"), y)
            probe += [y, np.zeros(int(0.8 * SR))]
        probe.append(np.zeros(int(0.8 * SR)))
    tmp = os.path.join(OUT, f"_probe_{mon}.wav"); write(tmp, np.concatenate(probe))
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-c:a", "libmp3lame", "-q:a", "3", os.path.join(OUT, f"probe_{mon}.mp3")], check=True)
    os.remove(tmp)
print("Proben:", OUT)
