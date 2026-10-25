# 348.12 Probe (Chef 25.10., 21:36): fertiger CC0-Grundkoerper (Quaternius) in unserem Look neben Held r5, kein Ersatz.
# Quellen (alle CC0 1.0, Lizenzdatei im Paket; Urheber Quaternius, quaternius.com / quaternius.itch.io), laedt cc0_laden.sh:
#   Universal Base Characters [Standard]   – Kopf, Augen, Brauen (Superhero_Male_FullBody)
#   Modular Character Outfits – Fantasy [Standard] – Ausruestung (Male_Ranger oder Male_Peasant, AUSRUESTUNG=)
#   Universal Animation Library [Standard] – Bewegungen auf demselben Skelett (UAL1_Standard.glb, ohne Wurzelbewegung)
# Umbau hier: Kopf aus dem Grundkoerper geschnitten (die Ausruestung bringt Arme, Haende, Beine), alles auf DREIECKE
# verkleinert (Modellregel 7), Farbe gedaempft wie tex.py (worn), Haut auf die Haut des Helden (Doll.kt), Texturen
# hoechstens 1024 px, kein Glanz (Modellregel 6), Groesse wie der Held (175 cm), Bewegungen deutsch benannt (Modellregel 5).
# Skelett bleibt das fremde (Modellregel 4 gebrochen, nur Probe; Chefsache 34812-cc0).
# Aufruf: CC0=<ordner von cc0_laden.sh> OUT=<ordner> bl/bin/python -I cc0.py  ->  <OUT>/cc0.glb, cc0-info.json, tex/
import bpy, os, sys, json, glob
import numpy as np
from mathutils import Vector
from PIL import Image

CC0 = os.environ.get('CC0', os.path.expanduser('~/cc0'))
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
AUS = os.environ.get('AUSRUESTUNG', 'Male_Ranger')
DREIECKE = int(os.environ.get('DREIECKE', '6000'))
H = 1.75                                     # Held (held3.py: Mensch, Mann, mittel, 175 cm)
os.makedirs(OUT + '/tex', exist_ok=True)

def eins(muster):
    f = sorted(glob.glob(os.path.join(CC0, muster), recursive=True))
    if not f: sys.exit('fehlt: ' + muster)
    return f[0]
KOERPER = eins('**/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf')
KLEID = eins('**/Exports/glTF (Godot-Unreal)/Outfits/%s.gltf' % AUS)
BEWEG = eins('**/Unreal-Godot/UAL1_Standard.glb')

# Bewegungen: unser Name <- Name in der Bibliothek
BEWEGUNGEN = {'Stehen': 'Idle_Loop', 'Gehen': 'Walk_Loop', 'Rennen': 'Sprint_Loop', 'Hieb': 'Sword_Attack',
              'Abwehr': 'Sword_Idle', 'Treffer': 'Hit_Chest', 'Tod': 'Death01', 'Fackel': 'Idle_Torch_Loop'}

def hx(c): return np.array([(c >> 16) & 255, (c >> 8) & 255, c & 255], float)
HAUT = hx(0xC98B6B)                          # held3.py COL['skin']
ABNUTZ = hx(0x3A3632)                        # held3.py worn()

bpy.ops.wm.read_factory_settings(use_empty=True)
sc = bpy.context.scene
sc.render.fps = 30

def lade(p):
    vor = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=p)
    return [o for o in bpy.data.objects if o not in vor]

kleid = lade(KLEID)
ske = next(o for o in kleid if o.type == 'ARMATURE')
koerper = lade(KOERPER)
beweg = lade(BEWEG)
ual = next(o for o in beweg if o.type == 'ARMATURE')

def weg(o): bpy.data.objects.remove(o, do_unlink=True)

# ---------------------------------------------------------------- Kopf aus dem Grundkoerper
OHNE = os.environ.get('OHNE', 'Pauldron').split(',')   # Helfer Runde 1: Schulterstueck hell, steht von hinten ab
teile = [o for o in kleid if o.type == 'MESH' and o.vertex_groups and not any(k and k in o.name for k in OHNE)]
for o in koerper:
    if o.type != 'MESH' or not o.vertex_groups: continue
    if o.name.startswith('SuperHero'):
        gi = {g.name: g.index for g in o.vertex_groups}
        kopf = {gi['Head'], gi['neck_01']}
        loesch = []
        for v in o.data.vertices:
            w = sum(g.weight for g in v.groups if g.group in kopf)
            z = (o.matrix_world @ v.co).z
            if w < 0.5 or z < 1.47: loesch.append(v.index)
        import bmesh
        bm = bmesh.new(); bm.from_mesh(o.data)
        bm.verts.ensure_lookup_table()
        bmesh.ops.delete(bm, geom=[bm.verts[i] for i in loesch], context='VERTS')
        bm.to_mesh(o.data); bm.free()
    for m in o.modifiers:
        if m.type == 'ARMATURE': m.object = ske
    mw = o.matrix_world.copy()
    o.parent = ske; o.matrix_world = mw
    teile.append(o)
for o in [o for o in koerper + beweg + kleid if o.name in bpy.data.objects]:
    if o not in teile and o not in (ske, ual): weg(o)   # auch das Skelett des Grundkoerpers

# ---------------------------------------------------------------- ein Netz, verkleinert
bpy.ops.object.select_all(action='DESELECT')
for o in teile: o.select_set(True)
bpy.context.view_layer.objects.active = teile[0]
bpy.ops.object.join()
leib = bpy.context.view_layer.objects.active
leib.name = 'Leib'
def dreiecke(o): return sum(len(p.vertices) - 2 for p in o.data.polygons)
vorher = dreiecke(leib)
for _ in range(3):                           # Collapse trifft das Ziel nicht genau: nachregeln
    n = dreiecke(leib)
    if n <= DREIECKE: break
    d = leib.modifiers.new('klein', 'DECIMATE'); d.ratio = DREIECKE / n * 0.98
    bpy.ops.object.modifier_apply(modifier=d.name)
nachher = dreiecke(leib)

# ---------------------------------------------------------------- Farbe: gedaempft, Haut wie der Held, 1024 px, kein Glanz
def bild_von(mat):
    if not mat.use_nodes: return None
    for n in mat.node_tree.nodes:
        if n.type == 'BSDF_PRINCIPLED':
            l = n.inputs['Base Color'].links
            if not l: return (n, None)
            q = l[0].from_node
            if q.type == 'MIX':                  # Bild mal Eckfarbe: die Eckfarbe faellt weg (unten), das Bild direkt
                q = next((k.from_node for k in q.inputs['A'].links), None) if 'A' in q.inputs else None
                if q is None:
                    q = next((k.from_node for s in l[0].from_node.inputs for k in s.links if k.from_node.type == 'TEX_IMAGE'), None)
            if q is not None and q.type == 'TEX_IMAGE':
                mat.node_tree.links.new(q.outputs['Color'], n.inputs['Base Color'])
                return (n, q)
            return (n, None)
    return None
while leib.data.color_attributes: leib.data.color_attributes.remove(leib.data.color_attributes[0])
fertig = {}
for mat in leib.data.materials:
    r = bild_von(mat)
    if not r: continue
    bsdf, tn = r
    for k in ['Normal', 'Roughness', 'Metallic', 'Specular IOR Level']:
        if k in bsdf.inputs:
            for l in list(bsdf.inputs[k].links): mat.node_tree.links.remove(l)
    bsdf.inputs['Metallic'].default_value = 0.0
    bsdf.inputs['Roughness'].default_value = 1.0
    if not tn or not tn.image: continue
    src = bpy.path.abspath(tn.image.filepath) if tn.image.filepath else None
    key = os.path.basename(src) if src else tn.image.name
    if key not in fertig:
        if src and os.path.exists(src): im = Image.open(src).convert('RGB')
        else:
            px = np.array(tn.image.pixels[:]).reshape(tn.image.size[1], tn.image.size[0], 4)[::-1, :, :3]
            im = Image.fromarray((px ** (1 / 2.2) * 255).clip(0, 255).astype(np.uint8))
        im = im.resize((min(1024, im.width), min(1024, im.height)), Image.LANCZOS)
        a = np.asarray(im).astype(float)
        haut = 'Superhero' in key or 'Regular' in key
        if haut:                                 # Haut des Helden, vom fremden Bild nur ein Viertel der Helligkeit (Helfer: Bartschatten wie Schmutz, nachts fahl)
            L = a.mean(2, keepdims=True)
            Lm = np.median(L[L > 30])
            a = HAUT * np.clip(0.75 + 0.25 * L / Lm, 0.6, 1.1)
        else:                                    # Leder, Stoff: Saettigung 0,75, 25 % Richtung Abnutzung (tex.py worn)
            g = a.mean(2, keepdims=True)
            a = g + (a - g) * 0.75
            a = a + (ABNUTZ - a) * 0.25
        p = OUT + '/tex/%s.png' % bpy.path.clean_name(os.path.splitext(key)[0])
        Image.fromarray(a.clip(0, 255).astype(np.uint8)).save(p)
        neu = bpy.data.images.load(p); neu.pack()
        fertig[key] = neu
    tn.image = fertig[key]

# ---------------------------------------------------------------- Groesse wie der Held
hoch = max((leib.matrix_world @ Vector(c)).z for c in leib.bound_box)
s = H / 1.81                                     # Grundkoerper 1,81 m ohne Kapuze
ske.scale = (s, s, s)

# ---------------------------------------------------------------- Bewegungen aus der Bibliothek, deutsch benannt
ad = ske.animation_data_create()
ad.action = None
for alt in list(ske.animation_data.nla_tracks): ske.animation_data.nla_tracks.remove(alt)
laengen = {}
for neu_n, alt_n in BEWEGUNGEN.items():
    act = bpy.data.actions.get(alt_n) or next((a for a in bpy.data.actions if a.name.startswith(alt_n)), None)
    if not act: print('BEWEGUNG FEHLT', alt_n); continue
    act.name = neu_n
    act.use_fake_user = True
    tr = ad.nla_tracks.new(); tr.name = neu_n
    st = tr.strips.new(neu_n, int(act.frame_range[0]), act)
    if hasattr(st, 'action_slot') and act.slots: st.action_slot = act.slots[0]
    tr.mute = False
    laengen[neu_n] = round((act.frame_range[1] - act.frame_range[0]) / sc.render.fps, 3)
weg(ual)
for o in list(bpy.data.objects):
    if o not in (ske, leib): weg(o)

# Gehtempo gegen Fussgleiten: im Stand der Bewegung „Gehen“ wandert der tragende Fuss mit dem Gehtempo nach hinten
def gehtempo():
    act = bpy.data.actions['Gehen']
    ad.action = act
    if hasattr(ad, 'action_slot') and act.slots: ad.action_slot = act.slots[0]
    for tr in ad.nla_tracks: tr.mute = True
    a, b = int(act.frame_range[0]), int(act.frame_range[1])
    v = []
    for f in range(a, b):
        sc.frame_set(f); p0 = {k: (ske.matrix_world @ ske.pose.bones[k].head) for k in ('foot_l', 'foot_r')}
        sc.frame_set(f + 1); p1 = {k: (ske.matrix_world @ ske.pose.bones[k].head) for k in ('foot_l', 'foot_r')}
        k = min(p0, key=lambda k: p0[k].z)
        v.append((p1[k] - p0[k]).length * sc.render.fps)
    ad.action = None
    for tr in ad.nla_tracks: tr.mute = False
    return round(float(np.median(v)), 3)
tempo = gehtempo()

# ---------------------------------------------------------------- Ausgabe
bpy.ops.object.select_all(action='DESELECT')
ske.select_set(True); leib.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUT + '/cc0.glb', export_format='GLB', use_selection=True, export_yup=True,
                          export_animation_mode='NLA_TRACKS', export_force_sampling=True, export_frame_step=1,
                          export_image_format='AUTO')
info = {'gehen_m_je_s': tempo, 'dreiecke': nachher, 'dreiecke_vorher': vorher, 'hoehe_m': round(hoch * s, 3),
        'bewegungen': laengen, 'ausruestung': AUS,
        'quellen': ['Quaternius, Universal Base Characters [Standard], CC0 1.0',
                    'Quaternius, Modular Character Outfits - Fantasy [Standard], CC0 1.0',
                    'Quaternius, Universal Animation Library [Standard], CC0 1.0']}
json.dump(info, open(OUT + '/cc0-info.json', 'w'), indent=1, ensure_ascii=False)
print('CC0', json.dumps(info, ensure_ascii=False))
