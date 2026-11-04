# 431 Runde 4 (Chef 01.11., 20:3x, Archiv 431; 431b, Chef 02.11., 11:17: „selbst, gemeinsam, wie von Sokrates empfohlen“):
# Ohren und Hauer als ein Teil fuer alle Voelker und Gegner, Form und Mass aus Jerrys Bau: grak_gestalt.py (Grak auf dem Kaufkopf
# Superhero: spitze Ohren, Hauer; 348.12) und goblin.py (Doll-Kopf, Goblin). Am Kaufkopf gelten die Stellen aus grak_gestalt.py;
# die Ohrwurzel wird hier je Kopf gemessen (Regular und Superhero sind verschieden breit), statt fester 7,4-8,0 cm.
# Voelker nach LISTE-FIGUREN.md (430): Elf lange spitze Ohren schraeg nach hinten oben; Huegelvolk kurz zugespitzt, halb so lang
# wie beim Elf; Orkbluetiger kurz zugespitzt und zwei kurze Hauer aus dem Unterkiefer ueber die Oberlippe.
# Am Kaufkopf (Regular, Superhero; kein Formschluessel) wird das eigene Ohr geformt (wie die Kopfformen, Archiv 376.1 27.10.: keine
# Naht, folgt Haut und Ton); die Hauer sind eigene kleine Netze am Kopfknochen, Farbe vergilbter Knochen (wie goblin.py zahn).
# Benutzt von voelker.py; goblin.py kann OHR und HAUER fuer Goblin und Grak lesen (Jerry).
import numpy as np
import bpy
from mathutils import Vector
import kopf as KO

# Spitze in Metern am Kaufkopf (Kopfhoehe Scheitel-Kinn K_REF), wie grak_gestalt.py (Jerry, 348.12: Ohr 1,65-1,73 m, oberer Rand
# 3,6 cm hoch, 2,2 hinten, 1,4 aussen); andere Koepfe nach ihrer Hoehe k mal k / K_REF. spitz: Rand laeuft zur Spitze zusammen (0 wie Grak)
K_REF = 0.23
OHR = {
    'grak':   {'aussen': 0.014, 'hinten': 0.022, 'oben': 0.036, 'spitz': 0.0},
    'elf':    {'aussen': 0.012, 'hinten': 0.038, 'oben': 0.046, 'spitz': 0.55},   # lang, schraeg nach hinten oben (430)
    'huegel': {'aussen': 0.008, 'hinten': 0.018, 'oben': 0.022, 'spitz': 0.45},   # halb so lang wie beim Elf (430)
    'ork':    {'aussen': 0.010, 'hinten': 0.014, 'oben': 0.020, 'spitz': 0.40},   # kurz zugespitzt (430)
}
# Hauer wie grak_gestalt.py: Wurzel am Mundwinkel (x, unter dem Mund) im Kiefer, Bogen nach vorn und oben vor die Oberlippe;
# (x, unter mund_z, hoch, vor, Radius Wurzel) in m bei K_REF. Grak „lange Hauer“ 3,8 cm; Orkbluetiger „zwei kurze Hauer“ (430)
HAUER = {
    'grak': (0.020, 0.012, 0.038, 0.020, 0.0060),
    'ork':  (0.019, 0.010, 0.026, 0.013, 0.0050),
}
ZAHN = (0.80, 0.74, 0.58)   # vergilbter Knochen (goblin.py zahn), sRGB


def _glatt(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3 - 2 * t)


def ohren(haut, augen, art):
    """Formt beide Ohren des Kaufkopfs nach OHR[art] (haut: Netz mit dem Gesicht, Ruhelage). Gibt je Seite die Messung zurueck (Ecken, Ohrhoehe, Spitze vorher/nachher) fuer die Probe."""
    o = OHR[art]
    p = KO.merkpunkte(haut, augen)
    k = p['hoehe']
    W = KO._welt(haut)
    x, y, z = W[:, 0], W[:, 1], W[:, 2]
    my = p['mitte'][1]
    # Ohr: am Kopf zwischen Nasenspitze und etwas ueber den Augen, nicht vor der Kopfmitte (Wangen), am weitesten aussen
    zlo, zhi = float(p['nase'][2]) - 0.025, p['augen_z'] + 0.035
    box = (z > zlo) & (z < zhi) & (y > my - 0.015) & (y < my + 0.065)
    aus = {}
    D = np.zeros_like(W)
    for s in (-1.0, 1.0):
        seite = box & (s * x > 0.03)
        if not seite.any(): aus[s] = None; continue
        xmax = float((s * x[seite]).max())
        # Ohrwurzel: grak_gestalt.py mass am Superhero-Kopf Ohr bis 9 cm, Schaedel 7,0-7,3 cm, und verzog ab 7,4-8,0 cm: 1,6 cm innen
        x0 = xmax - 0.016
        ohr = seite & (s * x > x0 + 0.002)
        if ohr.sum() < 20: aus[s] = {'ecken': int(ohr.sum())}; continue
        E = W[ohr]
        e_lo, e_hi = float(E[:, 2].min()), float(E[:, 2].max())
        h = max(e_hi - e_lo, 0.02)
        yc = float(E[:, 1].mean())
        # Gewicht: aussen (ueber die Wurzel weich), in der Hoehe zur Spitze hin steigend, nur nahe am Ohr
        wl = _glatt(x0, x0 + 0.006, s * x)
        t = np.clip((z - e_lo) / h, 0.0, 1.5)
        wt = _glatt(0.30, 1.0, t) ** 1.5
        nah = np.exp(-((y - yc) / 0.045) ** 2) * (1 - _glatt(e_hi + 0.01, e_hi + 0.04, z)) * _glatt(e_lo - 0.01, e_lo + 0.005, z)
        w = wl * wt * nah * seite
        # Spitze: oberer Rand nach (aussen, hinten, oben); hinten = +Y (Blick -Y)
        d = np.array([s * o['aussen'], o['hinten'], o['oben']]) * (k / K_REF)
        D[:, 0] += w * d[0]; D[:, 1] += w * d[1]; D[:, 2] += w * d[2]
        # zur Spitze zusammenlaufen: die Breite (Y um die Ohrmitte) schrumpft mit dem Gewicht
        D[:, 1] += (yc - y) * o['spitz'] * w
        oben_i = np.where(ohr)[0][np.argmax(E[:, 2])]
        aus[s] = {'ecken': int(ohr.sum()), 'hoehe_cm': round(h * 100, 1), 'abstand_cm': round((xmax - x0) * 100, 1),
                  'spitze_vorher': [round(float(c), 3) for c in W[oben_i]],
                  'bewegt': int((w > 0.05).sum()), 'oben_i': int(oben_i)}
    KO._zurueck(haut, W + D)
    W2 = KO._welt(haut)
    for s_, a in aus.items():
        if a and 'oben_i' in a:
            a['spitze_nachher'] = [round(float(c), 3) for c in W2[a.pop('oben_i')]]
    return aus


def rohr(punkte, radien, n=8):
    # wie grak_gestalt.py: Roehre entlang punkte mit Radius je Punkt, Spitze bei Radius 0, Boden geschlossen
    verts, faces = [], []
    for i, (q, r) in enumerate(zip(punkte, radien)):
        d = (punkte[min(i + 1, len(punkte) - 1)] - punkte[max(i - 1, 0)]).normalized()
        a = d.orthogonal().normalized(); b = d.cross(a).normalized()
        for j in range(n):
            ang = 2 * np.pi * j / n
            verts.append(q + (a * float(np.cos(ang)) + b * float(np.sin(ang))) * r)
    for i in range(len(punkte) - 1):
        for j in range(n):
            faces.append((i * n + j, i * n + (j + 1) % n, (i + 1) * n + (j + 1) % n, (i + 1) * n + j))
    verts.append(punkte[0] - (punkte[1] - punkte[0]).normalized() * radien[0] * 0.3)
    faces += [(len(verts) - 1, (j + 1) % n, j) for j in range(n)]
    return verts, faces


def hauer(haut, augen, art, arm, knochen='Head'):
    """Zwei Hauer aus dem Unterkiefer vor die Oberlippe nach HAUER[art] (wie grak_gestalt.py), ein Netz „Hauer“ am Kopfknochen
    (Gewicht 1, Armature), Material „Hauer“ (Farbe ZAHN; Godot toent es, Gebiet.male nimmt nur Bilder). Gibt Objekt und Lage zurueck."""
    hx, hz, hoch, vor, r0 = HAUER[art]
    p = KO.merkpunkte(haut, augen)
    f = p['hoehe'] / K_REF
    V = KO._welt(haut)
    x, y, z = V[:, 0], V[:, 1], V[:, 2]
    verts, faces, lage = [], [], []
    for s in (-1.0, 1.0):
        # Wurzel 6 mm hinter der Haut am Mundwinkel (grak_gestalt r2: sonst steht der ferne Hauer neben der Wange in der Luft)
        m_ = (np.abs(x - s * hx * f) < 0.005 * f) & (np.abs(z - (p['mund_z'] - 0.008 * f)) < 0.006 * f) & (y < p['mitte'][1])
        yb = float(y[m_].min()) + 0.006 * f if m_.any() else p['kinn_y'] + 0.006 * f
        b = Vector((s * hx * f, yb, p['mund_z'] - hz * f))
        pts = [b + Vector((s * 0.003 * f * t ** 1.5, -vor * f * float(np.sin(t * np.pi / 2)), hoch * f * t)) for t in np.linspace(0, 1, 7)]
        vs, fs = rohr(pts, [r0 * f * k_ for k_ in (1.0, 0.97, 0.87, 0.73, 0.57, 0.33, 0.0)])
        faces += [tuple(len(verts) + i for i in fc) for fc in fs]; verts += vs
        lage.append({'wurzel': [round(c, 3) for c in b], 'spitze': [round(c, 3) for c in pts[-1]], 'haut_gefunden': bool(m_.any())})
    me = bpy.data.meshes.new('Hauer'); me.from_pydata([tuple(v) for v in verts], [], faces); me.update()
    for fc in me.polygons: fc.use_smooth = True
    mat = bpy.data.materials.new('Hauer')
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    if bsdf: bsdf.inputs['Base Color'].default_value = (*[c ** 2.2 for c in ZAHN], 1.0)
    me.materials.append(mat)
    o = bpy.data.objects.new('Hauer', me)
    bpy.context.scene.collection.objects.link(o)
    g = o.vertex_groups.new(name=knochen)
    g.add(range(len(me.vertices)), 1.0, 'REPLACE')
    mo = o.modifiers.new('Armature', 'ARMATURE'); mo.object = arm
    return o, lage
