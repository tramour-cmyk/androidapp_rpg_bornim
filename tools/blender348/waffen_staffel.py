# 458.3 Waffenformen gestaffelt (Chef 01.11., 19:5x, Archiv 458.3: „Staffel nach Stufe, Seltenheit über Material und Zeichen“; Zu 458.3:
# „wir können schon das gleiche Modell nehmen und dann eben wird es seltener oder verzaubert durch andere Effekte oder Texturen“):
# je Waffenart 2-4 Formen aus dem Bestand (Omie, Anker, Avramania; LISTE-BESTAND „Waffen und Schilde“), welche Form ab welcher Stufe gilt,
# steht nur in der Datendatei (tools/gegenstaende/gegenstaende.json, Spalte formen). Alles in unsere Farben (Fremdes fliegt raus):
# jede Flaeche bekommt eine Klasse (metall, beschlag, holz, leder, akzent) nach ihrer Farbe im Paket; je Klasse und Seltenheit eine
# Farbe aus unserer Palette (PALETTE unten), die Zeichnung des Pakets (Maserung, Kratzer) bleibt als Helligkeit. So wird es gebaut:
# ein Gegenstand = Netz x Bild je Klasse und Seltenheit (wie 455.1: Godot tauscht nur das Bild).
# Aufruf: KAUF=<kaufpakete> KATALOG=<gegenstaende.json> ZIEL=<ordner> bl/bin/python -I waffen_staffel.py
#   -> <ZIEL>/<kennung>.glb (Flaechen je Klasse, Material „<klasse>.<n>“), <ZIEL>/<kennung>__<material>__<SELTENHEIT>.png, staffel.json
# Ohne Kaufpakete: TESTPAKETE=1 baut drei kleine Probenetze (obj mit Bild, fbx mit Grundfarben, glb mit Palette) zum Pruefen des Wegs.
import bpy, os, sys, json, glob, re, colorsys
import numpy as np
from mathutils import Vector, Matrix

KAUF = os.environ.get('KAUF', os.path.expanduser('~/kauf'))
ZIEL = os.environ.get('ZIEL', os.path.expanduser('~/staffel'))
KATALOG = os.environ.get('KATALOG', os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'gegenstaende', 'gegenstaende.json'))
GROSS = int(os.environ.get('GROSS', '256'))   # Bildkante: im Film und auf dem Handy ist eine Waffe selten hoeher als 300 Bildpunkte
os.makedirs(ZIEL, exist_ok=True)
PAKETE = [('Omie', 'Medieval.Weapon.Pack.Godot', '.obj'), ('Anker', 'Low.Poly.Medieval.Weapons', '.fbx'),
          ('Avramania', 'Weapons_Shields_Free', '.glb')]
SELTENHEITEN = ['COMMON', 'UNCOMMON', 'RARE', 'VERY_RARE', 'EPIC', 'DIVINE']   # wie Rarity in Gear.kt
KLASSEN = ['metall', 'beschlag', 'holz', 'leder', 'akzent']


def h(x):
    return tuple(((x >> s) & 255) / 255.0 for s in (16, 8, 0))


# Unsere Farben (sRGB) je Seltenheit und Klasse. Ausgang: waffen.py (Stahl 868E98, Eisen 4A4C50, Leder 3A2A20, Messing A8884A,
# Holz 6A4A2E), Baukasten 455.1 (Krapprot, Nachtblau), Gold B8904A (Signatur: Gold einziger Glanz, erst ab „episch“).
# Material und Zeichen je Seltenheit in Worten: Datendatei, Block „seltenheit“.
PALETTE = {
    'COMMON':    {'metall': h(0x5E6168), 'beschlag': h(0x4A4C50), 'holz': h(0x6A4A2E), 'leder': h(0x3A2A20), 'akzent': h(0x4A3A30)},
    'UNCOMMON':  {'metall': h(0x868E98), 'beschlag': h(0x3A3C42), 'holz': h(0x5A3A26), 'leder': h(0x6E2E24), 'akzent': h(0x6E2E24)},
    'RARE':      {'metall': h(0xA0A6AE), 'beschlag': h(0xA8884A), 'holz': h(0x4A3020), 'leder': h(0x2A2220), 'akzent': h(0x2A3450)},
    'VERY_RARE': {'metall': h(0x4E5660), 'beschlag': h(0xA8884A), 'holz': h(0x2A2220), 'leder': h(0x22202A), 'akzent': h(0x5A3A8A)},
    'EPIC':      {'metall': h(0x30333A), 'beschlag': h(0xB8904A), 'holz': h(0x221C1A), 'leder': h(0x4A1A16), 'akzent': h(0xB0601A)},
    'DIVINE':    {'metall': h(0xC4C8CE), 'beschlag': h(0xB8904A), 'holz': h(0x2A2220), 'leder': h(0x3A2A20), 'akzent': h(0xD8B040)},
}
# Glimmen (Godot: glow je Flaeche in glow_col): verzaubert ab „sehr selten“, schwach, in der Farbe der Seltenheit (Gear.kt), Klinge
# leiser als Stein und Schmuck (akzent); bleibt hier, damit Film und Spiel dieselben Zahlen lesen (staffel.json)
GLIMMEN = {'VERY_RARE': (h(0x9A4FE0), {'metall': 0.10, 'akzent': 0.45}), 'EPIC': (h(0xE8841A), {'metall': 0.14, 'akzent': 0.55}),
           'DIVINE': (h(0xE8C030), {'metall': 0.16, 'beschlag': 0.10, 'akzent': 0.6})}


def klasse(rgb):
    # Klasse einer Paketfarbe (sRGB 0-1): grau = Metall, gelb-hell = Beschlag (Messing, Gold), braun = Holz oder Leder, sonst Akzent
    r, g, b = [float(x) for x in rgb[:3]]
    hu, s, v = colorsys.rgb_to_hsv(r, g, b)
    hu *= 360
    if v < 0.10: return 'leder'
    if s < 0.18: return 'metall'
    if 18 <= hu <= 65:
        if v > 0.55 and s > 0.35: return 'beschlag'
        return 'leder' if v < 0.26 else 'holz'
    if hu < 18 or hu > 330:
        return 'leder' if (s < 0.6 and v < 0.45) else 'akzent'
    return 'akzent'


def slug(s):
    return re.sub(r'[^a-z0-9]+', '_', s.lower()).strip('_')


def hat_bild(im):
    # has_data ist bei Bildern aus glb (gepackt) falsch, bis jemand die Pixel liest
    try:
        return im is not None and im.size[0] > 0 and len(im.pixels) > 0
    except Exception:
        return False


def basisbild(m):
    if not m or not m.node_tree: return None
    bsdf = next((n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None)
    n = bsdf.inputs['Base Color'].links[0].from_node if bsdf and bsdf.inputs['Base Color'].links else None
    while n is not None and n.type != 'TEX_IMAGE':
        n = next((i.links[0].from_node for i in n.inputs if i.links), None)
    if n is not None and hat_bild(n.image): return n.image
    return next((x.image for x in m.node_tree.nodes if x.type == 'TEX_IMAGE' and hat_bild(x.image)), None)


def grundfarbe(m):
    if m is None: return (0.6, 0.6, 0.6)
    bsdf = next((n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None) if m.node_tree else None
    c = bsdf.inputs['Base Color'].default_value if bsdf else m.diffuse_color
    # Grundfarbe ist linear, Klasse und Palette in sRGB
    return tuple((1.055 * x ** (1 / 2.4) - 0.055) if x > 0.0031308 else 12.92 * x for x in c[:3])


def omie_bild(p, m):
    # Omie: obj, die mtl nennt kein Bild (waffen_bestand.py); TGA mit dem Namen der Waffe daneben
    stamm = re.sub(r'^sm_', '', os.path.splitext(os.path.basename(p))[0].lower())
    kand = sorted(glob.glob(os.path.join(os.path.dirname(p), '**', '*.tga'), recursive=True) +
                  glob.glob(os.path.join(os.path.dirname(p), '**', '*.png'), recursive=True))
    farbe = [k for k in kand if re.search(r'base.?color|albedo|diffuse', os.path.basename(k), re.I)] or kand
    genau = [k for k in farbe if stamm.replace('_', '') in os.path.basename(k).lower().replace('_', '')]
    wahl = (genau or farbe or [None])[0]
    return bpy.data.images.load(wahl) if wahl else None


def pixel(im):
    W, H = im.size
    px = np.empty(W * H * 4, dtype=np.float32)
    im.pixels.foreach_get(px)
    return px.reshape(H, W, 4)[:, :, :3].copy()


def verkleinert(a):
    H, W = a.shape[:2]
    f = max(1, int(np.ceil(max(H, W) / GROSS)))
    if f == 1: return a
    H2, W2 = H // f, W // f
    return a[:H2 * f, :W2 * f].reshape(H2, f, W2, f, 3).mean((1, 3))


def bild_klassen(a):
    # Klasse je Bildpunkt (gleiche Regel wie klasse(), vektorisiert)
    mx, mn = a.max(2), a.min(2)
    s = np.where(mx > 1e-6, (mx - mn) / np.maximum(mx, 1e-6), 0)
    r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
    d = np.maximum(mx - mn, 1e-6)
    hu = np.where(mx == r, (g - b) / d % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    k = np.full(a.shape[:2], 4, np.int8)   # akzent
    rotbraun = (hu < 18) | (hu > 330)
    k = np.where(rotbraun & (s < 0.6) & (mx < 0.45), 3, k)
    gelb = (hu >= 18) & (hu <= 65)
    k = np.where(gelb, np.where((mx > 0.55) & (s > 0.35), 1, np.where(mx < 0.26, 3, 2)), k)
    k = np.where(s < 0.18, 0, k)
    k = np.where(mx < 0.10, 3, k)
    return k


def umfaerben(a, kl, sel):
    # ganzes Bild in der Farbe der Klasse kl, Zeichnung als Helligkeit gegen den Median der Bildpunkte dieser Klasse
    lum = a @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    k = bild_klassen(a)
    eigen = lum[k == KLASSEN.index(kl)]
    med = float(np.median(eigen)) if eigen.size > 16 else float(np.median(lum))
    S = np.clip(lum / max(med, 0.02), 0.55, 1.45) ** 0.85
    out = np.array(PALETTE[sel][kl], dtype=np.float32)[None, None, :] * S[:, :, None]
    return np.clip(out, 0, 1)


def speichern(a, pfad):
    H, W = a.shape[:2]
    im = bpy.data.images.new(os.path.basename(pfad), W, H, alpha=False)
    rgba = np.concatenate([a, np.ones((H, W, 1), np.float32)], 2)
    im.pixels.foreach_set(rgba.ravel())
    im.filepath_raw = pfad
    im.file_format = 'PNG'
    im.save()
    return im


def testpakete(wo):
    # drei kleine Probenetze, je Paketart eines, damit der Weg ohne Kaufdateien am Rechner geprueft werden kann
    bpy.ops.wm.read_factory_settings(use_empty=True)
    os.makedirs(os.path.join(wo, 'Medieval.Weapon.Pack.Godot', 'Mace'), exist_ok=True)
    os.makedirs(os.path.join(wo, 'Low.Poly.Medieval.Weapons'), exist_ok=True)
    os.makedirs(os.path.join(wo, 'Weapons_Shields_Free'), exist_ok=True)
    # Omie: Stiel (Holz, unten) und Kopf (Stahl, oben) in einem Netz, Farbe nur im Bild (links braun, rechts grau)
    bpy.ops.mesh.primitive_cylinder_add(radius=0.02, depth=0.5, location=(0, 0, 0))
    stiel = bpy.context.active_object
    bpy.ops.mesh.primitive_cube_add(size=0.12, location=(0, 0, 0.3))
    kopf = bpy.context.active_object
    for o, u in ((stiel, 0.25), (kopf, 0.75)):
        for l in o.data.uv_layers.active.data: l.uv = (u + (l.uv[0] - 0.5) * 0.2, l.uv[1])
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.join()
    img = bpy.data.images.new('t', 64, 64)
    px = np.zeros((64, 64, 4), np.float32); px[:, :, 3] = 1
    px[:, :32, :3] = (0.45, 0.30, 0.16); px[:, 32:, :3] = (0.55, 0.56, 0.58); px[::7, 32:, :3] = 0.35
    img.pixels.foreach_set(px.ravel())
    d = os.path.join(wo, 'Medieval.Weapon.Pack.Godot', 'Mace')
    img.filepath_raw = os.path.join(d, 'sm_mace_Mat_Mace_BaseColor.png'); img.file_format = 'PNG'; img.save()
    bpy.ops.wm.obj_export(filepath=os.path.join(d, 'sm_mace.obj'), export_materials=False)
    # Anker: Grundfarben je Material, ohne Bild; Klinge liegt (laengste Achse x), Griff rechts
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    o = bpy.context.active_object
    o.scale = (1.2, 0.06, 0.01); bpy.ops.object.transform_apply(scale=True)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0.75, 0, 0))
    g = bpy.context.active_object
    g.scale = (0.3, 0.03, 0.03); bpy.ops.object.transform_apply(scale=True)
    for ob, nm, c in ((o, 'Metal', (0.6, 0.6, 0.62, 1)), (g, 'Handle', (0.12, 0.05, 0.02, 1))):
        m = bpy.data.materials.new(nm); m.use_nodes = True
        m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = c
        ob.data.materials.append(m)
    bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.join()
    bpy.ops.export_scene.fbx(filepath=os.path.join(wo, 'Low.Poly.Medieval.Weapons', 'Sword.fbx'))
    # Avramania: glb mit Palettenbild
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.mesh.primitive_cone_add(radius1=0.05, depth=0.8)
    o = bpy.context.active_object
    pal = bpy.data.images.new('pal', 16, 16)
    px = np.zeros((16, 16, 4), np.float32); px[:, :, 3] = 1; px[:, :8, :3] = (0.75, 0.6, 0.2); px[:, 8:, :3] = (0.2, 0.2, 0.7)
    pal.pixels.foreach_set(px.ravel()); pal.pack()
    m = bpy.data.materials.new('pal'); m.use_nodes = True
    t = m.node_tree.nodes.new('ShaderNodeTexImage'); t.image = pal
    m.node_tree.links.new(t.outputs['Color'], m.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
    o.data.materials.append(m)
    for l in o.data.uv_layers.active.data: l.uv = (0.2, 0.5)
    bpy.ops.export_scene.gltf(filepath=os.path.join(wo, 'Weapons_Shields_Free', 'mdvl_weapons_spear_01.glb'), export_format='GLB')


if os.environ.get('TESTPAKETE'):
    testpakete(KAUF)

# Formen aus der Datendatei: jede Kennung, die eine Waffe in „formen“ nennt
katalog = json.load(open(KATALOG, encoding='utf-8'))
gesucht = {}
for g in katalog['gegenstaende']:
    for f in g.get('formen') or []:
        gesucht.setdefault(f['netz'], []).append(g['id'])
print('FORMEN', len(gesucht), 'aus', KATALOG)

dateien = {}
for paket, ordner, endung in PAKETE:
    wurzeln = [d for d in glob.glob(os.path.join(KAUF, '**', ordner + '*'), recursive=True) if os.path.isdir(d)]
    for f in sorted({f for w in wurzeln for f in glob.glob(os.path.join(w, '**', '*' + endung), recursive=True)}):
        dateien.setdefault('%s_%s' % (paket.lower(), slug(os.path.splitext(os.path.basename(f))[0])), (paket, f))
print('DATEIEN', len(dateien))

info = {}
for kennung in sorted(gesucht):
    if kennung not in dateien:
        print('FEHLT Datei', kennung); continue
    paket, p = dateien[kennung]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    try:
        if p.endswith('.obj'): bpy.ops.wm.obj_import(filepath=p)
        elif p.endswith('.fbx'): bpy.ops.import_scene.fbx(filepath=p)
        else: bpy.ops.import_scene.gltf(filepath=p)
    except Exception as e:
        print('FEHLT Import', kennung, e); continue
    netze = [o for o in bpy.data.objects if o.type == 'MESH']
    if not netze: print('FEHLT Netz', kennung); continue
    for o in [o for o in bpy.data.objects if o.type != 'MESH']: bpy.data.objects.remove(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in netze: o.select_set(True)
    bpy.context.view_layer.objects.active = netze[0]
    if len(netze) > 1: bpy.ops.object.join()
    o = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    me = o.data
    if not me.materials: me.materials.append(None)
    # Quelle je altem Material: Bild (Omie: Datei daneben) oder Grundfarbe
    quellen = []
    for m in me.materials:
        im = basisbild(m)
        if im is None and paket == 'Omie': im = omie_bild(p, m)
        quellen.append(('bild', verkleinert(pixel(im))) if im is not None else ('farbe', grundfarbe(m)))
    if not me.uv_layers: me.uv_layers.new(name='UV')
    uv = np.empty(len(me.loops) * 2); me.uv_layers.active.data.foreach_get('uv', uv); uv = uv.reshape(-1, 2)
    # Klasse je Flaeche: Bild an Schwerpunkt und Ecken der UV (Mehrheit), sonst Grundfarbe des Materials
    fl_kl, fl_q = [], []
    for pg in me.polygons:
        qi = min(pg.material_index, len(quellen) - 1)
        art, q = quellen[qi]
        if art == 'farbe':
            fl_kl.append(klasse(q))
        else:
            H, W = q.shape[:2]
            pts = uv[list(pg.loop_indices)]
            pts = np.vstack([pts.mean(0, keepdims=True)] * 2 + [pts * 0.7 + pts.mean(0) * 0.3])
            xs = np.clip((pts[:, 0] % 1.0) * W, 0, W - 1).astype(int); ys = np.clip((pts[:, 1] % 1.0) * H, 0, H - 1).astype(int)
            ks = bild_klassen(q[ys, xs][None, :, :])[0]
            fl_kl.append(KLASSEN[int(np.bincount(ks, minlength=5).argmax())])
        fl_q.append(qi)
    # neue Materialien je (Quelle, Klasse)
    paare = sorted({(q, k) for q, k in zip(fl_q, fl_kl)}, key=lambda x: (KLASSEN.index(x[1]), x[0]))
    neu = []
    for i, (qi, kl) in enumerate(paare):
        name = '%s.%d' % (kl, i)
        bilder = {}
        art, q = quellen[qi]
        for sel in SELTENHEITEN:
            a = umfaerben(q, kl, sel) if art == 'bild' else np.tile(np.array(PALETTE[sel][kl], np.float32), (4, 4, 1))
            bilder[sel] = speichern(a, os.path.join(ZIEL, '%s__%s__%s.png' % (kennung, name, sel)))
        m = bpy.data.materials.new(name); m.use_nodes = True
        t = m.node_tree.nodes.new('ShaderNodeTexImage'); t.image = bilder['COMMON']
        m.node_tree.links.new(t.outputs['Color'], m.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
        neu.append(m)
    idx = {pk: i for i, pk in enumerate(paare)}
    zuordnung = [idx[(q, k)] for q, k in zip(fl_q, fl_kl)]
    me.materials.clear()
    for m in neu: me.materials.append(m)
    for pg, i in zip(me.polygons, zuordnung): pg.material_index = i
    for a in list(me.color_attributes): me.color_attributes.remove(a)   # Eckfarben faerbten im toon.gdshader mit (COLOR.rgb)
    # Lage: Mitte in den Ursprung, laengste Achse senkrecht; Metall nach oben (Klinge, Kopf), Griff nach unten
    vs = np.array([v.co[:] for v in me.vertices])
    lo, hi = vs.min(0), vs.max(0)
    lang = int(np.argmax(hi - lo))
    R = Matrix.Identity(4)
    if lang == 0: R = Matrix.Rotation(1.5708, 4, 'Y')
    elif lang == 1: R = Matrix.Rotation(1.5708, 4, 'X')
    me.transform(R @ Matrix.Translation(Vector(-(lo + hi) / 2)))
    laenge = float((hi - lo).max())
    zs = np.array([(o.matrix_world @ pg.center).z for pg in me.polygons])
    fl = np.array([pg.area for pg in me.polygons])
    metall = np.array([k in ('metall', 'beschlag') for k in fl_kl])
    oben = float((fl * metall * (zs > laenge * 0.25)).sum()); unten = float((fl * metall * (zs < -laenge * 0.25)).sum())
    gedreht = unten > oben * 1.15 and float((fl * metall).sum()) < 0.9 * float(fl.sum())   # ganz aus Metall: Lage lassen
    if gedreht: me.transform(Matrix.Rotation(3.14159, 4, 'X'))
    me.transform(Matrix.Scale(1.0 / max(laenge, 1e-6), 4))   # 1 m zum Ansehen; Laenge am Helden setzt das Spiel (417)
    o.name = kennung
    dr = sum(len(pg.vertices) - 2 for pg in me.polygons)
    bpy.ops.object.select_all(action='DESELECT'); o.select_set(True)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, kennung + '.glb'), export_format='GLB', use_selection=True)
    anteil = {k: round(float(fl[np.array(fl_kl) == k].sum() / max(fl.sum(), 1e-9)), 3) for k in KLASSEN}
    info[kennung] = {'paket': paket, 'datei': os.path.relpath(p, KAUF), 'dreiecke': dr, 'laenge_roh': round(laenge, 3),
                     'gedreht': gedreht, 'materialien': [m.name for m in neu], 'anteil': anteil, 'fuer': gesucht[kennung]}
    print('FORM', kennung, dr, 'Dreiecke', 'Materialien', ','.join(m.name for m in neu), 'Anteil', anteil,
          'gedreht' if info[kennung]['gedreht'] else '')
json.dump({'formen': info, 'seltenheiten': SELTENHEITEN, 'glimmen': {s: {'farbe': c, 'klassen': k} for s, (c, k) in GLIMMEN.items()}},
          open(os.path.join(ZIEL, 'staffel.json'), 'w'), indent=1, ensure_ascii=False)
print('STAFFEL OK', len(info), 'von', len(gesucht))
