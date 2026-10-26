# Pruefblatt einer Figur: Ruhehaltung vorn, rechts, hinten, links (45 Grad wie Spielkamera), Kopf nah vorn/seitlich/hinten,
# Gehen seitlich zwei Phasen, Stehen Bild 1. Aufruf: OUT=<figurordner> python -I pruefblatt.py -> <OUT>/pb/*.png
import bpy, os, math, json
from mathutils import Vector
OUT = os.environ['OUT']
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']
scn.render.engine = 'CYCLES'; scn.cycles.samples = 16; scn.cycles.device = 'CPU'
w = bpy.data.worlds.new('w'); w.use_nodes = True; w.node_tree.nodes['Background'].inputs[0].default_value = (0.30, 0.32, 0.30, 1); scn.world = w
sun = bpy.data.objects.new('sun', bpy.data.lights.new('sun', 'SUN')); scn.collection.objects.link(sun)
sun.data.energy = 3.2; sun.rotation_euler = (math.radians(40), 0, math.radians(35))
bpy.ops.mesh.primitive_plane_add(size=6)
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); scn.collection.objects.link(cam); scn.camera = cam
cam.data.type = 'ORTHO'
G = json.load(open(OUT + '/gelenke.json'))['J']
def rest():
    for t in rig.animation_data.nla_tracks: t.mute = True
    rig.animation_data.action = None
    for pb in rig.pose.bones:
        pb.location = (0, 0, 0); pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = (1, 0, 0, 0); pb.scale = (1, 1, 1)
    scn.frame_set(1)
def shot(name, az, el, mid, scale, rx, ry):
    scn.render.resolution_x = rx; scn.render.resolution_y = ry
    e = math.radians(el); a = math.radians(az)
    d = Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))
    cam.location = mid + d * 6.0
    cam.rotation_euler = (-d).to_track_quat('-Z', 'Y').to_euler()
    cam.data.ortho_scale = scale
    scn.render.filepath = OUT + '/pb/' + name + '.png'; bpy.ops.render.render(write_still=True)
rest()
hz = G['neckTop'][0][2] * 0.01 + 0.1
for n, az in (('a_vorn', 0), ('b_rechts', 90), ('c_hinten', 180), ('d_links', 270)):
    shot(n, az, 45, Vector((0, 0, 0.95)), 2.4, 260, 360)
for n, az in (('e_kopf_vorn', 0), ('f_kopf_seite', 90), ('g_kopf_hinten', 180)):
    shot(n, az, 20, Vector((0, G['neckTop'][0][1] * 0.01 - 0.03, hz)), 0.6, 240, 240)   # Helfer 4c: Gebeugten hing der Kopf aus dem Bild
# Gehen: Aktion aus der NLA
acts = {t.name: t.strips[0].action for t in rig.animation_data.nla_tracks}
for t in rig.animation_data.nla_tracks: t.mute = True
for an, frames in (('Gehen', None), ('Stehen', [1])):
    if an not in acts: continue
    act = acts[an]; rig.animation_data.action = act
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    fs = frames or [f0, f0 + (f1 - f0) // 4, f0 + (f1 - f0) // 2]
    for i, f in enumerate(fs):
        scn.frame_set(f)
        if an == 'Stehen':
            for j, az in enumerate((0, 90, 270)): shot('h_stehen%d' % j, az, 20, Vector((0, 0, 0.95)), 2.2, 220, 320)
        else: shot('h_%s%d' % (an.lower(), i), 90, 15, Vector((0, 0, 0.95)), 2.2, 260, 320)
# CC0-Geruest Runde 2 (Fremdpruefung Tom 34): beim Helden auch Rennen (seitlich, von hinten: Schild) und die Fackel
for an, az, nm in (('Rennen', 90, 'i_rennen'), ('Rennen', 180, 'i_rennen_hinten'), ('Stehen_Fackel', 60, 'j_fackel_stehen'),
                   ('Gehen_Fackel', 90, 'j_fackel_gehen'), ('Rennen_Fackel', 90, 'j_fackel_rennen')):
    if an not in acts: continue
    act = acts[an]; rig.animation_data.action = act
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    for i, f in enumerate((f0, f0 + (f1 - f0) // 3) if nm.startswith('i') else (f0 + (f1 - f0) // 4,)):
        scn.frame_set(f); shot('%s%d' % (nm, i), az, 15, Vector((0, 0, 0.95)), 2.2, 260, 320)
print('PB OK')
