# 385: Stab des Protofactor-Zauberer-Sets (SM_WizardStaffProp.fbx, gekauft) als .glb fuer figurenprobe.gd (daten/waffen/stab.bin).
# Ursprung am Griff, Kopf oben (+Y in Godot). Aufruf: QUELLE=<SM_WizardStaffProp.fbx> OUT=<stab.glb> bl/bin/python -I stab385.py
import bpy, os

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.fbx(filepath=os.environ['QUELLE'])
ms = [o for o in bpy.data.objects if o.type == 'MESH']
for o in bpy.data.objects:
    o.select_set(o in ms)
bpy.context.view_layer.update()
zs = [(o.matrix_world @ v.co).z for o in ms for v in o.data.vertices]
print('STAB385', len(ms), 'Teile, unten %.2f oben %.2f m' % (min(zs), max(zs)))
bpy.ops.export_scene.gltf(filepath=os.environ['OUT'], export_format='GLB', use_selection=True, export_animations=False)
