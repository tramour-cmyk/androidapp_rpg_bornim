# 490, 491, 492 Daten fuer den Flüsterwald und die Blutzahnhoehle (hoehle.py KARTE=cave, Lyra) am Rechner (nach tools/pruef348/rechner.sh), ohne Bild: Held, Dorf, Wald und Tiefer Wald (dorf.py
# KARTE=forest, deep_forest), Garrick, Morwen, Grimmzahn, Monster der Karte (Wolf, Ratte, Goblins, Kobold wie godot.yml „Kampfort bauen“, ohne Kaufmodelle), Godot-Kopie mit daten/
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
for g in forest deep_forest; do [ -f $O/.$g ] || { OUT=$O KARTE=$g $B -I tools/blender348/v3/dorf.py > $O/$g.log 2>&1 && touch $O/.$g; } || { tail -30 $O/$g.log; exit 1; }; done
[ -f $O/.cave ] || { OUT=$O KARTE=cave $B -I tools/blender348/v3/hoehle.py > $O/cave.log 2>&1 && touch $O/.cave; } || { tail -30 $O/cave.log; exit 1; }
for i in garrick morwen lyra; do L=$O/leute/$i; [ -f $L/.fertig ] || { mkdir -p $L; for s in held3 rig; do OUT=$L FIGUR=$i $B -I tools/blender348/v3/$s.py > $L/$s.log 2>&1 || { tail -30 $L/$s.log; exit 1; }; done; touch $L/.fertig; }; done
bau() { n=$1; shift; m="$O/.k-$n-$(echo "$*" | tr -c "A-Za-z0-9_=\n" -)"; [ -f "$m" ] && return 0; env OUT=$O "$@" $B -I tools/blender348/$n > $O/k-$n.log 2>&1 && touch "$m" || { tail -30 $O/k-$n.log; exit 1; }; }
bau wolf.py; bau wolf.py ART=dire_wolf; bau waffen.py; bau ratte.py
for a in goblin goblin_archer kobold; do bau goblin.py ART=$a V3=tools/blender348/v3_kampf; done
rm -rf $G && mkdir -p $G && cp -r $R/godot/. $G/ && D=$G/daten && mkdir -p $D/leute
cp $O/karten.json $D/; cp $O/held.glb $D/held.bin; cp $O/held-info.json $D/
cp $O/dorf.glb $D/dorf.bin; cp $O/dorf-info.json $D/
for g in forest deep_forest; do cp $O/$g.glb $D/$g.bin; cp $O/$g-info.json $D/; cp $O/$g-boden-maske.png $D/$g-boden-maske.bild; cp $O/$g-boden-rand.png $D/$g-boden-rand.bild; done
for t in gras erde pflaster halme korn weiss; do cp $O/tex/$t.png $D/$t.bild; done
cp $O/boden-maske.png $D/boden-maske.bild; cp $O/boden-rand.png $D/boden-rand.bild
cp $O/cave.glb $D/cave.bin; cp $O/cave-info.json $D/; cp $O/cave-boden-maske.png $D/cave-boden-maske.bild
for i in garrick morwen lyra; do cp $O/leute/$i/held.glb $D/leute/$i.bin; cp $O/leute/$i/held-info.json $D/leute/$i-info.json; done; cp tools/blender348/v3/leute.json $D/leute/
K=$G/kampf/daten; mkdir -p $K
cp $O/held.glb $K/held.bin
for f in grau dunkel rost asche; do cp $O/wolf-$f.glb $K/wolf-$f.bin; done; cp $O/wolf-info.json $K/
for f in schwarz schimmer; do cp $O/dire_wolf-$f.glb $K/dire_wolf-$f.bin; done; cp $O/dire_wolf-info.json $K/
for f in braun grau schwarz; do cp $O/giant_rat-$f.glb $K/giant_rat-$f.bin; done; cp $O/giant_rat-info.json $K/
for w in dagger shortsword longsword quarterstaff shield round_shield scimitar handaxe scimitar-rost handaxe-rost dagger-rost dagger-kobold round_shield-grob shortbow staff-schamane spear-rost; do [ -f $O/$w.glb ] && cp $O/$w.glb $K/$w.bin; done
for k in leder kappe helm; do cp $O/goblin-$k.glb $K/goblin-$k.bin; done; cp $O/goblin-info.json $K/
for k in kapuze kappe fell; do cp $O/goblin_archer-$k.glb $K/goblin_archer-$k.bin; done; cp $O/goblin_archer-info.json $K/
for k in kappe schild fell; do cp $O/kobold-$k.glb $K/kobold-$k.bin; done; cp $O/kobold-info.json $K/
for t in gras erde halme; do cp $O/tex/$t.png $K/$t.bild; done
./gradlew -p core exportTexts -Pout=$D/texte.json -q
./gradlew -p core exportHero -Pout=$D/held.json -q
# 505 (Rechner 04.11.: kartennebel_505 hing ohne Kartenblaetter, am Bauserver liegen sie da): Kartenblaetter wie godot.yml
./gradlew -p core exportMapSheets -Pout=$D -q
(cd $G && ~/godot/godot --headless --import --path . > $A/import.log 2>&1 || true)
