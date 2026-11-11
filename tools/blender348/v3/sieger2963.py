# 296.3 (Siegerpose, Chef 23.10., 18:25; Bestand zuerst 377, mehrere Stuecke drehend in einem Film 408): alle Bewegungen der
# Protofactor-Saetze (Schwert & Schild, Einhand, Zweihand, Bogen, Zauberer), deren Name nach Sieg, Spott, Jubel klingt, je eine .glb
# auf dem Geruest der UAL (zauber385.py, Becken nach Beinlaenge wie 438a). Dazu nimmt film_sieger_2963.gd Celebration aus der UAL Pro.
# Aufruf: KAUF=<kaufpakete> ZIEL=<UAL1.glb> OUT=<ordner> BL=<bl/bin/python> python3 -I sieger2963.py
import glob, os, re, subprocess, sys

KAUF = os.environ['KAUF']; ZIEL = os.environ['ZIEL']; OUT = os.environ['OUT']; BL = os.environ.get('BL', sys.executable)
HIER = os.path.dirname(os.path.abspath(__file__))
WORTE = re.compile(os.environ.get('WORTE', 'taunt|victory|cheer|celebrat|triumph|salute'), re.I)
os.makedirs(OUT, exist_ok=True)
alle = sorted(set(glob.glob(os.path.join(KAUF, '**', 'Humanoid@*.fbx'), recursive=True) + glob.glob(os.path.join(KAUF, '**', 'Humanoid@*.FBX'), recursive=True)))
treffer = []
for p in alle:
    n = os.path.basename(p)[len('Humanoid@'):-4]
    if n.lower().endswith('_rm') or not WORTE.search(n):     # ohne Wurzelweg-Fassungen
        continue
    treffer.append((n, p))
print('SIEGER Kandidaten: %d aus %d Bewegungen' % (len(treffer), len(alle)))
for n, p in treffer:
    ziel = os.path.join(OUT, re.sub(r'[^A-Za-z0-9_]', '_', n) + '.glb')
    r = subprocess.run([BL, '-I', os.path.join(HIER, 'zauber385.py')],
                       env=dict(os.environ, QUELLE=p, ZIEL=ZIEL, NAME=re.sub(r'[^A-Za-z0-9_]', '_', n), OUT=ziel, BECKEN='bein'),
                       capture_output=True, text=True)
    ok = r.returncode == 0 and os.path.exists(ziel)
    print('SIEGER %s %s (%s)' % ('ok' if ok else 'FEHLER', n, os.path.relpath(p, KAUF)))
    if not ok:
        print(r.stdout[-400:], r.stderr[-400:])
