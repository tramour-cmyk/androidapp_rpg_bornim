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
    # gebaute, ignorierte Dateien (Kaufmodelle, Import) teilen: gleiche res://-Pfade
    for d in godot/.godot godot/daten godot/kampf/daten; do
        [ -e "$REPO/$d" ] && [ ! -e "$W/$d" ] && ln -s "$REPO/$d" "$W/$d"
    done
done
lauf() {   # Stand Name Umgebung…
    local s=$1 n=$2; shift 2
    (cd "$AUS/wt_$s/godot" && env "$@" timeout 900 ~/godot/godot --headless --fixed-fps 30 --path . -s res://tests/sollbild_784.gd \
        > "$AUS/${s}_$n.txt" 2>&1)
}
export -f lauf; export AUS
{
    for s in main alle zweig; do
        echo "$s wolves7 GEGNER=WOLVES SEED=7 STRENG=1"
        for g in RUDEL GRIMM; do for i in $(seq 1 10); do echo "$s ${g,,}$i GEGNER=$g SEED=$i RUNDEN=99 ZEILEN=1"; done; done
    done
} | xargs -P "$(nproc)" -L 1 bash -c 'lauf "$@"' _
cp godot/tests/ring_1068.gd "$AUS/wt_main/godot/tests/"
for s in main zweig; do
    (cd "$AUS/wt_$s/godot" && HEUTE=1 N=200 timeout 3000 ~/godot/godot --headless --path . -s res://tests/ring_1068.gd > "$AUS/auto_$s.log" 2>&1) &
done
wait
echo "Stände: main $MAIN, alle 874d28464, zweig ${STAND[zweig]}" > "$AUS/zahlen.txt"
for f in "$AUS"/*_*.txt; do
    printf '%s\t%s\t%s\n' "$(basename "$f" .txt)" "$(grep -m1 -o 'SOLLBILD784 [0-9]* über dem Maß' "$f")" \
        "$(grep -E '^(Runde|Eröffnung|Ende|Ausgang)' "$f" | tr '\n' ' ')" >> "$AUS/zahlen.txt"
done
cat "$AUS/zahlen.txt"
