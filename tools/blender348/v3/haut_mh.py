# 2031 (Chef 25.11., 13:39: „MakeHuman nehmen und testen … Haut“): eine MakeHuman-Haut (Bild in hm08-UV, skins01/skins02) auf die UV des
# Kaufkoerpers backen. Weg H der LISTE-QUELLEN.md „MakeHuman-Asset-Packs“; eigener Weg nach kleid_mh.py (Quelle fuer Uebertragung
# zwischen UV-Lagen durch Backen: kein Beleg mit Datum gefunden; Weg folgt aus kauf_kleid.py/kleid_mh.py):
#  (1) hm08 auf den Kaufkoerper legen wie kleid_mh.py Schritte 1–2 (A-Haltung, je Knochen, Feld) – derselbe Code, aus kleid_mh.py gelesen
#  (2) je Texel der Kauf-UV (je Material des Koerpers: Kopf, Leib; Orkbluetige ein Bild fuer beide) der Punkt auf der Kaufhaut, dazu der
#      naechste Punkt des angepassten hm08, dessen UV, dort die Farbe des MakeHuman-Bildes (bilinear). Ungetoent wie die Kaufhaut
#      (held_klassen.py: „Godot toent Haut und Haar“); keine Aufhellung (431: linear aufgehellt gab Flecken)
#  (2b) stark rote Stellen am Kopf (Lippen, Lidrand, Nasenloch) gemildert: keine Schminke
#  (3) Texel ohne Treffer (weiter als WEIT vom hm08) bleiben magenta (Pruefung kutte_haut_2031 zaehlt sie); Rand um die UV-Inseln mit
#      der Nachbarfarbe gefuellt (keine Naht beim Verkleinern)
# Ausgabe: <ZIEL>/<KENNUNG>__<Material>.jpg (BILD px), <ZIEL>/<KENNUNG>__<Material>.json (Mittel sRGB, Helligkeit linear, Texel, ohne Treffer)
# Aufruf: HELD=<held_WACHE_M.bin> HM08=<base.obj> HAUT=<skin.mhmat> KENNUNG=<name> ZIEL=<ordner> [BILD=1024] bl/bin/python -I haut_mh.py
import os, sys, json, re
import numpy as np

HIER = os.path.dirname(os.path.abspath(__file__))
os.environ.setdefault('STUECKE', '')
# (1) Schritte 1–2 aus kleid_mh.py (bis vor „3. Stuecke aus der Bindung“)
quelle = open(os.path.join(HIER, 'kleid_mh.py'), encoding='utf-8').read()
quelle = quelle[:quelle.index('# ---------------------------------------------------------------- 3. Stuecke aus der Bindung')]
exec(compile(quelle, 'kleid_mh.py', 'exec'))

from PIL import Image
HAUT = os.environ['HAUT']
KENNUNG = os.environ['KENNUNG']
BILD = int(os.environ.get('BILD', '1024'))
WEIT = float(os.environ.get('WEIT', '0.08'))
ROT_F = float(os.environ.get('ROT_F', '1.6'))     # rot: Rot ueber 1,6 mal Gruen (Haut 1,2-1,4)
os.makedirs(ZIEL, exist_ok=True)

# hm08-UV: vt und f v/vt der Koerperflaechen
VT, FT = [], []
for l in open(HM08, encoding='utf-8', errors='replace'):
    if l.startswith('vt '): VT.append([float(x) for x in l.split()[1:3]])
    elif l.startswith('f '): FT.append([int(t.split('/')[1]) - 1 if '/' in t and t.split('/')[1] else -1 for t in l.split()[1:]])
VT = np.array(VT)
FT_k = [ft for ft, g in zip(FT, HFG) if g == 'body']
htri, huv = [], []
for f, ft in zip(koerper_f, FT_k):
    for k in range(1, len(f) - 1):
        htri.append([f[0], f[k], f[k + 1]]); huv.append([ft[0], ft[k], ft[k + 1]])
htri = np.array(htri); huv = np.array(huv)
bvh_h = BVHTree.FromPolygons([Vector(v) for v in HV2], htri.tolist())

bild_p = None
for l in open(HAUT, encoding='utf-8', errors='replace'):
    if l.startswith('diffuseTexture'): bild_p = os.path.join(os.path.dirname(HAUT), l.split(None, 1)[1].strip())
Q = np.asarray(Image.open(bild_p).convert('RGB'), dtype=np.float32) / 255.0
QH, QW = Q.shape[:2]


def probe(uv):   # bilinear, uv wie obj (v nach oben)
    x = np.clip(uv[0], 0, 1) * (QW - 1); y = (1 - np.clip(uv[1], 0, 1)) * (QH - 1)
    x0, y0 = int(x), int(y); x1, y1 = min(x0 + 1, QW - 1), min(y0 + 1, QH - 1); fx, fy = x - x0, y - y0
    return (Q[y0, x0] * (1 - fx) * (1 - fy) + Q[y0, x1] * fx * (1 - fy) + Q[y1, x0] * (1 - fx) * fy + Q[y1, x1] * fx * fy)


def bary(p, a, b, c):
    v0, v1, v2 = b - a, c - a, p - a
    d00, d01, d11, d20, d21 = v0 @ v0, v0 @ v1, v1 @ v1, v2 @ v0, v2 @ v1
    den = d00 * d11 - d01 * d01
    if abs(den) < 1e-14: return np.array([1.0, 0, 0])
    v = (d11 * d20 - d01 * d21) / den; w = (d00 * d21 - d01 * d20) / den
    return np.array([1 - v - w, v, w])


# (2) je Material der Haut ein Bild
def matname(m): return re.sub(r'\.\d{3}$', '', m.name)

gruppen = {}
dg = bpy.context.evaluated_depsgraph_get()
for o in koerper:
    oe = o.evaluated_get(dg); me = oe.to_mesh()
    P = np.array([oe.matrix_world @ v.co for v in me.vertices])
    uvl = me.uv_layers[0].data
    for p in me.polygons:
        mn = matname(o.data.materials[p.material_index])
        if 'Leinen' in mn: continue
        L = list(p.loop_indices)
        for k in range(1, len(L) - 1):
            ls = [L[0], L[k], L[k + 1]]
            X_ = P[[me.loops[i].vertex_index for i in ls]]
            n_ = np.cross(X_[1] - X_[0], X_[2] - X_[0]); n_ = n_ / max(np.linalg.norm(n_), 1e-12)
            gesicht = ('Regular' in o.name or 'Head' in o.name) and n_[1] < -0.5   # Kopfnetz, Flaeche nach vorn (Blender -y)
            gruppen.setdefault(mn, []).append((X_, np.array([uvl[i].uv[:] for i in ls]), gesicht))
    oe.to_mesh_clear()

ERG = {}
for mn, tris in gruppen.items():
    B = np.zeros((BILD, BILD, 3), np.float32); M = np.zeros((BILD, BILD), np.uint8)   # 1 getroffen, 2 ohne Treffer
    AUG = np.zeros((BILD, BILD), bool)   # Texel am Kopf
    KOPF_G = any(g_ for _, _, g_ in tris) or any(('Regular' in o.name or 'Head' in o.name) and matname(o.data.materials[0]) == mn for o in koerper)
    for X, U, gesicht in tris:
        px = U * [BILD, BILD]; px[:, 1] = BILD - px[:, 1]
        x0, y0 = np.maximum(np.floor(px.min(0)).astype(int), 0); x1, y1 = np.minimum(np.ceil(px.max(0)).astype(int), BILD - 1)
        if x1 < x0 or y1 < y0: continue
        gx, gy = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
        G2 = np.stack([gx.ravel(), gy.ravel()], 1)
        v0, v1 = px[1] - px[0], px[2] - px[0]; v2 = G2 - px[0]
        d00, d01, d11 = v0 @ v0, v0 @ v1, v1 @ v1; den = d00 * d11 - d01 * d01
        if abs(den) < 1e-12: continue
        d20, d21 = v2 @ v0, v2 @ v1
        bv = (d11 * d20 - d01 * d21) / den; bw = (d00 * d21 - d01 * d20) / den; bu = 1 - bv - bw
        drin = np.minimum(np.minimum(bu, bv), bw) >= -0.02
        for (gxx, gyy), b in zip(G2[drin], np.stack([bu, bv, bw], 1)[drin]):
            xx, yy = int(gxx), int(gyy)
            if M[yy, xx] == 1: continue
            P3 = b @ X
            co, n, fi, d = bvh_h.find_nearest(Vector(P3))
            if co is None or d > WEIT:
                if M[yy, xx] == 0: M[yy, xx] = 2; B[yy, xx] = (1, 0, 1)
                continue
            t = htri[fi]; bb = bary(np.array(co), HV2[t[0]], HV2[t[1]], HV2[t[2]])
            B[yy, xx] = probe(bb @ VT[huv[fi]]); M[yy, xx] = 1
            if KOPF_G and AUGEN is not None and P3[2] > AUGEN.z - 0.13: AUG[yy, xx] = True   # Gesicht und Kopf ueber dem Kinn
    # (2b) Lippen, Lidrand, Nasenloch: das MakeHuman-Bild malt sie kraeftig rot (Lippen wie geschminkt); am Kaufkopf fallen sie groesser
    # aus (Probe 2031: zwei rote Ovale am Mund). Stark rote Texel am Kopf (Rot ueber ROT_F mal Gruen) werden zu 70 % aus der Haut ringsum
    # gefuellt (Mittel der Nachbarn, Schritte), 30 % eigene Farbe bleiben (Lippen leicht roeter)
    rot = AUG & (M == 1) & (B[..., 0] > ROT_F * B[..., 1])
    n_rot = int(rot.sum()); rot0 = rot.copy(); B0 = B.copy()
    gut = (M == 1) & ~rot
    for _ in range(60):
        if not rot.any(): break
        S = np.zeros_like(B); C = np.zeros((BILD, BILD), np.float32)
        for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            sv = np.roll(gut, (dy, dx), (0, 1)); S += np.roll(B, (dy, dx), (0, 1)) * sv[..., None]; C += sv
        f = rot & (C > 0)
        B[f] = S[f] / C[f][:, None]; gut |= f; rot &= ~f
    B[rot0] = 0.7 * B[rot0] + 0.3 * B0[rot0]
    print('ROT', mn, int((AUG & (M == 1)).sum()), 'Texel am Kopf, stark rot gemildert', n_rot)
    # (3) Rand fuellen (8 Schritte, nur ausserhalb der Inseln)
    voll = M > 0
    for _ in range(8):
        neu = ~voll
        S = np.zeros_like(B); C = np.zeros((BILD, BILD), np.float32)
        for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)):
            sv = np.roll(voll, (dy, dx), (0, 1)); sb = np.roll(B, (dy, dx), (0, 1))
            S += sb * sv[..., None]; C += sv
        f = neu & (C > 0)
        B[f] = S[f] / C[f][:, None]; voll |= f
    ok = M == 1
    lin = np.where(B <= 0.04045, B / 12.92, ((B + 0.055) / 1.055) ** 2.4)
    mittel = B[ok].mean(0)
    hell = float((lin[ok] @ np.array([0.2126, 0.7152, 0.0722])).mean())
    p = os.path.join(ZIEL, '%s__%s.jpg' % (KENNUNG, mn))
    Image.fromarray((np.clip(B, 0, 1) * 255 + 0.5).astype(np.uint8)).save(p, quality=90)
    info = {'material': mn, 'mittel_srgb': [round(float(x), 4) for x in mittel], 'hell_linear': round(hell, 4),
            'texel': int(ok.sum()), 'ohne_treffer': int((M == 2).sum()), 'quelle': os.path.basename(bild_p), 'bild': BILD}
    ERG[mn] = (p, info)
# Bezug der Toenung wie held_klassen.py haut_bild: Median der Bildfarbe an den Ecken des Kopfnetzes im Gesicht (Band unter den Augen,
# vordere Haelfte), Ruhelage; alle Bilder eines Koerpers mit demselben Bezug (toene nimmt ihn fuer jede Hautflaeche)
GES, ALT = [], []
for o in koerper:
    if not ('Regular' in o.name or 'Head' in o.name) or AUGEN is None: continue
    mn = matname(o.data.materials[0]); im = np.asarray(Image.open(ERG[mn][0]).convert('RGB'), dtype=np.float32) / 255.0
    W_ = np.array([o.matrix_world @ v.co for v in o.data.vertices]); my = W_[:, 1].mean()
    ok = (W_[:, 2] > AUGEN.z - 0.09) & (W_[:, 2] < AUGEN.z) & (W_[:, 1] < my)
    uv = o.data.uv_layers[0].data
    alt = next((n.image for n in o.data.materials[0].node_tree.nodes if n.type == 'TEX_IMAGE' and n.image), None)
    if alt:
        Wa, Ha = alt.size; pa = np.empty(Wa * Ha * 4, np.float32); alt.pixels.foreach_get(pa); pa = pa.reshape(Ha, Wa, 4)
    for l in o.data.loops:
        if not ok[l.vertex_index]: continue
        u, v = uv[l.index].uv
        GES.append(im[min(int((1 - v % 1) * im.shape[0]), im.shape[0] - 1), min(int(u % 1 * im.shape[1]), im.shape[1] - 1)])
        if alt: ALT.append(pa[int(v % 1 * Ha) % Ha, int(u % 1 * Wa) % Wa, :3])   # wie held_klassen.py bildfarbe (Blender-Bild, v unten)
G_ = np.median(np.array(GES), axis=0)
lin = lambda c: np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
srgb = lambda l: np.where(l <= 0.0031308, l * 12.92, 1.055 * l ** (1 / 2.4) - 0.055)
# gleich der heutigen Haut (kutte_haut_2031: der heutige Bezug haut_bild aus held-klassen.json liegt nicht genau auf dem Median des Bandes,
# Menschen 23 % heller als der Zielton): Bezug der neuen Haut = Median neu * haut_bild heute / Median heute (gleiches Band, linear)
KJ = os.environ.get('KLASSEN', os.path.join(HIER, '..', '..', '..', 'godot', 'daten', 'held-klassen.json'))
G = 'W' if re.search(r'_W\.(bin|glb)$', HELD) else 'M'   # Geschlecht aus dem Dateinamen (haut_bild je Geschlecht)
if os.path.exists(KJ) and ALT:
    kj = json.load(open(KJ)); tr = re.sub(r'^held_|\.(bin|glb)$', '', os.path.basename(HELD))
    hb = kj['trachten'].get(tr, {}).get('haut_bild', kj['geschlechter'][G]['haut_bild'])
    fak = lin(np.array(hb)) / np.maximum(lin(np.median(np.array(ALT), axis=0)), 1e-4)
    print('BEZUG heute', tr, 'haut_bild', hb, 'Median Band heute', np.median(np.array(ALT), axis=0).round(4), 'Faktor', fak.round(3))
    G_ = srgb(np.clip(lin(G_) * fak, 0, 1))
GL = lin(G_)
for mn, (p, info) in ERG.items():
    info['gesicht_srgb'] = [round(float(x), 4) for x in G_]
    info['gesicht_hell_linear'] = round(float(GL @ np.array([0.2126, 0.7152, 0.0722])), 4)
    info['gesicht_ecken'] = len(GES)
    json.dump(info, open(p[:-4] + '.json', 'w'), indent=1)
    print('HAUT_MH', KENNUNG, mn, info)
