# 403 (Team Tom zu 376.1, Perikles M: „Held gleitet im Kampf“): Kampfbewegungen des Helden auf dem Kaufkoerper (heldfigur.gd) aus der
# gekauften Universal Animation Library Pro (Quaternius, bornim-kaufmodelle Version stufe1, Unreal-Godot/UAL1.glb; gleiches Geruest
# wie der Kaufkoerper). Nur Geruest und diese Bewegungen, Namen wie figur.gd sie spielt; Godot traegt sie wie HeldFigur.bewegungen
# auf den Helden (nur Drehungen, Becken im Verhaeltnis der Beckenhoehe).
# Aufruf: KAUF=<ordner> OUT=<ordner> bl/bin/python -I held_kampf_pro.py  ->  <OUT>/held-kampf.glb, <OUT>/held-kampf-info.json
# info: Laengen (s), Aufschlag des Hiebs (s, die Faust am weitesten vorn; hieb_vorn: so weit vor dem Becken, m), Wurzelweg der Ausweichsaetze aus UAL1_RM.glb (je Bild
# [x, z] in Metern, +Z vorn, +X links der Figur, wie <art>-info.json „weg“ der Tiere), fps.
# Die UAL Pro hat keinen Stich (Toms Zu 376.1, Technik): der Stich nimmt den Hieb, figur.gd spielt ihn schneller.
import bpy, glob, json, os, struct
import numpy as np

KAUF = os.environ.get('KAUF', '')
OUT = os.environ.get('OUT', '/tmp/held_kampf')
os.makedirs(OUT, exist_ok=True)

# Name in figur.gd <- Quelle; drei Treffer, zwei Tode (DESIGN-LEITBILD 2: Abwechslung)
BEWEGUNGEN = [('Kampfstehen', 'Sword_Idle'), ('Hieb', 'Sword_Attack_Standing'), ('Treffer', 'Hit_Chest'), ('Treffer_2', 'Hit_Stomach'),
              ('Treffer_3', 'Hit_Shoulder_R'), ('Tod', 'Death01'), ('Tod_2', 'Death02'), ('Ausweichen', 'Dodge_Right'),
              ('Ausweichen links', 'Dodge_Left'), ('Ausholen', 'Spell_Simple_Shoot')]
WEG = ['Ausweichen', 'Ausweichen links']


def finde(name):
    f = sorted(glob.glob(os.path.join(KAUF, '**', 'Unreal-Godot', name), recursive=True)) if KAUF else []
    if not f: raise SystemExit('FEHLT %s (gekauft, KAUF=)' % name)
    return f[0]


def wurzelweg(pfad, quelle, fps):
    # Uebersetzung des Knotens root in der _RM-Fassung, je Bild (lineare Zwischenwerte wie glTF)
    b = open(pfad, 'rb').read()
    n = struct.unpack('<I', b[12:16])[0]
    j = json.loads(b[20:20 + n]); bin0 = 20 + n + 8
    def acc(i):
        a = j['accessors'][i]; v = j['bufferViews'][a['bufferView']]
        k = {'SCALAR': 1, 'VEC3': 3, 'VEC4': 4}[a['type']]
        return np.frombuffer(b, dtype=np.float32, count=a['count'] * k, offset=bin0 + v.get('byteOffset', 0) + a.get('byteOffset', 0)).reshape(a['count'], k)
    namen = {i: nd.get('name', '') for i, nd in enumerate(j['nodes'])}
    for an in j['animations']:
        if an['name'] != quelle: continue
        for c in an['channels']:
            if namen[c['target']['node']] == 'root' and c['target']['path'] == 'translation':
                s = an['samplers'][c['sampler']]
                t = acc(s['input'])[:, 0]; v = acc(s['output'])
                ts = np.arange(0.0, t[-1] + 1e-6, 1.0 / fps)
                return [[round(float(np.interp(x, t, v[:, 0])), 4), round(float(np.interp(x, t, v[:, 2])), 4)] for x in ts]
    return []


pro = finde('UAL1.glb')
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=pro)
arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for o in [o for o in bpy.data.objects if o != arm]: bpy.data.objects.remove(o)
namen = dict((q, n) for n, q in BEWEGUNGEN)
for a in list(bpy.data.actions):
    if a.name in namen: a.name = namen[a.name]; a.use_fake_user = True
    else: bpy.data.actions.remove(a)
fehlt = [n for n, _ in BEWEGUNGEN if n not in bpy.data.actions]
if fehlt: raise SystemExit('FEHLT in UAL Pro: %s' % fehlt)
fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base


def setze(a):
    arm.animation_data_create(); arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots: arm.animation_data.action_slot = a.slots[0]


# Aufschlag: die rechte Faust am weitesten vor dem Becken (Blick -Y), im ersten Teil des Hiebs (vor dem Durchschwung nach links unten)
a = bpy.data.actions['Hieb']; setze(a)
f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
vorn = []
for fr in range(f0, f1 + 1):
    bpy.context.scene.frame_set(fr)
    h = arm.matrix_world @ arm.pose.bones['hand_r'].head
    p = arm.matrix_world @ arm.pose.bones['pelvis'].head
    vorn.append((-(h.y - p.y), (fr - f0) / fps))
haelfte = vorn[:len(vorn) // 2]
hieb_vorn, hieb_s = max(haelfte)
laengen = {a.name: round((a.frame_range[1] - a.frame_range[0]) / fps, 3) for a in bpy.data.actions}
if arm.animation_data: arm.animation_data.action = None

bpy.ops.object.select_all(action='DESELECT'); arm.select_set(True)
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT, 'held-kampf.glb'), export_format='GLB', use_selection=True, export_animations=True,
                          export_animation_mode='ACTIONS', export_skins=True, export_force_sampling=True)

rm = finde('UAL1_RM.glb')
quelle = dict(BEWEGUNGEN)
info = {'ual': os.path.basename(pro), 'fps': fps, 'laengen': laengen, 'hieb_s': round(hieb_s, 3), 'hieb_vorn': round(hieb_vorn, 3),
        'weg': {n: wurzelweg(rm, quelle[n], fps) for n in WEG}}
json.dump(info, open(os.path.join(OUT, 'held-kampf-info.json'), 'w'), indent=1)
print('HELD KAMPF OK', sorted(laengen), 'Hieb am Ziel %.2f s' % hieb_s, {n: info['weg'][n][-1] for n in WEG})
