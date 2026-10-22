"""
Klanglogo Endrunde (292.1, Chef 22.10., 16:42: „292.1 in der Endrunde sind 4,5,7,9,12,13,15 und 23.“): die acht
gewählten Proben aus Runde 4 unverändert, jede zweimal hintereinander, damit sich das Motiv einprägt. Nummern wie in
Runde 4. Nur echte Instrumente aus VSCO 2 CE (CC0 1.0, github.com/sgossner/VSCO-2-CE).

    python3 tools/klang/klanglogo5.py <ziel> --vsco <ordner der Bibliothek>
      → end_04.mp3 … end_23.mp3, probe_endrunde.mp3 (je Probe zweimal, 0,8 s Pause, 2 s bis zur nächsten)
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from klang import *
import klanglogo4 as R4

ENDRUNDE = [4, 5, 7, 9, 12, 13, 15, 23]

if __name__ == "__main__":
    OUT = sys.argv[1]; os.makedirs(OUT, exist_ok=True)
    R4.V["dir"] = sys.argv[sys.argv.index("--vsco") + 1]
    kurz, lang = np.zeros(int(0.8 * SR)), np.zeros(int(2.0 * SR)); seq = []
    for nr, fam, text, fn in R4.P:
        if nr not in ENDRUNDE: continue
        x = fn(); f = os.path.join(OUT, f"end_{nr:02d}.wav"); write(f, x)
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", f, "-b:a", "160k", f[:-4] + ".mp3"], check=True)
        os.remove(f)
        print(f"{nr:2d} {fam} {len(x) / SR:.1f} s  bei {sum(len(s) for s in seq) / SR:.1f} s  {text}", flush=True)
        seq += [x, kurz, x, lang]
    import soundfile as sf
    tmp = os.path.join(OUT, "_probe.wav"); sf.write(tmp, np.clip(np.concatenate(seq), -1, 1), SR, subtype="PCM_16")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-b:a", "160k", os.path.join(OUT, "probe_endrunde.mp3")], check=True)
    os.remove(tmp)
