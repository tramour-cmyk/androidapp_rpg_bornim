#!/usr/bin/env python3
# 854 (Jerry 10.11.; Chef 12:34 „Kaufmodelle im Kaufrepo ablegen, ja“, 12:37 „fang doch nicht immer bei Null an“): die mit Blender
# gebauten Modelle (Schritte „Modelle bauen“, „Held je Klasse“, „Kampfort bauen“ in godot.yml) als Zweige im privaten Kaufrepo
# ablegen und wiederholen, statt 35-40 Minuten neu zu bauen. Nie in dieses öffentliche Repo, nie als Artefakt oder actions/cache
# (Caches eines öffentlichen Repos liest auch ein Lauf aus einem fremden Fork).
# Kennung je Block (Chef 11.11., 08:52 „2 ja“ über Sokrates: vorher warf jede der 44 Änderungen an tools/blender348 in 7 Tagen alles
# weg, auch leute.json, Film- und Prüfskripte): je Block ein Zweig bau/<block>-<Kennung>; die Kennung geht nur über die Dateien, die
# der Block liest (Skripte des Schritts und was sie selbst laden, gefunden in ihrem Text: import, Dateinamen, Ordnernamen), den Text
# seines Schritts in godot.yml, bpy- und CC0-Cache-Schlüssel, bei dorf karten.json, bei figur/klassen/kampf die Kaufdateien, und die
# Blöcke, deren Ergebnis er braucht ($RUNNER_TEMP/out):
#   figur   tex, held3, rig (Held held.bin; sein held.glb und die Texturen in $RUNNER_TEMP/out brauchen klassen und kampf)
#   dorf    tex, dorf, raum (Dorf, Grundrisse, Wald, Bodenbilder)
#   klassen Held je Klasse (waffengang, held_klassen auch für die Leute auf dem Kaufkörper, held_kampf), braucht figur
#   kampf   Kampfort bauen (alle Skripte des Schritts), braucht figur
# Fehlt klassen oder kampf, baut „Modelle bauen“ den Teil figur trotzdem neu (4 Minuten; $RUNNER_TEMP/out liegt nicht im Cache).
# Schritt 7 nennt je Block treffer oder bauen und bei bauen die Eingaben, die sich gegen den nächsten abgelegten Stand geändert haben.
# Aufruf im Repo (nach „Karten und Texte“, weil karten.json in die Kennung geht):
#   kauf_cache.py kennung [block]    Kennungen ausgeben
#   kauf_cache.py eingaben block     die Eingabedateien eines Blocks
#   kauf_cache.py pruefen [--env D]  je Block Treffer oder nicht; schreibt KAUF_<BLOCK>=treffer|bauen, KAUF_FIGUR_BAUEN, KAUF_ALLES,
#                                    KAUF_HOLEN nach D (Bauserver: $GITHUB_ENV); Ende 0, wenn alle Blöcke Treffer sind
#   kauf_cache.py merke NAME         Stand von godot/daten und godot/kampf/daten merken (Schritte: start, figur, dorf, vor_klassen,
#                                    klassen, vor_kampf, kampf)
#   kauf_cache.py holen              die Blöcke mit Treffer, die nicht ohnehin neu gebaut werden, nach godot/daten, godot/kampf/daten
#   kauf_cache.py ablegen            je gebautem Block die zwischen seinen Marken neuen oder geänderten Dateien als Zweig schieben
#   kauf_cache.py vergleich          Gegenprobe nach einem vollen Bau ohne Cache: jede Datei jedes Blockzweigs Byte für Byte gegen den
#                                    Bau; Ende 1 bei Abweichung (dann deckt die Kennung eine Eingabe nicht; Perikles 10.11., zu 854)
# Zugang: in der Sitzung über den Proxy; auf dem Bauserver GH_TOKEN mit Schreibrecht (Contents) aufs Kaufrepo.
import hashlib, json, os, re, shutil, subprocess, sys, tempfile, urllib.request

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
KAUF = os.environ.get('KAUF', '/home/user/bornim-kaufmodelle')
RT = os.environ.get('RUNNER_TEMP', '/home/user/rt')
R = 'tramour-cmyk/bornim-kaufmodelle'
TAG = 'bau'   # frühere Version für den Cache, aus der Kennung ausgenommen
BL = 'tools/blender348'
ORDNER = ['godot/daten', 'godot/kampf/daten']
FORMAT = b'format 3'   # 3: je Block ein Zweig, mit EINGABEN
# Block: Schritt in godot.yml, Startskripte (sonst aus dem Schritt gelesen), gebraucht, Kaufdateien, karten.json, Marken (von, bis)
BLOECKE = {
    'figur': dict(schritt='Modelle bauen', skripte=['v3/tex.py', 'v3/held3.py', 'v3/rig.py'], braucht=[], kauf=True, karten=False,
                  marken=('start', 'figur')),
    'dorf': dict(schritt='Modelle bauen', skripte=['v3/tex.py', 'v3/dorf.py', 'v3/raum.py', 'v3/hoehle.py'], braucht=[], kauf=False, karten=True,
                 marken=('figur', 'dorf')),
    'klassen': dict(schritt='Held je Klasse', skripte=None, braucht=['figur'], kauf=True, karten=False, marken=('vor_klassen', 'klassen')),
    'kampf': dict(schritt='Kampfort bauen', skripte=None, braucht=['figur'], kauf=True, karten=False, marken=('vor_kampf', 'kampf')),
}
# Auf dem Bauserver laufen „Leute bauen“ und „Dorftiere bauen“ (Tom) zwischen den Blöcken; deren Dateien bleiben draußen, sie bauen
# bei jedem Lauf selbst. godot/daten/kauf.txt (Liste fürs Verschlüsseln) teilen sich alle: abgelegt werden nur die Zeilen, die ein
# Block zwischen seinen Marken anhängt (Datei ZUSATZ), beim Holen angehängt.
# Ausnahme: die Kaufschilde (kampf, kaufschild.py) ersetzen daten/waffen/shield.bin und round_shield.bin aus „Leute bauen“; darum
# holt der Bauserver erst nach den Dorftieren (Schritt vor „Kampfort bauen“).
OHNE = ('godot/daten/leute/', 'godot/daten/tiere/', 'godot/daten/dorftiere/', 'godot/daten/kauf.txt')
WAFFEN = ('godot/daten/waffen/shield.bin', 'godot/daten/waffen/round_shield.bin')
LISTE = 'godot/daten/kauf.txt'
ZUSATZ = 'KAUF_ZUSATZ'
EINGABEN = 'EINGABEN'
ENDUNGEN = ('py', 'json', 'txt', 'csv', 'png', 'jpg', 'jpeg', 'blend', 'glb', 'gltf', 'fbx', 'obj', 'svg', 'bin', 'sh', 'npy', 'exr')


def api(pfad, daten=None, methode=None, host='api.github.com', typ='application/json', laenge=None):
    req = urllib.request.Request('https://%s/repos/%s%s' % (host, R, pfad), data=daten, method=methode)
    req.add_header('Accept', 'application/vnd.github+json')
    if daten is not None:
        req.add_header('Content-Type', typ)
        if laenge is not None:
            req.add_header('Content-Length', str(laenge))
    if os.environ.get('GH_TOKEN'):
        req.add_header('Authorization', 'Bearer ' + os.environ['GH_TOKEN'])
    with urllib.request.urlopen(req) as r:
        b = r.read()
        return json.loads(b) if b else None


# Probe am Rechner ohne Kaufrepo (tests/kauf_cache_854.sh): KAUF_CACHE_PROBE=<nacktes git-Repo> statt des Kaufrepos, ohne Versionen
PROBE = os.environ.get('KAUF_CACHE_PROBE', '')


def versionen():
    return [] if PROBE else api('/releases?per_page=100')


def _schritte():
    import yaml   # erst hier: merke läuft nach setup-python ohne PyYAML (Lauf 343)
    return yaml.safe_load(open(os.path.join(REPO, '.github/workflows/godot.yml')))['jobs']['apk']['steps']


def _schritt(name):
    st = [s for s in _schritte() if s.get('name', '').startswith(name)]
    return st[0] if st else None


def _gueltig(rel):
    return not (rel.endswith(('.md', '.pyc')) or '/__pycache__/' in '/' + rel + '/')


def _ordner_dateien(rel):
    out = []
    for wurzel, dirs, dateien in os.walk(os.path.join(REPO, rel)):
        dirs[:] = sorted(d for d in dirs if d != '__pycache__')
        out += [os.path.relpath(os.path.join(wurzel, f), REPO) for f in sorted(dateien)]
    return [p for p in out if _gueltig(p)]


def _skripte_im_schritt(run):
    # tools/blender348/<pfad> und „bau <name>.py“ (Kampfort bauen: bl/bin/python tools/blender348/$n)
    namen = set()
    for m in re.finditer(r'tools/blender348/([\w./-]+)', run):
        namen.add(m.group(1).rstrip('/.'))
    for m in re.finditer(r'\bbau\s+(\w+\.py)', run):
        namen.add(m.group(1))
    return sorted(namen)


def _verweise(rel):
    # was eine Datei unter tools/blender348 selbst liest: Module (import), Dateinamen und Ordnernamen in Zeichenketten
    try:
        text = open(os.path.join(REPO, rel), encoding='utf-8', errors='replace').read()
    except OSError:
        return []
    basis = [os.path.dirname(rel), BL, BL + '/v3', BL + '/v3_kampf']
    kand = set()
    for m in re.finditer(r'^\s*(?:from\s+([\w.]+)\s+import|import\s+([\w., ]+))', text, re.M):
        for mod in (m.group(1) or m.group(2) or '').split(','):
            mod = mod.strip().split(' ')[0].lstrip('.')
            if mod:
                kand.add(mod.replace('.', '/') + '.py')
                kand.add(mod.replace('.', '/'))
    for m in re.finditer(r'[\'"]([\w./-]{2,})[\'"]', text):
        kand.add(m.group(1))
    out = []
    for k in kand:
        if k.startswith('/') and ('/' + BL + '/') in k:   # 1060: ROOT + '/tools/blender348/v3/leute.json' (raum.py, 758)
            k = k[k.index(BL):]
        if k.startswith('/') or '..' in k:
            continue
        for b in basis + ['']:
            p = os.path.normpath(os.path.join(b, k)) if b else os.path.normpath(k)
            if not p.startswith(BL + '/') and p != BL:
                continue
            voll = os.path.join(REPO, p)
            if os.path.isfile(voll) and (k.rsplit('.', 1)[-1] in ENDUNGEN or k.endswith('.py')):
                out.append(p)
                break
            if os.path.isdir(voll) and p not in (BL, BL + '/v3', BL + '/v3_kampf'):
                out += _ordner_dateien(p)
                break
    return out


def eingaben(block):
    b = BLOECKE[block]
    st = _schritt(b['schritt'])
    run = (st or {}).get('run', '')
    start = ['%s/%s' % (BL, s) for s in b['skripte']] if b['skripte'] else ['%s/%s' % (BL, s) for s in _skripte_im_schritt(run)]
    gesehen, offen = set(), []
    for s in start:
        voll = os.path.join(REPO, s)
        if os.path.isdir(voll):
            offen += _ordner_dateien(s)
        elif os.path.isfile(voll):
            offen.append(s)
    while offen:
        p = offen.pop()
        if p in gesehen or not _gueltig(p):
            continue
        gesehen.add(p)
        if p.endswith(('.py', '.sh')):
            offen += [q for q in _verweise(p) if q not in gesehen]
    return sorted(gesehen)


_kauf_cache = None
def _kauf():
    global _kauf_cache
    if _kauf_cache is None:
        kauf = []
        for v in versionen():
            if v['tag_name'] == TAG:
                continue
            for a in v['assets']:
                kauf.append('%s/%s %d %s' % (v['tag_name'], a['name'], a['size'], a['updated_at']))
        if os.path.isdir(os.path.join(KAUF, '.git')):
            ls = subprocess.run(['git', '-C', KAUF, 'ls-files', '-s'], capture_output=True, text=True, check=True).stdout
            kauf += [z for z in ls.splitlines() if not z.endswith('.md')]
        else:
            kauf.append('ohne Kaufrepo')
        _kauf_cache = '\n'.join(sorted(kauf)).encode()
    return _kauf_cache


def _liste_eingaben(block):
    # Zeilen „name hash“: alles, was in die Kennung geht (auch als Datei EINGABEN im Zweig, für den Vergleich in Schritt 7)
    b = BLOECKE[block]
    z = []
    st = _schritt(b['schritt'])
    ein = eingaben(block)
    for p in ein:
        if block in NUR_FELDER and os.path.basename(p) == 'leute.json':
            z.append('%s:felder %s' % (p, _leute_felder_hash(p, ein, (st or {}).get('run', ''))))
            continue
        z.append('%s %s' % (p, hashlib.sha256(open(os.path.join(REPO, p), 'rb').read()).hexdigest()[:16]))
    z.append('schritt:%s %s' % (b['schritt'], hashlib.sha256(((st or {}).get('run', 'FEHLT')).encode()).hexdigest()[:16]))
    caches = [json.dumps(s.get('with', {}), sort_keys=True) for s in _schritte() if 'actions/cache' in str(s.get('uses', ''))
              and str(s.get('with', {}).get('path', '')) in ('bl', '~/cc0')]
    z.append('caches %s' % hashlib.sha256('\n'.join(caches).encode()).hexdigest()[:16])
    if b['karten']:
        # 870.9: karten.json ist eingecheckt und lesbar gesetzt; die Kennung nimmt die kompakte Form (gleich dem alten Export aus core),
        # damit ein Umbruch oder Einzug allein kein neues Dorf baut
        k = json.dumps(json.load(open(os.path.join(REPO, 'godot/daten/karten.json'), encoding='utf-8')), ensure_ascii=False, separators=(',', ':'))
        z.append('godot/daten/karten.json %s' % hashlib.sha256(k.encode()).hexdigest()[:16])
    if b['kauf']:
        z.append('kaufdateien %s' % hashlib.sha256(_kauf()).hexdigest()[:16])
    for vor in b['braucht']:
        z.append('block:%s %s' % (vor, kennung(vor)))
    return z


# 1060 (Tom 12.11., 17:35; Chef 17:34 „Wieso dauern denn jetzt die Runs wieder so lange?“): klassen und kampf lesen leute.json nur
# für Gestalt, Kleidung und Bewegung; ein Feld nur fürs Dorf oder für Godot (758 Borin „sitz_cm“, Lauf 43246170504: Held je Klasse
# und Kampfort neu, 80 statt 50 Minuten) baut sie nicht neu. In die Kennung gehen je Person nur die Felder, deren Name als Wort in
# einem Skript des Blocks oder im Text seines Schritts steht, dazu alle Personen (auch ohne solches Feld); Felder mit „_“ vorn sind
# Vermerke. Gilt für jeden Block: figur (held3.py liest die Person) geht in klassen und kampf ein, dorf liest mit 758 sitz_cm (raum.py).
NUR_FELDER = ('figur', 'dorf', 'klassen', 'kampf')


def _leute_felder_hash(rel, ein, run):
    text = run + '\n'.join(open(os.path.join(REPO, q), encoding='utf-8', errors='replace').read()
                           for q in ein if q.endswith(('.py', '.sh')))
    worte = set(re.findall(r'\w+', text))
    daten = json.load(open(os.path.join(REPO, rel), encoding='utf-8'))
    aus = {}
    for pid, f in daten.items():
        if pid.startswith('_'):
            continue
        aus[pid] = {k: v for k, v in f.items() if not k.startswith('_') and k in worte} if isinstance(f, dict) else f
    return hashlib.sha256(json.dumps(aus, sort_keys=True, ensure_ascii=False, separators=(',', ':')).encode()).hexdigest()[:16]


_kennungen = {}
def kennung(block):
    if block not in _kennungen:
        h = hashlib.sha256(FORMAT + b'\0' + block.encode() + b'\0' + '\n'.join(_liste_eingaben(block)).encode())
        _kennungen[block] = h.hexdigest()[:20]
    return _kennungen[block]


def git(*a, cwd=None, check=True, **kw):
    # 854 (Lauf 335: ls-remote Exit 128, nie ein Treffer): im Arbeitsrepo setzt actions/checkout http.https://github.com/.extraheader
    # mit dem GITHUB_TOKEN, der gilt vor dem KAUF_TOKEN in der Adresse und darf das Kaufrepo nicht lesen; darum nie im Arbeitsrepo
    return subprocess.run(['git'] + list(a), cwd=cwd or tempfile.gettempdir(), check=check, text=True, **kw)


def zweig(block, k=None):
    return 'bau/%s-%s' % (block, k or kennung(block))


def url():
    # in der Sitzung setzt der Proxy den Zugang; auf dem Bauserver GH_TOKEN (KAUF_TOKEN) in der Adresse wie kauf_laden.sh
    if PROBE:
        return PROBE
    t = os.environ.get('GH_TOKEN')
    return 'https://%sgithub.com/%s.git' % ('x-access-token:%s@' % t if t else '', R)


def _fern(muster):
    r = git('ls-remote', url(), muster, capture_output=True, check=False)
    if r.returncode != 0:
        print('KAUF-CACHE Abfrage misslungen (Exit %d), gilt als kein Treffer' % r.returncode, r.stderr.strip()[-200:], flush=True)
        return None
    return dict((z.split('\t')[1], z.split('\t')[0]) for z in r.stdout.splitlines() if '\t' in z)


def _was_anders(block, alle):
    # Schritt 7: gegen den abgelegten Stand dieses Blocks mit den wenigsten Unterschieden (Datei EINGABEN im Zweig)
    jetzt = dict(z.rsplit(' ', 1) for z in _liste_eingaben(block))
    refs = [r for r in alle if r.startswith('refs/heads/bau/%s-' % block)]
    if not refs:
        return 'noch kein Stand abgelegt'
    best = None
    with tempfile.TemporaryDirectory() as t:
        git('init', '-q', t)
        if git('fetch', '-q', '--depth', '1', '--filter=blob:none', url(), *refs, cwd=t, check=False).returncode:
            return 'Vergleich nicht geladen'
        for r in refs:
            e = git('show', '%s:%s' % (alle[r], EINGABEN), cwd=t, capture_output=True, check=False)
            if e.returncode:
                continue
            alt = dict(z.rsplit(' ', 1) for z in e.stdout.splitlines() if ' ' in z)
            anders = sorted(n for n in set(alt) | set(jetzt) if alt.get(n) != jetzt.get(n))
            if best is None or len(anders) < len(best):
                best = anders
    if best is None:
        return 'kein Stand mit EINGABEN'
    return 'geändert: ' + (', '.join(best[:12]) + (' …' if len(best) > 12 else '') if best else 'nichts (Zweig halb?)')


def pruefen(env_datei=None):
    alle = _fern('refs/heads/bau/*')
    werte = {}
    for block in BLOECKE:
        k = kennung(block)
        treffer = alle is not None and ('refs/heads/' + zweig(block)) in alle
        werte['KAUF_' + block.upper()] = 'treffer' if treffer else 'bauen'
        print('KAUF-CACHE %-8s %s %s%s' % (block, 'treffer' if treffer else 'bauen  ', k,
              '' if treffer or alle is None else '  (' + _was_anders(block, alle) + ')'), flush=True)
    figur_bauen = any(werte['KAUF_' + b] == 'bauen' for b in ('FIGUR', 'KLASSEN', 'KAMPF'))
    werte['KAUF_FIGUR_BAUEN'] = 'ja' if figur_bauen else 'nein'
    werte['KAUF_ALLES'] = 'treffer' if all(v == 'treffer' for k, v in werte.items() if k[5:].lower() in BLOECKE) else 'bauen'
    werte['KAUF_HOLEN'] = 'ja' if _zu_holen(werte) else 'nein'
    if env_datei:
        with open(env_datei, 'a') as f:
            f.write(''.join('%s=%s\n' % kv for kv in werte.items()))
    else:
        print('\n'.join('%s=%s' % kv for kv in werte.items()))
    return 0 if werte['KAUF_ALLES'] == 'treffer' else 1


def _zu_holen(werte):
    # Treffer, die nicht ohnehin gebaut werden: figur wird neu gebaut, sobald klassen oder kampf fehlen
    out = [b for b in BLOECKE if werte.get('KAUF_' + b.upper()) == 'treffer']
    if werte.get('KAUF_FIGUR_BAUEN') == 'ja' and 'figur' in out:
        out.remove('figur')
    return out


def _werte_aus_env():
    return dict((k, v) for k, v in os.environ.items() if k.startswith('KAUF_'))


def holen():
    bloecke = _zu_holen(_werte_aus_env())
    if not bloecke:
        print('KAUF-CACHE nichts zu holen', flush=True)
        return 0
    zusatz = ''
    for block in bloecke:
        k = kennung(block)
        with tempfile.TemporaryDirectory() as t:
            git('init', '-q', t)
            for versuch in range(3):
                if git('fetch', '-q', '--depth', '1', url(), zweig(block), cwd=t, check=False).returncode == 0:
                    break
            else:
                print('KAUF-CACHE Laden misslungen', block, k, flush=True)
                return 1
            namen = git('ls-tree', '-r', '--name-only', 'FETCH_HEAD', cwd=t, capture_output=True).stdout.splitlines()
            if ZUSATZ not in namen:
                print('KAUF-CACHE Zweig unvollständig', block, k, flush=True)
                return 1
            namen = [n for n in namen if n not in (ZUSATZ, EINGABEN)]
            if any(n.startswith(('/', '..')) or '/../' in n or not n.startswith(tuple(o + '/' for o in ORDNER)) for n in namen):
                sys.exit('KAUF-CACHE fremder Pfad im Zweig')
            if namen:
                git('-c', 'core.autocrlf=false', '--work-tree', REPO, 'checkout', '-q', 'FETCH_HEAD', '--', *namen, cwd=t)
            zusatz += git('show', 'FETCH_HEAD:' + ZUSATZ, cwd=t, capture_output=True).stdout
        print('KAUF-CACHE geholt', block, k, len(namen), 'Dateien', flush=True)
    with open(os.path.join(REPO, LISTE), 'a') as f:
        f.write(zusatz)
    return 0


def stand():
    s = {}
    for o in ORDNER:
        for wurzel, _, dateien in os.walk(os.path.join(REPO, o)):
            for f in dateien:
                p = os.path.join(wurzel, f)
                st = os.stat(p)
                s[os.path.relpath(p, REPO)] = [st.st_size, st.st_mtime_ns]
    return s


def liste():
    p = os.path.join(REPO, LISTE)
    return open(p).read().splitlines() if os.path.exists(p) else []


def _marke(name):
    return os.path.join(RT, 'kauf_cache_%s.json' % name)


def merke(name):
    os.makedirs(RT, exist_ok=True)
    json.dump({'stand': stand(), 'liste': liste()}, open(_marke(name), 'w'))


def _block_dateien(block):
    von, bis = BLOECKE[block]['marken']
    if not (os.path.exists(_marke(von)) and os.path.exists(_marke(bis))):
        return None, None
    a, b = json.load(open(_marke(von))), json.load(open(_marke(bis)))
    neu = sorted(p for p, w in b['stand'].items() if a['stand'].get(p) != w and not p.startswith(OHNE)
                 and (not p.startswith('godot/daten/waffen/') or p in WAFFEN))
    alt_liste = list(a['liste'])
    zusatz = []
    for z in b['liste']:
        if z in alt_liste:
            alt_liste.remove(z)
        elif not z.startswith(('daten/leute/', 'daten/dorftiere/', 'daten/tiere/')):
            zusatz.append(z)
    return neu, zusatz


def ablegen():
    # je gebautem Block ein eigener Zweig bau/<block>-<Kennung> ohne Vorgeschichte im Kaufrepo (Versionen anlegen darf eine Sitzung
    # nicht); gleiche Dateien teilen sich git-Objekte. In Stücken von etwa 60 MB geschoben (413); ZUSATZ kommt mit dem letzten Stück
    # und zeigt, dass der Zweig vollständig ist (Löschen von Zweigen lehnt die Sitzung ab).
    werte = _werte_aus_env()
    alle = _fern('refs/heads/bau/*') or {}
    for block in BLOECKE:
        if werte.get('KAUF_' + block.upper()) != 'bauen':
            continue
        k = kennung(block)
        neu, zusatz = _block_dateien(block)
        if neu is None:
            print('KAUF-CACHE %s: Marken fehlen, nicht abgelegt' % block, flush=True)
            continue
        if not neu and not zusatz:
            print('KAUF-CACHE %s: nichts gebaut, nicht abgelegt' % block, flush=True)
            continue
        if ('refs/heads/' + zweig(block)) in alle:
            print('KAUF-CACHE %s: Zweig gibt es schon, nicht überschrieben' % block, k, flush=True)
            continue
        with tempfile.TemporaryDirectory() as t:
            git('init', '-q', t)
            git('config', 'user.name', 'kauf_cache', cwd=t); git('config', 'user.email', 'kauf_cache@bornim.invalid', cwd=t)
            with open(os.path.join(t, ZUSATZ), 'w') as f:
                f.write(''.join(z + '\n' for z in zusatz))
            with open(os.path.join(t, EINGABEN), 'w') as f:
                f.write(''.join(z + '\n' for z in _liste_eingaben(block)))
            stuecke, jetzt, groesse = [], [], 0
            for f in neu:
                jetzt.append(f); groesse += os.path.getsize(os.path.join(REPO, f))
                if groesse > 60 * 2**20:
                    stuecke.append(jetzt); jetzt, groesse = [], 0
            stuecke.append(jetzt + [EINGABEN, ZUSATZ])
            for i, st in enumerate(stuecke):
                for f in st:
                    if f not in (ZUSATZ, EINGABEN):
                        os.makedirs(os.path.dirname(os.path.join(t, f)), exist_ok=True)
                        shutil.copy2(os.path.join(REPO, f), os.path.join(t, f))
                git('add', '-f', '--', *st, cwd=t)
                git('commit', '-q', '-m', '854 %s %s, Teil %d/%d' % (block, k, i + 1, len(stuecke)), cwd=t)
                for versuch in range(4):
                    if git('push', '-q', url(), 'HEAD:refs/heads/' + zweig(block), cwd=t, check=False).returncode == 0:
                        break
                else:
                    sys.exit('KAUF-CACHE Ablegen misslungen %s %s' % (block, k))
        print('KAUF-CACHE abgelegt', block, k, len(neu), 'Dateien', sum(os.path.getsize(os.path.join(REPO, f)) for f in neu) // 2**20,
              'MB', flush=True)


def vergleich():
    alle = _fern('refs/heads/bau/*') or {}
    anders, gesamt = [], 0
    for block in BLOECKE:
        if ('refs/heads/' + zweig(block)) not in alle:
            print('KAUF-CACHE Gegenprobe %s: kein Zweig' % block, flush=True)
            continue
        with tempfile.TemporaryDirectory() as t:
            git('init', '-q', t)
            if git('fetch', '-q', '--depth', '1', url(), zweig(block), cwd=t, check=False).returncode:
                print('KAUF-CACHE Laden misslungen', block, flush=True)
                return 1
            namen = [n for n in git('ls-tree', '-r', '--name-only', 'FETCH_HEAD', cwd=t, capture_output=True).stdout.splitlines()
                     if n not in (ZUSATZ, EINGABEN)]
            if namen:
                git('-c', 'core.autocrlf=false', 'checkout', '-q', 'FETCH_HEAD', '--', *namen, cwd=t)
            gesamt += len(namen)
            for n in namen:
                p = os.path.join(REPO, n)
                if not os.path.exists(p) or open(p, 'rb').read() != open(os.path.join(t, n), 'rb').read():
                    anders.append(block + ': ' + n)
    for n in anders[:20]:
        print('KAUF-CACHE weicht ab', n, flush=True)
    print('KAUF-CACHE Gegenprobe', gesamt, 'Dateien,', len(anders), 'abweichend', flush=True)
    return 1 if anders else 0


if __name__ == '__main__':
    a = sys.argv[1:]
    befehl = a[0] if a else ''
    if befehl == 'kennung':
        for b in (a[1:] or list(BLOECKE)):
            print(b, kennung(b))
    elif befehl == 'eingaben' and len(a) == 2:
        print('\n'.join(eingaben(a[1])))
    elif befehl == 'pruefen':
        sys.exit(pruefen(a[a.index('--env') + 1] if '--env' in a else None))
    elif befehl == 'merke' and len(a) == 2:
        merke(a[1])
    elif befehl == 'holen':
        sys.exit(holen())
    elif befehl == 'ablegen':
        ablegen()
    elif befehl == 'vergleich':
        sys.exit(vergleich())
    else:
        sys.exit('Aufruf: kauf_cache.py kennung [block]|eingaben block|pruefen [--env datei]|merke name|holen|ablegen|vergleich')
