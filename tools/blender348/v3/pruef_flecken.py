# 376.1 Urteil Tracht (Chef 01.11., 20:2x): „Farbstreifen durch den Umhang“ (Wachsoldat), „Knie durch … zwischen den Knien ein Fleck
# und auf Brusthoehe ein Fleck“ (Zauberlehrling). Misst, was die Kamera sieht, ohne Bild: Strahlen von der Kamera auf die fertige Figur
# (held_<TRACHT>_<G>.glb aus held_klassen.py, mit Stiefeln und Statur) in UAL-Bewegungen; je Strahl die erste Flaeche und ihr Teil
# (Kleid-Teile aus der Rohfigur roh/held_<k>.blend, Attribut 'teil'; sonst das Netz: Koerper, Stiefel, Augen …). Godot zeichnet beidseitig
# (toon.gdshader cull_disabled): trifft der Strahl die Innenseite eines Teils, zaehlt sie als „<teil>/innen“.
# Fleck: ein Feld fremder Bildpunkte, das ganz von einem Huellenteil (Umhang, Robe) umschlossen ist (Rand zu mindestens 90 % Huelle).
# Aufruf: GLB=<held_X.glb> ROH=<roh/held_X.blend> TEILE=<teile.json> UAL=<UAL1_Standard.glb> [HUELLE=cloak] [BEW=..] bl/bin/python -I pruef_flecken.py
import bpy, os, json, math
import numpy as np
from mathutils import Vector, Matrix
from mathutils.bvhtree import BVHTree
from mathutils.kdtree import KDTree

GLB = os.environ['GLB']; ROH = os.environ['ROH']; UAL = os.environ['UAL']
TEILNAMEN = json.load(open(os.environ['TEILE']))
HUELLE = os.environ.get('HUELLE', 'cloak,robe').split(',')
BEW = os.environ.get('BEW', 'Ruhe,Idle_Loop,Walk_Loop,Jog_Fwd_Loop,Sword_Attack,Hit_Chest').split(',')
BILDER = int(os.environ.get('BILDER', '6'))
SICHT = [(float(a), float(e)) for a, e in (s.split('/') for s in os.environ.get('SICHT', '0/10,45/30,90/10,135/30,180/10,180/30,225/30,270/10,315/30').split(','))]
AUF = float(os.environ.get('AUF', '0.006'))   # m je Bildpunkt
WO = os.environ.get('WO', '')                 # „<bewegung>“: Mittelpunkte der Flecken ausgeben

# Teile der Rohfigur (Ruhelage)
bpy.ops.wm.open_mainfile(filepath=ROH)
rk = bpy.data.objects['Kleid']
tl = np.zeros(len(rk.data.vertices), dtype=int); rk.data.attributes['teil'].data.foreach_get('value', tl)
kd = KDTree(len(rk.data.vertices))
for i, v in enumerate(rk.data.vertices): kd.insert(rk.matrix_world @ v.co, i)
kd.balance()

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=GLB)
qa = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
netze = [o for o in bpy.data.objects if o.type == 'MESH' and o.find_armature() == qa]
kleid = next(o for o in netze if o.name.startswith('Kleid'))
KT = np.zeros(len(kleid.data.vertices), dtype=int); weit = 0
for i, v in enumerate(kleid.data.vertices):
    _, j, d = kd.find(kleid.matrix_world @ v.co); KT[i] = tl[j]; weit += d > 0.003
print('TEILE ZUGEORDNET', len(KT), 'Ecken, weiter als 3 mm:', weit)
vorher = set(bpy.data.actions)
bpy.ops.import_scene.gltf(filepath=UAL)
for o in [o for o in bpy.data.objects if o != qa and o not in netze]: bpy.data.objects.remove(o)
AKT = {a.name.split('|')[-1]: a for a in bpy.data.actions if a not in vorher}
dg = bpy.context.evaluated_depsgraph_get()

def name_netz(o):
    n = o.name.lower()
    if 'feet' in n or 'boot' in n: return 'stiefel'
    if 'eye' in n: return 'augen'
    return 'koerper'

def lage():
    dg.update()
    V, F, LF = [], [], []
    for o in netze:
        me = o.evaluated_get(dg).to_mesh(); b = len(V); M = o.matrix_world
        V += [M @ v.co for v in me.vertices]
        for p in me.polygons:
            vs = tuple(b + i for i in p.vertices); F.append(vs)
            LF.append(TEILNAMEN[KT[p.vertices[0]]] if o == kleid else name_netz(o))
        o.evaluated_get(dg).to_mesh_clear()
    return V, F, LF

def sehen(V, F, LF, az, el):
    bv = BVHTree.FromPolygons(V, F)
    P = np.array(V); mn, mx = P.min(0), P.max(0); c = Vector(((mn + mx) / 2).tolist())
    a, e = math.radians(az), math.radians(el)
    # Kamera vor der Figur bei az 0: Figur blickt -Y, also steht die Kamera bei -Y und blickt +Y
    d = Vector((math.sin(a) * math.cos(e), math.cos(a) * math.cos(e), -math.sin(e)))
    rechts = d.cross(Vector((0, 0, 1))).normalized(); oben = rechts.cross(d).normalized()
    r = float(np.linalg.norm(mx - mn)) * 0.55
    n = int(2 * r / AUF)
    L = np.full((n, n), '', dtype=object)
    for y in range(n):
        for x in range(n):
            p = c + rechts * (-r + x * AUF) + oben * (r - y * AUF) - d * 5
            h = bv.ray_cast(p, d, 10)
            if h[0] is None: continue
            t = LF[h[2]]
            L[y, x] = t + '/innen' if h[1].dot(d) > 0 else t
    return L, c, rechts, oben, r

def flecken(L):
    # Felder fremder Bildpunkte (nicht leer, nicht Huelle aussen), die ganz von Huelle aussen umschlossen sind
    H = np.isin(L, HUELLE); leer = L == ''
    fremd = ~H & ~leer
    n0, n1 = L.shape; gesehen = np.zeros_like(fremd); aus = []
    for y in range(n0):
        for x in range(n1):
            if not fremd[y, x] or gesehen[y, x]: continue
            st = [(y, x)]; gesehen[y, x] = True; feld = []; rand_h = rand_a = 0
            while st:
                cy, cx = st.pop(); feld.append((cy, cx))
                for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    ny, nx = cy + dy, cx + dx
                    if not (0 <= ny < n0 and 0 <= nx < n1): rand_a += 1; continue
                    if fremd[ny, nx]:
                        if not gesehen[ny, nx]: gesehen[ny, nx] = True; st.append((ny, nx))
                    elif H[ny, nx]: rand_h += 1
                    else: rand_a += 1
            if rand_h >= 0.9 * (rand_h + rand_a) and len(feld) >= 2:
                teile = {}
                for p in feld: teile[L[p]] = teile.get(L[p], 0) + 1
                aus.append((len(feld), np.mean(feld, axis=0), teile))
    return aus

def strahl(V, F, LF, w, az, el):
    # alle Flaechen entlang des Strahls durch w (Teil, Seite, Abstand in mm zur ersten): Loch oder Durchstossen
    bv = BVHTree.FromPolygons(V, F); a, e = math.radians(az), math.radians(el)
    d = Vector((math.sin(a) * math.cos(e), math.cos(a) * math.cos(e), -math.sin(e)))
    p = w - d * 5; aus = []; t0 = None
    for _ in range(8):
        h = bv.ray_cast(p, d, 10)
        if h[0] is None: break
        t0 = t0 if t0 is not None else h[0]
        aus.append('%s%s@%d' % (LF[h[2]], '/i' if h[1].dot(d) > 0 else '', round((h[0] - t0).length * 1000)))
        p = h[0] + d * 0.0005
    return ' '.join(aus)

qa.animation_data_create()
gesamt = {}
for bn in BEW:
    if bn == 'Ruhe': qa.animation_data.action = None; fr = [0]
    else:
        a = AKT.get(bn)
        if a is None: print('FEHLT', bn); continue
        qa.animation_data.action = a
        if hasattr(qa.animation_data, 'action_slot') and a.slots: qa.animation_data.action_slot = a.slots[0]
        fr = [int(round(f)) for f in np.linspace(a.frame_range[0], a.frame_range[1], BILDER)]
    zahl = {}; groesst = 0; innen = {}
    for f in fr:
        bpy.context.scene.frame_set(f)
        V, F, LF = lage()
        for az, el in SICHT:
            L, c, rechts, oben, r = sehen(V, F, LF, az, el)
            for t in set(L.ravel().tolist()):
                if t.endswith('/innen') and t.split('/')[0] in HUELLE: innen[t] = innen.get(t, 0) + int((L == t).sum())
            for gr, m, teile in flecken(L):
                groesst = max(groesst, gr)
                for t, k in teile.items(): zahl[t] = zahl.get(t, 0) + k
                if WO == bn and gr >= 4:
                    w = c + rechts * (-r + m[1] * AUF) + oben * (r - m[0] * AUF)
                    print('WO', bn, f, '%d/%d' % (az, el), gr, teile, 'Hoehe %.2f m' % w.z, 'Strahl', strahl(V, F, LF, w, az, el))
    for t, k in zahl.items(): gesamt[t] = gesamt.get(t, 0) + k
    print('FLECKEN', bn, 'groesster %d Punkte;' % groesst, dict(sorted(zahl.items(), key=lambda x: -x[1])[:8]), 'innen sichtbar', innen)
print('FLECKEN GESAMT', dict(sorted(gesamt.items(), key=lambda x: -x[1])), '(Bildpunkte zu %.0f mm)' % (AUF * 1000))
