#!/bin/bash
# 2034 Teil 0: Einzelbilder 2048x1024 aus den Rohbildern von godot/tests/abzug_2034.gd (ImageMagick), je Stueck ein Bild, kein Sammelbild.
#   Abzug:   links vorn, rechts Seite (je 1024x924, mit Tusche), Rand unten 100 px: Nummer, Name, Paket, Lizenz, Dreiecke, Bild, Commit.
#   Probe (SIGNATUR=1): links vorn mit Tusche, rechts vorn ohne Tusche, Messung im Rand.
#   Massstab: senkrechter Strich am linken Rand jeder Haelfte, 1 m, wenn er ins Bild passt, sonst 10 cm (beschriftet).
#   Haeute (<Nr>_haut.png aus abzug_mh.py im GLB-Ordner): Hautbild verkleinert mittig auf Grund, Vermerk „ohne Koerper, Weg H erst 2031“.
#   2034-Ue6 (Planer 19:01): je Stueck „FUELLT <Nr> vorn <Anteil> seite <Anteil>“ (Hoehe des Stuecks / Bildhoehe, aus MARKE), Liste
#   <ziel>/fuellt.tsv; unter 0,80 als „UNTER80“ gemeldet.
# Aufruf: tools/godot/abzug_2034.sh <roh> <liste.json> <lauf.log> <ziel> <commit> [probe <messung.json>] [<Nummer,...>] [<glb-ordner>]
set -e
R=$1; L=$2; LOG=$3; Z=$4; C=$5; ART=${6:-abzug}; MESSUNG=${7:-}; NUR=${8:-}; GLB=${9:-}
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
    if not e.get('glb', '') or (nur and e['nummer'] not in nur): continue
    print('\t'.join([e['nummer'], e['name'], e['paket'], e['art'], e.get('lizenz', '') or e.get('lizenz_kopf', ''), str(e['dreiecke']), e['bild'], e.get('urheber', ''), e['glb']]))
EOF
[ "$ART" = probe ] || : > $Z/fuellt.tsv
while IFS=$'\t' read -r nr name paket art liz dr bild urh datei; do
  if [ "${datei%_haut.png}" != "$datei" ]; then
    [ "$ART" = probe ] && continue
    [ -n "$GLB" ] || { echo "OHNE $nr (GLB-Ordner fehlt)"; continue; }
    convert -size 2048x924 xc:'rgb(9,11,19)' \( $GLB/$datei -resize 1200x880 \) -gravity east -geometry +60+0 -composite \
      -gravity northwest -fill "$GOLD" -pointsize 24 -annotate +40+30 "Hautbild verkleinert,\nohne Körper\n(hm08-UV, Weg H erst 2031)" $T/oben.png
    txt="$nr  $name  ($art)  ·  Paket $paket, Urheber $urh, Lizenz $liz  ·  Bild $bild  ·  Stand $C"
    txt=${txt//%/%%}
    convert -background black -fill "$GOLD" -pointsize 21 -size 2024x88 -gravity west caption:"$txt" -bordercolor black -border 12x6 $T/rand.png
    convert $T/oben.png $T/rand.png -background black -append -resize 2048x1024! $Z/$nr.png
    convert $Z/$nr.png -quality 90 $Z/$nr.webp && rm $Z/$nr.png
    echo "BILD $Z/$nr.webp"; continue
  fi
  pv=$(grep -a "^MARKE $nr vorn " $LOG | tail -1 | awk '{print $5}')
  ps=$(grep -a "^MARKE $nr seite " $LOG | tail -1 | awk '{print $5}')
  [ -n "$pv" ] || { echo "OHNE $nr"; continue; }
  fv=$(grep -a "^MARKE $nr vorn " $LOG | tail -1 | awk '{print $11}'); fs=$(grep -a "^MARKE $nr seite " $LOG | tail -1 | awk '{print $11}')
  if [ "$ART" != probe ]; then
    printf '%s\t%s\t%s\n' "$nr" "$fv" "$fs" >> $Z/fuellt.tsv
    echo "FUELLT $nr vorn $fv seite $fs"
    python3 -c "import sys; sys.exit(0 if min(float('$fv'), float('$fs')) >= 0.8 else 1)" || echo "UNTER80 $nr vorn $fv seite $fs"
  fi
  if [ "$ART" = probe ]; then
    strich $R/${nr}_vorn.png $pv $T/a.png; strich $R/${nr}_vorn_ohne.png $pv $T/b.png
    la="vorn, mit Signatur (Toon-Licht, Tusche)"; lb="vorn, ohne Tusche (Toon-Licht)"
    mess=$(python3 -c "import json;m=json.load(open('$MESSUNG')).get('$nr',{});print(m.get('satz',''))")
  else
    strich $R/${nr}_vorn.png $pv $T/a.png; strich $R/${nr}_seite.png $ps $T/b.png
    la="vorn"; lb="Seite (Blick nach rechts)"; mess=""
  fi
  convert $T/a.png -fill "$GOLD" -pointsize 20 -annotate +110+27 "$la" $T/a2.png
  convert $T/b.png -fill "$GOLD" -pointsize 20 -annotate +110+27 "$lb" $T/b2.png
  convert $T/a2.png $T/b2.png +append $T/oben.png
  txt="$nr  $name  ($art)  ·  Paket $paket, Urheber $urh, Lizenz $liz  ·  $dr Dreiecke (nicht ausgedünnt), Bild $bild  ·  Spiel-Shader toon + tusche (Held), Stand $C"
  [ -n "$mess" ] && txt="$txt"$'\n'"$mess"
  txt=${txt//%/%%}   # ImageMagick: % ist Steuerzeichen
  ps_rand="-pointsize 21"; [ -n "$mess" ] && ps_rand=""   # Probe: Schrift passt sich dem Rand an (Messsatz drei Zeilen)
  convert -background black -fill "$GOLD" $ps_rand -size 2024x88 -gravity west caption:"$txt" -bordercolor black -border 12x6 $T/rand.png
  convert $T/oben.png $T/rand.png -background black -append -resize 2048x1024! $Z/$nr.png
  convert $Z/$nr.png -quality 90 $Z/$nr.webp && rm $Z/$nr.png
  echo "BILD $Z/$nr.webp"
done < $T/zeilen
rm -rf $T
