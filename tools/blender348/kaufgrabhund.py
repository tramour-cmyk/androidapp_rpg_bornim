# 506 Grabhund (Wochenziel 03.11. Reihe 2; Kauf 348.12c A, Chef 03.11., 15:40: „506 baut die Untoten aus dem Kauf“): gekaufter
# Protofactor „Barghest“ (privates Repo, $KAUF, nie hierher und nie als Artefakt) nach `LISTE-FIGUREN.md` „Grabhund“ (ersetzt den
# Ghul, 348.12c; Regeln bleiben die des Ghuls, Monsters.kt ghoul):
#   1 Schulter 90–100 cm, Rücken etwa auf Hüfthöhe des Helden; jeder schlank, mittel oder kräftig (hier je Haut eine Statur)
#   2 Riesenhund auf vier Beinen, tiefe Brust, schmale Hüften, schwere Mähne über Hals und Schultern
#   3 schwarze Mähne über nackter fahler Haut; langer Fang mit gebleckten Zähnen; Augen klar gelb oder rot (995, ersetzt „matt“)
#   4 Haut leichenfahl, grabgrau oder graublau, Mähne schwarz; drei Tiere auf einen Blick verschieden (Mähne lang, kurz oder
#     zerrupft, Narben)
#   5 Kopf gesenkt, lautlos, lauernd (Stehen = idleAggressive des Kaufs: Kopf tief, gemessen in KOPF)
# Bemalung wie bei den anderen Kauftieren: aus dem Kaufbild nur die Helligkeit, Farben und Narben sind unsere; das Leuchtbild (ILLUM)
# bleibt weg, die Augen malt male_auge (995). Mähne und Schwanzhaar sind im Kauf Haarkarten mit Durchsicht: Bild mit Alpha
# (BARGHEST_HAIR_Transparency), im glTF „MASK“; figur.gd gibt dem Stoff „schnitt“ (toon.gdshader schneidet dort aus).
# Bewegungen unter unseren Namen (figur.gd, wie die Riesenspinne: eigene Häute in ghoul-info.json), Wurzelweg aus den _RM-Dateien;
# im Kauf fehlt das Ausweichen (aus dem Gehen mit seitlichem Weg, wie kaufspinne.py).
# Aufruf: KAUF=<ordner> OUT=<ordner> [FELL=fahl] python -I kaufgrabhund.py  ->  <OUT>/ghoul-<haut>.glb, ghoul-info.json
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kaufquelle     # 980: von doppelten Kaufdateien nur, was Blender liest (Binär-FBX)
T0 = time.time()
import bpy
import bmesh
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from kaufratte import lin, srgb, tris, aktion_von, weg as entferne, slot, welt_netz, importiere
from kaufspinne import male_lage, gewicht_feld

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
ID = 'ghoul'
TEX = 1024
HAAR_TEX = 512
FPS = 30
# Modellregel 7: ganze Figur unter 6.000 Dreiecken (Kauf: Körper 14.338, Mähne 3.520, Schwanzhaar 1.316)
KOERPER_DREIECKE = int(os.environ.get('DREIECKE', '3000'))
MAEHNE_DREIECKE, SCHWANZ_DREIECKE = 2200, 600
RNG = np.random.default_rng(5062)
P = 'BARGHEST_ '

# Liste 4: drei Tiere auf einen Blick verschieden: Haut, Mähne, Narben; dazu je eine Statur (Liste 1)
HAEUTE = {
    'fahl': {'haut': 0xA49A8C, 'tief': 0x403830, 'maehne': 'lang', 'statur': 'mittel', 'narben': 1},
    'grabgrau': {'haut': 0x76726A, 'tief': 0x2C2824, 'maehne': 'kurz', 'statur': 'kraeftig', 'narben': 4},
    'graublau': {'haut': 0x66707C, 'tief': 0x22262E, 'maehne': 'zerrupft', 'statur': 'schlank', 'narben': 2},
}
STATUR = {'schlank': (0.90, 0.91), 'mittel': (1.0, 0.95), 'kraeftig': (1.12, 0.99)}     # (Dicke, Schulter m)
MAEHNE_SCHWARZ = 0x141210
NARBE, NARBE_RAND = 0xC2AEA2, 0x3A2A26
MAUL, ZAHN = 0x3E1E1C, 0xA8987A     # Zahnfleisch dunkel, Zähne vergilbt
# 995 (Chef 11.11., 20:58, Film 744: „klar erkennbare Augen in einer klaren Farbe, rot oder gelb“; ersetzt „Augen matt“ aus 506 und
# Liste 3): das Auge ist im Kauf eine eigene runde UV-Insel (Mitte, Halbmesser im Bild, gemessen an den UV der Augenflächen). Iris in
# klarer Farbe mit Schlitzpupille, dunkler Rand; eigener Stoff „Auge“, den figur.gd leicht von selbst leuchten lässt (im Schatten lesbar)
AUGE_MITTE, AUGE_R = (0.480, 0.902), 0.086
IRIS = {'gelb': 0xF0B818, 'rot': 0xD8281C}
AUGE_FARBE = os.environ.get('AUGE', 'gelb')
PUPILLE, AUGE_RAND = 0x080606, 0x120C0A
# 995 („Nasenrücken und Ohren lesbarer“): Nasenspiegel schwarz, Nasenrücken als dunklere Kante zu den Seiten des Fangs, Ohren innen
# dunkel; Lage im Kaufnetz (Ruhelage, Kopf −Y), gemessen: Schnauze vorn y −1,58, Stirnabsatz y −1,42, Ohren über z 1,30 bei |x| ab 0,17
NASE, FANG_SEITE, OHR_INNEN = 0x161210, 0x2C2420, 0x1E1614
AUGE_HOEHLE = 0x140E0C
ERDE = 0x1E1A16     # 995: Läufe und Bauch zum Boden hin
AO_TIEFE = 0.55     # Anteil des Kauf-AO an der Helligkeit (0 aus)

# unser Name <- Kaufdatei (ohne „BARGHEST@“)
NAMEN = [('Stehen', 'idleAggressive'), ('Lefzen', 'idleBreathe'), ('Umsehen', 'idleLookAround'), ('Gehen', 'walk'),
         ('Rennen', 'run'), ('Biss', 'biteAggressive'), ('Sprungbiss', 'jumpBiteAggressive'), ('Treffer', 'getHitAggressive'),
         ('Tod', 'deathAggressive')]
WEGE = [('Gehen', 'walk'), ('Rennen', 'run'), ('Sprungbiss', 'jumpBiteAggressive')]
AUSWEICHEN_M = float(os.environ.get('AUSWEICHEN_M', '1.1'))
AUSWEICHEN_BILDER = 12


def quelle():
    if not KAUF:
        sys.exit('KAUF fehlt (Ordner mit den gekauften Modellen)')
    t = kaufquelle.alle(KAUF, 'BARGHEST_AllMeshes.FBX', 'GRABHUND')
    if not t:
        sys.exit('BARGHEST_AllMeshes.FBX nicht gefunden unter %s' % KAUF)
    d = os.path.dirname(t[0])
    return t[0], d, os.path.join(os.path.dirname(d), 'Textures')


def bild(pfad, kante, modus='RGB'):
    from PIL import Image
    im = Image.open(pfad).convert(modus)
    if im.size[0] != kante:
        im = im.resize((kante, kante), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def rauschen(n, glatt, kante=TEX):
    from PIL import Image, ImageFilter
    r = RNG.random((kante // n, kante // n)).astype(np.float32)
    im = Image.fromarray((r * 255).astype(np.uint8)).resize((kante, kante), Image.BICUBIC).filter(ImageFilter.GaussianBlur(glatt))
    a = np.asarray(im, np.float32) / 255.0
    return (a - a.min()) / max(a.max() - a.min(), 1e-4)


def narben_fn(koerper, n):
    """Narben (Liste 4): n Risse quer über Flanke, Schulter und Schenkel, im Raum gemalt (Kauf-UV ist gespiegelt), je Tier anders."""
    Pk = np.array([(koerper.matrix_world @ v.co)[:] for v in koerper.data.vertices])
    lo, hi = Pk.min(0), Pk.max(0)
    seg = []
    for i in range(n):
        seite = 1 if i % 2 == 0 else -1
        y = lo[1] + (hi[1] - lo[1]) * RNG.uniform(0.3, 0.7)          # entlang des Körpers (ohne Kopf und Schwanz)
        z = lo[2] + (hi[2] - lo[2]) * RNG.uniform(0.45, 0.7)
        band = Pk[(np.abs(Pk[:, 1] - y) < 0.04 * (hi[1] - lo[1])) & (np.abs(Pk[:, 2] - z) < 0.06 * (hi[2] - lo[2]))]
        if not len(band):
            continue
        x = band[:, 0].max() if seite > 0 else band[:, 0].min()
        mitte = np.array([x, y, z])
        w = RNG.uniform(-0.6, 0.6)
        lang = (hi[1] - lo[1]) * RNG.uniform(0.07, 0.12)
        d = np.array([0.0, math.cos(w), math.sin(w)]) * lang
        for k in range(3):     # drei Krallenstriche nebeneinander
            o = np.array([0.0, -math.sin(w), math.cos(w)]) * (k - 1) * lang * 0.18
            seg.append((mitte + o - d / 2, mitte + o + d / 2))
    breit = (hi[1] - lo[1]) * 0.006

    def fn(X, grob=False):
        w = np.zeros(len(X))
        r = breit * (6.0 if grob else 1.0)
        for a0, a1 in seg:
            s = a1 - a0
            t = np.clip(((X - a0) @ s) / max(s @ s, 1e-9), 0, 1)
            ab = np.linalg.norm(X - (a0 + t[:, None] * s), axis=1)
            w = np.maximum(w, np.clip((1.0 - ab / r) * 1.8, 0, 1))
        return w
    return fn, len(seg)


def maehne_fn(koerper):
    """Mähne (Liste 2, 3): über Hals und Schultern oben, dazu ein schmaler Grat den Rücken entlang; Kaufnetz in Ruhelage, Kopf −Y."""
    Pk = np.array([(koerper.matrix_world @ v.co)[:] for v in koerper.data.vertices])
    lo, hi = Pk.min(0), Pk.max(0)
    L, H, W = hi[1] - lo[1], hi[2] - lo[2], hi[0] - lo[0]

    def fn(X, grob=False):
        u = (X[:, 1] - lo[1]) / L          # 0 Schnauze … 1 Schwanzende
        h = (X[:, 2] - lo[2]) / H
        q = np.abs(X[:, 0] - (lo[0] + hi[0]) / 2) / W
        # 506 (Chef 10.11., 12:25: „oben ist eine dunkle Mähne und dann haben alle drei einen rechteckigen Fleck … eigentlich keine
        # Augen“): die Mähne begann bei u 0,10 und deckte Scheitel, Stirn und Augen mit geraden Kanten (Kaufbild: schwarzer Block über
        # dem Kopf). Jetzt erst hinter den Ohren (u 0,17), Kanten weich und unregelmäßig wie Fell
        zack = 0.025 * np.sin(X[:, 0] * 41.0 + X[:, 2] * 23.0) + 0.018 * np.sin(X[:, 1] * 57.0 + X[:, 0] * 13.0)
        # Probebild 13:32: der „rechteckige Fleck“ war die bemalte Halsflanke (h ab 0,55 = halbe Flanke, unter den Haarkarten frei
        # sichtbar); jetzt nur der Kamm unter der Mähne (oben, schmal), die Flanke bleibt Haut
        hals = np.clip((u - 0.17 + zack) / 0.06, 0, 1) * np.clip((0.50 - u + zack) / 0.08, 0, 1) * np.clip((h - 0.74 + zack) / 0.08, 0, 1) \
            * np.clip((0.22 - q + zack) / 0.08, 0, 1)
        grat = np.clip((u - 0.40 + zack) / 0.06, 0, 1) * np.clip((0.78 - u + zack) / 0.08, 0, 1) * np.clip((h - 0.72 + zack) / 0.07, 0, 1) \
            * np.clip((0.12 - q + zack) / 0.05, 0, 1)
        w = np.maximum(hals, grat)
        return np.clip(w * (3.0 if grob else 1.0), 0, 1)
    return fn


def bemale(koerper, tex_dir, haut):
    """Kaufbild -> unsere Haut: Helligkeit des Kaufs (Falten, Adern, Fell der Mähne), Farben unsere. Dunkle Stellen (der Kauf malt
    die Mähne auf den Rücken) werden schwarz, rote (Maul, Zahnfleisch) dunkel und gedämpft, gelbe (Zähne) vergilbt, das Auge matt."""
    a = bild(os.path.join(tex_dir, 'BARGHEST_BaseColor.jpg'), TEX)
    lum = a.mean(2)
    sat = a.max(2) - a.min(2)
    bel = lum > 0.02
    med = float(np.median(lum[bel & (lum > 0.3)])) if (bel & (lum > 0.3)).any() else 0.6
    t = np.clip(lum / max(med, 1e-3), 0.0, 1.6)[..., None]
    hautc, tief = np.array(lin(haut['haut'])), np.array(lin(haut['tief']))
    b = tief + (hautc - tief) * np.clip((t - 0.35) / 0.75, 0, 1) ** 1.2
    # Liste 3 „schwarze Mähne über nackter fahler Haut“: der Kauf malt Rücken und Flanken dunkel wie Fell (Bild 11:48: las sich
    # als brauner Wolf). Dort Haut in mittlerer Helligkeit; schwarz nur die Mähne über Hals und Schultern und ein Grat den Rücken
    # entlang, im Raum gemalt (MAEHNE_FN)
    dunkel = np.clip((0.22 - lum) / 0.12, 0, 1)[..., None]
    b = b * (1 - dunkel) + (tief + (hautc - tief) * 0.55) * (0.85 + 0.3 * rauschen(20, 2)[..., None]) * dunkel
    m = dunkel * 0.0
    rot = np.clip((a[..., 0] - a[..., 1] * 1.25 - 0.06) * 6, 0, 1) * np.clip((sat - 0.18) * 6, 0, 1)
    gelb = np.clip((np.minimum(a[..., 0], a[..., 1]) - a[..., 2] * 1.6 - 0.05) * 6, 0, 1) * (lum > 0.35)
    b = b * (1 - rot[..., None]) + np.array(lin(MAUL)) * (0.5 + 0.6 * t) * rot[..., None]
    b = b * (1 - gelb[..., None]) + np.array(lin(ZAHN)) * (0.6 + 0.4 * t) * gelb[..., None]
    b = male_lage(b, koerper, maehne_fn(koerper), lin(MAEHNE_SCHWARZ), 0.95, 2.5)
    # 995 Kopf lesbar: Seiten des Fangs dunkler (der Nasenrücken bleibt hell und steht als Kante), Nasenspiegel schwarz, Ohren dunkel
    # 995: Falten und Senken aus dem Schattenbild des Kaufs (AO) tiefer, damit der Körper Form zeigt statt flach und durchscheinend
    ao = bild(os.path.join(tex_dir, 'BARGHEST_AO.jpg'), TEX).mean(2)[..., None]
    b *= (1.0 - AO_TIEFE) + AO_TIEFE * ao
    # 995 („wirkt durch seine Farbe unstrukturiert, wie halb transparent“): Hell-Dunkel von oben nach unten, Bauch und Läufe zum
    # Boden hin dunkel wie von Grabeserde, die Pfoten fast schwarz; oben bleibt die fahle Haut
    b = male_lage(b, koerper, unten_fn(koerper), lin(ERDE), 0.85, 3.0)
    b = male_lage(b, koerper, ruecken_fn, lin(FANG_SEITE), 0.55, 1.5)
    b = male_lage(b, koerper, fang_fn, lin(FANG_SEITE), 0.85, 2.0)
    b = male_lage(b, koerper, hoehle_fn, lin(AUGE_HOEHLE), 0.9, 1.5)
    b = male_lage(b, koerper, ohr_fn, lin(OHR_INNEN), 0.75, 1.5)
    b = male_lage(b, koerper, nase_fn, lin(NASE), 0.95, 1.0)
    # Haut fleckig wie Leichenhaut, nicht glatt
    b *= (0.9 + 0.18 * rauschen(48, 1.0)[..., None])
    fn, n = narben_fn(koerper, haut['narben'])
    if n:
        b = male_lage(b, koerper, fn, lin(NARBE_RAND), 0.7, 1.4)
        b = male_lage(b, koerper, lambda X, grob=False: np.clip(fn(X, grob) * 1.6 - 0.6, 0, 1), lin(NARBE), 0.9, 0.6)
    b, aug = male_auge(b)
    print('BEMALUNG %s: Mähne %.1f %%, Maul %.1f %%, Zähne %.1f %%, Auge %.2f %% (%s), Narben %d Striche' % (
        haut['haut'], 100 * float((m[..., 0] > 0.5)[bel].mean()), 100 * float((rot > 0.5)[bel].mean()),
        100 * float((gelb > 0.5)[bel].mean()), 100 * float(aug.mean()), AUGE_FARBE, n))
    return np.clip(srgb(b), 0, 1)


def male_auge(b):
    """995: die runde Augeninsel des Kaufs neu: Iris in klarer Farbe (innen heller), senkrechte Schlitzpupille, dunkler Ring, außen
    die Lidhöhle dunkel. Gibt das Bild und die Maske der Insel (Bildpunkte) zurück."""
    k = b.shape[0]
    y, x = np.mgrid[0:k, 0:k].astype(np.float32) + 0.5
    dx = (x / k - AUGE_MITTE[0]) / AUGE_R
    dy = (y / k - AUGE_MITTE[1]) / AUGE_R
    r = np.sqrt(dx * dx + dy * dy)
    insel = r < 1.0
    iris = np.array(lin(IRIS[AUGE_FARBE]))
    c = iris * (1.15 - 0.45 * np.clip(r / 0.6, 0, 1))[..., None]          # innen heller, zum Rand satter
    ring = np.clip((r - 0.50) / 0.08, 0, 1)[..., None]
    c = c * (1 - ring) + np.array(lin(AUGE_RAND)) * ring
    breite = 0.10 * np.clip(1.0 - (dy / 0.46) ** 2, 0, 1)
    pup = np.clip((breite - np.abs(dx)) / 0.03, 0, 1)[..., None]
    c = c * (1 - pup) + np.array(lin(PUPILLE)) * pup
    b = np.where(insel[..., None], c, b)
    return b, insel


def _profil(koerper):
    """Halbe Breite des Kopfes je Länge (Kaufnetz, Ruhelage) als Stützstellen für fang_fn."""
    Pk = np.array([(koerper.matrix_world @ v.co)[:] for v in koerper.data.vertices])
    w = gewicht_feld(koerper, ('Head',))
    H = Pk[w > 0.5]
    ys = np.arange(H[:, 1].min(), -1.30, 0.02)
    xm = np.array([np.abs(H[np.abs(H[:, 1] - y) < 0.02][:, 0]).max() if (np.abs(H[:, 1] - y) < 0.02).any() else 0.1 for y in ys])
    return ys, np.maximum(xm, 0.03)


PROFIL = None


def fang_fn(X, grob=False):
    """Seiten des Fangs (Stirnabsatz bis Nasenspitze): je weiter außen, desto dunkler; der Rücken (|x| klein) bleibt hell."""
    ys, xm = PROFIL
    y = X[:, 1]
    rel = np.abs(X[:, 0]) / np.interp(y, ys, xm)
    w = np.clip((rel - 0.30) / 0.25, 0, 1) * np.clip((-1.36 - y) / 0.05, 0, 1) * np.clip((X[:, 2] - 0.80) / 0.05, 0, 1)
    return np.clip(w * (3.0 if grob else 1.0), 0, 1)


def unten_fn(koerper):
    """Gewicht nach der Höhe im Kaufnetz (Ruhelage): ab gut halber Körperhöhe abwärts zunehmend, an den Pfoten voll; der Kopf
    bleibt aus (er hat seine eigene Zeichnung)."""
    Pk = np.array([(koerper.matrix_world @ v.co)[:] for v in koerper.data.vertices])
    lo, hi = Pk.min(0), Pk.max(0)
    H = hi[2] - lo[2]

    def fn(X, grob=False):
        h = (X[:, 2] - lo[2]) / H
        kopf = np.clip((h - 0.5) / 0.1, 0, 1) * np.clip((-1.2 - X[:, 1]) / 0.1, 0, 1)
        w = np.clip((0.60 - h) / 0.45, 0, 1) ** 1.1 * (1 - kopf)
        return np.clip(w * (1.5 if grob else 1.0), 0, 1)
    return fn


def ruecken_fn(X, grob=False):
    """Kante des Nasenrückens: schmaler dunkler Strich beidseits des hellen Rückens (relative Breite um 0,24) von der Nasenspitze
    bis zum Stirnabsatz; so steht der Rücken als helle Linie zwischen zwei Kanten."""
    ys, xm = PROFIL
    rel = np.abs(X[:, 0]) / np.interp(X[:, 1], ys, xm)
    w = np.clip(1.0 - np.abs(rel - 0.24) / 0.08, 0, 1) * np.clip((-1.38 - X[:, 1]) / 0.04, 0, 1) * np.clip((X[:, 1] + 1.53) / 0.02, 0, 1)
    return np.clip(w * (3.0 if grob else 1.0), 0, 1)


AUGEN = None     # Mitten der beiden Augen (Kaufnetz, Ruhelage), aus den Flächen der Augeninsel


def hoehle_fn(X, grob=False):
    """Augenhöhle: dunkler Hof um jedes Auge (wie die tiefen Höhlen des alten Ghuls, Doll.kt ghoulFace), länglich zur Schnauze hin;
    die helle Iris steht davor, das Auge wird auch klein im Kampfort lesbar."""
    w = np.zeros(len(X))
    for m in AUGEN:
        d = X - m
        r = np.sqrt((d[:, 0] / 0.05) ** 2 + (d[:, 1] / 0.075) ** 2 + (d[:, 2] / 0.055) ** 2)
        w = np.maximum(w, np.clip((1.0 - r) / 0.35, 0, 1))
    return np.clip(w * (3.0 if grob else 1.0), 0, 1)


def augen_mitten(koerper):
    uv = koerper.data.uv_layers.active.data
    M = koerper.matrix_world
    P = []
    for p in koerper.data.polygons:
        if all(((uv[li].uv[0] - AUGE_MITTE[0]) ** 2 + ((1 - uv[li].uv[1]) - AUGE_MITTE[1]) ** 2) <= (AUGE_R * 1.02) ** 2 for li in p.loop_indices):
            P.append((M @ p.center)[:])
    P = np.array(P)
    if not len(P):
        sys.exit('Augeninsel nicht gefunden (AUGE_MITTE, AUGE_R)')
    m = [P[P[:, 0] > 0].mean(0), P[P[:, 0] < 0].mean(0)]
    print('AUGEN Mitten %s' % [np.round(x, 3).tolist() for x in m])
    return m


def ohr_fn(X, grob=False):
    """Ohren: über z 1,30 außen am Kopf (|x| ab 0,17) zwischen y −1,28 und −1,06; nach vorn (Innenseite) dunkler."""
    w = np.clip((X[:, 2] - 1.29) / 0.04, 0, 1) * np.clip((np.abs(X[:, 0]) - 0.16) / 0.03, 0, 1) \
        * np.clip((X[:, 1] + 1.29) / 0.03, 0, 1) * np.clip((-1.05 - X[:, 1]) / 0.03, 0, 1)
    w = w * (0.55 + 0.45 * np.clip((-1.13 - X[:, 1]) / 0.08, 0, 1))
    return np.clip(w * (3.0 if grob else 1.0), 0, 1)


def nase_fn(X, grob=False):
    """Nasenspiegel: vorn an der Schnauze (y unter −1,515), obere Hälfte."""
    w = np.clip((-1.515 - X[:, 1]) / 0.025, 0, 1) * np.clip((X[:, 2] - 0.875) / 0.03, 0, 1)
    return np.clip(w * (3.0 if grob else 1.0), 0, 1)


KOPF_ANTEIL = float(os.environ.get('KOPF_ANTEIL', '0.65'))     # 995: Anteil des Kopfes an den Dreiecken des Körpers


def kopf_dreiecke(o, gname=None):
    """Dreiecke, deren Ecken alle überwiegend am Kopfknochen hängen."""
    w = gewicht_feld(o, ('Head',))
    return int(sum(len(p.vertices) - 2 for p in o.data.polygons if all(w[v] > 0.5 for v in p.vertices)))


def kopf_gruppe(o):
    """Gewicht des Kopfknochens je Ecke als Gruppe „Kopf“ (weich zum Hals hin)."""
    w = gewicht_feld(o, ('Head',))
    g = o.vertex_groups.new(name='Kopf')
    for i, x in enumerate(w):
        if x > 0.01:
            g.add([i], float(min(1.0, x)), 'REPLACE')
    print('KOPF %d von %d Ecken geschont' % (int((w > 0.5).sum()), len(w)))
    return g.name


def kopf_gruppe(o):
    """Gewicht des Kopfknochens je Ecke als Gruppe „Kopf“ (weich zum Hals hin)."""
    w = gewicht_feld(o, ('Head',))
    g = o.vertex_groups.new(name='Kopf')
    for i, x in enumerate(w):
        if x > 0.01:
            g.add([i], float(min(1.0, x)), 'REPLACE')
    print('KOPF %d von %d Ecken geschont' % (int((w > 0.5).sum()), len(w)))
    return g.name


def naht_gruppe(o):
    """Ecken auf UV-Nähten (Kante, deren zwei Flächen dort verschiedene UV haben) und offenen Rändern: Gruppe „Naht“, Gewicht 1."""
    bm = bmesh.new(); bm.from_mesh(o.data)
    uv = bm.loops.layers.uv.active
    ecken = set()
    for e in bm.edges:
        if len(e.link_faces) != 2:
            ecken.update(v.index for v in e.verts); continue
        f0, f1 = e.link_faces
        for v in e.verts:
            a = next(l[uv].uv for l in f0.loops if l.vert == v)
            b = next(l[uv].uv for l in f1.loops if l.vert == v)
            if (a - b).length > 1e-5:
                ecken.update(x.index for x in e.verts); break
    bm.free()
    g = o.vertex_groups.new(name='Naht')
    g.add(sorted(ecken), 1.0, 'REPLACE')
    print('NAHT %d von %d Ecken geschützt' % (len(ecken), len(o.data.vertices)))
    return g.name


def auge_stoff(koerper, mat):
    """995: Flächen der Augeninsel (alle UV im Kreis) bekommen einen eigenen Stoff „Auge“ (selbes Bild); figur.gd lässt ihn leuchten."""
    auge = mat.copy()
    auge.name = 'Auge'
    koerper.data.materials.append(auge)
    i = len(koerper.data.materials) - 1
    uv = koerper.data.uv_layers.active.data
    n = 0
    for p in koerper.data.polygons:
        drin = True
        for li in p.loop_indices:
            u, v = uv[li].uv
            if ((u - AUGE_MITTE[0]) ** 2 + ((1 - v) - AUGE_MITTE[1]) ** 2) > (AUGE_R * 1.02) ** 2:
                drin = False
                break
        if drin:
            p.material_index = i
            n += 1
    print('AUGE %d Flächen, Farbe %s' % (n, AUGE_FARBE))
    if n == 0:
        sys.exit('Augeninsel nicht gefunden (AUGE_MITTE, AUGE_R)')


def haar_bild(tex_dir):
    """Haarkarten (Mähne, Schwanz): schwarz, Helligkeit der Strähnen aus dem Kauf, Alpha aus BARGHEST_HAIR_Transparency."""
    a = bild(os.path.join(tex_dir, 'BARGHEST_HAIR.tga'), HAAR_TEX, 'RGBA')
    al = bild(os.path.join(tex_dir, 'BARGHEST_HAIR_Transparency.jpg'), HAAR_TEX, 'L')
    lum = a[..., :3].mean(2)
    c = np.array(lin(MAEHNE_SCHWARZ)) * (0.8 + 1.4 * np.clip(lum / 0.3, 0, 1))[..., None]
    rgba = np.concatenate([np.clip(srgb(c), 0, 1), al[..., None]], axis=2)
    return rgba


def speichere(b, name, jpg=True):
    from PIL import Image
    if jpg:
        p = os.path.join(OUT, 'tex_grabhund_%s.jpg' % name)
        Image.fromarray((b * 255).astype(np.uint8)).save(p, quality=90)
    else:
        p = os.path.join(OUT, 'tex_grabhund_%s.png' % name)
        Image.fromarray((b * 255).astype(np.uint8), 'RGBA').save(p)
    return p


def material(o, bildpfad, name, schnitt=False):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = nt.nodes.get('Principled BSDF')
    ti = nt.nodes.new('ShaderNodeTexImage')
    ti.image = bpy.data.images.load(bildpfad, check_existing=False)
    nt.links.new(ti.outputs['Color'], bsdf.inputs['Base Color'])
    bsdf.inputs['Roughness'].default_value = 0.85
    if schnitt:     # glTF „MASK“: Alpha über einen Rundungsknoten (so erkennt der Exporter das Ausschneiden, Grenze 0,5)
        r = nt.nodes.new('ShaderNodeMath'); r.operation = 'ROUND'
        nt.links.new(ti.outputs['Alpha'], r.inputs[0])
        nt.links.new(r.outputs[0], bsdf.inputs['Alpha'])
        if hasattr(mat, 'surface_render_method'):
            mat.surface_render_method = 'DITHERED'
        if hasattr(mat, 'blend_method'):
            try:
                mat.blend_method = 'CLIP'
            except TypeError:
                pass
    o.data.materials.clear()
    o.data.materials.append(mat)


def inseln(o):
    """Zusammenhängende Teile eines Netzes (je Haarkarte eins): Liste von Eckenlisten."""
    bm = bmesh.new(); bm.from_mesh(o.data); bm.verts.ensure_lookup_table()
    gesehen, aus = set(), []
    for v in bm.verts:
        if v.index in gesehen:
            continue
        stapel, teil = [v], []
        gesehen.add(v.index)
        while stapel:
            x = stapel.pop(); teil.append(x.index)
            for e in x.link_edges:
                y = e.other_vert(x)
                if y.index not in gesehen:
                    gesehen.add(y.index); stapel.append(y)
        aus.append(teil)
    bm.free()
    return aus


def haar_formen(haar, koerper, art, budget, name):
    """Liste 4 „Mähne lang, kurz oder zerrupft“: jede Haarkarte um ihre Wurzel (Ecke am nächsten zur Haut) gestreckt oder gestaucht,
    bei „zerrupft“ ungleich und mit Lücken; danach Karten weglassen, bis das Budget passt (gleichmäßig verteilt, nach Zufall)."""
    dg = bpy.context.evaluated_depsgraph_get()
    bm = bmesh.new(); bm.from_mesh(koerper.data); bm.transform(koerper.matrix_world)
    baum = BVHTree.FromBMesh(bm); bm.free()
    teile = inseln(haar)
    Mw, Mi = haar.matrix_world, haar.matrix_world.inverted()
    V = haar.data.vertices
    faktor = {'lang': 1.35, 'kurz': 0.62, 'zerrupft': None}.get(art, 1.0)
    weg_teile = set()
    for i, teil in enumerate(teile):
        W = [Mw @ V[k].co for k in teil]
        ab = [baum.find_nearest(p)[3] or 0.0 for p in W]
        w = W[int(np.argmin(ab))]
        f = faktor if faktor is not None else float(RNG.uniform(0.45, 1.25))
        if faktor is None and RNG.random() < 0.3:
            weg_teile.add(i)
        for k, p in zip(teil, W):
            V[k].co = Mi @ (w + (p - w) * f)
    # Budget: Dreiecke je Karte, Karten weglassen
    ecke_teil = {}
    for i, teil in enumerate(teile):
        for k in teil:
            ecke_teil[k] = i
    dreiecke = np.zeros(len(teile))
    for p in haar.data.polygons:
        dreiecke[ecke_teil[p.vertices[0]]] += len(p.vertices) - 2
    rest = [i for i in range(len(teile)) if i not in weg_teile]
    RNG.shuffle(rest)
    summe = float(dreiecke[rest].sum())
    while summe > budget and rest:
        i = rest.pop(); weg_teile.add(i); summe -= dreiecke[i]
    if weg_teile:
        bm = bmesh.new(); bm.from_mesh(haar.data); bm.verts.ensure_lookup_table()
        bmesh.ops.delete(bm, geom=[bm.verts[k] for i in weg_teile for k in teile[i]], context='VERTS')
        bm.to_mesh(haar.data); bm.free()
    print('HAAR %s %s: %d Karten, %d weg, Faktor %s, Dreiecke %d' % (name, art, len(teile), len(weg_teile),
          'je Karte 0,45–1,25' if faktor is None else '%.2f' % faktor, tris([haar])))


def statur(rig, netze, dicke):
    """Liste 1: jede Ecke um die Achse ihres Hauptknochens (Ruhelage) dicker oder dünner; Kopf bleibt (Fang, Augen)."""
    if abs(dicke - 1.0) < 1e-3:
        return
    Mr = rig.matrix_world
    for o in netze:
        namen = {g.index: g.name for g in o.vertex_groups}
        Mk, Mi = o.matrix_world, o.matrix_world.inverted()
        for v in o.data.vertices:
            if not v.groups:
                continue
            g = max(v.groups, key=lambda g: g.weight)
            b = rig.data.bones.get(namen.get(g.group, ''))
            if b is None or 'Head' in b.name:
                continue
            h, t = Mr @ b.head_local, Mr @ b.tail_local
            p = Mk @ v.co
            ax = t - h
            u = max(0.0, min(1.0, (p - h).dot(ax) / max(ax.length_squared, 1e-9)))
            q = h + ax * u
            v.co = Mi @ (q + (p - q) * dicke)
    print('STATUR Dicke %.2f' % dicke)


def aktionen(d):
    akt = {}
    for nm, q in NAMEN:
        f = os.path.join(d, 'BARGHEST@%s.FBX' % q)
        if not os.path.exists(f):
            print('FEHLT Bewegung', q); continue
        neu = importiere(f)
        a = aktion_von(neu)
        if a is None:
            entferne(neu); print('FEHLT Aktion', q); continue
        a.use_fake_user = True
        akt[nm] = a
        entferne(neu)
    return akt


def wurzelweg(d, s):
    """Wurzelweg je Bewegung: Ort des Beckens aus der _RM-Datei minus dem der Datei ohne Weg, in unseren Metern."""
    wege = {}
    for nm, q in WEGE:
        bahn = []
        for v in (q, q + '_RM'):
            f = os.path.join(d, 'BARGHEST@%s.FBX' % v)
            if not os.path.exists(f):
                break
            neu = importiere(f)
            r = next((o for o in neu if o.type == 'ARMATURE'), None)
            a = aktion_von(neu)
            if r is None or a is None or P + 'Pelvis' not in r.pose.bones:
                entferne(neu); break
            pb = r.pose.bones[P + 'Pelvis']
            pts = []
            for fr in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1):
                bpy.context.scene.frame_set(fr)
                pts.append((r.matrix_world @ pb.matrix).translation.copy())
            bahn.append(pts)
            entferne(neu)
        if len(bahn) < 2:
            print('WEG fehlt', q); continue
        k = min(len(bahn[0]), len(bahn[1]))
        w = []
        for i in range(k):
            p = (bahn[1][i] - bahn[0][i]) - (bahn[1][0] - bahn[0][0])
            w.append([round(p.x * s, 4), round(-p.y * s, 4)])     # Blender −Y vorn = glTF +Z
        wege[nm] = w
        print('WEG %s (%s): %d Bilder, Ende x %.3f z %.3f m, %.2f m/s' % (
            nm, q, k, w[-1][0], w[-1][1], math.hypot(w[-1][0], w[-1][1]) / max((k - 1) / FPS, 1e-3)))
    return wege


def kopf_hoehe(rig, a):
    rig.animation_data.action = a
    if slot(a) is not None:
        rig.animation_data.action_slot = slot(a)
    z = []
    for f in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1, 3):
        bpy.context.scene.frame_set(f)
        z.append((rig.matrix_world @ rig.pose.bones[P + 'Head'].head).z)
    return float(np.mean(z))


def baue(haut_name):
    haut = HAEUTE[haut_name]
    fbx, d, tex_dir = quelle()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene
    scn.render.fps = FPS
    teile = importiere(fbx)
    rig = next(o for o in teile if o.type == 'ARMATURE')
    netze = {o.name: o for o in teile if o.type == 'MESH'}
    koerper = netze['BARGHEST']
    maehne = next(o for n, o in netze.items() if 'MANE' in n)
    schwanz = next(o for n, o in netze.items() if 'TAIL' in n)
    INFO = {'statur': haut['statur'], 'maehne': haut['maehne']}
    # ------------------------------------------------ Bemalen (Kaufnetz, Ruhelage: Narben im Raum)
    global PROFIL
    PROFIL = _profil(koerper)
    global AUGEN
    AUGEN = augen_mitten(koerper)
    png = speichere(bemale(koerper, tex_dir, haut), haut_name)
    material(koerper, png, 'Grabhund')
    auge_stoff(koerper, koerper.data.materials[0])
    hp = speichere(haar_bild(tex_dir), 'haar', jpg=False)
    material(maehne, hp, 'Haar', schnitt=True)
    material(schwanz, hp, 'Haar', schnitt=True)
    haar_formen(maehne, koerper, haut['maehne'], MAEHNE_DREIECKE, 'Mähne')
    haar_formen(schwanz, koerper, 'zerrupft' if haut['maehne'] == 'zerrupft' else 'mittel', SCHWANZ_DREIECKE, 'Schwanz')
    vorher = tris([koerper])
    if vorher > KOERPER_DREIECKE:
        # 995 (Probebild 14:19: Nasenrücken verwaschen, „wie halb transparent“): das Ausdünnen in einem Zug zog das Bild quer über
        # den Fang (am vollen Netz gestochen scharf). Jetzt zwei Züge mit eigenem Anteil: erst nur der Kopf (Gruppe „Kopf“) auf
        # KOPF_ANTEIL der Dreiecke, dann nur der Rest (Gruppe umgekehrt) bis KOERPER_DREIECKE; eine Gruppe begrenzt das Ausdünnen in
        # Blender auf ihre Ecken
        gname = kopf_gruppe(koerper)
        kopf_vorher = kopf_dreiecke(koerper, gname)
        ziel_kopf = int(KOERPER_DREIECKE * KOPF_ANTEIL)
        bpy.context.view_layer.objects.active = koerper
        for inv, ziel in ((False, vorher - max(0, kopf_vorher - ziel_kopf)), (True, KOERPER_DREIECKE)):
            jetzt = tris([koerper])
            if jetzt <= ziel:
                continue
            mod = koerper.modifiers.new('weniger', 'DECIMATE')
            mod.ratio = ziel / jetzt
            mod.vertex_group = gname
            mod.invert_vertex_group = inv
            bpy.ops.object.modifier_apply(modifier=mod.name)
            print('DREIECKE Zug %s: %d -> %d (Ziel %d)' % ('Rest' if inv else 'Kopf', jetzt, tris([koerper]), ziel))
        koerper.vertex_groups.remove(koerper.vertex_groups[gname])
        print('DREIECKE Kopf %d -> %d' % (kopf_vorher, kopf_dreiecke(koerper)))
    print('DREIECKE Körper %d -> %d' % (vorher, tris([koerper])))
    dicke, schulter = STATUR[haut['statur']]
    statur(rig, [koerper, maehne], dicke)
    alle = [koerper, maehne, schwanz]
    # ------------------------------------------------ Bewegungen
    rig.animation_data_create()
    akt = aktionen(d)
    for nm in ('Stehen', 'Gehen', 'Biss'):
        if nm not in akt:
            sys.exit('%s fehlt im Kauf' % nm)
    print('KOPF Mitte des Kopfknochens: Stehen (idleAggressive) %.3f, Lefzen (idleBreathe) %.3f (Kaufmaß)' % (
        kopf_hoehe(rig, akt['Stehen']), kopf_hoehe(rig, akt['Lefzen']) if 'Lefzen' in akt else -1))
    # Ausweichen: Beine wie im Gehen, der Wurzelweg trägt seitlich
    for nm in ('Ausweichen', 'Ausweichen links'):
        a = akt['Gehen'].copy(); a.name = nm; a.use_fake_user = True
        akt[nm] = a
    # ------------------------------------------------ Größe (Liste 1): Schulter = höchste Ecke an Wirbeln und Schlüsselbeinen im Stehen
    rig.animation_data.action = akt['Stehen']
    if slot(akt['Stehen']) is not None:
        rig.animation_data.action_slot = slot(akt['Stehen'])
    f0 = int(akt['Stehen'].frame_range[0])
    w_sch = gewicht_feld(koerper, ('Spine3', 'Clavicle', 'UpperArm'))
    Pk = welt_netz([koerper], f0)
    lo = welt_netz(alle, f0).min(0)
    sch0 = float(Pk[w_sch > 0.5][:, 2].max() - lo[2])
    s = schulter / max(sch0, 1e-4)
    aussen = bpy.data.objects.new('Grabhund', None)
    scn.collection.objects.link(aussen)
    rig.parent = aussen
    bpy.context.view_layer.update()
    aussen.scale = (s, s, s)
    bpy.context.view_layer.update()
    Pa = welt_netz(alle, f0)
    lo, hi = Pa.min(0), Pa.max(0)
    aussen.location = (-(lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2])
    bpy.context.view_layer.update()
    Pa = welt_netz(alle, f0)
    lo, hi = Pa.min(0), Pa.max(0)
    Pk = welt_netz([koerper], f0)
    INFO['schulter_m'] = round(float(Pk[w_sch > 0.5][:, 2].max()), 3)
    INFO['breite_m'] = round(float(hi[0] - lo[0]), 3)
    INFO['laenge_m'] = round(float(hi[1] - lo[1]), 3)
    INFO['hoehe_m'] = round(float(hi[2] - lo[2]), 3)
    w_rumpf = gewicht_feld(koerper, ('Spine', 'Pelvis'))
    INFO['koerper_hoch_m'] = round(float(Pk[w_rumpf > 0.5][:, 2].max()), 3)
    print('MASS neu (Stehen): Schulter %.3f m (Kauf %.3f), breit %.3f lang %.3f hoch %.3f, Rumpf oben %.3f, Maßstab %.4f' % (
        INFO['schulter_m'], sch0, INFO['breite_m'], INFO['laenge_m'], INFO['hoehe_m'], INFO['koerper_hoch_m'], s))
    # ------------------------------------------------ Wurzelweg
    wege = wurzelweg(d, s)
    wege['Ausweichen'] = [[round(AUSWEICHEN_M * (i / AUSWEICHEN_BILDER) ** 0.8, 4), 0.0] for i in range(AUSWEICHEN_BILDER + 1)]
    wege['Ausweichen links'] = [[-x, z] for x, z in wege['Ausweichen']]
    INFO['weg'] = wege
    INFO['fps'] = FPS
    # ------------------------------------------------ Spuren (figur.gd spielt sie über ihre Namen)
    for nm, a in akt.items():
        a2 = a if nm.startswith('Ausweichen') else a.copy()
        a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'):
            st.action_slot = slot(a2)
        INFO.setdefault('zeiten', {})[nm] = round((st.action_frame_end - st.action_frame_start) / FPS, 3)
    for tr in rig.animation_data.nla_tracks:
        tr.mute = True
    # Kein Teil im Boden (figur.gd setzt die Figur auf 0): Ort des Gerüsts je Bild heben; Mähne und Haar zählen mit
    gehoben, tief = {}, {}
    for nm in INFO['zeiten']:
        a = bpy.data.actions[nm]
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        r0, r1 = int(a.frame_range[0]), int(a.frame_range[1])
        rig.location.z = 0.0
        for f in range(r0, r1 + 1):
            rig.keyframe_insert('location', frame=f)
        hoch = 0.0
        for _ in range(4):
            rest = 0.0
            for f in range(r0, r1 + 1):
                z = float(welt_netz(alle, f)[:, 2].min())
                if z < -0.002:
                    scn.frame_set(f)
                    rig.location.z = rig.location.z - z / max(s, 1e-6)
                    rig.keyframe_insert('location', frame=f)
                    hoch = max(hoch, rig.location.z * s)
                    rest = min(rest, z)
            if rest > -0.002:
                break
        if hoch > 0.0:
            gehoben[nm] = round(hoch, 3)
        tief[nm] = round(min(float(welt_netz(alle, f)[:, 2].min()) for f in range(r0, r1 + 1)), 3)
    INFO['gehoben_m'] = gehoben
    INFO['tiefster_punkt_m'] = tief
    print('BODEN gehoben (m): %s; tiefster Punkt je Bewegung: %s' % (gehoben, tief))
    # Biss (figur.gd BITE): Abstand Ursprung–Rand des Ziels (Schnauze 0,07 m im Rand), Zeitpunkt, Drehung (Grad, + links)
    a = bpy.data.actions['Biss']
    rig.animation_data.action = a
    if slot(a) is not None:
        rig.animation_data.action_slot = slot(a)
    a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
    vorn = []
    for f in range(a0, a1 + 1):
        Pf = welt_netz([koerper], f); i = int(Pf[:, 1].argmin()); vorn.append((f, Pf[i, 1], Pf[i, 0]))
    best = min(vorn, key=lambda v: v[1])
    INFO['biss'] = [round(float(-best[1] - 0.07), 3), round((best[0] - a0) / FPS, 3), round(-math.degrees(math.atan2(best[2], -best[1])), 1)]
    print('BISS vorn %.2f m bei %.2f s -> %s' % (-best[1], (best[0] - a0) / FPS, INFO['biss']))
    rig.animation_data.action = None
    rig.location.z = 0.0
    for tr in rig.animation_data.nla_tracks:
        tr.mute = False
    INFO['dreiecke'] = tris(alle)
    print('DREIECKE gesamt %d (Körper %d, Mähne %d, Schwanz %d)' % (INFO['dreiecke'], tris([koerper]), tris([maehne]), tris([schwanz])))
    bpy.ops.object.select_all(action='DESELECT')
    for o in [aussen, rig] + alle:
        o.select_set(True)
    pfad = os.path.join(OUT, '%s-%s.glb' % (ID, haut_name))
    bpy.ops.export_scene.gltf(filepath=pfad, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False,
                              export_image_format='AUTO',
                              export_optimize_animation_keep_anim_object=True, export_optimize_animation_keep_anim_armature=True)
    INFO['sekunden_bau'] = round(time.time() - T0, 1)
    print('GLB %s %d Bytes' % (pfad, os.path.getsize(pfad)))
    return INFO


if __name__ == '__main__':
    namen = [os.environ['FELL']] if os.environ.get('FELL') else list(HAEUTE)
    info = {}
    for n in namen:
        info[n] = baue(n)
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1, ensure_ascii=False)
    print('KAUFGRABHUND FERTIG %.1f s, Häute %s' % (time.time() - T0, ', '.join(namen)))
