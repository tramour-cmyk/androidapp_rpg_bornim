# 458.3 Gegenstandskatalog, Waffen (Chef 01.11., 13:1x, Archiv 458; Netzliste LISTE-NETZE.md 455.2): fuer Streitkolben, Streitaxt,
# Morgenstern, Kriegshammer, Zauberstab, Zweihaender, Grossaxt, Zweihandhammer, Hellebarde, Magierstab, Langbogen, Armbrust, Foliant,
# Fackel fehlt das Netz im Spiel. 408 (Chef 29.10., 11:19–11:26): passen mehrere Stuecke aus dem Bestand, alle drehend in einem Film,
# der Chef waehlt. Wie schilde_bestand.py (406, Jerry): jede Waffe der Waffenpakete (LISTE-BESTAND „Waffen und Schilde“: Omie, Anker,
# Avramania; Schilde schon gewaehlt, 406) unveraendert bis auf Lage und Groesse: Mitte in den Ursprung, laengste Achse senkrecht,
# Laenge 1 m (nur zum Ansehen; die echte Laenge steht in waffen.json), Texturen eingebettet.
# Aufruf: KAUF=<kaufpakete> ZIEL=<ordner> bl/bin/python -I waffen_bestand.py -> <ZIEL>/<kennung>.glb, waffen.json, dateien.txt
import bpy, os, json, glob, re
from mathutils import Vector, Matrix

KAUF = os.environ.get('KAUF', os.path.expanduser('~/kauf'))
ZIEL = os.environ.get('ZIEL', os.path.expanduser('~/waffen'))
os.makedirs(ZIEL, exist_ok=True)
PAKETE = [('Omie', 'Medieval.Weapon.Pack.Godot', '.obj'), ('Anker', 'Low.Poly.Medieval.Weapons', '.fbx'),
          ('Avramania', 'Weapons_Shields_Free', '.glb')]
# keine Waffe fuer die Hand oder schon gewaehlt (Schilde 406)
OHNE = re.compile(r'shield|buckler|arrow|bolt|quiver|potion|flask|bottle|catapult|ballista|trebuchet|siege|ram_|cart|wagon|'
                  r'pitchfork|scythe|sickle|broom|lute|jug|mug|stand|rack|sheath|scabbard|coin|tower|cannon|wheel|barrel|crate', re.I)
# Waffenart je Name (erste passende), nur zum Ordnen im Film
ARTEN = [('Foliant', r'book|tome'), ('Fackel', r'torch'), ('Armbrust', r'crossbow'), ('Bogen', r'bow'), ('Stab', r'staff|wand'),
         ('Hellebarde', r'halberd|bardiche|poleaxe|glaive|trident|lance|pike|spear|javelin'), ('Hammer', r'hammer|maul|mallet|sledge'),
         ('Kolben', r'mace|morning|flail|club|star'), ('Axt', r'axe|hatchet|pick'),
         ('Schwert', r'sword|claymore|falchion|sabre|saber|scimitar|katana|rapier|blade|knife|dagger|cleaver')]
dateien = []
for paket, ordner, endung in PAKETE:
    wurzeln = [d for d in glob.glob(os.path.join(KAUF, '**', ordner + '*'), recursive=True) if os.path.isdir(d)]
    fs = sorted({f for w in wurzeln for f in glob.glob(os.path.join(w, '**', '*' + endung), recursive=True)})
    print('PAKET', paket, len(fs), 'Dateien', endung, wurzeln[:1])
    for f in fs: dateien.append((paket, f))
open(os.path.join(ZIEL, 'dateien.txt'), 'w').write('\n'.join('%s\t%s' % (p, os.path.relpath(f, KAUF)) for p, f in dateien) + '\n')


def art(stamm):
    for a, m in ARTEN:
        if re.search(m, stamm, re.I): return a
    return 'Sonst'


def bild_dazu(p, nt, bsdf):
    # Omie: obj ohne Bild in der mtl; TGA mit dem Namen der Waffe daneben (sonst das erste BaseColor-Bild im Ordner)
    stamm = re.sub(r'^sm_', '', os.path.splitext(os.path.basename(p))[0].lower())
    kand = sorted(glob.glob(os.path.join(os.path.dirname(p), '**', '*.tga'), recursive=True) +
                  glob.glob(os.path.join(os.path.dirname(p), '**', '*.png'), recursive=True))
    farbe = [k for k in kand if re.search(r'base.?color|albedo|diffuse', os.path.basename(k), re.I)] or kand
    genau = [k for k in farbe if stamm in os.path.basename(k).lower()]
    wahl = (genau or farbe or [None])[0]
    if wahl:
        t = nt.nodes.new('ShaderNodeTexImage'); t.image = bpy.data.images.load(wahl)
        nt.links.new(t.outputs['Color'], bsdf.inputs['Base Color'])
    return wahl


info = []
for paket, p in dateien:
    stamm = os.path.splitext(os.path.basename(p))[0]
    if OHNE.search(stamm): continue
    bpy.ops.wm.read_factory_settings(use_empty=True)
    try:
        if p.endswith('.obj'): bpy.ops.wm.obj_import(filepath=p)
        elif p.endswith('.fbx'): bpy.ops.import_scene.fbx(filepath=p)
        else: bpy.ops.import_scene.gltf(filepath=p)
    except Exception as e:
        print('FEHLT Import', paket, stamm, e); continue
    netze = [o for o in bpy.data.objects if o.type == 'MESH']
    if not netze: print('FEHLT Netz', paket, stamm); continue
    for o in [o for o in bpy.data.objects if o.type != 'MESH']:
        bpy.data.objects.remove(o)
    bild = None
    for o in netze:
        for ms in o.material_slots:
            m = ms.material
            if m is None: continue
            m.use_nodes = True
            nt = m.node_tree
            bsdf = next((n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED'), None)
            hat = any(n.type == 'TEX_IMAGE' and n.image and n.image.has_data for n in nt.nodes)
            if hat or bsdf is None or paket != 'Omie': continue
            bild = bild_dazu(p, nt, bsdf)
    bpy.ops.object.select_all(action='DESELECT')
    for o in netze: o.select_set(True)
    bpy.context.view_layer.objects.active = netze[0]
    if len(netze) > 1: bpy.ops.object.join()
    o = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    vs = [v.co.copy() for v in o.data.vertices]
    lo = Vector((min(v.x for v in vs), min(v.y for v in vs), min(v.z for v in vs)))
    hi = Vector((max(v.x for v in vs), max(v.y for v in vs), max(v.z for v in vs)))
    ausd = hi - lo
    lang = max(range(3), key=lambda i: ausd[i])
    R = Matrix.Identity(4)
    if lang == 0: R = Matrix.Rotation(1.5708, 4, 'Y')     # x -> z
    elif lang == 1: R = Matrix.Rotation(1.5708, 4, 'X')   # y -> z
    o.data.transform(R @ Matrix.Translation(-(lo + hi) / 2))
    laenge = max(ausd)
    o.data.transform(Matrix.Scale(1.0 / max(laenge, 1e-6), 4))
    k = '%s_%s' % (paket.lower(), re.sub(r'[^a-z0-9]+', '_', stamm.lower()).strip('_'))
    o.name = k
    dr = sum(len(pg.vertices) - 2 for pg in o.data.polygons)
    bpy.ops.export_scene.gltf(filepath=os.path.join(ZIEL, k + '.glb'), export_format='GLB', use_selection=True)
    info.append({'kennung': k, 'paket': paket, 'name': stamm, 'art': art(stamm), 'datei': os.path.relpath(p, KAUF), 'dreiecke': dr,
                 'laenge_roh': round(laenge, 3), 'bild': os.path.basename(bild) if bild else None})
    print('WAFFE', k, art(stamm), dr, 'Dreiecke, Laenge roh', round(laenge, 3), 'Bild', os.path.basename(bild) if bild else '-')
reihe = [a for a, _ in ARTEN] + ['Sonst']
info.sort(key=lambda e: (reihe.index(e['art']), e['paket'], e['name']))
json.dump(info, open(os.path.join(ZIEL, 'waffen.json'), 'w'), indent=1, ensure_ascii=False)
print('WAFFEN OK', len(info))
