"""
Klanglogo Runde 4 (292.1, Chef 22.10., 07:56: „20, 30 Hörproben, kurz und prägnant … mit so einem hellen Glockenton am
Schluss oder eine Kaskade“; Vorgaben Sokrates 07:58): 24 Proben in vier Familien zu je 6, je 1,5–3 s, 3–5 Töne, ein
Motiv zum Nachsummen, Schluss Glockenton oder Glockenkaskade (der goldene Draht). Für BornWire, kein Spielthema.
Nur echte Instrumente aus VS Chamber Orchestra 2 Community Edition (CC0 1.0, github.com/sgossner/VSCO-2-CE).

    python3 tools/klang/klanglogo4.py <ziel> --vsco <ordner der Bibliothek>
      → r4_01.wav … r4_24.wav (und .mp3), probe_runde4.mp3 (alle nacheinander, je 1,5 s Pause)

Familien: A schlicht (Harfe solo), B orchestral (tiefer Aufsatz, da-dum), C Glocke (Glockenspiel, wenig darunter),
D gemischt (Harfe steigt, Streicher tragen, Glocke schließt).
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from klang import *
import klanglogo as K
from klanglogo import S, V, hz, boah, tutti, schwellen, CB_G, VC_G, HN_D, HN_G, VA_D, VN, TIMP, BD, GL

# gemessene Tonhöhe je Aufnahme (die Dateinamen stimmen nicht immer)
HARFE = {48: ("Strings/Harp/KSHarp_C3_mf.wav", 130.8), 59: ("Strings/Harp/KSHarp_B3_mf.wav", 245.5),
         62: ("Strings/Harp/KSHarp_D4_mf.wav", 291.2), 65: ("Strings/Harp/KSHarp_F4_mf.wav", 349.0),
         69: ("Strings/Harp/KSHarp_A4_mf.wav", 437.8), 72: ("Strings/Harp/KSHarp_C5_mf.wav", 520.2),
         76: ("Strings/Harp/KSHarp_E5_mf.wav", 654.8), 79: ("Strings/Harp/KSHarp_G5_mf.wav", 781.8),
         83: ("Strings/Harp/KSHarp_B5_mf.wav", 983.2), 86: ("Strings/Harp/KSHarp_D6_mf.wav", 1170.0),
         89: ("Strings/Harp/KSHarp_F6_mf.wav", 1392.0), 93: ("Strings/Harp/KSHarp_A6_mf.wav", 1741.0),
         95: ("Strings/Harp/KSHarp_B6_mf.wav", 1963.5), 98: ("Strings/Harp/KSHarp_D7_f.wav", 2338.8)}
GLOCK = {84: ("Percussion/Glock/glock_medium_C5.wav", 1054.5), 91: ("Percussion/Glock/glock_medium_G5.wav", 1578.8),
         96: ("Percussion/Glock/glock_medium_C6.wav", 2111.5), 98: ("Percussion/Glock/glock_medium_G4.wav", 2346.2),
         103: ("Percussion/Glock/glock_medium_G6.wav", 3164.5)}

def nah(tab, n):
    return tab[min(tab, key=lambda k: abs(k - n))]

def harfe(n, d=1.6):
    f, h = nah(HARFE, n); return S(f, h, n, 0, d)

def glocke(n, d=1.8):
    f, h = nah(GLOCK, n); return S(f, h, n, 0, d)

def lauf(noten, t0, dt, g=0.6, d=1.6):
    """Harfe: Töne [noten] ab t0 im Abstand dt (oder Liste von Abständen)."""
    L = []; t = t0
    for i, n in enumerate(noten):
        L.append((harfe(n, d), t, g)); t += (dt[i] if i < len(dt) else 0) if isinstance(dt, (list, tuple)) else dt
    return L

def kaskade(noten, t0, dt=0.07, g=0.35, ab=0.85):
    """Glockenspiel: kurze Kette, jede weitere etwas leiser."""
    return [(glocke(n), t0 + i * dt, g * ab ** i) for i, n in enumerate(noten)]

def streich(n, d, t0, g, att=0.25):
    """Ein gehaltener Streicherton (Geigen, Bratschen, Celli oder Bass), schwillt in [att] s an."""
    if n >= 67: f, h = VN[min(VN, key=lambda k: abs(k - n))]
    elif n >= 60: f, h = VA_D, 289.0
    elif n >= 43: f, h = VC_G, 97.9
    else: f, h = CB_G, 48.8
    x = S(f, h, n)[:int(d * SR)].copy(); t = np.arange(len(x)) / SR
    x *= np.clip(t / att, 0, 1) ** 1.5; fo = int(min(0.3, d / 3) * SR); x[-fo:] *= np.linspace(1, 0, fo) ** 2
    return (x, t0, g)

def akkord(noten, d, t0, g=0.3, att=0.25):
    return [streich(n, d, t0, g, att) for n in noten]

def pauke(n, t0, g=1.0, d=0.7):
    return (S(TIMP, 122.1, n, 0, d), t0, g)

def ende(L, lang=2.4, wet=0.24, decay=1.5):
    """Hall, auf [lang] s, gleich laut (lautestes Fenster von 0,3 s), Stille vorn weg."""
    y = reverb(mix(*L), wet=wet, decay=decay, damp=5200, predelay=0.02)
    i = int(np.argmax(np.abs(y) > 0.02 * np.max(np.abs(y)))); y = y[i:i + int(lang * SR)].copy()
    fo = int(0.35 * SR); y[-fo:] *= np.linspace(1, 0, fo) ** 1.6
    y = highpass(y, 35, 2)
    w = int(0.3 * SR); rms = max(np.sqrt(np.mean(y[k:k + w] ** 2)) for k in range(0, max(1, len(y) - w), w // 4))
    y *= 0.16 / rms
    pk = np.max(np.abs(y))
    if pk > 0.89: y = np.tanh(y / 0.89 * 1.2) / np.tanh(1.2) * 0.89  # weich begrenzt statt leiser
    return y

# G-Dur; MIDI: G2=43 D3=50 G3=55 B3=59 D4=62 G4=67 A4=69 B4=71 C5=72 D5=74 E5=76 G5=79 A5=81 B5=83 D6=86 G6=91 B6=95 D7=98
P = []  # (Nummer, Familie, Halbsatz, Funktion)
def probe(fam, text):
    def reg(fn): P.append((len(P) + 1, fam, text, fn)); return fn
    return reg

# ---- A schlicht: Harfe solo, Glocke schließt
@probe("A", "Harfe G–D–G steigt, Glocke G")
def a1(): return ende(lauf([67, 74, 79], 0, 0.16) + kaskade([91], 0.40, g=0.45), 2.0)
@probe("A", "Harfe D–G–H–D, Glocke D hoch")
def a2(): return ende(lauf([74, 79, 83, 86], 0, 0.12) + kaskade([98], 0.42, g=0.4), 2.0)
@probe("A", "Harfe fällt und steigt: D–H–G … D, Glocke G")
def a3(): return ende(lauf([86, 83, 79, 86], 0, [0.11, 0.11, 0.24]) + kaskade([91], 0.50, g=0.42), 2.0)
@probe("A", "Harfe Quarte hoch, Quinte, Oktave: D–G–D–G, Glockenkette")
def a4(): return ende(lauf([62, 67, 74, 79], 0, 0.14) + kaskade([91, 95, 98], 0.46, g=0.38), 2.2)
@probe("A", "Harfe zwei Töne, Pause, ein Ton (da-da … daa), Glocke")
def a5(): return ende(lauf([74, 79, 86], 0, [0.13, 0.36]) + kaskade([98], 0.52, g=0.4), 2.1)
@probe("A", "Harfe C–E–G–C (C-Dur, heller), Glocke C")
def a6(): return ende(lauf([72, 76, 79, 84], 0, 0.12) + kaskade([96], 0.40, g=0.42), 2.0)

# ---- B orchestral: tiefer Aufsatz, da-dum, Glocke
@probe("B", "Boah, da (D) – dum (G), Streicher G-Dur, Glocke G")
def b1():
    L = boah() + tutti(0.6) + [pauke(50, K.DA, 0.9), pauke(43, K.DUM, 1.2), (S(BD, 61.9, 35, 0, 0.7), K.DUM, 0.45)]
    return ende(L + kaskade([91], K.DUM + 0.02, g=0.34), 2.4)
@probe("B", "Boah, dum allein, Glockenkette G–H–D")
def b2():
    L = boah() + tutti(0.7) + [pauke(43, K.DUM, 1.25), (S(BD, 61.9, 35, 0, 0.7), K.DUM, 0.5)]
    return ende(L + kaskade([91, 95, 98], K.DUM + 0.05, g=0.32), 2.5)
@probe("B", "Boah kurz, da-da-dum (D–D–G), Glocke")
def b3():
    L = boah(d=0.80) + tutti(0.5, start=0.74) + [pauke(50, 0.46, 0.7), pauke(50, 0.58, 0.75), pauke(43, 0.74, 1.2)]
    return ende(L + kaskade([98], 0.76, g=0.34), 2.3)
@probe("B", "Streicher steigen G–D–G als Crescendo, dum, Glocke G")
def b4():
    L = [streich(67, 0.30, 0.0, 0.35, 0.12), streich(74, 0.30, 0.26, 0.40, 0.10), (S(CB_G, 48.8, 43, 0, 0.6), 0.52, 0.5)]
    L += tutti(0.6, start=0.52, hoch=True) + [pauke(43, 0.52, 1.1)]
    return ende(L + kaskade([91], 0.55, g=0.34), 2.3)
@probe("B", "Boah, da-dum, Harfe rauscht hoch, Glocke D")
def b5():
    L = boah() + tutti(0.6) + [pauke(50, K.DA, 0.85), pauke(43, K.DUM, 1.2)]
    L += lauf([67, 71, 74, 79, 83, 86], K.DUM, 0.035, g=0.35, d=1.0)
    return ende(L + kaskade([98], K.DUM + 0.24, g=0.34), 2.5)
@probe("B", "Boah löst sich in Moll–Dur (B–H), dum, Glocke")
def b6():
    L = boah() + akkord([55, 58, 62], 0.5, 0.25, g=0.22, att=0.3) + tutti(0.6) + [pauke(43, K.DUM, 1.2)]
    return ende(L + kaskade([95, 98], K.DUM + 0.04, g=0.32), 2.5)

# ---- C Glocke: Glockenspiel vorn, wenig darunter
@probe("C", "Glocke G–D–G hoch, Harfe tief darunter")
def c1(): return ende(kaskade([91, 98, 103], 0, 0.16, g=0.42, ab=0.95) + lauf([43 + 12], 0, 0.1, g=0.5), 2.0)
@probe("C", "Glockenkaskade abwärts G–D–H–G, Ton G bleibt")
def c2(): return ende(kaskade([103, 98, 95, 91], 0, 0.09, g=0.40, ab=0.92) + [streich(55, 1.2, 0.0, 0.25, 0.08)], 2.0)
@probe("C", "Glocke D–G … G hoch (da-daa … ding)")
def c3(): return ende(kaskade([86, 91], 0, 0.15, g=0.42, ab=1.0) + kaskade([103], 0.55, g=0.36), 2.0)
@probe("C", "Glocke C–E–G–C, wie eine Uhr, sehr klar")
def c4(): return ende(kaskade([84, 88, 91, 96], 0, 0.14, g=0.42, ab=0.95), 2.0, wet=0.2)
@probe("C", "Glocke G–A–H … D, Streicher G darunter")
def c5(): return ende(kaskade([91, 93, 95], 0, 0.12, g=0.40, ab=1.0) + kaskade([98], 0.48, g=0.42) + [streich(67, 1.3, 0.0, 0.18, 0.4), streich(43, 1.3, 0.0, 0.3, 0.4)], 2.2)
@probe("C", "Pauke tief, dann Glockenkette steigt G–H–D–G")
def c6(): return ende([pauke(43, 0.0, 1.1)] + kaskade([91, 95, 98, 103], 0.18, 0.07, g=0.38, ab=0.93), 2.2)

# ---- D gemischt: Harfe steigt, Streicher tragen, Glocke schließt
@probe("D", "Harfe G–D–G, Streicher G-Dur setzen ein, Glocke")
def d1(): return ende(lauf([67, 74, 79], 0, 0.15) + akkord([43, 55, 62, 71], 1.3, 0.30, g=0.24, att=0.2) + kaskade([91], 0.32, g=0.38), 2.3)
@probe("D", "Harfe vier Töne, Celli tief, Glockenkette")
def d2(): return ende(lauf([62, 67, 71, 74], 0, 0.12) + [streich(43, 1.4, 0.0, 0.42, 0.35)] + kaskade([91, 95, 98], 0.40, g=0.34), 2.4)
@probe("D", "Streicher Brummen, Harfe D–G drüber, Pauke, Glocke")
def d3():
    L = [(schwellen(S(VC_G, 97.9, 43), 1.0), 0.0, 0.5)] + lauf([74, 79], 0.42, 0.18) + [pauke(43, 0.60, 1.0)]
    return ende(L + akkord([55, 62, 71], 0.8, 0.60, g=0.2, att=0.05) + kaskade([91], 0.62, g=0.36), 2.4)
@probe("D", "Harfe Arpeggio schnell, Streicher Schlag, Glocke D")
def d4():
    L = lauf([55, 62, 67, 71, 74, 79], 0, 0.05, g=0.5) + tutti(0.5, start=0.30) + [pauke(43, 0.30, 1.0)]
    return ende(L + kaskade([98], 0.32, g=0.34), 2.2)
@probe("D", "Harfe da-da-daa, Horn hält, Glocke G")
def d5():
    L = lauf([74, 74, 79], 0, [0.14, 0.14], g=0.6) + [(S(HN_D, 146.7, 50, 0, 1.2), 0.28, 0.4), (S(HN_G, 193.5, 55, 0, 1.2), 0.28, 0.3)]
    return ende(L + kaskade([91], 0.30, g=0.36), 2.3)
@probe("D", "Boah, Harfe G–D–G im da-dum, Glockenkette")
def d6():
    L = boah(d=0.72, horn=0.4) + lauf([67, 74, 79], 0.42, 0.13, g=0.55) + tutti(0.6, start=0.68) + [pauke(43, 0.68, 1.1)]
    return ende(L + kaskade([91, 98], 0.70, 0.09, g=0.34), 2.5)

if __name__ == "__main__":
    OUT = sys.argv[1]; os.makedirs(OUT, exist_ok=True)
    V["dir"] = sys.argv[sys.argv.index("--vsco") + 1]
    stille = np.zeros(int(1.5 * SR)); seq = []
    for nr, fam, text, fn in P:
        x = fn(); f = os.path.join(OUT, f"r4_{nr:02d}.wav"); write(f, x)
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", f, "-b:a", "160k", f[:-4] + ".mp3"], check=True)
        seq += [x, stille]; print(f"{nr:2d} {fam} {len(x) / SR:.1f} s  {text}", flush=True)
    import soundfile as sf
    tmp = os.path.join(OUT, "_probe.wav"); sf.write(tmp, np.clip(np.concatenate(seq), -1, 1), SR, subtype="PCM_16")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-b:a", "160k", os.path.join(OUT, "probe_runde4.mp3")], check=True)
    os.remove(tmp)
