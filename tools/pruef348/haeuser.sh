# 348.6 Haeuser mit Innenraum: Dorf ohne und mit KITHAUS (Bausatz medieval-village-megakit in ~/cc0, cc0_laden.sh), Bilder --haeuser
# Aufruf: haeuser.sh <S> [alt]   (vorher rechner.sh; ≈15 Min., „alt“ knipst auch KITHAUS=0)
set -e
S=$1; R=/home/user/androidapp_rpg_bornim; B=~/bl/bin/python
cd $R
[ -d ~/cc0/medieval-village-megakit ] || PAKETE=medieval-village-megakit bash tools/blender348/v3/cc0_laden.sh ~/cc0
[ -f $S/karten.json ] || ./gradlew -p core exportMaps -Pout=$S/karten.json -q
export KARTEN=$S/karten.json
mkdir -p $S/out
for s in tex held3 rig; do [ -f $S/out/.$s ] || { OUT=$S/out $B -I tools/blender348/v3/$s.py > $S/$s.log 2>&1 && touch $S/out/.$s; }; done
echo GEMEINSAM OK
# Haeuser mit Raum aus karten.json: Name, Kacheln, Tuer
H=$(python3 - $S/karten.json <<'PY'
import json, sys
K = json.load(open(sys.argv[1]))['karten']; v = K['village']
raum = {(a['x'], a['y']): a['ziel']['karte'] for a in v['ausgaenge'] if K.get(a['ziel']['karte'], {}).get('art') == 'INTERIOR'}
out = []
for f in v['fassaden']:
    for (x, y), n in raum.items():
        if y == f['y'] and f['x'] <= x < f['x'] + f['n']: out.append('%s,%d,%d,%d,%d,%d' % (n, f['x'], f['y'] - f['d'] + 1, f['x'] + f['n'] - 1, f['y'], x))
print(';'.join(out))
PY
)
echo "HAEUSER $H"
V="neu"; [ "$2" = alt ] && V="alt neu"
for v in $V; do
  mkdir -p $S/out_$v; ln -sfn $S/out/tex $S/out_$v/tex
  K=1; [ $v = alt ] && K=0
  OUT=$S/out_$v KITHAUS=$K $B -I tools/blender348/v3/dorf.py > $S/dorf_$v.log 2>&1
done
echo DORF OK
for v in $V; do
  G=$S/godot_$v; rm -rf $G; cp -r $R/godot $G; D=$G/daten; mkdir -p $D
  cp $S/karten.json $D/
  cp $S/out/held.glb $D/held.bin && cp $S/out/held-info.json $D/
  cp $S/out_$v/dorf.glb $D/dorf.bin && cp $S/out_$v/dorf-info.json $D/
  for t in gras erde pflaster halme korn weiss; do cp $S/out/tex/$t.png $D/$t.bild; done
  cp $S/out_$v/boden-maske.png $D/boden-maske.bild
  (cd $G && ~/godot/godot --headless --import --path . > $S/import_$v.log 2>&1 || true)
  (cd $G && timeout 900 xvfb-run -a -s "-screen 0 1080x2340x24" ~/godot/godot --path . --resolution 1080x2340 -- --haeuser=$S/bild_$v:$H > $S/godot_$v.log 2>&1 || true)
done
ls $S/bild_*
echo BILDER OK
