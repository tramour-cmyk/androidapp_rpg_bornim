# Rendert die Passes (Licht, Grundfarbe, Normale, Tiefe, Material-ID) fuer eine Ansicht, je 1 Abtastung, doppelte Aufloesung.
# Aufruf: python -I render.py <name> <azimut_kamera_grad> <hoehe_grad> <drehung_held_grad> <bildhoehe_px>
import bpy, sys, math, os, time, json
import numpy as np
from mathutils import Vector, Matrix

OUT = '/tmp/claude-0/-home-user-androidapp-rpg-bornim/ead9dff2-4f6b-5a16-9d5b-e4aa4f9dade4/scratchpad/blender-held/aldric'
fix = None
raw = sys.argv[sys.argv.index(next(x for x in sys.argv if x.endswith('rk.py'))) + 1:]
WHO = raw.pop(0); CZ = float(raw.pop()); ASP = float(raw.pop())
name, az, el, yaw, hpx = raw[0], float(raw[1]), float(raw[2]), float(raw[3]), int(raw[4])
if len(raw) > 5: fix = float(raw[5])
t0 = time.time()
bpy.ops.wm.open_mainfile(filepath=OUT + '/' + WHO + '.blend')
scn = bpy.context.scene
bpy.context.view_layer.update()

# Kamera orthografisch; Azimut 0 = von vorn (Held blickt nach -Y), positiv = von seiner rechten Seite
cam_d = bpy.data.cameras.new('cam'); cam_d.type = 'ORTHO'
cam = bpy.data.objects.new('cam', cam_d); scn.collection.objects.link(cam); scn.camera = cam
a, e = math.radians(az), math.radians(el)
dirv = Vector((-math.sin(a) * math.cos(e), -math.cos(a) * math.cos(e), math.sin(e)))  # vom Ziel zur Kamera
target = Vector((0, 0, CZ))
cam.location = target + dirv * 600
cam.rotation_euler = (-dirv).to_track_quat('-Z', 'Y').to_euler()
cam_d.clip_start = 1; cam_d.clip_end = 2000
bpy.context.view_layer.update()
# Rahmen: alle sichtbaren Ecken in Kamerakoordinaten
inv = cam.matrix_world.inverted()
dg = bpy.context.evaluated_depsgraph_get()
pts = []
for o in scn.objects:
    if o.type != 'MESH' or o.hide_render: continue
    oe = o.evaluated_get(dg); me = oe.to_mesh()
    mw = o.matrix_world
    co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co); co = co.reshape(-1, 3)
    M = np.array(inv @ mw)
    pts += list((co @ M[:3, :3].T) + M[:3, 3])
    oe.to_mesh_clear()
pts = np.array(pts)
x0, x1 = pts[:, 0].min(), pts[:, 0].max(); y0, y1 = pts[:, 1].min(), pts[:, 1].max()
pad = 0.05 * (y1 - y0)
hgt = (y1 - y0) + 2 * pad; wid = (x1 - x0) + 2 * pad
H2 = hpx * 2
W2 = int(math.ceil(H2 * wid / hgt / 2) * 2)
if fix:
    # feste Groesse und Mitte (Bildstreifen): Fusspunkt-Mitte auf Hoehe 95 cm
    c = inv @ Vector((0, 0, CZ)); x0, x1 = c.x - fix * ASP / 2, c.x + fix * ASP / 2; y0, y1 = c.y - fix / 2, c.y + fix / 2
    pad = 0; hgt = fix; wid = fix * ASP
    W2 = int(math.ceil(H2 * wid / hgt / 2) * 2)
cam_d.ortho_scale = max(hgt, wid)
cam_d.sensor_fit = 'VERTICAL' if hgt >= wid else 'HORIZONTAL'
cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
cam.location = cam.matrix_world @ Vector((cx, cy, 0))
scn.render.resolution_x = W2; scn.render.resolution_y = H2; scn.render.resolution_percentage = 100

# Licht: eine warme Quelle von links oben vorn (vom Betrachter aus), Sonne, harte Schatten
sun_d = bpy.data.lights.new('sun', 'SUN'); sun_d.energy = 1.0; sun_d.angle = 0.0
sun = bpy.data.objects.new('sun', sun_d); scn.collection.objects.link(sun)
la = math.radians(az - 72); le = math.radians(40)
ldir = Vector((-math.sin(la) * math.cos(le), -math.cos(la) * math.cos(le), math.sin(le)))
sun.rotation_euler = (-ldir).to_track_quat('-Z', 'Y').to_euler()
# Boden nur als Schattenfaenger? nein: Figur frei, Schatten am Boden zeichnet die Nachbearbeitung

scn.render.engine = 'CYCLES'
cy_ = scn.cycles
cy_.device = 'CPU'; cy_.samples = 1; cy_.use_denoising = False; cy_.use_adaptive_sampling = False
cy_.max_bounces = 0; cy_.diffuse_bounces = 0; cy_.glossy_bounces = 0; cy_.transmission_bounces = 0
cy_.filter_width = 0.01
cy_.seed = 1
scn.render.film_transparent = True
scn.view_settings.view_transform = 'Standard'
scn.render.image_settings.file_format = 'OPEN_EXR'
scn.render.image_settings.color_depth = '32'
scn.render.image_settings.color_mode = 'RGBA'
w = bpy.data.worlds.new('w'); scn.world = w
w.use_nodes = True
w.node_tree.nodes['Background'].inputs['Strength'].default_value = 0.0

mats = [m for m in bpy.data.materials if m.node_tree and 'M_out' in m.node_tree.nodes]
def set_mode(mode):
    for m in mats:
        nt = m.node_tree; out = nt.nodes['M_out']
        for l in list(out.inputs['Surface'].links): nt.links.remove(l)
        nt.links.new(nt.nodes['M_' + mode].outputs[0], out.inputs['Surface'])

d = OUT + '/passes/' + name
os.makedirs(d, exist_ok=True)
res = {}
for mode in ('light', 'albedo', 'normal', 'depth', 'id', 'ink'):
    set_mode(mode)
    sun.hide_render = mode != 'light'
    scn.render.filepath = d + '/' + mode + '.exr'
    bpy.ops.render.render(write_still=True)
    img = bpy.data.images.load(d + '/' + mode + '.exr')
    px = np.array(img.pixels[:], dtype=np.float32).reshape(H2, W2, 4)[::-1]
    np.save(d + '/' + mode + '.npy', px)
    bpy.data.images.remove(img)
# Lichtrichtung in Kamerabildkoordinaten fuer Goldglanz (Normale ist Weltraum)
json.dump({'ldir': list(ldir), 'view': list(dirv), 'secs': time.time() - t0, 'W': W2, 'H': H2}, open(d + '/meta.json', 'w'))
print('RENDER OK', name, W2, H2, round(time.time() - t0, 1))
