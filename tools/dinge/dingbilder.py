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
        nh = np.clip((n * hv).sum(axis=2), 0, 1)
        sp = nh ** 26 + 0.22 * nh ** 5
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
    """Ein Stein je Stufe über gewöhnlich, in einer Reihe unten von rechts (ItemArt.pips): geschliffene Raute in voller Farbe
    der Seltenheit (Magie, leuchtet aus sich), Facette zum Licht hell, abgewandt dunkel, kräftige Tusche, so lesbar wie die alten Rauten."""
    n = SELTENHEIT.index(r)
    if n == 0:
        return []
    col = farbe(SELTEN[r])
    rad = 0.088; abst = rad * 2 + 0.006
    teile = []
    for k in range(n):
        cx = 1 - 0.012 - rad - k * abst; cy = 1 - 0.012 - rad
        dx, dy = UX - cx, UY - cy
        m = np.abs(dx) + np.abs(dy) <= rad
        hell = col + (255 - col) * 0.6
        dunkel = col * 0.62
        f = np.where((dx <= 0) & (dy <= 0), 0, np.where((dx > 0) & (dy > 0), 2, 1))
        leucht = np.where((f == 0)[..., None], hell, np.where((f == 2)[..., None], dunkel, col))
        funke = (np.hypot(dx + rad * 0.32, dy + rad * 0.32) < rad * 0.13)[..., None]
        leucht = np.where(funke, np.array([255.0, 252, 240]), leucht)
        teile.append(Teil(m, np.zeros((S, S)), np.zeros(3), leucht=leucht, linie=2.0, matt=0.0))
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

# Klingen (785/1073): eine Form, je Art andere Maße. Lage diagonal von unten links (Knauf) nach oben rechts (Spitze).
# griff: Ende des Griffs (Anteil der Länge), parier: halbe Breite der Parierstange, breit: halbe Klingenbreite am Heft,
# spitze: wo die Klinge zur Spitze läuft, kruemm: Biegung der Klinge (Säbel), korb: Bügel um die Hand (Rapier),
# rille: Hohlkehle bis, wick: Wicklungen am Griff, knauf: Radius
KLINGEN = {
    "dagger":     dict(p0=(0.27, 0.73), p1=(0.80, 0.20), griff=0.32, parier=0.10, breit=0.090, spitze=0.30, kruemm=0.0, rille=0.70, wick=6, knauf=0.050),
    "shortsword": dict(p0=(0.17, 0.83), p1=(0.87, 0.13), griff=0.25, parier=0.13, breit=0.070, spitze=0.74, kruemm=0.0, rille=0.62, wick=7, knauf=0.054),
    "longsword":  dict(p0=(0.125, 0.875), p1=(0.90, 0.10), griff=0.205, parier=0.16, breit=0.068, spitze=0.78, kruemm=0.0, rille=0.66, wick=9, knauf=0.056),
    "greatsword": dict(p0=(0.07, 0.93), p1=(0.94, 0.06), griff=0.29, parier=0.22, breit=0.084, spitze=0.84, kruemm=0.0, rille=0.70, wick=12, knauf=0.052),
    "rapier":     dict(p0=(0.13, 0.87), p1=(0.93, 0.07), griff=0.19, parier=0.12, breit=0.024, spitze=0.70, kruemm=0.0, rille=0.0, wick=8, knauf=0.050, korb=True),
    "scimitar":   dict(p0=(0.16, 0.84), p1=(0.86, 0.14), griff=0.22, parier=0.10, breit=0.055, spitze=0.80, kruemm=0.17, rille=0.0, wick=7, knauf=0.046),
}


def klinge(art, r="COMMON"):
    k = KLINGEN[art]
    p0, p1 = k["p0"], k["p1"]
    s, q, d, lang = achse(p0, p1)
    s = s / lang                     # 0 Knauf … 1 Spitze
    g = k["griff"]
    h0 = g + 0.015                   # Heft: hier beginnt die Klinge
    sb = np.clip((s - h0) / (1 - h0), 0, 1)
    qc = q + k["kruemm"] * sb ** 2   # Säbel: Mittellinie biegt zur Schneide hin
    knauf = kreis(p0[0] + d[0] * 0.014, p0[1] + d[1] * 0.014, k["knauf"])
    gb = 0.030 if art != "greatsword" else 0.028
    griff = (s >= 0.03) & (s <= g) & (np.abs(q) <= gb + 0.004 * np.sin(np.clip((s - 0.03) / (g - 0.03), 0, 1) * math.pi))
    pb = k["parier"]
    parier = (np.abs(s - (g + 0.01)) <= 0.020 + 0.010 * (np.abs(q) / pb) ** 2) & (np.abs(q) <= pb)
    sp = k["spitze"]
    b0 = k["breit"]
    if art == "scimitar":            # wird zur Spitze breiter, dann scharf zurück
        breite = np.where(sb < sp, b0 * (0.85 + 0.45 * sb / sp), b0 * 1.3 * np.clip(1 - (sb - sp) / (1 - sp), 0, 1) ** 0.6)
    else:
        breite = np.where(sb < sp, b0 - b0 * 0.24 * sb / sp, b0 * 0.76 * np.clip(1 - (sb - sp) / (1 - sp), 0, 1) ** 0.8)
    klinge_m = (s >= h0 - 0.01) & (s <= 1.0) & (np.abs(qc) <= breite)
    if art == "scimitar":            # eine Schneide: der Rücken gerade, die Schneide bauchig
        klinge_m &= qc >= -breite * 0.55

    hk = np.clip(1 - np.abs(qc) / np.maximum(breite, 1e-4), 0, 1) * 0.024 * S
    stahl = farbe(0xa8aeb4)[None, None, :] * (0.93 + 0.07 * gestreckt(40, 2, 31, 45))[..., None]
    teile = [Teil(klinge_m, hk, stahl, matt=0.55, k=1.0)]
    if k["rille"]:
        rille = (s >= h0 + 0.02) & (s <= k["rille"]) & (np.abs(qc) <= max(0.006, b0 * 0.13))
        teile.append(Teil(rille & klinge_m, hk - 3, stahl * 0.72, matt=0.55, linie=0.5))
    eisen = stoff(0x6e6c6a, 0.12, 32, 20)
    wick = 0.62 + 0.38 * (np.sin((s * lang * 160 + q * 160)) > -0.2)
    lederton = 0x5a3a26 if art != "scimitar" else 0x6a2a20
    teile.append(Teil(griff, aufblasen(griff, 0.03), farbe(lederton)[None, None, :] * wick[..., None], matt=0.32))
    teile.append(Teil(parier, aufblasen(parier, 0.02), eisen, matt=0.32))
    if k.get("korb"):                # Bügel vom Parier zum Knauf, auf der Seite zum Betrachter
        n = (-d[1], d[0])
        pts = []
        for t in np.linspace(0, 1, 24):
            ss = (g + 0.01) * (1 - t) + 0.04 * t
            off = 0.075 * math.sin(t * math.pi) + 0.02
            pts.append((p0[0] + d[0] * lang * ss + n[0] * off, p0[1] + d[1] * lang * ss + n[1] * off))
        buegel = strich(pts, 2.4) > 0.5
        teile.append(Teil(buegel & ~griff, aufblasen(buegel, 0.01) + 4, eisen, matt=0.32, linie=0.6))
        ring = (np.abs(np.hypot(UX - (p0[0] + d[0] * lang * (g + 0.04)), UY - (p0[1] + d[1] * lang * (g + 0.04))) - 0.045) < 0.009) & (s > g)
        teile.append(Teil(ring & ~klinge_m, aufblasen(ring, 0.008) + 3, eisen, matt=0.32, linie=0.6))
    teile.append(Teil(knauf, aufblasen(knauf, 0.04), eisen, matt=0.32))
    striche = []
    for i in range(k["wick"]):       # Lederwicklung, schräg
        ss = 0.04 + i * (g - 0.05) / max(1, k["wick"] - 1)
        a = (p0[0] + d[0] * lang * ss, p0[1] + d[1] * lang * ss)
        n = (-d[1], d[0])
        e0 = (a[0] - n[0] * gb + d[0] * 0.012, a[1] - n[1] * gb * 0.8 + d[1] * 0.012)
        e1 = (a[0] + n[0] * gb - d[0] * 0.006, a[1] + n[1] * gb * 0.8 - d[1] * 0.006)
        striche.append(strich([e0, e1], 0.7, 0.8))
    return male(teile + steine(r), striche, saat=41)


def langschwert(r="COMMON"):
    return klinge("longsword", r)


# ------------------------------------------------------------------ Stangenwaffen, Hämmer, Stäbe (1073)
# Schaft diagonal von unten links nach oben rechts; Kopf in Achsenlage: u = Weg entlang (Einheiten ab dem unteren Ende),
# q = quer (positiv nach rechts unten, also zur Schneide bei Äxten auf der rechten Seite des Schafts).

def _holz(saat, ton=0x6a4628):
    return farbe(ton)[None, None, :] * (0.80 + 0.20 * gestreckt(3, 34, saat, 45))[..., None]


def schaftwaffe(art, r="COMMON"):
    lage = {
        "handaxe": ((0.30, 0.90), (0.62, 0.22)), "battleaxe": ((0.24, 0.92), (0.64, 0.20)), "greataxe": ((0.22, 0.94), (0.64, 0.20)),
        "halberd": ((0.14, 0.95), (0.80, 0.08)), "spear": ((0.12, 0.92), (0.88, 0.08)), "mace": ((0.26, 0.90), (0.64, 0.24)),
        "morningstar": ((0.26, 0.90), (0.64, 0.24)), "warhammer": ((0.26, 0.91), (0.64, 0.22)), "maul": ((0.24, 0.93), (0.64, 0.24)),
        "quarterstaff": ((0.10, 0.90), (0.90, 0.10)), "staff": ((0.18, 0.95), (0.74, 0.12)), "wand": ((0.28, 0.78), (0.74, 0.24)),
    }[art]
    p0, p1 = lage
    s, q, d, lang = achse(p0, p1)
    u = s                                   # Einheiten ab unten
    n = (-d[1], d[0])
    teile, striche = [], []
    eisen = stoff(0x7a7672, 0.14, 33, 18)
    stahl = farbe(0xa8aeb4)[None, None, :] * (0.93 + 0.07 * gestreckt(40, 2, 34, 45))[..., None]
    sb = {"wand": 0.024, "quarterstaff": 0.030, "staff": 0.032, "spear": 0.027, "halberd": 0.028}.get(art, 0.034)
    oben = lang - {"handaxe": 0.0, "spear": 0.24, "halberd": 0.12, "staff": 0.11, "wand": 0.05}.get(art, 0.0)
    schaft = (u >= 0) & (u <= oben) & (np.abs(q) <= sb)
    if art == "staff":                       # knorrig: Breite schwankt, Wurzelstück oben
        schaft = (u >= 0) & (u <= oben) & (np.abs(q + 0.003 * np.sin(u * 31)) <= sb * (1 + 0.14 * np.sin(u * 19) ** 2))
    holzton = {"wand": 0x3a2a20, "staff": 0x5a4030, "quarterstaff": 0x7a5a38}.get(art, 0x6a4628)
    teile.append(Teil(schaft, aufblasen(schaft, sb * 0.9), _holz(35, holzton), matt=0.32))
    if art not in ("quarterstaff", "staff", "wand", "spear", "halberd"):     # Griff unten mit Leder
        g = (u >= 0.01) & (u <= 0.20) & (np.abs(q) <= sb + 0.004)
        wick = 0.62 + 0.38 * (np.sin((u * 160 + q * 160)) > -0.2)
        teile.append(Teil(g, aufblasen(g, 0.03) + 2, farbe(0x5a3a26)[None, None, :] * wick[..., None], matt=0.32))
        for i in range(6):
            a = (p0[0] + d[0] * (0.02 + i * 0.032), p0[1] + d[1] * (0.02 + i * 0.032))
            striche.append(strich([(a[0] - n[0] * sb, a[1] - n[1] * sb + 0.008), (a[0] + n[0] * sb, a[1] + n[1] * sb - 0.004)], 0.7, 0.8))
    def kopf(maske, hoehe=0.03, grund=None, **kw):
        teile.append(Teil(maske, aufblasen(maske, hoehe) + 6, eisen if grund is None else grund, matt=kw.pop("matt", 0.36), **kw))
    L = lang
    if art in ("handaxe", "battleaxe", "greataxe"):
        hl = {"handaxe": 0.24, "battleaxe": 0.29, "greataxe": 0.30}[art]      # Höhe der Schneide entlang
        tief = {"handaxe": 0.21, "battleaxe": 0.26, "greataxe": 0.24}[art]
        mitte = L - hl * 0.62
        for seite in ((1,) if art != "greataxe" else (1, -1)):
            qq = q * seite
            t = np.clip((qq - sb) / tief, 0, 1)                       # 0 am Schaft, 1 an der Schneide
            halb = hl * 0.18 + hl * 0.5 * t ** 1.6                    # Bart wird zur Schneide breit
            bogen = tief + 0.035 * (1 - ((u - mitte) / (hl * 0.7)) ** 2)
            m = (qq >= sb * 0.5) & (qq <= bogen) & (np.abs(u - mitte) <= halb)
            hk = np.clip(1 - t, 0, 1) * 0.02 * S
            teile.append(Teil(m, hk + 6, stahl, matt=0.50))
            schneide = m & (qq > bogen - 0.022)
            teile.append(Teil(schneide, hk + 5, stahl * 1.12, matt=0.55, linie=0.4))
        if art != "greataxe":                                         # Nacken gegenüber
            m = (q <= -sb * 0.5) & (q >= -0.055) & (np.abs(u - mitte) <= hl * 0.20)
            kopf(m, 0.02)
        kappe = (np.abs(u - (L - hl * 0.02)) <= 0.016) & (np.abs(q) <= sb + 0.006)
        kopf(kappe, 0.012)
    elif art == "halberd":
        mitte = oben - 0.06
        t = np.clip((q - sb) / 0.24, 0, 1)
        m = (q >= sb * 0.5) & (q <= 0.24 + 0.025 * (1 - ((u - mitte) / 0.15) ** 2)) & (np.abs(u - mitte) <= 0.05 + 0.10 * t ** 1.5)
        teile.append(Teil(m, np.clip(1 - t, 0, 1) * 0.02 * S + 6, stahl, matt=0.50))
        haken = (q <= -sb * 0.5) & (q >= -0.14) & (np.abs(u - mitte - 0.03 * (q / -0.14) ** 2) <= 0.026 * (1 - (q / -0.14)) + 0.007)
        kopf(haken, 0.015, stahl, matt=0.5)
        spitze = (u >= oben - 0.01) & (u <= L) & (np.abs(q) <= 0.03 * np.clip(1 - (u - oben) / (L - oben), 0, 1) + 0.002)
        teile.append(Teil(spitze, np.clip(1 - np.abs(q) / 0.03, 0, 1) * 0.015 * S + 6, stahl, matt=0.5))
        tuelle = (u >= oben - 0.20) & (u <= oben) & (np.abs(q) <= sb + 0.008)
        kopf(tuelle, 0.012)
    elif art == "spear":
        blatt = (u >= oben) & (u <= L) & (np.abs(q) <= 0.068 * np.sin(np.clip((u - oben) / (L - oben), 0, 1) ** 0.7 * math.pi) ** 0.9)
        teile.append(Teil(blatt, np.clip(1 - np.abs(q) / 0.068, 0, 1) * 0.018 * S + 6, stahl, matt=0.5))
        striche.append(strich([(p0[0] + d[0] * (oben + 0.02), p0[1] + d[1] * (oben + 0.02)), (p0[0] + d[0] * (L - 0.02), p0[1] + d[1] * (L - 0.02))], 0.6, 0.6))
        tuelle = (u >= oben - 0.07) & (u <= oben + 0.01) & (np.abs(q) <= sb + 0.007)
        kopf(tuelle, 0.012)
        for k in range(3):
            uu = oben - 0.10 - k * 0.02
            striche.append(strich([(p0[0] + d[0] * uu - n[0] * sb, p0[1] + d[1] * uu - n[1] * sb), (p0[0] + d[0] * uu + n[0] * sb, p0[1] + d[1] * uu + n[1] * sb)], 0.8, 0.8))
    elif art in ("mace", "morningstar"):
        cx, cy = p0[0] + d[0] * (L - 0.09), p0[1] + d[1] * (L - 0.09)
        if art == "mace":
            ball = kreis(cx, cy, 0.088)
            w = np.arctan2(UY - cy, UX - cx)
            flansch = (np.hypot(UX - cx, UY - cy) <= 0.135) & (np.cos(w * 6) > 0.80)
            kopf(flansch & ~ball, 0.02)
            kopf(ball, 0.088, matt=0.34)
        else:
            stachel = np.zeros((S, S), bool)
            for a in np.linspace(0, 2 * math.pi, 11)[:-1]:
                tip = (cx + 0.15 * math.cos(a), cy + 0.15 * math.sin(a))
                bl, br = (cx + 0.085 * math.cos(a - 0.26), cy + 0.085 * math.sin(a - 0.26)), (cx + 0.085 * math.cos(a + 0.26), cy + 0.085 * math.sin(a + 0.26))
                stachel |= vieleck([tip, bl, br])
            kopf(stachel, 0.012, stahl, matt=0.5)
            kopf(kreis(cx, cy, 0.095), 0.095, matt=0.34)
        kopf((np.abs(u - (L - 0.19)) <= 0.014) & (np.abs(q) <= sb + 0.007), 0.012)
    elif art in ("warhammer", "maul"):
        hl = 0.10 if art == "warhammer" else 0.14
        breit = 0.10 if art == "warhammer" else 0.16
        mitte = L - hl
        block = (np.abs(u - mitte) <= hl) & (q >= -breit * (0.4 if art == "warhammer" else 1)) & (q <= breit)
        kopf(block, 0.03, matt=0.34)
        if art == "warhammer":
            dorn = (q <= -breit * 0.4) & (q >= -0.15) & (np.abs(u - mitte) <= hl * 0.7 * np.clip((q + 0.15) / (0.15 - breit * 0.4), 0, 1))
            kopf(dorn, 0.015, stahl, matt=0.5)
        bande = (np.abs(u - mitte) <= hl) & (np.abs(np.abs(q) - breit * 0.6) <= 0.010)
        kopf(bande & block, 0.03, eisen * 0.8)
    elif art == "quarterstaff":
        for a, b in ((0.0, 0.06), (L - 0.06, L), (L * 0.42, L * 0.58)):
            m = (u >= a) & (u <= b) & (np.abs(q) <= sb + 0.006)
            kopf(m, 0.015, None if b - a < 0.1 else farbe(0x5a3a26), matt=0.34)
    elif art == "staff":
        cx, cy = p0[0] + d[0] * (L - 0.04), p0[1] + d[1] * (L - 0.04)
        stein = ellipse(cx, cy, 0.062, 0.085, math.atan2(d[1], d[0]) + math.pi / 2)
        schein = np.clip(1 - np.hypot(UX - cx, UY - cy) / 0.07, 0, 1)[..., None]
        teile.append(Teil(stein, aufblasen(stein, 0.05) + 8, farbe(0x5aa8c8), glanz=0.8, leucht=schein * np.array([60, 120, 150]), matt=0.4))
        for a in (-0.7, 0.0, 0.7):           # Wurzelfinger halten den Stein
            pts = [(p0[0] + d[0] * (oben - 0.02) + n[0] * 0.02 * math.sin(a), p0[1] + d[1] * (oben - 0.02) + n[1] * 0.02 * math.sin(a))]
            pts += [(cx + 0.06 * math.cos(math.atan2(d[1], d[0]) + math.pi + a * 1.6) * t, cy + 0.06 * math.sin(math.atan2(d[1], d[0]) + math.pi + a * 1.6) * t) for t in (0.9, 0.5)]
            pts.append((cx + n[0] * 0.04 * a + d[0] * 0.05, cy + n[1] * 0.04 * a + d[1] * 0.05))
            f = strich(pts, 2.6) > 0.5
            teile.append(Teil(f & ~stein, aufblasen(f, 0.01) + 10, _holz(36, 0x5a4030), matt=0.32, linie=0.6))
    elif art == "wand":
        cx, cy = p0[0] + d[0] * (L - 0.02), p0[1] + d[1] * (L - 0.02)
        spitze = kreis(cx, cy, 0.042)
        schein = np.clip(1 - np.hypot(UX - cx, UY - cy) / 0.07, 0, 1)[..., None]
        teile.append(Teil(spitze, aufblasen(spitze, 0.03) + 6, farbe(0xd8c8f0), glanz=0.6, leucht=schein * np.array([90, 70, 140]), matt=0.4))
        for a, b in ((0.0, 0.14), (0.26, 0.29)):
            kopf((u >= a) & (u <= b) & (np.abs(q) <= sb + 0.005), 0.01, farbe(0x8a6a3a) if a else farbe(0x2a1e18), matt=0.34)
    return male(teile + steine(r), striche, saat=45)


# ------------------------------------------------------------------ Bögen, Armbrust (1073)

def _bogenpunkte(a, b, tiefe, n=40, rueck=0.0):
    """Bogenarm von a nach b, zur Seite gewölbt (tiefe in Einheiten); rueck: Enden biegen zurück (Reflex)."""
    ax, ay = a; bx, by = b
    dx, dy = bx - ax, by - ay; L = math.hypot(dx, dy); nx, ny = dy / L, -dx / L
    pts = []
    for t in np.linspace(0, 1, n):
        w = tiefe * math.sin(t * math.pi) - rueck * (math.sin(t * math.pi * 2) ** 2) * (1 if t < 0.5 else 1) * (abs(t - 0.5) > 0.38)
        pts.append((ax + dx * t + nx * w, ay + dy * t + ny * w))
    return pts


def bogen(art, r="COMMON"):
    teile, striche = [], []
    if art == "light_crossbow":
        s, q, d, lang = achse((0.18, 0.86), (0.84, 0.20))
        schaft = (s >= 0) & (s <= lang) & (np.abs(q) <= 0.040 * np.where(s < 0.25, 1.35, 1.0))
        teile.append(Teil(schaft, aufblasen(schaft, 0.035), _holz(55, 0x6a4628), matt=0.32))
        rinne = (s >= 0.32) & (s <= lang - 0.02) & (np.abs(q) <= 0.010)
        teile.append(Teil(rinne & schaft, aufblasen(schaft, 0.035) - 2, _holz(55, 0x4a3018), matt=0.30, linie=0.4))
        mitte = (0.18 + d[0] * lang * 0.80, 0.86 + d[1] * lang * 0.80)
        n = (-d[1], d[0])
        a = (mitte[0] + n[0] * 0.30, mitte[1] + n[1] * 0.30); b = (mitte[0] - n[0] * 0.30, mitte[1] - n[1] * 0.30)
        arm = _bogenpunkte(b, a, 0.07)
        m = strich(arm, 9.0) > 0.5
        sehne = [a, (mitte[0] - d[0] * 0.12, mitte[1] - d[1] * 0.12), b]
        sm = strich(sehne, 1.8) > 0.4
        teile.append(Teil(sm & ~schaft & ~m, np.zeros((S, S)) + 12, farbe(0xc8b890), matt=0.5, linie=0.3))
        teile.append(Teil(m, aufblasen(m, 0.02) + 8, stoff(0x7a7672, 0.12, 56, 16), matt=0.36))
        abzug = vieleck([(0.32, 0.66), (0.35, 0.70), (0.30, 0.76), (0.28, 0.73)])
        teile.append(Teil(abzug, aufblasen(abzug, 0.01), stoff(0x7a7672, 0.12, 57, 8), matt=0.34))
        bolzen = strich([(0.40, 0.62), (0.80, 0.24)], 2.2) > 0.5
        teile.append(Teil(bolzen, aufblasen(bolzen, 0.01) + 10, farbe(0x8a6a40), matt=0.34, linie=0.6))
    else:
        lang_b = art == "longbow"
        a, b = ((0.20, 0.06), (0.80, 0.94)) if lang_b else ((0.27, 0.12), (0.73, 0.88))
        tiefe = 0.20 if lang_b else 0.22
        arm = _bogenpunkte(a, b, -tiefe)
        breite = [11.0 * (0.45 + 0.55 * math.sin(t * math.pi)) for t in np.linspace(0, 1, len(arm))]
        m = np.zeros((S, S), bool)
        for i in range(len(arm) - 1):
            m |= strich(arm[i:i + 2], breite[i]) > 0.5
        teile.append(Teil(m, aufblasen(m, 0.02), _holz(58, 0x8a5e34 if lang_b else 0x6a4026), matt=0.32))
        gm = arm[len(arm) // 2]
        griff = strich(arm[len(arm) // 2 - 4: len(arm) // 2 + 5], 13.0) > 0.5
        wick = 0.62 + 0.38 * (np.sin((UX * 0.7 + UY) * 170) > -0.2)
        teile.append(Teil(griff, aufblasen(griff, 0.02) + 3, farbe(0x5a3a26)[None, None, :] * wick[..., None], matt=0.32))
        sm = strich([arm[1], arm[-2]], 1.8) > 0.4
        teile.insert(0, Teil(sm, np.zeros((S, S)), farbe(0xc8b890), matt=0.5, linie=0.3))
        if not lang_b:              # Kurzbogen: Hornspitzen
            for e in (arm[0], arm[-1]):
                k = kreis(e[0], e[1], 0.022)
                teile.append(Teil(k, aufblasen(k, 0.02) + 4, farbe(0xd8c8a0), matt=0.36))
    return male(teile + steine(r), striche, saat=59)


# ------------------------------------------------------------------ Lederkappe

def lederkappe(r="COMMON"):
    cx, cy, rx, ry, rb = 0.5, 0.56, 0.34, 0.40, 0.08
    x = (UX - cx) / rx
    kuppel = ellipse(cx, cy, rx, ry) & (UY <= cy)
    unten = ellipse(cx, cy, rx, rb) & (UY > cy)
    kappe = kuppel | unten
    vorn = cy + rb * np.sqrt(np.clip(1 - x ** 2, 0, 1))          # Unterkante vorn
    saum = kappe & (UY > vorn - 0.075)
    knopf = ellipse(cx, cy - ry + 0.014, 0.036, 0.022)
    # Ohrenklappen links und rechts, darunter Riemen
    klappen = np.zeros((S, S), bool)
    for sx in (-1, 1):
        kx = cx + sx * (rx - 0.075)
        klappen |= (ellipse(kx, cy + 0.13, 0.085, 0.15) & (UY > cy - 0.02))

    # Kuppel als Halbkugel, der Saum steht senkrecht und zeigt nach vorn
    yk = np.clip((UY - cy) / ry, -1, 0)
    hk = np.sqrt(np.clip(1 - x ** 2 - yk ** 2, 0, 1)) * ry * S
    hs = np.sqrt(np.clip(1 - x ** 2, 0, 1)) * rb * S * 2.2
    h = np.where(UY <= cy, hk, hs)
    leder = stoff(0xb08a58, 0.22, 51, 16) * (0.92 + 0.08 * rauschen(5, 52, 1))[..., None]
    t_klappen = Teil(klappen & ~kappe, aufblasen(klappen, 0.05), leder * 0.9, matt=0.34, linie=1.0)
    t_kappe = Teil(kappe, h, leder, matt=0.32, k=0.8)
    hsaum = hs + aufblasen(saum, 0.025) * 0.5
    t_saum = Teil(saum, hsaum, stoff(0x8a6a40, 0.2, 53, 12), matt=0.36, linie=0.9, k=0.8)
    t_knopf = Teil(knopf, aufblasen(knopf, 0.022) + ry * S, stoff(0x8a6a40, 0.2, 54, 8), matt=0.32)
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
    riemen = np.zeros((S, S), bool)
    for sx in (-1, 1):
        kx = cx + sx * (rx - 0.075)
        pts = [(kx + sx * 0.004 * t, cy + 0.27 + t * 0.012) for t in range(13)]
        riemen |= strich(pts, 2.6) > 0.5
    t_riemen = Teil(riemen, aufblasen(riemen, 0.01), farbe(0x6a4a2c), matt=0.34, linie=0.6)
    return male([t_klappen, t_riemen, t_kappe, t_saum, t_knopf] + steine(r), striche, saat=61)


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
    # geviertelt bemalt, zwei Viertel in stumpfem Ochsenblut, abgeschabt (Farbe ist matt)
    viertel = ((UX - cx) * (UY - cy)) > 0
    farbe_ab = viertel & (rauschen(10, 74, 2) > 0.22)
    holzfarbe = np.where(farbe_ab[..., None], farbe(0x8c3024)[None, None, :] * (0.85 + 0.15 * maser)[..., None], holzfarbe)
    t_holz = Teil(holz, h0, holzfarbe, matt=0.30)
    eisen = stoff(0x8a8682, 0.14, 72, 16)
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


# ------------------------------------------------------------------ Wappenschild, Turmschild (1073)

def schild(art, r="COMMON"):
    if art == "shield":         # Dreieckschild: oben gerade, unten spitz
        pts = [(0.16, 0.10), (0.84, 0.10)]
        for t in np.linspace(0, 1, 30):
            pts.append((0.5 + 0.34 * (1 - t ** 2.4), 0.10 + 0.82 * t))
        pts += [(1 - x, y) for x, y in reversed(pts[2:])]
    else:                       # Turmschild: hoch, oben gerundet, leicht gewölbt
        pts = []
        for t in np.linspace(math.pi, 2 * math.pi, 20):
            pts.append((0.5 + 0.30 * math.cos(t), 0.20 + 0.10 * math.sin(t)))
        pts += [(0.80, 0.90), (0.20, 0.90)]
    form = vieleck(pts)
    innen = nd.binary_erosion(form, iterations=int(0.035 * S))
    rand = form & ~innen
    h0 = aufblasen(form, 0.5) * 0.45
    bretter = np.floor((UY if art == "tower_shield" else UX) * (8 if art == "tower_shield" else 6))
    ton = 0.86 + 0.14 * ((bretter * 7919) % 5) / 4
    maser = 0.82 + 0.18 * gestreckt(30 if art == "tower_shield" else 3, 3 if art == "tower_shield" else 30, 75)
    holz = farbe(0x7c5634)[None, None, :] * (ton * maser)[..., None]
    if art == "shield":         # oberes Feld in Ochsenblut, unten Holz; ein Balken quer, abgeschabt
        feld = (UY < 0.42) & (rauschen(10, 76, 2) > 0.2)
        holz = np.where(feld[..., None], farbe(0x8c3024)[None, None, :] * (0.85 + 0.15 * maser)[..., None], holz)
    else:
        feld = (np.abs(UX - 0.5) < 0.09) & (rauschen(10, 77, 2) > 0.2)
        holz = np.where(feld[..., None], farbe(0x2c3a5a)[None, None, :] * (0.85 + 0.15 * maser)[..., None], holz)
    eisen = stoff(0x8a8682, 0.14, 78, 16)
    teile = [Teil(innen, h0, holz, matt=0.30), Teil(rand, h0 + aufblasen(rand, 0.02) * 1.3, eisen, matt=0.32)]
    striche = []
    if art == "tower_shield":
        for y in (0.38, 0.70):
            band = innen & (np.abs(UY - y) < 0.022)
            teile.append(Teil(band, h0 + aufblasen(band, 0.02) * 1.2, eisen * 0.92, matt=0.32))
            for x in (0.27, 0.5, 0.73):
                m = kreis(x, y, 0.013)
                teile.append(Teil(m, h0 + 8, farbe(0x7a7570), matt=0.32, linie=0.6))
        for k in range(1, 8):
            y = k / 8
            striche.append(strich([(0.21, y), (0.79, y)], 0.7, 0.7))
    else:
        buckel = kreis(0.5, 0.40, 0.07)
        teile.append(Teil(buckel, h0 + aufblasen(buckel, 0.07), eisen, matt=0.32, k=1.1))
        for k in range(1, 6):
            x = k / 6
            striche.append(strich([(x, 0.13), (x, 0.95)], 0.7, 0.7))
    return male(teile + steine(r), striche, saat=79)


# ------------------------------------------------------------------ Rüstungen am Leib (1073)
# Ein Rumpf von vorn (Halsausschnitt, Schultern, Taille, Saum), dazu je Art Ärmel, Saumlänge und Stoff.

def _rumpf(saum=0.82, aermel=0.0, weit=0.0):
    pts = [(0.40, 0.12), (0.45, 0.18), (0.55, 0.18), (0.60, 0.12),          # Halsausschnitt
           (0.78, 0.17), (0.82, 0.24)]
    if aermel:
        pts += [(0.82 + aermel * 0.12, 0.28 + aermel * 0.30), (0.74 + aermel * 0.10, 0.31 + aermel * 0.32), (0.72, 0.38)]
    else:
        pts += [(0.76, 0.34), (0.70, 0.38)]
    pts += [(0.68, 0.55), (0.72 + weit, saum), (0.28 - weit, saum), (0.32, 0.55)]
    if aermel:
        pts += [(0.28, 0.38), (0.26 - aermel * 0.10, 0.31 + aermel * 0.32), (0.18 - aermel * 0.12, 0.28 + aermel * 0.30)]
    else:
        pts += [(0.30, 0.38), (0.24, 0.34)]
    pts += [(0.18, 0.24), (0.22, 0.17)]
    return vieleck(pts)


def ruestung(art, r="COMMON"):
    form = {
        "leather": _rumpf(0.74), "studded_leather": _rumpf(0.74), "chain_shirt": _rumpf(0.70, 0.35), "chain_mail": _rumpf(0.86, 0.75, 0.03),
        "scale_mail": _rumpf(0.84, 0.45, 0.02), "breastplate": _rumpf(0.66), "half_plate": _rumpf(0.72), "splint": _rumpf(0.80, 0.3),
        "plate": _rumpf(0.80, 0.0), "robe": _rumpf(0.95, 0.85, 0.10),
    }[art]
    h = nd.gaussian_filter(aufblasen(form, 0.30) * 0.55, 6) + np.clip(1 - np.abs(UX - 0.5) / 0.3, 0, 1) * 0.02 * S
    teile, striche = [], []
    eisen = stoff(0x8a8682, 0.12, 81, 18)
    stahl = farbe(0x80868c)[None, None, :] * (0.92 + 0.08 * rauschen(30, 82, 2))[..., None]
    leder = stoff(0x5a3c26, 0.22, 83, 14)
    if art in ("leather", "studded_leather"):
        teile.append(Teil(form, h, leder, matt=0.32))
        for x in (0.40, 0.60):
            striche.append(strich([(x, 0.20), (x - 0.02 * (x - 0.5) * 10, 0.72)], 0.8, 0.8))
            striche.append(punkte([(x + 0.012, y) for y in np.linspace(0.23, 0.70, 14)], 0.45, 0.8))
        guertel = form & (np.abs(UY - 0.58) < 0.03)
        teile.append(Teil(guertel, h + 4, farbe(0x4a2e1c), matt=0.32))
        schnalle = (np.abs(UX - 0.5) < 0.03) & (np.abs(UY - 0.58) < 0.034)
        teile.append(Teil(schnalle, h + 6, eisen, matt=0.34))
        if art == "studded_leather":
            nieten = []
            for y in np.linspace(0.26, 0.50, 5):
                for x in np.linspace(0.30, 0.70, 6):
                    if form[int(y * S), int(x * S)]:
                        nieten.append((x + (0.03 if int(y * 20) % 2 else 0), y))
            for x, y in nieten:
                m = kreis(x, y, 0.014) & form
                teile.append(Teil(m, h + 6, farbe(0x8e8a84), matt=0.34, linie=0.5))
    elif art in ("chain_shirt", "chain_mail"):
        ringe = 0.68 + 0.32 * ((np.sin(UX * 210) * np.sin(UY * 210 + (np.floor(UX * 210 / math.pi) % 2) * math.pi / 2)) > 0)
        teile.append(Teil(form, h, stoff(0x8a8682, 0.10, 84, 18) * ringe[..., None], matt=0.36))
        saum = form & (UY > (0.66 if art == "chain_shirt" else 0.82))
        teile.append(Teil(saum, h + 2, eisen * 0.9 * ringe[..., None], matt=0.36, linie=0.6))
        kragen = form & (UY < 0.21) & (np.abs(UX - 0.5) < 0.16)
        teile.append(Teil(kragen, h + 3, leder, matt=0.32))
    elif art == "scale_mail":
        teile.append(Teil(form, h, leder * 0.8, matt=0.32))
        sc = np.zeros((S, S, 3)); maske = np.zeros((S, S), bool); hh = np.zeros((S, S))
        for j, y in enumerate(np.arange(0.20, 0.86, 0.055)):
            for x in np.arange(0.18 + (0.027 if j % 2 else 0), 0.84, 0.054):
                m = ellipse(x, y, 0.030, 0.040) & (UY > y - 0.01) & form
                maske |= m; hh = np.where(m, aufblasen(m, 0.03) + j * 2, hh)
        teile.append(Teil(maske, h + hh, stoff(0x8e8070, 0.15, 85, 10), matt=0.34, linie=0.5))
    elif art in ("breastplate", "half_plate", "plate"):
        brust = form & (UY > 0.16)
        grat = np.clip(1 - np.abs(UX - 0.5) / 0.32, 0, 1) * 0.05 * S
        teile.append(Teil(brust, h + grat * 0.6, stahl, matt=0.48, k=0.8))
        striche.append(strich([(0.5, 0.22), (0.5, 0.54)], 0.7, 0.7))
        if art in ("half_plate", "plate"):
            for sx in (-1, 1):
                schulter = ellipse(0.5 + sx * 0.28, 0.24, 0.11, 0.075)
                teile.append(Teil(schulter, aufblasen(schulter, 0.07) + 14, stahl * 0.95, matt=0.42, k=1.3))
                for k in (1, 2):
                    ring = ellipse(0.5 + sx * (0.28 + 0.015 * k), 0.24 + 0.045 * k, 0.10, 0.05) & ~schulter
                    teile.append(Teil(ring, aufblasen(ring, 0.04) + 8 - k, stahl * 0.9, matt=0.50, linie=0.6))
        if art == "plate":
            for k, y in enumerate((0.64, 0.70, 0.76)):
                band = form & (np.abs(UY - y) < 0.03)
                teile.append(Teil(band, h + 4 - k, stahl * (0.92 - 0.04 * k), matt=0.50, linie=0.7))
        riemen = form & (np.abs(UY - 0.40) < 0.012) & (np.abs(np.abs(UX - 0.5) - 0.20) < 0.04)
        teile.append(Teil(riemen, h + 12, leder * 0.7, matt=0.32, linie=0.5))
    elif art == "splint":
        teile.append(Teil(form, h, leder * 0.85, matt=0.32))
        for k, x in enumerate(np.arange(0.31, 0.70, 0.065)):
            stab = form & (np.abs(UX - x) < 0.026) & (UY > 0.24) & (UY < 0.76)
            teile.append(Teil(stab, h + aufblasen(stab, 0.02) * 1.2, stahl * (0.92 + 0.04 * (k % 2)), matt=0.48, linie=0.6))
            striche.append(punkte([(x, 0.28), (x, 0.72)], 0.8, 0.9))
    elif art == "robe":
        tuch = farbe(0x3a2c4e)[None, None, :] * (0.85 + 0.15 * gestreckt(3, 40, 86))[..., None]
        teile.append(Teil(form, h, tuch, matt=0.36))
        kante = form & (np.abs(UX - 0.5) < 0.04) & (UY > 0.18)
        teile.append(Teil(kante, h + 3, farbe(0xb08a3a) * 0.9, glanz=0.4, matt=0.40, linie=0.5))
        guertel = form & (np.abs(UY - 0.52) < 0.022)
        teile.append(Teil(guertel, h + 5, farbe(0x6a4a2c), matt=0.32))
        for x in (0.36, 0.44, 0.56, 0.64):
            striche.append(strich([(x, 0.56), (x + (x - 0.5) * 0.25, 0.93)], 0.7, 0.6))
    return male(teile + steine(r), striche, saat=87)


# ------------------------------------------------------------------ Kopf, Hände, Beine (1073)

def _stahl(saat):
    return farbe(0x80868c)[None, None, :] * (0.92 + 0.08 * rauschen(30, saat, 2))[..., None]


def kopfteil(art, r="COMMON"):
    teile, striche = [], []
    stahl = _stahl(91)
    if art == "helmet":             # Spangenhelm mit Nasal
        kuppel = ellipse(0.5, 0.56, 0.30, 0.40) & (UY <= 0.62)
        h = nd.gaussian_filter(aufblasen(kuppel, 0.3) * 0.6, 4)
        teile.append(Teil(kuppel, h, stahl, matt=0.46, k=0.9))
        rand = kuppel & (UY > 0.55)
        teile.append(Teil(rand, h + 4, stahl * 0.9, matt=0.46, linie=0.7))
        nasal = (np.abs(UX - 0.5) < 0.036 - 0.012 * np.clip((UY - 0.55) / 0.2, 0, 1)) & (UY > 0.50) & (UY < 0.76)
        teile.append(Teil(nasal, aufblasen(nasal, 0.02) + 20, stahl * 0.95, matt=0.46))
        for x in (0.38, 0.62):
            striche.append(strich([(0.5, 0.17), (x, 0.56)], 0.8, 0.8))
        spange = kuppel & (np.abs(UX - 0.5) < 0.025)
        teile.append(Teil(spange, h + 6, stahl * 0.85, matt=0.46, linie=0.6))
    elif art == "great_helm":       # Topfhelm mit Sehschlitz und Atemlöchern
        pts = [(0.24, 0.30), (0.30, 0.16), (0.70, 0.16), (0.76, 0.30), (0.76, 0.86), (0.24, 0.86)]
        topf = vieleck(pts)
        h = nd.gaussian_filter(aufblasen(topf, 0.3) * 0.5, 4) + np.clip(1 - np.abs(UX - 0.5) / 0.26, 0, 1) * 0.02 * S
        teile.append(Teil(topf, h, stahl, matt=0.46, k=0.9))
        schlitz = (np.abs(UY - 0.44) < 0.022) & (np.abs(UX - 0.5) < 0.22) & ~((np.abs(UX - 0.5) < 0.025))
        teile.append(Teil(schlitz & topf, h - 6, np.full(3, 20.0), matt=0.1, linie=0.4))
        kreuz = topf & (((np.abs(UX - 0.5) < 0.025) & (UY > 0.30)) | (np.abs(UY - 0.40) < 0.0))
        teile.append(Teil(kreuz, h + 5, farbe(0xb08a3a), glanz=0.6, matt=0.4))
        striche.append(punkte([(0.5 + sx * (0.08 + 0.05 * k), 0.62 + 0.05 * j) for sx in (-1, 1) for k in range(3) for j in range(3)], 1.0, 1.0))
    elif art == "hood":             # Gugel aus Wolle, Schulterkragen
        pts = [(0.5, 0.08)]
        for t in np.linspace(0, 1, 16):
            pts.append((0.5 + 0.26 * math.sin(t * math.pi * 0.62) + 0.02 * t, 0.08 + 0.62 * t))
        pts += [(0.88, 0.86), (0.12, 0.86)]
        pts += [(1 - x, y) for x, y in reversed(pts[1:17])]
        kap = vieleck(pts)
        tuch = farbe(0x4a5040)[None, None, :] * (0.85 + 0.15 * gestreckt(3, 30, 92))[..., None]
        teile.append(Teil(kap, nd.gaussian_filter(aufblasen(kap, 0.25) * 0.6, 4), tuch, matt=0.36))
        oeff = ellipse(0.5, 0.46, 0.15, 0.20)
        teile.append(Teil(oeff, np.zeros((S, S)), np.full(3, 26.0), matt=0.2, linie=1.0))
        for x in (0.36, 0.5, 0.64):
            striche.append(strich([(x, 0.70), (x + (x - 0.5) * 0.4, 0.84)], 0.6, 0.6))
    elif art == "circlet":          # Stirnreif aus Gold mit Stein
        ring = (np.abs(np.hypot((UX - 0.5) / 0.36, (UY - 0.52) / 0.16) - 1) < 0.10)
        vorn = UY > 0.47
        gold = stoff(0xe0b048, 0.08, 93, 14)
        teile.append(Teil(ring & ~vorn, aufblasen(ring, 0.02), gold * 0.75, glanz=0.8, matt=0.5, leucht=np.array([20.0, 14, 2])))
        teile.append(Teil(ring & vorn, aufblasen(ring, 0.02) + 6, gold, glanz=1.4, matt=0.5, leucht=np.array([36.0, 24, 4])))
        stein = ellipse(0.5, 0.66, 0.05, 0.06)
        sch = np.clip(1 - np.hypot(UX - 0.5, UY - 0.66) / 0.06, 0, 1)[..., None]
        teile.append(Teil(stein, aufblasen(stein, 0.04) + 10, farbe(0x3a6aa8), glanz=0.9, leucht=sch * np.array([30, 60, 120]), matt=0.4))
    return male(teile + steine(r), striche, saat=95)


def _hand(ox, oy, s=1.0, links=False):
    """Handschuh von oben: Handteller, vier Finger, Daumen, Stulpe nach unten (Einheiten)."""
    sx = -1 if links else 1
    teller = ellipse(ox, oy, 0.13 * s, 0.15 * s)
    finger = np.zeros((S, S), bool)
    for k, (dx, ln) in enumerate(((-0.09, 0.14), (-0.03, 0.17), (0.03, 0.16), (0.09, 0.13))):
        x = ox + dx * s * sx
        finger |= (np.abs(UX - x) < 0.028 * s) & (UY < oy - 0.04 * s) & (UY > oy - (0.10 + ln) * s)
        finger |= kreis(x, oy - (0.10 + ln) * s, 0.028 * s)
    daumen = ellipse(ox + sx * 0.15 * s, oy + 0.01 * s, 0.045 * s, 0.09 * s, sx * 0.6)
    stulpe = vieleck([(ox - 0.12 * s, oy + 0.08 * s), (ox + 0.12 * s, oy + 0.08 * s), (ox + 0.15 * s, oy + 0.32 * s), (ox - 0.15 * s, oy + 0.32 * s)])
    return teller | finger | daumen, stulpe, finger


def handteil(art, r="COMMON"):
    teile, striche = [], []
    stahl = _stahl(96)
    leder = stoff(0x5a3c26, 0.22, 97, 14)
    if art in ("gloves", "gauntlets"):
        for ox, links, z in ((0.36, True, 0), (0.62, False, 8)):
            hand, stulpe, finger = _hand(ox, 0.46 + (0.04 if links else 0), 0.95, links)
            m = hand | stulpe
            if art == "gloves":
                teile.append(Teil(m, aufblasen(m, 0.04) + z, leder, matt=0.32))
                teile.append(Teil(stulpe, aufblasen(stulpe, 0.03) + z + 2, leder * 0.85, matt=0.32, linie=0.8))
            else:
                teile.append(Teil(hand, aufblasen(hand, 0.04) + z, stahl, matt=0.46))
                for k in range(4):
                    y = 0.42 + (0.04 if links else 0) - 0.05 * k
                    band = finger & (np.abs(UY - y) < 0.006)
                    striche.append(band.astype(float) * 0.9)
                teile.append(Teil(stulpe, aufblasen(stulpe, 0.03) + z + 3, stahl * 0.92, matt=0.46, linie=0.8))
    elif art in ("bracers", "wraps"):
        for k, (ox, oy) in enumerate(((0.36, 0.52), (0.62, 0.48))):
            pts = [(ox - 0.10, oy - 0.26), (ox + 0.10, oy - 0.26), (ox + 0.12, oy + 0.26), (ox - 0.12, oy + 0.26)]
            m = vieleck(pts)
            h = aufblasen(m, 0.10) * 0.8 + k * 8
            if art == "bracers":
                teile.append(Teil(m, h, leder, matt=0.32))
                for y in (oy - 0.12, oy + 0.0, oy + 0.12):
                    band = m & (np.abs(UY - y) < 0.016)
                    teile.append(Teil(band, h + 3, farbe(0x3a2618), matt=0.32))
                    teile.append(Teil(kreis(ox + 0.07, y, 0.016), h + 6, farbe(0x8e8a84), matt=0.34, linie=0.5))
            else:
                binde = farbe(0xc8b89a)[None, None, :] * (0.85 + 0.15 * (np.sin((UX * 0.5 + UY) * 110) > 0))[..., None]
                teile.append(Teil(m, h, binde, matt=0.40))
                for j in range(7):
                    y = oy - 0.24 + j * 0.075
                    striche.append(strich([(ox - 0.11, y + 0.03), (ox + 0.11, y - 0.01)], 0.7, 0.7))
    return male(teile + steine(r), striche, saat=98)


def beinteil(art, r="COMMON"):
    teile, striche = [], []
    stahl = _stahl(99)
    leder = stoff(0x5a3c26, 0.22, 100, 14)
    if art == "boots":
        for ox, z in ((0.36, 0), (0.60, 8)):
            schaft = vieleck([(ox - 0.08, 0.14), (ox + 0.08, 0.14), (ox + 0.08, 0.70), (ox - 0.08, 0.70)])
            fuss = ellipse(ox + 0.07, 0.76, 0.16, 0.08) | vieleck([(ox - 0.08, 0.66), (ox + 0.08, 0.66), (ox + 0.14, 0.76), (ox - 0.08, 0.80)])
            m = schaft | fuss
            teile.append(Teil(m, aufblasen(m, 0.06) + z, leder, matt=0.32))
            sohle = m & (UY > 0.80)
            teile.append(Teil(sohle, aufblasen(m, 0.06) + z + 2, farbe(0x2a1c14), matt=0.30))
            stulpe = m & (UY < 0.24)
            teile.append(Teil(stulpe, aufblasen(stulpe, 0.03) + z + 4, leder * 0.82, matt=0.32, linie=0.8))
    else:
        for ox, z in ((0.38, 0), (0.62, 6)):
            bein = vieleck([(ox - 0.10, 0.10), (ox + 0.10, 0.10), (ox + 0.08, 0.90), (ox - 0.07, 0.90)])
            h = aufblasen(bein, 0.10) * 0.8 + z
            if art == "leggings":
                teile.append(Teil(bein, h, stoff(0x4a3a2e, 0.18, 101, 14), matt=0.34))
                striche.append(strich([(ox, 0.12), (ox + 0.005, 0.88)], 0.6, 0.6))
            elif art == "chain_leggings":
                ringe = 0.68 + 0.32 * ((np.sin(UX * 210) * np.sin(UY * 210 + (np.floor(UX * 210 / math.pi) % 2) * math.pi / 2)) > 0)
                teile.append(Teil(bein, h, stoff(0x8a8682, 0.10, 102, 18) * ringe[..., None], matt=0.36))
            else:                   # greaves: Schienen über Knie und Schienbein
                teile.append(Teil(bein, h, stoff(0x4a3a2e, 0.18, 103, 14), matt=0.34))
                knie = ellipse(ox, 0.42, 0.085, 0.07)
                schiene = vieleck([(ox - 0.075, 0.50), (ox + 0.075, 0.50), (ox + 0.065, 0.88), (ox - 0.06, 0.88)])
                teile.append(Teil(schiene, h + aufblasen(schiene, 0.06) * 0.8, stahl, matt=0.46))
                teile.append(Teil(knie, h + 14, stahl * 0.95, matt=0.46, k=1.2))
        guertel = (UY > 0.08) & (UY < 0.15) & (np.abs(UX - 0.5) < 0.23)
        teile.append(Teil(guertel, aufblasen(guertel, 0.02) + 10, farbe(0x3a2618), matt=0.32))
    return male(teile + steine(r), striche, saat=104)


# ------------------------------------------------------------------ Schmuck, Umhänge, Bücher (1073)

def _gold(saat, k=1.0):
    return stoff(0xe0b048, 0.08, saat, 14) * k


def _stein(cx, cy, rx, ry, ton, saat):
    m = ellipse(cx, cy, rx, ry)
    sch = np.clip(1 - np.hypot((UX - cx) / rx, (UY - cy) / ry), 0, 1)[..., None]
    c = farbe(ton)
    return Teil(m, aufblasen(m, min(rx, ry)) + 12, c, glanz=1.0, leucht=sch * c * 0.6, matt=0.4, linie=0.8)


def _kette(pts, teile, saat):
    m = strich(pts, 3.4) > 0.4
    glieder = 0.7 + 0.3 * (np.sin((UX + UY) * 300) > 0)
    teile.append(Teil(m, aufblasen(m, 0.008), _gold(saat, 0.8) * glieder[..., None], glanz=0.8, matt=0.5, linie=0.4, leucht=np.array([16.0, 10, 2])))


def schmuck(art, r="COMMON"):
    teile, striche = [], []
    if art in ("amulet", "talisman", "holy_symbol"):
        kette = [(0.5 + 0.30 * math.sin(t), 0.52 - 0.40 * (1 - math.cos(t)) / (1 - math.cos(1.35))) for t in np.linspace(-1.35, 1.35, 30)]
        _kette(kette, teile, 111)
        cx, cy = 0.5, 0.66
        if art == "amulet":
            fass = ellipse(cx, cy, 0.15, 0.18)
            teile.append(Teil(fass, aufblasen(fass, 0.06), _gold(112), glanz=1.4, matt=0.5, leucht=np.array([36.0, 24, 4])))
            teile.append(_stein(cx, cy, 0.10, 0.125, 0xa82828, 113))
        elif art == "talisman":   # Knochen-Anhänger mit eingeritztem Zeichen, an einer Lederschnur
            teile.pop()
            m = strich(kette, 3.4) > 0.4
            teile.append(Teil(m, aufblasen(m, 0.008), farbe(0x4a3020), matt=0.32, linie=0.4))
            zahn = vieleck([(cx - 0.07, 0.50), (cx + 0.07, 0.50), (cx + 0.05, 0.70), (cx, 0.88), (cx - 0.05, 0.70)])
            teile.append(Teil(zahn, aufblasen(zahn, 0.05), stoff(0xd8ccb0, 0.12, 114, 10), matt=0.40))
            striche.append(strich([(cx - 0.03, 0.58), (cx, 0.66), (cx + 0.03, 0.58)], 0.9, 0.9))
            striche.append(strich([(cx, 0.66), (cx, 0.76)], 0.9, 0.9))
        else:                     # Sonnenscheibe des Tempels in Silber
            silber = stoff(0xb8bcc0, 0.08, 115, 14)
            sonne = kreis(cx, cy, 0.10)
            w = np.arctan2(UY - cy, UX - cx)
            strahlen = (np.hypot(UX - cx, UY - cy) < 0.19) & (np.cos(w * 8) > 0.6) & ~sonne
            teile.append(Teil(strahlen, aufblasen(strahlen, 0.02) + 4, silber * 0.9, glanz=0.4, matt=0.5))
            teile.append(Teil(sonne, aufblasen(sonne, 0.08) + 8, silber, glanz=0.5, matt=0.5))
    elif art in ("ring", "signet"):
        cx, cy = 0.5, 0.56
        reif = (np.abs(np.hypot((UX - cx) / 0.27, (UY - cy) / 0.20) - 1) < (0.14 if art == "ring" else 0.18))
        vorn = UY > cy
        teile.append(Teil(reif & ~vorn, aufblasen(reif, 0.03), _gold(116, 0.7), glanz=0.8, matt=0.5, leucht=np.array([20.0, 14, 2])))
        teile.append(Teil(reif & vorn, aufblasen(reif, 0.03) + 8, _gold(117), glanz=1.4, matt=0.5, leucht=np.array([36.0, 24, 4])))
        if art == "ring":
            teile.append(_stein(cx, cy - 0.20, 0.07, 0.06, 0x2a8a5a, 118))
            fass = ellipse(cx, cy - 0.20, 0.09, 0.075) & ~ellipse(cx, cy - 0.20, 0.07, 0.06)
            teile.insert(-1, Teil(fass, aufblasen(fass, 0.02) + 10, _gold(119), glanz=1.2, matt=0.5))
        else:
            platte = ellipse(cx, cy - 0.20, 0.12, 0.08)
            teile.append(Teil(platte, aufblasen(platte, 0.05) + 12, _gold(120), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4])))
            striche.append(strich([(cx - 0.04, cy - 0.22), (cx, cy - 0.17), (cx + 0.04, cy - 0.22)], 1.0, 0.9))
    return male(teile + steine(r), striche, saat=121)


def umhang(art, r="COMMON"):
    teile, striche = [], []
    if art == "cloak":
        pts = [(0.38, 0.14), (0.62, 0.14), (0.82, 0.88), (0.68, 0.92), (0.5, 0.88), (0.32, 0.92), (0.18, 0.88)]
        ton = 0x3a4a3a
    else:                         # mantle: kürzer, mit Pelzkragen
        pts = [(0.30, 0.22), (0.70, 0.22), (0.86, 0.70), (0.70, 0.74), (0.5, 0.70), (0.30, 0.74), (0.14, 0.70)]
        ton = 0x6a2a24
    m = vieleck(pts)
    tuch = farbe(ton)[None, None, :] * (0.82 + 0.18 * (0.5 + 0.5 * np.sin(UX * 38 + UY * 4)))[..., None]
    teile.append(Teil(m, nd.gaussian_filter(aufblasen(m, 0.2) * 0.5, 4) + 6 * np.sin(UX * 38), tuch, matt=0.36))
    for x in (0.38, 0.5, 0.62):
        striche.append(strich([(x + (x - 0.5) * 0.1, 0.30), (x + (x - 0.5) * 0.9, 0.86 if art == "cloak" else 0.68)], 0.6, 0.6))
    if art == "mantle":
        pelz = ellipse(0.5, 0.24, 0.24, 0.08)
        flaum = 0.8 + 0.2 * rauschen(4, 122, 1)
        teile.append(Teil(pelz, aufblasen(pelz, 0.06) + 10, farbe(0x8a7a64)[None, None, :] * flaum[..., None], matt=0.40))
    spange = kreis(0.5, 0.17 if art == "cloak" else 0.30, 0.04)
    teile.append(Teil(spange, aufblasen(spange, 0.04) + 14, _gold(123), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4])))
    return male(teile + steine(r), striche, saat=124)


def zauberding(art, r="COMMON"):
    teile, striche = [], []
    if art == "orb":
        kugel = kreis(0.5, 0.44, 0.27)
        sch = np.clip(1 - np.hypot(UX - 0.46, UY - 0.40) / 0.30, 0, 1)[..., None]
        teile.append(Teil(kugel, aufblasen(kugel, 0.27), farbe(0x3a4a8a), glanz=1.0, leucht=sch ** 1.5 * np.array([60, 90, 170]), matt=0.40))
        fuss = vieleck([(0.32, 0.70), (0.68, 0.70), (0.60, 0.86), (0.40, 0.86)])
        teile.append(Teil(fuss, aufblasen(fuss, 0.04) + 4, _gold(125), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4])))
    elif art == "tome":
        deckel = vieleck([(0.20, 0.16), (0.76, 0.12), (0.80, 0.80), (0.24, 0.86)])
        seiten = vieleck([(0.76, 0.14), (0.83, 0.18), (0.86, 0.82), (0.80, 0.80)])
        teile.append(Teil(seiten, aufblasen(seiten, 0.02), stoff(0xd8ccb0, 0.1, 126, 6), matt=0.40))
        teile.append(Teil(deckel, aufblasen(deckel, 0.06), stoff(0x5a2a22, 0.2, 127, 14), matt=0.32))
        for y0, y1 in ((0.16, 0.86), ):
            ruecken = vieleck([(0.20, 0.16), (0.27, 0.155), (0.31, 0.855), (0.24, 0.86)])
            teile.append(Teil(ruecken, aufblasen(ruecken, 0.02) + 4, stoff(0x3a1a14, 0.2, 128, 10), matt=0.32))
        zeichen = kreis(0.53, 0.48, 0.09) & ~kreis(0.53, 0.48, 0.065)
        teile.append(Teil(zeichen, aufblasen(zeichen, 0.01) + 8, _gold(129), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4])))
        for ec in ((0.76, 0.12), (0.80, 0.80)):
            e = kreis(ec[0] - 0.02, ec[1] + (0.02 if ec[1] < 0.5 else -0.02), 0.04)
            teile.append(Teil(e & deckel, aufblasen(e, 0.03) + 8, _gold(130, 0.85), glanz=1.0, matt=0.5))
    elif art == "torch":
        stiel = strich([(0.30, 0.90), (0.58, 0.34)], 9.0) > 0.5
        teile.append(Teil(stiel, aufblasen(stiel, 0.03), _holz(131, 0x5a3a22), matt=0.32))
        kopf = ellipse(0.60, 0.32, 0.08, 0.06, -1.1)
        teile.append(Teil(kopf, aufblasen(kopf, 0.05) + 6, farbe(0x3a2a1a), matt=0.30))
        flamme = vieleck([(0.62, 0.06), (0.72, 0.20), (0.70, 0.30), (0.56, 0.30), (0.52, 0.20)])
        sch = np.clip(1 - np.hypot(UX - 0.62, UY - 0.24) / 0.14, 0, 1)[..., None]
        teile.append(Teil(flamme, np.zeros((S, S)) + 20, farbe(0xd86a20), leucht=sch * np.array([140, 90, 20]), matt=0.6, linie=0.5))
    return male(teile + steine(r), striche, saat=132)


# ------------------------------------------------------------------ Heilkräuter

def heilkraeuter():
    rng = np.random.default_rng(91)
    teile, striche = [], []
    # ein Bund: fünf Stiele, unten abgeschnitten, oben gefächert, mit Schnur gebunden
    stiele = []
    for k in range(7):
        u = (k - 3) / 3
        unten = (0.46 + u * 0.035, 0.92 + abs(u) * 0.01)
        bund = (0.48 + u * 0.022, 0.70)
        oben = (0.48 + u * 0.34 + rng.uniform(-0.02, 0.02), 0.14 + abs(u) * 0.10 + rng.uniform(-0.02, 0.02))
        pts = [(unten[0] + (bund[0] - unten[0]) * t, unten[1] + (bund[1] - unten[1]) * t) for t in np.linspace(0, 1, 6)]
        pts += [(bund[0] + (oben[0] - bund[0]) * t + 0.03 * u * math.sin(t * math.pi), bund[1] + (oben[1] - bund[1]) * t) for t in np.linspace(0, 1, 12)[1:]]
        stiele.append(pts)
    stielmaske = np.zeros((S, S), bool)
    for pts in stiele:
        stielmaske |= strich(pts, 3.2) > 0.5
    teile.append(Teil(stielmaske, aufblasen(stielmaske, 0.012), farbe(0x5c7a30), matt=0.36, linie=0.6))
    # Blätter wie Salbei: breit-länglich, matt graugrün, je mit Mittelrippe; hintere dunkler
    blaetter = []
    for i, pts in enumerate(stiele):
        for j, t in enumerate((0.46, 0.57, 0.68, 0.79, 0.90, 1.0)):
            idx = min(int(t * (len(pts) - 1)), len(pts) - 1)
            px, py = pts[idx]
            a0, a1 = pts[max(idx - 2, 0)], pts[idx]
            richt = math.atan2(a1[1] - a0[1], a1[0] - a0[0])
            seite = 1 if (i + j) % 2 else -1
            ang = richt + (0 if t == 1.0 else seite * rng.uniform(0.55, 0.85))
            ln = rng.uniform(0.19, 0.24) * (1.15 - 0.3 * t)
            bx, by = px + math.cos(ang) * ln * 0.5, py + math.sin(ang) * ln * 0.5
            blaetter.append((rng.uniform(0.0, 1.0), bx, by, ln, ang))
    blaetter.sort()
    for z, bx, by, ln, ang in blaetter:
        m = ellipse(bx, by, ln * 0.5, ln * 0.26, ang)
        ton = 0.80 + 0.30 * z
        teile.append(Teil(m, aufblasen(m, 0.025) + z * 6, stoff(0x6fae45, 0.14, int(z * 1000), 10) * ton, matt=0.40, linie=0.8))
        a = (bx - math.cos(ang) * ln * 0.46, by - math.sin(ang) * ln * 0.46)
        b = (bx + math.cos(ang) * ln * 0.38, by + math.sin(ang) * ln * 0.38)
        striche.append(strich([a, b], 0.6, 0.6))
    # kleine blasse Blüten an drei Spitzen
    for pts in (stiele[0], stiele[3], stiele[6]):
        ex, ey = pts[-1]
        for k in range(5):
            m = kreis(ex + rng.uniform(-0.03, 0.03), ey + rng.uniform(-0.045, 0.0), 0.017)
            teile.append(Teil(m, aufblasen(m, 0.017) + 9, farbe(0xc0aad0), matt=0.36, linie=0.6))
    band = vieleck([(0.405, 0.69), (0.56, 0.68), (0.565, 0.73), (0.41, 0.742)])
    windung = 0.72 + 0.28 * (np.sin((UX * 0.6 + UY) * 150) > 0)
    teile.append(Teil(band, aufblasen(band, 0.02) + 12, farbe(0xa88c5c)[None, None, :] * windung[..., None], matt=0.32))
    return male(teile, striche, saat=93)


# ------------------------------------------------------------------ Tränke (1073): Form und Farbe je Art (SupplyArt.kt)

def flasche(ton, form="rund", leucht=0.6, band=False, kappe=False, docht=False, sonne=False, zweig=False, schnur=True):
    if form == "rund":
        bauch = kreis(0.5, 0.64, 0.30); hals_b, hals_o = 0.065, 0.20; spiegel_y = 0.56
    elif form == "gross":
        bauch = kreis(0.5, 0.62, 0.34); hals_b, hals_o = 0.075, 0.16; spiegel_y = 0.50
    elif form == "hoch":
        bauch = ellipse(0.5, 0.60, 0.22, 0.32); hals_b, hals_o = 0.06, 0.12; spiegel_y = 0.44
    elif form == "bauchig":
        bauch = ellipse(0.5, 0.68, 0.33, 0.24); hals_b, hals_o = 0.08, 0.28; spiegel_y = 0.60
    else:                       # schlank
        bauch = ellipse(0.5, 0.58, 0.15, 0.32) | vieleck([(0.35, 0.58), (0.65, 0.58), (0.62, 0.90), (0.38, 0.90)]) & ellipse(0.5, 0.62, 0.15, 0.30)
        hals_b, hals_o = 0.05, 0.14; spiegel_y = 0.40
    hals = vieleck([(0.5 - hals_b, hals_o), (0.5 + hals_b, hals_o), (0.5 + hals_b + 0.005, hals_o + 0.24), (0.5 - hals_b - 0.005, hals_o + 0.24)])
    glas = bauch | hals
    lippe = ellipse(0.5, hals_o + 0.012, hals_b + 0.03, 0.032)
    korken = vieleck([(0.5 - hals_b + 0.012, hals_o - 0.11), (0.5 + hals_b - 0.012, hals_o - 0.11), (0.5 + hals_b - 0.016, hals_o + 0.012), (0.5 - hals_b + 0.016, hals_o + 0.012)])
    innen = nd.binary_erosion(bauch, iterations=int(0.03 * S))
    spiegel = spiegel_y + 0.012 * np.sin(UX * 21)
    trank = innen & (UY >= spiegel)
    hg = aufblasen(glas, 0.18)
    glasfarbe = stoff(0xb6c2bc, 0.10, 11, 30)
    c = farbe(ton)
    yy, ys = np.where(bauch)
    my = ys.mean() / S if len(ys) else 0.6; my = yy.mean() / S if len(yy) else 0.6
    schein = np.clip(1 - np.hypot(UX - 0.47, UY - (my + 0.06)) / 0.30, 0, 1) ** 1.6
    teile = [Teil(glas, hg, glasfarbe, leucht=(schein * leucht * 0.4)[..., None] * c * 0.5, matt=0.42),
             Teil(trank, hg, c * (0.82 + 0.18 * rauschen(20, 12))[..., None] * 0.7, glanz=0.35,
                  leucht=(schein * leucht)[..., None] * c * 0.9 + c * 0.1, linie=0.0, matt=0.45),
             Teil(lippe, aufblasen(lippe, 0.03), glasfarbe * 0.85, matt=0.30)]
    striche = [strich([(x, spiegel_y + 0.012 * math.sin(x * 21)) for x in np.linspace(0.15, 0.85, 40)], 0.9, 0.85)]
    striche[0] = striche[0] * innen
    poren = 1 - 0.35 * (rauschen(6, 13, 1) > 0.72)
    if kappe:
        teile.append(Teil(korken, aufblasen(korken, 0.05), _gold(14), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4])))
    elif not docht:
        teile.append(Teil(korken, aufblasen(korken, 0.05), farbe(0x9a7046)[None, None, :] * poren[..., None], matt=0.30))
    if docht:                   # Lappen im Hals, oben glimmend
        lappen = ellipse(0.5, hals_o - 0.03, 0.06, 0.07) | ellipse(0.56, hals_o - 0.10, 0.035, 0.06, 0.5)
        teile.append(Teil(lappen, aufblasen(lappen, 0.04) + 6, stoff(0xc8b48a, 0.25, 15, 8), matt=0.36))
        glut = kreis(0.585, hals_o - 0.15, 0.026)
        teile.append(Teil(glut, np.zeros((S, S)) + 10, farbe(0xffb030), leucht=np.array([120.0, 70, 10]), matt=0.5, linie=0.4))
    hn = hals_o + 0.17
    if schnur or zweig:
        sch = (UY >= hn) & (UY <= hn + 0.035) & (np.abs(UX - 0.5) <= hals_b + 0.018)
        windung = 0.75 + 0.25 * (np.sin((UX * 1.4 + UY) * 130) > 0)
        teile.append(Teil(sch, hg + 4, farbe(0xa88c5c)[None, None, :] * windung[..., None], matt=0.30, linie=0.7))
    if band:
        b = (UY >= hn - 0.05) & (UY <= hn - 0.02) & (np.abs(UX - 0.5) <= hals_b + 0.012)
        teile.append(Teil(b, hg + 5, _gold(16), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4])))
    if zweig:
        for a in (-0.5, 0.2, 0.8):
            bl = ellipse(0.5 + 0.10 + 0.05 * math.cos(a), hn - 0.02 + 0.05 * math.sin(a), 0.045, 0.02, a)
            teile.append(Teil(bl, hg + 8, farbe(0x6fae45), matt=0.40, linie=0.6))
    if sonne:
        cy = my + 0.04
        m = kreis(0.5, cy, 0.05)
        w = np.arctan2(UY - cy, UX - 0.5)
        st = (np.hypot(UX - 0.5, UY - cy) < 0.10) & (np.cos(w * 8) > 0.6) & ~m
        teile.append(Teil(st | m, hg + 6, _gold(17), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4]), linie=0.5))
    return male(teile, striche, saat=21)


TRAENKE = {
    "ding-greater_potion": dict(ton=0xc83c5a, form="gross", band=True),
    "ding-superior_potion": dict(ton=0x7a3ab0, form="hoch", band=True, kappe=True),
    "ding-remedy": dict(ton=0x4a8a2a, form="bauchig", leucht=0.3, zweig=True),
    "ding-stamina_potion": dict(ton=0xd8a020, form="schlank"),
    "ding-alchemist_fire": dict(ton=0xf07a18, form="rund", leucht=1.0, docht=True, schnur=False),
    "ding-holy_water": dict(ton=0x8ac8f0, form="schlank", leucht=0.4, sonne=True, schnur=False),
    "ding-spark_potion": dict(ton=0xe8f0ff, form="rund", leucht=1.2),
}


# ------------------------------------------------------------------ Beute und Kleinzeug (1073)

def fleisch(art):
    teile, striche = [], []
    roh = art == "raw_meat"
    stueck = ellipse(0.44, 0.52, 0.30, 0.22, -0.4)
    fett = ellipse(0.22, 0.66, 0.09, 0.12, -0.4) & stueck if roh else np.zeros((S, S), bool)
    if roh:
        mar = np.abs(np.sin(UX * 22 + UY * 14 + 4 * rauschen(30, 140, 2))) < 0.10
        grund = np.where(mar[..., None], farbe(0xe8d2c0), farbe(0x9a2a2a)) * (0.9 + 0.1 * rauschen(10, 141))[..., None]
    else:
        grund = stoff(0x8a4a20, 0.30, 142, 10)
    teile.append(Teil(stueck, aufblasen(stueck, 0.14), grund, glanz=0.0, matt=0.34))
    if roh:
        teile.append(Teil(fett, aufblasen(stueck, 0.14) + 2, farbe(0xe8d2c0), matt=0.40))
    knochen = (strich([(0.66, 0.40), (0.84, 0.24)], 9.0) > 0.5) & ~stueck
    teile.append(Teil(knochen, aufblasen(knochen, 0.02) + 6, farbe(0xf0e8da), matt=0.42))
    for c in ((0.86, 0.20), (0.88, 0.26)):
        k = kreis(c[0], c[1], 0.035)
        teile.append(Teil(k, aufblasen(k, 0.03) + 8, farbe(0xf0e8da), matt=0.42))
    if not roh:
        for k in range(4):
            striche.append(strich([(0.26 + k * 0.08, 0.40 + k * 0.02), (0.30 + k * 0.08, 0.62 + k * 0.01)], 0.7, 0.5))
    return male(teile, striche, saat=143)


def schluessel(art):
    rost = art == "rusty_key"
    ton = 0x8a5a3a if rost else 0x4a4a46
    metall = stoff(ton, 0.35 if rost else 0.15, 144, 8)
    ring = (np.abs(np.hypot(UX - 0.30, UY - 0.32) - 0.12) < 0.035)
    halm = (strich([(0.38, 0.40), (0.80, 0.82)], 9.0) > 0.5)
    bart = vieleck([(0.66, 0.74), (0.74, 0.66), (0.86, 0.66), (0.86, 0.72), (0.78, 0.72), (0.72, 0.80)])
    if not rost:                # Graks Schlüssel: grob, mit Zahn an einer Schnur
        bart = vieleck([(0.64, 0.76), (0.72, 0.68), (0.88, 0.62), (0.90, 0.70), (0.82, 0.70), (0.86, 0.78), (0.74, 0.80)])
    teile = [Teil(ring | halm | bart, aufblasen(ring | halm | bart, 0.02), metall, matt=0.40)]
    if not rost:
        zahn = vieleck([(0.18, 0.46), (0.24, 0.46), (0.20, 0.66)])
        m = strich([(0.22, 0.30), (0.21, 0.46)], 2.4) > 0.4
        teile.append(Teil(m, np.zeros((S, S)) + 4, farbe(0x4a3020), matt=0.32, linie=0.4))
        teile.append(Teil(zahn, aufblasen(zahn, 0.02) + 6, farbe(0xe0d4b4), matt=0.40))
    return male(teile, saat=145)


def beute(art):
    teile, striche = [], []
    if art == "boar_tusk":
        pts = []
        for t in np.linspace(0, 1, 30):
            a = -0.3 + t * 2.4
            rr = 0.30
            w = 0.06 * (1 - t) + 0.006
            pts.append((0.5 + rr * math.cos(a), 0.62 - rr * math.sin(a), w))
        m = np.zeros((S, S), bool)
        for i in range(len(pts) - 1):
            m |= strich([pts[i][:2], pts[i + 1][:2]], pts[i][2] * OUT * 2) > 0.5
        wurzel = np.clip((UX - 0.55) / 0.3, 0, 1)[..., None]
        teile.append(Teil(m, aufblasen(m, 0.05), farbe(0xe8dcbc) * (1 - 0.3 * wurzel) + farbe(0x8a6a3a) * 0.3 * wurzel, matt=0.42))
    elif art == "grey_rag":     # grauer Fetzen, ein offenes Auge eingestickt
        pts = [(0.18, 0.24), (0.40, 0.18), (0.62, 0.22), (0.84, 0.16), (0.80, 0.40), (0.86, 0.62), (0.76, 0.84), (0.60, 0.78),
               (0.44, 0.86), (0.30, 0.78), (0.14, 0.82), (0.20, 0.56)]
        m = vieleck(pts)
        teile.append(Teil(m, nd.gaussian_filter(aufblasen(m, 0.1) * 0.3, 3) + 3 * np.sin(UX * 30), stoff(0x7a7a74, 0.25, 154, 8), matt=0.38))
        auge = ellipse(0.50, 0.50, 0.16, 0.08)
        teile.append(Teil(auge & m, aufblasen(auge, 0.02) + 6, farbe(0xd8d0c0), matt=0.40, linie=0.8))
        teile.append(Teil(kreis(0.50, 0.50, 0.05), np.zeros((S, S)) + 8, farbe(0x2a2a3a), matt=0.30, linie=0.4))
    elif art == "gwenna_ring":  # schmaler Ring aus angelaufenem Silber
        reif = (np.abs(np.hypot((UX - 0.5) / 0.26, (UY - 0.56) / 0.20) - 1) < 0.13)
        silber = stoff(0x9a9ca0, 0.25, 155, 8)
        teile.append(Teil(reif & (UY <= 0.56), aufblasen(reif, 0.02), silber * 0.7, glanz=0.2, matt=0.45))
        teile.append(Teil(reif & (UY > 0.56), aufblasen(reif, 0.02) + 6, silber, glanz=0.3, matt=0.45))
    elif art == "sun_amulet":
        _kette([(0.5 + 0.30 * math.sin(t), 0.52 - 0.40 * (1 - math.cos(t)) / (1 - math.cos(1.35))) for t in np.linspace(-1.35, 1.35, 30)], teile, 156)
        cx, cy = 0.5, 0.66
        m = kreis(cx, cy, 0.11)
        w = np.arctan2(UY - cy, UX - cx)
        st = (np.hypot(UX - cx, UY - cy) < 0.22) & (np.cos(w * 12) > 0.4) & ~m
        teile.append(Teil(st, aufblasen(st, 0.02) + 4, _gold(157, 0.9), glanz=1.2, matt=0.5, leucht=np.array([30.0, 20, 4])))
        teile.append(Teil(m, aufblasen(m, 0.1) + 8, _gold(158), glanz=1.8, matt=0.5, leucht=np.array([44.0, 30, 6])))
    elif art == "prophet_letter":
        blatt = vieleck([(0.16, 0.26), (0.84, 0.20), (0.86, 0.74), (0.18, 0.80)])
        teile.append(Teil(blatt, nd.gaussian_filter(aufblasen(blatt, 0.1) * 0.2, 3), stoff(0xd8ccaa, 0.18, 159, 10), matt=0.42))
        for k in range(5):
            y = 0.34 + k * 0.08
            striche.append(strich([(0.24, y), (0.74 - 0.08 * (k == 4), y - 0.012)], 0.7, 0.6))
        siegel = kreis(0.56, 0.72, 0.08)
        teile.append(Teil(siegel, aufblasen(siegel, 0.05) + 6, farbe(0x8a1a1a), glanz=0.3, matt=0.40))
        striche.append(strich([(0.53, 0.70), (0.56, 0.74), (0.59, 0.70)], 0.9, 0.9))
    elif art == "smoke_bundle":
        bund = vieleck([(0.36, 0.40), (0.56, 0.36), (0.66, 0.84), (0.44, 0.88)])
        teile.append(Teil(bund, aufblasen(bund, 0.06), stoff(0x7a7a4a, 0.25, 161, 8) * (0.85 + 0.15 * gestreckt(2, 20, 162, 10))[..., None], matt=0.36))
        for y in (0.52, 0.72):
            b = bund & (np.abs(UY - y) < 0.02)
            teile.append(Teil(b, aufblasen(bund, 0.06) + 4, farbe(0xa88c5c), matt=0.32))
        rauch = (ellipse(0.48, 0.28, 0.08, 0.06) | ellipse(0.40, 0.18, 0.07, 0.05) | ellipse(0.50, 0.10, 0.06, 0.04))
        teile.append(Teil(rauch, np.zeros((S, S)), farbe(0xb0aca4), matt=0.6, linie=0.3, deckung=0.75))
        glut = kreis(0.46, 0.38, 0.03)
        teile.append(Teil(glut, np.zeros((S, S)) + 8, farbe(0xd85a10), leucht=np.array([90.0, 40, 4]), matt=0.5, linie=0.3))
    return male(teile, striche, saat=163)


# ------------------------------------------------------------------ Tierteile (1073, zweiter Anlauf; Zerlegen nach werte.json)

def _fell(ton, saat, dunkel=0.0):
    f = farbe(ton)[None, None, :] * (0.78 + 0.22 * gestreckt(2, 9, saat, 70))[..., None]
    return f * (1 - dunkel * np.clip(1 - np.abs(UX - 0.5) / 0.18, 0, 1))[..., None]


def tierteil(art):
    teile, striche = [], []
    if art in ("wolf_pelt", "small_pelt"):
        k = 1.0 if art == "wolf_pelt" else 0.72
        o = (1 - k) / 2
        P = lambda x, y: (o + x * k, o * 0.6 + y * k)
        # Kopf mit Ohren und Schnauze oben, Vorderläufe, Leib, Hinterläufe, Schwanz
        pts = [P(0.44, 0.06), P(0.40, 0.14), P(0.34, 0.08), P(0.36, 0.22), P(0.28, 0.26), P(0.10, 0.24), P(0.12, 0.32), P(0.30, 0.36),
               P(0.30, 0.60), P(0.12, 0.70), P(0.10, 0.80), P(0.30, 0.74), P(0.42, 0.80), P(0.46, 0.97), P(0.54, 0.97), P(0.58, 0.80),
               P(0.70, 0.74), P(0.90, 0.80), P(0.88, 0.70), P(0.70, 0.60), P(0.70, 0.36), P(0.88, 0.32), P(0.90, 0.24), P(0.72, 0.26),
               P(0.64, 0.22), P(0.66, 0.08), P(0.60, 0.14), P(0.56, 0.06), P(0.50, 0.02)]
        m = vieleck(pts)
        ton = 0x707470 if art == "wolf_pelt" else 0x6a5a48
        teile.append(Teil(m, nd.gaussian_filter(aufblasen(m, 0.08) * 0.5, 3), _fell(ton, 151, 0.45), matt=0.36))
        for sx in (-1, 1):            # Augenlöcher
            teile.append(Teil(ellipse(0.5 + sx * 0.04 * k, o * 0.6 + 0.15 * k, 0.018 * k, 0.012 * k), np.zeros((S, S)) + 6, np.full(3, 20.0), matt=0.1, linie=0.4))
        striche.append(strich([P(0.5, 0.30), P(0.5, 0.86)], 0.7, 0.5))
        for y in np.linspace(0.36, 0.80, 6):
            striche.append(strich([P(0.30, y), P(0.33, y + 0.02)], 0.6, 0.6)); striche.append(strich([P(0.70, y), P(0.67, y + 0.02)], 0.6, 0.6))
    elif art == "bat_wing":       # Flügel aufgespannt: Arm zum Handgelenk, vier Finger gefächert, Haut dazwischen gebuchtet
        basis, hand = (0.10, 0.56), (0.30, 0.20)
        spitzen = [(0.92, 0.16), (0.90, 0.46), (0.72, 0.74), (0.42, 0.86)]
        pts = [basis, hand, spitzen[0]]
        for a, b in zip(spitzen, spitzen[1:]):
            mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
            pts += [(mx + (hand[0] - mx) * 0.30, my + (hand[1] - my) * 0.30), b]
        pts += [(0.24, 0.72)]
        haut = vieleck(pts)
        teile.append(Teil(haut, nd.gaussian_filter(aufblasen(haut, 0.12) * 0.3, 3), stoff(0x6a4c40, 0.18, 153, 10), matt=0.40))
        knochen = strich([basis, hand], 8.0) > 0.5
        for sp in spitzen:
            knochen |= strich([hand, sp], 3.0) > 0.5
        teile.append(Teil(knochen & (haut | (strich([basis, hand], 8.0) > 0.5)), aufblasen(knochen, 0.02) + 6, farbe(0x3a2a26), matt=0.34, linie=0.4))
        kralle = vieleck([(hand[0] - 0.02, hand[1] + 0.01), (hand[0] - 0.05, hand[1] - 0.09), (hand[0] + 0.03, hand[1] - 0.02)])
        teile.append(Teil(kralle, aufblasen(kralle, 0.01) + 8, farbe(0x1e1614), matt=0.3))
    elif art in ("spider_gland", "venom_gland"):
        spinne = art == "spider_gland"
        sack = ellipse(0.46, 0.58, 0.24, 0.20, 0.35)
        ton = 0x6a8a2a if spinne else 0x8a7a2a
        teile.append(Teil(sack, aufblasen(sack, 0.2), stoff(ton, 0.2, 152, 12), glanz=0.7, matt=0.40, leucht=np.array([8.0, 16, 0])))
        for kk in range(6):
            a = kk * 1.05 + 0.3
            striche.append(strich([(0.46 + 0.05 * math.cos(a), 0.58 + 0.04 * math.sin(a)), (0.46 + 0.14 * math.cos(a + 0.25), 0.58 + 0.12 * math.sin(a + 0.25)),
                                   (0.46 + 0.21 * math.cos(a + 0.1), 0.58 + 0.17 * math.sin(a + 0.1))], 0.8, 0.55))
        if spinne:                    # zwei schwarze Klauen am Gang: daran erkennt man die Spinne
            for dx in (-0.05, 0.06):
                kl = vieleck([(0.56 + dx, 0.44), (0.66 + dx, 0.38), (0.74 + dx, 0.24), (0.80 + dx, 0.12), (0.74 + dx, 0.30), (0.72 + dx, 0.44), (0.62 + dx, 0.50)])
                teile.append(Teil(kl, aufblasen(kl, 0.02) + 10, farbe(0x1e1a1c), glanz=0.3, matt=0.34))
        else:                         # Hundertfüßer: Gang mit Zange
            kl = strich([(0.64, 0.44), (0.76, 0.30), (0.82, 0.30), (0.84, 0.36)], 6.0) > 0.5
            teile.append(Teil(kl & ~sack, aufblasen(kl, 0.02) + 6, farbe(0x6a3a1a), matt=0.34))
        tropfen = ellipse(0.88 if spinne else 0.86, 0.18 if spinne else 0.48, 0.022, 0.032)
        teile.append(Teil(tropfen, aufblasen(tropfen, 0.02) + 12, farbe(0x9ad040), glanz=0.8, leucht=np.array([30.0, 60, 6]), matt=0.5, linie=0.5))
    elif art == "spider_silk":    # Spinnseide: ein Netz in einer Astgabel, daran ein dicker weißer Strang aufgewickelt
        ast = (strich([(0.12, 0.92), (0.44, 0.52), (0.40, 0.10)], 7.0) > 0.5) | (strich([(0.44, 0.52), (0.88, 0.30)], 6.0) > 0.5)
        teile.append(Teil(ast, aufblasen(ast, 0.02), _holz(164, 0x5a3e28), matt=0.32))
        mitte = (0.62, 0.30)
        netz = np.zeros((S, S))
        for a in np.linspace(0, math.pi * 2, 9)[:-1]:
            netz = np.maximum(netz, strich([mitte, (mitte[0] + 0.22 * math.cos(a), mitte[1] + 0.20 * math.sin(a))], 1.5, 1.0))
        for rr in (0.06, 0.11, 0.16, 0.20):
            pts = [(mitte[0] + rr * math.cos(a), mitte[1] + rr * 0.9 * math.sin(a)) for a in np.linspace(0, math.pi * 2, 9)]
            netz = np.maximum(netz, strich(pts, 1.4, 1.0))
        nm = (netz > 0.3) & ~ast & (UY < 0.52) & (UX > 0.42)
        teile.append(Teil(nm, np.zeros((S, S)) + 4, farbe(0xeeeee8), matt=0.6, linie=0.0))
        knaeuel = ellipse(0.40, 0.70, 0.16, 0.13, -0.5)
        faeden = 0.78 + 0.22 * (np.sin((UX * 0.6 - UY) * 280) > 0)
        teile.append(Teil(knaeuel, aufblasen(knaeuel, 0.11), farbe(0xf0f0ea)[None, None, :] * faeden[..., None], glanz=0.3, matt=0.55))
    elif art == "bandage":        # Verband: Rolle Leinen von der Seite, das Ende läuft lose aus
        s_, q, d, lang = achse((0.18, 0.40), (0.62, 0.40))
        rolle = (UX >= 0.22) & (UX <= 0.62) & (np.abs(UY - 0.42) <= 0.16)
        rolle |= ellipse(0.62, 0.42, 0.07, 0.16)
        stirn = ellipse(0.22, 0.42, 0.07, 0.16)
        binde = farbe(0xe8e0cc)[None, None, :] * (0.86 + 0.14 * (np.sin(UX * 300) > 0.6) + 0.06 * rauschen(8, 160, 1))[..., None]
        lauf = vieleck([(0.50, 0.56), (0.62, 0.56), (0.80, 0.70), (0.90, 0.86), (0.76, 0.90), (0.64, 0.74), (0.48, 0.60)])
        teile.append(Teil(lauf, aufblasen(lauf, 0.02) + 3 * np.sin(UX * 20), binde * 0.95, matt=0.42))
        hr = np.clip(1 - ((UY - 0.42) / 0.16) ** 2, 0, 1) ** 0.5 * 0.05 * S
        teile.append(Teil(rolle, hr, binde, matt=0.42, k=0.8))
        teile.append(Teil(stirn, hr + 4, binde * 0.92, matt=0.40, linie=0.8))
        for rr in (0.4, 0.7):
            striche.append(((np.abs(np.hypot((UX - 0.22) / (0.07 * rr), (UY - 0.42) / (0.16 * rr)) - 1) < 0.08) & stirn).astype(float) * 0.7)
        striche.append(strich([(0.22, 0.42), (0.225, 0.42)], 1.4, 1.0))
    elif art == "bone":           # Knochen eines Skeletts: Röhrenknochen mit zwei Gelenkköpfen
        s_, q, d, lang = achse((0.20, 0.78), (0.80, 0.22))
        schaft = (s_ >= 0.08) & (s_ <= lang - 0.08) & (np.abs(q) <= 0.045 + 0.01 * np.cos((s_ / lang) * math.pi * 2))
        m = schaft.copy()
        for t in (0.0, 1.0):
            c = (0.20 + d[0] * lang * (0.06 + 0.88 * t), 0.78 + d[1] * lang * (0.06 + 0.88 * t))
            n = (-d[1], d[0])
            for sx in (-1, 1):
                m |= kreis(c[0] + n[0] * 0.045 * sx, c[1] + n[1] * 0.045 * sx, 0.065)
        alt = stoff(0xe0d4b4, 0.18, 165, 10)
        teile.append(Teil(m, aufblasen(m, 0.05), alt, matt=0.42))
        for f in range(3):
            striche.append(strich([(0.40 + f * 0.06, 0.58 - f * 0.06), (0.44 + f * 0.06, 0.55 - f * 0.06)], 0.6, 0.5))
    elif art == "teeth":          # Wolfszähne an einer Schnur
        sch = [(0.12 + 0.76 * t, 0.30 + 0.30 * math.sin(t * math.pi)) for t in np.linspace(0, 1, 30)]
        m = strich(sch, 2.6) > 0.4
        teile.append(Teil(m, np.zeros((S, S)), farbe(0x4a3020), matt=0.32, linie=0.4))
        for kk, t in enumerate(np.linspace(0.18, 0.82, 5)):
            x, y = 0.12 + 0.76 * t, 0.30 + 0.30 * math.sin(t * math.pi)
            ln = 0.20 if kk == 2 else 0.15
            z = vieleck([(x - 0.035, y), (x + 0.035, y), (x + 0.01, y + ln * 0.7), (x, y + ln)])
            teile.append(Teil(z, aufblasen(z, 0.02) + 6, stoff(0xece2c8, 0.1, 166 + kk, 6), matt=0.44))
    elif art == "hide":           # Schwarte: ein Stück borstige Wildschweinhaut, Rand eingerollt
        pts = [(0.14, 0.30), (0.42, 0.18), (0.74, 0.20), (0.88, 0.42), (0.82, 0.72), (0.56, 0.84), (0.26, 0.80), (0.12, 0.58)]
        m = vieleck(pts)
        teile.append(Teil(m, nd.gaussian_filter(aufblasen(m, 0.08) * 0.5, 3), _fell(0x5a4232, 167), matt=0.34))
        innen = nd.binary_erosion(m, iterations=int(0.05 * S))
        rand = m & ~innen & (UY > 0.6)
        teile.append(Teil(rand, aufblasen(m, 0.08) * 0.5 + 4, farbe(0xc8a890), matt=0.40))
        rng = np.random.default_rng(168)
        for _ in range(40):
            x, y = rng.uniform(0.2, 0.8), rng.uniform(0.25, 0.7)
            striche.append(strich([(x, y), (x + 0.01, y - 0.03)], 0.5, 0.7))
    elif art == "chitin_plates":  # Panzerplatten: drei gewölbte Glieder, rotbraun glänzend
        for kk in range(3):
            cx_, cy_ = 0.30 + kk * 0.18, 0.36 + kk * 0.16
            pl = vieleck([(cx_ - 0.17, cy_ - 0.02), (cx_ - 0.08, cy_ - 0.11), (cx_ + 0.12, cy_ - 0.09), (cx_ + 0.18, cy_ + 0.02), (cx_ + 0.07, cy_ + 0.10), (cx_ - 0.12, cy_ + 0.08)])
            teile.append(Teil(pl, aufblasen(pl, 0.06) + kk * 10, stoff(0x7a3a1a, 0.15, 169 + kk, 10), glanz=0.5, matt=0.40, k=1.0))
            striche.append(strich([(cx_ - 0.12, cy_ + 0.02), (cx_ + 0.13, cy_ - 0.01)], 0.7, 0.7))
    elif art == "acid":           # Säure: Phiole mit grünlich-gelber, rauchender Flüssigkeit
        return flasche(0xb8d020, form="schlank", leucht=0.9, schnur=False)
    return male(teile, striche, saat=170)


# ------------------------------------------------------------------ Gold

def muenze(cx, cy, rx, ry, dicke, saat):
    oben = ellipse(cx, cy, rx, ry)
    seite = (ellipse(cx, cy + dicke, rx, ry) | ((np.abs(UX - cx) <= rx) & (UY >= cy) & (UY <= cy + dicke))) & ~oben
    gold = stoff(0xe9bb48, 0.10, saat, 14)
    rillen = 0.78 + 0.22 * (np.sin(UX * 420) > 0)
    hs = aufblasen(seite | oben, 0.03)
    t_seite = Teil(seite, hs, gold * 0.80 * rillen[..., None], glanz=0.9, matt=0.50, linie=0.8, leucht=np.array([34.0, 22, 4]))
    # Gesicht: erhabener Rand und eine Sonne in der Mitte (geprägt)
    e = ((UX - cx) / rx) ** 2 + ((UY - cy) / ry) ** 2
    praeg = np.where(e > 0.70, 1.0, 0.0) * np.clip((1 - e) * 8, 0, 1)
    sonne_r = np.hypot((UX - cx) / rx, (UY - cy) / ry)
    w = np.arctan2((UY - cy) / ry, (UX - cx) / rx)
    sonne = (sonne_r < 0.25) | ((sonne_r < 0.48) & (np.cos(w * 8) > 0.55) & (sonne_r > 0.25))
    hf = aufblasen(oben, 0.05) * 0.4 + praeg * 5 + sonne * 4
    t_oben = Teil(oben, hf, gold, glanz=1.8, matt=0.52, k=1.3, leucht=np.array([40.0, 28, 6]))
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
for _n, _kw in TRAENKE.items():
    DINGE[_n] = (lambda _kw=_kw: flasche(**_kw))
DINGE["ding-raw_meat"] = lambda: fleisch("raw_meat")
DINGE["ding-roast_meat"] = lambda: fleisch("roast_meat")
DINGE["ding-rusty_key"] = lambda: schluessel("rusty_key")
DINGE["ding-grak_key"] = lambda: schluessel("grak_key")
for _n in ("boar_tusk", "grey_rag", "gwenna_ring", "sun_amulet", "prophet_letter", "smoke_bundle"):
    DINGE["ding-" + _n] = (lambda _n=_n: beute(_n))
for _n in ("wolf_pelt", "spider_gland", "bat_wing", "bandage", "spider_silk"):
    DINGE["ding-" + _n] = (lambda _n=_n: tierteil(_n))
# Zerlegen (werte.json „zerlegen“): noch ohne Kennung im Spiel, Bilder liegen bereit; Kennung = Dateiname
for _n in ("bone", "teeth", "hide", "small_pelt", "venom_gland", "chitin_plates", "acid"):
    DINGE["ding-" + _n] = (lambda _n=_n: tierteil(_n))
STUECKE = {"leather_cap": lederkappe, "round_shield": rundschild}
for _art in ("handaxe", "battleaxe", "greataxe", "halberd", "spear", "mace", "morningstar", "warhammer", "maul", "quarterstaff", "staff", "wand"):
    STUECKE[_art] = (lambda r="COMMON", _a=_art: schaftwaffe(_a, r))
for _art in ("shortbow", "longbow", "light_crossbow"):
    STUECKE[_art] = (lambda r="COMMON", _a=_art: bogen(_a, r))
for _art in ("shield", "tower_shield"):
    STUECKE[_art] = (lambda r="COMMON", _a=_art: schild(_a, r))
for _art in ("leather", "studded_leather", "chain_shirt", "chain_mail", "scale_mail", "breastplate", "half_plate", "splint", "plate", "robe"):
    STUECKE[_art] = (lambda r="COMMON", _a=_art: ruestung(_a, r))
for _art, _f in (("helmet", kopfteil), ("great_helm", kopfteil), ("hood", kopfteil), ("circlet", kopfteil), ("gloves", handteil),
                 ("gauntlets", handteil), ("bracers", handteil), ("wraps", handteil), ("boots", beinteil), ("leggings", beinteil),
                 ("chain_leggings", beinteil), ("greaves", beinteil)):
    STUECKE[_art] = (lambda r="COMMON", _a=_art, _f=_f: _f(_a, r))
for _art, _f in (("amulet", schmuck), ("talisman", schmuck), ("holy_symbol", schmuck), ("ring", schmuck), ("signet", schmuck),
                 ("cloak", umhang), ("mantle", umhang), ("orb", zauberding), ("tome", zauberding), ("torch", zauberding)):
    STUECKE[_art] = (lambda r="COMMON", _a=_art, _f=_f: _f(_a, r))
for _art in KLINGEN:
    STUECKE[_art] = (lambda r="COMMON", _a=_art: klinge(_a, r))


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
