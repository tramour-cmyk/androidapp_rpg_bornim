#!/bin/bash
# 348.12 Kobold auf dem CC0-Gerüst: Kampfort GEGNER=KOBOLDS eigen gegen CC0, Standbilder je Haltung, Blatt, Film nebeneinander
# (wie Workflow-Schritt „348.12:“ für den Goblin). Aufruf: PROBE=348.12 bash tools/blender348/kobold-cc0-probe.sh <eigen-out> <cc0-out> <basis-out> <ziel>
set -u
R=/home/user/androidapp_rpg_bornim; E=$1; C=$2; B=$3; P=$4; mkdir -p $P
D=$R/godot/kampf/daten; mkdir -p $D
cp $B/held.glb $D/held.bin
cp $B/kampfort-wald.glb $D/kampfort-wald.bin; cp $B/wald-maske.png $D/wald-maske.bild
for w in dagger shortsword longsword quarterstaff shield round_shield scimitar handaxe scimitar-rost handaxe-rost dagger-rost dagger-kobold round_shield-grob shortbow staff-schamane spear-rost; do cp $B/$w.glb $D/$w.bin; done
for t in gras erde halme; do cp $B/tex/$t.png $D/$t.bild; done
export GEGNER=KOBOLDS OHNEUI=1 SCHAU_LISTE=Stehen,Gehen,Hieb
G=~/godot/godot
bild() { (cd $R/godot && timeout 180 xvfb-run -a -s "-screen 0 1080x2340x24" $G --rendering-driver opengl3 --path . --resolution 1080x2340 -- --bild=$P/$1.png > $P/$1.log 2>&1) || true; }
film() { (cd $R/godot && SCHAU=1 SCHAU_TITEL="$2" timeout 300 xvfb-run -a -s "-screen 0 540x1170x24" $G --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie /tmp/$1.avi --fixed-fps 30 -- --bild=/tmp/x.png > $P/$1-film.log 2>&1) || true
  ffmpeg -loglevel error -y -i /tmp/$1.avi -vf scale=360:-2 -c:v libx264 -pix_fmt yuv420p -crf 30 -preset veryfast $P/$1.mp4 || true; rm -f /tmp/$1.avi; }
halt() { for h in Stehen= Gehen=Gehen:0.25 ${2:-}; do for g in 1 2 3; do NUR=gob$g HALTUNG=${h#*=} bild st-$1-${h%%=*}-$g; done; done; }
(cd $R/godot && timeout 300 $G --headless --path . --import > $P/import.log 2>&1) || true
for m in eigen cc0; do
  S=$E; [ $m = cc0 ] && S=$C
  for k in kappe schild fell; do cp $S/kobold-$k.glb $D/kobold-$k.bin; done
  cp $S/kobold-info.json $D/
  (cd $R/godot && timeout 300 $G --headless --path . --import >> $P/import.log 2>&1) || true
  bild kobold-$m
  if [ $m = cc0 ]; then halt $m "Aus=Hieb:0.22 Auf=Hieb:0.43"; else halt $m; fi
  film kob-$m $m
done
cp $C/kobold-info.json $P/
grep -E "Schirm|Waffe|Schild|SCRIPT ERROR|^ +at: " $P/kobold-cc0.log | head -20 || true
NAMEN="kappe;schild;fell" python3 $R/tools/blender348/hiebblatt.py $P/348.12-kobold-blatt.png $P "Stehen (Lauer)=Stehen" "Gehen 0,25 s=Gehen" "Hieb ausgeholt 0,22 s=Aus!" "Hieb Aufschlag 0,43 s=Auf!" || true
L=$(for v in kob-eigen kob-cc0; do ffmpeg -i $P/$v.mp4 2>&1 | grep -oE 'Duration: [0-9:.]+' | awk -F'[: ]' '{print $3*3600+$4*60+$5}'; done | sort -g | tail -1 | awk '{print $1 - 1}')
ffmpeg -loglevel error -y -ss 1 -i $P/kob-eigen.mp4 -ss 1 -i $P/kob-cc0.mp4 -filter_complex "[0]tpad=stop_mode=clone:stop_duration=30[a];[1]tpad=stop_mode=clone:stop_duration=30[b];[a][b]hstack=inputs=2,trim=duration=$L" -c:v libx264 -pix_fmt yuv420p -crf 30 -preset veryfast $P/348.12-kobold-film.mp4 || true
ls -l $P | grep -v " st-"
