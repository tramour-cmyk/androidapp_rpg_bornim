# 348.6 Kontaktblatt der Kampfbewegungen (kampf.py): je Bewegung eine Zeile Bilder aus drei Richtungen (vorn links, vorn rechts,
# hinten rechts, 15 Grad von oben), Schwert in der rechten Faust laengs faust_R (held-info.json), Schild am linken Unterarm wie
# figur.gd _hold (Ruhelage: Vorderseite nach aussen). Cycles, schlichtes Licht.
# Aufruf: OUT=<ordner mit held3-rig.blend, held-info.json> WAFFEN=<ordner mit longsword.glb, shield.glb> bl/bin/python -I kampfblatt.py
# Ausgabe <OUT>/kampfblatt/<bewegung>.png (Spalten = Zeitpunkte, Zeilen = Richtungen)
import bpy, os, sys, math, json
from mathutils import Vector, Matrix
OUT = os.environ['OUT']; WAF = os.environ.get('WAFFEN', OUT + '/../waffen')
LISTE = os.environ.get('BEWEGUNGEN', 'Kampfstehen:0,Ausholen:0;4;8;12,Hieb:0;4;6;8;9;10;11;14;20;24,Stich:0;3;5;7;8;10;14;18,'
                       'Treffer:0;2;4;8;13,Ausweichen:0;2;4;7;10;13,Abwehr:0;3;5;7,Tod:0;8;16;24;30;36;48;72')
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']; ad = rig.animation_data
INFO = json.load(open(OUT + '/held-info.json'))
scn.render.engine = 'CYCLES'; scn.cycles.samples = 12; scn.cycles.device = 'CPU'
scn.render.resolution_x = 240; scn.render.resolution_y = 320
w = bpy.data.worlds.new('w'); w.use_nodes = True; w.node_tree.nodes['Background'].inputs[0].default_value = (0.35, 0.37, 0.4, 1); scn.world = w
sun = bpy.data.objects.new('sun', bpy.data.lights.new('sun', 'SUN')); scn.collection.objects.link(sun)
sun.data.energy = 3.0; sun.rotation_euler = (math.radians(40), 0, math.radians(-30))
bpy.ops.mesh.primitive_plane_add(size=8); fl = bpy.context.active_object
m = bpy.data.materials.new('boden'); m.use_nodes = True; m.node_tree.nodes['Principled BSDF'].inputs[0].default_value = (0.25, 0.3, 0.2, 1)
fl.data.materials.append(m)
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); scn.collection.objects.link(cam); scn.camera = cam
cam.data.type = 'ORTHO'; cam.data.ortho_scale = 2.6


def lade(name):
    vor = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=os.path.join(WAF, name + '.glb'))
    neu = [o for o in bpy.data.objects if o not in vor and o.type == 'MESH']
    o = neu[0]
    for x in neu[1:]: x.parent = o
    o.parent = None
    return o


schwert, schild = lade('longsword'), lade('shield')
PB = rig.pose.bones
A = Vector(INFO['faust_R']['achse']); G = Vector(INFO['faust_R']['griff'])
RL = rig.data.bones['hand_l'].matrix_local
# Schild wie figur.gd in der Ruhelage der Hand: x vorn, y oben, z aussen (Godot, gespiegelt), Griff 0,35 * 15,7 cm am Knochen, 4 cm aussen
cols = [Vector((0, -1, 0)), Vector((-1, 0, 0)), Vector((0, 0, 1))]   # Spalten in Blender: vorn, -aussen, oben
SCH0 = Matrix([[cols[j][i] for j in range(3)] for i in range(3)]).to_4x4()
SCH0.translation = (RL @ Vector((0, 0.157 * 0.35, 0))) + Vector((0.04, 0, 0))
SCH_REL = RL.inverted() @ SCH0


def setze_waffen():
    H = rig.matrix_world @ PB['hand_r'].matrix; R = H.to_3x3()
    ax = (R @ A).normalized(); y = R.col[1].normalized(); edge = (y - ax * y.dot(ax)).normalized()
    M = Matrix([[edge[i], ax.cross(edge)[i], ax[i]] for i in range(3)]).to_4x4(); M.translation = H @ G
    schwert.matrix_world = M
    schild.matrix_world = rig.matrix_world @ PB['hand_l'].matrix @ SCH_REL


SICHT = [('vorn links', 35), ('vorn rechts', -35), ('hinten rechts', -145)]
os.makedirs(OUT + '/kampfblatt', exist_ok=True)
from PIL import Image, ImageDraw
for eintrag in LISTE.split(','):
    nm, fr = eintrag.split(':'); frames = [int(x) for x in fr.split(';')]
    if nm not in bpy.data.actions: print('fehlt', nm); continue
    for t in ad.nla_tracks: t.mute = True
    act = bpy.data.actions[nm]; ad.action = act; ad.use_nla = False
    if act.slots: ad.action_slot = act.slots[0]
    bilder = []
    for vi, (vn, az) in enumerate(SICHT):
        zeile = []
        for f in frames:
            scn.frame_set(f); setze_waffen()
            a = math.radians(az); el = math.radians(15)
            ziel = Vector((0, 0, 0.85)) if nm != 'Tod' or f < 20 else Vector((0, 0.5, 0.4))
            d = Vector((math.sin(a) * math.cos(el), -math.cos(a) * math.cos(el), math.sin(el)))
            cam.location = ziel + d * 6; cam.rotation_euler = (-d).to_track_quat('-Z', 'Y').to_euler()
            p = OUT + '/kampfblatt/_%s_%d_%d.png' % (nm, vi, f); scn.render.filepath = p
            bpy.ops.render.render(write_still=True); zeile.append(p)
        bilder.append(zeile)
    W_, H_ = 240, 320
    blatt = Image.new('RGB', (W_ * len(frames), H_ * len(SICHT) + 24), (20, 20, 20)); dr = ImageDraw.Draw(blatt)
    for i, f in enumerate(frames): dr.text((i * W_ + 6, 4), '%s %.2f s' % (nm, f / 30.0), fill=(255, 255, 255))
    for r, zeile in enumerate(bilder):
        for c, p in enumerate(zeile):
            blatt.paste(Image.open(p).convert('RGB'), (c * W_, 24 + r * H_)); os.remove(p)
        dr.text((6, 24 + r * H_ + 4), SICHT[r][0], fill=(255, 255, 0))
    blatt.save(OUT + '/kampfblatt/%s.png' % nm)
    print('BLATT', nm, OUT + '/kampfblatt/%s.png' % nm)
