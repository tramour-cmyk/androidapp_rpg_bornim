# 348.7 (Jerry): Prüfwerkzeug: Rückenlinie und Brustunterkante eines Vierbeiners aus der .glb in einer Bewegung (ANIM=Stehen),
# je 5-cm-Scheibe längs; Aufruf: ANIM=Stehen ~/bl/bin/python -I profil.py <datei.glb>
import bpy, sys, numpy as np
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=sys.argv[-1])
import os
A = os.environ.get('ANIM', 'Stehen')
for o in bpy.context.scene.objects:
    if o.type == 'ARMATURE':
        o.animation_data_create()
        acts = [a for a in bpy.data.actions if a.name.startswith(A)]
        if acts:
            o.animation_data.action = acts[0]
            try: o.animation_data.action_slot = acts[0].slots[0]
            except Exception: pass
        for t in list(o.animation_data.nla_tracks): o.animation_data.nla_tracks.remove(t)
bpy.context.scene.frame_set(1)
dg = bpy.context.evaluated_depsgraph_get()
V = []
for o in bpy.context.scene.objects:
    if o.type == 'MESH':
        e = o.evaluated_get(dg); M = e.matrix_world
        V += [(M @ v.co)[:] for v in e.data.vertices]
print('Bewegung', A, [a.name for a in bpy.data.actions][:12])
V = np.array(V); y0, y1 = V[:, 1].min(), V[:, 1].max()
print('Laenge y %.2f..%.2f  Hoehe max %.3f' % (y0, y1, V[:, 2].max()))
for y in np.arange(round(y0, 1), y1, 0.05):
    s = V[(V[:, 1] >= y) & (V[:, 1] < y + 0.05) & (np.abs(V[:, 0]) < 0.06)]
    if len(s): 
        rumpf = s[s[:, 2] > 0.3]
        print('y %+.2f  oben %.3f  unten(Rumpf) %s' % (y, s[:, 2].max(), '%.3f' % rumpf[:, 2].min() if len(rumpf) else '-'))
