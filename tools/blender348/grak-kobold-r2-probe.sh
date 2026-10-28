#!/bin/bash
# 348.12 Runde 2: Grak und die drei Kobolde auf dem CC0-Gerüst in einem Probelauf (389: höchstens zwei je Vorlage). Grak: Kampfort,
# Standbilder je Haltung (Stehen, Gehen, Hieb ausgeholt, Abwärtsschlag, Aufschlag), Blatt, Film. Kobolde: nur CC0, je Kobold allein je
# Haltung (hiebblatt.py NUR_CC0=1), Kampfort, Film.
# Aufruf: PROBE=348.12 bash tools/blender348/grak-kobold-r2-probe.sh <grak-out> <kobold-out> <basis-out> <ziel>
set -u
R=/home/user/androidapp_rpg_bornim; C=$1; K=$2; B=$3; P=$4; mkdir -p $P
D=$R/godot/kampf/daten; mkdir -p $D
cp $B/held.glb $D/held.bin
cp $B/kampfort-wald.glb $D/kampfort-wald.bin; cp $B/wald-maske.png $D/wald-maske.bild
for w in dagger shortsword longsword quarterstaff shield round_shield scimitar handaxe scimitar-rost handaxe-rost dagger-rost dagger-kobold round_shield-grob shortbow staff-schamane spear-rost greataxe-grak; do cp $B/$w.glb $D/$w.bin; done
for t in gras erde halme; do cp $B/tex/$t.png $D/$t.bild; done
cp $C/hobgoblin_captain-hauptmann.glb $D/hobgoblin_captain-hauptmann.bin; cp $C/hobgoblin_captain-info.json $D/; cp $C/hobgoblin_captain-info.json $P/
for k in kappe schild fell; do cp $K/kobold-$k.glb $D/kobold-$k.bin; done
cp $K/kobold-info.json $D/; cp $K/kobold-info.json $P/
G=~/godot/godot
bild() { (cd $R/godot && timeout 180 xvfb-run -a -s "-screen 0 1080x2340x24" $G --rendering-driver opengl3 --path . --resolution 1080x2340 -- --bild=$P/$1.png > $P/$1.log 2>&1) || true; }
film() { (cd $R/godot && SCHAU=1 SCHAU_TITEL="$2" timeout 300 xvfb-run -a -s "-screen 0 540x1170x24" $G --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie /tmp/$1.avi --fixed-fps 30 -- --bild=/tmp/x.png > $P/$1-film.log 2>&1) || true
  ffmpeg -loglevel error -y -i /tmp/$1.avi -vf scale=360:-2 -c:v libx264 -pix_fmt yuv420p -crf 30 -preset veryfast $P/$1.mp4 || true; rm -f /tmp/$1.avi; }
(cd $R/godot && timeout 300 $G --headless --path . --import > $P/import.log 2>&1) || true
export OHNEUI=1 SCHAU_LISTE=Stehen,Gehen,Hieb
# ---- Grak
export GEGNER=GRAK
bild grak-ort
for h in Stehen= Gehen=Gehen:0.25 Aus=Hieb:0.33 Ab=Hieb:0.50 Auf=Hieb:0.62; do NUR=grak HALTUNG=${h#*=} bild st-grak-${h%%=*}; done
NAH=grak NUR=grak bild nah-grak
# Runde 2b (Prüfer Probe 1: Film Hieb Bild 1 Axt kopfüber; in Blender kippt die Axt in keinem Bild): je Bild Griff und Achse der Axt
SCHAU_MESS=1 film grak grak
# ---- Kobolde
export GEGNER=KOBOLDS
bild kobold-ort
for h in Stehen= Gehen=Gehen:0.25 Aus=Hieb:0.22 Auf=Hieb:0.43; do for g in 1 2 3; do NUR=gob$g HALTUNG=${h#*=} bild st-cc0-${h%%=*}-$g; done; done
for g in 1 2 3; do NAH=gob$g NAHVORN=0 NAHM=0.9 NUR=gob$g bild nah-kob$g; done   # Runde 2b: Strich durch Kopf und Hals, Kappe (Prüfer Probe 1); 2d: von vorn (Probe 2 zeigte Ohr und Hinterkopf)
film kobold kobold
grep -E "Schirm|Zweihand|SCRIPT ERROR|^ +at: res" $P/grak-ort.log | head -20
for h in Stehen Aus Ab Auf; do grep -E "Zweihand" $P/st-grak-$h.log | head -1 | sed "s/^/$h: /"; done
grep -E "^Mess Hieb" $P/grak-film.log | grep -oE "^Mess Hieb +[0-9]+|Achse \([^)]*\)" | paste - - | head -40
grep -E "Schirm|SCRIPT ERROR|^ +at: " $P/kobold-ort.log | head -12
python3 - "$P" <<'EOF'
import sys, re
from PIL import Image, ImageDraw, ImageFont
P = sys.argv[1]
try: F = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 17)
except OSError: F = None
Z = [('Stehen', 'Stehen'), ('Gehen 0,25 s', 'Gehen'), ('ausgeholt 0,33 s', 'Aus'), ('Schlag 0,50 s', 'Ab'), ('Aufschlag 0,62 s', 'Auf')]
TW, TH = 216, 300
B = Image.new('RGB', (len(Z) * TW, TH + 28), (20, 20, 20)); d = ImageDraw.Draw(B)
for i, (t, n) in enumerate(Z):
    x, fu, k = [int(v) for v in re.search(r'Schirm grak: Fuß (\d+),(\d+) Kopf \d+,(\d+)', open('%s/st-grak-%s.log' % (P, n)).read()).groups()]
    h = max(fu - k, 40); hh = int(h * 2.0); w = int(hh * TW / TH)
    B.paste(Image.open('%s/st-grak-%s.png' % (P, n)).convert('RGB').crop((x - w // 2, fu + int(h * 0.22) - hh, x + w // 2, fu + int(h * 0.22))).resize((TW, TH)), (i * TW, 28))
    d.text((i * TW + 6, 5), t, fill=(240, 232, 216), font=F)
B.save(P + '/348.12-grak-blatt.png'); print('BLATT', B.size)
EOF
NUR_CC0=1 NAMEN="kappe;schild;fell" python3 $R/tools/blender348/hiebblatt.py $P/348.12-kobold-blatt.png $P "Stehen (Lauer)=Stehen" "Gehen 0,25 s=Gehen" "Hieb ausgeholt 0,22 s=Aus" "Hieb Aufschlag 0,43 s=Auf" || true
ls -l $P | grep -v " st-"
