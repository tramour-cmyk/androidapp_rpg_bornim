# 348.12 Runde 2 (Chef 26.10., 16:21 „cc0 nochmal“, Archiv): geduckte Grundhaltung für den Goblin auf dem CC0-Gerüst aus den
# Bewegungen der Universal Animation Library (Quaternius, CC0 1.0): Rumpf und Beine zwischen Sword_Idle und Crouch_Idle_Loop
# (GEDUCKT = Anteil der Hocke), Arme aus Sword_Idle, nach vorn gehoben (ARM_R, ARM_L: Grad um die Querachse der Welt), damit Waffe
# und Schild vor dem Körper stehen wie in der eigenen Lauer (goblin.py LAUER). Schreibt eine Kopie der Bibliothek mit der neuen
# Bewegung „Goblin_Lauer_Loop“ (geruest.py liest sie über CC0=<ziel>, goblin.py mit CC0_RUHE=Goblin_Lauer_Loop).
# Aufruf: python -I ual_lauer.py <cc0-ordner> <ziel-ordner>
import bpy, sys, os, glob, math, shutil
from mathutils import Quaternion, Vector, Matrix

QUELLE, ZIEL = sys.argv[-2], sys.argv[-1]
GEDUCKT = float(os.environ.get('GEDUCKT', '0.55'))
ARM_VOR = {'r': float(os.environ.get('ARM_R', '75')), 'l': float(os.environ.get('ARM_L', '15'))}
UNTEN = ('root', 'pelvis', 'spine_01', 'spine_02', 'spine_03', 'neck_01', 'Head',
         'thigh_l', 'calf_l', 'foot_l', 'ball_l', 'thigh_r', 'calf_r', 'foot_r', 'ball_r')
NAME = 'Goblin_Lauer_Loop'

f = sorted(glob.glob(os.path.join(QUELLE, '**', 'UAL1_Standard.glb'), recursive=True))
f = [x for x in f if 'Unreal-Godot' in x] or f
src = f[0]
rel = os.path.relpath(src, QUELLE)
dst = os.path.join(ZIEL, rel)
os.makedirs(os.path.dirname(dst), exist_ok=True)
for lz in glob.glob(os.path.join(os.path.dirname(os.path.dirname(src)), 'License*')):
    shutil.copy(lz, os.path.join(os.path.dirname(os.path.dirname(dst)), os.path.basename(lz)))

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
scn = bpy.context.scene
rig = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
PB = rig.pose.bones
for pb in PB: pb.rotation_mode = 'QUATERNION'
A = bpy.data.actions


def setze(act):
    rig.animation_data.action = act
    if hasattr(act, 'slots') and len(act.slots): rig.animation_data.action_slot = act.slots[0]


def lies(act, ph):
    setze(act); a0, a1 = act.frame_range
    scn.frame_set(int(round(a0 + ph * (a1 - a0)))); bpy.context.view_layer.update()
    return {pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB}


sw, cr = A['Sword_Idle'], A['Crouch_Idle_Loop']
n = int(sw.frame_range[1] - sw.frame_range[0])
frames = []
for i in range(n + 1):
    ph = i / n
    S, C = lies(sw, ph), lies(cr, ph)
    frames.append({b: ((S[b][0].slerp(C[b][0], GEDUCKT), S[b][1].lerp(C[b][1], GEDUCKT)) if b in UNTEN else S[b]) for b in S})
neu = bpy.data.actions.new(NAME); neu.use_fake_user = True
setze(neu)
for i, P in enumerate(frames):
    for b, (q, l) in P.items():
        PB[b].rotation_quaternion = q; PB[b].location = l
    # Arme nach vorn: Oberarm um die Querachse der Welt (Blick −Y), als Drehung im Knochenraum
    bpy.context.view_layer.update()
    for s in 'lr':
        pb = PB['upperarm_' + s]
        h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-ARM_VOR[s]), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()
    for pb in PB:
        pb.keyframe_insert('rotation_quaternion', frame=i + 1); pb.keyframe_insert('location', frame=i + 1)
tr = rig.animation_data.nla_tracks.new(); tr.name = NAME; st = tr.strips.new(NAME, 1, neu)
if hasattr(st, 'action_slot') and len(neu.slots): st.action_slot = neu.slots[0]
# Prüfwerte wie in den Quellen: Becken, Kopf, Hände gegen das Becken
scn.frame_set(1); bpy.context.view_layer.update()
W = lambda b: rig.matrix_world @ PB[b].head
P0 = W('pelvis')
print('LAUER Becken %.2f Kopf %.2f Hand_r %s Hand_l %s' % (P0.z, W('Head').z, tuple(round(x, 2) for x in W('hand_r') - P0), tuple(round(x, 2) for x in W('hand_l') - P0)))
# übrige Bewegungen wieder als NLA-Spuren (so liest sie geruest.py wie aus der Quelle)
rig.animation_data.action = None
for a in list(A):
    if a.name == NAME or any(t.name == a.name for t in rig.animation_data.nla_tracks): continue
    t = rig.animation_data.nla_tracks.new(); t.name = a.name; s_ = t.strips.new(a.name, int(a.frame_range[0]), a)
    if hasattr(s_, 'action_slot') and len(a.slots): s_.action_slot = a.slots[0]
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_animations=True, export_animation_mode='NLA_TRACKS', export_skins=True)
print('UAL', dst, os.path.getsize(dst))
