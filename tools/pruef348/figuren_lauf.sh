# 376.1 am Rechner (nach rechner.sh): Kaufpakete laden, Figuren (quaternius.py), Daten fuer Godot wie godot.yml (ohne Leute),
# Standbilder und Film zugleich (figurenprobe.gd), Blaetter (figuren_blaetter.py) und Film (figuren_film.py).
# Vorher add_repo bornim-kaufmodelle (Zugang fuer gh api). Aufruf: bash figuren_lauf.sh [ablage]  -> <ablage>/aus/3761-figuren-kauf-*
set -e
A=${1:-/home/user/q376}
K=$A/kauf; S=$A/aus; O=$A/out; G=$A/godot
R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
mkdir -p $K/src $S $O
# Universal Base Characters Source, Modular Character Outfits Source, UAL Pro
for id in 681384045 681373666 678371987; do
  [ -f $K/$id.ok ] || { gh api -H "Accept: application/octet-stream" repos/tramour-cmyk/bornim-kaufmodelle/releases/assets/$id > $K/$id.zip \
    && unzip -q -o $K/$id.zip -d $K/src/$id && : > $K/$id.zip && touch $K/$id.ok; }
done
UAL=$(find $K/src/678371987 -path "*Unreal-Godot/UAL1.glb" | head -1)
Q=~/cc0 KAUF=$K/src OUT=$A/fig $B -I $R/tools/blender348/v3/quaternius.py | grep -E "FIGUR|FEHLT|OK"
cd $R
[ -f $O/karten.json ] || ./gradlew -p core exportMaps -Pout=$O/karten.json -q
export KARTEN=$O/karten.json
for s in tex held3 rig dorf; do [ -f $O/.$s ] || { OUT=$O $B -I tools/blender348/v3/$s.py > $O/$s.log 2>&1 && touch $O/.$s; } || { tail -30 $O/$s.log; exit 1; }; done
git show origin/claude/jerry-348-kampf:tools/blender348/waffen.py > $O/waffen.py
for w in longsword shield; do [ -f $O/waffen/$w.glb ] || OUT=$O/waffen WAFFE=$w $B -I $O/waffen.py > $O/waffe-$w.log 2>&1; done
mkdir -p $G && cp -r $R/godot/. $G/ && D=$G/daten && mkdir -p $D/waffen
cp $O/karten.json $D/; cp $O/held.glb $D/held.bin; cp $O/held-info.json $D/
cp $O/dorf.glb $D/dorf.bin; cp $O/dorf-info.json $D/
for t in gras erde pflaster halme korn weiss; do cp $O/tex/$t.png $D/$t.bild; done
cp $O/boden-maske.png $D/boden-maske.bild
for w in longsword shield; do cp $O/waffen/$w.glb $D/waffen/$w.bin; done
(cd $G && ~/godot/godot --headless --import --path . > $O/import.log 2>&1 || true)
cd $G
for t in reihe film; do mkdir -p $A/bild_$t
  (VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json timeout 2400 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . \
    --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 -- --figuren=$A/bild_$t --quelle=$A/fig --ual=$UAL --teil=$t \
    > $A/godot_$t.log 2>&1; echo "$t fertig $?") &
done
wait
grep -h "SCRIPT ERROR" $A/godot_*.log | head -3 || true
python3 -I $R/tools/pruef348/figuren_blaetter.py $A/bild_reihe $S/3761-figuren-kauf
python3 -I $R/tools/pruef348/figuren_film.py $A/bild_film/film $S/3761-figuren-kauf-film.mp4
