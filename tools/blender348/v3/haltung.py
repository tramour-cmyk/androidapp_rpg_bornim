# 431 Tuch: Lage der Knochen in einer Bewegung der UAL (Bild 0), so wie Godot sie zeigt (HeldFigur.bewegungen: nur Drehungen, das
# Becken im Verhaeltnis der Beckenhoehe), ohne Godot: aus den glTF-Knoten des Koerpers (Ruhelage) und den Spuren der UAL.
# verformung(koerper_glb, ual_glb, 'Idle_Loop') -> {Knochen: 4x4 im Raum von Blender (z oben)}, D = Lage * Ruhelage^-1
import json, struct
import numpy as np

_TYP = {5126: ('f', 4), 5123: ('H', 2), 5125: ('I', 4), 5121: ('B', 1)}
_N = {'SCALAR': 1, 'VEC3': 3, 'VEC4': 4, 'MAT4': 16}


def _glb(p):
    d = open(p, 'rb').read()
    n = struct.unpack_from('<I', d, 12)[0]
    j = json.loads(d[20:20 + n])
    o = 20 + n
    bn = struct.unpack_from('<I', d, o)[0]
    return j, d[o + 8:o + 8 + bn]


def _acc(j, b, i):
    a = j['accessors'][i]; v = j['bufferViews'][a['bufferView']]
    f, s = _TYP[a['componentType']]; k = _N[a['type']]
    off = v.get('byteOffset', 0) + a.get('byteOffset', 0)
    st = v.get('byteStride', s * k)
    return np.array([struct.unpack_from('<' + f * k, b, off + st * r) for r in range(a['count'])])


def _mat(t, q, s=(1, 1, 1)):
    x, y, z, w = q
    R = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                  [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                  [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])
    M = np.eye(4); M[:3, :3] = R * np.array(s); M[:3, 3] = t
    return M


def _knochen(j):
    sk = j['skins'][0]; jn = set(sk['joints'])
    eltern = {}
    for i, n in enumerate(j['nodes']):
        for c in n.get('children', []): eltern[c] = i
    return jn, eltern


def verformung(koerper_glb, ual_glb, bewegung='Idle_Loop', zeit=0.0):
    j, b = _glb(koerper_glb)
    jn, eltern = _knochen(j)
    name = {i: j['nodes'][i].get('name', '') for i in jn}
    # Bild 0 der Bewegung: Drehungen je Knochenname, Beckenverschiebung
    u, ub = _glb(ual_glb)
    an = next(a for a in u['animations'] if a['name'] == bewegung)
    rot, pos = {}, {}
    for c in an['channels']:
        nn = u['nodes'][c['target']['node']].get('name', '')
        sm = an['samplers'][c['sampler']]
        tt = _acc(u, ub, sm['input'])[:, 0]; vv = _acc(u, ub, sm['output'])
        k = int(np.searchsorted(tt, zeit)) if zeit > 0 else 0
        k = min(k, len(vv) - 1)
        # Godot verwirft beim Einlesen Spuren, die über die ganze Bewegung der Ruhelage der UAL gleichen (spine_01 in Idle_Loop): dort
        # bleibt die Ruhelage des Körpers
        ruhe = u['nodes'][c['target']['node']].get(c['target']['path'])
        if ruhe is not None and len(vv) and np.allclose(vv, np.array(ruhe)[None, :], atol=1e-4) or (ruhe is not None and c['target']['path'] == 'rotation' and np.allclose(np.abs((vv * np.array(ruhe)[None, :]).sum(1)), 1, atol=1e-6)):
            continue
        if c['target']['path'] == 'rotation': rot[nn] = vv[k]
        elif c['target']['path'] == 'translation': pos[nn] = vv[k]
    ujn, _ = _knochen(u)
    uname = {u['nodes'][i].get('name', ''): u['nodes'][i] for i in ujn}
    becken_u = np.linalg.norm(uname['pelvis'].get('translation', [0, 0, 0])) if 'pelvis' in uname else 1.0
    becken_k = next((np.linalg.norm(j['nodes'][i].get('translation', [0, 0, 0])) for i in jn if name[i] == 'pelvis'), 1.0)
    f = becken_k / max(becken_u, 1e-6)

    def lokal(i, posiert):
        n = j['nodes'][i]
        t = np.array(n.get('translation', [0, 0, 0])); q = n.get('rotation', [0, 0, 0, 1]); s = n.get('scale', [1, 1, 1])
        if posiert and name.get(i) in rot: q = rot[name[i]]
        if posiert and name.get(i) in ('pelvis', 'root') and name[i] in pos: t = np.array(pos[name[i]]) * f
        return _mat(t, q, s)

    G = {}
    def glob(i, posiert):
        k = (i, posiert)
        if k in G: return G[k]
        M = lokal(i, posiert)
        if i in eltern: M = glob(eltern[i], posiert if eltern[i] in jn else False) @ M
        G[k] = M
        return M
    C = np.array([[1, 0, 0, 0], [0, 0, -1, 0], [0, 1, 0, 0], [0, 0, 0, 1]], float)   # glTF (y oben) -> Blender (z oben)
    aus = {}
    for i in jn:
        D = glob(i, True) @ np.linalg.inv(glob(i, False))
        aus[name[i]] = C @ D @ np.linalg.inv(C)
    return aus
