# 399.5 Grundrisse am Rechner (nach rechner.sh): Moebelbausatz laden, Held, Dorf, die vier Grundrisse (raum.py), Daten fuer Godot wie
# godot.yml (ohne Leute und Kaufmodelle), Standbilder --raeume (Tag, Nacht, gedreht), Blatt alt/neu je Raum (raeume_blatt.py).
# Alte Bilder vorher: tools/t bild KARTENZOOM=1 "HELDORT=inn:4:6:u;inn:4:6:u:23;shop:4:4:u;…" nach <ablage>/alt.
# Aufruf: PROBE=399.5 [NACHTSTUFEN=0.3,0.45] bash raeume_lauf.sh [ablage]   -> <ablage>/aus/3995-raeume-*.jpg (Stufen: Umgebung
# nachts zusaetzlich, Bilder <raum>_nacht_<stufe>.png)
set -e
A=${1:-/home/user/r3995}
O=$A/out; G=$A/godot; S=$A/aus
R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
mkdir -p $O $S
for p in medieval-village-megakit stylized-nature-megakit fantasy-props-megakit; do [ -d ~/cc0/$p ] || PAKETE=$p bash $R/tools/blender348/v3/cc0_laden.sh ~/cc0; done
cd $R
[ -f $O/karten.json ] || ./gradlew -p core exportMaps -Pout=$O/karten.json -q
export KARTEN=$O/karten.json
for s in tex held3 rig dorf; do [ -f $O/.$s ] || { OUT=$O $B -I tools/blender348/v3/$s.py > $O/$s.log 2>&1 && touch $O/.$s; } || { tail -30 $O/$s.log; exit 1; }; done
for g in inn shop elder temple; do OUT=$O KARTE=$g $B -I tools/blender348/v3/raum.py > $O/raum-$g.log 2>&1 || { tail -30 $O/raum-$g.log; exit 1; }; grep -h "^NETZE\|^GLB" $O/raum-$g.log; done
rm -rf $G && mkdir -p $G && cp -r $R/godot/. $G/ && D=$G/daten && mkdir -p $D
cp $O/karten.json $D/; cp $O/held.glb $D/held.bin; cp $O/held-info.json $D/
cp $O/dorf.glb $D/dorf.bin; cp $O/dorf-info.json $D/
for g in inn shop elder temple; do cp $O/$g.glb $D/$g.bin; cp $O/$g-info.json $D/; done
for t in gras erde pflaster halme korn weiss; do cp $O/tex/$t.png $D/$t.bild; done
cp $O/boden-maske.png $D/boden-maske.bild
./gradlew -p core exportTexts -Pout=$D/texte.json -q
./gradlew -p core exportHero -Pout=$D/held.json -q
(cd $G && ~/godot/godot --headless --import --path . > $A/import.log 2>&1 || true)
rm -rf $A/bild && mkdir -p $A/bild
(cd $G && VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json timeout 1500 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . \
  --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 -- --raeume=$A/bild ${NACHTSTUFEN:+--nachtstufen=$NACHTSTUFEN} ${KERZENPROBE:+--kerzenprobe} > $A/godot.log 2>&1 || true)
grep -E "SCRIPT ERROR|SHADER ERROR|^BILD|^ZEICHNEN" $A/godot.log | cut -c1-200 | head -40
[ -n "$KERZENPROBE" ] && python3 -I $R/tools/pruef348/kerzen_mass.py $A/bild $A/godot.log
python3 -I $R/tools/pruef348/raeume_blatt.py $A/alt $A/bild $S/3995-raeume
ls -l $S
