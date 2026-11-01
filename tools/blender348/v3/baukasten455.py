# 455.1 Probeblatt Baukasten (Chef 01.11., 11:24 „Abzug von … unterschiedlichen Roben, Umhängen oder Stiefeln“; Archiv 455): je ein
# vorhandenes Netz (kein Eigenbau) in drei Materialien x zwei Zeichen, Mann und Frau. Das Netz bleibt; Material und Zeichen werden in
# eine Kopie seines Farbbilds gemalt (baukasten_muster.py), Godot tauscht nur das Bild (baukastenprobe.gd). So wird es spaeter gebaut:
# ein Gegenstand = Netz x Bild.
#   Robe:   lange Robe des Zauberlehrlings (held_ROBE, unser Netz, Teil „robe“; 376.1)
#   Umhang: Umhang des Wachsoldaten (held_WACHE, unser Netz, Teil „cloak“)
#   Beine:  Beine und Stiefel des Waldlaeufers (held_WALD, Quaternius gekauft: *_Legs, *_Feet)
#   Arme:   Arme des Waldlaeufers (held_WALD, *_Arms)
# Bildpunkte je Dreieck in die Ruhelage zurueckgerechnet (wie sonne() in held_klassen.py), dort Muster und Band (Borte, Runen).
# Aufruf nach held_klassen.py (TRACHTEN=WACHE,ROBE,WALD): Z=<klassen> OUT=<held3-Ausgabe> ZIEL=<ordner> bl/bin/python -I baukasten455.py
#   -> <ZIEL>/<tracht>_<netz>_<mat>_<zeichen>_<n>.png, <ZIEL>/baukasten.json
import bpy, os, sys, json
import numpy as np
from PIL import Image

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)
import baukasten_muster as BM

Z = os.environ['Z']
OUT = os.environ.get('OUT', '')
ZIEL = os.environ.get('ZIEL', os.path.join(Z, 'baukasten'))
GROSS = int(os.environ.get('GROSS', '1024'))   # wie schlank() in held_klassen.py
os.makedirs(ZIEL, exist_ok=True)

ZEICHEN = ['borte', 'runen']
NETZE = [
    # Pruefer 455.1 Lauf 2: mit nur 'robe' wechselte allein der Rock, Oberteil und Aermel blieben blau: alle Stoffteile der Tracht
    {'netz': 'robe', 'name': 'Robe', 'tracht': 'ROBE', 'teil': ['*'], 'teil_ohne': ['belt', 'buckle', 'clasp', 'boots', 'cloak'], 'mats': ['stoff', 'leder', 'kette'], 'band': 'saum', 'ansicht': 'vorn'},
    {'netz': 'umhang', 'name': 'Umhang', 'tracht': 'WACHE', 'teil': ['cloak'], 'mats': ['stoff', 'leder', 'fell'], 'band': 'saum',
     'ansicht': 'hinten'},
    {'netz': 'beine', 'name': 'Beine mit Stiefeln', 'tracht': 'WALD', 'objekte': ['Legs', 'Feet'], 'mats': ['stoff', 'leder', 'kette'],
     'band': 'stiefel', 'ansicht': 'vorn'},
    {'netz': 'arme', 'name': 'Arme', 'tracht': 'WALD', 'objekte': ['Arms'], 'mats': ['stoff', 'leder', 'kette'], 'band': 'handgelenk',
     'ansicht': 'vorn'},
]
BAND_H = 0.05   # m, Borte und Runenband
# Ordner von held3 je Tracht und Geschlecht (teile.json: Namen zur Kennung 'teil'), wie spike-probe-3761.yml (pruef_tracht.py)
HELD3 = {'WACHE_M': OUT, 'WACHE_W': os.path.join(Z, 'roh_held_w'), 'ROBE_M': os.path.join(Z, 'roh_held_wizard_m'),
         'ROBE_W': os.path.join(Z, 'roh_held_wizard_w')}
HAUT = ('Skin', 'Regular', 'Superhero', 'Eye', 'Hair', 'Brow', 'Body_')   # Materialien, die nie bemalt werden


def basisbild(m):
    bsdf = next((n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED'), None) if m and m.node_tree else None
    n = bsdf.inputs['Base Color'].links[0].from_node if bsdf and bsdf.inputs['Base Color'].links else None
    while n is not None and n.type != 'TEX_IMAGE':
        n = next((i.links[0].from_node for i in n.inputs if i.links), None)
    return n.image if n is not None else None


def welt(o):
    me = o.data
    co = np.empty(len(me.vertices) * 3); me.vertices.foreach_get('co', co)
    M = np.array(o.matrix_world)
    return co.reshape(-1, 3) @ M[:3, :3].T + M[:3, 3]


def dreiecke(o):
    me = o.data
    me.calc_loop_triangles()
    n = len(me.loop_triangles)
    tv = np.empty(n * 3, dtype=np.int64); me.loop_triangles.foreach_get('vertices', tv)
    tl = np.empty(n * 3, dtype=np.int64); me.loop_triangles.foreach_get('loops', tl)
    tm = np.empty(n, dtype=np.int64); me.loop_triangles.foreach_get('material_index', tm)
    uv = np.empty(len(me.loops) * 2); me.uv_layers.active.data.foreach_get('uv', uv)
    return tv.reshape(-1, 3), tl.reshape(-1, 3), tm, uv.reshape(-1, 2)


def bildpunkte(U, W, H):
    # Bildpunkte (x, y) und Schwerpunktgewichte eines Dreiecks im Bild (U: 3 x 2 in Bildpunkten); Rand grosszuegig (Naehte)
    x0, y0 = np.floor(U.min(0)).astype(int) - 1; x1, y1 = np.ceil(U.max(0)).astype(int) + 1
    xs, ys = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
    T = np.array([[U[1, 0] - U[0, 0], U[2, 0] - U[0, 0]], [U[1, 1] - U[0, 1], U[2, 1] - U[0, 1]]])
    if abs(np.linalg.det(T)) < 1e-9: return None
    l12 = np.linalg.solve(T, np.stack([xs.ravel() - U[0, 0], ys.ravel() - U[0, 1]]))
    l0 = 1 - l12[0] - l12[1]
    tol = 0.6 / max(1.0, np.sqrt(abs(np.linalg.det(T))))   # etwa ein halber Bildpunkt
    drin = (l0 >= -tol) & (l12[0] >= -tol) & (l12[1] >= -tol)
    if not drin.any(): return None
    X = np.floor(xs.ravel()[drin]).astype(int); Y = np.floor(ys.ravel()[drin]).astype(int)
    ok = (X >= 0) & (X < W) & (Y >= 0) & (Y < H)
    L = np.stack([l0[drin], l12[0][drin], l12[1][drin]], 1)
    return X[ok], Y[ok], np.clip(L[ok], 0, 1) / np.clip(L[ok], 0, 1).sum(1, keepdims=True)


def bild_lesen(im):
    if max(im.size) > GROSS:
        f = GROSS / max(im.size); im.scale(max(1, int(im.size[0] * f)), max(1, int(im.size[1] * f)))
    W, H = im.size
    px = np.empty(W * H * 4, dtype=np.float32); im.pixels.foreach_get(px)
    return px.reshape(H, W, 4).copy()


def belegt(objs, image, W, H):
    # alle Bildpunkte, die irgendein Dreieck mit diesem Bild deckt (dort wird nicht ueber den Rand hinaus gemalt)
    b = np.zeros((H, W), bool)
    for o in objs:
        tv, tl, tm, uv = dreiecke(o)
        mats = [basisbild(m) == image for m in o.data.materials]
        for t in range(len(tv)):
            if not mats or not mats[min(tm[t], len(mats) - 1)]: continue
            r = bildpunkte(uv[tl[t]] * (W, H), W, H)
            if r: b[r[1], r[0]] = True
    return b


def band(spec, P, N, alle_P, arm):
    # v quer (0-1, NaN ausserhalb), s entlang (m)
    if spec['band'] == 'handgelenk':
        xw = abs((arm.matrix_world @ arm.data.bones['hand_l'].head_local).x) if arm and 'hand_l' in arm.data.bones else 0.82 * np.abs(alle_P[:, 0]).max()
        t = xw - np.abs(P[:, 0]) - 0.02
        s = np.where(np.abs(N[:, 2]) > np.abs(N[:, 1]), P[:, 1], P[:, 2])
    else:
        z0 = alle_P[:, 2].min() + 0.025 if spec['band'] == 'saum' else spec['_stiefel_oben'] - 0.015 - BAND_H
        t = P[:, 2] - z0
        s = np.where(np.abs(N[:, 1]) > np.abs(N[:, 0]), P[:, 0], P[:, 1])
    v = np.where((t >= 0) & (t <= BAND_H), t / BAND_H, np.nan)   # 0 unten (Saum, Stiefel) bzw. am Handgelenk
    return v, s


def male_netz(spec, g, objs, sel, arm):
    # sel: Objektname -> Maske der Dreiecke; je (Objekt, Material) ein Satz Bilder
    eintraege = []
    proben = []   # (o, mat_name, image, X, Y, P, N)
    for o in objs:
        if o.name not in sel: continue
        tv, tl, tm, uv = dreiecke(o)
        V = welt(o)
        gruppen = {}
        for t in np.nonzero(sel[o.name])[0]:
            mi = min(tm[t], len(o.data.materials) - 1)
            m = o.data.materials[mi] if o.data.materials else None
            if m is None or any(w in m.name for w in HAUT): continue
            gruppen.setdefault(m.name, []).append(t)
        for mn, ts in gruppen.items():
            m = bpy.data.materials[mn]
            im = basisbild(m)
            if im is None: print('FEHLT Bild', o.name, mn); continue
            W, H = (min(GROSS, im.size[0]), min(GROSS, im.size[1])) if max(im.size) <= GROSS else \
                   (max(1, int(im.size[0] * GROSS / max(im.size))), max(1, int(im.size[1] * GROSS / max(im.size))))
            Xs, Ys, Ps, Ns = [], [], [], []
            for t in ts:
                r = bildpunkte(uv[tl[t]] * (W, H), W, H)
                if not r: continue
                X, Y, L = r
                A = V[tv[t]]
                nr = np.cross(A[1] - A[0], A[2] - A[0]); nr = nr / (np.linalg.norm(nr) + 1e-12)
                Xs.append(X); Ys.append(Y); Ps.append(L @ A); Ns.append(np.repeat(nr[None], len(X), 0))
            if Xs: proben.append((o, mn, im, np.concatenate(Xs), np.concatenate(Ys), np.concatenate(Ps), np.concatenate(Ns)))
    if not proben: print('FEHLT', spec['tracht'], g, spec['netz'], 'keine Bildpunkte'); return []
    alle_P = np.concatenate([p[5] for p in proben])
    if spec['band'] == 'stiefel':
        fu = [o for o in objs if 'Feet' in o.name]
        spec['_stiefel_oben'] = max(welt(o)[:, 2].max() for o in fu) if fu else alle_P[:, 2].min() + 0.3
    alle_objs = [o for o in bpy.data.objects if o.type == 'MESH']
    for o, mn, im, X, Y, P, N in proben:
        px = bild_lesen(im)
        H, W = px.shape[:2]
        X = np.clip(X, 0, W - 1); Y = np.clip(Y, 0, H - 1)
        hell = px[Y, X, :3] @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
        S = hell / max(1e-3, float(np.median(hell)))
        v, s = band(spec, P, N, alle_P, arm)
        frei = ~belegt(alle_objs, im, W, H)
        print('BAUKASTEN %s %s %s %s/%s: %d Bildpunkte, Bild %dx%d, im Band %d' % (spec['tracht'], g, spec['netz'], o.name, mn, len(X), W, H,
              int((~np.isnan(v)).sum())))
        for mat in spec['mats']:
            for z in ZEICHEN:
                rgb, a = BM.male(mat, z, P, N, S, v, s, BAND_H)
                neu = px.copy(); neu[..., 3] = 1.0
                neu[Y, X, :3] = rgb; neu[Y, X, 3] = a
                gemalt = np.zeros((H, W), bool); gemalt[Y, X] = True
                for _ in range(3):   # ueber die Naht hinaus in freie Bildpunkte (Mipmaps mischen sonst die alte Farbe hinein)
                    for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)):
                        q = np.roll(gemalt, (dy, dx), (0, 1)) & ~gemalt & frei
                        if q.any():
                            neu[q] = np.roll(neu, (dy, dx), (0, 1))[q]
                            gemalt |= q
                n = '%s_%s_%s_%s_%s_%d.png' % (spec['tracht'], g, spec['netz'], mat, z, len(eintraege))
                Image.fromarray((np.clip(neu[::-1], 0, 1) * 255 + 0.5).astype(np.uint8), 'RGBA').save(os.path.join(ZIEL, n), optimize=True)
                eintraege.append({'mat': mat, 'zeichen': z, 'netz': o.name, 'material': mn, 'bild': n})
    return eintraege


def teile_namen(k):
    p = os.path.join(HELD3.get(k, ''), 'teile.json')
    return json.load(open(p)) if os.path.exists(p) else None


ergebnis = {'zeichen': ZEICHEN, 'worte': BM.WORT, 'netze': []}
for spec in NETZE:
    e = {k: v for k, v in spec.items() if not k.startswith('_')}
    e['bilder'] = {}
    for g in ('M', 'W'):
        k = '%s_%s' % (spec['tracht'], g)
        bpy.ops.wm.read_factory_settings(use_empty=True)
        if 'teil' in spec:   # unser Netz: Rohdatei aus kauf_kleid.py mit Kennung 'teil' (dieselben UV und dasselbe Bild wie das glb)
            p = os.path.join(Z, 'roh', 'held_%s.blend' % k)
            namen = teile_namen(k)
            if not os.path.exists(p) or namen is None: print('FEHLT', p, 'oder teile.json'); continue
            bpy.ops.wm.open_mainfile(filepath=p)
            objs = [o for o in bpy.data.objects if o.type == 'MESH']
            sel = {}
            for o in objs:
                if 'teil' not in o.data.attributes: continue
                tl = np.zeros(len(o.data.vertices), dtype=int); o.data.attributes['teil'].data.foreach_get('value', tl)
                wahl = [t for t in namen if t not in spec.get('teil_ohne', [])] if spec['teil'] == ['*'] else [t for t in spec['teil'] if t in namen]
                print('TEILE %s: %s' % (k, ', '.join(wahl)))
                will = np.isin(tl, [namen.index(t) for t in wahl])
                tv = dreiecke(o)[0]
                sel[o.name] = will[tv].all(1)
                print('TEIL %s %s: %d von %d Dreiecken' % (k, o.name, int(sel[o.name].sum()), len(tv)))
        else:   # Kaufnetz: aus dem fertigen glb (Bild schon verkleinert und getoent)
            p = os.path.join(Z, 'held_%s.glb' % k)
            if not os.path.exists(p): print('FEHLT', p); continue
            bpy.ops.import_scene.gltf(filepath=p)
            objs = [o for o in bpy.data.objects if o.type == 'MESH']
            sel = {o.name: np.ones(len(dreiecke(o)[0]), bool) for o in objs if any(w in o.name for w in spec['objekte'])}
            print('NETZE %s %s: %s' % (k, spec['netz'], ', '.join('%s (%s)' % (o.name, ', '.join(m.name for m in o.data.materials if m))
                                                                    for o in objs if o.name in sel)))
        arm = next((o for o in bpy.data.objects if o.type == 'ARMATURE'), None)
        e['bilder'][g] = male_netz(spec, g, objs, sel, arm)
    ergebnis['netze'].append(e)
json.dump(ergebnis, open(os.path.join(ZIEL, 'baukasten.json'), 'w'), indent=1, ensure_ascii=False)
print('BAUKASTEN OK', sum(len(b) for e in ergebnis['netze'] for b in e['bilder'].values()), 'Bilder')
