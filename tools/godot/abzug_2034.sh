#!/bin/bash
# 2034 Teil 0: Einzelbilder 2048x1024 aus den Rohbildern von godot/tests/abzug_2034.gd (ImageMagick), je Stueck ein Bild, kein Sammelbild.
#   Abzug:   links vorn, rechts Seite (je 1024x924, mit Tusche), Rand unten 100 px: Nummer, Name, Paket, Lizenz, Dreiecke, Bild, Commit.
#   Probe (SIGNATUR=1): links vorn mit Tusche, rechts vorn ohne Tusche, Messung im Rand.
#   Massstab: senkrechter Strich am linken Rand jeder Haelfte, 1 m, wenn er ins Bild passt, sonst 10 cm (beschriftet).
# Aufruf: tools/godot/abzug_2034.sh <roh> <liste.json> <lauf.log> <ziel> <commit> [probe <messung.json>] [<Nummer,...>]
set -e
R=$1; L=$2; LOG=$3; Z=$4; C=$5; ART=${6:-abzug}; MESSUNG=${7:-}; NUR=${8:-}
mkdir -p $Z
T=$(mktemp -d)
GOLD='#D4AF6A'
strich() {   # Bild, px je m, Ausgabe
  local p=$2 l m
  m=$(python3 -c "p=float('$p'); print('1 m' if p<=860 else '10 cm')")
  l=$(python3 -c "p=float('$p'); print(int(round(p if p<=860 else p*0.1)))")
  convert "$1" -stroke "$GOLD" -strokewidth 3 -draw "line 30,$((900-l)) 30,900" -draw "line 22,$((900-l)) 38,$((900-l))" -draw "line 22,900 38,900" \
    -stroke none -fill "$GOLD" -pointsize 22 -annotate +44+$((900-l/2)) "$m" "$3"
}
python3 - "$L" "$NUR" > $T/zeilen <<'EOF'
import json, sys
nur = set(sys.argv[2].split(',')) if sys.argv[2] else None
for e in json.load(open(sys.argv[1])):
    if not e.get('glb', '').endswith('.glb') or (nur and e['nummer'] not in nur): continue
    print('\t'.join([e['nummer'], e['name'], e['paket'], e['art'], e.get('lizenz', '') or e.get('lizenz_kopf', ''), str(e['dreiecke']), e['bild'], e.get('urheber', '')]))
EOF
while IFS=$'\t' read -r nr name paket art liz dr bild urh; do
  pv=$(grep -a "^MARKE $nr vorn " $LOG | tail -1 | awk '{print $5}')
  ps=$(grep -a "^MARKE $nr seite " $LOG | tail -1 | awk '{print $5}')
  [ -n "$pv" ] || { echo "OHNE $nr"; continue; }
  if [ "$ART" = probe ]; then
    strich $R/${nr}_vorn.png $pv $T/a.png; strich $R/${nr}_vorn_ohne.png $pv $T/b.png
    la="vorn, mit Signatur (Toon-Licht, Tusche)"; lb="vorn, ohne Tusche (Toon-Licht)"
    mess=$(python3 -c "import json;m=json.load(open('$MESSUNG')).get('$nr',{});print(m.get('satz',''))")
  else
    strich $R/${nr}_vorn.png $pv $T/a.png; strich $R/${nr}_seite.png $ps $T/b.png
    la="vorn"; lb="Seite (Blick nach rechts)"; mess=""
  fi
  convert $T/a.png -fill "$GOLD" -pointsize 24 -annotate +80+40 "$la" $T/a2.png
  convert $T/b.png -fill "$GOLD" -pointsize 24 -annotate +80+40 "$lb" $T/b2.png
  convert $T/a2.png $T/b2.png +append $T/oben.png
  txt="$nr  $name  ($art)  ·  Paket $paket, Urheber $urh, Lizenz $liz  ·  $dr Dreiecke (nicht ausgedünnt), Bild $bild  ·  Spiel-Shader toon + tusche (Held), Stand $C"
  [ -n "$mess" ] && txt="$txt"$'\n'"$mess"
  convert -background black -fill "$GOLD" -pointsize 21 -size 2024x88 -gravity west caption:"$txt" -bordercolor black -border 12x6 $T/rand.png
  convert $T/oben.png $T/rand.png -background black -append -resize 2048x1024! $Z/$nr.png
  cwebp -quiet -q 90 $Z/$nr.png -o $Z/$nr.webp && rm $Z/$nr.png
  echo "BILD $Z/$nr.webp"
done < $T/zeilen
rm -rf $T
