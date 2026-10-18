#!/usr/bin/env python3
"""Misst Standbilder einer Zwischensequenz am Muster Intro (112, DESIGN-STIL.md „Muster ist das Intro“).

Aufruf: python3 tools/bildmass.py <bild.jpg> …   (ohne Bilder: Intro aus app/src/main/assets/intro)
Spalten: dunkel = fast schwarz (Punkt 1), kalt = Blau über Rot (2), warm/hell = Anteil warmer Pixel am Hellen (1, 6),
glatt = helle Fläche ohne Struktur (3), R-B mitte = Farbschleier in Mitteltönen (6).
Intro 1–4 (18.10.): dunkel 4–26 %, kalt 14–54 %, warm/hell 0–78 %, glatt 40–68 %, R-B mitte −0,11 bis +0,26.
"""
import glob, os, sys
import numpy as np
from PIL import Image

def box(x, k):
    c = np.cumsum(np.cumsum(np.pad(x, ((k // 2 + 1, k // 2), (k // 2 + 1, k // 2)), mode="edge"), 0), 1)
    return (c[k:, k:] - c[:-k, k:] - c[k:, :-k] + c[:-k, :-k]) / (k * k)

def mass(p):
    a = np.asarray(Image.open(p).convert("RGB")).astype(float) / 255
    R, G, B = a[..., 0], a[..., 1], a[..., 2]
    L = .299 * R + .587 * G + .114 * B
    mu = box(L, 7); sd = np.sqrt(np.maximum(box(L * L, 7) - mu * mu, 0))
    hell = L > 0.25; mid = (L > 0.3) & (L < 0.7)
    return ((L < 0.06).mean() * 100, ((B - R > 0.02) & (L > 0.08)).mean() * 100,
            100 * ((R - B > 0.15) & hell).sum() / max(1, hell.sum()), ((sd < 0.012) & (L > 0.06)).mean() * 100,
            (R - B)[mid].mean() if mid.any() else float("nan"))

bilder = sys.argv[1:] or sorted(glob.glob(os.path.join(os.path.dirname(__file__), "..", "app/src/main/assets/intro/intro_[0-9].jpg")))
print(f"{'Bild':24} dunkel  kalt  warm/hell  glatt  R-B mitte")
for p in bilder:
    d, k, w, g, rb = mass(p)
    print(f"{os.path.basename(p):24} {d:5.0f}% {k:5.0f}% {w:8.0f}% {g:5.0f}%  {rb:+.2f}")
