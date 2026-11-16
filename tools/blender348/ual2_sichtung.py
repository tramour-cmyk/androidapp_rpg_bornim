# 1416 (Chef 16.11., 12:27 zu 1386: „ein Winken irgendwo drin … Hatte ich in dem Video gesehen“): alle Bewegungen der
# gekauften UAL2 (Quaternius) als Kontaktblätter, nicht nur nach Namen; je Bewegung eine Zeile mit BILDER Standbildern
# gleichmäßig über die Länge, von vorn. Läuft nur auf dem Bauserver (416.4a: Kaufmodelle nie in eine Sitzung), ins Artefakt
# gehen nur die gerenderten Blätter, nie die Rohdatei (348.12c a).
# Aufruf: KAUF=<Kaufordner> OUT=<Ziel> [BILDER=8] [NUR=<Anzahl>] [JE_BLATT=12] bl/bin/python -I ual2_sichtung.py
import os, glob, math
import bpy
from mathutils import Vector
from PIL import Image, ImageDraw, ImageFont

KAUF, OUT = os.environ['KAUF'], os.environ['OUT']
N = int(os.environ.get('BILDER', '8'))
JE = int(os.environ.get('JE_BLATT', '12'))
W, H = 220, 280
os.makedirs(OUT, exist_ok=True)

glb = sorted(p for p in glob.glob(KAUF + '/**/UAL2.glb', recursive=True) if 'Unreal-Godot' in p)
assert glb, 'UAL2.glb fehlt unter ' + KAUF
print('GLB', glb[0])
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=glb[0])
arm = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
netze = [o for o in bpy.data.objects if o.type == 'MESH']
print('NETZE', len(netze), [o.name for o in netze][:8])
assert netze, 'UAL2.glb ohne Körper'
aktionen = sorted(bpy.data.actions, key=lambda a: a.name)[:int(os.environ.get('NUR', '9999'))]     # NUR=3 zum Ausprobieren
print('BEWEGUNGEN', len(aktionen))

sc = bpy.context.scene
sc.render.engine = 'CYCLES'
sc.cycles.samples = 8
sc.cycles.use_denoising = False
sc.cycles.device = 'CPU'
sc.render.resolution_x, sc.render.resolution_y = W, H
sc.render.film_transparent = False
welt = bpy.data.worlds.new('w'); sc.world = welt
welt.use_nodes = True
welt.node_tree.nodes['Background'].inputs[0].default_value = (0.82, 0.80, 0.74, 1)
welt.node_tree.nodes['Background'].inputs[1].default_value = 1.0
mat = bpy.data.materials.new('grau'); mat.use_nodes = True
mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (0.25, 0.27, 0.32, 1)
for o in netze:
    o.data.materials.clear(); o.data.materials.append(mat)
licht = bpy.data.objects.new('l', bpy.data.lights.new('l', 'SUN'))
licht.data.energy = 3.0; licht.rotation_euler = (math.radians(50), 0, math.radians(30))
sc.collection.objects.link(licht)
boden = bpy.data.meshes.new('b'); boden.from_pydata([(-3, -3, 0), (3, -3, 0), (3, 3, 0), (-3, 3, 0)], [], [(0, 1, 2, 3)])
bo = bpy.data.objects.new('b', boden); sc.collection.objects.link(bo)
# Kamera von vorn, leicht seitlich und erhöht, orthografisch, fester Ausschnitt für alle Bewegungen (Größen vergleichbar).
# Quaternius-Figuren schauen nach dem glTF-Import nach -Y (am freien UAL1 am Rechner nachgesehen: Laterne in Idle_Torch vorn).
cam = bpy.data.objects.new('c', bpy.data.cameras.new('c')); sc.collection.objects.link(cam); sc.camera = cam
cam.data.type = 'ORTHO'; cam.data.ortho_scale = 2.6
ziel = Vector((0, 0, 1.05))
cam.location = ziel + Vector((1.5, -6.0, 1.2))
cam.rotation_euler = (ziel - cam.location).to_track_quat('-Z', 'Y').to_euler()
try:
    SCHRIFT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 18)
except OSError:
    SCHRIFT = ImageFont.load_default()

if arm.animation_data is None:
    arm.animation_data_create()
zeilen = []
tmp = OUT + '/_bild.png'
for a in aktionen:
    arm.animation_data.action = a
    if hasattr(arm.animation_data, 'action_slot') and a.slots:     # Blender 4.4+: Aktion braucht ihren Platz
        arm.animation_data.action_slot = a.slots[0]
    f0, f1 = (int(round(v)) for v in a.frame_range)
    bilder = []
    for i in range(N):
        sc.frame_set(f0 + round((f1 - f0) * i / max(N - 1, 1)))
        sc.render.filepath = tmp
        bpy.ops.render.render(write_still=True)
        bilder.append(Image.open(tmp).convert('RGB').copy())
    name = a.name.replace('_Loop', '')
    zeilen.append((name, f1 - f0, bilder))
    print('ZEILE', name, f0, f1)

for b in range(0, len(zeilen), JE):
    teil = zeilen[b:b + JE]
    LW = 260
    blatt = Image.new('RGB', (LW + N * W, len(teil) * H), (20, 20, 20))
    d = ImageDraw.Draw(blatt)
    for z, (name, dauer, bilder) in enumerate(teil):
        d.text((8, z * H + H // 2 - 20), '%d %s' % (b + z + 1, name), fill=(235, 200, 90), font=SCHRIFT)
        d.text((8, z * H + H // 2 + 4), '%d Bilder' % dauer, fill=(170, 170, 170), font=SCHRIFT)
        for i, im in enumerate(bilder):
            blatt.paste(im, (LW + i * W, z * H))
    p = '%s/1416-ual2-blatt-%02d.jpg' % (OUT, b // JE + 1)
    blatt.save(p, quality=82)
    print('BLATT', p)
os.remove(tmp)
with open(OUT + '/1416-ual2-namen.txt', 'w') as f:
    f.write('\n'.join('%d %s %d' % (i + 1, n, d) for i, (n, d, _) in enumerate(zeilen)) + '\n')
