#!/usr/bin/env python3
# 562 (Jerry 08.11.): baut am Rechner, was der Bauserver (godot.yml) vor den Prüfschritten baut, mit den Kaufmodellen, damit
# Messungen wie wolf_mess_438, groesse_587, wenden_560 ohne Bauserverlauf laufen (Prüftreppe 1; kein Probelauf, kein Bild).
# Vorher einmal: add_repo bornim-kaufmodelle, nach /home/user/bornim-kaufmodelle klonen (die Anhänge holt dieses Skript),
# Blender als Modul: python3 -m venv ~/bl && ~/bl/bin/pip install bpy==5.2.3 numpy pillow; ln -s ~/bl bl (im Repo, nicht committen).
# Aufruf im Repo: python3 tools/godot/bau_am_rechner.py [--laden] [--cache] [Schritt-Anfang …]
#   ohne Schritte: Karten und Texte, CC0, Modelle, Held je Klasse, Kampfort (am Rechner mit 4 Kernen etwa 35 Minuten)
#   --cache (854): ohne Schritte erst Karten und Texte, dann je Block (figur, dorf, klassen, leute, kampf) die gebauten Modelle aus dem
#   Kaufrepo (kauf_cache.py, wenige Minuten); nur was fehlt --laden und Bau, danach ablegen, damit die nächste Sitzung nicht bei Null
#   anfängt
#   danach: cd godot && ~/godot/godot --headless --import --path . ; dann die Tests wie im Prüfschritt
# Rohdateien bleiben in /home/user/bornim-kaufmodelle (nie in dieses Repo); godot/daten und godot/kampf/daten sind ignoriert.
import json, os, re, subprocess, sys, tempfile, urllib.request
import yaml

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
KAUF = os.environ.get('KAUF', '/home/user/bornim-kaufmodelle')
RT = os.environ.get('RUNNER_TEMP', '/home/user/rt')
# 854 (Tom 10.11., 14:55): „Leute bauen“ wie auf dem Bauserver vor „Kampfort bauen“ (daten/leute, daten/waffen; Kampfort liest
# daten/waffen, die Kaufschilde ersetzen dort shield und round_shield)
SCHRITTE = ['Karten und Texte', 'CC0-Pakete', 'Modelle bauen', 'Held je Klasse', 'Leute bauen', 'Kampfort bauen',
            'Held in den Kampfort']   # 1114

def laden():
    # Anhänge der Version stufe1 über die API (der Zugang kommt vom Proxy der Sitzung), dann entpacken wie kauf_laden.sh
    api = 'https://api.github.com/repos/tramour-cmyk/bornim-kaufmodelle/releases/tags/stufe1'
    rel = json.load(urllib.request.urlopen(api))
    ziel = os.path.join(KAUF, 'anhang', 'stufe1'); os.makedirs(ziel, exist_ok=True)
    for a in rel['assets']:
        p = os.path.join(ziel, a['name'])
        if os.path.exists(p) and os.path.getsize(p) == a['size']:
            continue
        for versuch in range(3):
            r = subprocess.run(['curl', '-sSL', '-o', p + '.part', '-H', 'Accept: application/octet-stream', a['url']])
            if r.returncode == 0 and os.path.getsize(p + '.part') == a['size']:
                os.replace(p + '.part', p); print('geladen', a['name'], flush=True); break
        else:
            print('FEHLT', a['name'], flush=True)
    # kauf_laden.sh entpackt nur (ohne gh: ein stilles gh im PATH, das keine Versionen meldet). Nur einmal: ein zweiter Lauf packt
    # auch die Zips in den ausgepackten Ordnern aus (Universal.Base.Characters.Source/Engine Projects/Godot), dann findet
    # held_klassen.py dort Haare ohne Bilder (ZeroDivisionError in bildfarbe)
    marke = os.path.join(KAUF, 'anhang', '.entpackt')
    if os.path.exists(marke):
        return
    leer = tempfile.mkdtemp()
    with open(os.path.join(leer, 'gh'), 'w') as f: f.write('#!/bin/sh\nexit 0\n')
    os.chmod(os.path.join(leer, 'gh'), 0o755)
    env = dict(os.environ, PATH=leer + ':' + os.environ['PATH'], GH_TOKEN='nur-entpacken')
    subprocess.run(['bash', 'tools/blender348/kauf_laden.sh', KAUF], cwd=REPO, env=env, check=True, stdout=subprocess.DEVNULL)
    open(marke, 'w').close()

def schritte(namen):
    steps = yaml.safe_load(open(os.path.join(REPO, '.github/workflows/godot.yml')))['jobs']['apk']['steps']
    env = dict(os.environ, RUNNER_TEMP=RT, GITHUB_WORKSPACE=REPO, KAUF=KAUF, GITHUB_ENV=os.devnull, GODOT='4.7.2')
    os.makedirs(RT, exist_ok=True)
    for n in namen:
        st = [s for s in steps if s.get('name', '').startswith(n)]
        if not st:
            sys.exit('kein Schritt ' + n)
        if 'verschluessel' in st[0]['name'].lower():
            sys.exit('nicht am Rechner: ' + st[0]['name'] + ' (setzt einen Schlüssel in schluessel.gd und verschlüsselt die Daten)')
        print('== SCHRITT', st[0]['name'], flush=True)
        # 778: Ausdrücke des Bauservers (${{ github.event.inputs.kampf }} …) gibt es am Rechner nicht; leer wie ein Lauf ohne Eingaben
        run = re.sub(r'\$\{\{[^}]*\}\}', '', st[0]['run'])
        r = subprocess.run(['bash', '-e', '-c', run], cwd=REPO, env=env)
        print('== ENDE', st[0]['name'], r.returncode, flush=True)
        if r.returncode:
            sys.exit(r.returncode)

def cache(mit_laden):
    # 854 Kennung je Block: wie godot.yml; pruefen setzt KAUF_<BLOCK>, KAUF_FIGUR_BAUEN, KAUF_ALLES, KAUF_HOLEN, die Schritte und
    # ihre Teile richten sich danach (am Rechner gelten die Bedingungen „if:“ der Schritte nicht, darum hier)
    kc = [sys.executable, os.path.join(REPO, 'tools/godot/kauf_cache.py')]
    os.environ.update(RUNNER_TEMP=RT, KAUF=KAUF)
    schritte(['Karten und Texte', 'CC0-Pakete'])
    e = os.path.join(RT, 'kauf_env'); os.makedirs(RT, exist_ok=True); open(e, 'w').close()
    subprocess.run(kc + ['pruefen', '--env', e], cwd=REPO)
    os.environ.update(dict(z.strip().split('=', 1) for z in open(e) if '=' in z))
    if os.environ['KAUF_ALLES'] != 'treffer' and mit_laden:
        laden()
    if os.environ['KAUF_ALLES'] != 'treffer':
        schritte(['Modelle bauen'])
    if os.environ['KAUF_KLASSEN'] != 'treffer':
        schritte(['Held je Klasse'])
    # Leute vor dem Holen (wie auf dem Bauserver): seit 1115 Block leute, der Schritt baut nur ohne Treffer (KAUF_LEUTE) und legt
    # leute.json immer hin; holen bringt danach die Leute aus dem Cache und ersetzt die Kaufschilde
    schritte(['Leute bauen'])
    if os.environ['KAUF_HOLEN'] == 'ja':
        subprocess.run(kc + ['holen'], cwd=REPO, check=True)
    if os.environ['KAUF_KAMPF'] != 'treffer':
        schritte(['Kampfort bauen'])
    schritte(['Held in den Kampfort'])   # 1114: nach dem Block kampf, auch wenn er traf
    if os.environ['KAUF_ALLES'] != 'treffer':
        subprocess.run(kc + ['ablegen'], cwd=REPO, check=True)

if __name__ == '__main__':
    args = sys.argv[1:]
    mit_laden = '--laden' in args
    if mit_laden:
        args.remove('--laden')
    if '--cache' in args and not [a for a in args if a != '--cache']:
        cache(mit_laden); sys.exit(0)
    if '--cache' in args:
        sys.exit('--cache nur ohne Schritte')
    if mit_laden:
        laden()
    schritte(args or SCHRITTE)
