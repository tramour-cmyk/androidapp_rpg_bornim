# 431 Nachbesserung (Sokrates 25.11., 08:08; LISTE-FIGUREN.md „Völker“, Zwerg 3: Frauen zwei Zöpfe von den Schläfen bis auf die Brust):
# Doppelzopf aus MakeHuman-Paket hair01, „elvs_double_mh_braid“ (Elvaerwyn), CC0 laut
# https://static.makehumancommunity.org/assets/assetpacks/hair01.html (gelesen 25.11.), Datei hair01_cc0.zip.
# Legt ihn auf den Frauenkopf unserer Haare (haare_w.bin, Ruhelage der Bezugsfigur, Meter, Y oben, Blick +Z) und führt die Zöpfe, die
# im Paket hinten hängen, von den Schläfen nach vorn bis auf die Brust. Ausgabe: godot/figuren/zopf_zwergin.glb (Netz „Zopf_Zwergin“,
# Material „Hair_Zopf“ mit Bild in Grau wie die Haare des Pakets, damit HeldFigur.toene die Haarfarbe trifft).
# Aufruf: bl/bin/python -I tools/blender348/v3/zopf_mh.py <ordner mit double_mhbraid.obj und braid01_diffuse_black.png> <ausgabe.glb>
import sys, os
import numpy as np
from PIL import Image
import bpy

QUELLE, AUS = sys.argv[1], sys.argv[2]
# Bezug: Hair_Buzzed auf dem Frauenkopf (haare_w.bin, gemessen 25.11.): Breite 0,170 m, Scheitel 1,770 m, Tiefe -0,115 .. 0,079 m
BREITE, SCHEITEL, Z_MITTE = 0.170 * 1.16, 1.785, -0.022
SCHNITT = 0.20      # dm unter dem Scheitel des Pakets beginnen die Zöpfe (2,0 dm)
SCHLAEFE_X, VORN_Z = 0.072, 0.035   # Ansatz an den Schläfen, vor dem Ohr
AUSSEN, BRUST_Z = 0.035, 0.10       # nach unten: so weit nach außen und nach vorn (Brust der Frau etwa 0,10-0,13 m vor dem Kopf)

V, VT, F = [], [], []
for z in open(os.path.join(QUELLE, 'double_mhbraid.obj')):
    p = z.split()
    if not p: continue
    if p[0] == 'v': V.append([float(x) for x in p[1:4]])
    elif p[0] == 'vt': VT.append([float(x) for x in p[1:3]])
    elif p[0] == 'f': F.append([tuple(int(i) - 1 for i in q.split('/')[:2]) for q in p[1:]])
V = np.array(V)
oben = V[:, 1].max()
kappe = V[V[:, 1] > oben - 2.0]
k = BREITE / (kappe[:, 0].max() - kappe[:, 0].min())
W = np.empty_like(V)
W[:, 0] = (V[:, 0] - (kappe[:, 0].max() + kappe[:, 0].min()) / 2) * k
W[:, 1] = (V[:, 1] - oben) * k + SCHEITEL
W[:, 2] = (V[:, 2] - (kappe[:, 2].max() + kappe[:, 2].min()) / 2) * k + Z_MITTE
yc = SCHEITEL - SCHNITT * 10 * k   # Ansatz der Zöpfe in Metern
# Zöpfe: je Seite die Mittellinie in Scheiben (1 cm), Abstand jeder Ecke von ihr bleibt; die Mittellinie läuft neu von der Schläfe
# nach vorn unten bis auf die Brust (weich, Länge wie im Paket)
zopf = (W[:, 1] < yc) & (np.abs(W[:, 0]) > 0.025)   # Nackenhaar zwischen den Zöpfen bleibt hinten
for seite in (-1, 1):
    m = zopf & (np.sign(W[:, 0]) == seite)
    idx = np.where(m)[0]
    if len(idx) == 0: continue
    s = yc - W[idx, 1]                          # Tiefe unter dem Ansatz
    zent = np.zeros((len(idx), 2))
    for b in np.unique(np.floor(s / 0.01)):
        j = np.floor(s / 0.01) == b
        zent[j] = W[idx][j][:, [0, 2]].mean(0)
    off = W[idx][:, [0, 2]] - zent
    t = np.clip(s / 0.12, 0, 1)
    glatt = t * t * (3 - 2 * t)
    W[idx, 0] = seite * (SCHLAEFE_X + AUSSEN * glatt) + off[:, 0]
    W[idx, 2] = VORN_Z + (BRUST_Z - VORN_Z) * glatt + off[:, 1]
print('ZOPF Ecken %d, Zöpfe %d, Maßstab %.4f, Ansatz %.3f m, Ende %.3f m' % (len(W), zopf.sum(), k, yc, W[:, 1].min()))

me = bpy.data.meshes.new('Zopf_Zwergin')
# Blender Z oben, Blick -Y; glTF-Export dreht zurück (Y oben, +Z vorn)
me.from_pydata([(x, -z, y) for x, y, z in W], [], [[i for i, _ in f] for f in F])
uv = me.uv_layers.new()
for poly in me.polygons:
    for li, (_, ti) in zip(poly.loop_indices, F[poly.index]):
        uv.data[li].uv = VT[ti]
for o in list(bpy.data.objects): bpy.data.objects.remove(o)
ob = bpy.data.objects.new('Zopf_Zwergin', me)
bpy.context.scene.collection.objects.link(ob)
# Bild: Grau mit Mittel 0,545 wie haar_bild der Haare (held-klassen.json), 512 px. Das Paketbild ist fast schwarz (Mittel 0,05);
# linear auf 0,545 gehoben (Faktor ~10, abgeschnitten) wurden Straehnen weiss und Schattenstellen schwarz, getoent orange-schwarz
# gefleckt wie Fell (Pruefer 25.11., 09:58; Test zopf_431 rot 69,8 %). Daher Helligkeit mit Gamma 0,4 gestaucht und nur halb
# gespannt (Mittel 1 ± Haelfte), Straehnen bleiben sichtbar
a = np.asarray(Image.open(os.path.join(QUELLE, 'braid01_diffuse_black.png')).convert('RGBA')).astype(float) / 255
t = (a[..., :3].mean(2) + 0.004) ** 0.4
t /= t.mean()
g = np.repeat(np.clip(0.545 * (0.5 + 0.5 * t), 0, 1)[..., None], 3, axis=2)
bild = os.path.join(os.path.dirname(AUS) or '.', '_zopf.png')
Image.fromarray((np.dstack([g, a[..., 3:]]) * 255).astype(np.uint8)).resize((512, 512), Image.LANCZOS).save(bild)
mat = bpy.data.materials.new('Hair_Zopf')
mat.use_nodes = True
tx = mat.node_tree.nodes.new('ShaderNodeTexImage')
tx.image = bpy.data.images.load(bild)
mat.node_tree.links.new(tx.outputs['Color'], mat.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
me.materials.append(mat)
bpy.ops.export_scene.gltf(filepath=AUS, export_format='GLB', export_image_format='JPEG')
os.remove(bild)
print('ZOPF geschrieben', AUS, os.path.getsize(AUS))
