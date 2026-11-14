#!/usr/bin/env python3
# 882.2 (Umzug BRS Schritt 8): Kerntest = Godot-Logiksatz, ohne Kaufmodelle, am Rechner unter 2 Minuten (4 Kerne).
# Aufruf über tools/t logik [Muster]. Liste: godot/tests/logik.txt (eine Testdatei je Zeile, # Kommentar). Jede Zeile läuft mit
# genau dem Befehl und Prüfkriterium aus godot.yml „Skripte pruefen“ (eine Quelle; Zeilen mit „|| true“ sperren dort nicht und
# gehören nicht in die Liste). Vorher wie auf dem Bauserver „Karten und Texte“ und „Klang“, Import nur, wenn sich unter godot/
# etwas geändert hat. Jeder Test bekommt ein eigenes user:// (XDG_DATA_HOME), darum laufen sie nebeneinander.
# Der Rest (Messungen mit Kaufmodellen, Bilder, Filme) bleibt in godot.yml und 918.
import os, re, shutil, signal, subprocess, sys, tempfile, time
from concurrent.futures import ThreadPoolExecutor
import yaml

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
G = os.path.join(REPO, 'godot')
LISTE = os.path.join(G, 'tests', 'logik.txt')
GODOT = os.path.expanduser('~/godot/godot')
ZEIT = 120  # je Test höchstens (die langsamsten der Liste brauchen etwa 40 s)


def liste():
    return [z.split('#')[0].strip() for z in open(LISTE, encoding='utf-8') if z.split('#')[0].strip()]


def zeilen():
    """Befehl je Testdatei aus godot.yml „Skripte pruefen“; nebenher-Zeilen ausgepackt."""
    st = yaml.safe_load(open(os.path.join(REPO, '.github/workflows/godot.yml'), encoding='utf-8'))['jobs']['apk']['steps']
    run = [s for s in st if s.get('name') == 'Skripte pruefen'][0]['run']
    aus = {}
    for z in run.splitlines():
        m = re.search(r'res://tests/([a-z0-9_]+)\.gd', z)
        if not m or '|| true' in z or m.group(1) in aus:
            continue
        n = re.match(r"nebenher \S+ '(.*)'\s*(#.*)?$", z)
        aus[m.group(1)] = n.group(1) if n else z
    return aus


def vorbereiten():
    r = subprocess.run([sys.executable, os.path.join(REPO, 'tools/godot/bau_am_rechner.py'), 'Karten und Texte', 'Klang'],
                       cwd=REPO, capture_output=True, text=True)
    if r.returncode:
        sys.exit('LOGIK: Vorbereitung rot (bau_am_rechner.py „Karten und Texte“, „Klang“)\n' + (r.stdout + r.stderr)[-1500:])
    marke = os.path.join(G, '.godot', 'logik-import')
    if os.path.exists(marke):
        neu = subprocess.run(['find', G, '-path', os.path.join(G, '.godot'), '-prune', '-o', '-newer', marke, '-type', 'f',
                              '-not', '-name', '*.log', '-print', '-quit'], capture_output=True, text=True).stdout.strip()
        if not neu:
            return
    r = subprocess.run([GODOT, '--headless', '--import', '--path', G], capture_output=True, text=True, timeout=600)
    open(marke, 'w').close()


def lauf(name, befehl, ablage):
    d = tempfile.mkdtemp(prefix='logik-')
    env = dict(os.environ, XDG_DATA_HOME=d, GITHUB_WORKSPACE=ablage)
    t = time.time()
    p = subprocess.Popen(['bash', '-c', 'set -o pipefail; ' + befehl], cwd=G, env=env, stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT, text=True, start_new_session=True)
    try:
        out, _ = p.communicate(timeout=ZEIT); rc = p.returncode
    except subprocess.TimeoutExpired:
        os.killpg(p.pid, signal.SIGKILL); out, _ = p.communicate(); rc = 'Zeit'
    shutil.rmtree(d, ignore_errors=True)
    return name, rc, time.time() - t, out


def main():
    if not os.path.isfile(GODOT):
        sys.exit('LOGIK: Godot fehlt (~/godot/godot); tools/setup-session.sh holt es')
    muster = sys.argv[1] if len(sys.argv) > 1 else ''
    namen = [n for n in liste() if muster in n]
    befehle = zeilen()
    fehlt = [n for n in namen if n not in befehle]
    if fehlt:
        sys.exit('LOGIK: nicht (sperrend) im Prüfschritt von godot.yml: ' + ', '.join(fehlt))
    if not namen:
        sys.exit('LOGIK: kein Test passt zu „%s“' % muster)
    t0 = time.time()
    vorbereiten()
    vor = set(os.listdir(G))
    ablage = tempfile.mkdtemp(prefix='logik-ablage-')
    with ThreadPoolExecutor(os.cpu_count() or 2) as ex:
        res = list(ex.map(lambda n: lauf(n, befehle[n], ablage), namen))
    # Unter Last nebeneinander kann ein zeitkritischer Test kippen (13.11.: eingebung_840 zweimal im ersten Lauf nach dem
    # Klonen); rote einmal allein wiederholen, grün allein heißt „wackelig“ (genannt, nicht rot; auf dem Bauserver laufen sie einzeln)
    rot = []
    for r in res:
        if r[1] == 0:
            continue
        r2 = lauf(r[0], befehle[r[0]], ablage)
        if r2[1] == 0:
            print('WACKELIG %s (nebeneinander Exit %s, allein grün)' % (r[0], r[1]))
        else:
            rot.append(r2)
    for f in set(os.listdir(G)) - vor:  # Protokolle der Testzeilen (tee x.log) nicht im Arbeitsordner lassen
        if f.endswith('.log'):
            os.remove(os.path.join(G, f))
    shutil.rmtree(ablage, ignore_errors=True)
    for name, rc, s, out in rot:
        print('ROT %s (Exit %s, %.0f s):' % (name, rc, s))
        print('\n'.join('    ' + z for z in out.strip().splitlines()[-12:]))
    print('LOGIK %d gut, %d rot (%.0f s)' % (len(res) - len(rot), len(rot), time.time() - t0))
    sys.exit(1 if rot else 0)


if __name__ == '__main__':
    main()
