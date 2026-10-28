# 348.12 Runde 2 (Jerry): Messskript, Aufruf ~/bl/bin/python -I <dies> [Arg] <Ordner/Datei>
import bpy, sys, math
from mathutils import Vector
bpy.ops.wm.open_mainfile(filepath=sys.argv[-1])
sk = bpy.data.objects['Held_Skelett']; ad = sk.animation_data; scn = bpy.context.scene
P = sk.pose.bones
def W(b, t=False): return sk.matrix_world @ (P[b].tail if t else P[b].head)
for tr in ad.nla_tracks:
    ad.use_nla = False; ad.action = tr.strips[0].action
    if hasattr(ad, 'action_slot') and ad.action.slots: ad.action_slot = ad.action.slots[0]
    n = int(tr.strips[0].action.frame_range[1])
    for f in sorted({0, n // 4, n // 2}):
        scn.frame_set(f); bpy.context.view_layer.update()
        knie = {s: math.degrees((W('calf_'+s) - W('thigh_'+s)).angle(W('foot_'+s) - W('calf_'+s))) for s in 'lr'}
        hv = (sk.matrix_world.to_3x3() @ P['Head'].matrix.to_3x3() @ Vector((0, 0, 0)))
        kopf = W('Head', True) - W('Head'); neig = math.degrees(math.atan2(kopf.y * -1, kopf.z))
        rumpf = W('neck_01') - W('pelvis'); lean = math.degrees(math.atan2(-rumpf.y, rumpf.z))
        print('%s %2d Becken %.2f Knie l %.0f r %.0f | Ferse l %.2f r %.2f Ballen l %.2f r %.2f | Rumpf vor %.0f Kopfachse vor %.0f Scheitel %.2f' % (
            tr.name, f, W('pelvis').z, knie['l'], knie['r'], W('foot_l').z, W('foot_r').z, W('ball_l').z, W('ball_r').z, lean, neig, W('Head', True).z))
