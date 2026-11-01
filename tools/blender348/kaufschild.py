# 406 (Chef 31.10., 23:22 an Sokrates, Archiv: „Schild 2 für ehemaligen Kleriker (neues System!!!) und 15 für Krieger (neues
# System)“): die zwei gewählten Schilde aus den Kaufpaketen als Schilde des Spiels, in der Form von waffen.py (Vorderseite nach
# glTF +Z, Ursprung an der Fessel auf der Rückseite, Y oben), damit figur.gd (Kampfort, linker Unterarm) und heldfigur.gd (Rücken
# unterwegs) sie ohne Änderung tragen:
#   round_shield  (Kleriker) = Nr. 2 des Films ansehen/406-schilde: Omie Kite-Schild (sm_shield_kite.obj)
#   shield        (Kämpfer)  = Nr. 15: PolyMech open_sides_round_Shield.fbx
# Lage und Größe wie im Film (schilde_bestand.py: dünnste Richtung = Dicke, längere der anderen nach oben, Vorderseite zur Kamera,
# Kite-Spitze unten; Helfer am Standbild 01.11., 11:0x), größte Ausdehnung 0,60 m wie der Rundschild (Blatt 406: „im Spiel bekommt
# der gewählte die Größe des Rundschilds“). Farbe: Omie aus der eigenen Textur (BaseColor, auf 512² verkleinert); PolyMech hat keine
# Textur (Pfad im Paket absolut), seine Grundfarbe je Material geht als Eckfarbe mit, wie bei waffen.py (Shader: Textur × Eckfarbe).
# Gekauft (Paket privat), also nur verschlüsselt ins APK (kauf.txt). Ergebnis: <OUT>/round_shield.glb, <OUT>/shield.glb, kaufschild.json
# Aufruf: KAUF=<kaufpakete> OUT=<ordner> bl/bin/python -I kaufschild.py
import bpy, os, json, glob
from mathutils import Vector, Matrix

KAUF = os.environ.get('KAUF', os.path.expanduser('~/kauf'))
OUT = os.environ.get('OUT', os.path.expanduser('~/kaufschild'))
os.makedirs(OUT, exist_ok=True)
GROESSE = 0.60
TEX = 512
LISTE = [('round_shield', 'Omie', 'sm_shield_kite.obj', 2), ('shield', 'PolyMech', 'open_sides_round_Shield.fbx', 15)]


def finde(muster):
    f = sorted(glob.glob(os.path.join(KAUF, '**', muster), recursive=True))
    return f[0] if f else None


def lade(p, paket):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    if p.endswith('.obj'): bpy.ops.wm.obj_import(filepath=p)
    elif p.endswith('.fbx'): bpy.ops.import_scene.fbx(filepath=p)
    else: bpy.ops.import_scene.gltf(filepath=p)
    for o in [o for o in bpy.data.objects if o.type != 'MESH']:
        bpy.data.objects.remove(o)
    netze = [o for o in bpy.data.objects if o.type == 'MESH']
    farben = {}
    for o in netze:     # ohne Material (obj ohne mtl) bekäme der Schild keine Textur
        if not o.material_slots or all(ms.material is None for ms in o.material_slots):
            o.data.materials.clear(); o.data.materials.append(bpy.data.materials.new(paket.lower() + '_schild'))
    for o in netze:
        for ms in o.material_slots:
            m = ms.material
            if m is None: continue
            m.use_nodes = True
            nt = m.node_tree
            bsdf = next((n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED'), None)
            for n in [n for n in nt.nodes if n.type == 'TEX_IMAGE' and not (n.image and n.image.has_data)]:
                nt.nodes.remove(n)     # PolyMech: Bild mit absolutem Pfad, nicht da
            if bsdf is None: continue
            hat = any(l.from_node.type == 'TEX_IMAGE' for l in bsdf.inputs['Base Color'].links)
            if not hat:
                kand = sorted(glob.glob(os.path.join(os.path.dirname(p), '*BaseColor*.tga')))     # Omie: TGA neben dem obj
                if kand:
                    # die passende zuerst (Name mit „kite“, sonst „shield“); schilde_bestand.py nahm die erste im Ordner
                    film = kand[0]
                    kand.sort(key=lambda f: (0 if 'kite' in os.path.basename(f).lower() else 1 if 'shield' in os.path.basename(f).lower() else 2, f))
                    if kand[0] != film: print('FILMTEXTUR', paket, os.path.basename(film), 'statt', os.path.basename(kand[0]))
                    t = nt.nodes.new('ShaderNodeTexImage'); t.image = bpy.data.images.load(kand[0])
                    nt.links.new(t.outputs['Color'], bsdf.inputs['Base Color'])
                    hat = True
            for l in bsdf.inputs['Base Color'].links:
                img = l.from_node.image if l.from_node.type == 'TEX_IMAGE' else None
                if img and max(img.size) > TEX:
                    img.scale(TEX, TEX)
                if img:
                    img.pack()
                    print('TEXTUR', paket, m.name, img.name, tuple(img.size))
            if not hat:
                farben[m.name] = tuple(bsdf.inputs['Base Color'].default_value)
                print('FARBE', paket, m.name, ['%.2f' % c for c in farben[m.name][:3]])
            # Metall- und Rauheitskanäle bleiben außen vor: der Toon-Shader liest nur Farbe (und Textur)
            for k in ('Normal',):
                for l in list(bsdf.inputs[k].links): nt.links.remove(l)
    bpy.ops.object.select_all(action='DESELECT')
    for o in netze: o.select_set(True)
    bpy.context.view_layer.objects.active = netze[0]
    if len(netze) > 1: bpy.ops.object.join()
    o = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return o, farben


def lege(o):
    # wie schilde_bestand.py (so stand er im Film: Vorderseite zur Kamera, Kite-Spitze unten)
    vs = [o.matrix_world @ v.co for v in o.data.vertices]
    lo = Vector((min(c.x for c in vs), min(c.y for c in vs), min(c.z for c in vs)))
    hi = Vector((max(c.x for c in vs), max(c.y for c in vs), max(c.z for c in vs)))
    ausd = hi - lo
    achsen = sorted(range(3), key=lambda i: ausd[i])
    dick = achsen[0]
    R = Matrix.Identity(3)
    if dick != 1:
        R = Matrix.Rotation(1.5708, 3, 'Z') if dick == 0 else Matrix.Rotation(1.5708, 3, 'X')
    o.data.transform((R.to_4x4() @ Matrix.Translation(-(lo + hi) / 2)))
    vs = [v.co for v in o.data.vertices]
    h = max(v.z for v in vs) - min(v.z for v in vs); b = max(v.x for v in vs) - min(v.x for v in vs)
    s = GROESSE / max(h, b, 1e-6)
    o.data.transform(Matrix.Scale(s, 4))
    vs = [v.co for v in o.data.vertices]
    # Fessel: Ursprung auf der Rückseite des Bretts (glTF +Z vorn = Blender -Y, hinten +Y). Rückseite = hinterste Punkte im Ring
    # zwischen 30 und 60 % des Halbmessers (ohne Griff in der Mitte, ohne Randwulst)
    r = GROESSE / 2
    ring = [v.y for v in vs if 0.3 * r < (v.x ** 2 + v.z ** 2) ** 0.5 < 0.6 * r]
    ring.sort()
    hinten = ring[int(len(ring) * 0.9)] if ring else max(v.y for v in vs)
    vorn = min(v.y for v in vs)
    o.data.transform(Matrix.Translation((0, -hinten, 0)))
    vs = [v.co for v in o.data.vertices]
    mass = dict(hoehe=round(max(v.z for v in vs) - min(v.z for v in vs), 3), breite=round(max(v.x for v in vs) - min(v.x for v in vs), 3),
                dicke_brett=round(hinten - vorn, 3), hinter_fessel=round(max(v.y for v in vs), 3))
    return mass


def eckfarben(o, farben):
    if not farben: return
    me = o.data
    ca = me.color_attributes.new('albedo', 'FLOAT_COLOR', 'CORNER')
    for poly in me.polygons:
        m = me.materials[poly.material_index] if poly.material_index < len(me.materials) else None
        c = farben.get(m.name, (1, 1, 1, 1)) if m else (1, 1, 1, 1)
        for li in poly.loop_indices:
            ca.data[li].color = (c[0], c[1], c[2], 1.0)     # Alpha 1: kein Glimmen (kampf/toon.gdshader)
    for m in me.materials:
        if m and m.name in farben:     # Grundfarbe weiß, die Farbe steckt in den Ecken
            bsdf = next((n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None)
            if bsdf: bsdf.inputs['Base Color'].default_value = (1, 1, 1, 1)


info = {}
for kenn, paket, datei, nr in LISTE:
    p = finde(datei)
    if not p:
        print('FEHLT', kenn, paket, datei); continue
    o, farben = lade(p, paket)
    mass = lege(o)
    eckfarben(o, farben)
    o.name = kenn
    dr = sum(len(pg.vertices) - 2 for pg in o.data.polygons)
    bpy.ops.object.select_all(action='DESELECT'); o.select_set(True)
    ziel = os.path.join(OUT, kenn + '.glb')
    bpy.ops.export_scene.gltf(filepath=ziel, export_format='GLB', use_selection=True, export_yup=True,
                              export_vertex_color='ACTIVE' if farben else 'NONE', export_image_format='JPEG')
    info[kenn] = dict(nr=nr, paket=paket, datei=os.path.relpath(p, KAUF), dreiecke=dr, **mass)
    print('GLB', kenn, nr, paket, dr, 'Dreiecke', mass, os.path.getsize(ziel), 'Bytes')
json.dump(info, open(os.path.join(OUT, 'kaufschild.json'), 'w'), indent=1, ensure_ascii=False)
print('KAUFSCHILD FERTIG', len(info), 'von', len(LISTE))
