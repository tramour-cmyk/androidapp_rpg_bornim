# 406 (Chef 31.10., 23:22, Archiv „406, Schilde“: „Schild 2 für ehemaligen Kleriker (neues System!!!) und 15 für Krieger (neues
# System)“): die zwei gewählten Schilde aus dem Drehfilm (schilde_bestand.py, Nummern wie dort) als Ausrüstung des Helden.
# Unverändert bis auf Lage und Größe, nach der Regel von waffen.py: Vorderseite nach glTF +Z (Blender -Y), oben nach +Z (Blender),
# Ursprung an der Fessel (Mitte des Griffs, auf der Rückseite des Bretts), so hängt figur.gd _hold und heldfigur.gd bewaffne sie
# wie die eigenen. Lage wie im Drehfilm (was der Chef gesehen hat): Omie oben breit, unten spitz; PolyMech die Aussparungen oben
# und unten. Farbe: Omie aus der Textur (BaseColor eingebettet), PolyMech aus den Grundfarben der Materialien als Eckfarben.
#   shield       = 2  Omie „3D Medieval Weapon Pack“ sm_shield_kite (Drachenschild), Kleriker
#   round_shield = 15 PolyMech „Low Poly Shields“ open_sides_round_Shield (zweiter offener runder), Krieger
# Kaufdateien (bornim-kaufmodelle, nie ins Repository); Ergebnis gekauft, also nur verschlüsselt ins APK (kauf.txt).
# Aufruf: KAUF=<kaufpakete> OUT=<ordner> bl/bin/python -I kaufschild.py  ->  <OUT>/shield.glb, round_shield.glb, kaufschild-info.json
import bpy, os, sys, glob, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kaufquelle     # 980: von doppelten Kaufdateien nur, was Blender liest (Binär-FBX)
from mathutils import Vector, Matrix

KAUF = os.environ.get('KAUF', os.path.expanduser('~/kauf'))
OUT = os.environ.get('OUT', os.path.expanduser('~/kaufschild'))
os.makedirs(OUT, exist_ok=True)

# Kennung, Nummer im Film, Datei, Vorderseite (Achse, Vorzeichen), oben (Achse, Vorzeichen), Rückseite des Bretts in der Mitte
# (gemessen auf der Achse der Vorderseite, Einheiten der Datei), Größe: Höhe (Drachenschild) bzw. Durchmesser (rund) in m.
# Rückseite gemessen 01.11.: Omie Mitte vorn -0,09 bis -0,11 (Buckel), Brett hinten -0,05, Griff bis +0,01;
# PolyMech Buckel vorn bis 0,094, Brett 0,03 bis 0,0, Griff bis -0,03.
# Größe: Drachenschild 72 cm hoch wie unser bisheriger Kampfschild (waffen.py build_shield 56 × 72), rund 60 cm wie der Rundschild.
SCHILDE = [
    dict(kennung='shield', nr=2, paket='Omie', datei='sm_shield_kite.obj', vorn=(0, -1), oben=(2, 1), ruecken=-0.05, groesse=0.72,
         sonne=True),
    dict(kennung='round_shield', nr=15, paket='PolyMech', datei='open_sides_round_Shield.fbx', vorn=(2, 1), oben=(1, 1), ruecken=0.0,
         groesse=0.60),
]


# 406, B5 (Chef 01.11., 22:35, Archiv 461c: „Schild 2 als Form, darauf die goldene Sonne in unseren Farben“): die Sonne des alten
# Kleriker-Rundschilds (Dress.kt: vergoldeter Buckel, Ring um ihn, acht Strahlen) als eigene dünne Fläche 2 mm vor der Vorderseite
# des Drachenschilds, aus der Ebene von vorn auf das Brett gelegt (folgt Wölbung und Buckel); Gold wie Wappenrock (held_klassen.py
# SONNE_GOLD, Dress.kt gold B8904A), als Eckfarbe linear wie die Grundfarben der PolyMech-Schilde. Maße wie Dress.kt (Ring bei 0,07,
# Strahlen bis 0,13, halbe Breite 0,012 der Körperhöhe) im Verhältnis zur Strahlenlänge, die 0,8 der halben Breite des Schilds an
# der Höhe des Buckels misst. Material „sonne“ (tests/schild_406.gd zählt es getrennt).
SONNE_GOLD_LIN = (0.477, 0.279, 0.069, 1.0)     # sRGB B8904A
SONNE_ABSTAND = 0.002


def sonne(o):
    import bmesh
    from math import pi, cos, sin
    from mathutils.bvhtree import BVHTree
    me = o.data
    bm0 = bmesh.new(); bm0.from_mesh(me)
    bvh = BVHTree.FromBMesh(bm0)
    vs = [v.co.copy() for v in me.vertices]

    def vorn_auf(x, z):     # vorderste Stelle des Schilds bei (x, z), 2 mm davor; None außerhalb
        loc, nrm, _, _ = bvh.ray_cast(Vector((x, -1.0, z)), Vector((0.0, 1.0, 0.0)))
        if loc is None: return None
        n = nrm if nrm.y < 0 else -nrm
        return loc + n.normalized() * SONNE_ABSTAND

    # Mitte: der Buckel, die vordersten Ecken im mittleren Feld
    mitte = [v for v in vs if abs(v.x) < 0.12 and abs(v.z) < 0.15]
    ymin = min(v.y for v in mitte)
    spitze = [v for v in mitte if v.y < ymin + 0.004]
    cx = sum(v.x for v in spitze) / len(spitze); cz = sum(v.z for v in spitze) / len(spitze)
    halb = max(abs(v.x - cx) for v in vs if abs(v.z - cz) < 0.02)
    # Buckel: Profil der Vorderseite über den Abstand von der Mitte (16 Richtungen); Rand, wo sie das Brett erreicht
    def tiefe(r):
        ys = [p.y for p in (vorn_auf(cx + r * cos(a * pi / 8), cz + r * sin(a * pi / 8)) for a in range(16)) if p is not None]
        return sum(ys) / len(ys) if ys else 0.0
    brett = tiefe(0.6 * halb)
    buckel = 0.0
    if tiefe(0.0) < brett - 0.01:
        r = 0.0
        while r < 0.5 * halb and tiefe(r) < brett - 0.003: r += 0.005
        buckel = r
    lang = 0.8 * halb
    ring = 0.54 * lang; w = 0.092 * lang
    scheibe = buckel + 0.005 if buckel > 0 else 0.27 * lang
    ring = max(ring, scheibe + 0.01 + w)

    bm = bmesh.new()
    def gitter(punkt, nu, nv):     # punkt(u, v) in [0,1]^2 -> (x, z); Vierecke, außerhalb des Schilds weggelassen
        ecken = []
        for i in range(nu + 1):
            reihe = []
            for j in range(nv + 1):
                x, z = punkt(i / nu, j / nv)
                p = vorn_auf(x, z)
                reihe.append(bm.verts.new(p) if p is not None else None)
            ecken.append(reihe)
        for i in range(nu):
            for j in range(nv):
                q = [ecken[i][j], ecken[i + 1][j], ecken[i + 1][j + 1], ecken[i][j + 1]]
                if all(q) and len(set(q)) == 4: bm.faces.new(q)
    def kreis(r0, r1, nr, ns):
        if r0 <= 0.0:     # Scheibe: Mitte als Fächer
            mp = vorn_auf(cx, cz)
            m = bm.verts.new(mp)
            rand = [bm.verts.new(vorn_auf(cx + r1 / nr * cos(2 * pi * k / ns), cz + r1 / nr * sin(2 * pi * k / ns))) for k in range(ns)]
            for k in range(ns): bm.faces.new([m, rand[k], rand[(k + 1) % ns]])
            r0 = r1 / nr; nr -= 1
            if nr <= 0: return
        gitter(lambda u, v: (cx + (r0 + (r1 - r0) * u) * cos(2 * pi * v), cz + (r0 + (r1 - r0) * u) * sin(2 * pi * v)), nr, ns)
    kreis(0.0, scheibe, 4, 48)
    kreis(ring - w, ring + w, 2, 96)
    for k in range(8):
        a = k * pi / 4; dx, dz = cos(a), sin(a)
        r0 = ring + 0.9 * w
        gitter(lambda u, v, dx=dx, dz=dz, r0=r0: (cx + dx * (r0 + (lang - r0) * u) - dz * w * (2 * v - 1),
                                                  cz + dz * (r0 + (lang - r0) * u) + dx * w * (2 * v - 1)), 12, 2)
    bmesh.ops.remove_doubles(bm, verts=[v for v in bm.verts if v.is_valid], dist=1e-6)
    for f in bm.faces:
        f.normal_update()
        if f.normal.y > 0: f.normal_flip()
    neu = bpy.data.meshes.new('sonne'); bm.to_mesh(neu); bm.free(); bm0.free()
    mat = bpy.data.materials.new('sonne'); mat.use_nodes = True
    bsdf = next((n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None)
    if bsdf: bsdf.inputs['Base Color'].default_value = SONNE_GOLD_LIN
    neu.materials.append(mat)
    so = bpy.data.objects.new('sonne', neu); bpy.context.scene.collection.objects.link(so)
    # Eckfarbe: Schild weiß (Textur × 1), Sonne Gold
    for m_, c in ((me, (1.0, 1.0, 1.0, 1.0)), (neu, SONNE_GOLD_LIN)):
        ca = m_.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER')
        for d in ca.data: d.color = c
        m_.color_attributes.active_color = ca
    bpy.ops.object.select_all(action='DESELECT'); so.select_set(True); o.select_set(True)
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.join()
    print('SONNE', dict(mitte_cm=(round(cx * 100, 1), round(cz * 100, 1)), halbe_breite_cm=round(halb * 100, 1),
                        buckel_cm=round(buckel * 100, 1), scheibe_cm=round(scheibe * 100, 1), ring_cm=round(ring * 100, 1),
                        ring_halb_cm=round(w * 100, 1), strahlen_cm=round(lang * 100, 1)))
    return o


def finde(muster):
    return kaufquelle.finde(KAUF, muster, 'SCHILD')


def achse(i, s):
    v = Vector((0, 0, 0)); v[i] = s; return v


def bau(e):
    p = finde(e['datei'])
    if not p:
        print('FEHLT', e['kennung'], e['datei']); return None
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if p.endswith('.obj'): bpy.ops.wm.obj_import(filepath=p)
    else: bpy.ops.import_scene.fbx(filepath=p)
    netze = [o for o in bpy.data.objects if o.type == 'MESH']
    for o in [o for o in bpy.data.objects if o.type != 'MESH']: bpy.data.objects.remove(o)
    bpy.ops.object.select_all(action='DESELECT')
    for o in netze: o.select_set(True)
    bpy.context.view_layer.objects.active = netze[0]
    if len(netze) > 1: bpy.ops.object.join()
    o = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    me = o.data
    # Farbe: Omie (obj ohne mtl) aus der BaseColor-TGA daneben; ohne Bild (PolyMech) die Grundfarbe je Material als Eckfarbe
    for ms in o.material_slots:
        m = ms.material
        if m is None: continue
        m.use_nodes = True
        nt = m.node_tree
        bsdf = next((n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED'), None)
        hat = any(n.type == 'TEX_IMAGE' and n.image and n.image.has_data for n in nt.nodes)
        kand = sorted(glob.glob(os.path.join(os.path.dirname(p), '*BaseColor*.tga')))
        if not hat and bsdf is not None and kand:
            t = nt.nodes.new('ShaderNodeTexImage'); t.image = bpy.data.images.load(kand[0])
            nt.links.new(t.outputs['Color'], bsdf.inputs['Base Color'])
    textur = any(n.type == 'TEX_IMAGE' and n.image for ms in o.material_slots if ms.material for n in ms.material.node_tree.nodes)
    if not textur:
        ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER')
        for poly in me.polygons:
            m = o.material_slots[poly.material_index].material if o.material_slots else None
            bsdf = next((n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None) if m else None
            c = tuple(bsdf.inputs['Base Color'].default_value) if bsdf else (0.6, 0.6, 0.6, 1.0)
            for li in poly.loop_indices: ca.data[li].color = (c[0], c[1], c[2], 1.0)
        # alle Flächen auf ein Material, das die Eckfarben nicht überschreibt (Godot: Farbe × Eckfarbe, figur.gd _paint)
        mat = bpy.data.materials.new('schild')
        me.materials.clear(); me.materials.append(mat)
    # Drehen: Vorderseite nach Blender -Y, oben nach +Z (eigentliche Drehung, nie gespiegelt)
    vi, vs_ = e['vorn']; oi, os_ = e['oben']
    vorn = achse(vi, vs_); oben = achse(oi, os_)
    quer = (-vorn).cross(oben)       # rechtshändig: X = Y × Z mit Y = -vorn
    R = Matrix((quer, -vorn, oben))  # Zeilen: neue X, Y, Z in alten Koordinaten
    assert abs(R.determinant() - 1.0) < 1e-6, 'gespiegelt'
    vs = [v.co.copy() for v in me.vertices]
    # Mitte (Breite, Höhe) aus den Ecken; Rückseite des Bretts in der Mitte (Messung), Griff = Ecken hinter dem Brett in der Mitte
    lo = Vector([min(v[i] for v in vs) for i in range(3)]); hi = Vector([max(v[i] for v in vs) for i in range(3)])
    c = (lo + hi) / 2
    R_ = max((hi - lo)[i] for i in range(3) if i != vi) / 2
    seiten = [i for i in range(3) if i != vi]
    zentral = [v for v in vs if all(abs(v[i] - c[i]) < 0.35 * R_ for i in seiten)]
    hinten = [v for v in zentral if (v[vi] - e['ruecken']) * vs_ < -0.005]     # hinter dem Brett: Griff, Fessel
    g = sum(hinten, Vector()) / len(hinten) if hinten else c.copy()
    ursprung = c.copy()
    for i in seiten: ursprung[i] = g[i]
    ursprung[vi] = e['ruecken']
    # Größe: Höhe (oben) bzw. größte Ausdehnung in der Fläche
    neu = [R @ (v - ursprung) for v in vs]
    h = max(v.z for v in neu) - min(v.z for v in neu); b = max(v.x for v in neu) - min(v.x for v in neu)
    s = e['groesse'] / (h if e['kennung'] == 'shield' else max(h, b))
    me.transform(Matrix.Scale(s, 4) @ R.to_4x4() @ Matrix.Translation(-ursprung))
    me.update()
    o.name = e['kennung']
    neu = [v.co for v in me.vertices]
    lo = [min(v[i] for v in neu) for i in range(3)]; hi = [max(v[i] for v in neu) for i in range(3)]
    dr = sum(len(pg.vertices) - 2 for pg in me.polygons)
    if e.get('sonne'):
        o = sonne(o); me = o.data
        sonne_dr = sum(len(pg.vertices) - 2 for pg in me.polygons) - dr
    bpy.ops.object.select_all(action='DESELECT'); o.select_set(True)
    pfad = os.path.join(OUT, e['kennung'] + '.glb')
    bpy.ops.export_scene.gltf(filepath=pfad, export_format='GLB', use_selection=True, export_yup=True,
                              export_vertex_color='ACTIVE' if not textur or e.get('sonne') else 'NONE')
    # Maße in cm (Blender: X Breite, Y Dicke, vorn negativ, Z Höhe; Ursprung an der Fessel)
    info = dict(nr=e['nr'], paket=e['paket'], datei=os.path.relpath(p, KAUF), dreiecke=dr, textur=textur,
                breite_cm=round((hi[0] - lo[0]) * 100, 1), hoehe_cm=round((hi[2] - lo[2]) * 100, 1),
                vorn_cm=round(-lo[1] * 100, 1), hinten_cm=round(hi[1] * 100, 1),
                oben_cm=round(hi[2] * 100, 1), unten_cm=round(-lo[2] * 100, 1), griff_hinten=len(hinten))
    if e.get('sonne'): info['sonne_dreiecke'] = sonne_dr
    print('SCHILD', e['kennung'], info)
    return info


if __name__ == '__main__':
    alle = {}
    for e in SCHILDE:
        i = bau(e)
        if i: alle[e['kennung']] = i
    json.dump(alle, open(os.path.join(OUT, 'kaufschild-info.json'), 'w'), indent=1, ensure_ascii=False)
    print('KAUFSCHILD OK', len(alle))
