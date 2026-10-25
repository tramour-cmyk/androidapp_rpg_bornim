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
VOLK = os.environ.get('VOLK', 'mensch')        # 348.12 (Chef 23:33): traegt das Geruest Zwerg und Halbling? mensch | zwerg | halbling
H = {'mensch': 1.75, 'zwerg': 1.35, 'halbling': 1.05}[VOLK]   # Doll.kt height (Abnahmeliste Held, Punkt 1)
NAME = 'cc0' if VOLK == 'mensch' else 'cc0-' + VOLK
TEX = OUT + '/tex-' + NAME                  # je Volk eigener Ordner: parallel gerechnet lasen sich die Laeufe halbe Bilder
os.makedirs(TEX, exist_ok=True)

def eins(muster):
    f = sorted(glob.glob(os.path.join(CC0, muster), recursive=True))
    if not f: sys.exit('fehlt: ' + muster)
    return f[0]
KOERPER = eins('**/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf')
KLEID = eins('**/Exports/glTF (Godot-Unreal)/Outfits/%s.gltf' % AUS)
BEWEG = eins('**/Unreal-Godot/UAL1_Standard.glb')
BART = os.environ.get('BART', '1' if VOLK == 'zwerg' else '0') == '1'
BARTDATEI = eins('**/Rigged to Head Bone/glTF (Godot -Unreal)/Hair_Beard.gltf')

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
bart = lade(BARTDATEI) if BART else []
ual = next(o for o in beweg if o.type == 'ARMATURE')

def weg(o): bpy.data.objects.remove(o, do_unlink=True)

# ---------------------------------------------------------------- Kopf aus dem Grundkoerper
OHNE = os.environ.get('OHNE', 'Pauldron,Hood' if VOLK == 'zwerg' else 'Pauldron').split(',')   # Zwerg: Bart und Gesicht frei   # Helfer Runde 1: Schulterstueck hell, steht von hinten ab
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
for o in bart:                               # Zwerg: Bart des Grundkoerpers, am Kopfknochen
    if o.type != 'MESH': continue
    for m in o.modifiers:
        if m.type == 'ARMATURE': m.object = ske
    mw = o.matrix_world.copy()
    o.parent = ske; o.matrix_world = mw
    teile.append(o)
for o in [o for o in koerper + beweg + kleid + bart if o.name in bpy.data.objects]:
    if o not in teile and o not in (ske, ual): weg(o)   # auch das Skelett des Grundkoerpers

# ---------------------------------------------------------------- ein Netz, verkleinert
bpy.ops.object.select_all(action='DESELECT')
for o in teile: o.select_set(True)
bpy.context.view_layer.objects.active = teile[0]
bpy.ops.object.join()
leib = bpy.context.view_layer.objects.active
leib.name = 'Leib'
# ---------------------------------------------------------------- Volk: Knochen laenger/kuerzer, Netz mitgezogen
# Masse aus Doll.kt (Mensch = 1): Beine bis zur Huefte (legF x Groesse), Rumpf, Hals, Kopf (Groesse / Koepfe), Arme
# (armK), Dicke (girth), Schultern (shoulderK), Haende (handK), Fuesse (footK); alles relativ zum Menschen, die
# Gesamtgroesse kommt unten mit H. Beine und Rumpf am fremden Koerper nachgemessen (Huefte bei legF, Scheitel bei H).
# Je Knochen: (entlang, quer); Finger und Zehen wie ihr Hand- bzw. Fussknochen.
VOELKER = {   # Zwerg 135 cm, 5,3 Koepfe, legF 0,39, girth 1,5, shoulderK 1,55, armK 1,05, handK 1,2, Hals 0,72
    'zwerg': {'bein': 0.5, 'rumpf': 1.1, 'hals': 0.555, 'kopf': 1.09, 'arm': 0.78, 'dick': 1.35, 'schulter': 1.12,
              'hand': 1.05, 'fuss': 0.85},   # Helfer Runde 1: „untersetzter kleiner Mensch“: Beine kuerzer, breiter, dickere Arme und Haende
              # Halbling 105 cm, 5,9 Koepfe, legF 0,46, girth 1,08, handK 1,05, footK 1,25
    'halbling': {'bein': 0.49, 'rumpf': 0.66, 'hals': 0.6, 'kopf': 0.7, 'arm': 0.6, 'dick': 0.76, 'schulter': 1.0,   # Runde 1: „kindlich“
                 'hand': 0.63, 'fuss': 0.79}}
def kurven(act):                                 # Blender 5: F-Kurven in Ebenen/Streifen/Kanalbuendeln
    if hasattr(act, 'layers') and act.layers:
        return [fc for ly in act.layers for st in ly.strips for cb in st.channelbags for fc in cb.fcurves]
    return list(getattr(act, 'fcurves', []))
VOLKMASS = {}
if VOLK != 'mensch':
    import mathutils
    V = VOELKER[VOLK]
    def mass(n):                                 # (entlang, quer)
        if n == 'root': return (1, 1)
        if n == 'pelvis' or n.startswith('spine'): return (V['rumpf'], V['dick'])
        if n.startswith('neck'): return (V['hals'], V['dick'])
        if n == 'Head': return (V['kopf'], V['kopf'])
        if n.startswith('clavicle'): return (V['schulter'], V['dick'])
        if n.startswith(('upperarm', 'lowerarm')): return (V['arm'], V['dick'])
        if n.startswith(('thigh', 'calf')): return (V['bein'], V['dick'])
        if n.startswith(('foot', 'ball')): return (V['fuss'], V['fuss'])
        return (V['hand'], V['hand'])              # Hand und Finger
    arm = ske.data
    R = {b.name: b.matrix_local.copy() for b in arm.bones}
    M = {}
    for b in arm.bones:                          # Eltern vor Kindern (Reihenfolge der Knochenliste)
        e, q = mass(b.name)
        S = mathutils.Matrix.Diagonal((q, e, q, 1))
        rot = R[b.name].to_3x3().to_4x4()
        h = R[b.name].translation if not b.parent else (M[b.parent.name] @ R[b.parent.name].inverted() @ R[b.name].translation)
        M[b.name] = mathutils.Matrix.Translation(h) @ rot @ S
    # Netz: lineares Skinning von alter zu neuer Ruhelage
    A = ske.matrix_world.inverted() @ leib.matrix_world
    gname = {g.index: g.name for g in leib.vertex_groups}
    D = {n: M[n] @ R[n].inverted() for n in M}
    me = leib.data
    co = []
    for v in me.vertices:
        p = A @ v.co
        acc = mathutils.Vector((0, 0, 0)); w = 0.0
        for g in v.groups:
            n = gname.get(g.group)
            if n in D and g.weight > 0:
                acc += g.weight * (D[n] @ p); w += g.weight
        co.append(acc / w if w > 0 else p)
    tief_alt = min((A @ v.co).z for v in me.vertices)
    tief = min(c.z for c in co) - tief_alt         # Sohlen zurueck auf den Boden: Becken und alles darunter senken
    for v, c in zip(me.vertices, co): v.co = A.inverted() @ (c - mathutils.Vector((0, 0, tief)))
    bpy.context.view_layer.objects.active = ske
    bpy.ops.object.mode_set(mode='EDIT')
    for eb in arm.edit_bones: eb.use_connect = False
    for eb in arm.edit_bones:
        e, q = mass(eb.name)
        roll = eb.roll
        k = M[eb.name].translation.copy()
        if eb.name != 'root': k.z -= tief
        d = (R[eb.name].to_3x3() @ mathutils.Vector((0, 1, 0))) * (eb.length * e)
        eb.head = k; eb.tail = k + d; eb.roll = roll
    bpy.ops.object.mode_set(mode='OBJECT')
    bpy.context.view_layer.objects.active = leib   # das Verkleinern unten wirkt auf das aktive Objekt
    # Bewegungen: Drehungen bleiben, Verschiebungen (Becken) mit der Beinlaenge
    for act in bpy.data.actions:
        for fc in kurven(act):
            if fc.data_path.endswith('location'):
                for kp in fc.keyframe_points:
                    kp.co[1] *= V['bein']; kp.handle_left[1] *= V['bein']; kp.handle_right[1] *= V['bein']
    VOLKMASS = dict(V, gesenkt_m=round(-tief, 3))

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
        p = TEX + '/%s.png' % bpy.path.clean_name(os.path.splitext(key)[0])
        Image.fromarray(a.clip(0, 255).astype(np.uint8)).save(p)
        neu = bpy.data.images.load(p); neu.pack()
        fertig[key] = neu
    tn.image = fertig[key]

# ---------------------------------------------------------------- Groesse wie der Held
hoch = max((leib.matrix_world @ Vector(c)).z for c in leib.bound_box)
s = 1.75 / 1.81                                  # Grundkoerper 1,81 m ohne Kapuze; Zwerg, Halbling schon oben verkleinert
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

def boden():   # je Bewegung: tiefster Ballen/Knoechel (m, nach Groesse) min/max ueber die Bilder; Stand ~ 0 heisst Fuesse am Boden
    r = {}
    for tr in ad.nla_tracks: tr.mute = True
    for n in laengen:
        act = bpy.data.actions[n]; ad.action = act
        if hasattr(ad, 'action_slot') and act.slots: ad.action_slot = act.slots[0]
        z = []
        for f in range(int(act.frame_range[0]), int(act.frame_range[1]) + 1):
            sc.frame_set(f)
            z.append(min((ske.matrix_world @ ske.pose.bones[k].head).z for k in ('ball_l', 'ball_r', 'foot_l', 'foot_r')))
        r[n] = [round(min(z), 3), round(max(z), 3)]
    ad.action = None
    for tr in ad.nla_tracks: tr.mute = False
    return r
BODEN = boden()

# ---------------------------------------------------------------- Ausgabe
bpy.ops.object.select_all(action='DESELECT')
ske.select_set(True); leib.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUT + '/' + NAME + '.glb', export_format='GLB', use_selection=True, export_yup=True,
                          export_animation_mode='NLA_TRACKS', export_force_sampling=True, export_frame_step=1,
                          export_image_format='AUTO')
info = {'gehen_m_je_s': tempo, 'dreiecke': nachher, 'dreiecke_vorher': vorher, 'hoehe_m': round(hoch * s, 3),
        'bewegungen': laengen, 'ausruestung': AUS, 'volk': VOLK, 'volkmass': VOLKMASS, 'bart': BART, 'boden_m': BODEN,
        'quellen': ['Quaternius, Universal Base Characters [Standard], CC0 1.0',
                    'Quaternius, Modular Character Outfits - Fantasy [Standard], CC0 1.0',
                    'Quaternius, Universal Animation Library [Standard], CC0 1.0']}
json.dump(info, open(OUT + '/' + NAME + '-info.json', 'w'), indent=1, ensure_ascii=False)
print('CC0', json.dumps(info, ensure_ascii=False))
