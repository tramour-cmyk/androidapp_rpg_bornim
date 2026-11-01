# 406 (Chef 29.10., 11:13 über Sokrates, Archiv 408): „nicht weiterbauen; erst alle Schilde der Bibliothek drehend in einem Film
# vorlegen, Chef wählt.“ Holt jeden Schild aus den Kaufpaketen (LISTE-BESTAND „Waffen und Schilde“: Omie, Anker, Avramania,
# PolyMech), unveraendert bis auf Lage und Groesse: Mitte in den Ursprung, Vorderseite nach +Y (glTF: vorn +Z), Hoehe auf 0,6 m;
# Texturen eingebettet (PolyMech: absoluter Pfad, hier aus textures/). Ergebnis je Schild ein glb fuer den Drehfilm in Godot
# (tests/schilde_film.gd, im Spielstil gezeichnet) und schilde.json (Name, Paket, Dreiecke).
# Aufruf: KAUF=<kaufpakete> ZIEL=<ordner> bl/bin/python -I schilde_bestand.py
import bpy, os, sys, json, glob
from mathutils import Vector, Matrix

KAUF = os.environ.get('KAUF', os.path.expanduser('~/kauf'))
ZIEL = os.environ.get('ZIEL', os.path.expanduser('~/schilde'))
os.makedirs(ZIEL, exist_ok=True)


def finde(muster):
    f = sorted(glob.glob(os.path.join(KAUF, '**', muster), recursive=True))
    return f[0] if f else None


# (Kennung, Paket, Datei)
LISTE = [('omie_rund', 'Omie', 'sm_round_shield.obj'), ('omie_kite', 'Omie', 'sm_shield_kite.obj'),
         ('omie_faust', 'Omie', 'sm_buckler_shield.obj')]
LISTE += [('anker_' + c.lower(), 'Anker', 'Shield %s.fbx' % c) for c in 'ABCDEF']
LISTE += [('avra_rund', 'Avramania', 'mdvl_weapons_shield_round_01.glb'), ('avra_holz', 'Avramania', 'mdvl_weapons_shield_wooden_01.glb'),
          ('avra_faust', 'Avramania', 'mdvl_weapons_buckler_01.glb')]
LISTE += [('poly_' + n.lower().replace(' ', '_'), 'PolyMech', n + '.fbx') for n in
          ['kite_Shield', 'open_top_round_Shield', 'open_sides_round_Shield', 'round wooden', 'round_metal_frame',
           'woden_shield_metal_frame', 'Iron_Long_shield', 'Lionheart_Long_shield', 'Lionheart_small']]
HOEHE = 0.6
info = []
for kenn, paket, datei in LISTE:
    p = finde(datei)
    if not p: print('FEHLT', kenn, datei); continue
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if p.endswith('.obj'): bpy.ops.wm.obj_import(filepath=p)
    elif p.endswith('.fbx'): bpy.ops.import_scene.fbx(filepath=p)
    else: bpy.ops.import_scene.gltf(filepath=p)
    netze = [o for o in bpy.data.objects if o.type == 'MESH']
    for o in [o for o in bpy.data.objects if o.type not in ('MESH',)]:
        bpy.data.objects.remove(o)
    # Texturen: Omie (obj ohne mtl-Bild) aus den TGA daneben, PolyMech aus textures/
    for o in netze:
        for ms in o.material_slots:
            m = ms.material
            if m is None: continue
            m.use_nodes = True
            nt = m.node_tree
            bsdf = next((n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED'), None)
            hat = any(n.type == 'TEX_IMAGE' and n.image and n.image.has_data for n in nt.nodes)
            if hat or bsdf is None: continue
            kand = sorted(glob.glob(os.path.join(os.path.dirname(p), '*BaseColor*.tga'))) or \
                (sorted(glob.glob(os.path.join(os.path.dirname(p), 'textures', '*.png'))) if paket == 'PolyMech' and 'Lionheart' in datei else [])
            if kand:
                t = nt.nodes.new('ShaderNodeTexImage'); t.image = bpy.data.images.load(kand[0])
                nt.links.new(t.outputs['Color'], bsdf.inputs['Base Color'])
    bpy.ops.object.select_all(action='DESELECT')
    for o in netze: o.select_set(True)
    bpy.context.view_layer.objects.active = netze[0]
    if len(netze) > 1: bpy.ops.object.join()
    o = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    ecken = [o.matrix_world @ Vector(c) for c in o.bound_box]
    lo = Vector((min(c.x for c in ecken), min(c.y for c in ecken), min(c.z for c in ecken)))
    hi = Vector((max(c.x for c in ecken), max(c.y for c in ecken), max(c.z for c in ecken)))
    ausd = hi - lo
    # duennste Richtung = Dicke (Blickrichtung); die groessere der beiden anderen nach oben (Z), es sei denn Z ist schon flach-hoch
    achsen = sorted(range(3), key=lambda i: ausd[i])
    dick, hoch = achsen[0], (2 if achsen[0] != 2 else achsen[2])
    R = Matrix.Identity(3)
    if dick != 1:     # Dicke auf Y (Blender: vorn -Y)
        R = Matrix.Rotation(1.5708, 3, 'Z') if dick == 0 else Matrix.Rotation(1.5708, 3, 'X')
    o.data.transform((R.to_4x4() @ Matrix.Translation(-(lo + hi) / 2)))
    # Groesse aus den Ecken selbst (Lauf 1: bound_box war nach transform noch alt, drei runde PolyMech-Schilde 8-fach)
    vs = [v.co for v in o.data.vertices]
    h = max(v.z for v in vs) - min(v.z for v in vs); b_ = max(v.x for v in vs) - min(v.x for v in vs)
    s = HOEHE / max(h, b_, 1e-6)
    o.data.transform(Matrix.Scale(s, 4))
    o.name = kenn
    dr = sum(len(pg.vertices) - 2 for pg in o.data.polygons)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, kenn + '.glb'), export_format='GLB', use_selection=True)
    info.append({'kennung': kenn, 'paket': paket, 'datei': os.path.relpath(p, KAUF), 'dreiecke': dr})
    print('SCHILD', kenn, paket, dr, 'Dreiecke')
json.dump(info, open(os.path.join(ZIEL, 'schilde.json'), 'w'), indent=1, ensure_ascii=False)
print('SCHILDE OK', len(info))
