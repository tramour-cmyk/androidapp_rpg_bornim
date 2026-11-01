# 376.1: Probefiguren aus Quaternius' Bausaetzen (Universal Base Characters, Modular Character Outfits - Fantasy;
# frei CC0 1.0, gekauft im privaten Repo bornim-kaufmodelle): Kleidung, Kopf, Haar, Bart zu einer Figur, Volk ueber Knochen
# (Zwerg, Elf, Halbling, Halbork), ohne Bewegungen (die kommen in Godot aus der Universal Animation Library, figurenprobe.gd).
# Aufruf: Q=<ordner mit den Paketen> [KAUF=<ordner>] OUT=<ordner> bl/bin/python -I quaternius.py   -> <OUT>/<kennung>.glb, figuren.json
# Gesucht wird je Datei nach Namen unter Q (frei und gekauft liegen verschieden); fehlt eine gekaufte Datei, nimmt die Figur
# den freien Ersatz (ERSATZ) und figuren.json sagt welchen.
import bpy, os, json, sys
from mathutils import Vector

Q = os.environ.get('Q', os.path.expanduser('~/cc0'))
OUT = os.environ.get('OUT', '/tmp/quaternius')
NUR = [s for s in os.environ.get('FIGUREN', '').split(',') if s]
os.makedirs(OUT, exist_ok=True)

DATEIEN = {}
# KAUF=<ordner mit den entpackten Source-Paketen>: nur Namen, die es frei nicht gibt (Regular-Koepfe, Knight, Noble)
for wurzel in (Q, os.environ.get('KAUF', '')):
    if not wurzel: continue
    neu = {}
    for wo, _, fs in sorted(os.walk(wurzel)):
        for f in sorted(fs):
            if f.endswith('.gltf') and f[:-5] not in DATEIEN: neu.setdefault(f[:-5], os.path.join(wo, f))
    DATEIEN.update(neu)

# gekauft -> frei: Regular-Koepfe und Knight gibt es nur gekauft
ERSATZ = {'Regular_Male_OnlyHead': 'Superhero_Male_FullBody', 'Regular_Female_OnlyHead': 'Superhero_Female_FullBody',
          'Male_Knight': 'Male_Ranger', 'Female_Knight': 'Female_Ranger', 'Male_Noble': 'Male_Peasant', 'Female_Noble': 'Female_Peasant',
          'Male_Knight_Cloth': 'Male_Peasant'}

# Volk: Groesse je Knochen (Laenge entlang des Knochens, quer), dazu Hauttoenung; Mensch = 1
# (Helfer 13:45: Zwerg nur kleiner Bauer, Halbork ohne Gruen: kraeftiger quer, Haut aus der Textur getoent)
VOLK = {
    'mensch':   {},
    'zwerg':    {'ganz': 0.8, 'beine': (0.7, 1.2), 'rumpf': (0.92, 1.3), 'arme': (0.88, 1.25), 'kopf': 1.12},
    'elf':      {'ganz': 1.04, 'beine': (1.08, 0.9), 'rumpf': (1.04, 0.88), 'arme': (1.04, 0.88), 'kopf': 0.95},
    'halbling': {'ganz': 0.6, 'beine': (0.88, 1.08), 'rumpf': (0.95, 1.12), 'kopf': 1.16},
    'halbork':  {'ganz': 1.07, 'beine': (1.0, 1.18), 'rumpf': (1.0, 1.3), 'arme': (1.0, 1.25), 'kopf': 1.02, 'haut': (0.62, 0.80, 0.52)},
}
BEINE = ['thigh_l', 'thigh_r']   # Kinder erben die Groesse (Wade mit)

# Haarfarben (die Haarbilder sind hellgrau zum Toenen; Helfer 13:45: fuenf Figuren mit gleichem weissen Haar und Bart)
HAAR = {'dunkel': (0.16, 0.11, 0.08), 'braun': (0.34, 0.22, 0.13), 'kastanie': (0.45, 0.22, 0.12), 'rot': (0.62, 0.26, 0.10),
        'blond': (0.86, 0.72, 0.45), 'schwarz': (0.07, 0.06, 0.06), 'grau': (0.55, 0.53, 0.50)}
# Teile ohne eigene Farbe (Helfer: Schulterstueck des Waldlaeufers weiss): Netz -> Farbe auf die Textur
LEDER = (0.42, 0.30, 0.20)
# Ritterplatten (Helfer Kaufteile: grauweiss, ueberstrahlt; Godot liest nur das Bild, kein Metall): Stahl abgedunkelt
STAHL = (0.55, 0.56, 0.60)

FIGUREN = {
    'q_held':     {'kleid': 'Male_Knight',    'kopf': 'Regular_Male_OnlyHead',   'haar': 'Hair_SimpleParted', 'bart': 'Hair_Beard', 'farbe': 'braun', 'ohne': ['Hood', 'Head_Armet']},
    'q_bauer':    {'kleid': 'Male_Peasant',   'kopf': 'Regular_Male_OnlyHead',   'haar': 'Hair_Buzzed', 'bart': 'Hair_Beard', 'farbe': 'dunkel'},
    'q_baeuerin': {'kleid': 'Female_Peasant', 'kopf': 'Regular_Female_OnlyHead', 'haar': 'Hair_Buns', 'brauen': 'Eyebrows_Female', 'farbe': 'kastanie'},
    'q_zwerg':    {'kleid': 'Male_Noble',     'kopf': 'Regular_Male_OnlyHead',   'haar': 'Hair_Buzzed', 'bart': 'Hair_Beard', 'farbe': 'rot', 'volk': 'zwerg', 'ohne': ['Crown']},
    'q_elf':      {'kleid': 'Female_Ranger',  'kopf': 'Regular_Female_OnlyHead', 'haar': 'Hair_Ponytail', 'brauen': 'Eyebrows_Female', 'farbe': 'blond', 'volk': 'elf', 'ohne': ['Hood']},
    'q_halbling': {'kleid': 'Male_Peasant',   'kopf': 'Regular_Male_OnlyHead',   'haar': 'Hair_SimpleParted', 'farbe': 'braun', 'volk': 'halbling'},
    'q_halbork':  {'kleid': 'Male_Knight_Cloth', 'kopf': 'Regular_Male_OnlyHead',   'haar': 'Hair_Buzzed', 'farbe': 'schwarz', 'volk': 'halbork', 'ohne': ['Head_Horns']},
}
KOPF_KNOCHEN = {'Head', 'neck_01', 'neck_02'}


def datei(n):
    if n in DATEIEN: return n, DATEIEN[n]
    e = ERSATZ.get(n)
    if e and e in DATEIEN: return e, DATEIEN[e]
    return None, None


def importiere(p):
    vorher = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=p)
    neu = [o for o in bpy.data.objects if o not in vorher]
    for o in [o for o in neu if o.type == 'MESH' and o.name.startswith('Icosphere')]:
        neu.remove(o); bpy.data.objects.remove(o)
    return neu


def an_geruest(objs, arm, versatz=Vector()):
    # Netze eines fremden Imports an unser Geruest; Versatz: deren Kopfknochen auf unseren
    for o in objs:
        if o.type != 'MESH': continue
        mw = o.matrix_world.copy()
        o.parent = arm
        o.matrix_world = mw
        for v in o.data.vertices: v.co = o.matrix_world.inverted() @ (o.matrix_world @ v.co + versatz)
        if not o.vertex_groups:   # Haar „Rigged to Head Bone“ ohne Gewichte: ganz an den Kopf
            vg = o.vertex_groups.new(name='Head'); vg.add(range(len(o.data.vertices)), 1.0, 'REPLACE')
        if not any(m.type == 'ARMATURE' for m in o.modifiers): o.modifiers.new('Armature', 'ARMATURE')
        for m in o.modifiers:
            if m.type == 'ARMATURE': m.object = arm
    for o in objs:
        if o.type == 'ARMATURE': bpy.data.objects.remove(o)


def kopf_pos(arm):
    return arm.matrix_world @ arm.data.bones['Head'].head_local


def nur_kopf(o):
    # Superhero_*_FullBody (frei): nur Ecken, deren staerkstes Gewicht an Kopf oder Hals haengt
    g = {vg.index: vg.name for vg in o.vertex_groups}
    weg = []
    for v in o.data.vertices:
        if not v.groups: weg.append(v.index); continue
        st = max(v.groups, key=lambda x: x.weight)
        if g.get(st.group) not in KOPF_KNOCHEN: weg.append(v.index)
    import bmesh
    bm = bmesh.new(); bm.from_mesh(o.data)
    bm.verts.ensure_lookup_table()
    bmesh.ops.delete(bm, geom=[bm.verts[i] for i in weg], context='VERTS')
    bm.to_mesh(o.data); bm.free()


def basisbild(m):
    bsdf = next((n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None) if m and m.node_tree else None
    n = bsdf.inputs['Base Color'].links[0].from_node if bsdf and bsdf.inputs['Base Color'].links else None
    while n is not None and n.type != 'TEX_IMAGE':   # ueber MIX (Eckfarben) zum Bild
        n = next((i.links[0].from_node for i in n.inputs if i.links), None)
    return n


KOPIEN = {}
def toene(o, wahl, farbe):
    # Materialien des Netzes, fuer die wahl(name) gilt, bekommen eine Kopie mit getoentem Bild (Godot liest nur das Bild, gebiet.gd male)
    import numpy as np
    for i, m in enumerate(o.data.materials):
        if not m or not wahl(m.name): continue
        key = (m.name, farbe)
        if key not in KOPIEN:
            tn0 = basisbild(m)
            if not tn0 or not tn0.image: continue
            m2 = m.copy(); m2.name = m.name + '_t%d' % len(KOPIEN)
            tn = basisbild(m2)
            im = tn.image.copy(); im.name = tn.image.name + '_t%d' % len(KOPIEN)
            px = np.empty(len(im.pixels), dtype=np.float32); im.pixels.foreach_get(px)
            px = px.reshape(-1, 4); px[:, :3] *= np.array(farbe, dtype=np.float32)
            im.pixels.foreach_set(px.ravel()); im.update(); im.pack()
            tn.image = im
            KOPIEN[key] = m2
        o.data.materials[i] = KOPIEN[key]


def volk(arm, netze, v):
    if not v: return
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    def gr(namen, s):
        if isinstance(s, (int, float)): s = (s, s)
        for n in namen:
            pb = arm.pose.bones.get(n)
            if pb: pb.scale = (s[1], s[0], s[1])   # Blender: Knochen laeuft entlang Y
    if 'beine' in v: gr(BEINE, v['beine'])
    if 'rumpf' in v: gr(['spine_01'], v['rumpf'])
    if 'arme' in v: gr(['upperarm_l', 'upperarm_r'], v['arme'])
    if 'kopf' in v:   # der Hals erbt die Groesse des Rumpfs: herausrechnen
        r = v.get('rumpf', (1, 1))
        gr(['neck_01'], (v['kopf'] / r[0], v['kopf'] / r[1]))
    bpy.ops.object.mode_set(mode='OBJECT')
    # Form backen, Pose als Ruhe
    for o in netze:
        if o.type != 'MESH': continue
        bpy.context.view_layer.objects.active = o
        for m in list(o.modifiers):
            if m.type == 'ARMATURE': bpy.ops.object.modifier_apply(modifier=m.name)
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode='POSE')
    bpy.ops.pose.armature_apply(selected=False)
    bpy.ops.object.mode_set(mode='OBJECT')
    for o in netze:
        if o.type != 'MESH': continue
        m = o.modifiers.new('Armature', 'ARMATURE'); m.object = arm
    if v.get('ganz', 1.0) != 1.0:
        arm.scale = [s * v['ganz'] for s in arm.scale]
        bpy.ops.object.select_all(action='DESELECT')
        for o in [arm] + [o for o in netze if o.type == 'MESH']: o.select_set(True)
        bpy.context.view_layer.objects.active = arm
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)


def baue(kennung, f):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    info = {'kennung': kennung, 'ersatz': {}}
    kn, kp = datei(f['kleid'])
    if not kp: print('FEHLT', kennung, f['kleid']); return None
    if kn != f['kleid']: info['ersatz'][f['kleid']] = kn
    kleid = importiere(kp)
    arm = next(o for o in kleid if o.type == 'ARMATURE')
    arm.name = 'Armature'
    netze = [o for o in kleid if o.type == 'MESH']
    for teil in ('kopf', 'haar', 'bart', 'brauen'):
        if teil not in f: continue
        n, p = datei(f[teil])
        if not p: info['ersatz'][f[teil]] = None; continue
        if n != f[teil]: info['ersatz'][f[teil]] = n
        objs = importiere(p)
        a2 = next((o for o in objs if o.type == 'ARMATURE'), None)
        vs = (kopf_pos(arm) - kopf_pos(a2)) if a2 and 'Head' in a2.data.bones else Vector()
        if teil == 'kopf' and n.endswith('FullBody'):
            for o in objs:
                if o.type == 'MESH' and o.name not in ('Eyes', 'Eyebrows'): nur_kopf(o)
            if 'brauen' in f:   # eigene Brauen statt der des Ersatzkopfs
                for o in [o for o in objs if o.type == 'MESH' and o.name == 'Eyebrows']: objs.remove(o); bpy.data.objects.remove(o)
        neu = [o for o in objs if o.type == 'MESH']
        an_geruest(objs, arm, vs)
        netze += neu
    for o in [o for o in netze if any(w in o.name for w in f.get('ohne', []))]:
        netze.remove(o); bpy.data.objects.remove(o)
    v = VOLK.get(f.get('volk', 'mensch'), {})
    volk(arm, netze, v)
    KOPIEN.clear()
    hf = HAAR[f.get('farbe', 'braun')]
    for o in netze:
        if o.name.startswith(('Hair_', 'Eyebrows')): toene(o, lambda n: True, hf)
        else: toene(o, lambda n: n.startswith('MI_Hair'), hf)   # Brauen im Kopf des Ersatzes
        if 'Pauldron' in o.name: toene(o, lambda n: True, LEDER)
        elif o.name.startswith('Male_Knight') or o.name.startswith('Female_Knight'): toene(o, lambda n: n.startswith('MI_Knight'), STAHL)
        if 'haut' in v: toene(o, lambda n: 'Regular' in n or 'Superhero' in n, v['haut'])
    dr = 0
    for o in netze:
        o.data.calc_loop_triangles(); dr += len(o.data.loop_triangles)
    bpy.context.view_layer.update()
    hoch = max((o.matrix_world @ Vector(c)).z for o in netze for c in o.bound_box)
    rumpf = [o for o in netze if o.name.endswith('_Body')]
    breit = max((o.matrix_world @ Vector(c)).x for o in rumpf for c in o.bound_box) - min((o.matrix_world @ Vector(c)).x for o in rumpf for c in o.bound_box) if rumpf else 0
    info.update({'dreiecke': dr, 'hoehe_m': round(hoch, 3), 'rumpf_breit_m': round(breit, 3), 'netze': sorted(o.name for o in netze), 'volk': f.get('volk', 'mensch')})
    p = os.path.join(OUT, kennung + '.glb')
    bpy.ops.export_scene.gltf(filepath=p, export_format='GLB', export_animations=False, export_apply=False, export_skins=True)
    print('FIGUR', kennung, dr, 'Dreiecke', round(hoch, 2), 'm hoch', round(breit, 2), 'm Rumpf', info['ersatz'])
    return info


if __name__ == '__main__':   # kauf_kleid.py holt nur die Hilfen
    alle = {}
    for k, f in FIGUREN.items():
        if NUR and k not in NUR: continue
        i = baue(k, f)
        if i: alle[k] = i
    json.dump(alle, open(os.path.join(OUT, 'figuren.json'), 'w'), indent=1, ensure_ascii=False)
    print('QUATERNIUS OK', len(alle))
