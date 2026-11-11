# 494 Riesenspinne (Wochenziel 03.11. Reihe 3; Sokrates 15:4x: Kauf 348.12c nehmen, „nur Fehlendes selbst bauen, Spinne ohne
# Treffer“): gekaufte Protofactor „Darkness Spider“ (privates Repo, $KAUF, nie hierher und nie als Artefakt) nach
# `LISTE-FIGUREN.md` „Riesenspinne“ (Liste 348.11 b, gebilligt Chef 25.10., 23:33).
# Liste: Beine Spitze zu Spitze 1,5–1,7 m, Körper 40–55 cm hoch; acht Augen, zwei groß, matt; behaarte Kieferklauen mit
# gedämpften Gifttropfen; drei Häute auf einen Blick verschieden (schwarz mit blutroter Sanduhr; braun mit hellen Streifen und
# Beinringen; blassgrau mit Winkelmustern und Narben); Vorderbeine leicht erhoben, Giftzähne halb offen.
# Bemalung wie bei den anderen Kauftieren: aus dem Kaufbild nur die Helligkeit (Zeichnung, Behaarung), die Farben sind unsere;
# das Leuchtbild (ILLUM) bleibt weg (Liste „Augen matt“, 348.11 b „Leuchten nur, wo eine sichtbare Quelle ist“). Muster im Raum
# gemalt (Sanduhr, Streifen, Beinringe, Winkel, Narben), nicht ins Bild gezeichnet: die Kauf-UV ist links und rechts gespiegelt.
# Bewegungen unter unseren Namen (figur.gd), Wurzelweg aus den _RM-Dateien. Es fehlen im Kauf: Treffer und Ausweichen —
# Treffer wird aus dem Stehen gebaut (Zusammenzucken), Ausweichen aus dem Kriechen mit seitlichem Wurzelweg.
# Aufruf: KAUF=<ordner> OUT=<ordner> [FELL=schwarz] python -I kaufspinne.py
#         -> <OUT>/giant_spider-<haut>.glb, giant_spider-info.json
import os, sys, glob, json, math, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import numpy as np
from mathutils import Vector, Matrix
from kaufratte import lin, srgb, tris, aktion_von, weg as entferne, slot, welt_netz, importiere

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
ID = 'giant_spider'
DREIECKE = 5800              # Modellregel 7: unter 6.000 (Kauf 6.192)
TEX = 1024                   # Handy
# Liste 1 verlangt beides: Beine Spitze zu Spitze 1,5–1,7 m und Körper 40–55 cm hoch. Der Kauf ist flacher (bei 1,62 m Spannweite
# nur 38 cm Körper), darum auf die untere Körpergrenze 0,40 m skaliert, solange die Spannweite unter SPANNE_MAX bleibt.
KOERPER = float(os.environ.get('KOERPER', '0.40'))
SPANNE_MAX = float(os.environ.get('SPANNE_MAX', '1.70'))
SPANNE = float(os.environ.get('SPANNE', '1.62'))
FPS = 30
RNG = np.random.default_rng(494)

# Liste 4: drei Häute auf einen Blick verschieden. (Grund, Zeichnung dunkel, Muster) als sRGB; „muster“ je Haut unten
HAEUTE = {
    'schwarz': {'grund': 0x2A2420, 'tief': 0x121010, 'muster': 0x8A1414, 'zeichnung': 'sanduhr'},
    'braun': {'grund': 0x5A3E24, 'tief': 0x241A10, 'muster': 0xC2A273, 'zeichnung': 'streifen'},
    'grau': {'grund': 0x7E7A70, 'tief': 0x34322E, 'muster': 0xD2CEC2, 'zeichnung': 'winkel'},
}
AUGE = 0x151214             # Liste 3: acht Augen, zwei groß, matt (kein Leuchten)
GIFT = 0x6A6A48             # Gifttropfen gedämpft, nicht grell grün
KLAUE = 0x1C1A18

# Bewegungen: unser Name <- Kaufdatei (ohne „DARKNESS_SPIDER@“); Schleife = läuft im Spiel in Schleife
NAMEN = [('Stehen', 'idleNormal', True), ('Lefzen', 'idleLookAroundNormal', True), ('Drohen', 'idleThreat', True),
         ('Gehen', 'crawlNormal', True), ('Rennen', 'crawlThreat', True), ('Biss', 'Bite', False),
         ('Sprungbiss', 'jumpBiteNormal', False), ('Netzwurf', 'throwSpiderWebNormal', False),
         ('Bisskette', 'Bite3HitCombo', False), ('Tod', 'deathNormal', False)]
# Wurzelweg: unser Name <- Kaufdatei mit und ohne _RM
WEGE = [('Gehen', 'crawlNormal'), ('Rennen', 'crawlThreat'), ('Sprungbiss', 'jumpBiteNormal')]
# Rennen: das Kriechen in Drohhaltung ist nur so schnell wie das normale; schneller abspielen bis zu diesem Tempo (m/s)
TEMPO_ZIEL = {'Rennen': 2.2}
AUSWEICHEN_M = float(os.environ.get('AUSWEICHEN_M', '1.2'))     # Satz zur Seite (m), Beine aus dem Kriechen
AUSWEICHEN_BILDER = 10
TREFFER_BILDER = 9


def quelle():
    if not KAUF:
        sys.exit('KAUF fehlt (Ordner mit den gekauften Modellen)')
    t = sorted(glob.glob(os.path.join(KAUF, '**', 'DARKNESS_SPIDER.FBX'), recursive=True))
    if not t:
        sys.exit('DARKNESS_SPIDER.FBX nicht gefunden unter %s' % KAUF)
    return t[0], os.path.dirname(t[0])


def bild(pfad, kante):
    from PIL import Image
    im = Image.open(pfad).convert('RGB')
    if im.size[0] != kante:
        im = im.resize((kante, kante), Image.LANCZOS)
    return np.asarray(im, dtype=np.float32) / 255.0


def uv_mitte(me, poly, kante):
    uv = me.uv_layers.active.data
    q = np.array([uv[li].uv[:] for li in poly.loop_indices])
    return q.mean(0) * np.array([kante, kante])


def male_lage(b, o, fn, farbe, staerke=1.0, weich=1.0):
    """Muster nach der Lage im Raum (Ruhelage, Modellmeter) ins UV-Bild: Gewicht je Bildpunkt aus fn(Punkte) -> 0..1."""
    from PIL import Image, ImageFilter
    Hh, Ww = b.shape[:2]
    mk = np.zeros((Hh, Ww), np.float32)
    me = o.data
    uv = me.uv_layers.active.data
    me.calc_loop_triangles()
    M = np.array(o.matrix_world)
    co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co)
    P = co.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]
    for tri in me.loop_triangles:
        P3 = P[list(tri.vertices)]
        if fn(P3.mean(0)[None, :], grob=True)[0] < 0.01:
            continue
        q = np.array([(uv[li].uv[0] % 1 * Ww, (1 - uv[li].uv[1] % 1) * Hh) for li in tri.loops])
        x0, y0 = np.floor(q.min(0)).astype(int); x1, y1 = np.ceil(q.max(0)).astype(int) + 1
        x0, y0 = max(x0, 0), max(y0, 0); x1, y1 = min(x1, Ww), min(y1, Hh)
        if x1 <= x0 or y1 <= y0:
            continue
        gx, gy = np.meshgrid(np.arange(x0, x1) + 0.5, np.arange(y0, y1) + 0.5)
        d = (q[1, 1] - q[2, 1]) * (q[0, 0] - q[2, 0]) + (q[2, 0] - q[1, 0]) * (q[0, 1] - q[2, 1])
        if abs(d) < 1e-9:
            continue
        l0 = ((q[1, 1] - q[2, 1]) * (gx - q[2, 0]) + (q[2, 0] - q[1, 0]) * (gy - q[2, 1])) / d
        l1 = ((q[2, 1] - q[0, 1]) * (gx - q[2, 0]) + (q[0, 0] - q[2, 0]) * (gy - q[2, 1])) / d
        l2 = 1 - l0 - l1
        drin = (l0 >= -0.02) & (l1 >= -0.02) & (l2 >= -0.02)
        X = (l0[..., None] * P3[0] + l1[..., None] * P3[1] + l2[..., None] * P3[2]).reshape(-1, 3)
        w = np.clip(fn(X), 0, 1).reshape(l0.shape)
        mk[y0:y1, x0:x1] = np.where(drin, np.maximum(mk[y0:y1, x0:x1], w), mk[y0:y1, x0:x1])
    mk = Image.fromarray((np.clip(mk, 0, 1) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(weich * Ww / 1024))
    mk = np.asarray(mk, dtype=np.float32)[..., None] / 255.0 * staerke
    return b * (1 - mk) + np.array(farbe)[None, None, :] * mk


def gewicht_feld(o, teile):
    """Summe der Gewichte aller Knochen, deren Name einen der Teile enthält."""
    idx = {g.index for g in o.vertex_groups if any(t in g.name for t in teile)}
    w = np.zeros(len(o.data.vertices))
    for v in o.data.vertices:
        for g in v.groups:
            if g.group in idx:
                w[v.index] += g.weight
    return w


# Augen (gemessen am Kaufnetz, Ruhelage): die zwei großen sitzen bei x ±0,052, y −0,097, z 0,370 (dort markiert sie das
# Leuchtbild des Kaufs); die sechs kleinen ringsherum. Alle matt (Liste 3), kein Leuchten.
AUGEN_GROSS = [(0.052, -0.097, 0.370), (-0.052, -0.097, 0.370)]
AUGEN_KLEIN = [(0.022, -0.112, 0.377), (-0.022, -0.112, 0.377), (0.078, -0.108, 0.360), (-0.078, -0.108, 0.360),
               (0.040, -0.125, 0.352), (-0.040, -0.125, 0.352)]
R_GROSS, R_KLEIN = 0.023, 0.014     # r2 (Prüfer r1, r2: nur zwei dunkle Punkte): größer, dazu ein matter Rand
AUGENRAND = 0x56504A
# Körperteile im Kaufnetz (gemessen): Hinterleib y 0,12…0,54, Vorderteil y −0,15…0,13, Klauen y −0,35…−0,13


def muster_fn(art):
    """Zeichnung je Haut (Liste 4) als Funktion der Lage im Kaufnetz; grob=True nur für den Vorentscheid je Fläche."""
    if art == 'sanduhr':
        def fn(X, grob=False):
            # blutrote Sanduhr oben auf dem Hinterleib: zwei Dreiecke, die sich in der Mitte berühren
            y = (X[:, 1] - 0.33) / 0.16          # −1 … 1 über den Hinterleib
            x = X[:, 0] / 0.19
            oben = np.clip((X[:, 2] - 0.30) / 0.06, 0, 1)
            breit = 0.06 + 0.85 * np.abs(y) ** 1.2     # Taille schmal, Enden breit: Sanduhr (r1: Block)
            s = np.clip((1.0 - np.abs(x) / np.maximum(breit, 1e-3)) * 6, 0, 1) * (np.abs(y) < 0.92)
            if grob:
                return np.clip(s * 3 + oben * 0.2, 0, 1)
            return s * oben
    elif art == 'streifen':
        def fn(X, grob=False):
            # helle Längsstreifen auf dem Hinterleib, Ringe auf den Beinen
            oben = np.clip((X[:, 2] - 0.28) / 0.08, 0, 1)
            hl = np.clip((X[:, 1] - 0.12) / 0.05, 0, 1)
            streifen = np.clip((np.cos(X[:, 0] / 0.19 * math.pi * 3.0) * 0.5 + 0.5) ** 2 * 2.2 - 0.3, 0, 1) * hl * oben
            arm = np.clip((np.abs(X[:, 0]) - 0.18) / 0.05, 0, 1)
            ring = (np.cos(np.abs(X[:, 0]) / 0.075 * math.pi * 2.0) * 0.5 + 0.5) ** 4 * arm
            if grob:
                return np.clip(streifen * 3 + ring * 3, 0, 1)
            return np.clip(np.maximum(streifen, ring * 0.8), 0, 1)
    else:
        def fn(X, grob=False):
            # Winkelmuster (Zickzack quer) auf dem Hinterleib und Narben am Vorderteil
            oben = np.clip((X[:, 2] - 0.28) / 0.08, 0, 1)
            hl = np.clip((X[:, 1] - 0.14) / 0.05, 0, 1)
            w = np.abs(((X[:, 1] - np.abs(X[:, 0]) * 0.8) / 0.065) % 1.0 - 0.5)
            winkel = np.clip((1.0 - w / 0.22) * 2.0, 0, 1) * hl * oben
            narbe = np.zeros(len(X))
            for a0, a1 in (((0.045, -0.10, 0.40), (-0.02, 0.02, 0.38)), ((-0.06, -0.06, 0.39), (-0.09, 0.06, 0.36))):
                a0 = np.array(a0); a1 = np.array(a1); seg = a1 - a0
                t = np.clip(((X - a0) @ seg) / (seg @ seg), 0, 1)
                ab = np.linalg.norm(X - (a0 + t[:, None] * seg), axis=1)
                narbe = np.maximum(narbe, np.clip((1.0 - ab / 0.010) * 1.6, 0, 1))
            if grob:
                return np.clip(winkel * 3 + narbe * 8, 0, 1)
            return np.clip(np.maximum(winkel, narbe), 0, 1)
    return fn


def kugeln(punkte, radius):
    def fn(X, grob=False):
        w = np.zeros(len(X))
        r = radius * (3.0 if grob else 1.0)
        for p in punkte:
            d = np.linalg.norm(X - np.array(p), axis=1)
            w = np.maximum(w, np.clip((r - d) / (r * 0.35), 0, 1))
        return w
    return fn


def bemale(mesh, tex_dir, haut):
    """Kaufbild -> unsere Haut: nur die Helligkeit bleibt (Zeichnung, Behaarung), Farben und Muster sind unsere."""
    a = bild(os.path.join(tex_dir, 'DARKNESS_SPIDER_ALBEDO.jpg'), TEX)
    lum = a.mean(2)
    med = float(np.median(lum[lum > 0.03]))
    t = np.clip(lum / max(med, 1e-3), 0.25, 1.9)[..., None]
    grund = np.array(lin(haut['grund'])); tief = np.array(lin(haut['tief']))
    b = tief + (grund - tief) * np.clip((t - 0.5) / 1.1, 0, 1) ** 0.9
    b = b * (0.75 + 0.45 * t) / 1.2
    # feine Behaarung: gerichtetes Rauschen, damit der Panzer nicht glatt wirkt
    r = RNG.random((TEX // 6, TEX // 6)).astype(np.float32)
    from PIL import Image, ImageFilter
    st = Image.fromarray((r * 255).astype(np.uint8)).resize((TEX, TEX), Image.BILINEAR).filter(ImageFilter.GaussianBlur(0.8))
    b *= (0.9 + 0.2 * (np.asarray(st, np.float32)[..., None] / 255.0))
    b = male_lage(b, mesh, muster_fn(haut['zeichnung']), lin(haut['muster']), 0.95, 0.9)
    # Rand zuerst (etwas heller, matt), dann die Augen darauf: so sind acht Augen auf dunkler Haut zu erkennen
    b = male_lage(b, mesh, kugeln(AUGEN_KLEIN, R_KLEIN * 1.5), lin(AUGENRAND), 0.9, 0.5)
    b = male_lage(b, mesh, kugeln(AUGEN_GROSS, R_GROSS * 1.4), lin(AUGENRAND), 0.9, 0.5)
    b = male_lage(b, mesh, kugeln(AUGEN_KLEIN, R_KLEIN), lin(AUGE), 0.95, 0.4)
    b = male_lage(b, mesh, kugeln(AUGEN_GROSS, R_GROSS), lin(AUGE), 0.98, 0.4)
    # Kieferklauen dunkel, Giftzähne mit gedämpftem Tropfen (Liste 3)
    w_kl = gewicht_feld(mesh, ('chelicere',))
    return np.clip(srgb(b), 0, 1), w_kl


def material(mesh, png):
    mat = bpy.data.materials.new('Spinne')
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    ti = mat.node_tree.nodes.new('ShaderNodeTexImage')
    ti.image = bpy.data.images.load(png, check_existing=False)
    mat.node_tree.links.new(ti.outputs['Color'], bsdf.inputs['Base Color'])
    bsdf.inputs['Roughness'].default_value = 0.6     # Panzer glänzt etwas, aber nicht nass
    mesh.data.materials.clear()
    mesh.data.materials.append(mat)


def aktionen(d, rig):
    """Bewegungen des Kaufs holen (je Datei eine), auf unser Gerüst legen (gleiche Knochennamen); {Kaufname: Aktion}."""
    akt = {}
    for _, q, _ in NAMEN:
        f = os.path.join(d, 'DARKNESS_SPIDER@%s.FBX' % q)
        if not os.path.exists(f):
            print('FEHLT Bewegung', q); continue
        neu = importiere(f)
        a = aktion_von(neu)
        if a is None:
            entferne(neu); print('FEHLT Aktion', q); continue
        a.use_fake_user = True
        akt[q] = a
        entferne(neu)
    return akt


def bilder(rig, a, f0, f1):
    """Lokale Drehungen (und Becken-Ort) je Bild einer Aktion auf unserem Gerüst."""
    rig.animation_data.action = a
    if slot(a) is not None:
        rig.animation_data.action_slot = slot(a)
    aus = []
    for f in range(f0, f1 + 1):
        bpy.context.scene.frame_set(f)
        aus.append({pb.name: (pb.rotation_quaternion.copy(), pb.location.copy(), pb.scale.copy()) for pb in rig.pose.bones})
    return aus


def setze_bilder(rig, name, folge):
    """Folge von Haltungen als eigene Aktion (ein Bild je Eintrag)."""
    a = bpy.data.actions.new(name)
    a.use_fake_user = True
    rig.animation_data.action = a
    if slot(a) is not None:
        rig.animation_data.action_slot = slot(a)
    for i, haltung in enumerate(folge):
        for pb in rig.pose.bones:
            q, l, s = haltung[pb.name]
            pb.rotation_quaternion = q; pb.location = l; pb.scale = s
            pb.keyframe_insert('rotation_quaternion', frame=i + 1)
            pb.keyframe_insert('location', frame=i + 1)
    return a


def treffer_bauen(rig, akt):
    """Im Kauf fehlt der Treffer (Sokrates 15:4x). Aus dem Stehen und dem Anfang des Todes gebaut: Zusammenzucken, gedämpft,
    dann zurück ins Stehen — so bleibt die Spinne erkennbar und zuckt nur."""
    for pb in rig.pose.bones:
        pb.rotation_mode = 'QUATERNION'
    ruhe = bilder(rig, akt['idleNormal'], int(akt['idleNormal'].frame_range[0]), int(akt['idleNormal'].frame_range[0]))[0]
    f0 = int(akt['deathNormal'].frame_range[0])
    tod = bilder(rig, akt['deathNormal'], f0, f0 + 5)
    folge = []
    for i in range(TREFFER_BILDER):
        t = i / (TREFFER_BILDER - 1)
        staerke = math.sin(math.pi * min(1.0, t * 1.15)) * 0.45     # hin und zurück, höchstens 45 % des Todesanfangs
        q = tod[min(len(tod) - 1, int(round(t * (len(tod) - 1))))]
        haltung = {}
        for b, (rq, loc, sc) in ruhe.items():
            zq, zl, zs = q[b]
            haltung[b] = (rq.slerp(zq, staerke), loc.lerp(zl, staerke), sc)
        folge.append(haltung)
    return setze_bilder(rig, 'Treffer', folge)


def ausweichen_bauen(rig, akt):
    """Im Kauf fehlt ein Satz zur Seite: die Beine laufen wie im Kriechen, der Wurzelweg trägt sie seitlich (AUSWEICHEN_M)."""
    f0 = int(akt['crawlNormal'].frame_range[0])
    folge = bilder(rig, akt['crawlNormal'], f0, f0 + AUSWEICHEN_BILDER)
    rechts = setze_bilder(rig, 'Ausweichen', folge)
    links = setze_bilder(rig, 'Ausweichen links', folge)
    return rechts, links


def haltung(rig, mesh, akt, namen):
    """Liste 5: Vorderbeine leicht erhoben und wippend, Giftzähne halb offen. Der Kauf stellt sie flach und geschlossen; in Ruhe
    und Drohen die Vorderbeine (leg_*_0, im Kauf die vordersten: Spitze bei y −0,47) heben und die Kieferklauen öffnen, je Bild.
    Die Drehrichtung wird gemessen, nicht geraten: beide Vorzeichen probieren, das nehmen, das die Spitze hebt bzw. öffnet."""
    heben = math.radians(float(os.environ.get('VORDERBEIN', '16')))
    oeffnen = math.radians(float(os.environ.get('KLAUE_AUF', '18')))
    wippen = math.radians(float(os.environ.get('WIPPEN', '5')))
    ENDE = {b[:-2]: (b[:-2] + '_d' if b[:-2] + '_d' in rig.pose.bones else b) for b in ('leg_L_0_a', 'leg_R_0_a')}

    def dreh(pb, achse, w):
        h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(w, 4, achse) @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()

    def spitze(nm):
        return (rig.matrix_world @ rig.pose.bones[nm].tail).copy()

    def achse_bein(b):
        p0 = (rig.matrix_world @ rig.pose.bones[b].head)
        p1 = spitze(ENDE[b[:-2]])
        d = Vector((p1.x - p0.x, p1.y - p0.y, 0.0))
        return (d.normalized().cross(Vector((0, 0, 1))) if d.length > 1e-4 else Vector((1, 0, 0)))

    # Vorzeichen messen (am ersten Bild von Stehen)
    a0 = bpy.data.actions.get(namen[0])
    rig.animation_data.action = a0
    if slot(a0) is not None:
        rig.animation_data.action_slot = slot(a0)
    bpy.context.scene.frame_set(int(a0.frame_range[0]))
    VZ = {}
    for b in ('leg_L_0_a', 'leg_R_0_a'):
        ax = achse_bein(b); z0 = spitze(ENDE[b[:-2]]).z
        dreh(rig.pose.bones[b], ax, heben)
        hoch = spitze(ENDE[b[:-2]]).z - z0
        dreh(rig.pose.bones[b], ax, -heben)
        VZ[b] = (ax, 1.0 if hoch > 0 else -1.0, abs(hoch))
    ziel = float(os.environ.get('VORDERBEIN_M', '0.07'))     # beide Seiten gleich weit heben (die Achsen liegen nicht spiegelbildlich)
    VZ = {b: (ax, vz * min(2.5, ziel / max(h, 1e-3)), h) for b, (ax, vz, h) in VZ.items()}
    KL = {}
    for b in ('chelicere_L_a', 'chelicere_R_a'):
        if b not in rig.pose.bones:
            continue
        x0 = abs(spitze(b).x)
        dreh(rig.pose.bones[b], Vector((0, 1, 0)), oeffnen)
        auf = abs(spitze(b).x) - x0
        dreh(rig.pose.bones[b], Vector((0, 1, 0)), -oeffnen)
        KL[b] = 1.0 if auf > 0 else -1.0
    print('HALTUNG gemessen: Hub je Vorderbein %s m, Klauen %s' % (
        {k: round(v[2], 3) for k, v in VZ.items()}, KL))
    gemessen = {}
    for nm in namen:
        a = bpy.data.actions.get(nm)
        if a is None:
            continue
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
        bpy.context.scene.frame_set(f0)
        vorher = [round(spitze(ENDE[b[:-2]]).z, 3) for b in ('leg_L_0_a', 'leg_R_0_a')]
        for f in range(f0, f1 + 1):
            bpy.context.scene.frame_set(f)
            ph = math.sin(2 * math.pi * (f - f0) / max(f1 - f0, 1) * 2.0)
            for b, (ax, vz, _) in VZ.items():
                pb = rig.pose.bones[b]
                dreh(pb, ax, vz * (heben + wippen * ph))
                pb.keyframe_insert('rotation_quaternion', frame=f)
                pb.keyframe_insert('location', frame=f)
            for b, vz in KL.items():
                pb = rig.pose.bones[b]
                dreh(pb, Vector((0, 1, 0)), vz * oeffnen)
                pb.keyframe_insert('rotation_quaternion', frame=f)
                pb.keyframe_insert('location', frame=f)
        bpy.context.scene.frame_set(f0)
        nachher = [round(spitze(ENDE[b[:-2]]).z, 3) for b in ('leg_L_0_a', 'leg_R_0_a')]
        klauen = round(abs(spitze('chelicere_L_a').x - spitze('chelicere_R_a').x), 3) if len(KL) == 2 else None
        gemessen[nm] = {'vorderbein_m': [vorher, nachher], 'klauen_auf_m': klauen}
    rig.animation_data.action = None
    print('HALTUNG je Bewegung: %s' % gemessen)
    return gemessen


def wurzelweg(d, rig, s):
    """Wurzelweg je Bewegung: Ort des Wurzelknochens aus der _RM-Datei minus dem der Datei ohne Weg, in unseren Metern."""
    wege = {}
    for nm, q in WEGE:
        bahn = []
        for v in (q, q + '_RM'):
            f = os.path.join(d, 'DARKNESS_SPIDER@%s.FBX' % v)
            if not os.path.exists(f):
                break
            neu = importiere(f)
            r = next((o for o in neu if o.type == 'ARMATURE'), None)
            a = aktion_von(neu)
            if r is None or a is None or 'DARKNESS_SPIDER_ROOT' not in r.pose.bones:
                entferne(neu); break
            pb = r.pose.bones['DARKNESS_SPIDER_ROOT']
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


def baue(haut_name):
    haut = HAEUTE[haut_name]
    fbx, d = quelle()
    tex_dir = d
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scn = bpy.context.scene
    scn.render.fps = FPS
    teile = importiere(fbx)
    rig = next(o for o in teile if o.type == 'ARMATURE')
    mesh = next(o for o in teile if o.type == 'MESH')
    INFO = {}
    # ------------------------------------------------ Ausdünnen (Modellregel 7)
    vorher = tris([mesh])
    if vorher > DREIECKE:
        mod = mesh.modifiers.new('weniger', 'DECIMATE')
        mod.ratio = DREIECKE / vorher
        bpy.context.view_layer.objects.active = mesh
        bpy.ops.object.modifier_apply(modifier=mod.name)
    print('DREIECKE %d -> %d' % (vorher, tris([mesh])))
    INFO['dreiecke'] = tris([mesh])
    # ------------------------------------------------ Bemalen (vor dem Skalieren: die Muster sind im Kaufnetz gemessen)
    b, _ = bemale(mesh, tex_dir, haut)
    from PIL import Image
    png = os.path.join(OUT, 'tex_spinne_%s.png' % haut_name)
    os.makedirs(OUT, exist_ok=True)
    Image.fromarray((b * 255).astype(np.uint8)).save(png)
    material(mesh, png)
    # ------------------------------------------------ Bewegungen
    rig.animation_data_create()
    akt = aktionen(d, rig)
    if 'idleNormal' not in akt or 'crawlNormal' not in akt:
        sys.exit('Stehen oder Kriechen fehlt im Kauf')
    treffer_bauen(rig, akt)
    ausweichen_bauen(rig, akt)
    rig.animation_data.action = None
    # ------------------------------------------------ Größe und Boden (Liste 1): Spannweite SPANNE, Füße auf 0
    rig.animation_data.action = akt['idleNormal']
    if slot(akt['idleNormal']) is not None:
        rig.animation_data.action_slot = slot(akt['idleNormal'])
    f0 = int(akt['idleNormal'].frame_range[0])
    P = welt_netz([mesh], f0)
    lo, hi = P.min(0), P.max(0)
    print('MASS gekauft (Stehen): breit %.3f lang %.3f hoch %.3f, Boden %.3f' % (hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], lo[2]))
    s = SPANNE / max(hi[0] - lo[0], 1e-4)
    w_k0 = gewicht_feld(mesh, ('Abdomen', 'cephalothorax'))
    k0 = float(P[np.nonzero(w_k0 > 0.5)[0]][:, 2].max() - lo[2])
    s_k = KOERPER / max(k0, 1e-4)
    if s_k * (hi[0] - lo[0]) <= SPANNE_MAX:
        print('MASS Körper des Kaufs %.3f m: Maßstab %.4f statt %.4f (Spannweite %.3f m)' % (k0, s_k, s, s_k * (hi[0] - lo[0])))
        s = s_k
    aussen = bpy.data.objects.new('Spinne', None)
    scn.collection.objects.link(aussen)
    rig.parent = aussen
    bpy.context.view_layer.update()
    aussen.scale = (s, s, s)
    bpy.context.view_layer.update()
    P = welt_netz([mesh], f0)
    lo, hi = P.min(0), P.max(0)
    aussen.location = (-(lo[0] + hi[0]) / 2, -(lo[1] + hi[1]) / 2, -lo[2])
    bpy.context.view_layer.update()
    P = welt_netz([mesh], f0)
    lo, hi = P.min(0), P.max(0)
    print('MASS neu (Stehen): breit %.3f lang %.3f hoch %.3f, Boden %.3f, Maßstab %.4f' % (
        hi[0] - lo[0], hi[1] - lo[1], hi[2] - lo[2], lo[2], s))
    INFO['breite_m'] = round(float(hi[0] - lo[0]), 3)
    INFO['laenge_m'] = round(float(hi[1] - lo[1]), 3)
    INFO['hoehe_m'] = round(float(hi[2] - lo[2]), 3)
    # Körperhöhe ohne Beine (Liste 1: Körper 40–55 cm hoch): Hinterleib und Vorderteil
    w_koerper = gewicht_feld(mesh, ('Abdomen', 'cephalothorax'))
    idx = np.nonzero(w_koerper > 0.5)[0]
    dg = bpy.context.evaluated_depsgraph_get()
    e = mesh.evaluated_get(dg); me = e.to_mesh()
    co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co)
    M = np.array(mesh.matrix_world)
    PK = co.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]
    e.to_mesh_clear()
    if len(idx):
        INFO['koerper_hoch_m'] = round(float(PK[idx][:, 2].max()), 3)
        print('MASS Körper (Hinterleib, Vorderteil) oben %.3f m' % INFO['koerper_hoch_m'])
    # ------------------------------------------------ Wurzelweg und Tempo
    wege = wurzelweg(d, rig, s)
    wege['Ausweichen'] = [[round(AUSWEICHEN_M * (i / AUSWEICHEN_BILDER) ** 0.8, 4), 0.0] for i in range(AUSWEICHEN_BILDER + 1)]
    wege['Ausweichen links'] = [[-x, z] for x, z in wege['Ausweichen']]
    INFO['weg'] = wege
    INFO['fps'] = FPS
    tempo = {}
    for nm, ziel in TEMPO_ZIEL.items():
        if nm not in wege:
            continue
        w = wege[nm]
        v = math.hypot(w[-1][0], w[-1][1]) / max((len(w) - 1) / FPS, 1e-3)
        tempo[nm] = round(max(1.0, min(3.0, ziel / max(v, 1e-3))), 3)
        print('TEMPO %s: Quelle %.2f m/s, Ziel %.2f m/s, Faktor %.2f' % (nm, v, ziel, tempo[nm]))
    if tempo:
        INFO['tempo'] = tempo
    # ------------------------------------------------ Bewegungen als Spuren (figur.gd spielt sie über ihre Namen)
    def spur(nm, a, schleife=False):
        a2 = a.copy(); a2.name = nm; a2.use_fake_user = True
        tr = rig.animation_data.nla_tracks.new(); tr.name = nm
        st = tr.strips.new(nm, int(a2.frame_range[0]), a2)
        if slot(a2) is not None and hasattr(st, 'action_slot'):
            st.action_slot = slot(a2)
        INFO.setdefault('zeiten', {})[nm] = round((st.action_frame_end - st.action_frame_start) / FPS, 3)
        return st
    for nm, q, _ in NAMEN:
        if q in akt:
            spur(nm, akt[q])
    for nm in ('Treffer', 'Ausweichen', 'Ausweichen links'):
        if nm in bpy.data.actions:
            spur(nm, bpy.data.actions[nm])
    rig.animation_data.action = None
    INFO['haltung'] = haltung(rig, mesh, akt, ('Stehen', 'Lefzen', 'Drohen'))
    # Kein Teil im Boden (figur.gd setzt die Figur auf 0): der Kauf taucht im Biss 27 cm, im Rennen 22 cm ein. Die Beine hängen
    # an einem eigenen Zweig (Dummy025) und folgen dem Wurzelknochen nicht (gemessen: ROOT verschieben hebt die Füße nicht),
    # darum hebt der Ort des Gerüsts selbst — eine Spur je Bewegung, die der glTF-Export mitnimmt
    gehoben = {}
    for nm in list(INFO.get('zeiten', {})):
        a = bpy.data.actions.get(nm)
        if a is None:
            continue
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        rig.location.z = 0.0     # Grundlinie je Bewegung, sonst wirkt der Hub der vorigen weiter
        for f in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1):
            rig.keyframe_insert('location', frame=f)
        hoch = 0.0
        for _ in range(4):     # in einem Durchgang blieb die Hälfte stehen (der Ort wirkt über den Maßstab); bis es sitzt
            rest = 0.0
            for f in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1):
                bpy.context.scene.frame_set(f)
                z = float(welt_netz([mesh], f)[:, 2].min())
                if z < -0.001:
                    bpy.context.scene.frame_set(f)
                    rig.location.z = rig.location.z - z / max(s, 1e-6)
                    rig.keyframe_insert('location', frame=f)
                    hoch = max(hoch, rig.location.z * s)
                    rest = min(rest, z)
            if rest > -0.001:
                break
        if hoch > 0.0:
            gehoben[nm] = round(hoch, 3)
    rig.animation_data.action = None
    rig.location.z = 0.0
    if gehoben:
        print('BODEN gehoben (m): %s' % gehoben)
    INFO['gehoben_m'] = gehoben
    # Prüfung: in keiner Bewegung im Boden (figur.gd setzt die Figur auf 0)
    tief = {}
    for nm in list(INFO.get('zeiten', {})):
        a = bpy.data.actions.get(nm)
        if a is None:
            continue
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        z = 9.0
        for f in range(int(a.frame_range[0]), int(a.frame_range[1]) + 1):
            z = min(z, float(welt_netz([mesh], f)[:, 2].min()))
        tief[nm] = round(z, 3)
    rig.animation_data.action = None
    INFO['tiefster_punkt_m'] = tief
    print('BODEN tiefster Punkt je Bewegung: %s' % tief)
    # 595 (Chef 05.11., 19:2x, Build 266: „Animation Spinne sehr gut, gibt es mehr Angriffsbewegungen/Abwechslung?“): Biss und
    # Bisskette (Bite3HitCombo) je wie kauftier.py „biss“: Kieferklauen am weitesten vorn (−Y), Zeitpunkt, seitlich -> figur.gd
    # [Abstand Ursprung–Rand des Ziels, Zeitpunkt s, Drehung Grad]; figur.gd nimmt für die Bisskette nur den Unterschied zum Biss
    # (der Biss selbst bleibt, wie er abgenommen ist)
    w_kl = gewicht_feld(mesh, ('chelicere',))
    kl = np.nonzero(w_kl > 0.5)[0]
    biss = {}
    for nm in ('Biss', 'Bisskette'):
        a = bpy.data.actions.get(nm)
        if a is None:
            continue
        rig.animation_data.action = a
        if slot(a) is not None:
            rig.animation_data.action_slot = slot(a)
        a0, a1 = int(a.frame_range[0]), int(a.frame_range[1])
        vorn = []
        for f in range(a0, a1 + 1):
            P = np.array([tuple(v) for v in welt_netz([mesh], f)])
            P = P[kl] if len(kl) else P
            i = int(P[:, 1].argmin())
            vorn.append((f, float(P[i, 1]), float(P[i, 0])))
        best = min(vorn, key=lambda x: x[1])
        biss[nm] = [round(-best[1] - 0.07, 3), round((best[0] - a0) / FPS, 3), round(-math.degrees(math.atan2(best[2], -best[1])), 1)]
        print('BISS %s: Kieferklauen vorn %.2f m bei %.2f s (Länge %.2f s), seitlich %.2f m -> %s' % (
            nm, -best[1], (best[0] - a0) / FPS, (a1 - a0) / FPS, best[2], biss[nm]))
    rig.animation_data.action = None
    INFO['biss_je'] = biss
    # ------------------------------------------------ Export
    bpy.ops.object.select_all(action='DESELECT')
    for o in (aussen, rig, mesh):
        o.select_set(True)
    pfad = os.path.join(OUT, '%s-%s.glb' % (ID, haut_name))
    bpy.ops.export_scene.gltf(filepath=pfad, export_format='GLB', use_selection=True, export_animations=True, export_skins=True,
                              export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False,
                              export_image_format='JPEG', export_jpeg_quality=88)
    INFO['sekunden_bau'] = round(time.time() - T0, 1)
    print('GLB %s %d Bytes' % (pfad, os.path.getsize(pfad)))
    return INFO


if __name__ == '__main__':
    namen = [os.environ['FELL']] if os.environ.get('FELL') else list(HAEUTE)
    info = {}
    for n in namen:
        info[n] = baue(n)
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1, ensure_ascii=False)
    print('KAUFSPINNE FERTIG %.1f s, Häute %s' % (time.time() - T0, ', '.join(namen)))
