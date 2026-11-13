"""1073: Bilder der Dinge in Tasche und Laden nach unserer Signatur (DESIGN-STIL.md 302) statt der Kotlin-Zeichnungen.

Jedes Ding wird aus Teilen gemalt (Umriss, Höhe, Stoff), vierfach groß, dann verkleinert:
  1. Licht hat eine Quelle: oben links, warm; was abgewandt ist, kühlt ins Blauschwarz.
  2. Tuschelinie: dunkler Umriss um jedes Teil, leicht ungleich, im Schatten dicker, im Licht dünner; mitgezeichnet,
     das Licht danach darüber (kein Filter über das fertige Bild).
  3. Gold ist der einzige Glanz: nur Gold, Feuer und Magie glänzen oder leuchten (Gold, Trank, Steine der Seltenheit);
     Stahl, Eisen, Leder, Holz, Glas bleiben matt.
Seltenheit wie bisher: ein Stein je Stufe über gewöhnlich, unten rechts (ItemArt.pips).

Aufruf: python3 tools/dinge/dingbilder.py <Ordner>          schreibt ding-<id>.bild, stueck-<grundform>-<SELTENHEIT>.bild
        python3 tools/dinge/dingbilder.py --vergleich <png>  alt (main) neben neu, je Ding, für die Probe
"""
import math
import os
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as nd

OUT = 128            # Bildgröße: 48 dp auf dem A56 (1080 px / 411 dp) sind 126 px
SS = 4               # vierfach gemalt
S = OUT * SS
YY, XX = np.mgrid[0:S, 0:S]
UX = (XX + 0.5) / S
UY = (YY + 0.5) / S

LICHT = np.array([-0.55, -0.70, 0.55]); LICHT /= np.linalg.norm(LICHT)
L2 = np.array([-0.62, -0.78]); L2 /= np.linalg.norm(L2)
WARM = np.array([1.0, 0.86, 0.66])
KALT = np.array([0.20, 0.25, 0.40])
TUSCHE = np.array([20, 16, 14], dtype=float)
SELTENHEIT = ["COMMON", "UNCOMMON", "RARE", "VERY_RARE", "EPIC", "DIVINE"]
SELTEN = {"COMMON": 0xbdb6a8, "UNCOMMON": 0x86c46e, "RARE": 0x82aaf2, "VERY_RARE": 0xbc8ef2, "EPIC": 0xf29e50, "DIVINE": 0xeac650}


def farbe(h):
    return np.array([(h >> 16) & 255, (h >> 8) & 255, h & 255], dtype=float)


def rauschen(zelle, saat, oktaven=3):
    """Weiches Wertrauschen 0..1 über die Fläche, Zellgröße in Bildpunkten der Zeichenfläche."""
    rng = np.random.default_rng(saat)
    aus = np.zeros((S, S)); amp = 1.0; summe = 0.0
    for o in range(oktaven):
        z = max(2, int(zelle / 2 ** o))
        n = S // z + 3
        roh = rng.random((n, n))
        groß = nd.zoom(roh, z, order=3)[:S, :S]
        aus += groß * amp; summe += amp; amp *= 0.5
    return np.clip(aus / summe, 0, 1)


def gestreckt(sx, sy, saat, winkel=0.0):
    """Rauschen, in eine Richtung gezogen (Holzmaserung, Fasern)."""
    rng = np.random.default_rng(saat)
    roh = rng.random((S // max(1, int(sy)) + 4, S // max(1, int(sx)) + 4))
    groß = nd.zoom(roh, (sy, sx), order=1)
    if winkel:
        groß = nd.rotate(groß, winkel, reshape=False, mode="reflect")
    return nd.gaussian_filter(groß[:S, :S], 1.0)


# ------------------------------------------------------------------ Formen (Einheiten 0..1 über das Bild)

def kreis(cx, cy, r):
    return (UX - cx) ** 2 + (UY - cy) ** 2 <= r * r


def ellipse(cx, cy, rx, ry, dreh=0.0):
    c, s = math.cos(dreh), math.sin(dreh)
    x = (UX - cx) * c + (UY - cy) * s
    y = -(UX - cx) * s + (UY - cy) * c
    return (x / rx) ** 2 + (y / ry) ** 2 <= 1


def vieleck(punkte):
    bild = Image.new("L", (S, S), 0)
    ImageDraw.Draw(bild).polygon([(x * S, y * S) for x, y in punkte], fill=255)
    return np.array(bild) > 127


def strich(punkte, breite, alpha=1.0):
    """Feine Tuschelinie (Breite in Bildpunkten des fertigen Bilds) als Deckung 0..1."""
    bild = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(bild)
    pp = [(x * S, y * S) for x, y in punkte]
    w = max(1, int(round(breite * SS)))
    d.line(pp, fill=255, width=w, joint="curve")
    for x, y in (pp[0], pp[-1]):
        d.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=255)
    return np.array(bild) / 255.0 * alpha


def punkte(liste, r, alpha=1.0):
    bild = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(bild)
    for x, y in liste:
        d.ellipse([x * S - r * SS, y * S - r * SS, x * S + r * SS, y * S + r * SS], fill=255)
    return np.array(bild) / 255.0 * alpha


def achse(p0, p1):
    """Lage zu einer Achse p0 → p1: Weg s entlang (Einheiten), Abstand q quer (positiv nach rechts unten)."""
    d = np.array(p1, float) - np.array(p0, float)
    lang = np.linalg.norm(d); d /= lang
    s = (UX - p0[0]) * d[0] + (UY - p0[1]) * d[1]
    q = (UX - p0[0]) * -d[1] + (UY - p0[1]) * d[0]
    return s, q, d, lang


def aufblasen(maske, radius):
    """Höhe eines Körpers aus seinem Umriss: am Rand rund, innen flach (Radius in Einheiten)."""
    r = radius * S
    d = nd.distance_transform_edt(maske)
    t = np.clip(d / r, 0, 1)
    return np.sqrt(1 - (1 - t) ** 2) * r


# ------------------------------------------------------------------ Malen

class Teil:
    def __init__(self, maske, hoehe, grund, glanz=0.0, leucht=None, linie=1.0, matt=0.32, k=1.0, deckung=1.0):
        self.maske = maske
        self.hoehe = hoehe
        self.grund = grund if np.ndim(grund) == 3 else np.broadcast_to(np.asarray(grund, float), (S, S, 3))
        self.glanz = glanz         # nur Gold, Magie
        self.leucht = leucht       # eigenes Licht (Magie, Feuer), kommt nach dem Licht dazu
        self.linie = linie         # Stärke des eigenen Umrisses
        self.matt = matt           # Grundlicht im Schatten
        self.k = k                 # wie stark die Höhe die Fläche neigt
        self.deckung = deckung


def schatte(t):
    h = nd.gaussian_filter(t.hoehe, 1.5)
    gy, gx = np.gradient(h)
    n = np.dstack([-gx * t.k, -gy * t.k, np.ones_like(h)])
    n /= np.linalg.norm(n, axis=2, keepdims=True)
    lam = np.clip((n * LICHT).sum(axis=2), 0, 1)[..., None]
    farb = t.grund * (KALT * t.matt + WARM * lam * 1.18)
    if t.glanz:
        hv = LICHT + np.array([0, 0, 1.0]); hv /= np.linalg.norm(hv)
        sp = np.clip((n * hv).sum(axis=2), 0, 1) ** 26
        farb = farb + (sp * t.glanz)[..., None] * np.array([255, 232, 176])
    if t.leucht is not None:
        farb = farb + t.leucht
    return farb, lam[..., 0]


def randlinie(maske, breite, saat):
    """Tusche am Rand innerhalb von [maske]: im Licht dünner, im Schatten dicker, leicht ungleich (Breite im fertigen Bild)."""
    if not maske.any():
        return np.zeros((S, S))
    d = nd.distance_transform_edt(maske)
    g = nd.gaussian_filter(d, 2.5)
    gy, gx = np.gradient(g)
    norm = np.hypot(gx, gy) + 1e-6
    zum_licht = (-gx * L2[0] - gy * L2[1]) / norm          # +1: Rand zeigt zum Licht
    w = breite * SS * (1.0 - 0.5 * zum_licht) * (0.82 + 0.36 * rauschen(40, saat, 2))
    return np.clip(w - d + 0.5, 0, 1) * maske


def male(teile, striche=(), saat=1, rand=1.7, innen=0.75):
    farb = np.zeros((S, S, 3)); deck = np.zeros((S, S)); wer = np.full((S, S), -1); licht = np.zeros((S, S))
    for i, t in enumerate(teile):
        f, lam = schatte(t)
        m = t.maske
        a = t.deckung
        farb[m] = farb[m] * (1 - a) + f[m] * a if a < 1 else f[m]
        deck[m] = np.maximum(deck[m], a)
        wer[m] = i
        licht[m] = lam[m]
    tusche = randlinie(deck > 0, rand, saat)
    for i, t in enumerate(teile):
        if t.linie > 0:
            tusche = np.maximum(tusche, randlinie(wer == i, innen * t.linie, saat + 7 * i + 3))
    for s in striche:
        tusche = np.maximum(tusche, s * (deck > 0))
    # die Linie zuerst, das Licht darüber: im Licht wird auch die Tusche etwas wärmer und heller (302.3)
    tfarbe = TUSCHE + (nd.gaussian_filter(licht, 6) ** 2)[..., None] * WARM * 34
    farb = farb * (1 - tusche[..., None]) + tfarbe * tusche[..., None]
    return farb, deck


def bild(farb, deck):
    """Vierfach gemalt → fertige Größe, Deckung vormultipliziert gemittelt."""
    pm = np.dstack([np.clip(farb, 0, 255) * deck[..., None], deck * 255])
    klein = pm.reshape(OUT, SS, OUT, SS, 4).mean(axis=(1, 3))
    a = klein[..., 3:4]
    rgb = klein[..., :3] / np.maximum(a, 1e-6) * 255 * (a > 0)
    return Image.fromarray(np.dstack([np.clip(rgb, 0, 255), np.clip(a, 0, 255)]).astype(np.uint8), "RGBA")


def stoff(grund, k, saat, zelle=24):
    """Grundfarbe mit Fleckigkeit."""
    return farbe(grund) * (1 - k / 2 + k * rauschen(zelle, saat))[..., None]


# ------------------------------------------------------------------ Steine der Seltenheit

def steine(r):
    """Ein Stein je Stufe über gewöhnlich, in einer Reihe unten von rechts (ItemArt.pips), geschliffen, mit Tusche."""
    n = SELTENHEIT.index(r)
    if n == 0:
        return []
    col = farbe(SELTEN[r])
    rad = 0.078; abst = rad * 2 + 0.014
    teile = []
    for k in range(n):
        cx = 1 - 0.02 - rad - k * abst; cy = 1 - 0.02 - rad
        m = np.abs(UX - cx) + np.abs(UY - cy) <= rad
        # vier Facetten: zum Licht hell, abgewandt dunkel, dazu ein Funke (Magie)
        h = (rad - np.abs(UX - cx) - np.abs(UY - cy)) * S * 0.9
        f = np.where(((UX - cx) <= 0) & ((UY - cy) <= 0), 1.0, 0.0)
        leucht = (f[..., None] * 0.25 + 0.12) * col
        teile.append(Teil(m, h, col * 0.75, glanz=0.9, leucht=leucht, linie=1.2, matt=0.55))
    return teile


# ------------------------------------------------------------------ Heiltrank

def heiltrank():
    bauch = kreis(0.5, 0.64, 0.325)
    hals = vieleck([(0.43, 0.15), (0.57, 0.15), (0.575, 0.38), (0.425, 0.38)])
    glas = bauch | hals
    lippe = ellipse(0.5, 0.165, 0.095, 0.034)
    korken = vieleck([(0.447, 0.04), (0.553, 0.04), (0.548, 0.165), (0.452, 0.165)]) | ellipse(0.5, 0.043, 0.053, 0.02)
    innen = kreis(0.5, 0.64, 0.29)
    spiegel = 0.58 + 0.012 * np.sin(UX * 21)
    trank = innen & (UY >= spiegel)
    schnur = (UY >= 0.325) & (UY <= 0.36) & (np.abs(UX - 0.5) <= 0.082)

    hg = aufblasen(glas, 0.18)
    # Glas matt und rauchig; der Trank leuchtet von innen (Magie) und färbt das Glas über sich rötlich
    glasfarbe = stoff(0xb6c2bc, 0.10, 11, 30)
    mitte = np.hypot(UX - 0.46, UY - 0.73)
    schein = np.clip(1 - mitte / 0.30, 0, 1) ** 1.6
    rot_glas = np.clip(1 - np.hypot(UX - 0.5, UY - 0.70) / 0.36, 0, 1) ** 2 * (UY > 0.40)
    t_glas = Teil(glas, hg, glasfarbe, leucht=rot_glas[..., None] * np.array([60, 6, 4]), matt=0.42)
    t_trank = Teil(trank, hg, stoff(0x8a1418, 0.18, 12, 20), glanz=0.35,
                   leucht=schein[..., None] * np.array([120, 20, 14]) + np.array([22, 2, 2]), linie=0.0, matt=0.45)
    t_lippe = Teil(lippe, aufblasen(lippe, 0.03), glasfarbe * 0.85, matt=0.30)
    poren = 1 - 0.35 * (rauschen(6, 13, 1) > 0.72)
    t_korken = Teil(korken, aufblasen(korken, 0.05), farbe(0x9a7046)[None, None, :] * poren[..., None], matt=0.30)
    hs = aufblasen(schnur, 0.012) + hg * 1.02
    windung = 0.75 + 0.25 * (np.sin((UX * 1.4 + UY) * 130) > 0)
    t_schnur = Teil(schnur, hs, farbe(0xa88c5c)[None, None, :] * windung[..., None], matt=0.30, linie=0.7)
    s_spiegel = strich([(x, 0.58 + 0.012 * math.sin(x * 21)) for x in np.linspace(0.218, 0.782, 30)], 0.9, 0.85)
    return male([t_glas, t_trank, t_lippe, t_korken, t_schnur], [s_spiegel], saat=21)


# ------------------------------------------------------------------ Langschwert

def langschwert(r="COMMON"):
    p0, p1 = (0.125, 0.875), (0.90, 0.10)
    s, q, d, lang = achse(p0, p1)
    s = s / lang                     # 0 Knauf … 1 Spitze
    knauf = kreis(p0[0] + d[0] * 0.014, p0[1] + d[1] * 0.014, 0.056)
    griff = (s >= 0.03) & (s <= 0.205) & (np.abs(q) <= 0.030 + 0.004 * np.sin(np.clip((s - 0.03) / 0.175, 0, 1) * math.pi))
    parier = (np.abs(s - 0.215) <= 0.022 + 0.010 * (np.abs(q) / 0.16) ** 2) & (np.abs(q) <= 0.16)
    breite = np.where(s < 0.78, 0.068 - 0.016 * (s - 0.23) / 0.55, 0.052 * np.clip(1 - (s - 0.78) / 0.22, 0, 1) ** 0.8)
    klinge = (s >= 0.225) & (s <= 1.0) & (np.abs(q) <= breite)

    # Klinge mit Grat: zwei Flächen, die zum Licht hell, die andere dunkel; Stahl matt, kühl
    hk = np.clip(1 - np.abs(q) / np.maximum(breite, 1e-4), 0, 1) * 0.024 * S
    stahl = farbe(0xa8aeb4)[None, None, :] * (0.93 + 0.07 * gestreckt(40, 2, 31, 45))[..., None]
    t_klinge = Teil(klinge, hk, stahl, matt=0.55, k=1.0)
    rille = (s >= 0.25) & (s <= 0.66) & (np.abs(q) <= 0.009)
    t_rille = Teil(rille & klinge, hk - 3, stahl * 0.72, matt=0.55, linie=0.5)
    eisen = stoff(0x6e6c6a, 0.12, 32, 20)
    t_parier = Teil(parier, aufblasen(parier, 0.02), eisen, matt=0.32)
    wick = 0.62 + 0.38 * (np.sin((s * lang * 160 + q * 160)) > -0.2)
    t_griff = Teil(griff, aufblasen(griff, 0.03), farbe(0x5a3a26)[None, None, :] * wick[..., None], matt=0.32)
    t_knauf = Teil(knauf, aufblasen(knauf, 0.04), eisen, matt=0.32)
    striche = []
    for k in range(9):           # Lederwicklung, schräg
        ss = 0.04 + k * 0.019
        a = (p0[0] + d[0] * lang * ss, p0[1] + d[1] * lang * ss)
        n = (-d[1], d[0])
        b0 = (a[0] - n[0] * 0.030 + d[0] * 0.012, a[1] - n[1] * 0.024 + d[1] * 0.012)
        b1 = (a[0] + n[0] * 0.030 - d[0] * 0.006, a[1] + n[1] * 0.024 - d[1] * 0.006)
        striche.append(strich([b0, b1], 0.7, 0.8))
    return male([t_klinge, t_rille, t_griff, t_parier, t_knauf] + steine(r), striche, saat=41)


# ------------------------------------------------------------------ Lederkappe

def lederkappe(r="COMMON"):
    cx, cy, rx, ry, rb = 0.5, 0.66, 0.36, 0.44, 0.09
    x = (UX - cx) / rx
    kuppel = ellipse(cx, cy, rx, ry) & (UY <= cy)
    unten = ellipse(cx, cy, rx, rb) & (UY > cy)
    kappe = kuppel | unten
    vorn = cy + rb * np.sqrt(np.clip(1 - x ** 2, 0, 1))          # Unterkante vorn
    saum = kappe & (UY > vorn - 0.075)
    knopf = ellipse(cx, cy - ry + 0.014, 0.036, 0.022)

    # Kuppel als Halbkugel, der Saum steht senkrecht und zeigt nach vorn
    yk = np.clip((UY - cy) / ry, -1, 0)
    hk = np.sqrt(np.clip(1 - x ** 2 - yk ** 2, 0, 1)) * ry * S
    hs = np.sqrt(np.clip(1 - x ** 2, 0, 1)) * rb * S * 2.2
    h = np.where(UY <= cy, hk, hs)
    leder = stoff(0x8a5c3c, 0.22, 51, 16) * (0.92 + 0.08 * rauschen(5, 52, 1))[..., None]
    t_kappe = Teil(kappe, h, leder, matt=0.32, k=0.8)
    hsaum = hs + aufblasen(saum, 0.025) * 0.5
    t_saum = Teil(saum, hsaum, stoff(0x6a452c, 0.2, 53, 12), matt=0.36, linie=0.9, k=0.8)
    t_knopf = Teil(knopf, aufblasen(knopf, 0.022) + ry * S, stoff(0x6a452c, 0.2, 54, 8), matt=0.32)
    striche = []
    for phi in (-1.05, -0.38, 0.38, 1.05):     # Nähte vom Knopf zum Saum
        pts = []
        for th in np.linspace(0.05, 1.0, 26):
            t = th * math.pi / 2
            px = cx + rx * math.sin(t) * math.sin(phi)
            unterkante = cy + rb * math.sqrt(max(0.0, 1 - (math.sin(t) * math.sin(phi)) ** 2)) - 0.075
            py = cy - ry * math.cos(t) + (unterkante - cy) * math.sin(t) ** 3 * math.cos(phi)
            pts.append((px, py))
        striche.append(strich(pts, 0.8, 0.9))
        stiche = [((pts[i][0] + pts[i + 1][0]) / 2 + 0.013 * math.cos(phi), (pts[i][1] + pts[i + 1][1]) / 2 - 0.004 * math.sin(phi)) for i in range(2, 24, 3)]
        striche.append(punkte(stiche, 0.5, 0.75))
    stiche = [(cx + rx * 0.97 * math.sin(a), cy + rb * math.cos(a) - 0.03) for a in np.linspace(-1.35, 1.35, 15)]
    striche.append(punkte(stiche, 0.55, 0.85))
    return male([t_kappe, t_saum, t_knopf] + steine(r), striche, saat=61)


# ------------------------------------------------------------------ Rundschild

def rundschild(r="COMMON"):
    cx, cy = 0.5, 0.49
    schild = kreis(cx, cy, 0.41)
    rand = schild & ~kreis(cx, cy, 0.365)
    holz = kreis(cx, cy, 0.37)
    buckel = kreis(cx - 0.004, cy - 0.004, 0.115)
    h0 = aufblasen(schild, 0.6) * 0.5
    bretter = np.floor((UX - (cx - 0.41)) / 0.118)
    ton = 0.86 + 0.14 * ((bretter * 7919) % 5) / 4
    maser = 0.82 + 0.18 * gestreckt(3, 30, 71)
    holzfarbe = farbe(0x7c5634)[None, None, :] * (ton * maser)[..., None]
    t_holz = Teil(holz, h0, holzfarbe, matt=0.30)
    eisen = stoff(0x66625e, 0.14, 72, 16)
    t_rand = Teil(rand, h0 + aufblasen(rand, 0.022) * 1.3, eisen, matt=0.32)
    t_buckel = Teil(buckel, h0 + aufblasen(buckel, 0.115) * 0.9, eisen, matt=0.32, k=1.1)
    nieten = []
    for a in np.linspace(0, 2 * math.pi, 13)[:-1]:
        m = kreis(cx + 0.388 * math.cos(a), cy + 0.388 * math.sin(a), 0.014)
        nieten.append(Teil(m, h0 + aufblasen(m, 0.014) * 3, farbe(0x7a7570), matt=0.32, linie=0.6))
    for a in np.linspace(0, 2 * math.pi, 7)[:-1]:
        m = kreis(cx + 0.088 * math.cos(a + 0.3), cy + 0.088 * math.sin(a + 0.3), 0.011)
        nieten.append(Teil(m, h0 + aufblasen(buckel, 0.115) * 0.9 + aufblasen(m, 0.011) * 3, farbe(0x7a7570), matt=0.32, linie=0.6))
    striche = []
    for k in range(1, 7):
        x = cx - 0.41 + k * 0.118
        hh = math.sqrt(max(0, 0.37 ** 2 - (x - cx) ** 2))
        striche.append(strich([(x, cy - hh), (x, cy + hh)], 0.8, 0.9))
    return male([t_holz, t_rand, t_buckel] + nieten + steine(r), striche, saat=81)


# ------------------------------------------------------------------ Heilkräuter

def heilkraeuter():
    rng = np.random.default_rng(91)
    teile, striche = [], []
    # ein Bund: fünf Stiele, unten abgeschnitten, oben gefächert, mit Schnur gebunden
    stiele = []
    for k in range(5):
        u = (k - 2) / 2
        unten = (0.46 + u * 0.035, 0.92 + abs(u) * 0.01)
        bund = (0.48 + u * 0.022, 0.70)
        oben = (0.48 + u * 0.34 + rng.uniform(-0.02, 0.02), 0.14 + abs(u) * 0.10 + rng.uniform(-0.02, 0.02))
        pts = [(unten[0] + (bund[0] - unten[0]) * t, unten[1] + (bund[1] - unten[1]) * t) for t in np.linspace(0, 1, 6)]
        pts += [(bund[0] + (oben[0] - bund[0]) * t + 0.03 * u * math.sin(t * math.pi), bund[1] + (oben[1] - bund[1]) * t) for t in np.linspace(0, 1, 12)[1:]]
        stiele.append(pts)
    stielmaske = np.zeros((S, S), bool)
    for pts in stiele:
        stielmaske |= strich(pts, 3.2) > 0.5
    teile.append(Teil(stielmaske, aufblasen(stielmaske, 0.012), farbe(0x6c7440), matt=0.34, linie=0.6))
    # Blätter wie Salbei: breit-länglich, matt graugrün, je mit Mittelrippe; hintere dunkler
    blaetter = []
    for i, pts in enumerate(stiele):
        for j, t in enumerate((0.50, 0.63, 0.76, 0.88, 1.0)):
            idx = min(int(t * (len(pts) - 1)), len(pts) - 1)
            px, py = pts[idx]
            a0, a1 = pts[max(idx - 2, 0)], pts[idx]
            richt = math.atan2(a1[1] - a0[1], a1[0] - a0[0])
            seite = 1 if (i + j) % 2 else -1
            ang = richt + (0 if t == 1.0 else seite * rng.uniform(0.55, 0.85))
            ln = rng.uniform(0.18, 0.22) * (1.15 - 0.3 * t)
            bx, by = px + math.cos(ang) * ln * 0.5, py + math.sin(ang) * ln * 0.5
            blaetter.append((rng.uniform(0.0, 1.0), bx, by, ln, ang))
    blaetter.sort()
    for z, bx, by, ln, ang in blaetter:
        m = ellipse(bx, by, ln * 0.5, ln * 0.23, ang)
        ton = 0.72 + 0.34 * z
        teile.append(Teil(m, aufblasen(m, 0.025) + z * 6, stoff(0x87a468, 0.16, int(z * 1000), 10) * ton, matt=0.32, linie=0.8))
        a = (bx - math.cos(ang) * ln * 0.46, by - math.sin(ang) * ln * 0.46)
        b = (bx + math.cos(ang) * ln * 0.38, by + math.sin(ang) * ln * 0.38)
        striche.append(strich([a, b], 0.6, 0.6))
    # kleine blasse Blüten an drei Spitzen
    for pts in (stiele[0], stiele[2], stiele[4]):
        ex, ey = pts[-1]
        for k in range(5):
            m = kreis(ex + rng.uniform(-0.03, 0.03), ey + rng.uniform(-0.045, 0.0), 0.017)
            teile.append(Teil(m, aufblasen(m, 0.017) + 9, farbe(0xc0aad0), matt=0.36, linie=0.6))
    band = vieleck([(0.405, 0.69), (0.56, 0.68), (0.565, 0.73), (0.41, 0.742)])
    windung = 0.72 + 0.28 * (np.sin((UX * 0.6 + UY) * 150) > 0)
    teile.append(Teil(band, aufblasen(band, 0.02) + 12, farbe(0xa88c5c)[None, None, :] * windung[..., None], matt=0.32))
    return male(teile, striche, saat=93)


# ------------------------------------------------------------------ Gold

def muenze(cx, cy, rx, ry, dicke, saat):
    oben = ellipse(cx, cy, rx, ry)
    seite = (ellipse(cx, cy + dicke, rx, ry) | ((np.abs(UX - cx) <= rx) & (UY >= cy) & (UY <= cy + dicke))) & ~oben
    gold = stoff(0xc89a3c, 0.12, saat, 14)
    rillen = 0.78 + 0.22 * (np.sin(UX * 420) > 0)
    hs = aufblasen(seite | oben, 0.03)
    t_seite = Teil(seite, hs, gold * 0.70 * rillen[..., None], glanz=0.55, matt=0.40, linie=0.8)
    # Gesicht: erhabener Rand und eine Sonne in der Mitte (geprägt)
    e = ((UX - cx) / rx) ** 2 + ((UY - cy) / ry) ** 2
    praeg = np.where(e > 0.70, 1.0, 0.0) * np.clip((1 - e) * 8, 0, 1)
    sonne_r = np.hypot((UX - cx) / rx, (UY - cy) / ry)
    w = np.arctan2((UY - cy) / ry, (UX - cx) / rx)
    sonne = (sonne_r < 0.25) | ((sonne_r < 0.48) & (np.cos(w * 8) > 0.55) & (sonne_r > 0.25))
    hf = aufblasen(oben, 0.05) * 0.4 + praeg * 5 + sonne * 4
    t_oben = Teil(oben, hf, gold, glanz=1.0, matt=0.42, k=1.3)
    return [t_seite, t_oben]


def gold():
    teile = []
    teile += muenze(0.62, 0.40, 0.21, 0.13, 0.05, 101)
    teile += muenze(0.60, 0.33, 0.21, 0.13, 0.05, 102)
    teile += muenze(0.63, 0.26, 0.21, 0.13, 0.05, 103)
    teile += muenze(0.33, 0.60, 0.21, 0.13, 0.05, 104)
    teile += muenze(0.57, 0.73, 0.21, 0.13, 0.05, 105)
    return male(teile, saat=107)


DINGE = {"ding-potion": heiltrank, "ding-herbs": heilkraeuter, "ding-gold": gold}
STUECKE = {"longsword": langschwert, "leather_cap": lederkappe, "round_shield": rundschild}


def alle():
    for name, f in DINGE.items():
        yield name, f
    for base, f in STUECKE.items():
        for r in SELTENHEIT:
            yield "stueck-%s-%s" % (base, r), (lambda f=f, r=r: f(r))


def schreibe(ordner):
    os.makedirs(ordner, exist_ok=True)
    for name, f in alle():
        bild(*f()).save(os.path.join(ordner, name + ".bild"), "PNG", optimize=True)
        print("Bild", name)


def vergleich(aus):
    """Je Ding eine Zeile: alt (main, 32 px, wie im Spiel scharf vergrößert) neben neu, beide auf 48 dp."""
    from io import BytesIO
    namen = list(DINGE) + ["stueck-%s-COMMON" % b for b in STUECKE]
    groß = 252
    blatt = Image.new("RGBA", (2 * groß + 60, len(namen) * (groß + 20) + 20), (0, 0, 0, 255))
    for i, n in enumerate(namen):
        roh = subprocess.run(["git", "show", "origin/main:godot/daten/%s.bild" % n], capture_output=True).stdout
        alt = Image.open(BytesIO(roh)).convert("RGBA").resize((groß, groß), Image.NEAREST)
        f = DINGE.get(n) or (lambda n=n: STUECKE[n.split("-")[1]]("COMMON"))
        neu = bild(*f()).resize((groß, groß), Image.LANCZOS)
        y = 20 + i * (groß + 20)
        blatt.alpha_composite(alt, (20, y)); blatt.alpha_composite(neu, (groß + 40, y))
    blatt.convert("RGB").save(aus)
    print("Vergleich", aus)


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--vergleich":
        vergleich(sys.argv[2])
    else:
        schreibe(sys.argv[1] if len(sys.argv) > 1 else "dinge")
