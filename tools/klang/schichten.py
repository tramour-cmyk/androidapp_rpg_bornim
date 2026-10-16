"""
Hörproben zu „Musik in Schichten“ (120, Idee 10): nähert sich ein Jäger, schleicht sich eine dunkle Spur in die Musik,
bevor der Kampf beginnt; Stille bewusst einsetzen. Gewählt: Form wie Probe 1, alle drei Spuren im Wechsel (Nutzer 16.10.).

    python3 tools/klang/schichten.py <ordner mit den Aufnahmen> <ziel>
    python3 tools/klang/schichten.py --spiel <ordner mit den Aufnahmen>

--spiel schreibt die drei Spuren als Schleifen nach app/src/main/assets/music (spur_*.ogg, Vorbis q 1, höchstens 90 s,
die letzten 3 s gehen in den Anfang über), Effektivpegel SPUR_RMS + SPUR_TOP: so laut wie in Probe 1 im Augenblick,
bevor der Jäger den Helden bemerkt (Hüllkurve 1,2); das Spiel regelt sie mit der Nähe herunter (MusicDirector).

Musik aus app/src/main/assets/music (schon auf -18 LUFS), Spur aus drei CC0-Aufnahmen (QUELLEN.md, „Musik in
Schichten“; laden mit tools/klang/holen.sh), auf gleichen Effektivpegel gebracht. Pegel wie im Spiel (Musik 0,6).
Proben (MP3, Stereo):
  0 heute: Waldmusik, Kampf beginnt hart
  1 Spur (Cello): Jäger kommt näher, Spur wächst, Waldmusik wird dunkler und leiser; Jäger dreht ab, Spur weicht;
    er kommt wieder, bemerkt den Helden: Stille, bis er da ist, dann die Kampfmusik
  2, 3 wie 1 (kürzer), Spur aus den anderen Aufnahmen (gedehnte Celli, tiefe Streicher)
  4 nur Stille: keine Spur, die Waldmusik verklingt, wenn er näher kommt; Stille, dann Kampf
"""
import os, subprocess, sys
import numpy as np
from scipy import signal

SR = 44100
SPIEL = sys.argv[1] == "--spiel"
D, OUT = (sys.argv[2], None) if SPIEL else (sys.argv[1], sys.argv[2])
if OUT: os.makedirs(OUT, exist_ok=True)
MUSIC = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../../app/src/main/assets/music")
LEVEL = 0.6
# Pegel der Spur bei Hüllkurve 1 (RMS, dBFS): etwa so laut wie die Waldmusik im Spiel (-28), nach Tiefe gleich laut
SPUR_RMS = -31
SPUR_TOP = 20 * np.log10(1.2)
SPUR_MAX_S = 90
SPUR = {"cello": "fs_465558.mp3", "gedehnt": "fs_195850.mp3", "tief": "fs_507741.mp3"}


def load(f, start=0.0):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-ss", str(start), "-i", f, "-af", f"aresample={SR}",
                          "-ac", "2", "-f", "f32le", "-"], capture_output=True, check=True).stdout
    return np.frombuffer(raw, np.float32).astype(np.float64).reshape(-1, 2)


def lowpass(x, hz):
    return signal.sosfiltfilt(signal.butter(2, hz, "low", fs=SR, output="sos"), x, axis=0)


def env(n, points):
    """Hüllkurve über n Proben aus (Zeit s, Wert); dazwischen weich (Kosinus)."""
    t = np.arange(n) / SR
    y = np.full(n, points[-1][1], dtype=float)
    for (a, va), (b, vb) in zip(points, points[1:]):
        m = (t >= a) & (t < b)
        k = (t[m] - a) / max(1e-9, b - a)
        y[m] = va + (vb - va) * (1 - np.cos(np.pi * k)) / 2
    y[t < points[0][0]] = points[0][1]
    return y[:, None]


def fit(x, n):
    """Auf n Proben bringen, zu kurze Aufnahmen weich verlängert (Schleife mit 3 s Überblendung)."""
    while len(x) < n:
        s = 3 * SR
        f = np.linspace(0, 1, s)[:, None]
        x = np.concatenate([x[:-s], x[-s:] * (1 - f) + x[:s] * f, x[s:]])
    return x[:n]


def place(x, darkness, gain):
    """Ortsmusik mit wachsender Dunkelheit (0 offen, 1 gedämpft bis 700 Hz) und Pegel."""
    return (x * (1 - darkness) + lowpass(x, 700) * darkness) * gain


def probe(name, total, wald_env, dark_env, spur=None, spur_env=None, fight_at=None):
    n = int(total * SR)
    wald = fit(load(f"{MUSIC}/wald_dark_forest.ogg"), n)
    y = place(wald, env(n, dark_env), env(n, wald_env) * LEVEL)
    if spur:
        s = fit(lowpass(load(os.path.join(D, SPUR[spur])), 2500), n)
        s *= 10 ** (SPUR_RMS / 20) / np.sqrt(np.mean(s ** 2))
        y += s * env(n, spur_env)
    if fight_at is not None:
        k = load(f"{MUSIC}/kampf_evil_approach.ogg")
        a = int(fight_at * SR)
        k = k[: n - a] * LEVEL
        f = min(len(k), int(0.3 * SR))
        k[:f] *= np.linspace(0, 1, f)[:, None]
        y[a:a + len(k)] += k
    y[-int(1.5 * SR):] *= np.linspace(1, 0, int(1.5 * SR))[:, None]
    p = np.max(np.abs(y))
    if p > 0.95: y *= 0.95 / p
    wav = os.path.join(OUT, name + ".wav")
    import soundfile as sf
    sf.write(wav, y, SR, subtype="PCM_16")
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", wav, "-b:a", "160k", os.path.join(OUT, name + ".mp3")], check=True)
    os.remove(wav)
    print(name, f"{total:.0f} s, Spitze {20 * np.log10(np.max(np.abs(y)) + 1e-9):.1f} dB")


def spiel():
    for name, f in SPUR.items():
        x = lowpass(load(os.path.join(D, f)), 2500)
        x = x[: SPUR_MAX_S * SR]
        s = 3 * SR
        k = np.linspace(0, 1, s)[:, None]
        # Schleife: das Ende geht in den Anfang über, die Datei beginnt nach der Überblendung
        x = np.concatenate([x[-s:] * (1 - k) + x[:s] * k, x[s:-s]])
        x *= 10 ** ((SPUR_RMS + SPUR_TOP) / 20) / np.sqrt(np.mean(x ** 2))
        wav = os.path.join(D, f"spur_{name}.wav")
        import soundfile as sf
        sf.write(wav, x, SR, subtype="PCM_16")
        ogg = os.path.join(MUSIC, f"spur_{name}.ogg")
        subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", wav, "-c:a", "libvorbis", "-q:a", "1", ogg], check=True)
        os.remove(wav)
        print(ogg, f"{len(x) / SR:.0f} s, Spitze {20 * np.log10(np.max(np.abs(x))):.1f} dB")


if SPIEL:
    spiel()
    sys.exit()

# 0 heute: Wald, nach 14 s steht der Jäger da, Kampf sofort (300 ms)
probe("probe0_heute", 26, [(0, 1), (14, 1), (14.3, 0)], [(0, 0)], fight_at=14)

# 1 lang: näher (12–24 s), dreht ab (24–32 s), wieder näher (32–42 s), bemerkt bei 42 s, Stille bis 43,5 s, Kampf
probe("probe1_spur_cello", 56,
      [(0, 1), (12, 1), (24, 0.45), (26, 0.45), (32, 0.9), (34, 0.9), (42, 0.35), (42.4, 0)],
      [(0, 0), (12, 0), (24, 0.8), (26, 0.8), (32, 0.15), (34, 0.15), (42, 0.9)],
      "cello",
      [(0, 0), (12, 0), (24, 1.0), (26, 1.0), (32, 0.1), (34, 0.1), (42, 1.2), (42.4, 0)],
      fight_at=43.5)

# 2, 3 kurz: näher (6–18 s), bemerkt bei 18 s, Stille bis 19,5 s, Kampf
for i, s in ((2, "gedehnt"), (3, "tief")):
    probe(f"probe{i}_spur_{s}", 30,
          [(0, 1), (6, 1), (18, 0.35), (18.4, 0)], [(0, 0), (6, 0), (18, 0.9)],
          s, [(0, 0), (6, 0), (18, 1.2), (18.4, 0)], fight_at=19.5)

# 4 nur Stille: Waldmusik verklingt beim Näherkommen, Stille, dann Kampf
probe("probe4_nur_stille", 30, [(0, 1), (6, 1), (16, 0)], [(0, 0), (6, 0), (16, 0.6)], fight_at=19.5)
