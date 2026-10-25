# 348.6 Leute: Entwurfsbild einer Figur von vorn und hinten, schraeg von oben wie die Spielkamera (45 Grad), Cycles, schlichtes Licht.
# Aufruf: OUT=<ordner> python -I leute_blatt.py   (vorher held3.py mit FIGUR und rig.py mit demselben OUT); Bilder in <OUT>/blatt/
import bpy, os, math, json
from mathutils import Vector
OUT = os.environ['OUT']
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']
scn.render.engine = 'CYCLES'; scn.cycles.samples = 24; scn.cycles.device = 'CPU'
scn.render.resolution_x = 300; scn.render.resolution_y = 420
w = bpy.data.worlds.new('w'); w.use_nodes = True; w.node_tree.nodes['Background'].inputs[0].default_value = (0.30, 0.32, 0.30, 1); scn.world = w
sun = bpy.data.objects.new('sun', bpy.data.lights.new('sun', 'SUN')); scn.collection.objects.link(sun)
sun.data.energy = 3.2; sun.rotation_euler = (math.radians(40), 0, math.radians(35))
bpy.ops.mesh.primitive_plane_add(size=6)
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); scn.collection.objects.link(cam); scn.camera = cam
cam.data.type = 'ORTHO'
for t in rig.animation_data.nla_tracks: t.mute = True
rig.animation_data.action = None   # Ruhehaltung (Runde 2: Stehen hob ein Bein, Rock knickte)
for pb in rig.pose.bones:   # ohne Bewegung bleibt sonst die zuletzt gebackene Haltung stehen (Runde 2: Gehen)
    pb.location = (0, 0, 0); pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = (1, 0, 0, 0); pb.scale = (1, 1, 1)
scn.frame_set(1)
G = json.load(open(OUT + '/gelenke.json'))['J']
h = G['neckTop'][0][2] * 0.01 + 0.2                       # Scheitel in m
mid = Vector((0, 0, 0.95))                              # alle im selben Massstab (Kind klein, Zwerg kurz)
for name, az in (('vorn', 0.0), ('hinten', 180.0)):
    el = math.radians(45); a = math.radians(az)
    d = Vector((math.sin(a) * math.cos(el), -math.cos(a) * math.cos(el), math.sin(el)))
    cam.location = mid + d * 6.0
    cam.rotation_euler = (-d).to_track_quat('-Z', 'Y').to_euler()
    cam.data.ortho_scale = 2.4
    scn.render.filepath = OUT + '/blatt/' + name + '.png'; bpy.ops.render.render(write_still=True)
print('BLATT OK', h)
