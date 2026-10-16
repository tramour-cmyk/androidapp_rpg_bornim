"""
Keuchen des Helden (95, zu 86.3; Nutzer 15.10., 16:5x: „Atem mit Anzeige … hört man nicht“): je drei Atemzüge
(laut aus, leiser ein) eines Mannes und einer Frau außer Atem, für Held und Heldin. Alle CC0 (QUELLEN.md, Runde 7):
BigSoundBank 1103 „Breathless Man“ und 1345 „Breathless Woman“ (Joseph Sardin).

    python3 tools/klang/atem.py <ordner mit bsb_1103.mp3, bsb_1345.mp3> <ziel>     # Hörprobe: 10 s Keuchen, die Pausen werden länger
    python3 tools/klang/atem.py <ordner> --spiel                                  # nach app/src/main/assets/sfx (pant_man_1–3, pant_woman_1–3)

Ein Atemzug reicht von einer Stille zur übernächsten (Ausatmen, dann Einatmen); die Zeiten stammen aus dem Pegelverlauf
der Aufnahme in 50-ms-Schritten. Das Spiel reiht sie aneinander (core/.../audio/Panting.kt).
"""
import sys, os, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *
D, OUT = sys.argv[1], sys.argv[2]
if OUT != "--spiel": os.makedirs(OUT, exist_ok=True)

def breath(n, a, b, lp):
    """Ein Atemzug aus BigSoundBank-Aufnahme [n] von [a] bis [b] s, Höhen leicht gedämpft, ohne Raum (draußen und drinnen)."""
    return norm(highpass(lowpass(cut(load(os.path.join(D, f"bsb_{n}.mp3")), a, b, 0.02, 0.08), lp, 2), 90), -3.0, -24)

S = {
    # Mann, Atemzug etwa 1,4 s
    "pant_man": [breath("1103", a, b, 7000) for a, b in ((1.35, 2.75), (8.30, 9.75), (12.55, 13.95))],
    # Frau, Atemzug etwa 1,6 s; die Aufnahme ist nah und laut, daher etwas mehr gedämpft
    "pant_woman": [breath("1345", a, b, 6000) for a, b in ((1.50, 3.05), (6.20, 7.80), (11.05, 12.75))],
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
    # wie im Spiel: erst Atemzug an Atemzug, dann werden die Pausen länger und das Keuchen leiser (Panting.kt)
    for name, takes in S.items():
        y, t, k = np.zeros(int(12 * SR)), 0.0, 0
        while t < 10.0:
            f = t / 10.0
            x = takes[k % 3] * (1.0 - 0.45 * f); k += 1
            i = int(t * SR); y[i:i + len(x)] += x[:len(y) - i]
            t += len(x) / SR + 1.4 * f
        write(os.path.join(OUT, f"probe_{name}.wav"), y)
    print("Proben:", OUT)
