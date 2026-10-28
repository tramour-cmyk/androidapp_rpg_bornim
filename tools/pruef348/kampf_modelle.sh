# 348.13a am Rechner (nach rechner.sh vom Zweig claude/tom-376-1-figuren): Modelle fuer GEGNER=GOBLINS, dann Probe tusche_probe.sh
# Modelle wie godot-kampf.yml, nur Held, Goblins, Wald, Waffen
set -e
cd /home/user/k34813; B=~/bl/bin/python; export OUT=/home/user/kout; mkdir -p $OUT
$B -I tools/blender348/v3/tex.py > $OUT/tex.log 2>&1
$B -I tools/blender348/v3/held3.py > $OUT/held.log 2>&1
$B -I tools/blender348/v3/rig.py > $OUT/rig.log 2>&1
$B -I tools/blender348/kampfort_wald.py > $OUT/wald.log 2>&1
$B -I tools/blender348/waffen.py > $OUT/waffen.log 2>&1
for a in goblin goblin_archer goblin_shaman; do ART=$a $B -I tools/blender348/goblin.py > $OUT/$a.log 2>&1; done
D=godot/kampf/daten; mkdir -p $D
cp $OUT/held.glb $D/held.bin; cp $OUT/kampfort-wald.glb $D/kampfort-wald.bin; cp $OUT/wald-maske.png $D/wald-maske.bild
for w in dagger shortsword longsword quarterstaff shield round_shield scimitar handaxe scimitar-rost handaxe-rost dagger-rost dagger-kobold round_shield-grob shortbow staff-schamane spear-rost; do cp $OUT/$w.glb $D/$w.bin 2>/dev/null || echo "fehlt $w"; done
for k in leder kappe helm; do cp $OUT/goblin-$k.glb $D/goblin-$k.bin; done; cp $OUT/goblin-info.json $D/
for k in kapuze kappe fell; do cp $OUT/goblin_archer-$k.glb $D/goblin_archer-$k.bin; done; cp $OUT/goblin_archer-info.json $D/
for k in robe fell beides; do cp $OUT/goblin_shaman-$k.glb $D/goblin_shaman-$k.bin; done; cp $OUT/goblin_shaman-info.json $D/
for t in gras erde halme; do cp $OUT/tex/$t.png $D/$t.bild; done
cd godot && timeout 300 ~/godot/godot --headless --import --path . > $OUT/import.log 2>&1 || true
echo KAMPF OK
