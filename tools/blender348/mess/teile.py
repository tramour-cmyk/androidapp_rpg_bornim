# 348.12 Runde 2 (Jerry): Messskript, Aufruf ~/bl/bin/python -I <dies> [Arg] <Ordner/Datei>
import bpy, sys, numpy as np
bpy.ops.wm.open_mainfile(filepath=sys.argv[-1])
for o in bpy.data.objects:
    if o.type != 'MESH': continue
    V = np.array([tuple(o.matrix_world @ v.co) for v in o.data.vertices])
    if not len(V): continue
    print('T %-22s %5d x %6.1f..%6.1f y %6.1f..%6.1f z %6.1f..%6.1f' % (o.name, len(V), V[:,0].min(), V[:,0].max(), V[:,1].min(), V[:,1].max(), V[:,2].min(), V[:,2].max()))
