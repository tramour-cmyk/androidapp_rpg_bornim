#!/bin/bash
# 348.12 Grak auf dem CC0-Gerüst: Kampfort GEGNER=GRAK, Standbilder je Haltung (Stehen, Gehen, Hieb ausgeholt, Aufschlag), Blatt, Film.
# Aufruf: PROBE=348.12 bash tools/blender348/grak-cc0-probe.sh <grak-out> <basis-out> <axt-out> <ziel>
set -u
R=/home/user/androidapp_rpg_bornim; C=$1; B=$2; W=$3; P=$4; mkdir -p $P
D=$R/godot/kampf/daten; mkdir -p $D
cp $B/held.glb $D/held.bin
cp $B/kampfort-wald.glb $D/kampfort-wald.bin; cp $B/wald-maske.png $D/wald-maske.bild
for w in dagger shortsword longsword quarterstaff shield round_shield scimitar handaxe; do cp $B/$w.glb $D/$w.bin; done
cp $W/greataxe-grak.glb $D/greataxe-grak.bin
for t in gras erde halme; do cp $B/tex/$t.png $D/$t.bild; done
cp $C/hobgoblin_captain-hauptmann.glb $D/hobgoblin_captain-hauptmann.bin; cp $C/hobgoblin_captain-info.json $D/; cp $C/hobgoblin_captain-info.json $P/
export GEGNER=GRAK OHNEUI=1 SCHAU_LISTE=Stehen,Gehen,Hieb
G=~/godot/godot
bild() { (cd $R/godot && timeout 180 xvfb-run -a -s "-screen 0 1080x2340x24" $G --rendering-driver opengl3 --path . --resolution 1080x2340 -- --bild=$P/$1.png > $P/$1.log 2>&1) || true; }
film() { (cd $R/godot && SCHAU=1 SCHAU_TITEL="$2" timeout 300 xvfb-run -a -s "-screen 0 540x1170x24" $G --rendering-driver opengl3 --path . --resolution 540x1170 --write-movie /tmp/$1.avi --fixed-fps 30 -- --bild=/tmp/x.png > $P/$1-film.log 2>&1) || true
  ffmpeg -loglevel error -y -i /tmp/$1.avi -vf scale=360:-2 -c:v libx264 -pix_fmt yuv420p -crf 30 -preset veryfast $P/$1.mp4 || true; rm -f /tmp/$1.avi; }
bild grak-cc0
export NUR=grak
for h in Stehen= Gehen=Gehen:0.25 Aus=Hieb:0.33 Auf=Hieb:0.60; do HALTUNG=${h#*=} bild st-${h%%=*}; done
film grak cc0
grep -E "Schirm|Waffe|Zweihand|SCRIPT ERROR|^ +at: res" $P/grak-cc0.log | head -20
for h in Stehen Aus Auf; do grep -E "Zweihand" $P/st-$h.log | head -1 | sed "s/^/$h: /"; done
python3 - "$P" <<'EOF'
import sys, re
from PIL import Image, ImageDraw, ImageFont
P = sys.argv[1]
try: F = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 17)
except OSError: F = None
Z = [('Stehen', 'Stehen'), ('Gehen 0,25 s', 'Gehen'), ('Hieb ausgeholt 0,33 s', 'Aus'), ('Hieb Aufschlag 0,60 s', 'Auf')]
TW, TH = 260, 330
B = Image.new('RGB', (len(Z) * TW, TH + 28), (20, 20, 20)); d = ImageDraw.Draw(B)
for i, (t, n) in enumerate(Z):
    x, fu, k = [int(v) for v in re.search(r'Schirm grak: Fuß (\d+),(\d+) Kopf \d+,(\d+)', open('%s/st-%s.log' % (P, n)).read()).groups()]
    h = max(fu - k, 40); hh = int(h * 1.9); w = int(hh * TW / TH)
    B.paste(Image.open('%s/st-%s.png' % (P, n)).convert('RGB').crop((x - w // 2, fu + int(h * 0.12) - hh, x + w // 2, fu + int(h * 0.12))).resize((TW, TH)), (i * TW, 28))
    d.text((i * TW + 6, 5), t, fill=(240, 232, 216), font=F)
B.save(P + '/348.12-grak-blatt.png'); print('BLATT', B.size)
EOF
ls -l $P | grep -v " st-"
