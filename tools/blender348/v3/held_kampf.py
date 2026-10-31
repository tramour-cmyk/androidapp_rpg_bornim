# 403 (von Team Tom zu 376.1; Chef 31.10.: nur Modell und Bewegungen): die Kampfbewegungen fuer den Helden je Klasse auf dem
# Kaufkoerper. Der Kaufkoerper ruht in der T-Pose der UAL (bewegungen.glb, held_klassen.py), unsere Kampfbewegungen (kampf.py in
# held.glb: Kampfstehen, Ausholen, Hieb, Stich, Treffer, Ausweichen, Abwehr, Tod) auf unserer Ruhelage mit haengenden Armen. Darum
# hier umgerechnet: jeder Knochen behaelt seine Lage im Raum (Drehung wie in held.glb, beide Gerueste aus der UAL mit denselben
# Knochenachsen: Ruhelagen unterscheiden sich nur durch Schwenk, nie um die eigene Achse, gemessen 31.10.), das Becken seine Hoehe im Verhaeltnis der Beckenhoehen; Knochen, die der Kaufkoerper nicht hat (Scheide, Umhang,
# Rueckenschild), fallen weg. Dazu als Kandidaten aus der gekauften UAL Pro (408: Bestand zuerst; Wahl beim Chef) mit Vorsilbe
# „Pro_“: Sword_Idle, Sword_Attack, Sword_Attack_Standing, Hit_Chest, Hit_Head, Hit_Stomach, Death01, Death02, Dodge_Left, Dodge_Right.
# Ergebnis auf dem Geruest der UAL wie bewegungen.glb (Godot uebertraegt beide gleich auf den Helden, figur.gd).
# Pruefung ohne Bild: je Bewegung die groesste Abweichung von Hand, Fuss und Kopf gegen held.glb (auf die Koerpergroesse bezogen).
# Aufruf: SRC=<held.glb aus rig.py> ZIEL=<ordner> KAUF=<kaufpakete> bl/bin/python -I held_kampf.py   -> <ZIEL>/kampf-bewegungen.glb
import bpy, os, sys, json
from mathutils import Matrix, Vector

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import geruest as GE

SRC = os.environ.get('SRC', os.path.join(os.environ.get('OUT', '/home/user/q376/out'), 'held.glb'))
ZIEL = os.environ.get('ZIEL', os.path.dirname(SRC))
EIGEN = ['Kampfstehen', 'Ausholen', 'Hieb', 'Stich', 'Treffer', 'Ausweichen', 'Abwehr', 'Tod']
PRO = ['Sword_Idle', 'Sword_Attack', 'Sword_Attack_Standing', 'Hit_Chest', 'Hit_Head', 'Hit_Stomach', 'Death01', 'Death02',
       'Dodge_Left', 'Dodge_Right']
PRUEF = ['hand_l', 'hand_r', 'foot_l', 'foot_r', 'Head']

pro = GE.ual_pro()
if not pro: raise SystemExit('UAL Pro fehlt (KAUF): ohne Kaufpakete keine Kampfbewegungen fuer den Kaufkoerper')
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.render.fps = 30   # wie kampf.py (FPS 30); sonst rechnet der Import die Zeiten in 24 Bilder um
bpy.ops.import_scene.gltf(filepath=pro)
ziel = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
for o in [o for o in bpy.data.objects if o != ziel]: bpy.data.objects.remove(o)
for a in list(bpy.data.actions):
    if a.name in PRO: a.name = 'Pro_' + a.name; a.use_fake_user = True
    else: bpy.data.actions.remove(a)
ziel.name = 'Ziel'
vorher = set(bpy.data.objects)
bpy.ops.import_scene.gltf(filepath=SRC)
quelle = next(o for o in bpy.data.objects if o.type == 'ARMATURE' and o not in vorher)
for o in [o for o in bpy.data.objects if o not in vorher and o != quelle]: bpy.data.objects.remove(o)
quelle.name = 'Quelle'
QW, ZW = quelle.matrix_world.to_3x3(), ziel.matrix_world.to_3x3()


def akt(arm, a):
    arm.animation_data_create(); arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots: arm.animation_data.action_slot = a.slots[0]


ZB = ziel.data.bones
REIHE = [b.name for b in ZB if b.name in quelle.data.bones]          # Eltern vor Kindern (Reihenfolge der Knochen)
F = ZB['pelvis'].head_local.z / quelle.data.bones['pelvis'].head_local.z
fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base


def lage_q(pb):   # Drehung des Posenknochens im Raum (Welt), ohne Groesse
    return (QW @ pb.matrix.to_3x3()).normalized()


bericht = {}
ERSTES = {}     # Gelenke im ersten Bild, zum Nachmessen der geschriebenen Datei
# „Ruhelage“: unsere Ruhelage (Arme haengend) als ein Bild; figur.gd haengt den Schild in dieser Haltung an, wie kampf.py ihn
# gebaut hat („in der Ruhelage der linken Hand“: Vorderseite nach aussen, oben nach oben)
RUHE = bpy.data.actions.new('Ruhelage'); RUHE.use_fake_user = True
for name in ['Ruhelage'] + EIGEN:
    a = bpy.data.actions.get(name)
    if a is None: print('FEHLT', name); continue
    akt(quelle, a)
    if name == 'Ruhelage':     # Quelle ohne Bewegung: Ruhelage
        quelle.animation_data.action = None
        for pb in quelle.pose.bones: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0); pb.scale = (1, 1, 1)
    neu = bpy.data.actions.new('Neu_' + name); neu.use_fake_user = True   # Name erst nach dem Loeschen der Quelle (sonst „Hieb.001“)
    akt(ziel, neu)
    f0, f1 = (1, 2) if name == 'Ruhelage' else (int(round(a.frame_range[0])), int(round(a.frame_range[1])))
    weit = 0.0
    for fr in range(f0, f1 + 1):
        bpy.context.scene.frame_set(fr)
        R = {n: lage_q(quelle.pose.bones[n]) for n in REIHE}
        for n in REIHE:
            pb = ziel.pose.bones[n]; b = ZB[n]
            Rt = ZW.inverted() @ R[n]                                     # im Raum des Zielgeruests
            if b.parent and b.parent.name in R:
                Lr = b.parent.matrix_local.to_3x3().inverted() @ b.matrix_local.to_3x3()
                Rp = ZW.inverted() @ R[b.parent.name]
                Q = (Lr.inverted() @ Rp.inverted() @ Rt)
            else:
                Q = b.matrix_local.to_3x3().inverted() @ Rt
            pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = Q.to_quaternion(); pb.scale = (1, 1, 1)
            pb.location = (0, 0, 0)
        bpy.context.view_layer.update()
        for n in ('root', 'pelvis'):                                     # Becken: Ort im Verhaeltnis der Beckenhoehen
            if n not in REIHE: continue
            q = quelle.pose.bones[n].matrix.translation * (F if n == 'pelvis' else 1.0)
            pb = ziel.pose.bones[n]; m = pb.matrix.copy(); m.translation = q; pb.matrix = m
            bpy.context.view_layer.update()
        for n in REIHE:
            pb = ziel.pose.bones[n]
            pb.keyframe_insert('rotation_quaternion', frame=fr)
            if n in ('root', 'pelvis'): pb.keyframe_insert('location', frame=fr)
        # Pruefung: Gelenke im Raum, auf die Beckenhoehe bezogen, gegen die Quelle (gleiche Groesse)
        for n in PRUEF:
            qs = QW @ quelle.pose.bones[n].head * F; zs = ZW @ ziel.pose.bones[n].head
            weit = max(weit, (qs - zs).length)
        if fr == f0: ERSTES[name] = {n: (ZW @ ziel.pose.bones[n].head).copy() for n in PRUEF}
    bericht[name] = {'bilder': f1 - f0 + 1, 'abweichung_m': round(weit, 3)}
    print('KAMPF UEBERTRAGEN %-12s %3d Bilder, Gelenke hoechstens %.3f m daneben' % (name, f1 - f0 + 1, weit))

bpy.data.objects.remove(quelle)
for a in [a for a in bpy.data.actions if not a.name.startswith(('Neu_', 'Pro_'))]: bpy.data.actions.remove(a)
for a in bpy.data.actions:
    if a.name.startswith('Neu_'): a.name = a.name[4:]
if ziel.animation_data: ziel.animation_data.action = None
for pb in ziel.pose.bones: pb.rotation_quaternion = (1, 0, 0, 0); pb.location = (0, 0, 0)
bpy.ops.object.select_all(action='DESELECT'); ziel.select_set(True)
os.makedirs(ZIEL, exist_ok=True)
out = os.path.join(ZIEL, 'kampf-bewegungen.glb')
bpy.ops.export_scene.gltf(filepath=out, export_format='GLB', use_selection=True, export_animations=True,
                          export_animation_mode='ACTIONS', export_skins=True, export_force_sampling=True)
# Nachmessen: die geschriebene Datei neu laden (Lauf 31.10.: gleichnamige Quelle „Hieb“ statt „Hieb.001“ exportiert, Arme in T-Pose)
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.context.scene.render.fps = 30
bpy.ops.import_scene.gltf(filepath=out)
neu = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
fehl = 0.0
for name, soll in ERSTES.items():
    akt(neu, bpy.data.actions[name]); bpy.context.scene.frame_set(int(round(bpy.data.actions[name].frame_range[0])))
    for n, v in soll.items(): fehl = max(fehl, (neu.matrix_world @ neu.pose.bones[n].head - v).length)
print('KAMPF NACHGEMESSEN Datei gegen Rechnung hoechstens %.3f m' % fehl)
if fehl > 0.01: raise SystemExit('kampf-bewegungen.glb weicht ab: %.3f m' % fehl)
json.dump({'bewegungen': sorted(a.name for a in bpy.data.actions), 'uebertragen': bericht, 'becken_faktor': round(F, 4),
           'ual': os.path.basename(pro)}, open(os.path.join(ZIEL, 'kampf-bewegungen.json'), 'w'), indent=1, ensure_ascii=False)
print('KAMPF BEWEGUNGEN OK', out, os.path.getsize(out))
