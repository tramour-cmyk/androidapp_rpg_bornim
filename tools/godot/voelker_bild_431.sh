#!/bin/bash
# 431 Schritt 3: Beleg aus den Rohbildern von godot/tests/voelker_bild_431.gd, beschriftet (ImageMagick).
# Aufruf: tools/godot/voelker_bild_431.sh <roh> <ziel> <commit> [<commit main>]
#   <ziel>/431-<volk>.png: Erschaffung am Handy (540x1170, halb) Mann alt | Mann neu | Frau alt | Frau neu, darunter der Held als Ausschnitt
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
for v in mensch elf zwerg huegelvolk orkbluetiger; do
  teile=(); aus=()
  for g in m w; do
    gw=$([ $g = m ] && echo Mann || echo Frau)
    for a in alt neu; do
      f=$R/erschaffung_${v}_${g}_${a}.png; [ -f $f ] || continue
      wo=$([ $a = alt ] && echo "alt, Menschenkörper ($M)" || echo "neu, Volkskörper ($C)")
      convert $f -resize 50% $T/k.png; schild $T/k.png "${NAME[$v]} $gw" $T/s_${g}_${a}.png
      convert $f -crop 200x290+20+20 +repage -resize 135% $T/a.png; schild $T/a.png "$wo" $T/a_${g}_${a}.png
      teile+=($T/s_${g}_${a}.png); aus+=($T/a_${g}_${a}.png)
    done
  done
  [ ${#teile[@]} -gt 0 ] || continue
  convert "${teile[@]}" +append $T/oben.png
  convert "${aus[@]}" +append $T/unten.png
  convert $T/oben.png $T/unten.png -background black -append -bordercolor black -border 6 $Z/431-$v.png
  echo "BILD $Z/431-$v.png"
done
r=()
for x in vorn:"vorn, Startausrüstung Wachsoldat" seite:"Seite" hinten:"hinten, Platte (Brustplatte, Handschuhe, Beinschienen), ohne Umhang und Schild"; do
  n=${x%%:*}; t=${x#*:}
  [ -f $R/reihe_$n.png ] || continue
  schild $R/reihe_$n.png "Mensch, Elf, Zwerg, Hügelvolk, Orkblütiger (je Mann, Frau), wahre Größe; $t; Stand $C" $T/r_$n.png; r+=($T/r_$n.png)
done
[ ${#r[@]} -gt 0 ] && convert "${r[@]}" -background black -append $Z/431-reihen.png && echo "BILD $Z/431-reihen.png"
# 431 (Sokrates 24.11., 15:34): Bogen in der linken Faust des Jägerkinds (Zwerg, Hauptmenü), alt gegen neu, vorn und außen
b=()
for a in alt neu; do
  for s in vorn aussen; do
    f=$R/bogen_${a}_${s}.png; [ -f $f ] || continue
    wo=$([ $a = alt ] && echo "alt, Bogen wie vor 431 ($M)" || echo "neu ($C)")
    schild $f "Zwerg, linke Faust mit Kurzbogen, $s; $wo" $T/b_${a}_${s}.png; b+=($T/b_${a}_${s}.png)
  done
done
[ ${#b[@]} -eq 4 ] && convert \( ${b[0]} ${b[1]} +append \) \( ${b[2]} ${b[3]} +append \) -background black -append $Z/431-bogen.png && echo "BILD $Z/431-bogen.png"
rm -rf $T
