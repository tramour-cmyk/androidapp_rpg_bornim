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


metas = {}       # guid -> Pfad
metatext = {}    # guid -> Inhalt der .meta
inhalt = {}      # guid -> Inhalt (nur Text: .prefab)
for p in glob.glob(os.path.join(KAUF, '**', '*.meta'), recursive=True):
    try: t = open(p, encoding='utf-8', errors='replace').read()
    except OSError: continue
    g = feld(t, 'guid')
    if g: metas[g] = p[:-5]; metatext[g] = t
# Lauf 41309203353: kauf_laden.sh packt .unitypackage ohne .meta aus; hier aus dem Paket selbst (Ordner <guid>: pathname, asset.meta)
import tarfile
for z in glob.glob(os.path.join(KAUF, '**', '*.unitypackage'), recursive=True):
    try:
        with tarfile.open(z, 'r:*') as t:
            for m in t:
                teil = m.name.lstrip('./').split('/')
                if len(teil) != 2 or not m.isfile(): continue
                if teil[1] == 'pathname': metas[teil[0]] = t.extractfile(m).read().decode('utf-8', 'replace').splitlines()[0].strip()
                elif teil[1] == 'asset.meta': metatext[teil[0]] = t.extractfile(m).read().decode('utf-8', 'replace')
                elif teil[1] == 'asset' and m.size < 200000:
                    b = t.extractfile(m).read()
                    if b.startswith(b'%YAML'): inhalt[teil[0]] = b.decode('utf-8', 'replace')
    except (OSError, tarfile.TarError) as e:
        print('PAKET NICHT LESBAR', os.path.basename(z), e)
print('GUIDS %d, meta %d, Prefab-Texte %d' % (len(metas), len(metatext), len(inhalt)))


def fbx_namen(g):   # fileID -> Name aus internalIDToNameTable (bzw. fileIDToRecycleName) der .meta
    t = metatext.get(g, '')
    if not t: return {}
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
# die Prop-Prefabs selbst (verschachtelt): Aufbau und Lage ihrer Teile, Quelle (FBX) der Netze
gesehen = set()
for paket in PAKETE:
    for g, t in inhalt.items():
        name = os.path.basename(metas.get(g, g))
        if g in gesehen or not re.search(r'Prop', name) or not name.endswith('.prefab'): continue
        gesehen.add(g)
        print('PROPPREFAB %s (%s) %s' % (name, g, metas.get(g, '')))
        for z in t.splitlines()[2:80]:
            if re.search(r'--- !u!|m_Name|m_Local(Position|Rotation|Scale)|m_Father|m_SourcePrefab|m_TransformParent|propertyPath|value:|target:|m_Mesh|m_CorrespondingSourceObject', z):
                print('   ', z.rstrip()[:200])
# Namen der Knochen, an denen die Props haengen (Figur 6f6eba35...)
for g in sorted({g for g in metatext if re.search(r'Protof-?Actor', os.path.basename(metas.get(g, '')), re.I) and metas.get(g, '').lower().endswith('.fbx')}):
    n = fbx_namen(g)
    print('FIGUR %s (%s): %d Namen; %s' % (os.path.basename(metas[g]), g, len(n), ', '.join('%s=%s' % (k, n[k]) for k in
          ('-7480972188250373298', '7884245643922716653', '-7830848555316311053') if k in n)))
for g in ('6f6eba35b8edc7d46be2a84fcc3eb248', 'cfa3ea7c30952984bb27ffecc9dccdad', '902d4c0c5058e4443ab48894a1f72cc0', 'd37934c4af0405647944aa8c04b3c47a',
          '92234b00789a7a64f9808fda309fd61a', 'db09ac67eae57b444b3154a5da349511', '8fa32a568eee9df4dbea1d984835078f'):
    t = metatext.get(g, '')
    print('GUID %s = %s, meta %d Zeichen%s' % (g, metas.get(g, '?'), len(t), ': ' + ' '.join(t.split())[:600] if g != '6f6eba35b8edc7d46be2a84fcc3eb248' else ''))
print('GRIFF417 fertig')
