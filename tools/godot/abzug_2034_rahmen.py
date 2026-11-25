# 2034-Ue14 (4), (5) (Planer Vera 20:07; Pruefer 19:59 (1), (3)): Rahmen aller gezeichneten Stuecke ohne Bildlauf nachrechnen,
# wie godot/tests/abzug_2034.gd rahmt (_groessen): je Ansicht Kamera orthogonal, Hoehe = max(Hoehe, Breite * H / 2048) * 1,08,
# Zuschnitt = Breite des Stuecks + 8 % der Bildhoehe; beide Zuschnitte teilen sich 2048 px, sonst beide gleich verkleinert. Seite =
# Stueck 90 Grad gedreht (Breite = Tiefe); Paare (Stiefel, Handschuhe) in der Seite nur das rechte Stueck (Dreiecke mit Mitte x > 0).
#   fuellt = Hoehe des Stuecks / Bildhoehe (je Ansicht); abstand_px = Bildpunkte vom unteren Rand des Stuecks bis zur
#   Massstabzeile unter dem Bild (tools/godot/abzug_2034.sh; Massstab und Schrift liegen ausserhalb des Bildes).
# Gegenprobe: dieselben Zahlen wie MARKE ... fuellt im Lauf (Probe-Stuecke).
# Aufruf: python3 tools/godot/abzug_2034_rahmen.py <glb-ordner> <liste.json> <aus.tsv>
import sys, json, struct
import numpy as np

B, H, RAND = 2048, 924, 1.08
PAARE = {'Stiefel', 'Handschuhe'}
TYP = {5120: np.int8, 5121: np.uint8, 5122: np.int16, 5123: np.uint16, 5125: np.uint32, 5126: np.float32}
N = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4}

def lies(p):
    b = open(p, 'rb').read()
    jl = struct.unpack('<I', b[12:16])[0]
    j = json.loads(b[20:20 + jl])
    bin_ = b[20 + jl + 8:]
    def acc(i):
        a = j['accessors'][i]; v = j['bufferViews'][a['bufferView']]
        o = v.get('byteOffset', 0) + a.get('byteOffset', 0)
        t = np.dtype(TYP[a['componentType']]); n = N[a['type']]
        assert v.get('byteStride', t.itemsize * n) == t.itemsize * n, p   # Blender schreibt dicht
        return np.frombuffer(bin_, t, a['count'] * n, o).reshape(-1, n)
    tris = []
    for node in j.get('nodes', []):
        if 'mesh' not in node: continue
        assert 'matrix' not in node and node.get('rotation', [0, 0, 0, 1]) == [0, 0, 0, 1] and node.get('scale', [1, 1, 1]) == [1, 1, 1], p
        off = np.array(node.get('translation', [0, 0, 0]))
        for pr in j['meshes'][node['mesh']]['primitives']:
            v = acc(pr['attributes']['POSITION']).astype(float) + off
            ix = acc(pr['indices']).reshape(-1) if 'indices' in pr else np.arange(len(v))
            tris.append(v[ix.reshape(-1, 3)])
    return np.concatenate(tris)

def groesse(t):   # wie _groessen in abzug_2034.gd: Kamerahoehe (m) und Zuschnitt (px) bei voller Hoehe
    p = t.reshape(-1, 3)
    sx, sy = np.ptp(p[:, 0]), np.ptp(p[:, 1])
    g = max(sy, sx * H / B) * RAND
    return g, sx * H / g + 0.08 * H, sy

out, unter, frei = [], [], 0
for e in json.load(open(sys.argv[2])):
    g = e.get('glb', '')
    if not g.endswith('.glb') or not e.get('zeichnen', True): continue   # nur gezeichnete (abzug_2034_liste.py)
    t = lies(sys.argv[1] + '/' + g)
    s = t[(t[:, :, 0].sum(1) > 0)] if e['art'] in PAARE else t
    s = s[:, :, [2, 1, 0]]   # 90 Grad um y: Breite im Bild = Tiefe
    (gv, wv, hv), (gs, ws, hs) = groesse(t), groesse(s)
    k = min(1.0, B / (wv + ws))   # beide Zuschnitte auf 2048 px, sonst beide gleich verkleinert
    fv, fs = hv * k / gv, hs * k / gs
    a = int(H * (1 - max(fv, fs)) / 2)
    frei += a > 0
    if min(fv, fs) < 0.8: unter.append(e['nummer'])
    out.append('%s\t%s\t%.3f\t%.3f\t%d' % (e['nummer'], e['art'], fv, fs, a))
open(sys.argv[3], 'w').write('nummer\tart\tfuellt_vorn\tfuellt_seite\tabstand_massstab_px\n' + '\n'.join(out) + '\n')
print('RAHMEN %d Stuecke, Massstab frei %d, mindestens 80 %% %d, darunter %d: %s' % (len(out), frei, len(out) - len(unter), len(unter), ','.join(unter)))
