# 348.6 CC0 Feinschliff, Diagnose: welche Lage zeigt sich an den schwarzen Stellen? Rendert ein Pruefbild (Bewegung, Bild, Azimut) beleuchtet und mit
# Lagenfarben (Emission, ohne Licht), zaehlt schwarze Bildpunkte und welche Lage dort liegt. ENV: OUT, SHOTS="Gehen:24:90 Stehen:1:0" (Bewegung:Bild:Azimut wie pruefblatt.py), BOX=x0,x1,y0,y1
import bpy, os, math, json
import numpy as np
from mathutils import Vector
from mathutils.kdtree import KDTree
OUT = os.environ['OUT']
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3.blend')
TEILE = {}
for o in bpy.data.objects:
    if o.type != 'MESH': continue
    n = o.name.split('.')[0]
    dg = bpy.context.evaluated_depsgraph_get(); m = o.evaluated_get(dg).to_mesh()
    TEILE.setdefault(n, []).extend([tuple(o.matrix_world @ v.co) for v in m.vertices]); o.evaluated_get(dg).to_mesh_clear()
NAMEN = sorted(TEILE); kd = KDTree(sum(len(p) for p in TEILE.values())); TI = []
for t, n in enumerate(NAMEN):
    for p in TEILE[n]: kd.insert(Vector(p) * 0.01, len(TI)); TI.append(t)
kd.balance()
bpy.ops.wm.open_mainfile(filepath=OUT + '/held3-rig.blend')
scn = bpy.context.scene; rig = bpy.data.objects['Held_Skelett']; me_o = bpy.data.objects['Held_Netz']
for t in rig.animation_data.nla_tracks: t.mute = True
rig.animation_data.action = None
for pb in rig.pose.bones: pb.location = (0, 0, 0); pb.rotation_mode = 'QUATERNION'; pb.rotation_quaternion = (1, 0, 0, 0)
scn.frame_set(0)
dg = bpy.context.evaluated_depsgraph_get(); ev = me_o.evaluated_get(dg); mm = ev.to_mesh()
TEIL = [TI[kd.find(ev.matrix_world @ v.co)[1]] for v in mm.vertices]; ev.to_mesh_clear()
rng = np.random.default_rng(3); FARBE = rng.uniform(0.15, 1.0, (len(NAMEN), 3))
ca = me_o.data.color_attributes.new('teil', 'FLOAT_COLOR', 'POINT')
ca.data.foreach_set('color', np.concatenate([np.append(FARBE[t], 1.0) for t in TEIL]).astype(np.float32))
alt = list(me_o.data.materials); mt = bpy.data.materials.new('teil'); mt.use_nodes = True; nt = mt.node_tree
for n in list(nt.nodes): nt.nodes.remove(n)
at = nt.nodes.new('ShaderNodeAttribute'); at.attribute_name = 'teil'; em = nt.nodes.new('ShaderNodeEmission'); ou = nt.nodes.new('ShaderNodeOutputMaterial')
nt.links.new(at.outputs['Color'], em.inputs['Color']); nt.links.new(em.outputs[0], ou.inputs['Surface'])
scn.render.engine = 'CYCLES'; scn.cycles.samples = 16; scn.cycles.device = 'CPU'
w = bpy.data.worlds.new('w'); w.use_nodes = True; w.node_tree.nodes['Background'].inputs[0].default_value = (0.30, 0.32, 0.30, 1); scn.world = w
sun = bpy.data.objects.new('sun', bpy.data.lights.new('sun', 'SUN')); scn.collection.objects.link(sun)
sun.data.energy = 3.2; sun.rotation_euler = (math.radians(40), 0, math.radians(35))
bpy.ops.mesh.primitive_plane_add(size=6)
cam = bpy.data.objects.new('cam', bpy.data.cameras.new('cam')); scn.collection.objects.link(cam); scn.camera = cam; cam.data.type = 'ORTHO'
acts = {t.name: t.strips[0].action for t in rig.animation_data.nla_tracks}
def bild(pfad):
    scn.render.filepath = pfad; bpy.ops.render.render(write_still=True)
    from PIL import Image
    return np.asarray(Image.open(pfad).convert('RGB')).astype(int)
for sh in os.environ['SHOTS'].split():
    an, f, az = sh.split(':'); f = int(f); az = float(az)
    rig.animation_data.action = acts[an]; scn.frame_set(f)
    el = 20 if an == 'Stehen' else 15; scn.render.resolution_x = 220 if an == 'Stehen' else 260; scn.render.resolution_y = 320
    e = math.radians(el); a = math.radians(az); d = Vector((math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))
    cam.location = Vector((0, 0, 0.95)) + d * 6.0; cam.rotation_euler = (-d).to_track_quat('-Z', 'Y').to_euler(); cam.data.ortho_scale = 2.2
    me_o.data.materials.clear(); [me_o.data.materials.append(m) for m in alt]
    vt = scn.view_settings.view_transform; A = bild(OUT + '/dunkel_%s_%d.png' % (an, f)); scn.view_settings.view_transform = 'Standard'
    me_o.data.materials.clear(); me_o.data.materials.append(mt)
    B = bild(OUT + '/teile_%s_%d.png' % (an, f)); scn.view_settings.view_transform = vt
    dunkel = A.max(2) < 25; zahl = {}
    if os.environ.get('BOX'):
        x0, x1, y0, y1 = map(int, os.environ['BOX'].split(',')); bx = np.zeros_like(dunkel); bx[y0:y1, x0:x1] = True; dunkel &= bx
    for p in B[dunkel]:
        c = p / 255.0; t = int(np.argmin(np.linalg.norm(np.where(FARBE <= 0.0031308, 12.92 * FARBE, 1.055 * FARBE ** (1 / 2.4) - 0.055) - c, axis=1)))
        zahl[NAMEN[t]] = zahl.get(NAMEN[t], 0) + 1
    ys, xs = np.where(dunkel)
    print('DUNKEL', sh, int(dunkel.sum()), dict(sorted(zahl.items(), key=lambda x: -x[1])), 'x', (int(xs.min()), int(xs.max())) if len(xs) else '', 'y', (int(ys.min()), int(ys.max())) if len(ys) else '')
