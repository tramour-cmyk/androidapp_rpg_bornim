# 385.1 am Rechner (nach rechner.sh, add_repo bornim-kaufmodelle): Grundbewegungen des Protofactor-Zauberer-Sets auf den Kaufkoerper
# (zauber385.py, gemeinsame Ruhelage aus dem Stehen), Stab (stab385.py), Figuren und Dorf wie figuren_lauf.sh, Zauberfeuer aus Jerrys
# kampf/ (zauber.gd, tafel.gd), Film figurenprobe.gd --teil=zauber2 und figuren_film.py.
# Aufruf: bash zauber_lauf.sh [ablage]  -> <ablage>/aus/385-zauberer-grund.mp4
set -e
A=${1:-/home/user/q376}
K=$A/kauf; S=$A/aus; O=$A/out; G=$A/godot; Z=$A/zauber
R=/home/user/t385; B=~/bl/bin/python
mkdir -p $K/src $S $O $Z/glb
# Universal Base Characters Source, Modular Character Outfits Source, UAL Pro, Zauberer-Set
for id in 681384045 681373666 678371987; do
  [ -f $K/$id.ok ] || { gh api -H "Accept: application/octet-stream" repos/tramour-cmyk/bornim-kaufmodelle/releases/assets/$id > $K/$id.zip \
    && unzip -q -o $K/$id.zip -d $K/src/$id && : > $K/$id.zip && touch $K/$id.ok; }
done
if [ ! -f $Z/wiz.ok ]; then
  gh api -H "Accept: application/octet-stream" repos/tramour-cmyk/bornim-kaufmodelle/releases/assets/682733782 > $Z/wiz.unitypackage
  python3 -I - $Z/wiz.unitypackage $Z/wiz << 'PY'
import os, sys, tarfile
z, d = sys.argv[1:3]; pfad, inhalt = {}, {}
with tarfile.open(z, 'r:*') as t:
    for m in t:
        teil = m.name.lstrip('./').split('/')
        if len(teil) != 2 or not m.isfile(): continue
        if teil[1] == 'pathname': pfad[teil[0]] = t.extractfile(m).read().decode('utf-8', 'replace').splitlines()[0].strip()
        elif teil[1] == 'asset': inhalt[teil[0]] = t.extractfile(m).read()
for g, b in inhalt.items():
    p = os.path.normpath(pfad.get(g, g))
    if p.startswith(('..', '/')): continue
    os.makedirs(os.path.dirname(os.path.join(d, p)) or d, exist_ok=True); open(os.path.join(d, p), 'wb').write(b)
PY
  : > $Z/wiz.unitypackage && touch $Z/wiz.ok
fi
UAL=$(find $K/src/678371987 -path "*Unreal-Godot/UAL1.glb" | head -1)
RU=$(find $Z/wiz -name "Humanoid@IdleWizard.fbx" | head -1)
NAMEN="IdleWizard IdleLookAroundWizard WalkForwardWizard CrouchIdleWizard DodgeLeftWizard GetHitFrontHeavyWizard DeathBackWizard GetBackUpBackWizard CastSpell4Wizard CastSpell6Wizard"
for n in $NAMEN; do
  [ -f $Z/glb/Zauber_$n.glb ] || { Q=$(find $Z/wiz -name "Humanoid@$n.fbx" | head -1)
    RUHE="$RU" QUELLE="$Q" ZIEL=$UAL NAME=Zauber_$n OUT=$Z/glb/Zauber_$n.glb $B -I $R/tools/blender348/v3/zauber385.py 2>&1 | grep -E "ABWEICHUNG|ZAUBER385" & }
done
wait
[ -f $Z/stab.glb ] || QUELLE="$(find $Z/wiz -name SM_WizardStaffProp.fbx | head -1)" OUT=$Z/stab.glb $B -I $R/tools/blender348/v3/stab385.py | grep STAB385
[ -d $A/fig ] || Q=~/cc0 KAUF=$K/src OUT=$A/fig $B -I $R/tools/blender348/v3/quaternius.py | grep -E "FIGUR|FEHLT|OK"
cd $R
[ -f $O/karten.json ] || ./gradlew -p core exportMaps -Pout=$O/karten.json -q
export KARTEN=$O/karten.json
for s in tex held3 rig dorf; do [ -f $O/.$s ] || { OUT=$O $B -I tools/blender348/v3/$s.py > $O/$s.log 2>&1 && touch $O/.$s; } || { tail -30 $O/$s.log; exit 1; }; done
rm -rf $G && mkdir -p $G && cp -r $R/godot/. $G/ && D=$G/daten && mkdir -p $D/waffen $G/kampf
for f in zauber.gd tafel.gd tafel.gdshader; do git show origin/claude/jerry-348-kampf:godot/kampf/$f > $G/kampf/$f; done
cp $O/karten.json $D/; cp $O/held.glb $D/held.bin; cp $O/held-info.json $D/
cp $O/dorf.glb $D/dorf.bin; cp $O/dorf-info.json $D/
for t in gras erde pflaster halme korn weiss; do cp $O/tex/$t.png $D/$t.bild; done
cp $O/boden-maske.png $D/boden-maske.bild
cp $Z/stab.glb $D/waffen/stab.bin
(cd $G && ~/godot/godot --headless --import --path . > $O/import.log 2>&1 || true)
cd $G
U2=$(ls $Z/glb/*.glb | tr '\n' ',' | sed 's/,$//')
rm -rf $A/bild_zauber2
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json timeout 2400 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . \
  --rendering-driver vulkan --rendering-method mobile --resolution 1080x2340 -- --figuren=$A/bild_zauber2 --quelle=$A/fig --ual=$UAL --ual2=$U2 \
  --teil=zauber2 > $A/godot_zauber2.log 2>&1 || echo "godot $?"
grep -h "SCRIPT ERROR\|ERROR" $A/godot_zauber2.log | head -5 || true
grep -E "ZAUBER|STAB|^[0-9]{2} " $A/bild_zauber2/probe.txt || true
DURCHLAEUFE=1 LUPE=2 python3 -I $R/tools/pruef348/figuren_film.py $A/bild_zauber2/film $S/385-zauberer-grund.mp4
