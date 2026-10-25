# 348.9 (Jerry): die Riesenratte (giant_rat) aus dem Grundmodell Vierbeiner (vierbeiner.py), Vorlage BeastArt.kt / Beast.kt rat():
# geduckter Rumpf, Rücken über der Lende am höchsten, runde Kruppe, schmale Brust, langer spitzer Kopf, rosa Nase, immer
# sichtbare orange Nagezähne, kleine rote Knopfaugen, runde dünne nackte Ohren (eines zerrissen), lange nackte Rute,
# Räude (kahle, verschorfte Flecken). Maß: Schulter 0,3 m, Rumpf mit Kopf 0,75 m, Rute 0,5 m (alt: 39 gegen Wolf 76).
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
HELL = {'braun': 1.0, 'grau': 0.95, 'schwarz': 1.35}
LIFT = 2.0
AUFLOESUNG = 0.007
DREIECKE = 4800
HAUT, RUTE, NASE, ZAHN, SCHORF = 0xA27268, 0x7E625E, 0xA27268, 0xC8862A, 0x5A2A22

# ---------------------------------------------------------------- Gelenke (Meter; x quer, -y vorn, z oben)
J = {
    'wurzel': (0, 0, 0),
    'becken': (0, 0.17, 0.23), 'kreuz': (0, 0.0, 0.27), 'brust': (0, -0.17, 0.22), 'widerrist': (0, -0.25, 0.235),
    'hals': (0, -0.31, 0.24), 'kopf': (0, -0.35, 0.24), 'schnauze': (0, -0.46, 0.195), 'nase': (0, -0.515, 0.175),
    'kiefer': (0, -0.37, 0.195), 'kinn': (0, -0.48, 0.16),
    'rute0': (0, 0.25, 0.20), 'rute1': (0, 0.46, 0.07), 'rute2': (0, 0.72, 0.025),
    'ohrL0': (0.035, -0.34, 0.29), 'ohrL1': (0.05, -0.335, 0.33), 'ohrR0': (-0.035, -0.34, 0.29), 'ohrR1': (-0.05, -0.335, 0.33),
}
for s in 'LR':
    vb.beine(J, s, schulter=(0.05, -0.19, 0.17), ellbogen=(0.05, -0.16, 0.10), vfuss=(0.045, -0.20, 0.03), vpfote=(0.045, -0.235, 0.012),
             huefte=(0.055, 0.15, 0.19), knie=(0.06, 0.08, 0.12), sprung=(0.05, 0.18, 0.05), hpfote=(0.05, 0.14, 0.012), hzehe=(0.05, 0.085, 0.01))
BLOBS = [
    ('becken', 'kreuz', 0.085, 0.105, 'becken'), ('kreuz', 'brust', 0.105, 0.08, 'ruecken'), ('brust', 'widerrist', 0.08, 0.066, 'brust'),
    ('widerrist', 'hals', 0.062, 0.052, 'hals'), ('hals', 'kopf', 0.052, 0.048, 'kopf'),
    ('kopf', 'schnauze', 0.044, 0.022, 'schnauze'), ('schnauze', 'nase', 0.022, 0.012, 'schnauze'),
    ('rute0', 'rute1', 0.016, 0.009, 'rute0'), ('rute1', 'rute2', 0.009, 0.003, 'rute1'),
]
for s in 'LR':
    BLOBS += [('schulter' + s, 'ellbogen' + s, 0.034, 0.02, 'oberarm' + s), ('ellbogen' + s, 'vfuss' + s, 0.016, 0.011, 'unterarm' + s),
              ('vfuss' + s, 'vpfote' + s, 0.011, 0.013, 'vpfote' + s),
              ('huefte' + s, 'knie' + s, 0.055, 0.03, 'schenkel' + s), ('knie' + s, 'sprung' + s, 0.02, 0.012, 'unterschenkel' + s),
              ('sprung' + s, 'hpfote' + s, 0.011, 0.012, 'hpfote' + s), ('hpfote' + s, 'hzehe' + s, 0.012, 0.011, 'hpfote' + s)]
KB = {'rute1': 1.2, 'rute0': 1.4}
KNUBBEL = [('knie', 0.03, (0, 0, 0))]
OHR = (0.026, 0.022)       # rund, nicht spitz
KIEFER = (0.02, 0.011)
SX = 0.9
GEHTEMPO = round(2 * 2 * 0.09 * math.sin(math.radians(24)) / (18 / vb.FPS), 3)


def form(Jv, me):
    for v in me.vertices:
        v.co.x *= SX
        o = None
        for s in 'LR':     # Ohren flach wie Schalen (quer zur Blickrichtung gedrückt)
            c = (Jv['ohr%s0' % s] + Jv['ohr%s1' % s]) / 2
            if (v.co - c).length < 0.035 and v.co.z > 0.27: o = c
        if o is not None: v.co.y = o.y + (v.co.y - o.y) * 0.35
    for k in Jv: Jv[k] = Vector((Jv[k].x * SX, Jv[k].y, Jv[k].z))


def zottel(Jv, me):
    rng = np.random.default_rng(9)
    for v in me.vertices:
        c = v.co
        if c.z < 0.12 or c.y < -0.42 or c.y > 0.26 or c.z > 0.27 and abs(c.y + 0.34) < 0.04: continue
        n = math.sin(c.y * 160 + c.z * 90) * math.sin(c.x * 140 + c.y * 60)
        v.co = c + v.normal * (0.004 * n + float(rng.normal(0, 0.0015)))


def uv(c):
    if c.z < 0.13:
        return c.z / 0.25, (c.x + c.y) / 0.25
    return c.y / 0.25, math.atan2(c.z - 0.22, c.x) * 0.08 / 0.25


def anbauten(Jv, fell, V):
    out = []
    # Nagezähne oben und unten, orange, immer sichtbar (Beast.kt incisor)
    n, k1 = np.array(Jv['nase']), np.array(Jv['kinn'])
    for sg in (1, -1):
        o = n + [0.004 * sg, 0.012, -0.012]
        out.append(vb.anbau_rohr([o, o + [0, -0.002, -0.014], o + [0, -0.003, -0.026]], [0.0045, 0.004, 0.003], 4) + ('schnauze', ZAHN))
        u = k1 + [0.004 * sg, -0.004, 0.004]
        out.append(vb.anbau_rohr([u, u + [0, -0.003, 0.01], u + [0, -0.004, 0.018]], [0.004, 0.0035, 0.0025], 4) + ('kiefer', ZAHN))
    # Knopfaugen als Perle (Wildschwein Runde 3: als Eckfarbe zu wenige Ecken), rot gedämpft
    for sg in (1, -1):
        nah = V[(np.abs(V[:, 1] + 0.40) < 0.012) & (np.abs(V[:, 2] - 0.245) < 0.012) & (V[:, 0] * sg > 0)]
        x = float(nah[:, 0].max() * sg) if len(nah) else 0.035
        c = np.array([sg * (x - 0.002), -0.40, 0.245])
        out.append(vb.anbau_rohr([c - [sg * 0.004, 0, 0], c + [sg * 0.003, 0, 0], c + [sg * 0.006, 0, 0]], [0.009, 0.008, 0.001], 6) +
                   ('kopf', np.minimum(rgb(COATS[fell][3]) * 0.55, 1.0)))
    # Schnurrhaare, dunkel, je Seite drei
    for sg in (1, -1):
        for i, (dy, dz) in enumerate(((-0.01, 0.01), (0.0, 0.0), (0.01, -0.012))):
            b0 = n + [0.012 * sg, 0.02, 0.0]
            out.append(vb.anbau_rohr([b0, b0 + [0.04 * sg, 0.015 + dy, dz], b0 + [0.07 * sg, 0.04 + dy, dz * 2]], [0.0012, 0.0008, 0.0003], 3) +
                       ('schnauze', 0x1A1412))
    return out


def faerbe(Jv, V, N, jaw, fell, n0):
    fur, saddle, belly, eye, mange, torn = COATS[fell]
    seg = lambda a, b, ra, rb: vb.seg(Jv, V, a, b, ra, rb)[0]
    C = np.tile(rgb(fur), (len(V), 1))
    up = N[:, 2]
    back = np.clip((up - 0.3) / 0.4, 0, 1) * np.clip((V[:, 2] - 0.24) / 0.06, 0, 1)
    C = C * (1 - back[:, None] * 0.6) + rgb(saddle) * back[:, None] * 0.6
    low = np.clip((-up - 0.1) / 0.5, 0, 1) * (V[:, 2] > 0.1)
    C = C * (1 - low[:, None] * 0.7) + rgb(belly) * low[:, None] * 0.7
    C = np.minimum(C * LIFT / FELL_MEAN * HELL[fell], 1.0)
    # nackte Teile: Pfoten, Rute, Ohren, Nase in Hautfarbe (alt: skin, tailSkin, earSkin)
    pfote = V[:, 2] < 0.035
    C[pfote] = rgb(HAUT) * 0.8
    rute = np.minimum(seg('rute0', 'rute1', 0.016, 0.009), seg('rute1', 'rute2', 0.009, 0.003)) < 0.006
    rute &= V[:, 1] > 0.27
    ring = (np.sin(np.linalg.norm(V - np.array(Jv['rute0']), axis=1) * 260) > 0.6) & rute
    C[rute] = rgb(RUTE); C[ring] = rgb(RUTE) * 0.7      # geschuppte Ringe
    for s in 'LR':
        ohr = (seg('ohr%s0' % s, 'ohr%s1' % s, OHR[0], OHR[1]) < 0.01) & (V[:, 2] > 0.285)
        C[ohr] = rgb(HAUT) * 0.85
        innen = ohr & (N[:, 1] < -0.4)
        C[innen] = rgb(SCHORF) * 1.2
        if torn and s == 'R':    # zerrissenes Ohr: obere Hälfte verschorft dunkel
            C[ohr & (V[:, 2] > 0.315)] = rgb(SCHORF) * 0.6
    nase = np.linalg.norm(V - np.array(Jv['nase']), axis=1) < 0.014
    C[nase] = rgb(NASE)
    rachen = jaw & (N[:, 2] > 0.35)
    C[rachen] = rgb(0x5A2222)
    # Räude: kahle, verschorfte Flecken (Beast.kt patches)
    flecken = [(0.07, -0.0, 0.27, 0.034), (-0.065, 0.08, 0.29, 0.026), (0.05, 0.16, 0.30, 0.024), (0.05, -0.19, 0.21, 0.02)] if mange \
        else [(0.075, 0.02, 0.26, 0.026), (-0.06, 0.16, 0.28, 0.022)]
    for x, y, z, r in flecken:
        P = np.array([x * SX, y, z * 0.92]); d = np.linalg.norm(V - P, axis=1)
        C[d < r] = rgb(HAUT) * 0.9
        C[d < r * 0.5] = rgb(SCHORF)
    strand = 1 + 0.05 * np.sin(V[:, 1] * 300 + V[:, 2] * 140) + np.random.default_rng(7).normal(0, 0.015, len(V))
    C = C * strand[:, None]
    return C


def bewegungen(K):
    PB, rot, setr, root, clear, legs, Zv, Yv = K['PB'], K['rot'], K['setr'], K['root'], K['clear'], K['legs'], K['Zv'], K['Yv']
    def stehen(p):     # schnuppern: Kopf hebt und senkt sich, Rute pendelt (R_SNIFF)
        br = math.sin(2 * math.pi * p)
        clear(); root(dz=0.003 * br); setr('brust', 2.0 * br)
        setr('hals', -4 * (0.5 - 0.5 * math.cos(2 * math.pi * p))); setr('kopf', 3 * math.sin(6 * math.pi * p))
        setr('rute0', 8 * math.sin(2 * math.pi * p), Zv); setr('rute1', 10 * math.sin(2 * math.pi * p + 1), Zv)
    def gehen(p):
        clear(); w = 2 * math.pi * p
        legs(24 * math.sin(w), 24 * math.sin(w + math.pi), 22 * math.sin(w + math.pi * 0.5), 22 * math.sin(w + math.pi * 1.5))
        root(dz=0.006 * abs(math.sin(2 * w))); setr('kopf', 3 * math.sin(2 * w)); setr('rute0', 10 * math.sin(w), Zv)
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
