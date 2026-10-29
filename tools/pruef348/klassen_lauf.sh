# 376.1 Held je Klasse am Rechner (nach rechner.sh, Kaufpakete wie figuren_lauf.sh): Modelle wie godot.yml (held_klassen.py, Waffen der
# Grundausruestung), Standbilder figurenprobe.gd --teil=klassen, Blaetter klassen_blatt.py.
# Aufruf: bash klassen_lauf.sh [ablage]  -> <ablage>/aus/3761-klassen.jpg, 3761-aussehen.jpg, 3761-erschaffung.jpg, haut.txt
set -e
A=${1:-/home/user/q376}
K=$A/kauf/src; O=$A/out; G=$A/godot; Z=$A/klassen; S=$A/aus
R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
mkdir -p $S
for p in medieval-village-megakit stylized-nature-megakit fantasy-props-megakit; do [ -d ~/cc0/$p ] || PAKETE=$p bash $R/tools/blender348/v3/cc0_laden.sh ~/cc0; done
cd $R
[ -f $O/karten.json ] || ./gradlew -p core exportMaps -Pout=$O/karten.json -q
export KARTEN=$O/karten.json
for s in tex held3 rig dorf; do [ -f $O/.$s ] || { OUT=$O $B -I tools/blender348/v3/$s.py > $O/$s.log 2>&1 && touch $O/.$s; } || { tail -30 $O/$s.log; exit 1; }; done
OUT=$O ZIEL=$Z Q=~/cc0 KAUF=$K $B -I tools/blender348/v3/held_klassen.py > $A/klassen.log 2>&1 || { tail -40 $A/klassen.log; exit 1; }
grep -E "^KLASSE|HELD KLASSEN|FEHLT" $A/klassen.log
[ -f $O/waffen.py ] || { git fetch -q origin claude/jerry-348-kampf && git show FETCH_HEAD:tools/blender348/waffen.py > $O/waffen.py; }
for w in longsword shield shortsword quarterstaff round_shield handaxe scimitar dagger shortbow spear-rost greataxe-grak; do [ -f $O/waffen/$w.glb ] || OUT=$O/waffen WAFFE=$w $B -I $O/waffen.py > $O/waffe-$w.log 2>&1 || echo "keine Waffe $w"; done
[ -f $O/held.json ] || { ./gradlew -p core exportTexts -Pout=$O/texte.json -q && ./gradlew -p core exportHero -Pout=$O/held.json -q \
  && ./gradlew -p core exportThingArt -Pout=$O/dinge -q; }
rm -rf $G && mkdir -p $G && cp -r $R/godot/. $G/ && D=$G/daten && mkdir -p $D/waffen
cp $O/texte.json $O/held.json $D/; cp -r $O/dinge/. $D/; cp $R/app/src/main/res/font/fondamento_regular.ttf $D/fondamento.ttf
cp $O/karten.json $D/; cp $O/held.glb $D/held.bin; cp $O/held-info.json $D/; cp $O/dorf.glb $D/dorf.bin; cp $O/dorf-info.json $D/
for t in gras erde pflaster halme korn weiss; do cp $O/tex/$t.png $D/$t.bild; done
cp $O/boden-maske.png $D/boden-maske.bild
# Wegstecken (376.1): Speer und Grossaxt gibt es nur als Gegnermodell; fuer das Probeblatt unter dem Grundnamen
cp $O/waffen/spear-rost.glb $O/waffen/spear.glb; cp $O/waffen/greataxe-grak.glb $O/waffen/greataxe.glb
for w in $O/waffen/*.glb; do cp $w $D/waffen/$(basename $w .glb).bin; done
for f in $Z/held_*.glb; do cp $f $D/$(basename $f .glb).bin; done
cp $Z/haare.glb $D/haare.bin; cp $Z/bewegungen.glb $D/bewegungen.bin; cp $Z/held-klassen.json $D/
cd $G
~/godot/godot --headless --import --path . > $A/import.log 2>&1 || true
timeout 300 ~/godot/godot --headless --path . -s res://tests/held_klassen_376.gd 2>&1 | grep -E "HELDKLASSEN|FALSCH|SCRIPT ERROR" || true
rm -rf $A/bild_klassen; mkdir -p $A/bild_klassen
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json timeout 1200 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . \
  --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 -- --figuren=$A/bild_klassen --teil=klassen \
  > $A/godot_klassen.log 2>&1 || echo "godot $?"
grep -h "SCRIPT ERROR" $A/godot_klassen.log | head -3 || true
python3 -I $R/tools/pruef348/klassen_blatt.py $A/bild_klassen $S
