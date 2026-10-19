"""
Kurzer Ruf zum goldenen Zeichen (134.3, zu 134.1): wer dem Helden Neues zu sagen hat, macht sich beim Herankommen
ohne Worte bemerkbar (DESIGN-STIL.md, Klang: keine erkennbare Sprache): ein Mann mit „Mhm!“, Räuspern oder fragendem
„Hm?“, eine Frau mit „Hm?“, „Hmm“ oder Räuspern, das Kind Pim mit „Psst“. Je drei Fassungen. Alle CC0 (QUELLEN.md,
„134.3 Ruf“), Freesound-Vorschau (holen.sh).

    python3 tools/klang/ruf.py <ordner mit den Aufnahmen> <ziel>     # Hörprobe: je Stimme die drei Fassungen mit Pause
    python3 tools/klang/ruf.py <ordner> --spiel                     # nach app/src/main/assets/sfx (hail_man_1–3, hail_woman_1–3, hail_child_1–3)

Die Zeiten stammen aus dem Pegelverlauf der Aufnahmen (klang.segments, −28 dB). Ohne Raum (wie die Hühner), Höhen leicht
gedämpft, alle auf denselben Pegel, damit keine Fassung heraussticht.
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)

def take(n, a, b, lp=7500):
    """Ein Laut aus Freesound-Aufnahme [n] von [a] bis [b] s."""
    return norm(highpass(lowpass(cut(load(os.path.join(D, f"fs_{n}.mp3")), a, b, 0.01, 0.06), lp, 2), 110), -4.0, -26)

S = {
    # Mann: geschlossener Ruf „Mhm!“ (ValentinPetiteau), Räuspern (magicjoshua), fragendes „Hm?“ (esperar)
    "hail_man": [take("557374", 0.30, 0.78), take("704174", 0.24, 0.68), take("170779", 0.0, 0.76)],
    # Frau: „Hm?“ und „Hmm“ (esperar), Räuspern (ZoshP)
    "hail_woman": [take("170768", 0.05, 0.68), take("170767", 0.84, 1.66), take("532425", 0.10, 0.62)],
    # Kind: „Psst“ (SkyRaeVoicing), drei Fassungen aus zwei Aufnahmen
    "hail_child": [take("363584", 0.12, 0.68, 9000), take("363585", 0.09, 0.68, 9000), take("363585", 0.97, 1.42, 9000)],
}

if OUT == "--spiel":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "app", "src", "main", "assets", "sfx")
    for name, takes in S.items():
        for i, x in enumerate(takes):
            tmp = os.path.join(out, "_tmp.wav"); write(tmp, x)
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-ac", "1", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "4",
                            "-map_metadata", "-1", os.path.join(out, f"{name}_{i + 1}.ogg")], check=True)
            os.remove(tmp)
            print(f"{name}_{i + 1}: {len(x) / SR:.2f} s")
    print("fertig:", os.path.normpath(out))
else:
    # je Stimme die drei Fassungen, 1,2 s Pause dazwischen, im Spiel etwa so laut wie zwei Felder entfernt (0,6)
    for name, takes in S.items():
        y = np.concatenate([np.concatenate([x * 0.6, np.zeros(int(1.2 * SR))]) for x in takes])
        write(os.path.join(OUT, f"probe_{name}.wav"), y)
    print("Proben:", OUT)
