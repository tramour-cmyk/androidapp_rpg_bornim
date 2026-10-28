# 348.12 Runde 2 (Jerry): Messskript, Aufruf ~/bl/bin/python -I <dies> [Arg] <Ordner/Datei>
import bpy, sys, math
from mathutils import Vector
bpy.ops.wm.read_factory_settings(use_empty=True); bpy.ops.import_scene.gltf(filepath=sys.argv[-1])
sk = next(o for o in bpy.data.objects if o.type == 'ARMATURE'); P = sk.pose.bones; scn = bpy.context.scene
me = [o for o in bpy.data.objects if o.type == 'MESH']
def W(b): return sk.matrix_world @ P[b].head
print('AKTIONEN', [a.name for a in bpy.data.actions])
for a in bpy.data.actions:
    sk.animation_data_create(); sk.animation_data.action = a
    if hasattr(sk.animation_data, 'action_slot') and a.slots: sk.animation_data.action_slot = a.slots[0]
    scn.frame_set(int(a.frame_range[0])); bpy.context.view_layer.update()
    dg = bpy.context.evaluated_depsgraph_get()
    top = max(max((o.matrix_world @ v.co).z for v in o.evaluated_get(dg).to_mesh().vertices) for o in me)
    knie = math.degrees((W('calf_l') - W('thigh_l')).angle(W('foot_l') - W('calf_l')))
    print('GLB %s Becken %.2f Kopf %.2f Oberkante %.2f Knie %.0f' % (a.name, W('pelvis').z, W('Head').z, top, knie))
import numpy as np
a = bpy.data.actions['Stehen']; sk.animation_data.action = a
if hasattr(sk.animation_data, 'action_slot') and a.slots: sk.animation_data.action_slot = a.slots[0]
scn.frame_set(int(a.frame_range[0])); bpy.context.view_layer.update(); dg = bpy.context.evaluated_depsgraph_get()
for o in me:
    ev = o.evaluated_get(dg).to_mesh(); V = np.array([tuple(o.matrix_world @ v.co) for v in ev.vertices])
    R = np.array([tuple(o.matrix_world @ v.co) for v in o.data.vertices])
    print('NETZ', o.name, len(V), 'z', V[:, 2].min().round(2), V[:, 2].max().round(2), 'ruhe z', R[:, 2].min().round(2), R[:, 2].max().round(2), 'mods', [m.type for m in o.modifiers], 'parent', o.parent.name if o.parent else None)
    hi = V[:, 2] > 0.75
    if hi.any(): print('  hoch', hi.sum(), 'ruhe', R[hi].mean(0).round(2), 'gruppen', sorted({o.vertex_groups[g.group].name for i in np.where(hi)[0][:50] for g in o.data.vertices[i].groups})[:8])
