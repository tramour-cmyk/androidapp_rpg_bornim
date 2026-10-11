"""Kleine Werkbank für Hörproben aus echten Aufnahmen: laden, schneiden, tiefer stimmen, filtern, Hall, mischen."""
import subprocess, numpy as np
from scipy import signal
SR = 44100

def load(f, sr=SR):
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", f, "-ac", "1", "-ar", str(sr), "-f", "f32le", "-"], capture_output=True).stdout
    return np.frombuffer(raw, np.float32).astype(np.float64)

def segments(x, thr_db=-30, min_gap=0.08, min_len=0.04):
    """Laute Stellen (Start, Ende in s) über thr_db unter dem Gipfel."""
    w = int(0.01 * SR)
    e = np.sqrt(np.convolve(x * x, np.ones(w) / w, "same"))
    on = e > np.max(e) * 10 ** (thr_db / 20)
    out = []; i = 0; n = len(x)
    while i < n:
        if on[i]:
            j = i
            while j < n and (on[j] or np.any(on[j:j + int(min_gap * SR)])): j += int(0.005 * SR)
            if (j - i) / SR >= min_len: out.append((i / SR, min(j, n) / SR))
            i = j
        else: i += int(0.005 * SR)
    return out

def cut(x, a, b=None, fade_in=0.005, fade_out=0.03):
    y = x[int(a * SR): (int(b * SR) if b else len(x))].copy()
    fi = min(len(y), int(fade_in * SR)); fo = min(len(y), int(fade_out * SR))
    if fi: y[:fi] *= np.linspace(0, 1, fi)
    if fo: y[-fo:] *= np.linspace(1, 0, fo) ** 2
    return y

def trim(x, thr_db=-45):
    e = np.abs(x); m = np.max(e) * 10 ** (thr_db / 20)
    idx = np.where(e > m)[0]
    return cut(x, max(0, idx[0] / SR - 0.003), idx[-1] / SR + 0.02) if len(idx) else x

def pitch(x, semis):
    """Wie ein Band langsamer abgespielt: tiefer und länger (größeres Tier)."""
    if semis == 0: return x
    k = 2 ** (semis / 12)
    return signal.resample(x, int(len(x) / k))

def lowpass(x, hz, order=4):
    return signal.sosfilt(signal.butter(order, hz, "low", fs=SR, output="sos"), x)

def highpass(x, hz, order=2):
    return signal.sosfilt(signal.butter(order, hz, "high", fs=SR, output="sos"), x)

def shelf_low(x, gain_db, hz=250):
    """Mehr Körper unten (einfach: Tiefpassanteil dazumischen)."""
    return x + (10 ** (gain_db / 20) - 1) * lowpass(x, hz, 2)

def reverb(x, wet=0.18, decay=0.9, damp=4000, seed=1, predelay=0.012):
    """Hall eines dunklen Raums: abklingendes, gedämpftes Rauschen als Raumantwort."""
    rng = np.random.default_rng(seed)
    n = int(decay * SR)
    ir = rng.standard_normal(n) * np.exp(-6.9 * np.arange(n) / n)
    ir = lowpass(ir, damp, 2); ir /= np.sqrt(np.sum(ir ** 2))
    ir = np.concatenate([np.zeros(int(predelay * SR)), ir])
    tail = signal.fftconvolve(x, ir)
    y = np.zeros(len(tail)); y[:len(x)] += x * (1 - wet * 0.5)
    y += tail * wet
    return y

def mix(*layers):
    """layers: (signal, start_s, gain)"""
    n = max(int(s * SR) + len(x) for x, s, g in layers)
    y = np.zeros(n)
    for x, s, g in layers: y[int(s * SR): int(s * SR) + len(x)] += x * g
    return y

def norm(x, peak_db=-1.0, rms_db=None):
    x = x - np.mean(x)
    if rms_db is not None:
        x = x * (10 ** (rms_db / 20) / max(1e-9, np.sqrt(np.mean(x ** 2))))
    p = np.max(np.abs(x))
    lim = 10 ** (peak_db / 20)
    if p > lim:  # weich begrenzen statt hart abschneiden
        x = np.tanh(x / p * 1.2) / np.tanh(1.2) * lim
    return x

def write(f, x):
    import soundfile as sf
    fo = int(0.01 * SR); x = x.copy(); x[-fo:] *= np.linspace(1, 0, fo)
    sf.write(f, np.clip(x, -1, 1), SR, subtype="PCM_16")
