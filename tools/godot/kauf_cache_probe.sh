#!/bin/bash
# 854 (Kennung je Block): Probe von kauf_cache.py am Rechner, ohne Kaufrepo und ohne Blender. Eine Kopie des Repos (nur godot.yml,
# tools/blender348, kauf_cache.py, ein karten.json) und ein nacktes git-Repo als Kaufrepo; die Bauschritte schreiben nur Platzhalter
# zwischen den Marken wie godot.yml. Prüft: erster Lauf baut alles und legt vier Zweige ab; zweiter Lauf trifft alles und holt
# dieselben Dateien; eine Änderung an raum.py baut nur dorf neu (und nennt raum.py), eine an kauftier.py nur kampf (figur wird für
# kampf neu gebaut, aber nicht geholt), eine an held_klassen.py nur klassen. 1101: eine Datei über der Teilgröße (hier 1 MB statt 45,
# Kaufrepo lehnt wie GitHub (GH001) jede Datei darüber ab) geht in Teilen über mehrere Stücke und kommt beim Holen ganz zurück, ohne
# Teile in godot/daten; misslingt dorf, steht kein halber Zweig bau/dorf-…, und kampf wird trotzdem abgelegt.
# Aufruf im Repo: bash tools/godot/kauf_cache_probe.sh   (Ende 0 = gut)
set -euo pipefail
QUELLE=$(cd "$(dirname "$0")/../.." && pwd)
T=$(mktemp -d); [ -n "${BEHALTEN:-}" ] && echo "Probe in $T" || trap 'rm -rf "$T"' EXIT
R=$T/repo; mkdir -p $R/tools/godot $R/.github/workflows $R/godot/daten $R/godot/kampf/daten
cp -r $QUELLE/tools/blender348 $R/tools/; cp $QUELLE/tools/godot/kauf_cache.py $R/tools/godot/
cp $QUELLE/.github/workflows/godot.yml $R/.github/workflows/
echo '{"karten": {}}' > $R/godot/daten/karten.json
git init -q --bare $T/kauf.git
export KAUF_CACHE_PROBE=$T/kauf.git KAUF=$T/ohne
fehler=0
pruefe() { if eval "$1"; then echo "gut  $2"; else echo "FALSCH $2"; fehler=$((fehler+1)); fi; }
KC="python3 $R/tools/godot/kauf_cache.py"

lauf() {   # ein Lauf wie godot.yml: pruefen, Teile nach den Schaltern, Leute, holen, Kampfort, ablegen; $1 = Inhalt der Platzhalter
  export RUNNER_TEMP=$T/rt-$RANDOM; mkdir -p $RUNNER_TEMP
  ABLEGEN=0
  rm -rf $R/godot/daten/*.bin $R/godot/daten/leute $R/godot/kampf/daten/*; : > $R/godot/daten/kauf.txt
  local E=$RUNNER_TEMP/env; : > $E
  $KC pruefen --env $E > $RUNNER_TEMP/pruefen.log || true
  set -a; . $E; set +a
  if [ "$KAUF_ALLES" != treffer ]; then
    $KC merke start
    if [ "$KAUF_FIGUR_BAUEN" = ja ]; then echo "held $1" > $R/godot/daten/held.bin; echo daten/held.bin >> $R/godot/daten/kauf.txt; fi
    $KC merke figur
    if [ "$KAUF_DORF" != treffer ]; then echo "dorf $1" > $R/godot/daten/dorf.bin
      [ -n "${GROSS:-}" ] && python3 -c "import random,sys; random.seed(sys.argv[1]); sys.stdout.buffer.write(random.randbytes(2600000))" "$1" > $R/godot/daten/deep_forest.bin
    fi
    $KC merke dorf
  fi
  if [ "$KAUF_KLASSEN" != treffer ]; then
    $KC merke vor_klassen; echo "klassen $1" > $R/godot/daten/held_WACHE_M.bin; echo daten/held_WACHE_M.bin >> $R/godot/daten/kauf.txt
    $KC merke klassen
  fi
  mkdir -p $R/godot/daten/leute; echo leute > $R/godot/daten/leute/garrick.bin; echo daten/leute/garrick.bin >> $R/godot/daten/kauf.txt
  [ "$KAUF_HOLEN" = ja ] && $KC holen > $RUNNER_TEMP/holen.log
  if [ "$KAUF_KAMPF" != treffer ]; then
    $KC merke vor_kampf; echo "kampf $1" > $R/godot/kampf/daten/wolf.bin; $KC merke kampf
  fi
  if [ "$KAUF_ALLES" = bauen ]; then $KC ablegen > $RUNNER_TEMP/ablegen.log || ABLEGEN=$?; fi
  return 0
}
inhalt() { cat $R/godot/daten/held.bin $R/godot/daten/dorf.bin $R/godot/daten/held_WACHE_M.bin $R/godot/kampf/daten/wolf.bin 2>/dev/null | tr '\n' ' '; }

lauf eins
pruefe '[ "$KAUF_ALLES" = bauen ] && [ "$KAUF_FIGUR" = bauen ] && [ "$KAUF_DORF" = bauen ]' "erster Lauf baut alles"
pruefe '[ $(git --git-dir=$T/kauf.git for-each-ref refs/heads/bau | wc -l) = 4 ]' "vier Zweige abgelegt"
eins=$(inhalt)

lauf zwei
pruefe '[ "$KAUF_ALLES" = treffer ] && [ "$KAUF_HOLEN" = ja ]' "zweiter Lauf trifft alles"
pruefe '[ "$(inhalt)" = "$eins" ]' "geholt wie gebaut ($(inhalt))"
pruefe 'grep -qx daten/held_WACHE_M.bin $R/godot/daten/kauf.txt && grep -qx daten/held.bin $R/godot/daten/kauf.txt' "kauf.txt der Blöcke angehängt"
pruefe '[ $(grep -c . $R/godot/daten/kauf.txt) = 3 ]' "kauf.txt ohne Doppel ($(grep -c . $R/godot/daten/kauf.txt) Zeilen)"

echo "# 854 Probe" >> $R/tools/blender348/v3/raum.py
lauf drei
pruefe '[ "$KAUF_DORF" = bauen ] && [ "$KAUF_FIGUR" = treffer ] && [ "$KAUF_KLASSEN" = treffer ] && [ "$KAUF_KAMPF" = treffer ] && [ "$KAUF_FIGUR_BAUEN" = nein ]' "raum.py: nur dorf baut"
pruefe 'grep -q "dorf .*raum.py" $RUNNER_TEMP/pruefen.log' "Schritt 7 nennt raum.py ($(grep 'dorf ' $RUNNER_TEMP/pruefen.log | cut -c1-120))"
pruefe '[ "$(inhalt)" = "held eins dorf drei klassen eins kampf eins " ]' "dorf neu, der Rest geholt ($(inhalt))"

echo "# 854 Probe" >> $R/tools/blender348/kauftier.py
lauf vier
pruefe '[ "$KAUF_KAMPF" = bauen ] && [ "$KAUF_DORF" = treffer ] && [ "$KAUF_KLASSEN" = treffer ] && [ "$KAUF_FIGUR_BAUEN" = ja ]' "kauftier.py: nur kampf baut, figur dafür neu"
pruefe '[ "$(inhalt)" = "held vier dorf drei klassen eins kampf vier " ]' "kampf neu, figur neu gebaut statt geholt ($(inhalt))"

echo "# 854 Probe" >> $R/tools/blender348/v3/held_klassen.py
lauf fuenf
pruefe '[ "$KAUF_KLASSEN" = bauen ] && [ "$KAUF_KAMPF" = treffer ] && [ "$KAUF_DORF" = treffer ]' "held_klassen.py: nur klassen baut"

echo "# 854 Probe" >> $R/tools/blender348/v3/rig.py
lauf sechs
pruefe '[ "$KAUF_FIGUR" = bauen ] && [ "$KAUF_KLASSEN" = bauen ] && [ "$KAUF_KAMPF" = bauen ] && [ "$KAUF_DORF" = treffer ]' "rig.py: figur, klassen, kampf bauen, dorf trifft"

# 1101: Kaufrepo lehnt Dateien über 1,1 MB ab wie GitHub über 100 MB; mit der Datei „abweisen“ auch jeden Zweig bau/dorf-…
cat > $T/kauf.git/hooks/pre-receive <<'HAKEN'
#!/bin/bash
while read alt neu ref; do
  [ -f abweisen ] && [[ $ref == refs/heads/bau/dorf-* ]] && { echo "abgewiesen $ref"; exit 1; }
  git rev-list --objects $neu --not --all | while read o n; do
    if [ "$(git cat-file -t $o)" = blob ] && [ $(git cat-file -s $o) -gt 1150000 ]; then echo "GH001 $n zu groß"; exit 1; fi
  done || exit 1
done
exit 0
HAKEN
chmod +x $T/kauf.git/hooks/pre-receive
export KAUF_CACHE_TEIL_MB=1 KAUF_CACHE_STUECK_MB=1.5
echo "# 1101 Probe" >> $R/tools/blender348/v3/raum.py
GROSS=1 lauf sieben
pruefe '[ "$KAUF_DORF" = bauen ] && [ $ABLEGEN = 0 ]' "1101: dorf mit großer Datei abgelegt (Ende $ABLEGEN)"
gross=$(sha256sum < $R/godot/daten/deep_forest.bin)
k=$($KC kennung dorf | cut -d' ' -f2)
pruefe '[ $(git --git-dir=$T/kauf.git ls-tree -r --name-only bau/dorf-$k | grep -c "deep_forest.bin.kauf-teil-00[1-3]-von-003") = 3 ]' "1101: drei Teile im Zweig"
pruefe '[ $(git --git-dir=$T/kauf.git rev-list --count bau/dorf-$k) -ge 2 ]' "1101: über mehrere Stücke ($(git --git-dir=$T/kauf.git rev-list --count bau/dorf-$k))"
GROSS=1 lauf acht
pruefe '[ "$KAUF_DORF" = treffer ] && [ "$(sha256sum < $R/godot/daten/deep_forest.bin)" = "$gross" ]' "1101: geholt Byte für Byte gleich"
pruefe '! ls $R/godot/daten | grep -q kauf-teil' "1101: keine Teile in godot/daten"
pruefe 'grep -q "geholt dorf .* 2 Dateien" $RUNNER_TEMP/holen.log' "1101: holen zählt ganze Dateien ($(grep 'geholt dorf' $RUNNER_TEMP/holen.log))"
(cd $R && $KC vergleich > $RUNNER_TEMP/vergleich.log) && v=0 || v=$?
pruefe '[ $v = 0 ] && grep -q " 0 abweichend" $RUNNER_TEMP/vergleich.log' "1101: Gegenprobe setzt Teile zusammen ($(tail -1 $RUNNER_TEMP/vergleich.log))"
touch $T/kauf.git/abweisen
echo "# 1101 Probe" >> $R/tools/blender348/v3/raum.py; echo "# 1101 Probe" >> $R/tools/blender348/kauftier.py
GROSS=1 lauf neun
k=$($KC kennung dorf | cut -d' ' -f2); kk=$($KC kennung kampf | cut -d' ' -f2)
pruefe '[ $ABLEGEN = 1 ] && grep -q "::warning::KAUF-CACHE Ablegen misslungen dorf" $RUNNER_TEMP/ablegen.log' "1101: misslungenes Ablegen meldet Warnung und Ende 1"
pruefe '! git --git-dir=$T/kauf.git rev-parse -q --verify refs/heads/bau/dorf-$k > /dev/null' "1101: kein halber Zweig bau/dorf-$k"
pruefe 'git --git-dir=$T/kauf.git rev-parse -q --verify refs/heads/bau/kampf-$kk > /dev/null' "1101: kampf trotzdem abgelegt"
rm $T/kauf.git/abweisen
lauf zehn
pruefe '[ "$KAUF_DORF" = bauen ] && [ "$KAUF_KAMPF" = treffer ] && [ $ABLEGEN = 0 ]' "1101: nächster Lauf baut dorf neu und legt ab"

echo "KAUFCACHE854 $([ $fehler = 0 ] && echo gut || echo "$fehler Fehler")"
exit $fehler
