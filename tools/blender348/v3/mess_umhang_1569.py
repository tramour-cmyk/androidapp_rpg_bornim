# 1569 Messung (Tom 18.11.): Robe M (held_ROBE_M.bin, unter_CLOAK an) gegen Schrankteil UMHANG in der Bewegung Stehen; zaehlt Ecken, die hinten
# durch den Umhang stechen, dazu Leib und Verschiebung im Schluessel. Aufruf nach bau_am_rechner.py --cache: ~/bl/bin/python tools/blender348/v3/mess_umhang_1569.py
import bpy, numpy as np, shutil
from mathutils import Vector
from mathutils.bvhtree import BVHTree
D='/home/user/androidapp_rpg_bornim/godot/daten/'
def imp(f):
    shutil.copy(D+f,'/tmp/claude-0/x.glb'); vor=set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath='/tmp/claude-0/x.glb'); return [o for o in bpy.data.objects if o not in vor]
bpy.ops.wm.read_factory_settings(use_empty=True)
held=imp('held_ROBE_M.bin'); arm=next(o for o in held if o.type=='ARMATURE')
um=imp('schrank_M_UMHANG.bin'); cl=[o for o in um if o.type=='MESH' and o.name.startswith('Teil')]
for o in cl:
    for md in o.modifiers:
        if md.type=='ARMATURE': md.object=arm
bw=imp('bewegungen.bin'); a=bpy.data.actions.get('Stehen') or next(x for x in bpy.data.actions if x.name.startswith('Stehen'))
arm.animation_data_create(); arm.animation_data.action=a
if hasattr(arm.animation_data,'action_slot') and a.slots: arm.animation_data.action_slot=a.slots[0]
robe=next(o for o in held if o.name=='Kleid_CHEST'); leibe=[o for o in held if o.name.startswith('Leib_')]
for k in robe.data.shape_keys.key_blocks: k.value = 1.0 if k.name=='unter_CLOAK' else 0.0
for fr in (int(a.frame_range[0]), int((a.frame_range[0]+a.frame_range[1])/2)):
    bpy.context.scene.frame_set(fr); dg=bpy.context.evaluated_depsgraph_get()
    V=[];F=[]
    for o in cl:
        e=o.evaluated_get(dg); m=e.to_mesh(); b=len(V)
        V+=[e.matrix_world@v.co for v in m.vertices]; F+=[[b+i for i in p.vertices] for p in m.polygons]
    bv=BVHTree.FromPolygons(V,F)
    e=robe.evaluated_get(dg); m=e.to_mesh(); P=np.array([e.matrix_world@v.co for v in m.vertices])
    cy=np.mean([v.y for v in V]); s=1 if cy>P[:,1].mean() else -1; d=Vector((0,s,0))
    raus=[]
    for p in P:
        if (p[1]-P[:,1].mean())*s<0: continue
        if bv.ray_cast(Vector(p)-d*0.3, d, 0.3)[0] is not None and bv.ray_cast(Vector(p),d,1.0)[0] is None: raus.append(p)
    raus=np.array(raus)
    zc=np.array([v.z for v in V])
    print('Bild',fr,'Umhang z %.2f-%.2f'%(zc.min(),zc.max()),'Robe z %.2f-%.2f'%(P[:,2].min(),P[:,2].max()),'Robe hinten vor dem Umhang:',len(raus), ('z %.2f-%.2f'%(raus[:,2].min(),raus[:,2].max())) if len(raus) else '')
    if len(raus): 
        h,_=np.histogram(raus[:,2],bins=[0,0.3,0.5,0.7,0.9,1.1,1.3,1.6]); print('  je Hoehe', h)
print('---- Leib (ohne Robe) gegen Umhang, Bild 0 und Robe nach Hoehe/Seite')
bpy.context.scene.frame_set(int(a.frame_range[0])); dg=bpy.context.evaluated_depsgraph_get()
V=[];F=[]
for o in cl:
    e=o.evaluated_get(dg); m=e.to_mesh(); b=len(V)
    V+=[e.matrix_world@v.co for v in m.vertices]; F+=[[b+i for i in p.vertices] for p in m.polygons]
bv=BVHTree.FromPolygons(V,F)
for o in leibe:
    e=o.evaluated_get(dg); m=e.to_mesh(); P=np.array([e.matrix_world@v.co for v in m.vertices])
    n=0
    for p in P:
        if (p[1]-0.05)*s<0: continue
        if bv.ray_cast(Vector(p)-d*0.3, d, 0.3)[0] is not None and bv.ray_cast(Vector(p),d,1.0)[0] is None: n+=1
    print(o.name, len(P), 'hinter dem Umhang hervor', n)
e=robe.evaluated_get(dg); m=e.to_mesh(); P=np.array([e.matrix_world@v.co for v in m.vertices])
R=[p for p in P if (p[1]-P[:,1].mean())*s>0 and bv.ray_cast(Vector(p)-d*0.3, d, 0.3)[0] is not None and bv.ray_cast(Vector(p),d,1.0)[0] is None]
R=np.array(R); print('Robe raus x %.2f..%.2f'%(R[:,0].min(),R[:,0].max()), 'Umhang x %.2f..%.2f'%(min(v.x for v in V),max(v.x for v in V)))
h,_=np.histogram(np.abs(R[:,0]),bins=[0,0.05,0.1,0.15,0.2,0.25,0.3,0.5]); print('je |x|',h)
print('---- Verschiebung der Durchstecher im Schluessel')
kb=robe.data.shape_keys.key_blocks
B=np.array([v.co[:] for v in kb['Basis'].data]); U=np.array([v.co[:] for v in kb['unter_CLOAK'].data]); dd=np.linalg.norm(U-B,axis=1)
idx=[i for i,p in enumerate(P) if (p[1]-P[:,1].mean())*s>0 and bv.ray_cast(Vector(p)-d*0.3, d, 0.3)[0] is not None and bv.ray_cast(Vector(p),d,1.0)[0] is None]
x=dd[idx]; print('Durchstecher', len(idx), 'davon verschoben', int((x>1e-4).sum()), 'Mittel %.3f'%x.mean())
# Ruhelage dieser Ecken: Abstand zum Umhang in Ruhe
bpy.context.scene.frame_set(0)
arm.animation_data.action=None
for pb in arm.pose.bones: pb.matrix_basis.identity()
dg=bpy.context.evaluated_depsgraph_get(); dg.update()
e=robe.evaluated_get(dg); m=e.to_mesh(); P0=np.array([e.matrix_world@v.co for v in m.vertices])
V=[];F=[]
for o in cl:
    e2=o.evaluated_get(dg); m2=e2.to_mesh(); b=len(V)
    V+=[e2.matrix_world@v.co for v in m2.vertices]; F+=[[b+i for i in p.vertices] for p in m2.polygons]
bv0=BVHTree.FromPolygons(V,F)
hin=[bv0.ray_cast(Vector(P0[i]), d, 0.5)[0] is not None for i in idx]
vor=[bv0.ray_cast(Vector(P0[i]), -d, 0.5)[0] is not None for i in idx]
print('in Ruhe: Umhang dahinter', sum(hin), 'Umhang davor', sum(vor), 'y Mittel Robe %.3f'%P0[:,1].mean(), 'Ecke y', np.round(P0[idx[:5],1],3), 'z', np.round(P0[idx[:5],2],2))
