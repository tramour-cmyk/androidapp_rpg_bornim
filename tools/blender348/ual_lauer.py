# 348.12 Runde 2 (Chef 26.10., 16:21 „cc0 nochmal“, Archiv): geduckte Grundhaltung für den Goblin auf dem CC0-Gerüst aus den
# Bewegungen der Universal Animation Library (Quaternius, CC0 1.0): Rumpf und Beine zwischen Sword_Idle und Crouch_Idle_Loop
# (GEDUCKT = Anteil der Hocke), Arme aus Sword_Idle, nach vorn gehoben (ARM_R, ARM_L: Grad um die Querachse der Welt), damit Waffe
# und Schild vor dem Körper stehen wie in der eigenen Lauer (goblin.py LAUER). Schreibt eine Kopie der Bibliothek mit der neuen
# Bewegung „Goblin_Lauer_Loop“ (geruest.py liest sie über CC0=<ziel>, goblin.py mit CC0_RUHE=Goblin_Lauer_Loop).
# Runde 2d (Helfer zu 2a–c: Hocke zu flach, 2a Bein gekreuzt; Crouch_Idle_Loop kniet links vorn, rechts unten): HOCKE=ik (Vorgabe)
# nimmt nur Sword_Idle, senkt das Becken auf BECKEN m, stellt die Füße symmetrisch (BREIT m von der Mitte, Versatz VERSATZ m, links
# vorn) flach auf den Boden und beugt die Knie per IK (Knie leicht nach außen, KNIE_AUS), Rumpf RUMPF Grad vor, Hals hebt den Kopf um
# KOPF_AUF davon wieder; HOCKE=misch wie 2a–c.
# Aufruf: python -I ual_lauer.py <cc0-ordner> <ziel-ordner>
import bpy, sys, os, glob, math, shutil
from mathutils import Quaternion, Vector, Matrix

QUELLE, ZIEL = sys.argv[-2], sys.argv[-1]
GEDUCKT = float(os.environ.get('GEDUCKT', '0.55'))
ARM_VOR = {'r': float(os.environ.get('ARM_R', '110')), 'l': float(os.environ.get('ARM_L', '60'))}
UNTEN = ('root', 'pelvis', 'spine_01', 'spine_02', 'spine_03', 'neck_01', 'Head',
         'thigh_l', 'calf_l', 'foot_l', 'ball_l', 'thigh_r', 'calf_r', 'foot_r', 'ball_r')
NAME = 'Goblin_Lauer_Loop'
HOCKE = os.environ.get('HOCKE', 'ik')
ELLE = {'r': float(os.environ.get('ELLE_R', '50')), 'l': float(os.environ.get('ELLE_L', '40'))}
BECKEN = float(os.environ.get('BECKEN', '0.58'))
BREIT = float(os.environ.get('BREIT', '0.24'))
VERSATZ = float(os.environ.get('VERSATZ', '0.12'))
KNIE_AUS = float(os.environ.get('KNIE_AUS', '0.4'))
RUMPF = float(os.environ.get('RUMPF', '25'))
KNIE_VOR = float(os.environ.get('KNIE_VOR', '0.4'))
KOPF_AUF = float(os.environ.get('KOPF_AUF', '1.0'))

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
if HOCKE == 'ik':
    # Ziele und Pole (Blick −Y, links +X); Füße flach wie in Sword_Idle, nur Ort neu
    ziele = {}
    for s_ in 'lr':
        z = bpy.data.objects.new('ziel_' + s_, None); scn.collection.objects.link(z)
        pol = bpy.data.objects.new('pol_' + s_, None); scn.collection.objects.link(pol)
        c = PB['calf_' + s_].constraints.new('IK'); c.target = z; c.pole_target = pol; c.chain_count = 2; c.use_tail = True
        c.pole_angle = math.radians(float(os.environ.get('PA_' + s_.upper(), {'l': '-90', 'r': '-120'}[s_])))
        ziele[s_] = (z, pol, c)
    LR = ('thigh_l', 'calf_l', 'foot_l', 'ball_l', 'thigh_r', 'calf_r', 'foot_r', 'ball_r')
    for i in range(n + 1):
        S = lies(sw, i / n)
        for b, (q, l) in S.items():
            PB[b].rotation_quaternion = q; PB[b].location = l
        bpy.context.view_layer.update()
        fuss = {s_: PB['foot_' + s_].matrix.copy() for s_ in 'lr'}
        pv = PB['pelvis'].matrix.translation.copy()
        # Becken senken (Armaturraum = Welt, Matrix Einheit)
        PB['pelvis'].matrix = Matrix.Translation((0, 0, BECKEN - pv.z)) @ PB['pelvis'].matrix
        bpy.context.view_layer.update()
        mx = PB['pelvis'].matrix.translation.x
        for s_, sx, sy in (('l', 1, -1), ('r', -1, 1)):
            z, pol, c = ziele[s_]
            boden = fuss[s_].translation.z
            z.location = (mx + sx * BREIT, pv.y + sy * VERSATZ, boden)
            pol.location = (mx + sx * (BREIT + KNIE_AUS), pv.y + sy * VERSATZ - KNIE_VOR, BECKEN)
        bpy.context.view_layer.update()
        fertig = {b: PB[b].matrix.copy() for b in LR}
        for s_ in 'lr': ziele[s_][2].mute = True
        bpy.context.view_layer.update()
        for b in ('thigh_l', 'calf_l', 'thigh_r', 'calf_r'):
            PB[b].matrix = fertig[b]; bpy.context.view_layer.update()
        for s_ in 'lr':     # Fuß flach wie in Sword_Idle, am Knöchel
            PB['foot_' + s_].matrix = Matrix.Translation(PB['foot_' + s_].matrix.translation) @ fuss[s_].to_3x3().to_4x4()
            bpy.context.view_layer.update()
        # Rumpf vor um die Querachse am spine_01
        pb = PB['spine_01']; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(RUMPF), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
        # Kopf hebt sich wieder (Blick nach vorn statt zu Boden): Hals zurück um KOPF_AUF des Rumpfwinkels
        pb = PB['neck_01']; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-RUMPF * KOPF_AUF), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
        bpy.context.view_layer.update()
        frames.append({pb.name: (pb.rotation_quaternion.copy(), pb.location.copy()) for pb in PB})
        for s_ in 'lr': ziele[s_][2].mute = False
    # das erste Bild kam aus dem noch nicht eingeschwungenen IK (Ballen rechts 18 cm hoch); die Schleife endet in derselben Stellung
    frames[0] = frames[-1]
    for s_ in 'lr':
        PB['calf_' + s_].constraints.remove(ziele[s_][2])
        bpy.data.objects.remove(ziele[s_][0]); bpy.data.objects.remove(ziele[s_][1])
else:
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
        # Runde 2e (Helfer 2d: Waffe hängt am Boden, Schild vor den Schienbeinen): Ellbogen beugt den Unterarm nach vorn oben
        pb = PB['lowerarm_' + s]; h = pb.matrix.translation.copy()
        pb.matrix = Matrix.Translation(h) @ Matrix.Rotation(math.radians(-ELLE[s]), 4, 'X') @ Matrix.Translation(-h) @ pb.matrix
    bpy.context.view_layer.update()
    for pb in PB:
        pb.keyframe_insert('rotation_quaternion', frame=i + 1); pb.keyframe_insert('location', frame=i + 1)
tr = rig.animation_data.nla_tracks.new(); tr.name = NAME; st = tr.strips.new(NAME, 1, neu)
if hasattr(st, 'action_slot') and len(neu.slots): st.action_slot = neu.slots[0]
# Prüfwerte wie in den Quellen: Becken, Kopf, Hände gegen das Becken
scn.frame_set(1); bpy.context.view_layer.update()
W = lambda b: rig.matrix_world @ PB[b].head
P0 = W('pelvis')
print('LAUER Becken %.2f Kopf %.2f (vor %.2f) Hand_r %s Hand_l %s' % (P0.z, W('Head').z, P0.y - W('Head').y, tuple(round(x, 2) for x in W('hand_r') - P0), tuple(round(x, 2) for x in W('hand_l') - P0)))
B = []
for f in range(1, n + 2, 5):
    scn.frame_set(f); bpy.context.view_layer.update(); B.append((round(W('ball_l').z, 2), round(W('ball_r').z, 2)))
print('LAUER Ballen je 5 Bilder', B)
scn.frame_set(1); bpy.context.view_layer.update()
print('LAUER Füße l %s r %s, Knie l %s r %s, Ballen z %.3f %.3f' % tuple([tuple(round(x, 2) for x in W(b) - P0) for b in ('foot_l', 'foot_r', 'calf_l', 'calf_r')] + [W('ball_l').z, W('ball_r').z]))
# übrige Bewegungen wieder als NLA-Spuren (so liest sie geruest.py wie aus der Quelle)
rig.animation_data.action = None
for a in list(A):
    if a.name == NAME or any(t.name == a.name for t in rig.animation_data.nla_tracks): continue
    t = rig.animation_data.nla_tracks.new(); t.name = a.name; s_ = t.strips.new(a.name, int(a.frame_range[0]), a)
    if hasattr(s_, 'action_slot') and len(a.slots): s_.action_slot = a.slots[0]
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_animations=True, export_animation_mode='NLA_TRACKS', export_skins=True)
print('UAL', dst, os.path.getsize(dst))
