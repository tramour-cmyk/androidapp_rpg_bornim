# 348.9 (Jerry): das Wildschwein (boar) aus dem Grundmodell Vierbeiner (vierbeiner.py), Vorlage BeastArt.kt / Beast.kt boar():
# schwerer Vorderleib, schmales Heck, kurzer dicker Hals, langer Keilkopf tief getragen, Rüsselscheibe, Hauer aus dem
# Unterkiefer nach oben und hinten, kleine Wetzer oben, dunkler Borstenkamm auf dem Rücken, dünne Läufe auf Hufen,
# dünne Rute mit Quaste. Maß wie alt (Beast.kt in cm): Widerrist 0,9 m, Länge Rüssel bis Rute 1,6 m.
# Felle wie BeastArt.BOAR_COATS (fur, saddle, belly, eye, Narbe, zerrissenes Ohr): DUNKEL, GRAU, ROST.
# Aufruf: OUT=<ordner> FELL=dunkel|grau|rost python -I wildschwein.py  ->  <OUT>/boar-<fell>.glb, boar-info.json
import os, sys, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vierbeiner as vb      # lädt bpy, danach erst mathutils
import numpy as np
from mathutils import Vector
from vierbeiner import rgb

ID = 'boar'
SCHULTER = 0.9
COATS = {
    'dunkel': (0x3A302A, 0x141010, 0x2E2622, 0xD82A18, False, False),
    'grau':   (0x5E5248, 0x221C18, 0x4A3E36, 0xE84A1A, True, False),
    'rost':   (0x5A3A26, 0x1E1410, 0x463024, 0xC81E14, True, True),
}
HELL = {'dunkel': 1.35, 'grau': 1.05, 'rost': 0.85}    # Runde 3 (Prüfer Runde 2: grau nicht von dunkel zu unterscheiden, rost zu bunt)    # Runde 2 (Prüfer Runde 1: „fast schwarze Masse, Glieder nicht zu trennen“): dunkel 1,2 → 1,5
LIFT = 2.0
AUFLOESUNG = 0.016
DREIECKE = 4300      # Modellregel 7: mit Borsten und Hauern unter 6000

# ---------------------------------------------------------------- Gelenke (Meter; x quer, -y vorn, z oben)
# aus Beast.kt boar() (cm, z dort vorn): Rumpfmitte 0,64 m, Brust 0,27 tief, Heck schmaler; Kopf vom Hals 0,4 m schräg nach unten
J = {
    'wurzel': (0, 0, 0),
    # Runde 2 (Prüfer Runde 1: „Läufe zu lang und dünn wie Pfosten“, „Hinterleib fehlt fast ganz“): Rumpf tiefer und voller, Läufe kürzer und dicker
    # Runde 3 (Prüfer Runde 2: „Rumpf eher ein Quader“, alt Keil): Widerrist höher, Heck tiefer und schmaler
    'becken': (0, 0.30, 0.57), 'kreuz': (0, 0.0, 0.61), 'brust': (0, -0.30, 0.66), 'widerrist': (0, -0.46, 0.75),
    'hals': (0, -0.62, 0.64), 'kopf': (0, -0.70, 0.61), 'schnauze': (0, -0.97, 0.48), 'nase': (0, -1.05, 0.445),
    'kiefer': (0, -0.74, 0.52), 'kinn': (0, -0.96, 0.425),
    'rute0': (0, 0.50, 0.62), 'rute1': (0, 0.62, 0.52), 'rute2': (0, 0.66, 0.39),    # Runde 3: Rute steckte im Heck („Stummel“)
    'ohrL0': (0.08, -0.66, 0.74), 'ohrL1': (0.13, -0.61, 0.92), 'ohrR0': (-0.08, -0.66, 0.74), 'ohrR1': (-0.13, -0.61, 0.92),    # Runde 2: „keine Ohren“: länger, aufrecht
}
for s in 'LR':
    vb.beine(J, s, schulter=(0.10, -0.42, 0.56), ellbogen=(0.10, -0.39, 0.34), vfuss=(0.09, -0.45, 0.12), vpfote=(0.09, -0.49, 0.02),
             huefte=(0.10, 0.30, 0.58), knie=(0.10, 0.19, 0.36), sprung=(0.09, 0.37, 0.18), hpfote=(0.09, 0.35, 0.03), hzehe=(0.09, 0.31, 0.02))
BLOBS = [
    ('becken', 'kreuz', 0.16, 0.20, 'becken'), ('kreuz', 'brust', 0.21, 0.25, 'ruecken'), ('brust', 'widerrist', 0.27, 0.21, 'brust'),
    ('widerrist', 'hals', 0.18, 0.14, 'hals'), ('hals', 'kopf', 0.13, 0.11, 'kopf'),
    ('kopf', 'schnauze', 0.10, 0.065, 'schnauze'), ('schnauze', 'nase', 0.065, 0.072, 'schnauze'),    # Runde 2: Rüsselscheibe breiter als die Schnauze („Hundemaul“)
    ('rute0', 'rute1', 0.026, 0.02, 'rute0'), ('rute1', 'rute2', 0.02, 0.042, 'rute1'),    # Quaste am Ende (Runde 3: dicker, sonst nicht zu sehen)
]
for s in 'LR':
    BLOBS += [('schulter' + s, 'ellbogen' + s, 0.10, 0.062, 'oberarm' + s), ('ellbogen' + s, 'vfuss' + s, 0.05, 0.038, 'unterarm' + s),
              ('vfuss' + s, 'vpfote' + s, 0.036, 0.05, 'vpfote' + s),    # Runde 3: Huf breiter als der Lauf
              ('huefte' + s, 'knie' + s, 0.14, 0.07, 'schenkel' + s), ('knie' + s, 'sprung' + s, 0.056, 0.038, 'unterschenkel' + s),
              ('sprung' + s, 'hpfote' + s, 0.036, 0.048, 'hpfote' + s), ('hpfote' + s, 'hzehe' + s, 0.048, 0.046, 'hpfote' + s)]
KB = {'rute1': 1.3}
KNUBBEL = [('ellbogen', 0.05, (0, 0.01, 0)), ('vfuss', 0.034, (0, 0, 0)), ('knie', 0.07, (0, 0, 0)), ('sprung', 0.034, (0, 0, 0))]
OHR = (0.06, 0.014)
KIEFER = (0.05, 0.03)
SX = 0.82     # quer schmal: das Schwein ist hoch und schmal, nicht rund
GEHTEMPO = round(2 * 2 * 0.22 * math.sin(math.radians(20)) / (24 / vb.FPS), 3)


def form(Jv, me):
    nase_y = Jv['nase'].y
    for v in me.vertices:
        v.co.x *= SX
        if v.co.y < nase_y - 0.015 and v.co.z > 0.35: v.co.y = nase_y - 0.015    # Rüsselscheibe vorn flach
    for k in Jv: Jv[k] = Vector((Jv[k].x * SX, Jv[k].y, Jv[k].z))


def zottel(Jv, me):
    rng = np.random.default_rng(5)
    nase = Jv['nase']
    for v in me.vertices:
        c = v.co
        if c.z < 0.3 or (c - nase).length < 0.07: continue
        n = math.sin(c.y * 70 + c.z * 41) * math.sin(c.x * 60 + c.y * 29)
        k = 0.5 if c.y < -0.7 else 1.0
        v.co = c + v.normal * k * (0.012 * n + float(rng.normal(0, 0.004)))


def uv(c):
    if c.z < 0.36 and (abs(c.y + 0.44) < 0.14 or abs(c.y - 0.3) < 0.14):
        lx = 0.09 * SX if c.x > 0 else -0.09 * SX
        return c.z / 0.5, (c.x - lx + c.y) / 0.5
    if c.y < -0.6:
        return c.y / 0.5, math.atan2(c.z - 0.55, c.x) * 0.1 / 0.5
    return c.y / 0.5, math.atan2(c.z - 0.64, c.x) * 0.2 / 0.5


def anbauten(Jv, fell, V):
    out = []
    # Hauer aus dem Unterkiefer: nach außen, oben, hinten gebogen (Beast.kt p0–p3), gelblich-matt; Wetzer oben klein
    k0, k1 = np.array(Jv['kiefer']), np.array(Jv['kinn'])
    for sg in (1, -1):
        base = k0 + (k1 - k0) * 0.82 + np.array([0.03 * sg, 0, 0.02])
        # Runde 2 (Prüfer Runde 1: „nur kleine helle Striche, kaum lesbar“): länger, dicker, heller
        # Runde 3 (Prüfer Runde 2: „kurz, gerade am Maul entlang“): steil nach oben, Spitze nach hinten
        pts = [base, base + [0.03 * sg, -0.02, 0.07], base + [0.055 * sg, 0.0, 0.14], base + [0.05 * sg, 0.06, 0.19]]
        out.append(vb.anbau_rohr(pts, [0.02, 0.016, 0.01, 0.002], 6) + ('kiefer', 0xE2D8C0))
        top = np.array(Jv['schnauze']) + [0.035 * sg, -0.05, -0.03]
        out.append(vb.anbau_rohr([top, top + [0.016 * sg, -0.01, 0.025], top + [0.02 * sg, 0.012, 0.04]], [0.008, 0.005, 0.001], 5) + ('schnauze', 0xC8BA98))
    # Augen als kleine Perle auf der Fläche (Runde 3: als Eckfarbe nur 1–2 Ecken, „Augen fehlen“), gedämpft rot mit dunklem Rand
    for sg in (1, -1):
        nah = V[(np.abs(V[:, 1] + 0.78) < 0.025) & (np.abs(V[:, 2] - 0.665) < 0.025) & (V[:, 0] * sg > 0)]
        x = float(nah[:, 0].max() * sg) if len(nah) else 0.07
        c = np.array([sg * (x - 0.004), -0.78, 0.665])
        out.append(vb.anbau_rohr([c - [sg * 0.006, 0, 0], c + [sg * 0.004, 0, 0], c + [sg * 0.008, 0, 0]], [0.016, 0.014, 0.002], 6) + ('kopf', 0x140C0A))
        out.append(vb.anbau_rohr([c + [sg * 0.004, -0.003, 0], c + [sg * 0.009, -0.003, 0], c + [sg * 0.011, -0.003, 0]], [0.009, 0.008, 0.001], 6) +
                   ('kopf', np.minimum(rgb(COATS[fell][3]) * 0.6, 1.0)))
    # Borstenkamm vom Widerrist bis über die Lende, in der Mitte am längsten, nach oben und hinten (Beast.kt: 17 × 3)
    rng = np.random.default_rng({'dunkel': 1, 'grau': 2, 'rost': 3}[fell])
    sat = rgb(COATS[fell][1]) * LIFT / FELL_MEAN * HELL[fell] * 1.4
    for i in range(22):
        y = -0.60 + i * 0.034
        nah = V[(np.abs(V[:, 1] - y) < 0.02) & (np.abs(V[:, 0]) < 0.03)]
        if len(nah) == 0: continue
        z = float(nah[:, 2].max()) - 0.01
        lang = (0.05 + 0.07 * max(0.15, 1 - abs(y + 0.3) / 0.4))
        for sx in (-0.018, 0.0, 0.018):
            b0 = np.array([sx, y + float(rng.normal(0, 0.006)), z - abs(sx) * 0.4])
            d = np.array([sx * 2, 0.45, 1.0]); d /= np.linalg.norm(d)
            L = lang * (1.0 if sx == 0 else 0.8) * float(rng.uniform(0.8, 1.15))
            out.append(vb.anbau_rohr([b0, b0 + d * L * 0.5, b0 + d * L], [0.011, 0.006, 0.0008], 4) +
                       ('brust' if y < -0.3 else 'ruecken', np.minimum(sat, 1.0)))
    return out


def faerbe(Jv, V, N, jaw, fell, n0):
    fur, saddle, belly, eye, scar, torn = COATS[fell]
    seg = lambda a, b, ra, rb: vb.seg(Jv, V, a, b, ra, rb)[0]
    C = np.tile(rgb(fur), (len(V), 1))
    up = N[:, 2]
    # dunkler Rücken (Sattel) vom Nacken bis zur Kruppe, Bauch dunkler-matt wie alt, Läufe nach unten dunkel, Hufe schwarz
    back = np.clip((up - 0.3) / 0.4, 0, 1) * np.clip((V[:, 2] - 0.62) / 0.15, 0, 1) * (V[:, 1] > -0.75)
    C = C * (1 - back[:, None] * 0.7) + rgb(saddle) * back[:, None] * 0.7
    low = np.clip((-up - 0.1) / 0.5, 0, 1) * (V[:, 2] > 0.3)
    C = C * (1 - low[:, None] * 0.6) + rgb(belly) * low[:, None] * 0.6
    leg = np.clip((0.34 - V[:, 2]) / 0.2, 0, 1) * 0.75
    C = C * (1 - leg[:, None]) + rgb(saddle) * leg[:, None]
    C = np.minimum(C * LIFT / FELL_MEAN * HELL[fell], 1.0)
    if fell == 'rost':   # wie der Wolf: fast die Hälfte zum Grau (Prüfer Runde 2: „sticht als Farbfleck heraus“)
        C = C * 0.55 + C.mean(axis=1, keepdims=True) * 0.45
    huf = V[:, 2] < 0.075    # Runde 3: „Hufe nicht erkennbar“: höher schwarz
    C[huf] = rgb(0x1A1614)
    for s in 'LR':     # gespaltene Hufe: Spalt vorn
        for tp in ('vpfote', 'hzehe'):
            P = np.array(Jv[tp + s]); d = V - P
            spalt = (np.linalg.norm(d, axis=1) < 0.05) & (V[:, 2] < 0.07) & (np.abs(d[:, 0]) < 0.005) & (d[:, 1] < 0)
            C[spalt] = rgb(0x050404)
    # Kopf: Stirn dunkel, Backenbart heller, Rüsselscheibe dunkelrosa mit Nasenlöchern
    stirn = np.clip((N[:, 2] - 0.4) / 0.4, 0, 1) * (V[:, 1] < -0.66)
    C = C * (1 - stirn[:, None] * 0.6) + rgb(saddle) * LIFT / FELL_MEAN * HELL[fell] * stirn[:, None] * 0.6
    scheibe = V[:, 1] < Jv['nase'].y - 0.005
    C[scheibe] = rgb(0x7A5E58)    # Runde 2: heller (dunkel war sie nicht zu sehen)
    for sg in (1, -1):
        loch = np.linalg.norm(V - np.array([0.017 * sg, Jv['nase'].y - 0.015, Jv['nase'].z + 0.0]), axis=1) < 0.012
        C[loch] = rgb(0x0C0808)
    # Maul innen dunkelrot, Lefzen dunkel
    rachen = jaw & (N[:, 2] > 0.35)
    C[rachen] = rgb(0x6A2A28)
    # Augen klein, tief unter der Braue, gedämpft rot (alt glühend; Wolf Runde 15: nicht wie Lämpchen)
    for sg in (1, -1):
        ey = -0.78; ez = 0.665    # Runde 3: Augen lagen im Kopf (nicht zu sehen)
        nah = (np.abs(V[:, 1] - ey) < 0.02) & (np.abs(V[:, 2] - ez) < 0.02) & (V[:, 0] * sg > 0)
        x = V[nah, 0][np.argmax(V[nah, 0] * sg)] if nah.any() else 0.07 * sg
        d = np.linalg.norm(V - np.array([x, ey, ez]), axis=1)
        C[d < 0.032] = rgb(saddle)
        C[d < 0.021] = rgb(eye) * 0.7
        C[d < 0.007] = rgb(0x080606)
    for s in 'LR':     # Ohren mit dunklem Rand
        A, B = np.array(Jv['ohr%s0' % s]), np.array(Jv['ohr%s1' % s])
        tt = np.clip(((V - A) @ (B - A)) / ((B - A) @ (B - A)), 0, 1)
        rim = (seg('ohr%s0' % s, 'ohr%s1' % s, 0.05, 0.015) < 0.0) & (tt > 0.5)
        C[rim] = rgb(saddle)
    quaste = np.linalg.norm(V - np.array(Jv['rute2']), axis=1) < 0.05
    C[quaste] = rgb(saddle)
    if scar:   # Narben auf der Schnauze und an der Backe (Beast.kt)
        sc = np.abs((V[:, 1] + 0.88) + 0.8 * (V[:, 2] - 0.55)) < 0.008
        sc &= (V[:, 0] > 0.03) & (V[:, 1] < -0.8) & (V[:, 1] > -0.95)
        C[sc] = rgb(0x8A7262)
    strand = 1 + 0.05 * np.sin(V[:, 1] * 120 + V[:, 2] * 70) + np.random.default_rng(7).normal(0, 0.015, len(V))
    C = C * strand[:, None]
    return C


def bewegungen(K):
    PB, rot, setr, root, clear, legs, Zv, Yv = K['PB'], K['rot'], K['setr'], K['root'], K['clear'], K['legs'], K['Zv'], K['Yv']
    def stehen(p):     # atmen, Kopf nickt, Rute schlägt
        br = math.sin(2 * math.pi * p)
        clear(); root(dz=0.006 * br); setr('brust', 2.0 * br); setr('ruecken', -1.0 * br)
        setr('kopf', 3 * (0.5 - 0.5 * math.cos(2 * math.pi * p))); setr('rute0', 6 * math.sin(4 * math.pi * p), Zv); setr('kiefer', -3)
    def gehen(p):
        clear(); w = 2 * math.pi * p
        legs(20 * math.sin(w), 20 * math.sin(w + math.pi), 18 * math.sin(w + math.pi * 0.5), 18 * math.sin(w + math.pi * 1.5))
        root(dz=0.01 * abs(math.sin(2 * w)) - 0.005); setr('kopf', 3 * math.sin(2 * w)); setr('rute0', 8 * math.sin(w), Zv)
    def hocke(p):      # Kopf gesenkt, Kamm hoch, bereit zum Ansturm (B_LOWER)
        br = math.sin(2 * math.pi * p)
        clear(); root(dz=-0.015 + 0.004 * br, pitch=2)
        for s in 'LR':     # Runde 2: Vorderhufe sanken 4 cm in den Boden (pitch 5 senkte vorn zu tief)
            setr('oberarm' + s, 12); setr('unterarm' + s, -18); setr('vpfote' + s, 4)
            setr('schenkel' + s, -6); setr('unterschenkel' + s, 6)
        setr('hals', 14); setr('kopf', 8); setr('kiefer', -6); setr('ohrL', -30); setr('ohrR', -30)
    def hauer(p):      # Hauerstoß 0,6 s: Kopf tief vor, am Aufschlag (p 0,45) nach oben reißen, zurück (B_LOWER → B_GORE)
        clear()
        a = min(1, p / 0.4); b = max(0.0, min(1, (p - 0.35) / 0.2)); c = max(0.0, (p - 0.6) / 0.4)
        a = a * a * (3 - 2 * a); e = 1 - c * c * (3 - 2 * c)
        root(dy=(-0.18 * a - 0.17 * b) * e, dz=(-0.03 * a + 0.05 * b) * e, pitch=(5 * a - 10 * b) * e)
        legs(12 * a * e, -6 * a * e, -10 * a * e, 6 * a * e)
        setr('hals', (14 * a - 32 * b) * e); setr('kopf', (10 * a - 20 * b) * e); setr('kiefer', -14 * b * e)
        setr('ohrL', -30 * a * e); setr('ohrR', -30 * a * e)
    def ansturm(p):    # Rammen: aus der Hocke 1,2 m vor, Aufprall, zurück (24 Bilder)
        clear()
        if p < 0.5:
            u = p / 0.5; w = 2 * math.pi * u * 2
            root(dy=-1.2 * u, dz=-0.03 + 0.03 * abs(math.sin(w)), pitch=4)
            legs(26 * math.sin(w), 26 * math.sin(w + math.pi), 24 * math.sin(w + math.pi * 0.5), 24 * math.sin(w + math.pi * 1.5))
            setr('hals', 14); setr('kopf', 8)
        else:
            u = (p - 0.5) / 0.5; u2 = u * u * (3 - 2 * u)
            root(dy=-1.2 + 1.2 * u2, dz=0.02 * math.sin(math.pi * u), pitch=-6 * math.sin(math.pi * u))
            setr('hals', 14 - 20 * math.sin(math.pi * u)); setr('kopf', 8 - 8 * u)
        setr('ohrL', -30); setr('ohrR', -30)
    def treffer(p):
        clear(); u = math.sin(math.pi * p); root(dy=0.08 * u, pitch=-5 * u); setr('kopf', 12 * u, Zv); setr('kiefer', -16 * u); setr('rute0', -30 * u)
    def ausweichen(p):
        clear(); u = math.sin(math.pi * p); root(dx=0.24 * u, dz=0.03 * u); setr('ruecken', 8 * u, Zv); legs(-8 * u, 10 * u, 8 * u, -8 * u)
    def tod(p):        # auf die Seite, Läufe steif (30 Bilder)
        clear(); u = min(1, p * 1.3); u = u * u * (3 - 2 * u)
        root(dz=-0.42 * u, dx=0.05 * u); PB['root'].rotation_quaternion = rot('root', 80 * u, Yv)
        legs(24 * u, 14 * u, -24 * u, -14 * u, bend=10 * u); setr('hals', -10 * u); setr('kiefer', -12 * u)
    def schnauben(p):  # Ruhebewegung (wie Lefzen beim Wolf): Kopf hoch, Rüssel wittert, Maul kurz auf (2 s)
        stehen(p * 2 % 1); u = min(1, p / 0.25, (1 - p) / 0.25); u = u * u * (3 - 2 * u)
        setr('hals', -10 * u); setr('kopf', -8 * u + 3 * math.sin(p * 30) * u); setr('kiefer', -10 * u * (0.5 + 0.5 * math.sin(p * 20)))
    def scharren(p, sd='L'):     # mit dem Vorderhuf scharren (1,6 s): heben, vor, über den Boden zurück, zweimal
        stehen(p)
        q = (p - 0.05) / 0.9
        if 0 < q < 1:
            c = q * 2 % 1
            hub = math.sin(math.pi * min(1, c / 0.5)) if c < 0.5 else 0.0
            zug = 0.0 if c < 0.5 else math.sin(math.pi * (c - 0.5) / 0.5)
            setr('oberarm' + sd, -28 * hub + 16 * zug); setr('unterarm' + sd, -55 * hub - 8 * zug); setr('vpfote' + sd, 20 * hub)
            setr('hals', 10); setr('kopf', 6)
    def drohen(p):     # wie Heulen beim Wolf: Kopf hoch, Maul auf, Kamm gesträubt (alt: neck 18, nod -24, mouth 0,8)
        clear(); u = math.sin(math.pi * min(1, p * 1.2)); root(dz=-0.02 * u, pitch=-4 * u); setr('hals', -18 * u); setr('kopf', -16 * u)
        setr('kiefer', -24 * u)
    return [('Stehen', 60, stehen, True), ('Gehen', 24, gehen, True), ('Hocke', 30, hocke, True), ('Hauer', 18, hauer, False),
            ('Ansturm', 24, ansturm, False), ('Treffer', 12, treffer, False), ('Ausweichen', 12, ausweichen, False),
            ('Tod', 30, tod, False), ('Schnauben', 60, schnauben, False), ('Scharren', 48, scharren, False),
            ('ScharrenR', 48, lambda p: scharren(p, 'R'), False), ('Drohen', 36, drohen, False)]


FELL_PNG = os.path.join(vb.OUT, 'boar-fell.png')
FELL_MEAN = vb.fell_textur(FELL_PNG, seed=13, laenge=(22, 50), striche=4800, kontrast=0.9)    # Runde 2: „feinkörniges Rauschen, flimmert“

if __name__ == '__main__':
    vb.alle(sys.modules[__name__])
