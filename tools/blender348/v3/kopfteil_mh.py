# 2029 (Chef 25.11., 12:37, Votum A zu 2026; Systemfrage 2029): ein Skript fuer jedes starre Kopfteil aus den MakeHuman-Paketen
# (Haar, Bart, Helm, Hut, Maske, Hoerner; Weg K in LISTE-QUELLEN.md), Ausgangspunkt zopf_mh.py (431).
# Je Stueck: Ecken aus der .mhclo auf das Grundnetz hm08 (base.obj, CC0) gelegt wie MakeHuman (Gewichte + Versatz * Achsmass), damit
# alle Stuecke im selben Raum liegen; dann vom Kopf des Grundnetzes auf unseren Kopf (Ruhelage der Bezugsfigur des Geschlechts, wie
# haare.bin / haare_w.bin; Meter, Y oben, Blick +Z) je Achse abgebildet: Breite, Tiefe Hinterkopf-Nase, Hoehe Scheitel-Auge-Kinn.
# Ausgeduennt auf hoechstens 800 Dreiecke (LISTE-UMZUG-348.md Modellregel 7), Bild hoechstens 1024 px. Haar und Bart in Grau wie die
# Haare (HeldFigur.toene toent Materialien mit „Hair“), nie linear aufgehellt (Fehler 431: Gamma 0,4, halb gespannt); Helm in seinem
# eigenen Eisengrau, matt (kein Glanz, Signatur 302.3). Je Stueck zwei Netze <Kennung>_M und <Kennung>_W (Kopf Mann, Frau).
# Aufruf: bl/bin/python -I tools/blender348/v3/kopfteil_mh.py <stueck> <paketordner> <base.obj> <ausgabe.glb>
#   <stueck>: haar | bart | helm | helm_b (STUECKE unten; helm_b: Helm mit Nackenschirm, NACKEN); <paketordner>: Ordner mit hair01/, bodyparts05/, hats02/ (ausgepackte *_cc0.zip von
#   https://static.makehumancommunity.org/assets/assetpacks/<paket>.html); <base.obj>: makehuman/data/3dobjs/base.obj (CC0, Repo
#   makehumancommunity/makehuman)
import sys, os, glob
import numpy as np
from PIL import Image
import bpy

STUECK, PAKETE, BASE, AUS = sys.argv[1:5]
# Kennung, Ordner im Paket, .obj, Bild, Material (mit „Hair“ = getoent), Grau wie Haar?
STUECKE = {
    'haar': ('Haar_MH01', 'hair01/hair/culturalibre_hair_01', 'fhair01.obj', 'diffuse_black.png', 'Hair_MH01', True),
    'bart': ('Bart_Wikinger', 'bodyparts05/clothes/rehmanpolanski_beard_viking', 'beardviking.obj', 'BeardViking.png', 'Hair_Bart_Wikinger', True),
    'helm': ('Helm_Templer', 'hats02/clothes/javherre_casco_caballero_templario_templar_knight_helmet', 'casco_templario.obj', 'casco.jpg', 'Helm_Templer', False),
}
STUECKE['helm_b'] = ('Helm_Templer_B',) + STUECKE['helm'][1:]
DREIECKE, BILD = 800, 1024
# Unser Kopf in der Ruhelage der Bezugsfigur (Mensch Wachsoldat, Haut RegularMale / Female_Regular und Eyes, gemessen 25.11. am
# Kaufcache figur 5b0a834e4 mit denselben Regeln wie kopf_grundnetz): Scheitel, Augenmitte, Kinn, halbe Breite, Hinterkopf, Nasenspitze,
# Stirnlinie (Oberkante der Brauen)
KOPF = {
    'M': dict(top=1.8101, eye=1.6985, kinn=1.5869, w=0.0906, hinten=-0.1061, nase=0.1152, stirn=1.725, nacken=1.627),
    'W': dict(top=1.7664, eye=1.6559, kinn=1.5565, w=0.0889, hinten=-0.1129, nase=0.1119, stirn=1.687, nacken=1.577),
}
# „nacken“: Haaransatz hinten = Unterkante der kuerzesten Frisur Hair_Buzzed (haare.bin, haare_w.bin; 2029 Teil 2, gemessen 25.11.)
# Sitz je Stueck: Massstab um die Kopfmitte auf Hoehe der Stirnlinie (Oberkante der Brauen, „stirn“). Helm: im Paket fuer einen Kopf
# mit Kappe gebaut, auf unserem Kopf rundum 2 bis 3 cm Luft (Beleglauf 25.11., 13:41: Helm schwebte, Stirn frei). 0,85 = kleinster
# Massstab, bei dem jede Ecke der Kopfhaut ueber der Stirnlinie mindestens 3 mm innerhalb des Helms bleibt (Strahl aus der Kopfmitte,
# Mann 0,85, Frau 0,84); der Rand liegt dann vorn auf den Brauen
SITZ = {'helm': 0.85, 'helm_b': 0.85}
# 2029 Teil 2 Variante B (Nackenschirm): der Rand hinten wird bis zum Haaransatz („nacken“) nach unten gezogen. Je Richtung um die
# Kopfachse (Winkel, 24 Stufen, dazwischen gleitend) liegt der Rand auf anderer Hoehe; unter der Stirnlinie wird jede Ecke so gestreckt,
# dass der Rand dieser Richtung auf „nacken“ faellt. Gewicht gleitend nach der Tiefe (z ueber Z_VORN gar nicht, unter Z_HINTEN ganz);
# gleiche Dreiecke (Verschiebung nach dem Ausduennen, an den Ecken des Helms ohne Schirm). EIN: Schirm unten um diesen Anteil zur Nackenmitte gezogen (liegt am Nacken an)
NACKEN = {'helm_b': dict(z_vorn=0.04, z_hinten=-0.02, ein=0.25)}

def nackenschirm(W, k, n):
    W = W.copy()
    wz = np.clip((n['z_vorn'] - W[:, 2]) / (n['z_vorn'] - n['z_hinten']), 0, 1)
    wz = wz * wz * (3 - 2 * wz)
    mz = 0.5 * (k['hinten'] + k['nase'])
    win = np.arctan2(W[:, 0], W[:, 2] - mz)
    st = np.linspace(-np.pi, np.pi, 25)
    rand = np.array([W[(win >= a) & (win < b), 1].min() if ((win >= a) & (win < b)).any() else k['stirn'] for a, b in zip(st[:-1], st[1:])])
    mitte = 0.5 * (st[:-1] + st[1:])
    r = np.interp(win, mitte, rand, period=2 * np.pi)
    f = (k['stirn'] - k['nacken']) / np.maximum(k['stirn'] - r, 0.005)
    d = np.maximum(k['stirn'] - W[:, 1], 0)
    t = wz * np.clip(d / np.maximum(k['stirn'] - r, 0.005), 0, 1)
    W[:, 1] = np.where(W[:, 1] < k['stirn'], k['stirn'] - d * (1 + wz * (f - 1)), W[:, 1])
    W[:, 2] -= t * t * n['ein'] * (W[:, 2] - k['hinten'] * 0.5)
    return W

def lies_obj(p):
    V, VT, F, G, g = [], [], [], {}, None
    for z in open(p, errors='ignore'):
        q = z.split()
        if not q: continue
        if q[0] == 'v': V.append([float(x) for x in q[1:4]])
        elif q[0] == 'vt': VT.append([float(x) for x in q[1:3]])
        elif q[0] == 'g': g = q[1] if len(q) > 1 else None
        elif q[0] == 'f':
            f = [tuple(int(i) - 1 if i else -1 for i in (s.split('/') + [''])[:2]) for s in q[1:]]
            F.append(f); G.setdefault(g, set()).update(i for i, _ in f)
    return np.array(V), VT, F, G

def passen(mhclo, B):
    # wie MakeHuman: Ecke = w1*B[v1] + w2*B[v2] + w3*B[v3] + Versatz * (Abstand der Massecken im Grundnetz / Abstand beim Bau)
    sc, rows, inv = {}, [], False
    for z in open(mhclo, errors='ignore'):
        q = z.split()
        if not q or q[0].startswith('#'): continue
        if q[0] in ('x_scale', 'y_scale', 'z_scale'):
            a, b, r = int(q[1]), int(q[2]), float(q[3]); ax = 'xyz'.index(q[0][0])
            sc[ax] = abs(B[a, ax] - B[b, ax]) / r; continue
        if q[0] == 'verts': inv = True; continue
        if inv:
            try: rows.append([float(x) for x in q])
            except ValueError: inv = False
    s = np.array([sc[0], sc[1], sc[2]])
    P = []
    for r in rows:
        if len(r) == 1: P.append(B[int(r[0])]); continue
        i = [int(x) for x in r[:3]]
        P.append(r[3] * B[i[0]] + r[4] * B[i[1]] + r[5] * B[i[2]] + np.array(r[6:9]) * s)
    return np.array(P)

def kopf_grundnetz(B, G):
    # dieselben Masse am Grundnetz (Gruppe body, Augen helper-l/r-eye), Kinn: vorn in der Mitte die Hoehe, unter der die Front unter
    # die Haelfte der Nasentiefe faellt
    H = B[sorted(G['body'])]
    E = B[sorted(G['helper-l-eye'] | G['helper-r-eye'])]
    top, eye = H[:, 1].max(), E[:, 1].mean()
    ob = H[H[:, 1] > eye]
    w = np.abs(ob[:, 0]).max()
    hinten = ob[:, 2].min()
    mitte = H[np.abs(H[:, 0]) < 0.1 * w]
    nase = mitte[mitte[:, 1] > eye - (top - eye), 2].max()
    kinn = eye
    for y in np.arange(eye, eye - 2 * (top - eye), -0.02 * (top - eye)):
        s = mitte[np.abs(mitte[:, 1] - y) < 0.02 * (top - eye)]
        if len(s) and s[:, 2].max() < hinten + 0.5 * (nase - hinten): break
        kinn = y
    return dict(top=top, eye=eye, kinn=kinn, w=w, hinten=hinten, nase=nase)

# 2029-Ü14 (Pruefer 18:43: Schirm zeigt gestreckte Streifen): die Flaechen des Schirms (jedes Dreieck mit einer gezogenen Ecke) bekommen
# eigene Bildkoordinaten, abgewickelt um die Kopfachse (Bogen x Hoehe) in derselben Bilddichte wie der uebrige Helm, aus der ruhigsten
# Stelle des Helmbilds (Fenster in Schirmgroesse, Helligkeit nahe dem Mittel des Helms, kleinste Streuung); sonst streckt der Schirm das
# schmale Randband des Bilds ueber den ganzen Nacken
def schirm_uv(me, X0, X, k, im):
    uv = me.uv_layers.active.data
    zug = np.linalg.norm(X - X0, axis=1) > 0.001
    L = np.asarray(im.convert('L')).astype(float) / 255
    H, B = L.shape
    sch, rest = [], []
    for p in me.polygons: (sch if zug[list(p.vertices)].any() else rest).append(p)
    def flaeche(a, b, c): return 0.5 * np.linalg.norm(np.cross(b - a, c - a))
    fu = f3 = 0.0
    m = []
    for p in rest:
        t = [np.array(uv[li].uv) * [B, H] for li in p.loop_indices]
        v = [X[i] for i in p.vertices]
        fu += flaeche(np.append(t[0], 0), np.append(t[1], 0), np.append(t[2], 0)); f3 += flaeche(*v)
        for q in t: m.append(L[int(np.clip((1 - q[1] / H) * H, 0, H - 1)), int(np.clip(q[0], 0, B - 1))])
    dichte = np.sqrt(fu / f3)   # Bildpunkte je Meter
    mz = 0.5 * (k['hinten'] + k['nase'])
    ecken = sorted({i for p in sch for i in p.vertices})
    rad = np.hypot(X[ecken, 0], X[ecken, 2] - mz).mean()
    def ab(i): return np.array([np.arctan2(X[i, 0], -(X[i, 2] - mz)) * rad, X[i, 1]]) * dichte
    A = np.array([ab(i) for i in ecken])
    lo, hi = A.min(0), A.max(0)
    gw, gh = int(min(B - 2, hi[0] - lo[0] + 1)), int(min(H - 2, hi[1] - lo[1] + 1))
    ziel, best = np.mean(m), None
    for y in range(0, H - gh, 8):
        for x in range(0, B - gw, 8):
            w = L[y:y + gh, x:x + gw]
            g = abs(w.mean() - ziel) + w.std()
            if best is None or g < best[0]: best = (g, x, y)
    _, x0, y0 = best
    for p in sch:
        for li, i in zip(p.loop_indices, p.vertices):
            q = ab(i) - lo
            uv[li].uv = ((x0 + q[0]) / B, 1 - (y0 + gh - q[1]) / H)
    n0 = np.array([np.cross(X0[p.vertices[1]] - X0[p.vertices[0]], X0[p.vertices[2]] - X0[p.vertices[0]]) for p in me.polygons])
    n1 = np.array([np.cross(X[p.vertices[1]] - X[p.vertices[0]], X[p.vertices[2]] - X[p.vertices[0]]) for p in me.polygons])
    print('KOPFTEIL Schirm: %d Dreiecke, %d Ecken gezogen, Bilddichte %.0f px/m, Fenster %dx%d bei %d,%d (Mittel %.3f, Helm %.3f), umgeklappt %d' % (
        len(sch), zug.sum(), dichte, gw, gh, x0, y0, L[y0:y0 + gh, x0:x0 + gw].mean(), ziel, int(((n0 * n1).sum(1) < 0).sum())))

def abbilden(P, b, k):
    W = np.empty_like(P)
    W[:, 0] = P[:, 0] * k['w'] / b['w']
    W[:, 2] = k['hinten'] + (P[:, 2] - b['hinten']) * (k['nase'] - k['hinten']) / (b['nase'] - b['hinten'])
    oben = (k['top'] - k['eye']) / (b['top'] - b['eye'])
    unten = (k['eye'] - k['kinn']) / (b['eye'] - b['kinn'])
    d = P[:, 1] - b['eye']
    W[:, 1] = k['eye'] + np.where(d > 0, d * oben, d * unten)
    return W

kennung, ordner, objn, bildn, matn, grau = STUECKE[STUECK]
ordner = os.path.join(PAKETE, ordner)
B, _, _, BG = lies_obj(BASE)
b = kopf_grundnetz(B, BG)
V, VT, F, _ = lies_obj(os.path.join(ordner, objn))
P = passen(glob.glob(os.path.join(ordner, '*.mhclo'))[0], B)
assert len(P) == len(V), 'mhclo passt nicht zum obj'
print('KOPFTEIL %s %s: Grundnetz Kopf %s' % (STUECK, kennung, {x: round(float(y), 3) for x, y in b.items()}))

# Bild: hoechstens 1024 px. Haar, Bart: Grau mit Mittel 0,545 wie haar_bild der Haare; Helligkeit mit Gamma 0,4 gestaucht und halb
# gespannt wie zopf_mh.py (431); Alpha bleibt (Straehnen ausgeschnitten, glTF MASK, toon „schnitt“). Helm: eigenes Bild, nur verkleinert
a = np.asarray(Image.open(os.path.join(ordner, bildn)).convert('RGBA')).astype(float) / 255
if grau:
    deck = a[..., 3] > 0.5
    t = (a[..., :3].mean(2) + 0.004) ** 0.4
    t /= t[deck].mean()
    g = np.clip(0.545 * (0.5 + 0.5 * t), 0, 1)
    a = np.dstack([g, g, g, a[..., 3]])
else:
    # Helm: Eisengrau des Pakets, Hell und Dunkel halb gespannt (Helligkeit = Mittel/2 + eigene/2, Farbton bleibt): Kratzer und
    # Schattenstellen des Bildes gaeben sonst Flecken (Test kopfteil_2029 wie zopf_431: 15 bis 18 % Dreiecke ausser 0,4 bis 1,6 des Mittels)
    l = a[..., :3].mean(2, keepdims=True)
    a[..., :3] = np.clip(a[..., :3] * (0.5 * l.mean() / np.maximum(l, 0.02) + 0.5), 0, 1)
im = Image.fromarray((a * 255).astype(np.uint8), 'RGBA')
if not grau: im = im.convert('RGB')   # Helm ohne Alpha: als JPEG im glb (kleiner)
f = min(1.0, BILD / max(im.size))
im = im.resize((max(1, round(im.size[0] * f)), max(1, round(im.size[1] * f))), Image.LANCZOS)
bild = os.path.join(os.path.dirname(os.path.abspath(AUS)), '_%s.%s' % (kennung, 'png' if grau else 'jpg'))
im.save(bild)

for o in list(bpy.data.objects): bpy.data.objects.remove(o)
mat = bpy.data.materials.new(matn)
mat.use_nodes = True
bsdf = mat.node_tree.nodes['Principled BSDF']
tx = mat.node_tree.nodes.new('ShaderNodeTexImage')
tx.image = bpy.data.images.load(bild)
mat.node_tree.links.new(tx.outputs['Color'], bsdf.inputs['Base Color'])
bsdf.inputs['Roughness'].default_value = 1.0
bsdf.inputs['Metallic'].default_value = 0.0
if grau:
    # Alpha ueber „groesser als 0,5“: der glTF-Export schreibt alphaMode MASK (Godot Alpha-Schnitt, toon „schnitt“), nicht BLEND
    ma = mat.node_tree.nodes.new('ShaderNodeMath')
    ma.operation = 'GREATER_THAN'
    ma.inputs[1].default_value = 0.5
    mat.node_tree.links.new(tx.outputs['Alpha'], ma.inputs[0])
    mat.node_tree.links.new(ma.outputs[0], bsdf.inputs['Alpha'])
for gs, k in KOPF.items():
    W = abbilden(P, b, k)
    if STUECK in SITZ: W = (W - [0, k['stirn'], 0]) * SITZ[STUECK] + [0, k['stirn'], 0]
    name = '%s_%s' % (kennung, gs)
    me = bpy.data.meshes.new(name)
    me.from_pydata([(x, -z, y) for x, y, z in W], [], [[i for i, _ in f] for f in F])   # Blender Z oben, Blick -Y
    uv = me.uv_layers.new()
    for poly in me.polygons:
        for li, (_, ti) in zip(poly.loop_indices, F[poly.index]):
            uv.data[li].uv = VT[ti] if ti >= 0 else (0, 0)
    me.materials.append(mat)
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    vor = sum(len(p.vertices) - 2 for p in me.polygons)
    bpy.context.view_layer.objects.active = ob
    if vor > DREIECKE:
        md = ob.modifiers.new('aus', 'DECIMATE')
        md.decimate_type = 'COLLAPSE'
        md.use_collapse_triangulate = True
        md.delimit = {'UV'}
        r = DREIECKE / vor
        for _ in range(20):   # Verhaeltnis so, dass hoechstens DREIECKE bleiben
            md.ratio = r
            n = len(ob.evaluated_get(bpy.context.evaluated_depsgraph_get()).data.loop_triangles)
            if n <= DREIECKE: break
            r *= 0.97
        bpy.ops.object.modifier_apply(modifier='aus')
    tm = ob.modifiers.new('tri', 'TRIANGULATE')
    bpy.ops.object.modifier_apply(modifier='tri')
    nach = len(me.polygons)
    if STUECK in NACKEN:   # nach dem Ausduennen: oben derselbe Helm wie ohne Schirm (gleiche Ecken, gleiche Dreiecke), nur der Rand gezogen
        X0 = np.array([(v.co.x, v.co.z, -v.co.y) for v in me.vertices])
        X = nackenschirm(X0, k, NACKEN[STUECK])
        for v, (x, y, z) in zip(me.vertices, X): v.co = (x, -z, y)
        schirm_uv(me, X0, X, k, im)
    print('KOPFTEIL %s: Dreiecke %d -> %d, Bild %dx%d, Hoehe %.3f..%.3f m, Breite %.3f m, Tiefe %.3f..%.3f m' % (
        name, vor, nach, im.size[0], im.size[1], W[:, 1].min(), W[:, 1].max(), np.ptp(W[:, 0]), W[:, 2].min(), W[:, 2].max()))
    assert nach <= DREIECKE
bpy.ops.export_scene.gltf(filepath=AUS, export_format='GLB', export_image_format='AUTO', export_apply=True)
os.remove(bild)
print('KOPFTEIL geschrieben', AUS, os.path.getsize(AUS))
