# 348.7 (Jerry): die Riesenfledermaus (giant_bat) auf dem Grundmodell Vogel (flieger.py), Vorlage Vermin.kt bat()/batBody()
# und die Abnahmeliste in docs/LISTE-FIGUREN.md (gebilligt 25.10., 23:33):
#   Größe: schwebt, Ohrspitzen etwa auf Hüfthöhe des Helden; Spannweite 1,5–1,8 m.
#   Umriss: aufrecht hängender Rumpf, ausgebreitete Hautflügel mit Fingerknochen.
#   Merkmal: hohe, eingekerbte Ohren; Nasenblatt; aufgerissenes Maul mit Fangzähnen und Geiferfaden; Hakenkrallen; Augen matt.
#   Farbe: braun; schwarz mit eingerissenem Flügel; grau mit Narben; Braun und Schwarz auf einen Blick verschieden.
#   Haltung: schwebt, schlägt ruhig mit den Flügeln, wippt, das Maul arbeitet.
# Runde 1: Rumpf schräg aufrecht (oben vorn, wie Vermin.kt tilt), Flughaut zwischen vier Fingern, Arm und Flanke bis zum Fuß;
# Braun mit rostbraunem Mantel um Hals und Schultern (wie bei großen Flughunden), damit es sich auch im Schatten vom Schwarz
# abhebt (alt: beide fast schwarz).
# Runde 2 (Prüfer Runde 1: „pechschwarze Scherenschnitte“, Flügel glatte Platten, V-Haltung „wie ein Vogel“): Farben als
# Bildfarbe (zeige(), Helligkeit je Fell mit Messlauf MASKE=1 gegen alt geeicht: braun 43, schwarz 10, grau 80–105), Fingerknochen
# dicker und heller, Hinterkante tiefer gewellt, Ruhe in der Mitte des Schlags.
# Offen nach Runde 2 (Prüfer 27.10., 08:4x, Bild Probe GEGNER=BATS): Gesicht auf Handygröße verloren (Maul, Zähne, Nasenblatt,
# Geifer nicht sichtbar: Kopf größer, Maul weiter und heller innen); Ohren lesen sich als „Büschel, Hörner“ statt hoch und glatt mit
# heller Innenseite; Auge als weißer Glanzpunkt, nicht matt; im Bild nur etwa 1,1 m breit (V-Haltung, Flügel waagerechter);
# Schwarz schräg „wie abstürzend“, Flügelkante als langes Dreieck über den Kopf, Riss kaum sichtbar; Stein vor dem Kopf der
# Schwarzen (Tiefe prüfen); Narben bei Grau nicht erkennbar; Braun im Gesamtbild fast schwarz (gemessen wie alt; Liste verlangt
# Braun und Schwarz verschieden).
# Runde 3, 3b (Jerry 27.10., 09:05; Prüfer Runde 3, 3b): die Probe GEGNER=BATS zeigt die Hocke (alle sagen „Anspringen“ an), darum
# hocke() flach gespreizt statt Flügel hoch; Kopf KS 1,35; Maul, Innenohren, Augen rot wie alt; Gesicht dunkler; Braun HELL 0,45;
# Narben breiter; Riss größer. Behoben: V-Haltung, Mondgesicht, rosa Rechteck, Braun gegen Schwarz, Riss sichtbar.
# Offen nach 3b (Prüfer): hoch: Schwarze (wolf2) etwa 35° schräg mit Flügelkeil über dem Kopf, Stein dahinter (Log: Blick soll
# gegen ist −29°, Ursache Drehung in figur.gd prüfen; Stein liegt hinten im Wald, nur am Schirm am Kopf); Gesicht auf Handygröße
# nicht lesbar (Maul erst ab 6-fach, Nasenblatt, Geifer, Augen nicht; Zahnpixel lesen sich als Augenglanz). mittel: Innenohr der
# Schwarzen hellrosa (niedlich, soll dunkelrot); Flughaut nicht sichtbar dunkler, Gummi mit Lichtflecken; drei gleiche flache
# Spreizhaltungen „Deko“ (Hocke je Figur versetzen, Lauer lesbar machen); Spannweite im Bild etwa 1,2–1,3 m; Ohren weiter Büschel
# (Umrisslinie franst). gering: Narben auf Handygröße kaum; Grau und Braun ähnlich; Füße hängen als Stummel; alt heller als neu?
# nein: neu heller als alt (Braun nach Liste gewollt, Flügel zu hell).
# Aufruf: OUT=<ordner> FELL=braun|schwarz|grau python -I fledermaus.py  ->  <OUT>/giant_bat-<fell>.glb, giant_bat-info.json;
# Probe in Godot: Dateien als godot/kampf/daten/giant_bat-<fell>.bin, GEGNER=BATS (drei Fledermäuse, Regeln des Wolfs)
import os, sys, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import flieger as fl      # lädt bpy (über vierbeiner), danach erst mathutils
import vierbeiner as vb
import numpy as np
from vierbeiner import rgb

ID = 'giant_bat'
# Felle: Fell, Mantel (Hals, Schultern), Haut (Gesicht, Ohren), Flughaut, Knochen der Finger (heller als die Haut, Runde 2:
# Prüfer Runde 1 sah keine Fingerknochen); Spannweite je Fell 1,5–1,8 m
# Runde 2: Farben als Bildfarbe im Licht (zeige()); Runde 1 lief als Eckfarbe durch Godot doppelt ins Dunkle (Prüfer: „pechschwarze
# Scherenschnitte“, gemessen Median 0 bei allen drei)
COATS = {
    'braun':   dict(fell=0x6E3E24, mantel=0x94542C, haut=0x523426, flug=0x5C3A2A, knochen=0x7A5640),
    'schwarz': dict(fell=0x221E20, mantel=0x2A2426, haut=0x1C181A, flug=0x1E1A1C, knochen=0x36302E),
    'grau':    dict(fell=0x766E6A, mantel=0x847C76, haut=0x58504E, flug=0x5C5654, knochen=0x827A74),
}
GROESSE = {'braun': 1.0, 'schwarz': 1.07, 'grau': 0.9}      # Spannweite 1,68 · 1,80 · 1,51 m
SPANNWEITE = 1.68
KOPF = 0.98            # Ohrspitzen über dem Boden in Ruhe (Held 1,8 m: Hüfte etwa 0,95 m)
# Runde 3: Schlund, Zunge, Geifer heller (Maul lag im Schwarz), Narbe hell gegen das graue Fell (war gleich hell wie das Fell)
# Runde 3b (Prüfer 3: Gesicht als blasse Scheibe, Ohren ohne Innenseite): wie alt rotes Maul, rote Innenohren, dunkelrote matte Augen
ZAHN, SCHLUND, ZUNGE, GEIFER, AUGE, NARBE, KRALLE = 0xF0E6CC, 0x8C2420, 0xA83C3C, 0xD8D0C0, 0x7A1C14, 0xD8B4AA, 0x2A2420
OHR_INNEN = {'braun': 0x8C3A30, 'schwarz': 0x6A2A28, 'grau': 0x8C4440}
HAUT_GESICHT = 0.55    # Gesicht dunkler als das Fell (Prüfer 3: helle Kopfscheibe „wie Eule, Plüsch“)
FLUG_HELL = 0.75       # Flughaut dunkler als der Rumpf (Prüfer 3: hellgrau glänzend „wie Gummi“)
AUFLOESUNG = 0.006
DREIECKE = 2400
GLAETTEN = (6, 0.5)
# Runde 3: Braun heller (Prüfer Runde 2: im Gesamtbild fast schwarz wie alt; die Liste verlangt Braun und Schwarz auf einen Blick
# verschieden, alt: braun 27, Mittel 43; schwarz 10; grau 85)
HELL = {'braun': 0.45, 'schwarz': 0.3, 'grau': 0.38}


def zeige(h, f=1.0):
    """Eckfarbe, die im Kampfort im Sonnenlicht etwa die Bildfarbe h ergibt: Godot nimmt die Eckfarbe wie sRGB und rechnet sie
    linear (gemessen 27.10.: reines Weiß mit Haartextur ergibt 216 im Licht), darum hier die Umkehrung."""
    c = np.array([((h >> s) & 255) for s in (16, 8, 0)], float) * f / 216.0
    return np.clip(c, 0, 1) ** (1 / 2.2)
SCHLAG = 30.0          # Grad je Flügelschlag nach oben und unten (Runde 3: 38 gab das V „wie ein Vogel“, im Bild nur 1,1 m breit)
GEHTEMPO = 1.4         # m/s im Flug (Kampfort: Gehen)

# Runde 3 (Prüfer Runde 2: Gesicht auf Handygröße verloren): Kopf mit Maul, Zähnen, Augen, Nasenblatt um KS größer, um den Hals
KS = 1.35
HALS = np.array((0, -0.07, 0.785))
def kk(p):
    return tuple(HALS + (np.array(p, float) - HALS) * KS)

# ---------------------------------------------------------------- Gelenke (Meter; x quer, +y hinten, z oben), nach Vermin.kt
J = fl.spiegel({
    'wurzel': (0, 0, 0),
    'becken': (0, 0.07, 0.43), 'kreuz': (0, 0.05, 0.52), 'brust': (0, -0.01, 0.67), 'widerrist': (0, -0.04, 0.74),
    'hals': (0, -0.07, 0.785), 'kopf': kk((0, -0.12, 0.815)), 'nase': kk((0, -0.215, 0.80)),
    'kiefer': kk((0, -0.125, 0.78)), 'kinn': kk((0, -0.20, 0.755)),
    'schwanz1': (0, 0.10, 0.38), 'schwanz2': (0, 0.12, 0.34),
    'ohrL0': kk((0.035, -0.10, 0.86)), 'ohrL1': (0.085, -0.085, KOPF),
    'schulterL': (0.06, -0.03, 0.70), 'achselL': (0.13, -0.0, 0.72), 'ellbogenL': (0.25, 0.05, 0.75),
    'handgelenkL': (0.54, 0.0, 0.80), 'handL': (0.555, 0.0, 0.80), 'daumenL': (0.575, -0.045, 0.835),
    'f2mL': (0.65, -0.012, 0.815), 'f2tL': (0.76, -0.005, 0.80),
    'f3mL': (0.70, 0.005, 0.78), 'f3tL': (0.84, 0.05, 0.69),
    'f4mL': (0.65, 0.04, 0.665), 'f4tL': (0.70, 0.09, 0.50),
    'f5mL': (0.55, 0.05, 0.63), 'f5tL': (0.48, 0.09, 0.45),
    'flankeL': (0.075, 0.03, 0.58), 'schulterkL': (0.055, -0.01, 0.68),
    'huefteL': (0.05, 0.075, 0.45), 'knieL': (0.085, 0.11, 0.37), 'fussL': (0.09, 0.095, 0.29), 'zeheL': (0.09, 0.06, 0.265),
})

# Kugelketten des Netzes (von, nach, Radius von, Radius nach, Knochen)
BLOBS = [
    ('becken', 'kreuz', 0.062, 0.078, 'becken'),
    ('kreuz', 'brust', 0.078, 0.084, 'ruecken'),
    ('brust', 'widerrist', 0.08, 0.058, 'brust'),
    ('widerrist', 'hals', 0.056, 0.05, 'hals'),
    ('hals', 'kopf', 0.052, 0.062 * KS, 'kopf'),
    ('kopf', 'nase', 0.05 * KS, 0.024 * KS, 'schnauze'),
]
for s in 'LR':
    BLOBS += [('schulter' + s, 'achsel' + s, 0.036, 0.024, 'oberarm' + s),
              ('huefte' + s, 'knie' + s, 0.026, 0.018, 'schenkel' + s), ('knie' + s, 'fuss' + s, 0.016, 0.013, 'unterschenkel' + s),
              ('fuss' + s, 'zehe' + s, 0.012, 0.008, 'fuss' + s)]
KB = {}
KNUBBEL = []
KIEFER = (0.03 * KS, 0.017 * KS)


def form(Jv, me):
    """Rumpf von vorn nach hinten etwas flacher (Fledermausbrust breit, Rücken flach)."""
    for v in me.vertices:
        if v.co.z < 0.76 and abs(v.co.y - 0.02) > 0.0: v.co.y = 0.02 + (v.co.y - 0.02) * 0.85


def zottel(Jv, me):
    """Zottiges Fell: Mantel am Hals etwas abstehend, Bauch struppig (Vermin.kt fuzz)."""
    rng = np.random.default_rng(5)
    for v in me.vertices:
        if 0.62 < v.co.z < 0.76 and v.co.y > -0.1:
            n = v.normal; k = 0.006 + 0.006 * rng.random(); v.co += n * k


UVK = 0.5
def uv(c):
    # Strähnen laufen in der Textur längs u: am hängenden Rumpf nach unten
    return (-c[2] / UVK, (c[0] + 0.6 * c[1]) / UVK)


def faerbe(Jv, V, N, jaw, fell):
    k = COATS[fell]
    C = np.tile(zeige(k['fell'], HELL[fell]), (len(V), 1))
    # Mantel um Hals und Schultern, weich übergehend
    m = np.clip((V[:, 2] - 0.60) / 0.08, 0, 1) * np.clip((0.80 - V[:, 2]) / 0.04, 0, 1) * (V[:, 1] > -0.13)
    C = C * (1 - m[:, None]) + zeige(k['mantel'], HELL[fell]) * m[:, None]
    # nackte Haut im Gesicht (Schnauze, um die Augen), am Unterkiefer und an den Füßen
    gesicht = (V[:, 1] < HALS[1] + (-0.165 - HALS[1]) * KS) | jaw | (V[:, 2] < 0.31)
    C[gesicht] = zeige(k['haut'], HELL[fell] * HAUT_GESICHT)
    # Bauch dunkler (Umgebungslicht von oben), Rücken etwas dunkler als die Brust
    C *= (0.82 + 0.18 * np.clip((V[:, 2] - 0.4) / 0.35, 0, 1))[:, None]
    strand = 1 + 0.05 * np.sin(V[:, 1] * 300 + V[:, 2] * 140) + np.random.default_rng(7).normal(0, 0.015, len(V))
    return np.minimum(C * strand[:, None], 1.0)


def kugel(c, r, n=8, m=5):
    """Ellipsoid (r Zahl oder (rx, ry, rz)) um c: Ecken, Flächen."""
    r = np.array([r] * 3 if np.isscalar(r) else r, float); c = np.array(c, float)
    V = [c + r * (0, 0, 1)]
    for i in range(1, m):
        th = math.pi * i / m
        for k in range(n):
            ph = 2 * math.pi * k / n
            V.append(c + r * (math.sin(th) * math.cos(ph), math.sin(th) * math.sin(ph), math.cos(th)))
    V.append(c - r * (0, 0, 1))
    F = [(0, 1 + k, 1 + (k + 1) % n) for k in range(n)]
    for i in range(m - 2):
        for k in range(n):
            a, b = 1 + i * n + k, 1 + i * n + (k + 1) % n
            F.append((a, a + n, b + n, b) if False else (a, b, b + n, a + n))
    L = len(V) - 1
    F += [(1 + (m - 2) * n + k, L, 1 + (m - 2) * n + (k + 1) % n) for k in range(n)]
    return V, F


def blatt(fuss, spitze, breite, quer, wolbung, kerbe=None, n=7):
    """Spitzes Blatt (Ohr, Nasenblatt) vom Fuß zur Spitze, quer = Richtung der Breite, gewölbt nach vorn; Kerbe (Höhe, Tiefe)
    am Außenrand. Zwei Lagen dicht beieinander (von beiden Seiten Tusche). Gibt Ecken, Flächen."""
    fuss, spitze, quer = (np.array(x, float) for x in (fuss, spitze, quer))
    ach = spitze - fuss; L = np.linalg.norm(ach); ach /= L
    quer = quer - ach * (quer @ ach); quer /= np.linalg.norm(quer)
    vor = np.cross(quer, ach)
    V, F = [], []
    for i in range(n + 1):
        t = i / n
        w = breite * (1 - t) ** 0.8 * (0.8 + 0.4 * math.sqrt(max(t * (1 - t), 0)) * 2)
        aussen = w
        if kerbe and abs(t - kerbe[0]) < 0.12: aussen = w * (1 - kerbe[1] * (1 - abs(t - kerbe[0]) / 0.12))
        for x in (-w, 0.0, aussen):
            p = fuss + ach * (t * L) + quer * x + vor * (wolbung * (1 - (x / max(w, 1e-6)) ** 2) * math.sin(math.pi * t))
            V.append(p)
    for i in range(n):
        for j in range(2):
            a = i * 3 + j
            F.append((a, a + 1, a + 4, a + 3))
    return V, F


def haeute(J, fell):
    """Flughäute je Seite: (Rand A, Rand B, Teile längs, Teile quer, Durchhang, Wölbung, Farbe, Riss)."""
    k = COATS[fell]
    def farbe(UV):
        out = []
        for u, v in UV:
            # Adern dunkler an den Fingern, zwischen ihnen wenig heller (dünne Haut); Ränder dunkler
            f = 0.9 + 0.12 * math.sin(math.pi * v) * (0.4 + 0.6 * u) - 0.08 * (u > 0.93)
            c = zeige(k['flug'], f * HELL[fell] * FLUG_HELL)
            if fell == 'grau' and abs(math.sin(31 * u + 17 * v)) < 0.12 and u > 0.3: c = zeige(NARBE, 0.8)    # Narben in der Haut
            out.append(c)
        return out
    out = []
    for s in 'LR':
        def kt(namen, kn): return fl.kette(J, [n + s if n + s in J else n for n in namen], [b + s if b + s in BONE_NAMES else b for b in kn])
        arm = kt(['schulter', 'ellbogen', 'handgelenk'], ['oberarm', 'unterarm'])
        vorne = [(J['schulter' + s] + np.array([0, -0.02, 0.03]), {'oberarm' + s: 1.0}),
                 ((J['schulter' + s] + J['handgelenk' + s]) / 2 + np.array([0, -0.025, 0.035]), {'oberarm' + s: 0.4, 'unterarm' + s: 0.6}),
                 (J['handgelenk' + s], {'unterarm' + s: 1.0})]
        out.append((vorne, arm, 6, 2, 0.0, 0.0, farbe, None))
        finger = {f: kt(['hand', 'f%sm' % f, 'f%st' % f], ['finger%sa' % f, 'finger%sb' % f]) for f in '2345'}
        riss = None
        if fell == 'schwarz' and s == 'L':      # eingerissener Flügel: zackiger Riss vom Rand zwischen drittem und viertem Finger
            # Runde 3: tiefer und breiter (Prüfer Runde 2: kaum sichtbar)
            riss = lambda u, v: u > 0.25 and abs(v - 0.45 - 0.1 * math.sin(u * 23)) < (u - 0.25) * 0.9 + 0.08
        out.append((finger['2'], finger['3'], 6, 2, 0.12, 0.004, farbe, None))
        out.append((finger['3'], finger['4'], 7, 4, 0.32, 0.014, farbe, riss))
        out.append((finger['4'], finger['5'], 7, 3, 0.32, 0.012, farbe, None))
        aussen = kt(['schulter', 'ellbogen', 'handgelenk', 'f5m', 'f5t'], ['oberarm', 'unterarm', 'finger5a', 'finger5b'])
        flanke = kt(['schulterk', 'flanke', 'huefte', 'knie', 'fuss'], ['brust', 'ruecken', 'schenkel', 'unterschenkel'])
        out.append((flanke, aussen, 9, 5, 0.22, 0.02, farbe, None))
    return out


def rohre(J, fell):
    k = {n: zeige(h, HELL[fell]) for n, h in COATS[fell].items()}; out = []
    for s in 'LR':
        out.append((fl.kette(J, ['schulter' + s, 'ellbogen' + s, 'handgelenk' + s], ['oberarm' + s, 'unterarm' + s]), [0.022, 0.015, 0.011], k['knochen']))
        for f in '2345':
            out.append((fl.kette(J, ['hand' + s, 'f%sm%s' % (f, s), 'f%st%s' % (f, s)], ['finger%sa%s' % (f, s), 'finger%sb%s' % (f, s)]),
                        [0.011, 0.008, 0.003], k['knochen']))
    return out


def anbauten(J, fell):
    k = {n: zeige(h, HELL[fell]) for n, h in COATS[fell].items()}; out = []
    def cone(a, b, ra, rb, knochen, farbe, n=6):
        V_, F_ = vb.anbau_rohr([a, (np.array(a) + np.array(b)) / 2, b], [ra, (ra + rb) / 2, rb], n)
        out.append((V_, F_, knochen, farbe))
    for s, sg in (('L', 1), ('R', -1)):
        # hohe Ohren, glatt mit flacher Kerbe, innen hell (Runde 3, Prüfer Runde 2: tiefe Kerbe und dunkle Innenseite lasen sich als
        # „Büschel, Hörner“)
        quer = np.array([sg * 0.3, -1.0, 0.0])
        V_, F_ = blatt(J['ohr%s0' % s], J['ohr%s1' % s], 0.044, quer, -0.010, kerbe=(0.62, 0.2))
        out.append((V_, F_, 'ohr' + s, k['haut']))
        V_, F_ = blatt(J['ohr%s0' % s] + np.array([0, -0.005, 0.012]), J['ohr%s1' % s] + np.array([0, -0.007, -0.028]), 0.028, quer, -0.008)
        out.append((V_, F_, 'ohr' + s, OHR_INNEN[fell]))
        # Augen klein und matt unter schwerem Brauenwulst (Runde 3: Glanz weg, dunkelrot statt fast schwarz)
        V_, F_ = kugel(kk((sg * 0.03, -0.168, 0.833)), 0.0085 * KS, 6, 4); out.append((V_, F_, 'kopf', AUGE))
        V_, F_ = kugel(kk((sg * 0.031, -0.163, 0.846)), (0.017 * KS, 0.011 * KS, 0.007 * KS), 6, 4); out.append((V_, F_, 'kopf', k['haut']))
        # Fangzähne oben und unten, Nadelzähne dazwischen (Runde 3: Fänge dicker und länger, auf Handygröße sichtbar)
        cone(kk((sg * 0.016, -0.198, 0.788)), kk((sg * 0.015, -0.204, 0.752)), 0.0075 * KS, 0.001, 'schnauze', ZAHN)
        cone(kk((sg * 0.014, -0.185, 0.762)), kk((sg * 0.014, -0.191, 0.791)), 0.0068 * KS, 0.001, 'kiefer', ZAHN)
        for t in (1, 2):
            cone(kk((sg * (0.016 - 0.0055 * t), -0.203 + 0.004 * t, 0.789)), kk((sg * (0.016 - 0.0055 * t), -0.205 + 0.004 * t, 0.776)), 0.0025 * KS, 0.0005, 'schnauze', ZAHN, 5)
            cone(kk((sg * (0.014 - 0.005 * t), -0.19 + 0.003 * t, 0.763)), kk((sg * (0.014 - 0.005 * t), -0.192 + 0.003 * t, 0.774)), 0.0022 * KS, 0.0005, 'kiefer', ZAHN, 5)
        # Hakenkralle am Daumen und an den Zehen
        d = J['daumen' + s]
        V_, F_ = vb.anbau_rohr([J['hand' + s], d, d + np.array([sg * 0.004, -0.012, -0.012])], [0.007, 0.004, 0.0008], 6)
        out.append((V_, F_, 'daumen' + s, KRALLE))
        z = J['zehe' + s]
        for q in (-0.012, 0.0, 0.012):
            V_, F_ = vb.anbau_rohr([z + np.array([q, 0.01, 0.0]), z + np.array([q, -0.006, -0.01]), z + np.array([q, 0.0, -0.024])], [0.004, 0.003, 0.0006], 5)
            out.append((V_, F_, 'fuss' + s, KRALLE))
    # Nasenblatt: Spitze steil über der Schnauze, darunter die Nüstern
    V_, F_ = blatt(kk((0, -0.214, 0.804)), kk((0, -0.207, 0.856)), 0.015 * KS, (1.0, 0, 0), -0.004 * KS)
    out.append((V_, F_, 'schnauze', k['haut']))
    # Schlund zwischen den Kiefern (Runde 3: dunkelrot statt schwarz, damit das offene Maul liest), Zunge, Geiferfaden von der Unterlippe
    V_, F_ = kugel(kk((0, -0.172, 0.776)), (0.022 * KS, 0.03 * KS, 0.016 * KS), 7, 4); out.append((V_, F_, 'kopf', SCHLUND))
    V_, F_ = kugel(kk((0, -0.175, 0.765)), (0.013 * KS, 0.022 * KS, 0.005 * KS), 6, 3); out.append((V_, F_, 'kiefer', ZUNGE))
    V_, F_ = vb.anbau_rohr([kk((0.008, -0.198, 0.758)), kk((0.0095, -0.201, 0.735)), (0.012, -0.21, 0.66)], [0.0022, 0.0016, 0.003], 5)
    out.append((V_, F_, 'kiefer', GEIFER))
    if fell == 'grau':     # alte Narben quer über Brust und Schulter (Runde 3: hell und breiter, Prüfer Runde 2 sah keine)
        for a, b in (((-0.07, -0.074, 0.67), (0.025, -0.084, 0.58)), ((0.05, -0.062, 0.72), (0.08, -0.035, 0.63)),
                     ((-0.03, -0.08, 0.55), (0.04, -0.078, 0.50))):
            V_, F_ = vb.anbau_rohr([a, (np.array(a) + np.array(b)) / 2 + np.array([0, -0.008, 0]), b], [0.008, 0.011, 0.008], 5)
            out.append((V_, F_, 'ruecken', NARBE))
    return out


def bewegungen(K):
    PB, setr, addr, root, clear, fluegel, Yv, Zv = K['PB'], K['setr'], K['addr'], K['root'], K['clear'], K['fluegel'], K['Yv'], K['Zv']
    def kopf(neig=0.0, maul=-22.0):
        setr('hals', neig * 0.5); setr('kopf', neig * 0.5); setr('kiefer', maul)
    def beine(a=0.0):
        for s in 'LR': setr('schenkel' + s, 8 * a); setr('unterschenkel' + s, -6 * a)
    def stehen(p):     # schwebt: zwei ruhige Schläge je Durchlauf, wippt gegen den Schlag, das Maul arbeitet
        w = 2 * math.pi * 2 * p
        clear(); root(dz=0.035 * math.sin(w), pitch=-3 * math.sin(w))
        kopf(4 * math.sin(w + 1), -32 - 10 * math.sin(2 * math.pi * p)); beine(math.sin(w + 2))
        fluegel(math.sin(w) - 0.25, 0.18 * max(0.0, math.cos(w)))
    def gehen(p):      # vorwärts fliegen: schneller, Rumpf nach vorn geneigt
        w = 2 * math.pi * p
        clear(); root(dz=0.04 * math.sin(w), pitch=-18)
        kopf(14, -18); beine(-0.6)
        fluegel(1.15 * math.cos(w), 0.3 * max(0.0, -math.sin(w)))
    def hocke(p):      # lauert zum Sturzflug: Flügel weit und flach gespreizt, Kopf vor, Maul weit offen
        # Runde 3 (Prüfer Runde 2 sah die Hocke, alle drei sagten „Anspringen“ an): Flügel hoch gab das V „wie ein Vogel“, bei der
        # Schwarzen mit dem Blickwinkel einen Keil über dem Kopf, Rumpf zurückgelehnt „wie abstürzend“
        w = 2 * math.pi * 2 * p
        clear(); root(dz=0.08 + 0.02 * math.sin(w), pitch=-6)
        kopf(-10, -44 + 4 * math.sin(w)); beine(0.8)
        fluegel(0.1 + 0.15 * math.sin(w), 0.0)
    def biss(p):       # ausholen nach hinten oben, vorschnellen, zubeißen am Aufschlag (p 0,45), zurück (0,6 s)
        clear()
        if p < 0.3: u = p / 0.3; dy, dz, pt, auf, maul = 0.08 * u, 0.06 * u, 6 * u, 0.9 * u, -22 - 18 * u
        elif p < 0.45: u = (p - 0.3) / 0.15; dy, dz, pt, auf, maul = 0.08 - 0.43 * u, 0.06 - 0.16 * u, 6 - 28 * u, 0.9 - 1.9 * u, -40
        else: u = (p - 0.45) / 0.55; e = 1 - (1 - u) ** 2; dy, dz, pt, auf, maul = -0.35 * (1 - e), -0.1 * (1 - e), -22 * (1 - e), -1.0 + 1.0 * e, -4 - 18 * e
        root(dy=dy, dz=dz, pitch=pt); kopf(-10 if p < 0.45 else 0, maul); beine(0.5)
        fluegel(auf, 0.1)
    def sprung(p):     # Sturzflug: hoch, dann schräg hinab auf das Gesicht des Ziels, Biss (p 0,65), zurück
        clear()
        if p < 0.35: u = p / 0.35; s_ = math.sin(math.pi / 2 * u); dy, dz, pt, auf = 0.05 * s_, 0.28 * s_, 10 * s_, math.cos(2 * math.pi * 2 * u)
        elif p < 0.65: u = (p - 0.35) / 0.3; dy, dz, pt, auf = 0.05 - 0.6 * u, 0.28 - 0.36 * u, 10 - 40 * u, 0.7
        else: u = (p - 0.65) / 0.35; e = u * u * (3 - 2 * u); dy, dz, pt, auf = -0.55 * (1 - e), -0.08 * (1 - e), -30 * (1 - e), 0.7 - 1.4 * math.sin(math.pi * u)
        root(dy=dy, dz=dz, pitch=pt); kopf(-12, -42 if 0.4 < p < 0.65 else -10); beine(0.8)
        fluegel(auf, 0.25 if 0.35 <= p < 0.65 else 0.05)
    def treffer(p):    # zurückgeworfen, Flügel schlagen wild, Kopf zuckt
        u = math.sin(math.pi * p)
        clear(); root(dy=0.12 * u, dz=0.05 * u, pitch=-20 * u)
        kopf(-16 * u, -30 - 10 * u); setr('kopf', 14 * u, Zv); beine(1.2 * u)
        fluegel(math.cos(2 * math.pi * 1.5 * p), 0.4 * u)
    def ausweichen(p): # Seitwärts weg und hoch, schräg gelegt
        u = math.sin(math.pi * p)
        clear(); root(dx=0.3 * u, dz=0.12 * u, roll=18 * u)
        kopf(0, -24); fluegel(math.cos(2 * math.pi * p), 0.2 * u)
    def tod(p):        # Flügel knicken ein, sie fällt und liegt bäuchlings, Flügel halb ausgebreitet am Boden
        clear()
        if p < 0.25:
            u = p / 0.25; root(dz=0.08 * math.sin(math.pi * u), pitch=-8 * u); kopf(-14 * u, -40); fluegel(1.0 - 0.3 * u, 0.3 * u)
        else:
            u = min(1.0, (p - 0.25) / 0.5); e = u * u
            root(dy=0.42 * e, dz=0.09 * e, pitch=-8 + 92 * e)
            kopf(30 * e, -40 + 20 * e); beine(1.0)
            fluegel(0.7 - 1.2 * e, 0.3 + 0.2 * e)
    def lefzen(p):     # schwebt, schnappt und geifert (2 s)
        stehen(p * 3 % 1); u = min(1, p / 0.15, (1 - p) / 0.15)
        setr('kiefer', -(30 + 14 * math.sin(p * 40)) * u - 24 * (1 - u)); addr('kopf', -8 * u)
    def drohen(p):     # richtet sich auf, Flügel weit gespreizt, Maul weit auf (Kreischen)
        u = math.sin(math.pi * min(1, p * 1.2))
        clear(); root(dz=0.08 * u, pitch=12 * u)
        kopf(-18 * u, -24 - 22 * u); beine(0.6 * u)
        fluegel(0.5 * u + math.cos(2 * math.pi * 2 * p) * (1 - u), 0.0)
    return [('Stehen', 40, stehen, True), ('Gehen', 20, gehen, True), ('Hocke', 30, hocke, True), ('Biss', 18, biss, False),
            ('Sprung', 24, sprung, False), ('Treffer', 12, treffer, False), ('Ausweichen', 12, ausweichen, False),
            ('Tod', 30, tod, False), ('Lefzen', 60, lefzen, False), ('Drohen', 36, drohen, False)]


BONE_NAMES = {b[0] for b in fl.BONES}
FELL_PNG = os.path.join(vb.OUT, 'giant_bat-fell.png')
PLAIN_UV = (24 / 512, 1 - 24 / 512)
FELL_MEAN = vb.fell_textur(FELL_PNG, seed=23, laenge=(10, 24), striche=4200, kontrast=1.1, breite=(3, 6), licht=True, glatt=48)

if __name__ == '__main__':
    J = {k: np.array(v, float) for k, v in J.items()}
    fl.alle(sys.modules[__name__])
