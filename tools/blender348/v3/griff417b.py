# 417 Messung 3d (Pruefer 01.11., 13:3x: Schwert durch Schild, Schild vor dem Gesicht, Bogen im Becken): wo die Pakete ihre Waffe in
# der Hand fuehren, als Rahmen der Hand, den Godot nachbaut (tragen.gd GRIFF). Lage der Props aus den Unity-Prefabs (griff417.py,
# Lauf 41309203353): Knochen, Lage (m), Drehung (x, y, z, w) im Raum des Unity-Knochens. Unity spiegelt FBX an X; hier beide Fassungen
# (gespiegelt, wie gelesen) mit Pruefung: beim Zweihaender muss die linke Faust auf der Griffachse liegen, beim Einhaender die rechte.
# Rahmen der Hand wie zauber385.py (x: Handgelenk -> Mittelfinger, z: x kreuz (Kleinfinger -> Zeigefinger), y: z kreuz x; Ursprung am
# Handgelenk, Laengen durch die Handlaenge), damit gleicht die Uebertragung die Hand Quelle -> Ziel ab.
# Aufruf: KAUF=<kaufpakete> bl/bin/python -I griff417b.py
import bpy, glob, json, math, os
from mathutils import Matrix, Quaternion, Vector

KAUF = os.environ['KAUF']
# Paket, Gehen, Rennen, [Prop, Seite, Lage, Drehung xyzw, innen (Lage, Drehung) des Prop-Prefabs oder None]
PROPS = {
    'axt': ('2.HANDED', 'WalkForwardNormal2HandMelee', 'Sprint2HandMelee',
            [('SM_2HandedSwordProp', 'R', (-0.094, 0.019, -0.037), (0.07145098, 0.0094069205, -0.9888669, -0.13018614))]),
    'einhand': ('1.HANDED', 'WalkForwardHold1hMelee', 'SprintHold1hMelee',
                [('SM_BludgeonProp', 'R', (-0.1, 0.029, 0.008), (0.70526814, -0.050958876, 0.05095906, 0.7052682))]),
    'schild': ('SWORD.SHIELD', 'WalkForwardS&S', 'RunFastNormalS&S',
               [('SM_1HandedSwordProp', 'R', (-0.103, 0.024, 0.0), (0.49373475, -0.54606485, -0.5061888, 0.44923505)),
                ('SM_ShieldProp', 'L', (0.025, -0.031, 0.0), (-0.00000041723246, 0.00000042840833, 0.66834575, 0.7438508))]),
    'bogen': ('BOW.ARROW', 'WalkBow', 'RunFastBow',
              [('SM_Bow&ArrowsProp', 'L', (-0.128, -0.014, -0.109), (0.52573436, -0.2766444, -0.44483477, 0.6702188))]),
}
INNEN = json.loads(os.environ.get('INNEN', '{}'))   # Prop -> [[x, y, z], [x, y, z, w]] aus dem Prop-Prefab (griff417.py), sonst keins


def fbx(paket, name):
    alle = [p for p in glob.glob(os.path.join(KAUF, '**', '*.fbx'), recursive=True) + glob.glob(os.path.join(KAUF, '**', '*.FBX'), recursive=True)
            if paket.lower() in p.lower().replace('_', '.')]
    genau = [p for p in alle if os.path.basename(p).lower() in ('humanoid@%s.fbx' % name.lower(), '%s.fbx' % name.lower())]
    return genau[0] if genau else None


def rahmen(d, w):
    x = d.normalized(); z = x.cross(w).normalized(); return Matrix((x, z.cross(x), z)).transposed()


def k(v): return '(%+.2f vor %+.2f li %+.2f hoch)' % (-v.y, v.x, v.z)


def r3(v): return [round(x, 4) for x in v]


def gerade(p, a, q):   # Abstand des Punkts q von der Geraden p + t a, und t
    t = (q - p).dot(a); return (q - p - a * t).length, t


ausgabe = {}
for art, (paket, geh, renn, props) in PROPS.items():
    for wort, name in (('Gehen', geh), ('Rennen', renn)):
        q = fbx(paket, name)
        if not q: print('FEHLT', art, wort, name); continue
        bpy.ops.wm.read_factory_settings(use_empty=True)
        bpy.ops.import_scene.fbx(filepath=q)
        S = next(o for o in bpy.data.objects if o.type == 'ARMATURE')
        a = S.animation_data.action
        f0, f1 = int(a.frame_range[0]), int(a.frame_range[1])
        sc_s = S.matrix_world.to_scale()[0]
        teile = []
        for (pn, seite, lage, dreh) in props:
            pq = fbx(paket, pn)
            if not pq: print('FEHLT PROP', pn); continue
            vorher = set(bpy.data.objects)
            bpy.ops.import_scene.fbx(filepath=pq)
            neu = [o for o in bpy.data.objects if o not in vorher]
            wurzel = [o for o in neu if o.parent is None]
            netze = [o for o in neu if o.type == 'MESH']
            if not wurzel or not netze: print('PROP OHNE NETZ', pn); continue
            W = wurzel[0]; sw = W.matrix_world.to_scale()[0]
            pts = []   # Ecken im Raum der Prop-Wurzel, Meter (Unity rechnet die Einheit wie Blender in Meter um)
            for o in netze:
                L = W.matrix_world.inverted() @ o.matrix_world
                for v in o.data.vertices: pts.append((L @ v.co) * sw)
            if wort == 'Gehen':
                lo = Vector([min(p[i] for p in pts) for i in range(3)]); hi = Vector([max(p[i] for p in pts) for i in range(3)])
                print('PROP %s: %d Netze, %d Ecken, Wurzel %s Masse %s (m), von %s bis %s, Wurzelmassstab %.4f' % (pn, len(netze), len(pts), W.name,
                      r3(hi - lo), r3(lo), r3(hi), sw))
            for o in neu: bpy.data.objects.remove(o)
            teile.append((pn, seite, lage, dreh, pts))
        for (pn, seite, lage, dreh, pts) in teile:
            b = 'humanoid_ %s ' % seite
            for fassung in ('gespiegelt', 'wie gelesen'):
                M = Matrix.Diagonal((-1.0, 1.0, 1.0, 1.0)) if fassung == 'gespiegelt' else Matrix.Identity(4)
                Tu = Matrix.Translation(Vector(lage)) @ Quaternion((dreh[3], dreh[0], dreh[1], dreh[2])).to_matrix().to_4x4()
                if pn in INNEN:
                    il, idr = INNEN[pn]
                    Tu = Tu @ Matrix.Translation(Vector(il)) @ Quaternion((idr[3], idr[0], idr[1], idr[2])).to_matrix().to_4x4()
                Tf = M @ Tu @ M
                Pm = pts   # Unity: Welt_u = M Hand_f M T_u M v_f, also Welt_f = Hand_f (M T_u M) v_f; die Ecken bleiben wie gelesen
                zeilen = []
                for ph in range(4):
                    fr = f0 + (f1 - f0) * ph // 4
                    bpy.context.scene.frame_set(fr)
                    H = S.matrix_world @ S.pose.bones[b + 'Hand'].matrix @ Matrix.Scale(1.0 / sc_s, 4)
                    welt = [H @ Tf @ p for p in Pm]
                    o = H @ Tf @ Vector()
                    # Hauptachse: laengste Ausdehnung (Hauptachsen der Ecken), zur weiter entfernten Spitze
                    mitte = sum(welt, Vector()) / len(welt)
                    C = Matrix(((0, 0, 0), (0, 0, 0), (0, 0, 0)))
                    for p in welt:
                        d = p - mitte
                        for i in range(3):
                            for j in range(3): C[i][j] += d[i] * d[j]
                    # Potenzverfahren fuer die groesste Achse
                    ax = Vector((0.3, 0.5, 0.8))
                    for _ in range(60): ax = (C @ ax).normalized()
                    ts = [(p - o).dot(ax) for p in welt]
                    if abs(min(ts)) > abs(max(ts)): ax = -ax; ts = [-t for t in ts]
                    W2 = lambda n, s=seite: S.matrix_world @ S.pose.bones['humanoid_ %s %s' % (s, n)].head
                    fr_ = (W2('Finger1') + W2('Finger4')) * 0.5
                    fl = (S.matrix_world @ S.pose.bones['humanoid_ L Finger1'].head + S.matrix_world @ S.pose.bones['humanoid_ L Finger4'].head) * 0.5
                    fr2 = (S.matrix_world @ S.pose.bones['humanoid_ R Finger1'].head + S.matrix_world @ S.pose.bones['humanoid_ R Finger4'].head) * 0.5
                    dr, tr = gerade(o, ax, fr2); dl, tl = gerade(o, ax, fl)
                    zeilen.append('%d/4 Achse %s Laenge %.2f, Ursprung %s ab Becken; Faust R %.3f m neben der Achse bei %.2f, L %.3f bei %.2f; Ursprung-Faust %.3f'
                                  % (ph, k(ax), max(ts) - min(ts), k(o - S.matrix_world @ S.pose.bones['humanoid_ Pelvis'].head), dr, tr, dl, tl, (o - fr_).length))
                    if ph == 0 and wort == 'Gehen':
                        # Rahmen der Hand (Quelle): Lage des Props darin; Laengen durch die Handlaenge
                        h = W2('Hand'); m_ = W2('Finger2')
                        F = rahmen(m_ - h, W2('Finger1') - W2('Finger4')); Fi = F.inverted(); lh = (m_ - h).length
                        # zweite Achse: groesste quer zur ersten
                        C2 = C.copy(); ax2 = Vector((0.7, -0.2, 0.4))
                        for _ in range(60):
                            ax2 = C2 @ ax2; ax2 = (ax2 - ax * ax2.dot(ax)).normalized()
                        g, _t = gerade(o, ax, fr_)
                        griff = o + ax * (fr_ - o).dot(ax)   # Punkt der Achse an der Faust
                        oben = Vector((0, 0, 1))
                        ausgabe.setdefault(art, {})['%s:%s' % (pn, fassung)] = {
                            'seite': seite.lower(), 'achse': r3(Fi @ ax), 'quer': r3(Fi @ ax2), 'griff': r3((Fi @ (griff - h)) / lh),
                            'ursprung': r3((Fi @ (o - h)) / lh), 'faust': r3((Fi @ (fr_ - h)) / lh), 'oben': r3(Fi @ oben), 'handlaenge': round(lh, 4),
                            'spitze_m': round(max(ts), 3), 'ende_m': round(min(ts), 3)}
                for z in zeilen: print('GRIFF %s %s %s %s: %s' % (art, wort, pn, fassung, z))
json.dump(ausgabe, open(os.environ.get('OUT', 'griff417.json'), 'w'), indent=1)
print('GRIFF417B', json.dumps(ausgabe))
