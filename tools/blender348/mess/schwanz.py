# 348.12 Runde 2 (Jerry): Messskript, Aufruf ~/bl/bin/python -I <dies> [Arg] <Ordner/Datei>
import bpy, sys, numpy as np
bpy.ops.wm.open_mainfile(filepath=sys.argv[-1])
sk = bpy.data.objects['Held_Skelett']; o = next(x for x in bpy.data.objects if x.type == 'MESH' and x.parent == sk)
ad = sk.animation_data; scn = bpy.context.scene
R = np.array([tuple(o.matrix_world @ v.co) for v in o.data.vertices])
sw = R[:, 1] > R[:, 1].max() - 0.25 * (R[:, 1].max() - R[:, 1].min())   # hinterstes Viertel (Blick -Y)
print('SCHWANZ Ecken', sw.sum(), 'ruhe z', R[sw, 2].min().round(3), R[sw, 2].max().round(3), 'y', R[sw, 1].max().round(2))
for nm in ('Stehen', 'Gehen', 'Hieb'):
    tr = ad.nla_tracks[nm]; ad.use_nla = False; ad.action = tr.strips[0].action
    if hasattr(ad, 'action_slot') and ad.action.slots: ad.action_slot = ad.action.slots[0]
    scn.frame_set(0); dg = bpy.context.evaluated_depsgraph_get(); m = o.evaluated_get(dg).to_mesh()
    V = np.array([tuple(o.matrix_world @ v.co) for v in m.vertices])
    i = np.argmax(R[:, 1] * sw)
    print('SCHWANZ', nm, 'Spitze z %.3f' % V[i, 2], 'tiefste Ecke hinten z %.3f' % V[sw, 2].min())
