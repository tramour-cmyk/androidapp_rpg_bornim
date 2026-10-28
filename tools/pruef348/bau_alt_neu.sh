# Aufruf: bau.sh  -> baut gemeinsame Teile, dann Dorf alt und neu, rendert markt-Bilder
set -e
S=/tmp/claude-0/-home-user-androidapp-rpg-bornim/186fd555-4c28-5ea3-ac12-1427c2c6e341/scratchpad
R=/home/user/androidapp_rpg_bornim
cd $R
[ -f $S/karten.json ] || ./gradlew -p core exportMaps -Pout=$S/karten.json -q
export KARTEN=$S/karten.json
B=~/bl/bin/python
mkdir -p $S/out
for s in tex held3 rig; do [ -f $S/out/.$s ] || { OUT=$S/out $B -I tools/blender348/v3/$s.py > $S/$s.log 2>&1 && touch $S/out/.$s; }; done
echo GEMEINSAM OK
mkdir -p $S/out_alt $S/out_neu; ln -sfn $S/out/tex $S/out_alt/tex; ln -sfn $S/out/tex $S/out_neu/tex
OUT=$S/out_alt $B -I $S/alt/blender348/v3/dorf.py > $S/dorf_alt.log 2>&1 &
OUT=$S/out_neu $B -I tools/blender348/v3/dorf.py > $S/dorf_neu.log 2>&1 &
wait
echo DORF OK
for v in alt neu; do
  G=$S/godot_$v; rm -rf $G; cp -r $R/godot $G; D=$G/daten; mkdir -p $D
  cp $S/karten.json $D/
  cp $S/out/held.glb $D/held.bin && cp $S/out/held-info.json $D/
  cp $S/out_$v/dorf.glb $D/dorf.bin && cp $S/out_$v/dorf-info.json $D/
  for t in gras erde pflaster halme korn weiss; do cp $S/out/tex/$t.png $D/$t.bild; done
  cp $S/out_$v/boden-maske.png $D/boden-maske.bild
  (cd $G && ~/godot/godot --headless --import --path . > $S/import_$v.log 2>&1 || true)
done
echo GODOT DATEN OK
