#!/bin/bash
# 854 (Kennung je Block): Probe von kauf_cache.py am Rechner, ohne Kaufrepo und ohne Blender. Eine Kopie des Repos (nur godot.yml,
# tools/blender348, kauf_cache.py, ein karten.json) und ein nacktes git-Repo als Kaufrepo; die Bauschritte schreiben nur Platzhalter
# zwischen den Marken wie godot.yml. Prüft: erster Lauf baut alles und legt vier Zweige ab; zweiter Lauf trifft alles und holt
# dieselben Dateien; eine Änderung an raum.py baut nur dorf neu (und nennt raum.py), eine an kauftier.py nur kampf (figur geholt,
# 1114), eine an held_klassen.py nur klassen. 1114: rig.py, held3.py, leute.json bauen kampf nicht neu, tex.py und v3_kampf schon;
# der Held liegt nach jedem Lauf in kampf/daten (Schritt „Held in den Kampfort“), aber in keinem Zweig bau/kampf-…; setzt ein Aufruf
# von goblin.py im Schritt nicht V3=…/v3_kampf, gehören v3/held3.py und v3/rig.py wieder zu kampf. 1101: eine Datei über der Teilgröße (hier 1 MB statt 45,
# Kaufrepo lehnt wie GitHub (GH001) jede Datei darüber ab) geht in Teilen über mehrere Stücke und kommt beim Holen ganz zurück, ohne
# Teile in godot/daten; misslingt dorf, steht kein halber Zweig bau/dorf-…, und kampf wird trotzdem abgelegt.
# 1111: NEU=1 (cache=neu) baut trotz Treffer alles, überschreibt nichts, vergleich prüft die vorher abgelegten Zweige gegen den Bau
# (gleich: 0 abweichend; anders gebaut: jede Datei abweichend). 1112: HALB=kampf (geduldeter Fehler) legt kampf nicht ab, der nächste
# Lauf baut ihn neu. 1113: aufraeumen lässt je Block die neuesten 3 und den eigenen, alte bau/teil/* gehen weg. 1126: verschwindet
# ein Treffer nach pruefen (WEG=block), holt holen ihn aus dem in pruefen gesicherten Stand.
# Aufruf im Repo: bash tools/godot/kauf_cache_probe.sh   (Ende 0 = gut)
set -euo pipefail
QUELLE=$(cd "$(dirname "$0")/../.." && pwd)
T=$(mktemp -d); [ -n "${BEHALTEN:-}" ] && echo "Probe in $T" || trap 'rm -rf "$T"' EXIT
R=$T/repo; mkdir -p $R/tools/godot $R/.github/workflows $R/godot/daten $R/godot/kampf/daten
cp -r $QUELLE/tools/blender348 $R/tools/; cp $QUELLE/tools/godot/kauf_cache.py $R/tools/godot/
cp $QUELLE/.github/workflows/godot.yml $R/.github/workflows/
KARTEN_LEER='{"karten": {"village": {"leute": []}, "inn": {"leute": []}, "shop": {"leute": []}, "elder": {"leute": []}, "temple": {"leute": []}, "forest": {"leute": []}, "deep_forest": {"leute": []}, "cave": {"leute": []}}}'   # 1115: alle Karten, die „Leute bauen“ liest
echo "$KARTEN_LEER" > $R/godot/daten/karten.json
git init -q --bare $T/kauf.git
export KAUF_CACHE_PROBE=$T/kauf.git KAUF=$T/ohne
fehler=0
pruefe() { if eval "$1"; then echo "gut  $2"; else echo "FALSCH $2"; fehler=$((fehler+1)); fi; }
KC="python3 $R/tools/godot/kauf_cache.py"

lauf() {   # ein Lauf wie godot.yml: pruefen, Teile nach den Schaltern, Leute, holen, Kampfort, ablegen; $1 = Inhalt der Platzhalter
  export RUNNER_TEMP=$T/rt-$RANDOM; mkdir -p $RUNNER_TEMP
  ABLEGEN=0; unset KAUF_GEGENPROBE   # nur der Lauf mit NEU=1 setzt es (Bauserver: jeder Lauf frisch)
  rm -rf $R/godot/daten/*.bin $R/godot/daten/leute $R/godot/daten/waffen $R/godot/kampf/daten/*; : > $R/godot/daten/kauf.txt
  local E=$RUNNER_TEMP/env; : > $E
  $KC pruefen --env $E ${NEU:+--neu} > $RUNNER_TEMP/pruefen.log || true
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
  $KC merke vor_leute   # 1115: Block leute wie godot.yml „Leute bauen“
  if [ "$KAUF_LEUTE" != treffer ]; then
    mkdir -p $R/godot/daten/leute $R/godot/daten/waffen; echo "leute $1" > $R/godot/daten/leute/garrick.bin
    echo daten/leute/garrick.bin >> $R/godot/daten/kauf.txt; echo "waffe $1" > $R/godot/daten/waffen/dagger.bin
  fi
  $KC merke leute
  mkdir -p $R/godot/daten/leute; cp $R/tools/blender348/v3/leute.json $R/godot/daten/leute/
  HOLEN=-; if [ "$KAUF_HOLEN" = ja ]; then
    for b in ${WEG:-}; do git --git-dir=$T/kauf.git update-ref -d refs/heads/bau/$b-$($KC kennung $b | cut -d' ' -f2); done   # 1126
    $KC holen > $RUNNER_TEMP/holen.log && HOLEN=0 || HOLEN=$?
  fi
  if [ "$KAUF_KAMPF" != treffer ]; then
    $KC merke vor_kampf; echo "kampf $1" > $R/godot/kampf/daten/wolf.bin
    [ -n "${HALB:-}" ] && $KC halb $HALB "Probe 1112" > /dev/null
    $KC merke kampf
  fi
  local K=$R/godot/kampf/daten; mkdir -p $K; touch $K/kauf.txt $R/godot/daten/kauf.txt   # 1114 wie godot.yml
  [ -s $R/godot/daten/held.bin ] || { echo "FALSCH 1114: held.bin fehlt"; fehler=$((fehler+1)); }
  cp $R/godot/daten/held.bin $K/held.bin
  if grep -qx daten/held.bin $R/godot/daten/kauf.txt; then grep -qx kampf/daten/held.bin $K/kauf.txt || echo kampf/daten/held.bin >> $K/kauf.txt; fi
  if [ "$KAUF_ALLES" = bauen ]; then $KC ablegen > $RUNNER_TEMP/ablegen.log || ABLEGEN=$?; fi
  VERGLEICH=-; if [ -n "${KAUF_GEGENPROBE:-}" ]; then (cd $R && $KC vergleich > $RUNNER_TEMP/vergleich.log) && VERGLEICH=0 || VERGLEICH=$?; fi
  return 0
}
inhalt() { cat $R/godot/daten/held.bin $R/godot/daten/dorf.bin $R/godot/daten/held_WACHE_M.bin $R/godot/daten/leute/garrick.bin $R/godot/daten/waffen/dagger.bin $R/godot/kampf/daten/wolf.bin 2>/dev/null | tr '\n' ' '; }

lauf eins
pruefe '[ "$KAUF_ALLES" = bauen ] && [ "$KAUF_FIGUR" = bauen ] && [ "$KAUF_DORF" = bauen ]' "erster Lauf baut alles"
pruefe '[ $(git --git-dir=$T/kauf.git for-each-ref refs/heads/bau | wc -l) = 5 ]' "fünf Zweige abgelegt (1115: dazu leute)"
eins=$(inhalt)

lauf zwei
pruefe '[ "$KAUF_ALLES" = treffer ] && [ "$KAUF_HOLEN" = ja ]' "zweiter Lauf trifft alles"
pruefe '[ "$(inhalt)" = "$eins" ]' "geholt wie gebaut ($(inhalt))"
pruefe 'grep -qx daten/held_WACHE_M.bin $R/godot/daten/kauf.txt && grep -qx daten/held.bin $R/godot/daten/kauf.txt' "kauf.txt der Blöcke angehängt"
pruefe '[ $(grep -c . $R/godot/daten/kauf.txt) = 3 ]' "kauf.txt ohne Doppel ($(grep -c . $R/godot/daten/kauf.txt) Zeilen)"

zweige=$(git --git-dir=$T/kauf.git for-each-ref --format='%(refname) %(objectname)' refs/heads/bau)
NEU=1 lauf eins
pruefe '[ "$KAUF_ALLES" = bauen ] && [ "$KAUF_FIGUR_BAUEN" = ja ] && [ "$KAUF_HOLEN" = nein ] && [ "$KAUF_GEGENPROBE" = figur,dorf,klassen,leute,kampf ]' "1111: cache=neu baut trotz Treffer alles ($KAUF_GEGENPROBE)"
pruefe '[ $VERGLEICH = 0 ] && grep -q "Gegenprobe 6 Dateien, 0 abweichend (figur, dorf, klassen, leute, kampf)" $RUNNER_TEMP/vergleich.log' "1111: Gegenprobe gegen den frischen Bau ($(tail -1 $RUNNER_TEMP/vergleich.log))"
pruefe '[ "$(git --git-dir=$T/kauf.git for-each-ref --format="%(refname) %(objectname)" refs/heads/bau)" = "$zweige" ]' "1111: kein Zweig überschrieben"
NEU=1 lauf anders
pruefe '[ $VERGLEICH = 1 ] && [ $(grep -c "weicht ab" $RUNNER_TEMP/vergleich.log) = 6 ]' "1111: anders gebaut, sechs Dateien weichen ab ($(tail -1 $RUNNER_TEMP/vergleich.log))"

echo "# 854 Probe" >> $R/tools/blender348/v3/raum.py
lauf drei
pruefe '[ "$KAUF_DORF" = bauen ] && [ "$KAUF_FIGUR" = treffer ] && [ "$KAUF_KLASSEN" = treffer ] && [ "$KAUF_KAMPF" = treffer ] && [ "$KAUF_FIGUR_BAUEN" = nein ]' "raum.py: nur dorf baut"
pruefe 'grep -q "dorf .*raum.py" $RUNNER_TEMP/pruefen.log' "Schritt 7 nennt raum.py ($(grep 'dorf ' $RUNNER_TEMP/pruefen.log | cut -c1-120))"
pruefe '[ "$(inhalt)" = "held eins dorf drei klassen eins leute eins waffe eins kampf eins " ]' "dorf neu, der Rest geholt ($(inhalt))"

echo "# 854 Probe" >> $R/tools/blender348/kauftier.py
lauf vier
pruefe '[ "$KAUF_KAMPF" = bauen ] && [ "$KAUF_DORF" = treffer ] && [ "$KAUF_KLASSEN" = treffer ] && [ "$KAUF_FIGUR_BAUEN" = nein ]' "1114: kauftier.py: nur kampf baut, figur nicht"
pruefe '[ "$(inhalt)" = "held eins dorf drei klassen eins leute eins waffe eins kampf vier " ]' "1114: kampf neu, figur geholt ($(inhalt))"
pruefe 'cmp -s $R/godot/daten/held.bin $R/godot/kampf/daten/held.bin && [ $(grep -cx kampf/daten/held.bin $R/godot/kampf/daten/kauf.txt) = 1 ]' "1114: Held im Kampfort wie daten/held.bin, einmal in kampf/daten/kauf.txt"
kk=$($KC kennung kampf | cut -d' ' -f2)
pruefe '! git --git-dir=$T/kauf.git ls-tree -r --name-only bau/kampf-$kk | grep -q held' "1114: kein Held im Zweig bau/kampf-$kk"

echo "# 854 Probe" >> $R/tools/blender348/v3/held_klassen.py
lauf fuenf
pruefe '[ "$KAUF_KLASSEN" = bauen ] && [ "$KAUF_KAMPF" = treffer ] && [ "$KAUF_DORF" = treffer ]' "held_klassen.py: nur klassen baut"

echo "# 854 Probe" >> $R/tools/blender348/v3/rig.py
lauf sechs
pruefe '[ "$KAUF_FIGUR" = bauen ] && [ "$KAUF_KLASSEN" = bauen ] && [ "$KAUF_KAMPF" = treffer ] && [ "$KAUF_DORF" = treffer ]' "1114: rig.py: figur, klassen bauen, kampf und dorf treffen"
pruefe '[ "$(cat $R/godot/kampf/daten/held.bin)" = "held sechs" ]' "1114: neuer Held im Kampfort ($(cat $R/godot/kampf/daten/held.bin))"

# 1114: held3.py und leute.json (Gestalt der Leute) bauen den Kampfort nicht neu, tex.py (Gras) und v3_kampf (Goblins) schon
echo "# 1114 Probe" >> $R/tools/blender348/v3/held3.py
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); d['probe1114']={'haut':'112233'}; json.dump(d,open(sys.argv[1],'w'),ensure_ascii=False,indent=1)" $R/tools/blender348/v3/leute.json
lauf held
pruefe '[ "$KAUF_FIGUR" = bauen ] && [ "$KAUF_KAMPF" = treffer ]' "1114: held3.py und leute.json: figur baut, kampf trifft"
for f in v3/tex.py v3_kampf/held3.py; do
  vor=$($KC kennung kampf | cut -d' ' -f2); echo "# 1114 Probe" >> $R/tools/blender348/$f
  pruefe '[ "$($KC kennung kampf | cut -d" " -f2)" != "$vor" ]' "1114: $f gehört zu kampf"
done
cp $R/.github/workflows/godot.yml $T/godot.yml
sed -i 's|bau goblin.py ART=$a V3=tools/blender348/v3_kampf|bau goblin.py ART=$a|' $R/.github/workflows/godot.yml
pruefe '$KC eingaben kampf | grep -qx tools/blender348/v3/held3.py && $KC eingaben kampf | grep -qx tools/blender348/v3/rig.py' "1114: goblin.py ohne V3=…/v3_kampf liest v3/held3.py und v3/rig.py"
cp $T/godot.yml $R/.github/workflows/godot.yml
pruefe '! $KC eingaben kampf | grep -q "v3/\(held3\|rig\|geruest\|leute\)"' "1114: mit V3=…/v3_kampf nicht"

# 1115: Block leute. waffen.py baut nur leute neu; ein Feld in leute.json, das kein Skript liest, baut nichts neu; eine Person
# mehr auf einer Karte (karten.json) baut leute neu, eine andere Änderung an karten.json nur dorf; leute.json liegt immer neben den Leuten
lauf leute0
pruefe '[ "$KAUF_LEUTE" = treffer ] && [ "$(cat $R/godot/daten/leute/garrick.bin)" = "leute held" ] && cmp -s $R/godot/daten/leute/leute.json $R/tools/blender348/v3/leute.json' "1115: leute geholt, leute.json daneben"
pruefe 'grep -qx daten/leute/garrick.bin $R/godot/daten/kauf.txt' "1115: kauf.txt mit der Zeile der Leute"
echo "# 1115 Probe" >> $R/tools/blender348/waffen.py
lauf leute1
pruefe '[ "$KAUF_LEUTE" = bauen ] && [ "$KAUF_FIGUR" = treffer ] && [ "$KAUF_DORF" = treffer ] && [ "$KAUF_KLASSEN" = treffer ]' "1115: waffen.py: leute baut, figur, dorf, klassen treffen (kampf $KAUF_KAMPF)"
python3 -c "import json,sys; d=json.load(open(sys.argv[1])); p=[k for k in d if not k.startswith('_')][0]; d[p]['nur_godot_1115']=3; json.dump(d,open(sys.argv[1],'w'),ensure_ascii=False,indent=1)" $R/tools/blender348/v3/leute.json
lauf leute2
pruefe '[ "$KAUF_LEUTE" = treffer ] && [ "$KAUF_FIGUR" = treffer ]' "1115: Feld nur für Godot in leute.json baut keine Leute neu"
pruefe 'grep -q nur_godot_1115 $R/godot/daten/leute/leute.json' "1115: neue leute.json trotzdem neben den Leuten"
p=$(python3 -c "import json,sys; print([k for k in json.load(open(sys.argv[1])) if not k.startswith('_')][0])" $R/tools/blender348/v3/leute.json)
python3 -c "import json,sys; k=json.loads(sys.argv[1]); k['karten']['village']['leute']=[{'id': sys.argv[2]}]; print(json.dumps(k))" "$KARTEN_LEER" "$p" > $R/godot/daten/karten.json
pruefe '[ "$($KC pruefen 2>/dev/null | grep -c "^KAUF_LEUTE=bauen")" = 1 ] && python3 -c "import sys; sys.path.insert(0, sys.argv[1]); import kauf_cache as k; sys.exit(0 if k.leute_ids() == [sys.argv[2]] else 1)" $R/tools/godot "$p"' "1115: eine Person mehr auf der Karte baut leute neu (Ids aus der Zeile des Schritts)"
lauf leute3
python3 -c "import json,sys; k=json.loads(sys.argv[1]); k['karten']['village']['leute']=[{'id': sys.argv[2]}]; k['karten']['village']['name']='anders'; print(json.dumps(k))" "$KARTEN_LEER" "$p" > $R/godot/daten/karten.json
pruefe '[ "$($KC pruefen 2>/dev/null | grep -E "^KAUF_(LEUTE|DORF)=" | tr "\n" " ")" = "KAUF_DORF=bauen KAUF_LEUTE=treffer " ]' "1115: andere Änderung an karten.json baut nur dorf"
lauf leute4

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


# 1112: geduldeter Fehler in kampf
echo "# 1112 Probe" >> $R/tools/blender348/kauftier.py
kk=$($KC kennung kampf | cut -d' ' -f2)
HALB=kampf lauf elf
pruefe '[ "$KAUF_KAMPF" = bauen ] && [ $ABLEGEN = 0 ] && grep -q "::warning::KAUF-CACHE kampf halb, nicht abgelegt (Probe 1112)" $RUNNER_TEMP/ablegen.log' "1112: halber Block nicht abgelegt, Warnung"
pruefe '! git --git-dir=$T/kauf.git rev-parse -q --verify refs/heads/bau/kampf-$kk > /dev/null' "1112: kein Zweig bau/kampf-$kk"
lauf zwoelf
pruefe '[ "$KAUF_KAMPF" = bauen ] && git --git-dir=$T/kauf.git rev-parse -q --verify refs/heads/bau/kampf-$kk > /dev/null' "1112: nächster Lauf baut kampf neu und legt ab"
(export RUNNER_TEMP=$T/rt-halb; $KC halb kampf alt > /dev/null; $KC merke vor_kampf; [ ! -e $RUNNER_TEMP/kauf_halb_kampf ]) && h=0 || h=1
pruefe '[ $h = 0 ]' "1112: erste Marke des Blocks löscht alte Marke halb"

# 1113: aufräumen
for i in 1 2 3; do echo "# 1113 Probe $i" >> $R/tools/blender348/v3/rig.py; lauf drei$i; done
vorher=$(git --git-dir=$T/kauf.git for-each-ref refs/heads/bau | wc -l)
teil=$(git --git-dir=$T/kauf.git for-each-ref refs/heads/bau/teil | wc -l)
(cd $R && $KC aufraeumen > $T/auf1.log)
pruefe '[ $(git --git-dir=$T/kauf.git for-each-ref refs/heads/bau/teil | wc -l) = $teil ] && [ $teil -ge 1 ]' "1113: junge Zwischenzweige bleiben ($teil)"
ok=1; for b in figur dorf klassen leute kampf; do
  n=$(git --git-dir=$T/kauf.git for-each-ref "refs/heads/bau/$b-*" | wc -l); [ $n -le 3 ] || ok=0
  git --git-dir=$T/kauf.git rev-parse -q --verify refs/heads/bau/$b-$($KC kennung $b | cut -d' ' -f2) > /dev/null || ok=0
done
pruefe '[ $ok = 1 ]' "1113: je Block höchstens 3, der eigene bleibt ($vorher Zweige vorher, $(git --git-dir=$T/kauf.git for-each-ref refs/heads/bau | wc -l) nachher; $(grep aufgeräumt $T/auf1.log | cut -c1-80))"
(cd $R && KAUF_CACHE_TEIL_STUNDEN=-1 $KC aufraeumen > $T/auf2.log)
pruefe '[ $(git --git-dir=$T/kauf.git for-each-ref refs/heads/bau/teil | wc -l) = 0 ]' "1113: alte Zwischenzweige weg"
lauf dreizehn
pruefe '[ "$KAUF_ALLES" = treffer ]' "1113: danach trifft alles"

# 1126: ein gleichzeitiger Lauf räumt den Treffer zwischen pruefen und holen weg; holen nimmt ihn aus dem Gesicherten
vorher=$(inhalt)
WEG=kampf lauf vierzehn
pruefe '[ "$KAUF_KAMPF" = treffer ] && [ $HOLEN = 0 ] && grep -q "geholt kampf" $RUNNER_TEMP/holen.log && [ "$(inhalt)" = "$vorher" ]' "1126: Treffer gelöscht nach pruefen, trotzdem geholt (Ende $HOLEN, $(grep -c gesichert $RUNNER_TEMP/pruefen.log) gesichert)"
lauf fuenfzehn
pruefe '[ "$KAUF_KAMPF" = bauen ] && [ "$KAUF_DORF" = treffer ]' "1126: danach baut kampf neu"

echo "KAUFCACHE854 $([ $fehler = 0 ] && echo gut || echo "$fehler Fehler")"
exit $fehler
