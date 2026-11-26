#!/bin/bash
# 2029 Bildherkunft (Auftrag 26.11., 08:59): Bild 2029-helm-eigen aus zwei Rohlaeufen von godot/tests/kopfteil_bild_2029.gd (ARTEN=nacken),
# einer mit den Helmen des alten Stands (Bild casco.jpg), einer mit dem eigenen Bild. Spalten: alt A, neu A, neu B (Nackenschirm);
# Zeilen: Spielkamera (Handy 540x1170, halb, von hinten schraeg), Ausschnitt Helm (3-fach), Kopf vorn, Seite, hinten. Pfeil neben dem Helm.
# Aufruf: tools/godot/helm_eigen_bild_2029.sh <roh alt> <roh neu> <ziel> <commit> <commit alt> <Text Dreiecke und Bild>
set -e
RA=$1; RN=$2; Z=$3; C=$4; M=$5; DV=$6
mkdir -p $Z
T=$(mktemp -d)
GOLD='#D4AF6A'
schild() {   # Bild, Text, Ausgabe[, Hoehe]
  local w; w=$(identify -format %w "$1")
  convert -background black -fill "$GOLD" -pointsize 15 -size $((w - 12))x${4:-} -gravity center caption:"$2" -bordercolor black -border 6x5 $T/cap.png
  convert $T/cap.png "$1" -background black -gravity center -append "$3"
}
pfeil() {   # Bild, x, y, Ausgabe: Pfeil von rechts oben, Spitze 16 px rechts neben der Stelle
  local x=$2 y=$3
  convert "$1" -stroke red -strokewidth 3 -draw "line $((x+70)),$((y-40)) $((x+24)),$((y-6))" \
    -fill red -draw "polygon $((x+16)),$((y-1)) $((x+32)),$((y-2)) $((x+22)),$((y-16))" "$4"
}
marke() { grep -a "^MARKE $2 kopf " $1/marken.txt | tail -1 | awk '{print $4, $5}'; }
sp=(); au=(); vo=(); se=(); hi=()
for s in "alt A:$RA:A:alt: Bild casco.jpg (Paket), $M" "neu A:$RN:A:neu: eigenes Bild, $C" "neu B:$RN:B:neu B (Nackenschirm): eigenes Bild, $C"; do
  n=${s%%:*}; r=$(echo "$s" | cut -d: -f2); w=$(echo "$s" | cut -d: -f3); txt=$(echo "$s" | cut -d: -f4-)
  k=$(echo $n | tr ' ' _)
  read kx ky < <(marke $r nacken_${w}_spiel.png)
  pfeil $r/nacken_${w}_spiel.png $kx $ky $T/p.png
  convert $T/p.png -resize 50% $T/k.png; schild $T/k.png "Spielkamera (Handy 540x1170) $txt" $T/sp_$k.png 60
  convert $r/nacken_${w}_spiel.png -crop 90x90+$((kx-45))+$((ky-35)) +repage -filter Mitchell -resize 270x270 $T/a.png
  schild $T/a.png "Ausschnitt Spielkamera, Helm (3-fach)" $T/au_$k.png
  for an in vorn seite hinten; do
    convert $r/nacken_${w}_${an}.png -resize 270x270 $T/v.png; schild $T/v.png "Kopf $an ($n)" $T/${an}_$k.png
  done
  sp+=($T/sp_$k.png); au+=($T/au_$k.png); vo+=($T/vorn_$k.png); se+=($T/seite_$k.png); hi+=($T/hinten_$k.png)
done
for r in sp au vo se hi; do eval "convert \"\${$r[@]}\" -background black -gravity north +append $T/z_$r.png"; done
convert $T/z_sp.png $T/z_au.png $T/z_vo.png $T/z_se.png $T/z_hi.png -background black -append $T/ganz0.png
w=$(identify -format %w $T/ganz0.png)
convert -background black -fill "$GOLD" -pointsize 14 -size $((w - 12))x -gravity west caption:"Gegenstand helmet (Helm_Templer, Netz MakeHuman hats02, CC0). Bildquelle alt: casco.jpg aus dem Paket (Marke einer Tapetenseite, Herkunft unbelegt). Bildquelle neu: eigen aus kopfteil_mh.py (Eisengrau aus der Form, Rand und Nasenschutz dunkler, Rauschen aus eigenem Code). $DV. Stand $C" -bordercolor black -border 6x6 $T/fuss.png
convert $T/ganz0.png $T/fuss.png -background black -append $T/ganz.png
schild $T/ganz.png "2029 Helmbild eigen: Mensch Mann, Wachsoldat; links alt, Mitte und rechts neu; Spiel-Shader mit Tusche" $T/g.png
convert $T/g.png -bordercolor black -border 6 $Z/2029-helm-eigen.png
echo "BILD $Z/2029-helm-eigen.png"
rm -rf $T
