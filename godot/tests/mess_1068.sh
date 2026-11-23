#!/usr/bin/env bash
# 1068 (Chef 23.11., 11:27: „nur messen, wie sich die Zeit verändert hat“; Prüfer 14:40: Befehl zur Messung): spielt sollbild_784 an
# drei Ständen und schreibt je Lauf eine Zeile. Stände: main (Abzweig), Ring für alle (874d28464), Zweig (HEAD).
#   (1) Sollbild 784: GEGNER=WOLVES SEED=7 STRENG=1 (Runde, Eröffnung, held_angriff, wolf_zug, über dem Maß)
#   (2) Kampf bis Ende: GEGNER=RUDEL und GRIMM, SEED=1..10, RUNDEN=99 ZEILEN=1 (Abbruch nach 300 s Spielzeit, sollbild_784)
#   (3) Automatik-Siege je Herkunft und Gegner: ring_1068.gd HEUTE=1 N=200 an main und am Zweig (gleiche Datei, Regeln des Stands)
# Vorher: Kaufmodelle gebaut (python3 tools/godot/bau_am_rechner.py --cache --laden; cd godot && ~/godot/godot --headless --import --path .)
# Aufruf im Hauptordner: bash godot/tests/mess_1068.sh [Ausgabeordner]   (Ausgabe: je Lauf eine .txt, dazu zahlen.txt)
set -u
cd "$(dirname "$0")/../.." || exit 1
REPO=$(pwd)
AUS=${1:-/tmp/mess_1068}
MAIN=$(git merge-base origin/main HEAD)
declare -A STAND=([main]=$MAIN [alle]=874d28464 [zweig]=$(git rev-parse HEAD))
mkdir -p "$AUS"
for s in main alle zweig; do
    W="$AUS/wt_$s"
    [ -d "$W" ] || git worktree add -q --detach "$W" "${STAND[$s]}"
    # gebaute, ignorierte Dateien (Kaufmodelle, Importe) als Verweis, gleiche res://-Pfade; den Importordner je Stand als Kopie
    git ls-files -oi --exclude-standard godot | grep -v '^godot/.godot/' | while read -r f; do
        [ -e "$W/$f" ] || { mkdir -p "$(dirname "$W/$f")"; ln -s "$REPO/$f" "$W/$f"; }
    done
    [ -d "$W/godot/.godot" ] || cp -r godot/.godot "$W/godot/.godot"
    cp godot/tests/sollbild_784.gd godot/tests/ring_1068.gd "$W/godot/tests/"     # Messgerät gleich an allen Ständen (ENDE-Zeile, HEUTE)
done
lauf() {   # Stand Name Umgebung…
    local s=$1 n=$2; shift 2
    (cd "$AUS/wt_$s/godot" && env MESS=1068 "$@" timeout 900 ~/godot/godot --headless --fixed-fps 30 --path . -s res://tests/sollbild_784.gd \
        > "$AUS/${s}_$n.txt" 2>&1)
}
export -f lauf; export AUS
{
    for s in main alle zweig; do
        echo "$s wolves7 GEGNER=WOLVES SEED=7 STRENG=1"
        for g in RUDEL GRIMM; do for i in $(seq 1 10); do echo "$s ${g,,}$i GEGNER=$g SEED=$i RUNDEN=99 ZEILEN=1"; done; done
    done
} | xargs -P "$(nproc)" -L 1 bash -c 'lauf "$@"' _
for s in main zweig; do
    (cd "$AUS/wt_$s/godot" && HEUTE=1 N=200 timeout 3000 ~/godot/godot --headless --path . -s res://tests/ring_1068.gd > "$AUS/auto_$s.log" 2>&1) &
done
wait
echo "Stände: main $MAIN, alle 874d28464, zweig ${STAND[zweig]}" | tee "$AUS/zahlen.txt"
python3 - "$AUS" <<'PY' | tee -a "$AUS/zahlen.txt"
import re, sys, os
A = sys.argv[1]
def lies(n):
    p = os.path.join(A, n + '.txt')
    return open(p, encoding='utf-8', errors='replace').read() if os.path.exists(p) else ''
print('(1) Sollbild 784, WOLVES SEED=7, STRENG=1: Eröffnung | Runden | held_angriff | wolf_zug max | über dem Maß')
for s in ['main', 'alle', 'zweig']:
    t = lies(s + '_wolves7')
    er = re.findall(r'== Eröffnung: ([\d.]+) s', t)
    ru = re.findall(r'== Runde \d+: .*?, ([\d.]+) s von Wahl zu Wahl', t)
    ha = re.findall(r'Zug Held\s+([\d.]+) s', t)
    wz = [float(x) for x in re.findall(r'Zug (?:Wolf \d|wolf\d|cub\d)\s+([\d.]+) s', t)]
    ue = re.findall(r'SOLLBILD784 (\d+)', t)
    print('  %-5s %s s | %s s | %s s | %s s | %s' % (s, er[0] if er else '?', ' + '.join(ru), ' + '.join(ha), max(wz) if wz else '?', ue[0] if ue else '?'))
for g in ['rudel', 'grimm']:
    print('(2) %s bis Ende, SEED 1–10 (Abbruch 300 s Spielzeit): Summe Dauer der in allen Ständen entschiedenen | Ringe | offen nach 300 s' % g.upper())
    E = {}
    for s in ['main', 'alle', 'zweig']:
        for i in range(1, 11):
            m = re.search(r'ENDE ([\d.]+) s, Ausgang (\w+), Ringe (\d+)', lies('%s_%s%d' % (s, g, i)))
            E[s, i] = (float(m[1]), m[2], int(m[3])) if m else None
    fertig = [i for i in range(1, 11) if all(E[s, i] and E[s, i][1] != 'ONGOING' for s in ['main', 'alle', 'zweig'])]
    for s in ['main', 'alle', 'zweig']:
        dauer = sum(E[s, i][0] for i in fertig)
        ringe = sum(E[s, i][2] for i in range(1, 11) if E[s, i])
        offen = sum(1 for i in range(1, 11) if not E[s, i] or E[s, i][1] == 'ONGOING')
        print('  %-5s %6.1f s (Seeds %s) | %d | %d' % (s, dauer, ','.join(map(str, fertig)), ringe, offen))
print('(3) Automatik-Siege (ring_1068.gd HEUTE=1 N=200): Herkunft Gegner main zweig Differenz')
def auto(s):
    d = {}
    for z in open(os.path.join(A, 'auto_%s.log' % s), encoding='utf-8', errors='replace'):
        m = re.match(r'heute\s+Automatik\s+(\S+)\s+(\S+)\s+(\d+)%.*?(\d+)\s*$', z)
        if m:
            d[m[1], m[2]] = (int(m[3]), int(m[4]))
    return d
am, az = auto('main'), auto('zweig')
for k in am:
    print('  %-15s %-7s %3d%% %3d%% %+4d  Patt %d/%d%s' % (k[0], k[1], am[k][0], az[k][0], az[k][0] - am[k][0], am[k][1], az[k][1],
          '  DURCHFALL' if abs(az[k][0] - am[k][0]) > 7 or az[k][1] > 0 else ''))
PY
