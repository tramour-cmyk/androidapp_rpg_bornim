#!/usr/bin/env python3
# 854 (Jerry 10.11.; Chef 12:34 „Kaufmodelle im Kaufrepo ablegen, ja“, 12:37 „fang doch nicht immer bei Null an“): die mit Blender
# gebauten Modelle (Schritte „CC0-Pakete“ bis „Kampfort bauen“ in godot.yml) als Anhang der Version „bau“ im privaten Kaufrepo
# ablegen und wiederholen, statt 35-40 Minuten neu zu bauen. Nie in dieses öffentliche Repo, nie als Artefakt oder actions/cache
# (Caches eines öffentlichen Repos liest auch ein Lauf aus einem fremden Fork).
# Kennung = Hash über alles, was den Bau bestimmt: tools/blender348/** (Skripte, Waffen, cc0_laden.sh), die Texte der Bauschritte in
# godot.yml, bpy-Fassung, CC0-Cache-Schlüssel, godot/daten/karten.json (dorf.py, raum.py) und die Kaufdateien (Anhänge aller Versionen
# außer „bau“ mit Name, Größe, Datum; Dateien im Kaufrepo ohne *.md). Ändert sich eines, baut man neu und legt neu ab.
# Aufruf im Repo (nach „Karten und Texte“, weil karten.json in die Kennung geht):
#   kauf_cache.py kennung            Kennung ausgeben
#   kauf_cache.py holen              Treffer: Dateien nach godot/daten, godot/kampf/daten, Ende 0; sonst Ende 1
#   kauf_cache.py vorher             Stand von godot/daten und godot/kampf/daten merken (vor dem Bau)
#   kauf_cache.py ablegen            seit „vorher“ neue oder geänderte Dateien packen und hochladen (ältere Anhänge: die 8 neuesten bleiben)
# Zugang: in der Sitzung über den Proxy; auf dem Bauserver GH_TOKEN mit Schreibrecht aufs Kaufrepo.
import hashlib, json, os, re, subprocess, sys, tarfile, tempfile, urllib.request
import yaml

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
KAUF = os.environ.get('KAUF', '/home/user/bornim-kaufmodelle')
RT = os.environ.get('RUNNER_TEMP', '/home/user/rt')
R = 'tramour-cmyk/bornim-kaufmodelle'
TAG = 'bau'
BEHALTEN = 8
SCHRITTE = ['CC0-Pakete', 'Modelle bauen', 'Held je Klasse', 'Kampfort bauen']
ORDNER = ['godot/daten', 'godot/kampf/daten']
VORHER = os.path.join(RT, 'kauf_cache_vorher.json')


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


def versionen():
    return api('/releases?per_page=100')


def kennung():
    h = hashlib.sha256()
    def teil(name, b):
        h.update(name.encode() + b'\0' + hashlib.sha256(b).digest())
    bl = os.path.join(REPO, 'tools/blender348')
    for wurzel, dirs, dateien in os.walk(bl):
        dirs[:] = sorted(d for d in dirs if d != '__pycache__')
        for f in sorted(dateien):
            if f.endswith('.pyc'):
                continue
            p = os.path.join(wurzel, f)
            teil(os.path.relpath(p, REPO), open(p, 'rb').read())
    wf = yaml.safe_load(open(os.path.join(REPO, '.github/workflows/godot.yml')))['jobs']['apk']['steps']
    for n in SCHRITTE:
        st = [s for s in wf if s.get('name', '').startswith(n)]
        teil('schritt ' + n, (st[0].get('run', '') if st else 'FEHLT').encode())
    caches = [json.dumps(s.get('with', {}), sort_keys=True) for s in wf if 'actions/cache' in str(s.get('uses', ''))
              and str(s.get('with', {}).get('path', '')) in ('bl', '~/cc0')]
    teil('caches', '\n'.join(caches).encode())
    teil('karten', open(os.path.join(REPO, 'godot/daten/karten.json'), 'rb').read())
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
    teil('kauf', '\n'.join(sorted(kauf)).encode())
    return h.hexdigest()[:20]


def bau_version(anlegen=False):
    for v in versionen():
        if v['tag_name'] == TAG:
            return v
    if not anlegen:
        return None
    return api('/releases', json.dumps({'tag_name': TAG, 'name': 'Gebaute Kaufmodelle (854, Cache)', 'target_commitish': 'main',
                                        'body': 'Gebaut von tools/godot/kauf_cache.py im Spiel-Repo; je Kennung ein Anhang. Nie weitergeben.'}).encode(), 'POST')


def holen():
    k = kennung()
    v = bau_version()
    a = [x for x in (v['assets'] if v else []) if x['name'] == 'bau-%s.tar.gz' % k]
    if not a:
        print('KAUF-CACHE kein Treffer', k, flush=True)
        return 1
    with tempfile.TemporaryDirectory() as t:
        p = os.path.join(t, 'bau.tar.gz')
        kopf = ['-H', 'Accept: application/octet-stream'] + (['-H', 'Authorization: Bearer ' + os.environ['GH_TOKEN']] if os.environ.get('GH_TOKEN') else [])
        for versuch in range(3):
            r = subprocess.run(['curl', '-sSL', '-o', p] + kopf + [a[0]['url']])
            if r.returncode == 0 and os.path.getsize(p) == a[0]['size']:
                break
        else:
            print('KAUF-CACHE Laden misslungen', k, flush=True)
            return 1
        with tarfile.open(p) as tf:
            namen = tf.getnames()
            if any(n.startswith(('/', '..')) or '/../' in n or not n.startswith(tuple(o + '/' for o in ORDNER)) for n in namen):
                sys.exit('KAUF-CACHE fremder Pfad im Paket')
            tf.extractall(REPO)
        # kauf.txt (Liste fürs Verschlüsseln) hängen die Schritte an; hier stand vorher die Liste aus „Karten und Texte“ (leer)
    print('KAUF-CACHE Treffer', k, len(namen), 'Dateien', a[0]['size'] // 2**20, 'MB', flush=True)
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


def vorher():
    os.makedirs(RT, exist_ok=True)
    json.dump(stand(), open(VORHER, 'w'))


def ablegen():
    k = kennung()
    alt = json.load(open(VORHER))
    neu = sorted(p for p, w in stand().items() if alt.get(p) != w)
    if not neu:
        sys.exit('KAUF-CACHE nichts gebaut')
    v = bau_version(anlegen=True)
    name = 'bau-%s.tar.gz' % k
    for a in v['assets']:
        if a['name'] == name:
            print('KAUF-CACHE schon abgelegt', k, flush=True)
            return
    with tempfile.TemporaryDirectory() as t:
        p = os.path.join(t, name)
        with tarfile.open(p, 'w:gz', compresslevel=3) as tf:
            for f in neu:
                tf.add(os.path.join(REPO, f), f)
        with open(p, 'rb') as f:
            api('/releases/%d/assets?name=%s' % (v['id'], name), f, 'POST', 'uploads.github.com', 'application/gzip', os.path.getsize(p))
        print('KAUF-CACHE abgelegt', k, len(neu), 'Dateien', os.path.getsize(p) // 2**20, 'MB', flush=True)
    v = bau_version()
    alte = sorted((a for a in v['assets'] if re.match(r'bau-[0-9a-f]+\.tar\.gz$', a['name'])), key=lambda a: a['created_at'])[:-BEHALTEN]
    for a in alte:
        api('/releases/assets/%d' % a['id'], methode='DELETE')
        print('KAUF-CACHE alt entfernt', a['name'], flush=True)


if __name__ == '__main__':
    befehl = sys.argv[1] if len(sys.argv) > 1 else ''
    if befehl == 'kennung':
        print(kennung())
    elif befehl == 'holen':
        sys.exit(holen())
    elif befehl == 'vorher':
        vorher()
    elif befehl == 'ablegen':
        ablegen()
    else:
        sys.exit('Aufruf: kauf_cache.py kennung|holen|vorher|ablegen')
