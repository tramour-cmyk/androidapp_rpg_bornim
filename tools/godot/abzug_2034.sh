#!/bin/bash
# 2034 Teil 0: Einzelbilder 2048x1024 aus den Rohbildern von godot/tests/abzug_2034.gd (ImageMagick), je Stueck ein Bild, kein Sammelbild.
#   Abzug:   links vorn, rechts Seite (je 1024x924, mit Tusche), Rand unten 100 px: Nummer, Name, Paket, Lizenz, Dreiecke, Bild, Commit.
#   Probe (SIGNATUR=1): links vorn mit Tusche, rechts vorn ohne Tusche, Messung im Rand.
#   Massstab und Ansichtsname (2034-Ue14 (4), Pruefer 19:59 (1): nie auf dem Stueck): unter jeder Haelfte in einer eigenen Zeile
#   (30 px) zwischen Bild und Rand, waagrechter Strich 1 m, wenn er in die Spalte passt, sonst 10 cm; im Bild selbst nur das Stueck.
#   Probe: dazu <Nr>_abzug.webp (vorn|Seite wie im Abzug) aus denselben Bildern.
#   Je Stueck „MASSSTAB <Nr> abstand_px <n>“: Bildpunkte vom unteren Rand des Stuecks bis zur Massstabzeile (> 0).
#   Haeute (<Nr>_haut.png aus abzug_mh.py im GLB-Ordner): Hautbild verkleinert mittig auf Grund, Vermerk „ohne Koerper, Weg H erst 2031“.
#   2034-Ue6 (Planer 19:01): je Stueck „FUELLT <Nr> vorn <Anteil> seite <Anteil>“ (Hoehe des Stuecks / Bildhoehe, aus MARKE), Liste
#   <ziel>/fuellt.tsv; unter 0,80 als „UNTER80“ gemeldet.
# Aufruf: tools/godot/abzug_2034.sh <roh> <liste.json> <lauf.log> <ziel> <commit> [probe <messung.json>] [<Nummer,...>] [<glb-ordner>]
set -e
R=$1; L=$2; LOG=$3; Z=$4; C=$5; ART=${6:-abzug}; MESSUNG=${7:-}; NUR=${8:-}; GLB=${9:-}
mkdir -p $Z
T=$(mktemp -d)
GOLD='#D4AF6A'
strich() {   # px je m, Ansichtsname, Breite, Ausgabe (<Breite>x30, schwarz): Massstab links, Name rechts daneben
  local p=$1 l m
  m=$(python3 -c "p=float('$p'); print('1 m' if p<=$3-320 else '10 cm')")
  l=$(python3 -c "p=float('$p'); print(int(round(p if p<=$3-320 else p*0.1)))")
  convert -size ${3}x30 xc:black -stroke "$GOLD" -strokewidth 3 -draw "line 30,15 $((30+l)),15" -draw "line 30,7 30,23" -draw "line $((30+l)),7 $((30+l)),23" \
    -stroke none -fill "$GOLD" -pointsize 18 -annotate +$((40+l))+21 "$m  ·  $2" "$4"
}
# 2034-Ue14 (5): zwei Ansichten (je 2048x924 gerendert) nach Zuschnitt (Breite des Stuecks + 8 %, aus MARKE) nebeneinander auf
# 2048 Bildpunkte; freier Platz zu gleichen Teilen. Darunter die Massstabzeile, dann der Rand mit Schrift.
zwei() {   # a b px_a px_b zuschnitt_a zuschnitt_b name_a name_b text ziel
  local wa wb
  read wa wb <<< "$(python3 -c "a,b=int('$5'),int('$6'); r=max(0,2048-a-b); w=min(2048,a+r//2); print(w, 2048-w)")"
  convert "$1" -gravity center -crop ${wa}x924+0+0 +repage $T/a1.png
  convert "$2" -gravity center -crop ${wb}x924+0+0 +repage $T/b1.png
  strich $3 "$7" $wa $T/a2.png; strich $4 "$8" $wb $T/b2.png
  convert $T/a1.png $T/b1.png +append \( $T/a2.png $T/b2.png +append \) -append $T/oben.png
  local t=${9//%/%%}   # ImageMagick: % ist Steuerzeichen
  convert -background black -fill "$GOLD" -size 2024x58 -gravity west caption:"$t" -bordercolor black -border 12x6 $T/rand.png
  convert $T/oben.png $T/rand.png -background black -append -resize 2048x1024! ${10%.webp}.png
  convert ${10%.webp}.png -quality 90 ${10} && rm ${10%.webp}.png
  echo "BILD ${10}"
}
python3 - "$L" "$NUR" > $T/zeilen <<'EOF'
import json, sys
nur = set(sys.argv[2].split(',')) if sys.argv[2] else None
for e in json.load(open(sys.argv[1])):
    if not e.get('glb', '') or (nur and e['nummer'] not in nur): continue
    print('\t'.join([e['nummer'], e['name'], e['paket'], e['art'], e.get('lizenz', '') or e.get('lizenz_kopf', ''), str(e['dreiecke']), e['bild'], e.get('urheber', ''), e['glb']]))
EOF
: > $Z/fuellt.tsv
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
  mv=$(grep -a "^MARKE $nr vorn " $LOG | tail -1); ms=$(grep -a "^MARKE $nr seite " $LOG | tail -1)
  [ -n "$mv" ] || { echo "OHNE $nr"; continue; }
  pv=$(echo "$mv" | awk '{print $5}'); fv=$(echo "$mv" | awk '{print $11}'); zv=$(echo "$mv" | awk '{print $13}')
  ps=$(echo "$ms" | awk '{print $5}'); fs=$(echo "$ms" | awk '{print $11}'); zs=$(echo "$ms" | awk '{print $13}')
  txt="$nr  $name  ($art)  ·  Paket $paket, Urheber $urh, Lizenz $liz  ·  $dr Dreiecke (nicht ausgedünnt), Bild $bild  ·  Spiel-Shader toon, Tusche nach Licht und Sonne wie im Kampfort, Stand $C"
  printf '%s\t%s\t%s\n' "$nr" "$fv" "$fs" >> $Z/fuellt.tsv
  echo "FUELLT $nr vorn $fv seite $fs"
  python3 -c "import sys; sys.exit(0 if min(float('$fv'), float('$fs')) >= 0.8 else 1)" || echo "UNTER80 $nr vorn $fv seite $fs"
  echo "MASSSTAB $nr abstand_px $(python3 -c "print(min(int(924*(1-f)/2) for f in (float('$fv'), float('$fs'))))")"
  if [ "$ART" = probe ]; then
    mess=$(python3 -c "import json;m=json.load(open('$MESSUNG')).get('$nr',{});print(m.get('satz',''))")
    zwei $R/${nr}_vorn.png $R/${nr}_vorn_ohne.png $pv $pv $zv $zv "vorn, mit Signatur (Toon-Licht, Tusche nach Licht)" "vorn, ohne Tusche (Toon-Licht)" "$txt"$'\n'"$mess" $Z/$nr.webp
    zwei $R/${nr}_vorn.png $R/${nr}_seite.png $pv $ps $zv $zs "vorn" "Seite (Blick nach rechts)" "$txt" $Z/${nr}_abzug.webp
  else
    zwei $R/${nr}_vorn.png $R/${nr}_seite.png $pv $ps $zv $zs "vorn" "Seite (Blick nach rechts)" "$txt" $Z/$nr.webp
  fi
done < $T/zeilen
rm -rf $T
