"""
Leerlauf-Laute der Monster auf der Karte (D3.9): was man von einem Tier hört, das noch nicht jagt. Schnüffeln, Grunzen,
Knochenklappern, Stöhnen, Blubbern; leise, ohne Hall (der Ort gibt ihn), je Familie drei Fassungen mit eigenem Charakter.
Alle CC0 (QUELLEN.md, „D3.9 Leerlauf-Laute“).

    python3 tools/klang/ruhe.py <ordner mit den Aufnahmen> <ziel>     # WAV-Proben und je Familie eine Probe probe_<familie>.mp3
    python3 tools/klang/ruhe.py <ordner mit den Aufnahmen> --spiel    # OGG nach app/src/main/assets/sfx (idle_<familie>_<n>.ogg)

Aufnahmen: tools/klang/holen.sh („D3.9 Leerlauf-Laute“).
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
SPIEL = OUT == "--spiel"
if SPIEL: OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
os.makedirs(OUT, exist_ok=True)

_index = {}
for root, _, fs in os.walk(D):
    for f in fs:
        if "__MACOSX" not in root: _index.setdefault(f, []).append(os.path.join(root, f))
_cache = {}
def L(name):
    if name not in _cache: _cache[name] = load(_index[name][0])
    return _cache[name]
def B(n, a=None, b=None, fo=0.06):
    """BigSoundBank-Aufnahme n, ganz oder als Ausschnitt a–b (s)."""
    x = L(f"bsb_{n}.mp3")
    return trim(x) if a is None else cut(x, a, b, 0.01, fo)
def T(f): return trim(L(f))
def lay(*parts):
    """parts: (signal, start_s, gain)"""
    return mix(*parts)
def soft(x, hz=6000): return lowpass(highpass(x, 80, 2), hz, 2)    # leise und etwas weg: oben weicher

S = {}
# Wolf: schnüffelt am Boden (zwei Züge), knurrt leise vor sich hin, schnaubt
S["wolf"] = [soft(lay((pitch(B("0784", 0.04, 0.36), -2), 0, 1.0), (pitch(B("0784", 1.40, 1.72), -3), 0.45, 0.8))),
             soft(pitch(T("dog-grumble.flac"), -3), 4000),
             soft(lay((pitch(T("nose.ogg"), -4), 0, 1.0), (pitch(T("breath.ogg"), -5), 0.25, 0.6)))]
# Keiler: drei verschiedene Grunzer echter Schweine, tiefer; der dritte zweimal
S["boar"] = [soft(pitch(B("1691"), -3)), soft(pitch(B("1692"), -4)),
             soft(lay((pitch(B("1693"), -3), 0, 1.0), (pitch(B("1693"), -4), 0.42, 0.7)))]
# Goblin: zieht die Nase hoch, grunzt, räuspert sich; keine Worte
S["goblin"] = [soft(pitch(B("1095", 7.90, 8.20), 3)), soft(pitch(T("grunt_01.ogg"), 2)), soft(pitch(T("cough_01.ogg"), 3), 5000)]
# Kobold: klein, schnauft und murrt (Igel, etwas tiefer), drei Stellen der Aufnahme mit eigenem Rhythmus
S["kobold"] = [soft(pitch(B("0941", 0.0, 1.20), -3)), soft(pitch(B("0941", 15.58, 16.60), -3)), soft(pitch(B("0941", 20.34, 21.26), -4))]
# Riesenratte: nagt (zwei Stellen), ein leises Fiepen, tief (Ratte von Hundegröße)
S["giant_rat"] = [soft(pitch(B("0185", 2.94, 3.54), -4)), soft(pitch(B("0185", 7.44, 7.84), -5)), soft(pitch(B("1073", 9.48, 9.96), -10), 4000)]
# Riesenfledermaus: Flügel und leises Zirpen, tief gestimmt
wings = lambda n, s: cut(pitch(B(n), s), 0, 0.7, 0.01, 0.25)
S["giant_bat"] = [soft(lay((wings("2892", -5), 0, 1.0), (pitch(B("0458", 9.96, 10.04), -8), 0.3, 0.5))),
                  soft(lay((pitch(B("0458", 11.34, 11.40), -7), 0, 0.8), (pitch(B("0458", 11.72, 11.80), -7), 0.35, 0.7)), 4000),
                  soft(wings("2893", -6))]
# Stirge: Surren der Flügel, sehr tief (Fliegen); kommt und geht
buzz = lambda a, b, s: cut(pitch(B("0822", a, b), s), 0, None, 0.12, 0.25)
S["stirge"] = [soft(buzz(3.66, 5.10, -12), 3000), soft(buzz(9.68, 9.98, -10), 3000), soft(buzz(0.14, 0.66, -11), 3000)]
# Riesenspinne: Beine tasten über Stein, ein Klicken der Kiefer
def taps(f, n, step, s0):
    return lay(*[(pitch(T(f), s0 - (k % 2)), k * step * (1 + 0.2 * (k % 3)), 0.9 ** k) for k in range(n)])
S["giant_spider"] = [soft(taps("bug_02.ogg", 3, 0.12, -6)), soft(pitch(T("bug_04.ogg"), -7)), soft(taps("bug_01.ogg", 2, 0.18, -5))]
# Riesenhundertfüßer: viele Glieder rascheln, schneller als die Spinne
S["giant_centipede"] = [soft(taps("bug_03.ogg", 6, 0.05, -4)), soft(taps("bug_02.ogg", 5, 0.06, -5)), soft(taps("bug_04.ogg", 6, 0.045, -6))]
# Skelett: Knochen klappern, wenn es sich regt; drei Folgen aus verschiedenen Klappern
def rattle(ks, step): return lay(*[(T(f"{k}.ogg"), i * step, 1.0 - 0.15 * i) for i, k in enumerate(ks)])
S["skeleton"] = [soft(rattle([0, 3, 6], 0.11)), soft(rattle([2, 5, 8, 1], 0.08)), soft(rattle([4, 9], 0.16))]
# Zombie: leises Stöhnen aus toter Kehle (drei Aufnahmen)
S["zombie"] = [soft(B("2106", 0.14, 0.80), 4000), soft(B("2108", 0.02, 1.10), 4000), soft(B("2107", 1.94, 3.06), 4000)]
# Ghul: schnuppert gierig, kaut, ein rasselnder Atem
S["ghoul"] = [soft(pitch(B("1095", 15.52, 15.80), -4)), soft(lay((pitch(T("eat_03.ogg"), -3), 0, 1.0), (pitch(T("eat_03.ogg"), -4), 0.28, 0.8))),
              soft(pitch(T("snore.ogg"), -3), 4000)]
# Ockergallerte: gluckert, blubbert
S["ochre_jelly"] = [soft(B("1280", 0.0, 1.0), 4000), soft(pitch(B("3176"), -2), 4000), soft(pitch(T("burble_01.ogg"), -6), 4000)]

def finish(x): return norm(trim(highpass(x, 35), -55), -1.0, -20)

for fam, takes in S.items():
    probe = []
    for i, x in enumerate(takes):
        y = finish(x)
        if SPIEL:
            tmp = os.path.join(OUT, "_tmp.wav"); write(tmp, y)
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(OUT, f"idle_{fam}_{i + 1}.ogg")], check=True)
            os.remove(tmp); continue
        write(os.path.join(OUT, f"idle_{fam}_{i + 1}.wav"), y)
        probe += [y, np.zeros(int(1.0 * SR))]
    if SPIEL: continue
    tmp = os.path.join(OUT, f"_probe_{fam}.wav"); write(tmp, np.concatenate(probe))
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-c:a", "libmp3lame", "-q:a", "3", os.path.join(OUT, f"probe_{fam}.mp3")], check=True)
    os.remove(tmp)
print("Leerlauf-Laute nach" if SPIEL else "Proben:", os.path.normpath(OUT))
