# 348.9 (Jerry): die Riesenratte (giant_rat) aus dem Grundmodell Vierbeiner (vierbeiner.py), Vorlage Beast.kt rat():
# geduckter Rumpf, Rücken über der Lende am höchsten, runde Kruppe, schmale Brust, großer Kopf ohne Hals mit langer spitzer
# Schnauze, rosa Nase, immer sichtbare orange Nagezähne, rote Knopfaugen, große runde dünne nackte Ohren (eines zerrissen),
# rosa Hände mit Krallen, lange nackte geringelte Rute, die am Boden nachschleift, Räude (kahle, verschorfte Flecken).
# Maße aus Beast.kt (k ≈ 0,0095 m): Schulter 0,3 m, Nase bis Kruppe 0,77 m, Rute 0,58 m (alt: 39 gegen Wolf 76).
# Runde 2 (Prüfer Runde 1: Zähne unsichtbar, Ohren wie Hörnchen, Rute dunkel ohne Ringe, Räude und Pfoten unsichtbar,
# „Meerschwein“, schwarz reine Silhouette, harmlos): Gelenke nach Beast.kt, Ohren als Schalen, Rute als geringeltes Rohr,
# Zähne, Augen, Zehen als Anbau, Räude am nächsten Punkt der Haut, dichteres Netz.
# Felle wie BeastArt.RAT_COATS (fur, saddle, belly, eye, Räude, zerrissenes Ohr): BRAUN, GRAU, SCHWARZ.
# Aufruf: OUT=<ordner> FELL=braun|grau|schwarz python -I ratte.py  ->  <OUT>/giant_rat-<fell>.glb, giant_rat-info.json
import os, sys, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vierbeiner as vb      # lädt bpy, danach erst mathutils
import numpy as np
from mathutils import Vector
from vierbeiner import rgb

ID = 'giant_rat'
SCHULTER = 0.3
COATS = {
    'braun':   (0x4A3C34, 0x2A201C, 0x6A5C50, 0xE01E14, False, False),
    'grau':    (0x55504C, 0x2A2826, 0x7A726A, 0xF03A20, True, False),
    'schwarz': (0x2A2624, 0x121010, 0x4A4240, 0xF04A28, False, True),
}
HELL = {'braun': 1.26, 'grau': 0.94, 'schwarz': 2.7}     # Median im Kampfbild wie alt (alt braun 44, grau 60, schwarz 34; Runde 5: 44, 60, 35; Runde 2: 25, 57, 16, Prüfer: Silhouette)
SATT = {'braun': 0.75, 'grau': 0.3, 'schwarz': 0.5}      # braun sonst bunter als alt; Runde 4: grau und schwarz kühler (Prüfer Runde 3: alle drei „dunkelgraubraun“)
LIFT = 2.0
AUFLOESUNG = 0.006
DREIECKE = 8000
OHR_KETTE = False
# Beast.kt: skin, tailSkin, earSkin, scab, incisor, claw; Runde 3 kühler und blasser (Prüfer Runde 2: in der warmen Sonne
# lasen sich Pfoten „glühend orange“, Räude „blutig“, Rute „rotbraun“); RING = Schuppenring, OHRINNEN
HAUT, RUTE, RING, OHRHAUT, OHRINNEN, SCHORF, ZAHN, KRALLE = 0xB49490, 0xA08C88, 0x8C7672, 0x9A7874, 0x6E4A48, 0x5A3C34, 0xE0B060, 0x2A2220

# ---------------------------------------------------------------- Gelenke (Meter; x quer, -y vorn, z oben), nach Beast.kt
J = {
    'wurzel': (0, 0, 0),
    'becken': (0, 0.20, 0.215), 'kreuz': (0, 0.05, 0.24), 'brust': (0, -0.11, 0.215), 'widerrist': (0, -0.20, 0.235),
    'hals': (0, -0.235, 0.245), 'kopf': (0, -0.275, 0.255), 'schnauze': (0, -0.37, 0.228), 'nase': (0, -0.425, 0.203),
    'kiefer': (0, -0.30, 0.214), 'kinn': (0, -0.385, 0.19),
    'backeL': (0.024, -0.385, 0.212), 'backeR': (-0.024, -0.385, 0.212),
    'rute0': (0, 0.27, 0.205), 'rute1': (0, 0.45, 0.03), 'rute2': (0, 0.86, 0.012),
    'ohrL0': (0.045, -0.255, 0.30), 'ohrL1': (0.07, -0.255, 0.35), 'ohrR0': (-0.045, -0.255, 0.30), 'ohrR1': (-0.07, -0.255, 0.35),
}
for s in 'LR':
    vb.beine(J, s, schulter=(0.055, -0.13, 0.18), ellbogen=(0.055, -0.10, 0.10), vfuss=(0.05, -0.15, 0.03), vpfote=(0.05, -0.18, 0.012),
             huefte=(0.065, 0.20, 0.21), knie=(0.07, 0.13, 0.12), sprung=(0.06, 0.245, 0.045), hpfote=(0.06, 0.205, 0.012), hzehe=(0.06, 0.15, 0.01))
BLOBS = [
    ('becken', 'kreuz', 0.092, 0.098, 'becken'), ('kreuz', 'brust', 0.098, 0.082, 'ruecken'), ('brust', 'widerrist', 0.082, 0.07, 'brust'),
    ('widerrist', 'hals', 0.07, 0.068, 'hals'), ('hals', 'kopf', 0.068, 0.066, 'kopf'),
    ('kopf', 'schnauze', 0.062, 0.038, 'schnauze'), ('schnauze', 'nase', 0.036, 0.022, 'schnauze'),
    # Runde 4: Schnurrhaarpolster, Schnauze kürzer und stumpfer (Prüfer Runde 3: „Rüssel“, „Spitzmaus“)
    ('backeL', 'backeL', 0.022, 0.022, 'schnauze'), ('backeR', 'backeR', 0.022, 0.022, 'schnauze'),
]
for s in 'LR':
    BLOBS += [('schulter' + s, 'ellbogen' + s, 0.044, 0.028, 'oberarm' + s), ('ellbogen' + s, 'vfuss' + s, 0.025, 0.017, 'unterarm' + s),
              ('vfuss' + s, 'vpfote' + s, 0.016, 0.018, 'vpfote' + s),
              ('huefte' + s, 'knie' + s, 0.056, 0.032, 'schenkel' + s), ('knie' + s, 'sprung' + s, 0.026, 0.016, 'unterschenkel' + s),
              ('sprung' + s, 'hpfote' + s, 0.015, 0.017, 'hpfote' + s), ('hpfote' + s, 'hzehe' + s, 0.017, 0.014, 'hpfote' + s)]
KB = {}
KNUBBEL = [('knie', 0.028, (0, 0, 0))]
OHR = (0.026, 0.022)
KIEFER = (0.03, 0.015)
SX = 0.95
SZ = (0.03, 0.8)    # Runde 4: über 3 cm flacher (Prüfer Runde 3: von vorn „überhoher, schmaler Buckel“, Beine stelzig)
GEHTEMPO = round(2 * 2 * 0.09 * math.sin(math.radians(24)) / (18 / vb.FPS), 3)


def form(Jv, me):
    z0, f = SZ
    sz = lambda z: z if z < z0 else z0 + (z - z0) * f
    for v in me.vertices:
        v.co.x *= SX; v.co.z = sz(v.co.z)
    for k in Jv: Jv[k] = Vector((Jv[k].x * SX, Jv[k].y, sz(Jv[k].z)))


def zottel(Jv, me):
    rng = np.random.default_rng(9)
    for v in me.vertices:
        c = v.co
        if c.z < 0.12 or c.y < -0.33 or c.y > 0.3: continue
        n = math.sin(c.y * 160 + c.z * 90) * math.sin(c.x * 140 + c.y * 60)
        v.co = c + v.normal * (0.004 * n + float(rng.normal(0, 0.0015)))


def uv(c):
    if c.z < 0.13:
        return c.z / 0.25, (c.x + c.y) / 0.25
    return c.y / 0.25, math.atan2(c.z - 0.22, c.x) * 0.08 / 0.25


def hell(h, f=1.0):
    """Farbe eines Anbaus: die Haartextur dunkelt alles um FELL_MEAN ab, Anbauten tragen keine Haare."""
    return np.minimum(rgb(h) * f / FELL_MEAN, 1.0)


def kugel(c, r, n=8, m=5):
    V, F = [], []
    for i in range(1, m):
        t = math.pi * i / m
        for k in range(n):
            a = 2 * math.pi * k / n
            V.append(np.array(c) + np.array(r) * [math.sin(t) * math.cos(a), math.sin(t) * math.sin(a), math.cos(t)])
    V.append(np.array(c) + [0, 0, r[2]]); V.append(np.array(c) - [0, 0, r[2]])
    top, bot = len(V) - 2, len(V) - 1
    for i in range(m - 2):
        for k in range(n):
            F.append((i * n + k, i * n + (k + 1) % n, (i + 1) * n + (k + 1) % n, (i + 1) * n + k))
    for k in range(n):
        F.append((top, (k + 1) % n, k)); F.append((bot, (m - 2) * n + k, (m - 2) * n + (k + 1) % n))
    return V, F


def schale(c, quer, hoch, vorn, rx, ry, mulde, zerrissen=False):
    """Rundes, dünnes Ohr als Schale (Beast.kt Ellipsoid 3,0 × 3,2 × 0,5): Mitte nach hinten gewölbt, geschlossene Linse
    (Runde 5: beide Seiten mit Normale nach außen, Rand gemeinsam; Prüfer Runde 4: fernes Ohr von hinten „schwarzes
    Stachelbüschel“); vorn heller, hinten Ohrhaut; zerrissen: tiefe Kerbe oben mit gezacktem Grund."""
    rng = np.random.default_rng(5)
    n, m = 22, 5
    kerbe = [0.3 + 0.12 * float(rng.random()) for _ in range(n)]
    def punkt(i, k, d):
        f = i / m; a = 2 * math.pi * k / n
        fa = f * kerbe[k] if zerrissen and 0.5 < a < 2.2 else f
        return np.array(c) + quer * (rx * fa * math.cos(a)) + hoch * (ry * fa * math.sin(a)) + vorn * (d * (1 - f * f) - mulde * (1 - fa * fa))
    V, F, farbe = [], [], []
    vo, hi = hell(OHRHAUT, 1.2), hell(OHRHAUT, 1.0)
    rand = len(V)
    for k in range(n): V.append(punkt(m, k, 0)); farbe.append(hell(OHRHAUT, 1.05))
    for d, col, vorne in ((0.0018, vo, True), (-0.0018, hi, False)):
        o = len(V)
        V.append(punkt(0, 0, d)); farbe.append(col)
        for i in range(1, m):
            for k in range(n): V.append(punkt(i, k, d)); farbe.append(col)
        ring = lambda i, k: rand + k % n if i == m else o + 1 + (i - 1) * n + k % n
        for k in range(n):
            t = (o, ring(1, k), ring(1, k + 1))
            F.append(t if vorne else t[::-1])
        for i in range(1, m):
            for k in range(n):
                q = (ring(i, k), ring(i, k + 1), ring(i + 1, k + 1), ring(i + 1, k))
                F.append(q if vorne else q[::-1])
    return V, F, farbe


def rute_punkte(Jv):
    """Rute wie Beast.kt: vom Hinterteil 40° abwärts nach hinten, am Boden in einem Bogen nachschleifend; 0,58 m."""
    P = [np.array(Jv['rute0'], float)]
    d = np.array([0.0, math.cos(math.radians(55)), -math.sin(math.radians(55))])
    for i in range(48):
        q = P[-1] + d * 0.012
        if q[2] < 0.011: q[2] = 0.011; d[2] = 0.0
        P.append(q)
        # Runde 3: am Boden ein weiter Bogen zur Seite (Prüfer: „steif wie ein Stock“, von vorn unsichtbar)
        if q[2] <= 0.012:      # Runde 5: am Boden gleichmäßig zur Seite gebogen (Prüfer Runde 4: „gerade mit Knick“)
            w = math.radians(5.5); d = np.array([d[0] * math.cos(w) - d[1] * math.sin(w), d[0] * math.sin(w) + d[1] * math.cos(w), 0.0])
        else:
            d = d + np.array([0.0, 0.0, -0.02]); d /= np.linalg.norm(d)
    return P


def anbauten(Jv, fell, V):
    out = []
    fur, saddle, belly, eye, mange, torn = COATS[fell]
    n, k1 = np.array(Jv['nase']), np.array(Jv['kinn'])
    # Nagezähne oben und unten (Beast.kt incisor: lang, meißelförmig, orange, immer sichtbar): unter der Schnauze heraus
    for sg in (1, -1):
        # Runde 3 (Prüfer Runde 2: „nur ein Punkt“): breiter, länger, vorn aus der Schnauze heraus
        # Runde 5 (Prüfer Runde 4: von vorn „orange Marke, Glocke unterm Kinn“): zwei schmale Meißel mit Spalt an der
        # Schnauzenspitze, leicht nach hinten gebogen; unten kurz im offenen Maul
        o = n + [0.0042 * sg, 0.007, -0.010]
        out.append(vb.anbau_rohr([o, o + [0, -0.003, -0.012], o + [0, -0.001, -0.024]], [0.0036, 0.0034, 0.0026], 5) +
                   ('schnauze', hell(ZAHN, 1.15)))
        u = k1 + [0.004 * sg, 0.004, 0.004]
        out.append(vb.anbau_rohr([u, u + [0, -0.003, 0.008], u + [0, -0.004, 0.015]], [0.0032, 0.003, 0.0022], 5) +
                   ('kiefer', hell(ZAHN, 1.0)))
    # Knopfaugen (Beast.kt: 1,35 hk, rot leuchtend, vorgewölbt): Kugel an der Kopfseite, dunkler Rand
    for sg in (1, -1):
        nah = V[(np.abs(V[:, 1] + 0.335) < 0.012) & (np.abs(V[:, 2] - 0.27) < 0.012) & (V[:, 0] * sg > 0)]
        x = float(nah[:, 0].max() * sg) if len(nah) else 0.045
        c = np.array([sg * (x - 0.003), -0.335, 0.27])
        # Runde 4 größer (Prüfer Runde 3: „nur ein Pixelpunkt“)
        out.append(kugel(c + [sg * 0.001, 0, 0], (0.015, 0.015, 0.014)) + ('kopf', hell(0x140C0A)))
        out.append(kugel(c + [sg * 0.007, -0.004, 0.001], (0.011, 0.011, 0.0105)) + ('kopf', hell(eye, 1.0)))
    # Ohren: große runde Schalen hinten oben am Kopf, nach außen geneigt, Öffnung nach vorn-außen (Beast.kt)
    for s, sg in (('L', 1), ('R', -1)):
        # Runde 3 kleiner und weiter zurückgelegt (Prüfer: von vorn „Micky-Maus“)
        hoch = np.array([sg * 0.45, 0.2, 1.0]); hoch /= np.linalg.norm(hoch)
        vorn = np.array([sg * 0.6, -1.0, 0.1]); vorn -= hoch * (vorn @ hoch); vorn /= np.linalg.norm(vorn)
        quer = np.cross(hoch, vorn)
        c = (np.array(Jv['ohr%s0' % s]) + np.array(Jv['ohr%s1' % s])) / 2
        Vo, Fo, Co = schale(c, quer, hoch, vorn, 0.033, 0.036, 0.005, zerrissen=torn and s == 'R')
        out.append((Vo, Fo, 'ohr' + s, Co))
    # Rute: nacktes, geringeltes Rohr (Beast.kt: 11 Glieder, jedes zweite mit Schuppenring), über rute0 und rute1
    P = rute_punkte(Jv)
    r = [0.02 - 0.013 * i / (len(P) - 1) for i in range(len(P))]     # Spitze nicht dünner als die Tusche (Runde 2: „Pinsel“)
    ring = [(i % 5 == 4) for i in range(len(P))]
    r = [x * (1.14 if g else 1.0) for x, g in zip(r, ring)]
    Vr, Fr = vb.anbau_rohr(P, r, 7)
    kn, fa = [], []
    for i in range(len(P)):
        kn += ['rute0' if P[i][1] < Jv['rute1'][1] else 'rute1'] * 7
        fa += [hell(RING, 1.1) if ring[i] else hell(RUTE, 1.2)] * 7
    kn.append('rute0'); fa.append(hell(RUTE, 1.2))
    out.append((Vr, Fr, kn, fa))
    # Hände: drei rosa Finger mit dunkler Kralle je Fuß (Beast.kt hand), hinten länger
    for s in 'LR':
        for vh, kno, lang in (('vpfote', 'vpfote', 0.016), ('hzehe', 'hpfote', 0.02)):
            f = np.array(Jv[vh + s]); f[2] = 0.006
            for t in (-1, 0, 1):
                a = f + [t * 0.008, -0.004, 0]
                b = a + [t * 0.003, -lang, 0.0]
                out.append(vb.anbau_rohr([a, (a + b) / 2, b], [0.0048, 0.0042, 0.0032], 5) + (kno, hell(HAUT, 1.05)))
                out.append(vb.anbau_rohr([b, b + [t * 0.001, -0.007, -0.003]], [0.0022, 0.0006], 4) + (kno, hell(KRALLE)))
    # Schnurrhaare entfallen (Prüfer Runde 2: in Spielgröße ein schwarzer Fleck „wie Schmutz“)
    return out


def faerbe(Jv, V, N, jaw, fell, n0):
    fur, saddle, belly, eye, mange, torn = COATS[fell]
    C = np.tile(rgb(fur), (len(V), 1))
    up = N[:, 2]
    back = np.clip((up - 0.3) / 0.4, 0, 1) * np.clip((V[:, 2] - 0.26) / 0.06, 0, 1)
    C = C * (1 - back[:, None] * 0.6) + rgb(saddle) * back[:, None] * 0.6
    low = np.clip((-up - 0.1) / 0.5, 0, 1) * (V[:, 2] > 0.08)
    C = C * (1 - low[:, None] * 0.7) + rgb(belly) * low[:, None] * 0.7
    C = np.minimum(C * LIFT / FELL_MEAN * HELL[fell], 1.0)
    g = C.mean(1, keepdims=True); C = g + (C - g) * SATT.get(fell, 1.0)
    # nackte Teile: Hände und Füße rosa (Beast.kt skin), Nase
    pfote = V[:, 2] < 0.026
    C[pfote] = hell(HAUT, 1.0)
    nase = np.linalg.norm(V - np.array(Jv['nase']), axis=1) < 0.017
    C[nase] = hell(HAUT, 1.1)
    rachen = jaw & (N[:, 2] > 0.35)
    C[rachen] = rgb(0x5A2222)
    # Räude: kahle, verschorfte Flecken (Beast.kt patches), an den nächsten Punkt der Haut gesetzt
    flecken = [(0.093, 0.095, 0.257, 0.042), (-0.085, 0.0, 0.285, 0.032), (0.066, 0.209, 0.31, 0.03), (0.063, -0.124, 0.2, 0.027)] if mange \
        else [(0.095, 0.076, 0.247, 0.022)]     # Runde 5: ohne Räude ein kleiner kahler Fleck (Prüfer Runde 4: Felle verwechselbar)
    for x, y, z, r in flecken:
        P = np.array([x * SX, y, z]); P = V[np.argmin(np.linalg.norm(V[:n0] - P, axis=1))]
        d = np.linalg.norm(V - P, axis=1); d[n0:] = 9
        C[d < r] = hell(HAUT, 0.95)
        if mange: C[d < r * 0.3] = hell(0x8A6A62, 1.0)     # Runde 5 nur leicht dunklere Mitte (Prüfer Runde 3, 4: „Wunde, Loch“)
    strand = 1 + 0.05 * np.sin(V[:, 1] * 300 + V[:, 2] * 140) + np.random.default_rng(7).normal(0, 0.015, len(V))
    C = C * strand[:, None]
    return C


def bewegungen(K):
    PB, rot, setr, root, clear, legs, Zv, Yv = K['PB'], K['rot'], K['setr'], K['root'], K['clear'], K['legs'], K['Zv'], K['Yv']
    def stehen(p):     # schnuppern: Kopf hebt und senkt sich, Rute pendelt (R_SNIFF); Lefzen leicht hoch, Zähne frei
        br = math.sin(2 * math.pi * p)
        clear(); root(dz=0.003 * br); setr('brust', 2.0 * br)
        setr('hals', -4 * (0.5 - 0.5 * math.cos(2 * math.pi * p))); setr('kopf', 3 * math.sin(6 * math.pi * p)); setr('kiefer', -12)
        setr('rute0', 6 * math.sin(2 * math.pi * p), Zv); setr('rute1', 8 * math.sin(2 * math.pi * p + 1), Zv)
    def gehen(p):
        clear(); w = 2 * math.pi * p
        legs(24 * math.sin(w), 24 * math.sin(w + math.pi), 22 * math.sin(w + math.pi * 0.5), 22 * math.sin(w + math.pi * 1.5))
        root(dz=0.006 * abs(math.sin(2 * w))); setr('kopf', 3 * math.sin(2 * w)); setr('rute0', 8 * math.sin(w), Zv)
    def hocke(p):      # geduckt, zum Sprung gespannt (R_COIL)
        br = math.sin(2 * math.pi * p)
        clear(); root(dz=-0.018 + 0.002 * br, pitch=2)
        for s in 'LR':
            setr('oberarm' + s, 16); setr('unterarm' + s, -26); setr('vpfote' + s, 6)
            setr('schenkel' + s, -14); setr('unterschenkel' + s, 18); setr('hpfote' + s, -4)
        setr('hals', 8); setr('kopf', -4); setr('kiefer', -10); setr('ohrL', -25); setr('ohrR', -25)
    def biss(p):       # vorschnellen, zuschnappen am Aufschlag (p 0,42), zurück (0,6 s)
        clear(); u = math.sin(math.pi * min(1, p / 0.84))
        root(dy=-0.14 * u, dz=-0.01 * u, pitch=-4 * u); legs(18 * u, -8 * u, -12 * u, 8 * u)
        setr('hals', -8 * u); setr('kopf', 6 * u); setr('kiefer', -34 if p < 0.42 else -4)
    def sprung(p):     # aus der Hocke ins Gesicht springen (R_LEAP, R_LAND)
        clear()
        if p < 0.25:
            u = p / 0.25; root(dz=-0.025 * (1 - u), pitch=4 - 16 * u); legs(-10 + 40 * u, -10 + 40 * u, -14 - 24 * u, -14 - 24 * u)
        elif p < 0.6:
            u = (p - 0.25) / 0.35; root(dz=0.35 * math.sin(math.pi * u), dy=-0.6 * u, pitch=-16 + 10 * u); legs(40, 38, -40, -38)
        else:
            u = (p - 0.6) / 0.4; root(dy=-0.6 + 0.6 * u * u, dz=-0.01 * math.sin(math.pi * u), pitch=-6 * (1 - u)); legs(10 * (1 - u), 8 * (1 - u), -8 * (1 - u), -6 * (1 - u))
        setr('kiefer', -36 if 0.3 < p < 0.7 else -6); setr('ohrL', -25); setr('ohrR', -25); setr('rute0', -14)
    def treffer(p):
        clear(); u = math.sin(math.pi * p); root(dy=0.05 * u, pitch=6 * u); setr('kopf', 14 * u, Zv); setr('kiefer', -20 * u); setr('rute0', -30 * u)
    def ausweichen(p):
        clear(); u = math.sin(math.pi * p); root(dx=0.16 * u, dz=0.02 * u); setr('ruecken', 12 * u, Zv); legs(-10 * u, 12 * u, 10 * u, -10 * u)
    def tod(p):        # auf den Rücken gerollt, Pfoten gekrümmt
        clear(); u = min(1, p * 1.3); u = u * u * (3 - 2 * u)
        root(dz=-0.14 * u, dx=0.03 * u); PB['root'].rotation_quaternion = rot('root', 100 * u, Yv)
        legs(30 * u, 20 * u, -30 * u, -20 * u, bend=40 * u); setr('hals', -10 * u); setr('kiefer', -14 * u)
    def lefzen(p):     # Zähne blecken, Kopf vor, Nase zuckt (2 s)
        stehen(p * 2 % 1); u = min(1, p / 0.2, (1 - p) / 0.2); u = u * u * (3 - 2 * u)
        setr('hals', -6 * u); setr('kopf', -4 * u + 2 * math.sin(p * 60) * u); setr('kiefer', -16 * u); setr('ohrL', -25 * u); setr('ohrR', -25 * u)
    def drohen(p):     # Kopf hoch, Maul auf (alt: neck 20, nod -24, mouth 0,8)
        clear(); u = math.sin(math.pi * min(1, p * 1.2)); root(pitch=-8 * u); setr('hals', -20 * u); setr('kopf', -14 * u); setr('kiefer', -30 * u)
    return [('Stehen', 60, stehen, True), ('Gehen', 18, gehen, True), ('Hocke', 30, hocke, True), ('Biss', 18, biss, False),
            ('Sprung', 24, sprung, False), ('Treffer', 12, treffer, False), ('Ausweichen', 12, ausweichen, False),
            ('Tod', 30, tod, False), ('Lefzen', 60, lefzen, False), ('Drohen', 36, drohen, False)]


FELL_PNG = os.path.join(vb.OUT, 'giant_rat-fell.png')
FELL_MEAN = vb.fell_textur(FELL_PNG, seed=17, laenge=(10, 24), striche=7000, kontrast=0.9)

if __name__ == '__main__':
    vb.alle(sys.modules[__name__])
