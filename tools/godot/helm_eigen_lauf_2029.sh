#!/bin/bash
# 2029 Bildherkunft: ein Beleglauf fuer 2029-helm-eigen. Rohbilder nacken (kopfteil_bild_2029.gd, ARTEN=nacken) zweimal in derselben
# Arbeitskopie: erst mit den Helmen des alten Stands <alt> (Bild casco.jpg; nur fuer diesen Lauf aus Git geholt, danach zurueck),
# dann mit dem Stand HEAD (eigenes Bild); je vorher godot --headless --import. Dann helm_eigen_bild_2029.sh.
# Aufruf im Hauptordner: PROBE=2029 bash tools/godot/helm_eigen_lauf_2029.sh <alt> <ziel> <Text Dreiecke und Bild>
set -e
ALT=$1; Z=$2; DV=$3
G=${GODOT:-$HOME/godot/godot}
T=$(mktemp -d)
F="godot/figuren/helm_templer.glb godot/figuren/helm_templer__Helm_Templer.jpg godot/figuren/helm_templer_b.glb godot/figuren/helm_templer_b__Helm_Templer_B.jpg"
roh() {   # Ausgabeordner
  (cd godot && $G --headless --import >/dev/null 2>&1)
  (cd godot && ARTEN=nacken AUS=$1 xvfb-run -a -s "-screen 0 540x1170x24" $G --path . --rendering-method mobile --resolution 540x1170 \
    -s res://tests/kopfteil_bild_2029.gd 2>&1 | tee $1.log | grep -a "^MARKE" > $1/marken.txt) || true
  grep -a "^BILD\|KOPFTEILBILD" $1.log
}
mkdir -p $T/alt $T/neu
for f in $F; do cp $f $T/$(basename $f).neu; git show $ALT:$f > $f; done
roh $T/alt
for f in $F; do cp $T/$(basename $f).neu $f; done
roh $T/neu
git diff --quiet HEAD -- $F || { echo "Helmdateien nicht wie HEAD"; exit 1; }
bash tools/godot/helm_eigen_bild_2029.sh $T/alt $T/neu $Z $(git rev-parse --short=9 HEAD) $ALT "$DV"
echo "ROH $T"
