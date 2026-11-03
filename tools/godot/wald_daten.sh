# 490 Daten fuer den Flüsterwald am Rechner (nach tools/pruef348/rechner.sh), ohne Bild: Held, Dorf, Wald (dorf.py KARTE=forest),
# Garrick, Monster der Karte (Wolf, Ratte, Goblins, Kobold wie godot.yml „Kampfort bauen“, ohne Kaufmodelle), Godot-Kopie mit daten/
# wie godot.yml, importiert. Aufruf: bash tools/godot/wald_daten.sh [ablage]; danach Test ohne Bild (kein Probelauf, 390a):
# cd <ablage>/godot && ~/godot/godot --headless --path . -s res://tests/wald_490.gd; Bilder mit Kaufheld: godot.yml „Waldbilder (490)“
set -e
A=${1:-/home/user/r490}
O=$A/out; G=$A/godot
R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
mkdir -p $O
for p in medieval-village-megakit stylized-nature-megakit fantasy-props-megakit; do [ -d ~/cc0/$p ] || PAKETE=$p bash $R/tools/blender348/v3/cc0_laden.sh ~/cc0; done
cd $R
[ -f $O/karten.json ] || ./gradlew -p core exportMaps -Pout=$O/karten.json -q
export KARTEN=$O/karten.json
for s in tex held3 rig dorf; do [ -f $O/.$s ] || { OUT=$O $B -I tools/blender348/v3/$s.py > $O/$s.log 2>&1 && touch $O/.$s; } || { tail -30 $O/$s.log; exit 1; }; done
[ -f $O/.forest ] || { OUT=$O KARTE=forest $B -I tools/blender348/v3/dorf.py > $O/forest.log 2>&1 && touch $O/.forest; } || { tail -30 $O/forest.log; exit 1; }
grep -h "GLB OK\|NETZ" $O/forest.log | head -5
[ -f $O/leute/.garrick ] || { mkdir -p $O/leute; for s in held3 rig; do OUT=$O/leute FIGUR=garrick $B -I tools/blender348/v3/$s.py > $O/leute/$s.log 2>&1 || { tail -30 $O/leute/$s.log; exit 1; }; done; touch $O/leute/.garrick; }
bau() { n=$1; shift; m="$O/.k-$n-$(echo "$*" | tr -c "A-Za-z0-9_=\n" -)"; [ -f "$m" ] && return 0; env OUT=$O "$@" $B -I tools/blender348/$n > $O/k-$n.log 2>&1 && touch "$m" || { tail -30 $O/k-$n.log; exit 1; }; }
bau wolf.py; bau waffen.py; bau ratte.py
for a in goblin goblin_archer kobold; do bau goblin.py ART=$a V3=tools/blender348/v3_kampf; done
rm -rf $G && mkdir -p $G && cp -r $R/godot/. $G/ && D=$G/daten && mkdir -p $D/leute
cp $O/karten.json $D/; cp $O/held.glb $D/held.bin; cp $O/held-info.json $D/
cp $O/dorf.glb $D/dorf.bin; cp $O/dorf-info.json $D/
cp $O/forest.glb $D/forest.bin; cp $O/forest-info.json $D/; cp $O/forest-boden-maske.png $D/forest-boden-maske.bild
for t in gras erde pflaster halme korn weiss; do cp $O/tex/$t.png $D/$t.bild; done
cp $O/boden-maske.png $D/boden-maske.bild
cp $O/leute/held.glb $D/leute/garrick.bin; cp $O/leute/held-info.json $D/leute/garrick-info.json; cp tools/blender348/v3/leute.json $D/leute/
K=$G/kampf/daten; mkdir -p $K
cp $O/held.glb $K/held.bin
for f in grau dunkel rost asche; do cp $O/wolf-$f.glb $K/wolf-$f.bin; done; cp $O/wolf-info.json $K/
for f in braun grau schwarz; do cp $O/giant_rat-$f.glb $K/giant_rat-$f.bin; done; cp $O/giant_rat-info.json $K/
for w in dagger shortsword longsword quarterstaff shield round_shield scimitar handaxe scimitar-rost handaxe-rost dagger-rost dagger-kobold round_shield-grob shortbow staff-schamane spear-rost; do [ -f $O/$w.glb ] && cp $O/$w.glb $K/$w.bin; done
for k in leder kappe helm; do cp $O/goblin-$k.glb $K/goblin-$k.bin; done; cp $O/goblin-info.json $K/
for k in kapuze kappe fell; do cp $O/goblin_archer-$k.glb $K/goblin_archer-$k.bin; done; cp $O/goblin_archer-info.json $K/
for k in kappe schild fell; do cp $O/kobold-$k.glb $K/kobold-$k.bin; done; cp $O/kobold-info.json $K/
for t in gras erde halme; do cp $O/tex/$t.png $K/$t.bild; done
./gradlew -p core exportTexts -Pout=$D/texte.json -q
./gradlew -p core exportHero -Pout=$D/held.json -q
(cd $G && ~/godot/godot --headless --import --path . > $A/import.log 2>&1 || true)
