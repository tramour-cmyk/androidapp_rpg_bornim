# 455.1 Baukasten (Chef 01.11., 11:24; Archiv 455): Material und Zeichen als Bildmuster auf ein vorhandenes Netz, nur numpy.
# Ein Gegenstand = Netz x Material x Zeichen; das Netz bleibt, Material und Zeichen stehen im Farbbild (Godot tauscht nur das Bild).
# Alpha im Bild traegt die Art fuer toon.gdshader (bild_code): 1 matt, 0,8 Glimmen (Runen), 0,5 Kette (Glanz wie das Kettenhemd),
# 0,1 Gold (Glanz in Goldfarbe; Signatur: Gold einziger Glanz). Farben sRGB 0-1 wie sonne() in held_klassen.py.
# Eingaben je Bildpunkt: P (Ruhelage, Blender Z oben, m), N (Flaechennormale), S (Helligkeit des alten Bilds / Median: Falten, Naehte
# bleiben gezeichnet), Band (v 0-1 quer, s entlang, m) fuer Borte und Runen.
import numpy as np

GOLD = (0.72, 0.565, 0.29)   # wie alt (Dress.kt gold B8904A), sonne() in held_klassen.py
MATT, GLIMMEN, KETTE, GLANZ = 1.0, 0.8, 0.5, 0.1

# Grundfarbe je Material und Zeichen; Borte (Zeichen 1) in Bortenfarbe, Runen (Zeichen 2) gold auf dunklem Band
FARBEN = {
    ('stoff', 'borte'): (0.42, 0.13, 0.10), ('stoff', 'runen'): (0.13, 0.16, 0.27),   # Krapprot, Nachtblau
    ('leder', 'borte'): (0.40, 0.24, 0.14), ('leder', 'runen'): (0.15, 0.12, 0.11),   # Rotbraun, Schwarzleder
    ('kette', 'borte'): (0.50, 0.51, 0.54), ('kette', 'runen'): (0.27, 0.28, 0.31),   # blankes Eisen, bruenierte Kette
    ('fell', 'borte'): (0.36, 0.27, 0.18), ('fell', 'runen'): (0.40, 0.40, 0.38),     # Braunfell, Wolfsgrau
}
BORTE = {'stoff': (0.62, 0.47, 0.20), 'leder': (0.22, 0.13, 0.08), 'kette': (0.58, 0.45, 0.22), 'fell': (0.25, 0.16, 0.10)}  # Ocker, Dunkelleder, Messing, Lederkante
WORT = {'stoff': 'Stoff', 'leder': 'Leder', 'kette': 'Kette', 'fell': 'Fell', 'borte': 'Farbe, Borte', 'runen': 'Runen, verzaubert'}


def _h(i, j, seed):
    return np.modf(np.abs(np.sin(i * 127.1 + j * 311.7 + seed * 74.7) * 43758.5453))[0]


def rauschen(x, y, seed=0.0):
    # Wertrauschen 0-1, weich zwischen den Gitterpunkten
    xi, yi = np.floor(x), np.floor(y)
    fx, fy = x - xi, y - yi
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b = _h(xi, yi, seed), _h(xi + 1, yi, seed)
    c, d = _h(xi, yi + 1, seed), _h(xi + 1, yi + 1, seed)
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


def ebene(P, N):
    # Muster-Koordinaten (a, b) je Bildpunkt: Projektion auf die Ebene quer zur staerksten Normalenachse, b moeglichst senkrecht (Z);
    # x gespiegelt (|x|), weil linke und rechte Seite der Kaufnetze oft dieselben Bildpunkte teilen
    x, y, z = np.abs(P[:, 0]), P[:, 1], P[:, 2]
    ax = np.argmax(np.abs(N), axis=1)
    a = np.where(ax == 0, y, x)
    b = np.where(ax == 2, y, z)
    return a, b


def ringe(a, b, p=0.012):
    # Kettengeflecht: versetzte Reihen von Ringen, Teilung p (m); 1 auf dem Ring, 0 in der Luecke
    zh = p * 0.8
    r = np.floor(b / zh)
    off = (r % 2) * p / 2
    cx = (np.floor((a + off) / p) + 0.5) * p - off
    cy = (r + 0.5) * zh
    d = np.hypot(a - cx, b - cy) / p
    return 1.0 - np.clip(np.abs(d - 0.36) / 0.14, 0, 1) ** 2


def material(mat, a, b):
    # Helligkeitsfaktor des Materials (um 1) und Art (Alpha)
    if mat == 'stoff':
        m = 1 + 0.16 * (rauschen(a / 0.02, b / 0.02, 1) - 0.5) + 0.06 * (rauschen(a / 0.004, b / 0.05, 2) - 0.5)
        return m, MATT
    if mat == 'leder':
        m = 1 + 0.30 * (rauschen(a / 0.045, b / 0.045, 3) - 0.5) + 0.14 * (rauschen(a / 0.011, b / 0.011, 4) - 0.5)
        return m, MATT
    if mat == 'kette':
        return 0.42 + 0.78 * ringe(a, b), KETTE
    if mat == 'fell':   # Haarstriche laengs (b), dunkle Spitzen in Flecken
        m = 0.70 + 0.55 * rauschen(a / 0.005, b / 0.035, 5) - 0.18 * (rauschen(a / 0.06, b / 0.09, 6) > 0.62)
        return m, MATT
    raise ValueError(mat)


def _strecke(x, y, x0, y0, x1, y1):
    dx, dy = x1 - x0, y1 - y0
    t = np.clip(((x - x0) * dx + (y - y0) * dy) / (dx * dx + dy * dy), 0, 1)
    return np.hypot(x - x0 - t * dx, y - y0 - t * dy)


# Runen: Stamm und Zweige wie im Futhark, je Zelle zwei bis drei Zweige nach Zufall der Zellnummer
ZWEIGE = [(0.5, 0.9, 0.82, 0.62), (0.5, 0.62, 0.82, 0.36), (0.5, 0.9, 0.18, 0.62), (0.5, 0.5, 0.18, 0.22), (0.5, 0.36, 0.82, 0.1),
          (0.18, 0.9, 0.82, 0.1)]


def runen(s, v, hoehe, dicke=0.0045):
    # s entlang (m), v quer 0-1, hoehe des Bands (m): True auf einem Strich
    zb = hoehe * 0.72
    c = np.floor(s / zb)
    u = s / zb - c
    x, y = u * zb, v * hoehe
    nah = _strecke(x, y, 0.5 * zb, 0.1 * hoehe, 0.5 * zb, 0.9 * hoehe)
    h = (_h(c, 0.0, 9) * 64).astype(int)
    for k, (x0, y0, x1, y1) in enumerate(ZWEIGE):
        an = ((h >> k) & 1).astype(bool) | ((h % 6) == k)
        d = _strecke(x, y, x0 * zb, y0 * hoehe, x1 * zb, y1 * hoehe)
        nah = np.where(an, np.minimum(nah, d), nah)
    return nah < dicke / 2


def male(mat, zeichen, P, N, S, band_v, band_s, band_h):
    # Farbe (n, 3) und Art (n) je Bildpunkt; band_v: NaN ausserhalb des Bands
    a, b = ebene(P, N)
    m, art = material(mat, a, b)
    S = np.clip(S, 0.6, 1.3) ** (0.5 if mat in ('kette', 'fell') else 0.85)
    grund = np.array(FARBEN[(mat, zeichen)], dtype=np.float32)
    rgb = grund[None, :] * (S * m)[:, None]
    alpha = np.full(len(P), art, dtype=np.float32)
    im = ~np.isnan(band_v)
    v = np.nan_to_num(band_v)
    if zeichen == 'borte':
        bc = np.array(BORTE[mat], dtype=np.float32)
        hell = (S * (m if mat == 'kette' else 1 + 0.08 * (rauschen(a / 0.01, b / 0.01, 7) - 0.5)))[:, None]
        rgb = np.where(im[:, None], bc[None, :] * hell, rgb)
        linie = im & ((np.abs(v - 0.14) < 0.05) | (np.abs(v - 0.86) < 0.05))
        rgb = np.where(linie[:, None], rgb * 0.55, rgb)
        if mat == 'leder':   # Naht: helle Stiche alle 8 mm
            stich = im & (np.abs(v - 0.3) < 0.06) & ((band_s % 0.008) < 0.0045)
            rgb = np.where(stich[:, None], np.array((0.55, 0.42, 0.28), dtype=np.float32)[None, :] * S[:, None], rgb)
    else:
        rgb = np.where(im[:, None], rgb * 0.5, rgb)
        alpha = np.where(im & (mat != 'kette'), MATT, alpha)
        g = np.array(GOLD, dtype=np.float32)[None, :] * np.clip(S, 0.85, 1.15)[:, None]
        rand = im & ((v < 0.09) | (v > 0.91))
        zeich = im & ~rand & runen(np.nan_to_num(band_s), v, band_h)
        rgb = np.where((rand | zeich)[:, None], g, rgb)
        alpha = np.where(rand, GLANZ, np.where(zeich, GLIMMEN, alpha))
    return np.clip(rgb, 0, 1), alpha
