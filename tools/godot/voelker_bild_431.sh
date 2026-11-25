#!/bin/bash
# 431 Schritt 3: Beleg aus den Rohbildern von godot/tests/voelker_bild_431.gd, beschriftet (ImageMagick).
# Aufruf: [KNIE=<Text>] tools/godot/voelker_bild_431.sh <roh> <ziel> <commit> [<commit alt>]
#   <ziel>/431-<volk>.png: Erschaffung am Handy (540x1170, halb), je Mann und Frau alt | neu V1 | neu V2, darunter Ausschnitt mit Marke
#   <ziel>/431-reihen.png: alle zehn Figuren in wahrer Groesse vorn, von der Seite, von hinten in Platte (ohne Umhang)
set -e
R=$1; Z=$2; C=$3; M=${4:-main}
mkdir -p $Z
T=$(mktemp -d)
GOLD='#D4AF6A'
schild() {   # Bild, Text, Ausgabe: Text oben auf schwarzem Streifen
  convert "$1" -background black -fill "$GOLD" -gravity north -splice 0x34 -pointsize 16 -annotate +0+7 "$2" "$3"
}
declare -A NAME=([mensch]=Mensch [elf]=Elf [zwerg]=Zwerg [huegelvolk]=Hügelvolk [orkbluetiger]=Orkblütiger)
declare -A MERK=([mensch]="" [elf]="Haar lang, kein Bart" [zwerg]="Bart/Zöpfe" [huegelvolk]="Bart kurz, Schild" [orkbluetiger]="Haut")
# 431 Nachbesserung: je Volk Zeile Mann und Zeile Frau: alt (5df25b2af, Rohbild des Laufs 45422069657 in <roh>/alt) | neu V1 | neu V2;
# Spielkamera in Handygröße (halb), darunter der Held als Ausschnitt mit Marke an Kopf und Schild (MARKE-Zeilen in <roh>/marken.txt)
for v in mensch elf zwerg huegelvolk orkbluetiger; do
  zeilen=()
  for g in m w; do
    gw=$([ $g = m ] && echo Mann || echo Frau)
    teile=(); aus=()
    for a in alt v1 v2; do
      f=$R/erschaffung_${v}_${g}_${a}.png; [ $a = alt ] && f=$R/alt/erschaffung_${v}_${g}_neu.png
      [ -f $f ] || continue
      case $a in alt) wo="alt $M";; v1) wo="neu V1 $C";; v2) wo="neu V2 $C";; esac
      convert $f -resize 50% $T/k.png; schild $T/k.png "${NAME[$v]} $gw, $wo" $T/s_${a}.png
      mk=$(grep -a "^MARKE erschaffung_${v}_${g}_${a}.png " $R/marken.txt 2>/dev/null | tail -1)
      zeich=""
      if [ -n "$mk" ] && [ -n "${MERK[$v]}" ]; then
        set -- $mk; kx=$4; ky=$5; sx=$7; sy=$8
        zeich="-fill none -stroke red -strokewidth 2 -draw \"circle $kx,$ky $((kx+22)),$ky\""
        [ $v = huegelvolk ] && [ $sx -ge 0 ] && zeich="$zeich -draw \"circle $sx,$sy $((sx+45)),$sy\""
      fi
      eval convert $f $zeich -crop 260x300+0+0 +repage $T/a.png
      schild $T/a.png "${MERK[$v]:-Ausschnitt}" $T/a_${a}.png
      teile+=($T/s_${a}.png); aus+=($T/a_${a}.png)
    done
    [ ${#teile[@]} -gt 0 ] || continue
    convert "${teile[@]}" +append $T/o_$g.png; convert "${aus[@]}" +append $T/u_$g.png
    convert $T/o_$g.png $T/u_$g.png -background black -append $T/z_$g.png; zeilen+=($T/z_$g.png)
  done
  [ ${#zeilen[@]} -gt 0 ] || continue
  convert "${zeilen[@]}" -background black -append -bordercolor black -border 6 $Z/431-$v.png
  echo "BILD $Z/431-$v.png"
done
r=()
for x in vorn:"vorn, Startausrüstung Wachsoldat" seite:"Seite, Platte ohne Umhang (Knie)" hinten:"hinten, Platte (Brustplatte, Handschuhe, Beinschienen), ohne Umhang und Schild"; do
  n=${x%%:*}; t=${x#*:}
  [ -f $R/reihe_$n.png ] || continue
  schild $R/reihe_$n.png "Mensch, Elf, Zwerg, Hügelvolk, Orkblütiger (je Mann, Frau), wahre Größe; $t; Stand $C${KNIE:+; Knie $KNIE}" $T/r_$n.png; r+=($T/r_$n.png)
done
[ ${#r[@]} -gt 0 ] && convert "${r[@]}" -background black -append $Z/431-reihen.png && echo "BILD $Z/431-reihen.png"
rm -rf $T
