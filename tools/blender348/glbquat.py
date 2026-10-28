# 348.12 Runde 2c, 387: Vorzeichen der Drehschlüssel im GLB stetig (aus goblin.py herausgelöst, auch für kauftier.py)
import json, os


def quat_stetig(pfad):
    """348.12 Runde 2b (Prüfer Probe 1: Grak, Film Hieb Bild 1 Axt kopfüber; Probe 2 SCHAU_MESS: Hieb Bild 3 Achse (−0,29; −0,95; −0,15)
    statt (−0,29; 0,95; 0,10), nur beim Überblenden aus Gehen): der Ausgang von Blender wählt das Vorzeichen jeder Drehung frei (q und −q,
    dieselbe Drehung; Unterarm im Hieb 14-mal w < 0), Godot blendet zwei Bewegungen ohne Abgleich über den langen Weg. Im GLB je Spur das
    erste Bild auf die Seite der Ruhelage des Knochens, jedes weitere auf die Seite des vorigen (nachgestellt mit Slerp: höchstens 3°)"""
    import struct
    b = bytearray(open(pfad, 'rb').read())
    jl = struct.unpack_from('<I', b, 12)[0]; G = json.loads(b[20:20 + jl].decode())
    bin0 = 20 + jl + 8; n = 0
    for an in G.get('animations', []):
        for ch in an['channels']:
            if ch['target'].get('path') != 'rotation': continue
            acc = G['accessors'][an['samplers'][ch['sampler']]['output']]; bv = G['bufferViews'][acc['bufferView']]
            st = bv.get('byteStride', 16); o0 = bin0 + bv.get('byteOffset', 0) + acc.get('byteOffset', 0)
            vor = G['nodes'][ch['target']['node']].get('rotation', [0.0, 0.0, 0.0, 1.0])
            for k in range(acc['count']):
                q = struct.unpack_from('<4f', b, o0 + k * st)
                if sum(x * y for x, y in zip(q, vor)) < 0:
                    q = tuple(-x for x in q); struct.pack_into('<4f', b, o0 + k * st, *q); n += 1
                vor = q
    open(pfad, 'wb').write(bytes(b)); print('QUAT STETIG', os.path.basename(pfad), n, 'Schlüssel gewendet')
