"""
Klanglogo (292.1): Hörmarke zum Logo im Vorspann, ganz aus Synthese (keine fremde Aufnahme, anmeldbar).
Bild: Harfe steigt, tiefe Streicher fallen, beide treffen sich in warmem Zusammenklang (Goldkern),
heller Glockenton für den Draht. Höchstens 1,5 s. Drei Fassungen.

    python3 tools/klang/klanglogo.py <ziel>          # klanglogo_a.wav … _c.wav und probe_klanglogo.mp3
"""
import sys, os, subprocess, numpy as np
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__))); from klang import *

LEN = 1.5
def hz(n): return 440.0 * 2 ** ((n - 69) / 12)  # MIDI-Nummer
def t_(d): return np.arange(int(d * SR)) / SR

def harfe(n, d=1.2, hell=0.5, seed=0):
    """Gezupfte Saite (Karplus-Strong), weich gedämpft wie eine Harfe."""
    rng = np.random.default_rng(seed + n)
    L = max(2, int(round(SR / hz(n) - 0.5)))
    buf = list(lowpass(rng.uniform(-1, 1, L + 64), 1500 + 5000 * hell, 2)[64:])
    out = np.zeros(int(d * SR)); k = 0.996 + 0.003 * hell
    for i in range(len(out)):
        a = buf[i % L]; b = buf[(i + 1) % L]
        out[i] = a; buf[i % L] = k * 0.5 * (a + b)
    body = lowpass(out, 3200, 2) + 0.25 * highpass(out, 1800, 2) * hell
    env = np.minimum(1, t_(d) / 0.003)
    return body * env

def streicher(n0, n1, d, glide=(0.0, 1.0), att=0.12, rel=0.25, stimmen=5, hell=1400, vib=0.006, seed=0):
    """Streichergruppe: verstimmte Sägezähne mit Vibrato, Ton gleitet von n0 nach n1 im Zeitfenster glide (Anteil)."""
    rng = np.random.default_rng(seed)
    t = t_(d); u = np.clip((t / d - glide[0]) / max(1e-6, glide[1] - glide[0]), 0, 1)
    u = u * u * (3 - 2 * u)
    f = hz(n0) * (hz(n1) / hz(n0)) ** u
    y = np.zeros(len(t))
    for s in range(stimmen):
        det = 1 + rng.uniform(-0.004, 0.004)
        vr = 4.8 + rng.uniform(-0.6, 0.6); ph = rng.uniform(0, 2 * np.pi)
        ff = f * det * (1 + vib * np.minimum(1, t / 0.35) * np.sin(2 * np.pi * vr * t + ph))
        phase = np.cumsum(ff) / SR + rng.uniform()
        y += 2 * (phase % 1) - 1
    y = lowpass(y / stimmen, hell, 2)
    y = lowpass(y, hell * 2.2, 2) + 0.15 * highpass(y, 2500, 1)
    env = np.minimum(1, t / att) * np.minimum(1, (d - t) / rel)
    return y * np.clip(env, 0, 1) ** 1.5

def horn(n, d, att=0.09, rel=0.35, seed=0):
    """Weiches Horn: obertonreich, stark gedämpft, langsames Aufblühen."""
    t = t_(d); rng = np.random.default_rng(seed)
    f = hz(n) * (1 + 0.003 * np.sin(2 * np.pi * 5.2 * t) * np.minimum(1, t / 0.4))
    ph = np.cumsum(f) / SR
    y = sum((0.75 ** k) * np.sin(2 * np.pi * (k + 1) * ph + rng.uniform(0, 6)) for k in range(8))
    bloom = np.minimum(1, t / 0.25)
    y = lowpass(y, 500 + 1300 * bloom.mean(), 2)
    env = np.minimum(1, t / att) * np.minimum(1, (d - t) / rel)
    return y * np.clip(env, 0, 1) ** 1.3

def glocke(n, d=1.3, hell=1.0):
    """Heller Glockenton (Celesta/kleine Glocke): unharmonische Teiltöne, kurzer Anschlag."""
    t = t_(d); f = hz(n)
    parts = [(1.0, 1.0, 1.4), (2.0, 0.45, 2.2), (2.76, 0.30, 3.0), (5.40, 0.16 * hell, 5.0), (8.93, 0.08 * hell, 8.0)]
    y = sum(a * np.sin(2 * np.pi * f * r * t) * np.exp(-k * t) for r, a, k in parts)
    return y * np.minimum(1, t / 0.0015)

def pauke(n, d=0.9):
    """Weiche Pauke mit Filzschlegel: tiefer Ton mit fallender Höhe, wenig Rauschen."""
    t = t_(d); f = hz(n) * (1 + 0.06 * np.exp(-t * 18))
    y = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 3.2)
    y += 0.3 * np.sin(2 * np.pi * np.cumsum(f * 1.5) / SR) * np.exp(-t * 6)
    y += 0.05 * lowpass(np.random.default_rng(3).standard_normal(len(t)), 600, 2) * np.exp(-t * 30)
    return y * np.minimum(1, t / 0.004)

def fertig(x, wet=0.30, decay=1.6):
    y = reverb(x, wet=wet, decay=decay, damp=5200, predelay=0.02)
    y = y[:int(LEN * SR)]
    fo = int(0.25 * SR); y[-fo:] *= np.linspace(1, 0, fo) ** 1.6
    return norm(highpass(y, 35, 2), peak_db=-1.0)

# D-Dur; MIDI: D2=38 A2=45 D3=50 F#3=54 A3=57 D4=62 E4=64 F#4=66 A4=69 D5=74 F#5=78 A5=81 D6=86
def fassung_a():
    """Goldkern: Harfe steigt D3–A4 in fünf Tönen, Celli fallen A3→D3, Treffpunkt 0,55 s D-Dur, Glocke D6."""
    L = []
    for i, n in enumerate([50, 54, 57, 62, 66, 69]): L.append((harfe(n, 1.1, 0.4 + 0.1 * i), 0.07 * i, 0.55))
    L.append((streicher(57, 50, 1.25, glide=(0.15, 0.45), att=0.10, rel=0.4, hell=1100), 0.0, 0.42))
    L.append((streicher(45, 38, 1.25, glide=(0.15, 0.45), att=0.12, rel=0.4, hell=700, seed=2), 0.0, 0.40))
    for n, g in [(62, 0.20), (66, 0.16), (69, 0.15), (74, 0.10)]:
        L.append((streicher(n, n, 0.95, att=0.16, rel=0.45, hell=2200, seed=n), 0.50, g))
    L.append((horn(57, 0.95), 0.50, 0.16)); L.append((horn(50, 0.95, seed=1), 0.50, 0.14))
    L.append((glocke(86, 0.95), 0.56, 0.30))
    return fertig(mix(*L))

def fassung_b():
    """Draht: Glocke zuerst (A5), dann rasch Harfe hoch und Bässe tief in Dsus4, löst nach D-Dur bei 0,6 s."""
    L = [(glocke(81, 1.4, 0.8), 0.0, 0.26)]
    for i, n in enumerate([57, 62, 64, 69, 74]): L.append((harfe(n, 1.0, 0.5 + 0.1 * i), 0.10 + 0.05 * i, 0.5))
    L.append((streicher(50, 38, 1.3, glide=(0.05, 0.35), att=0.08, rel=0.45, hell=800, seed=5), 0.10, 0.45))
    sus = [(62, 0.17), (67, 0.15), (69, 0.13)]
    for n, g in sus: L.append((streicher(n, n - 1 if n == 67 else n, 1.15, glide=(0.38, 0.52), att=0.12, rel=0.45, hell=2000, seed=n), 0.25, g))
    L.append((horn(54, 0.85, seed=2), 0.60, 0.15)); L.append((horn(50, 0.85, seed=3), 0.60, 0.13))
    L.append((pauke(38, 0.9), 0.60, 0.30))
    L.append((glocke(90, 0.85, 0.6), 0.62, 0.16))
    return fertig(mix(*L), wet=0.28)

def fassung_c():
    """Weite: Moll zu Dur (D-Moll-Harfe steigt, Bässe fallen), Treffpunkt D-Dur mit Hörnern und Pauke, Glocke F#6."""
    L = []
    for i, n in enumerate([50, 53, 57, 62, 65]):  # Moll-Töne klingen vor dem Dur-Treffpunkt aus (sonst F gegen F#)
        h = harfe(n, 0.55 - 0.08 * i + 0.12, 0.35 + 0.1 * i); h[-int(0.1 * SR):] *= np.linspace(1, 0, int(0.1 * SR)) ** 2
        L.append((h, 0.08 * i, 0.55))
    L.append((streicher(57, 50, 1.3, glide=(0.10, 0.42), att=0.10, rel=0.45, hell=900, seed=7), 0.0, 0.40))
    L.append((streicher(45, 38, 1.3, glide=(0.10, 0.42), att=0.12, rel=0.45, hell=600, seed=8), 0.0, 0.38))
    for n, g in [(57, 0.18), (62, 0.18), (66, 0.16), (69, 0.12)]:
        L.append((streicher(n, n, 1.0, att=0.10, rel=0.45, hell=2100, seed=n + 1), 0.45, g))
    L.append((horn(54, 1.0, seed=4), 0.45, 0.17)); L.append((horn(45, 1.0, seed=5), 0.45, 0.15))
    L.append((pauke(38, 1.0), 0.45, 0.32))
    L.append((glocke(90, 1.0, 0.9), 0.50, 0.26))
    return fertig(mix(*L), wet=0.34, decay=1.9)

# Runde 2 (Chef 21.10., 22:47): Titelmusik als Vorbild (G-Moll, langes Crescendo, endet in G-Dur), gegenläufig ohne Harfe,
# nur Streicher und Glöckchen, Crescendo und ganz kurzer Abschluss.
def korpus(y):
    """Klangkörper einer Geige: Resonanzen um 280 Hz, 1 kHz, 2,8 kHz (statt nacktem Sägezahn)."""
    out = 0.35 * y
    for f0, q, g in [(280, 2.0, 0.9), (520, 2.5, 0.5), (1050, 3.0, 0.7), (2800, 2.0, 0.45)]:
        b, a = signal.iirpeak(f0, q, fs=SR); out = out + g * signal.lfilter(b, a, y)
    return out

def linie(noten, d, gleit=0.06, stimmen=7, hell=(900, 3200), vib=0.005, seed=0):
    """Streichergruppe spielt eine Tonfolge [(MIDI, Einsatz s), …] gebunden; Crescendo hebt Lautstärke und Helligkeit."""
    rng = np.random.default_rng(seed); t = t_(d)
    m = np.full(len(t), float(noten[0][0]))
    for (n0, _), (n1, s1) in zip(noten, noten[1:]):
        u = np.clip((t - s1) / gleit, 0, 1); m += (n1 - n0) * u * u * (3 - 2 * u)
    f = 440.0 * 2 ** ((m - 69) / 12)
    y = np.zeros(len(t))
    for s in range(stimmen):
        det = 1 + rng.uniform(-0.005, 0.005); vr = 5.0 + rng.uniform(-0.7, 0.7); ph = rng.uniform(0, 6.3)
        ff = f * det * (1 + vib * np.minimum(1, t / 0.3) * np.sin(2 * np.pi * vr * t + ph))
        y += 2 * ((np.cumsum(ff) / SR + rng.uniform()) % 1) - 1
    y /= stimmen
    y += 0.04 * highpass(rng.standard_normal(len(t)), 3000, 2)  # Bogenrauschen
    dunkel, licht = korpus(lowpass(y, hell[0], 2)), korpus(lowpass(y, hell[1], 2))
    return dunkel, licht

def cresc(t, a, b, lo=0.12, k=2.2):
    """Lautstärke von lo bei a auf 1 bei b (steigend wie ein Bogen, der Druck aufbaut)."""
    u = np.clip((t - a) / (b - a), 0, 1); return lo + (1 - lo) * u ** k

def streicher_cresc(noten, d, a, b, aus, rel=0.05, **kw):
    dunkel, licht = linie(noten, d, **kw); t = t_(d); c = cresc(t, a, b)
    y = dunkel * (1 - c) + licht * c
    env = c * np.minimum(1, t / 0.06) * np.clip((aus + rel - t) / rel, 0, 1) ** 2
    return y * env

def gloeckchen(n, d=1.0, hell=1.0):
    """Glöckchen: heller, kürzer als glocke(), mit leichtem Schweben."""
    t = t_(d); f = hz(n)
    parts = [(1.0, 1.0, 2.6), (2.0, 0.35, 4.0), (3.0, 0.25 * hell, 6.0), (4.2, 0.12 * hell, 9.0)]
    y = sum(a * np.sin(2 * np.pi * f * r * t * (1 + 0.0007 * np.sin(2 * np.pi * 6 * t))) * np.exp(-k * t) for r, a, k in parts)
    return y * np.minimum(1, t / 0.001)

# G-Moll zu G-Dur; MIDI: G2=43 D3=50 G3=55 Bb3=58 D4=62 G4=67 A4=69 Bb4=70 B4=71 C5=72 D5=74 G5=79 B5=83 D6=86 G6=91 B6=95 D7=98
OBEN = [(67, 0), (69, 0.22), (70, 0.42), (72, 0.60), (74, 0.76)]        # Geigen steigen G4–D5
MITTE = [(62, 0), (62, 0.42), (63, 0.60), (62, 0.76)]                    # Bratschen halten, Vorhalt Es–D
UNTEN = [(55, 0), (53, 0.22), (51, 0.42), (50, 0.60), (43, 0.76)]       # Celli fallen G3–G2
TREFF = 0.88

def treffpunkt(d, aus, dur_terz=71):
    """G-Dur-Klang am Treffpunkt, Terz H (aus Moll wird Dur wie am Ende der Titelmusik)."""
    L = []
    for n, g, s in [(43, 0.5, 1), (50, 0.35, 2), (55, 0.35, 3), (dur_terz, 0.30, 4), (74, 0.30, 5), (79, 0.22, 6)]:
        y = streicher_cresc([(n, 0)], d, 0, 0.05, aus, rel=0.12, seed=40 + s, hell=(2600, 4200))
        L.append((y, TREFF, g))
    return L

def anlauf(aus_oben=TREFF, aus_unten=TREFF):
    return [(streicher_cresc(OBEN + [(74, TREFF)], TREFF + 0.1, 0.0, TREFF, aus_oben, seed=1), 0.0, 0.55),
            (streicher_cresc(MITTE, TREFF + 0.1, 0.0, TREFF, aus_oben, seed=2, hell=(700, 2400)), 0.0, 0.30),
            (streicher_cresc(UNTEN, TREFF + 0.1, 0.0, TREFF, aus_unten, seed=3, hell=(500, 1800)), 0.0, 0.55)]

def fassung_d():
    """Stoß: Crescendo, am Treffpunkt kurzer G-Dur-Schlag der Streicher mit Pauke, dann klingt nur das Glöckchen aus."""
    L = anlauf() + treffpunkt(0.30, 0.16) + [(pauke(43, 0.9), TREFF - 0.005, 0.55), (gloeckchen(91, 0.62), TREFF + 0.02, 0.32)]
    return fertig(mix(*L), wet=0.30, decay=1.5)

def fassung_e():
    """Funkeln: Crescendo, am Treffpunkt G-Dur gehalten, drei Glöckchen G6–H6–D7 perlen darüber."""
    L = anlauf() + treffpunkt(0.62, 0.50)
    for i, n in enumerate([91, 95, 98]): L.append((gloeckchen(n, 0.62 - 0.06 * i, 0.8), TREFF + 0.06 * i, 0.26 - 0.03 * i))
    return fertig(mix(*L), wet=0.32, decay=1.6)

def fassung_f():
    """Atem: kürzeres Crescendo, am Treffpunkt reißen die Streicher ab (Stille 0,1 s), dann ein einzelnes Glöckchen G6, keine Pauke."""
    L = anlauf() + treffpunkt(0.14, 0.08) + [(gloeckchen(91, 0.5), TREFF + 0.12, 0.28), (gloeckchen(98, 0.45, 0.6), TREFF + 0.12, 0.08)]
    return fertig(mix(*L), wet=0.22, decay=1.2)

if __name__ == "__main__":
    OUT = sys.argv[1]; os.makedirs(OUT, exist_ok=True)
    wavs = []
    runde1 = "--runde1" in sys.argv
    for k, fn in ([("a", fassung_a), ("b", fassung_b), ("c", fassung_c)] if runde1 else [("d", fassung_d), ("e", fassung_e), ("f", fassung_f)]):
        f = os.path.join(OUT, f"klanglogo_{k}.wav"); write(f, fn()); wavs.append(f)
    # Probe: A, Pause, B, Pause, C
    stille = np.zeros(int(1.0 * SR)); seq = []
    for f in wavs: seq += [load(f), stille]
    import soundfile as sf
    tmp = os.path.join(OUT, "_probe.wav"); sf.write(tmp, np.concatenate(seq), SR, subtype="PCM_16")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", tmp, "-b:a", "192k", os.path.join(OUT, "probe_klanglogo.mp3")], check=True)
    os.remove(tmp)
    for f in wavs: subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", f, "-b:a", "192k", f[:-4] + ".mp3"], check=True)
