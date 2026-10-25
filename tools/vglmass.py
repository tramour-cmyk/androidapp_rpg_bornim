#!/usr/bin/env python3
"""348.9 (Diogenes): misst Vergleichsblätter alt/neu, bevor sie zum Chef gehen (LISTE-UMZUG-348.md „Arbeitsteilung“ 3).

Aufruf:
  python3 tools/vglmass.py blatt.png …               Blatt mit Feldern (Trennstreifen einfarbig, je Zeile alt, neu, alt, neu …;
                                                     auch tools/vgl348.py und Raster daraus)
  python3 tools/vglmass.py --halb blatt.png …        beliebiges Blatt: linke Hälfte alt, rechte neu
  python3 tools/vglmass.py --paar alt.png neu.png    zwei Einzelbilder
  --ganz: ganzes Bild messen (sonst ohne obere und untere 12 %, dort steht die Leiste)
Helligkeit 0–255 (Luma), Streuung = Kontrast, dunkel < 40, hell > 200, Sätt. = mittlere Sättigung %, R−B = Wärme.
Messlatte 3489 (Chef 25.10., 13:26): Mittel höchstens 5 % (mindestens 2 Stufen) von alt, Streuung höchstens +25 % über alt,
Farbe gleich gerichtet (R−B warm > 3, neutral ±3, kalt < −3, wie alt); außerhalb nur „Hinweis“ (Chef 14:33).
„zurück“ nur bei deutlich heller oder bunter als alt (Mittel oder Sättigung mehr als 15 % über alt; Leitbild „düster“). Dunkel und Sättigung nur zur Auskunft. Magenta (Leerfläche) zählt nicht.
"""
import sys
import numpy as np
from PIL import Image

def richtung(rb): return "warm" if rb > 3 else "kalt" if rb < -3 else "neutral"

def werte(im, ganz):
    a = np.asarray(im.convert("RGB")).astype(float)
    if not ganz:
        h = a.shape[0]; a = a[int(h * .12):int(h * .88)]
    R, G, B = a[..., 0], a[..., 1], a[..., 2]
    frei = ~((R > 200) & (G < 60) & (B > 200))  # Magenta = Leerfläche (Jerry), nicht mitmessen
    R, G, B, a = R[frei], G[frei], B[frei], a[frei]
    L = .299 * R + .587 * G + .114 * B
    mx, mn = a.max(-1), a.min(-1)
    S = np.where(mx > 0, (mx - mn) / np.maximum(mx, 1), 0)
    return {"mittel": L.mean(), "streu": L.std(), "p10": np.percentile(L, 10), "p90": np.percentile(L, 90),
            "dunkel": (L < 40).mean() * 100, "hell": (L > 200).mean() * 100, "satt": S.mean() * 100, "rb": (R - B).mean()}

def urteil(a, n):
    f = []
    d = n["mittel"] - a["mittel"]
    if abs(d) > max(.05 * a["mittel"], 2): f.append(f"{'heller' if d > 0 else 'dunkler'} {d / max(a['mittel'], 1):+.0%}")
    d = n["streu"] / max(a["streu"], 1) - 1
    if d > .25: f.append(f"Kontrast {d:+.0%}")
    if richtung(a["rb"]) != richtung(n["rb"]): f.append(f"Farbe {richtung(a['rb'])}→{richtung(n['rb'])}")
    z = [x for x, w in (("heller", n["mittel"] / max(a["mittel"], 1) - 1), ("bunter", n["satt"] / max(a["satt"], 1) - 1)) if w > .15]
    if z: return "zurück (" + ", ".join(z) + " > 15 %): " + "; ".join(f)
    return "Hinweis: " + "; ".join(f) if f else "frei"

def zeile(name, a, n):
    k = lambda w: f"{w['mittel']:4.0f} {w['streu']:4.0f} {w['p10']:4.0f}-{w['p90']:<4.0f}{w['dunkel']:4.0f}%{w['hell']:4.0f}%{w['satt']:4.0f}%{w['rb']:+5.0f}"
    print(f"{name:18} alt {k(a)}\n{'':18} neu {k(n)}  → {urteil(a, n)}")

def spannen(v, mind=200):
    """Abschnitte zwischen einfarbigen Streifen (Streuung < 4), länger als mind Bildpunkte."""
    voll = v >= 4; out = []; s = None
    for i, x in enumerate(list(voll) + [False]):
        if x and s is None: s = i
        if not x and s is not None:
            if i - s >= mind: out.append((s, i))
            s = None
    return out

def felder(im):
    L = np.asarray(im.convert("L")).astype(float); out = []
    for y0, y1 in spannen(L.std(1)):
        xs = spannen(L[y0:y1].std(0))
        out += [(x0, y0, x1, y1) for x0, x1 in xs]
    return out

def main(argv):
    ganz = "--ganz" in argv; argv = [x for x in argv if x != "--ganz"]
    print(f"{'Blatt':18}     Mitl Stru p10-p90  dunk hell Sätt  R−B")
    if argv[:1] == ["--paar"]:
        zeile(argv[1].rsplit("/", 1)[-1], werte(Image.open(argv[1]), ganz), werte(Image.open(argv[2]), ganz)); return
    halb = argv[:1] == ["--halb"]
    for p in argv[1:] if halb else argv:
        im = Image.open(p); w, h = im.size
        if halb:
            zeile(p.rsplit("/", 1)[-1], werte(im.crop((0, 0, w // 2, h)), ganz), werte(im.crop((w - w // 2, 0, w, h)), ganz)); continue
        f = felder(im)
        if len(f) < 2 or len(f) % 2: print(f"{p}: {len(f)} Felder erkannt, nicht paarweise; --halb oder --paar"); continue
        for i in range(0, len(f), 2):
            zeile(f"{p.rsplit('/', 1)[-1]} #{i // 2 + 1}", werte(im.crop(f[i]), ganz), werte(im.crop(f[i + 1]), ganz))

if __name__ == "__main__":
    if len(sys.argv) < 2: print(__doc__); sys.exit(2)
    main(sys.argv[1:])
