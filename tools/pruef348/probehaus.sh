# 376 Probehaus: Dorf ohne und mit PROBEHAUS=3,12 (Bausatz medieval-village-megakit in ~/cc0, cc0_laden.sh), Bilder --probe
# Aufruf: probehaus.sh <S>   (vorher rechner.sh; ≈15 Min.)
set -e
S=$1; R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
cd $R
[ -d ~/cc0/medieval-village-megakit ] || PAKETE=medieval-village-megakit bash tools/blender348/v3/cc0_laden.sh ~/cc0
[ -f $S/karten.json ] || ./gradlew -p core exportMaps -Pout=$S/karten.json -q
export KARTEN=$S/karten.json
mkdir -p $S/out
for s in tex held3 rig; do [ -f $S/out/.$s ] || { OUT=$S/out $B -I tools/blender348/v3/$s.py > $S/$s.log 2>&1 && touch $S/out/.$s; }; done
echo GEMEINSAM OK
mkdir -p $S/out_alt $S/out_neu; ln -sfn $S/out/tex $S/out_alt/tex; ln -sfn $S/out/tex $S/out_neu/tex
OUT=$S/out_alt PROBEHAUS= $B -I tools/blender348/v3/dorf.py > $S/dorf_alt.log 2>&1
OUT=$S/out_neu PROBEHAUS=3,12 $B -I tools/blender348/v3/dorf.py > $S/dorf_neu.log 2>&1
echo DORF OK
for v in alt neu; do
  G=$S/godot_$v; rm -rf $G; cp -r $R/godot $G; D=$G/daten; mkdir -p $D
  cp $S/karten.json $D/
  cp $S/out/held.glb $D/held.bin && cp $S/out/held-info.json $D/
  cp $S/out_$v/dorf.glb $D/dorf.bin && cp $S/out_$v/dorf-info.json $D/
  for t in gras erde pflaster halme korn weiss; do cp $S/out/tex/$t.png $D/$t.bild; done
  cp $S/out_$v/boden-maske.png $D/boden-maske.bild
  (cd $G && ~/godot/godot --headless --import --path . > $S/import_$v.log 2>&1 || true)
  (cd $G && timeout 600 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . --resolution 1080x2340 -- --probe=$S/bild_$v > $S/godot_$v.log 2>&1 || true)
done
ls $S/bild_alt $S/bild_neu
echo BILDER OK
