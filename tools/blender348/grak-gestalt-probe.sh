#!/bin/bash
# 348.12 Gestalt (Chef 28.10., 08:09/08:10): Grak aus grak_gestalt.py im Kampfort, allein, Augenhöhe, ganzer Körper, eine Drehung,
# dann der Kopf nah (probe.gd SCHAU=dreh); Film und Blatt aus den Standbildern (0°, 45°, 90°, 180°, Kopf 0°, 30°).
# Aufruf: PROBE=348.12 bash tools/blender348/grak-gestalt-probe.sh <grak-gestalt-ordner> <basis-ordner> <ziel>
set -u
R=/home/user/androidapp_rpg_bornim; G=$1; B=$2; P=$3; mkdir -p $P
D=$R/godot/kampf/daten; mkdir -p $D
cp $B/held.glb $D/held.bin; cp $B/kampfort-wald.glb $D/kampfort-wald.bin; cp $B/wald-maske.png $D/wald-maske.bild
for t in gras erde halme; do cp $B/tex/$t.png $D/$t.bild; done
for w in $B/*.glb; do n=$(basename $w .glb); [ "$n" = held ] || [ "$n" = kampfort-wald ] || cp $w $D/$n.bin; done
cp $G/grak-gestalt.glb $D/hobgoblin_captain-hauptmann.bin
echo '{"hauptmann": {"waffen": [], "groesse_cm": 186, "geruest": "cc0"}}' > $D/hobgoblin_captain-info.json
X=~/godot/godot
(cd $R/godot && timeout 300 $X --headless --path . --import > $P/import.log 2>&1) || true
cd $R/godot && GEGNER=GRAK OHNEUI=1 SCHAU=dreh DREH_S=${DREH_S:-8} DREH_BILDER=$P SCHAU_TITEL="${TITEL:-Grak, Gestalt}" DREH_ZEILE="${ZEILE:-}" \
  timeout 300 xvfb-run -a -s "-screen 0 540x1170x24" $X --rendering-driver opengl3 --path . --resolution 540x1170 \
  --write-movie /tmp/grak-dreh.avi --fixed-fps 30 -- --bild=/tmp/x.png > $P/grak-film.log 2>&1 || true
# r2 (Prüfer r1: Sekunde 1 zeigte den Kampf): ab dem ersten Bild der Drehung
AB=$(grep -oE "^Dreh Start Bild [0-9]+" $P/grak-film.log | grep -oE "[0-9]+$" | head -1)
ffmpeg -loglevel error -y -ss $(python3 -c "print(${AB:-0}/30)") -i /tmp/grak-dreh.avi -c:v libx264 -pix_fmt yuv420p -crf 26 -preset veryfast $P/348.12-grak-gestalt.mp4 || true
rm -f /tmp/grak-dreh.avi
grep -E "^Dreh|SCRIPT ERROR|^ +at: " $P/grak-film.log | head -20
python3 - "$P" <<'EOF'
import sys, glob, os
from PIL import Image, ImageDraw, ImageFont
P = sys.argv[1]
try: F = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 18)
except OSError: F = None
Z = [('vorn', 'ganz-000'), ('halb seitlich', 'ganz-045'), ('seitlich', 'ganz-090'), ('hinten', 'ganz-180'), ('Kopf vorn', 'kopf-000'), ('Kopf halb', 'kopf-030')]
TW, TH = 300, 560
B = Image.new('RGB', (len(Z) * TW, TH + 30), (20, 20, 20)); d = ImageDraw.Draw(B)
for i, (t, n) in enumerate(Z):
    f = glob.glob('%s/dreh-*-%s.png' % (P, n))
    if not f: continue
    im = Image.open(f[0]).convert('RGB'); w, h = im.size
    k = im.crop((0, int(h * 0.09), w, int(h * 0.93))).resize((TW, TH))
    B.paste(k, (i * TW, 30)); d.text((i * TW + 8, 5), t, fill=(240, 232, 216), font=F)
B.save(P + '/348.12-grak-gestalt-blatt.png'); print('BLATT', B.size)
EOF
ls -l $P | grep -vE " dreh-"
