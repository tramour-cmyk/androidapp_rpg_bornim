# 417 Messung 3b (Pruefer 01.11., 13:3x: Schwert durch Schild, Schild vor dem Gesicht, Bogen im Becken; Messung 3 fand keine Prop-Lage,
# weil die Props in den Prefabs als verschachtelte Prefabs haengen): wo die Pakete ihre Waffe in der Hand fuehren. Liest die Unity-
# Prefabs und Demoszenen der Pakete als Text (GameObject, Transform, PrefabInstance mit Aenderungen, Namen aus den .meta der FBX) und
# druckt die Kette Prop -> Eltern -> Knochen mit Lage und Drehung. Nur Text, kein Bild (390a); gekaufte Dateien bleiben auf dem Runner.
# Aufruf: KAUF=<kaufpakete> python3 -I griff417.py
import glob, os, re

KAUF = os.environ['KAUF']
PAKETE = ('2.HANDED', '1.HANDED', 'SWORD.SHIELD', 'BOW.ARROW')
WICHTIG = re.compile(r'prop|weapon|sword|shield|bow|axe|quiver|arrow|hand|bludgeon', re.I)


def bloecke(t):
    aus = {}
    for b in re.split(r'\n--- !u!', '\n' + t)[1:]:
        kopf, _, rest = b.partition('\n')
        m = re.match(r'(\d+) &(-?\d+)( stripped)?', kopf)
        if m: aus[m.group(2)] = {'klasse': m.group(1), 'stripped': bool(m.group(3)), 'text': rest}
    return aus


def feld(t, k):
    m = re.search(r'^\s*' + re.escape(k) + r':\s*(.*)$', t, re.M)
    return m.group(1).strip() if m else ''


def fid(s):
    m = re.search(r'fileID:\s*(-?\d+)', s); return m.group(1) if m else ''


def guid(s):
    m = re.search(r'guid:\s*([0-9a-f]+)', s); return m.group(1) if m else ''


metas = {}
for p in glob.glob(os.path.join(KAUF, '**', '*.meta'), recursive=True):
    try: t = open(p, encoding='utf-8', errors='replace').read(4000)
    except OSError: continue
    g = feld(t, 'guid')
    if g: metas[g] = p[:-5]


def fbx_namen(g):   # fileID -> Name aus internalIDToNameTable (bzw. fileIDToRecycleName) der .meta
    p = metas.get(g)
    if not p or not os.path.exists(p + '.meta'): return {}
    t = open(p + '.meta', encoding='utf-8', errors='replace').read()
    n = {}
    for m in re.finditer(r'first:\s*\n\s*\d+:\s*(-?\d+)\s*\n\s*second:\s*(.+)', t): n[m.group(1)] = m.group(2).strip()
    for m in re.finditer(r'^\s*(-?\d+):\s*(\S.*)$', t, re.M):
        n.setdefault(m.group(1), m.group(2).strip())
    return n


for paket in PAKETE:
    dateien = sorted(p for p in glob.glob(os.path.join(KAUF, '**', '*'), recursive=True) if p.endswith(('.prefab', '.unity'))
                     and ('ANIMSET.' + paket) in p.upper() and re.search(r'Protof-Actor@|DemoScene|Prop', os.path.basename(p)) and os.path.isfile(p))
    print('PAKET %s: %d Dateien' % (paket, len(dateien)))
    for p in dateien:
        t = open(p, encoding='utf-8', errors='replace').read()
        B = bloecke(t)
        kl = {}
        for b in B.values(): kl[b['klasse']] = kl.get(b['klasse'], 0) + 1
        print('DATEI %s | %s | %d Bytes | Bloecke %s' % (paket, os.path.relpath(p, KAUF), len(t), kl))
        if not t.startswith('%YAML'): print('  BINAER, Anfang', repr(t[:40])); continue
        name = {i: feld(b['text'], 'm_Name') for i, b in B.items() if b['klasse'] == '1'}
        tf_go = {i: fid(feld(b['text'], 'm_GameObject')) for i, b in B.items() if b['klasse'] == '4'}
        def tname(i):
            b = B.get(i)
            if b is None: return '?%s' % i
            if b['stripped']:
                src = feld(b['text'], 'm_CorrespondingSourceObject')
                return 'stripped(%s@%s)' % (fbx_namen(guid(src)).get(fid(src), fid(src)), os.path.basename(metas.get(guid(src), guid(src))))
            return name.get(tf_go.get(i, ''), '?')
        def kette(i, n=8):
            k = []
            while i and i != '0' and n:
                k.append(tname(i)); b = B.get(i); i = fid(feld(b['text'], 'm_Father')) if b else ''; n -= 1
            return ' < '.join(k)
        z = 0
        for i, b in B.items():
            if b['klasse'] == '4' and not b['stripped'] and WICHTIG.search(tname(i)) and z < 40:
                z += 1
                print('  TF %s: pos %s rot %s skal %s | %s' % (i, feld(b['text'], 'm_LocalPosition'), feld(b['text'], 'm_LocalRotation'),
                      feld(b['text'], 'm_LocalScale'), kette(i)))
        for i, b in B.items():
            if b['klasse'] != '1001': continue
            m = b['text']
            par = fid(feld(m, 'm_TransformParent'))
            src = guid(feld(m, 'm_SourcePrefab'))
            print('  PREFABINSTANZ %s von %s, Eltern %s' % (i, os.path.basename(metas.get(src, src)), kette(par)))
            for mm in re.finditer(r'- target: \{([^}]*)\}\s*\n\s*propertyPath: (\S+)\s*\n\s*value: ?(.*)', m):
                if re.match(r'm_(Name|LocalPosition|LocalRotation|LocalScale|LocalEulerAnglesHint|IsActive)', mm.group(2)):
                    print('    %s = %s (%s)' % (mm.group(2), mm.group(3).strip(), fbx_namen(guid(mm.group(1))).get(fid(mm.group(1)), fid(mm.group(1)))))
        for i, b in B.items():
            if b['klasse'] == '4' and b['stripped']:
                print('  STRIPPED %s = %s, Kinder %s' % (i, tname(i), feld(b['text'], 'm_PrefabInstance')))
print('GRIFF417 fertig')
