# 348.12 Runde 2 (Jerry): Messskript, Aufruf ~/bl/bin/python -I <dies> [Arg] <Ordner/Datei>
import bpy, sys
bpy.ops.wm.open_mainfile(filepath=sys.argv[-1])
for o in bpy.data.objects:
    if o.type == 'MESH' and o.name.split('.')[0] in ('boots', 'cuff', 'body', 'pants'):
        zs = [(o.matrix_world @ v.co).z for v in o.data.vertices]
        print('OBJ', o.name, len(o.data.vertices), 'z %.1f..%.1f' % (min(zs), max(zs)), [m.name for m in o.data.materials])
for nm in ('boots', 'cuff', 'skin', 'pants'):
    m = bpy.data.materials.get(nm)
    if m: print('MAT', nm, [tuple(round(c, 3) for c in n.outputs[0].default_value[:3]) for n in m.node_tree.nodes if n.type == 'RGB'])
import numpy as np
for nm in ('boots', 'cuff'):
    o = bpy.data.objects[nm]; V = np.array([tuple(o.matrix_world @ v.co) for v in o.data.vertices])
    hi = V[:, 2] > 60
    print('HOCH', nm, hi.sum(), V[hi].round(1)[:12].tolist())
