#!/usr/bin/env python3
# 854 (Jerry 10.11.; Chef 12:34 „Kaufmodelle im Kaufrepo ablegen, ja“, 12:37 „fang doch nicht immer bei Null an“): die mit Blender
# gebauten Modelle (Schritte „Modelle bauen“ bis „Kampfort bauen“ in godot.yml) als Zweig bau/<Kennung> im privaten Kaufrepo
# ablegen und wiederholen, statt 35-40 Minuten neu zu bauen. Nie in dieses öffentliche Repo, nie als Artefakt oder actions/cache
# (Caches eines öffentlichen Repos liest auch ein Lauf aus einem fremden Fork).
# Kennung = Hash über alles, was den Bau bestimmt: tools/blender348/** (Skripte, Waffen, cc0_laden.sh), die Texte der Bauschritte in
# godot.yml, bpy-Fassung, CC0-Cache-Schlüssel, godot/daten/karten.json (dorf.py, raum.py) und die Kaufdateien (Anhänge aller Versionen
# mit Name, Größe, Datum; Dateien im Kaufrepo ohne *.md). Ändert sich eines, baut man neu und legt neu ab.
# Aufruf im Repo (nach „Karten und Texte“, weil karten.json in die Kennung geht):
#   kauf_cache.py kennung            Kennung ausgeben
#   kauf_cache.py pruefen            Ende 0, wenn es einen Zweig zur Kennung gibt (nichts geladen)
#   kauf_cache.py holen              Treffer: Dateien nach godot/daten, godot/kampf/daten, Ende 0; sonst Ende 1
#   kauf_cache.py vorher             Stand von godot/daten und godot/kampf/daten merken (vor dem Bau)
#   kauf_cache.py ablegen            seit „vorher“ neue oder geänderte Dateien als Zweig bau/<Kennung> schieben
#   kauf_cache.py vergleich          Gegenprobe nach einem vollen Bau ohne Cache: jede Datei des Zweigs Byte für Byte gegen den Bau;
#                                    Ende 1 bei Abweichung (dann deckt die Kennung eine Eingabe nicht; Perikles 10.11., zu 854)
# Eingaben außerhalb tools/blender348/ lesen die Schritte heute nur aus karten.json (dorf.py, raum.py) und daten/waffen/ (Kampfort
# bauen, aus „Leute bauen“, das selbst nur tools/blender348/ und karten.json liest); eine neue solche Eingabe gehört in kennung().
# Zugang: in der Sitzung über den Proxy; auf dem Bauserver GH_TOKEN mit Schreibrecht (Contents) aufs Kaufrepo.
import hashlib, json, os, re, shutil, subprocess, sys, tempfile, urllib.request
import yaml

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
KAUF = os.environ.get('KAUF', '/home/user/bornim-kaufmodelle')
RT = os.environ.get('RUNNER_TEMP', '/home/user/rt')
R = 'tramour-cmyk/bornim-kaufmodelle'
TAG = 'bau'   # frühere Version für den Cache, aus der Kennung ausgenommen
SCHRITTE = ['CC0-Pakete', 'Modelle bauen', 'Held je Klasse', 'Kampfort bauen']
ORDNER = ['godot/daten', 'godot/kampf/daten']
VORHER = os.path.join(RT, 'kauf_cache_vorher.json')
# Auf dem Bauserver laufen „Leute bauen“ und „Dorftiere bauen“ (Tom) zwischen den Schritten; deren Dateien bleiben draußen, sie bauen
# bei jedem Lauf selbst. godot/daten/kauf.txt (Liste fürs Verschlüsseln) teilen sich alle: abgelegt werden nur die Zeilen der Schritte
# oben (Mitglied ZUSATZ), beim Holen angehängt.
# Ausnahme: die Kaufschilde (Kampfort bauen, kaufschild.py) ersetzen daten/waffen/shield.bin und round_shield.bin aus „Leute bauen“; darum
# holt der Bauserver erst nach den Dorftieren (Schritt vor „Kampfort bauen“) und prüft vorher nur, ob es einen Treffer gibt.
OHNE = ('godot/daten/leute/', 'godot/daten/tiere/', 'godot/daten/dorftiere/', 'godot/daten/kauf.txt')
WAFFEN = ('godot/daten/waffen/shield.bin', 'godot/daten/waffen/round_shield.bin')
LISTE = 'godot/daten/kauf.txt'
ZUSATZ = 'KAUF_ZUSATZ'


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
    h.update(b'format 2')   # Inhalt des Zweigs (2: mit den Kaufschilden in daten/waffen)
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


def git(*a, cwd=None, check=True, **kw):
    return subprocess.run(['git'] + list(a), cwd=cwd, check=check, text=True, **kw)


def zweig(k):
    return 'bau/' + k


def url():
    # in der Sitzung setzt der Proxy den Zugang; auf dem Bauserver GH_TOKEN (KAUF_TOKEN) in der Adresse wie kauf_laden.sh
    t = os.environ.get('GH_TOKEN')
    return 'https://%sgithub.com/%s.git' % ('x-access-token:%s@' % t if t else '', R)


def pruefen(k=None):
    k = k or kennung()
    if not git('ls-remote', url(), 'refs/heads/' + zweig(k), capture_output=True).stdout.strip():
        print('KAUF-CACHE kein Treffer', k, flush=True)
        return 1
    return 0


def holen():
    k = kennung()
    if pruefen(k):
        return 1
    with tempfile.TemporaryDirectory() as t:
        git('init', '-q', t)
        for versuch in range(3):
            if git('fetch', '-q', '--depth', '1', url(), zweig(k), cwd=t, check=False).returncode == 0:
                break
        else:
            print('KAUF-CACHE Laden misslungen', k, flush=True)
            return 1
        namen = git('ls-tree', '-r', '--name-only', 'FETCH_HEAD', cwd=t, capture_output=True).stdout.splitlines()
        if ZUSATZ not in namen:
            print('KAUF-CACHE Zweig unvollständig', k, flush=True)
            return 1
        if any(n != ZUSATZ and (n.startswith(('/', '..')) or '/../' in n or not n.startswith(tuple(o + '/' for o in ORDNER))) for n in namen):
            sys.exit('KAUF-CACHE fremder Pfad im Zweig')
        git('-c', 'core.autocrlf=false', '--work-tree', REPO, 'checkout', '-q', 'FETCH_HEAD', '--', *[n for n in namen if n != ZUSATZ], cwd=t)
        zusatz = git('show', 'FETCH_HEAD:' + ZUSATZ, cwd=t, capture_output=True).stdout
    with open(os.path.join(REPO, LISTE), 'a') as f:
        f.write(zusatz)
    print('KAUF-CACHE Treffer', k, len(namen), 'Dateien', flush=True)
    return 0


def vergleich():
    k = kennung()
    if pruefen(k):
        return 1
    with tempfile.TemporaryDirectory() as t:
        git('init', '-q', t)
        if git('fetch', '-q', '--depth', '1', url(), zweig(k), cwd=t, check=False).returncode:
            print('KAUF-CACHE Laden misslungen', k, flush=True)
            return 1
        namen = [n for n in git('ls-tree', '-r', '--name-only', 'FETCH_HEAD', cwd=t, capture_output=True).stdout.splitlines() if n != ZUSATZ]
        git('-c', 'core.autocrlf=false', 'checkout', '-q', 'FETCH_HEAD', '--', *namen, cwd=t)
        anders = []
        for n in namen:
            p = os.path.join(REPO, n)
            if not os.path.exists(p) or open(p, 'rb').read() != open(os.path.join(t, n), 'rb').read():
                anders.append(n)
    for n in anders[:20]:
        print('KAUF-CACHE weicht ab', n, flush=True)
    print('KAUF-CACHE Gegenprobe', k, len(namen), 'Dateien,', len(anders), 'abweichend', flush=True)
    return 1 if anders else 0


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


def vorher():
    os.makedirs(RT, exist_ok=True)
    json.dump({'stand': stand(), 'liste': liste()}, open(VORHER, 'w'))


def ablegen():
    # je Kennung ein eigener Zweig bau/<Kennung> ohne Vorgeschichte im Kaufrepo (Versionen anlegen darf eine Sitzung nicht); gleiche
    # Dateien teilen sich git-Objekte, ein neuer Zweig kostet nur, was sich geändert hat. In Stücken von etwa 60 MB geschoben (413);
    # ZUSATZ kommt mit dem letzten Stück und zeigt, dass der Zweig vollständig ist (Löschen von Zweigen lehnt die Sitzung ab).
    k = kennung()
    alt = json.load(open(VORHER))
    neu = sorted(p for p, w in stand().items() if alt['stand'].get(p) != w and not p.startswith(OHNE)
                 and (not p.startswith('godot/daten/waffen/') or p in WAFFEN))
    zusatz = [z for z in liste() if z not in alt['liste'] and not z.startswith(('daten/leute/', 'daten/dorftiere/', 'daten/tiere/'))]
    if not neu:
        sys.exit('KAUF-CACHE nichts gebaut')
    if git('ls-remote', url(), 'refs/heads/' + zweig(k), capture_output=True).stdout.strip():
        print('KAUF-CACHE Zweig gibt es schon (ganz oder halb), nicht überschrieben', k, flush=True)
        return
    with tempfile.TemporaryDirectory() as t:
        git('init', '-q', t)
        git('config', 'user.name', 'kauf_cache', cwd=t); git('config', 'user.email', 'kauf_cache@bornim.invalid', cwd=t)
        with open(os.path.join(t, ZUSATZ), 'w') as f:
            f.write(''.join(z + '\n' for z in zusatz))
        stuecke, jetzt, groesse = [], [], 0
        for f in neu:
            jetzt.append(f); groesse += os.path.getsize(os.path.join(REPO, f))
            if groesse > 60 * 2**20:
                stuecke.append(jetzt); jetzt, groesse = [], 0
        stuecke.append(jetzt + [ZUSATZ])
        for i, st in enumerate(stuecke):
            for f in st:
                if f != ZUSATZ:
                    os.makedirs(os.path.dirname(os.path.join(t, f)), exist_ok=True)
                    shutil.copy2(os.path.join(REPO, f), os.path.join(t, f))
            git('add', '-f', '--', *st, cwd=t)
            git('commit', '-q', '-m', '854 Kennung %s, Teil %d/%d' % (k, i + 1, len(stuecke)), cwd=t)
            for versuch in range(4):
                if git('push', '-q', url(), 'HEAD:refs/heads/' + zweig(k), cwd=t, check=False).returncode == 0:
                    break
            else:
                sys.exit('KAUF-CACHE Ablegen misslungen ' + k)
    print('KAUF-CACHE abgelegt', k, len(neu), 'Dateien', sum(os.path.getsize(os.path.join(REPO, f)) for f in neu) // 2**20, 'MB', flush=True)


if __name__ == '__main__':
    befehl = sys.argv[1] if len(sys.argv) > 1 else ''
    if befehl == 'kennung':
        print(kennung())
    elif befehl == 'pruefen':
        sys.exit(pruefen())
    elif befehl == 'holen':
        sys.exit(holen())
    elif befehl == 'vorher':
        vorher()
    elif befehl == 'ablegen':
        ablegen()
    elif befehl == 'vergleich':
        sys.exit(vergleich())
    else:
        sys.exit('Aufruf: kauf_cache.py kennung|pruefen|holen|vorher|ablegen|vergleich')
