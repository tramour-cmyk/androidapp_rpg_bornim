# Kontaktblatt der Bewegung: 8 Bilder Gehen von der Seite, dazu vorn und nah (Hand, Gesicht). Cycles, schlichtes Licht.
import bpy, os, sys, math
from mathutils import Vector
OUT = os.environ['OUT']; ACT = os.environ.get('ACT', 'Gehen')
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']
scn.render.engine = 'CYCLES'; scn.cycles.samples = 16; scn.cycles.device = 'CPU'
scn.render.resolution_x = 260; scn.render.resolution_y = 400; scn.render.film_transparent = False
w = bpy.data.worlds.new('w'); w.use_nodes = True; w.node_tree.nodes['Background'].inputs[0].default_value = (0.35, 0.37, 0.4, 1); scn.world = w
# Material: Albedo aus Eckfarben auf Diffus (Principled war im Export)
sun = bpy.data.objects.new('sun', bpy.data.lights.new('sun', 'SUN')); scn.collection.objects.link(sun)
sun.data.energy = 3.0; sun.rotation_euler = (math.radians(50), 0, math.radians(30))
bpy.ops.mesh.primitive_plane_add(size=600); fl = bpy.context.active_object
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); scn.collection.objects.link(cam); scn.camera = cam
cam.data.type = 'ORTHO'
for t in rig.animation_data.nla_tracks: t.mute = True
act = bpy.data.actions[ACT]; rig.animation_data.action = act
if act.slots: rig.animation_data.action_slot = act.slots[0]
def shot(path, frame, loc, rot, scale, aim=None):
    scn.frame_set(frame); cam.location = loc; cam.rotation_euler = rot; cam.data.ortho_scale = scale
    if aim: cam.rotation_euler = (Vector(aim) - Vector(loc)).to_track_quat('-Z', 'Y').to_euler()
    scn.render.filepath = path; bpy.ops.render.render(write_still=True)
n = int(bpy.data.actions[ACT].frame_range[1]) - 1
for i in range(8):
    f = 1 + round(i * n / 8)
    shot(OUT + '/blatt/s%d.png' % i, f, (260, 0, 95), (math.radians(90), 0, math.radians(90)), 210)
shot(OUT + '/blatt/vorn.png', 1, (0, -260, 95), (math.radians(90), 0, 0), 210)
shot(OUT + '/blatt/hand.png', 1, (-140, -140, 88), (0, 0, 0), 30, aim=(-25, -2, 86))
shot(OUT + '/blatt/kopf.png', 1, (0, -200, 160), (math.radians(90), 0, 0), 40)
shot(OUT + '/blatt/vorn-schwung.png', 1 + round(n / 4), (0, -260, 95), (math.radians(90), 0, 0), 210)
shot(OUT + '/blatt/hand-schwung.png', 1 + round(n / 4), (-140, -140, 88), (0, 0, 0), 40, aim=(-25, -10, 86))
