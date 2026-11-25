#!/bin/bash
# 2029 Beleg aus den Rohbildern von godot/tests/kopfteil_bild_2029.gd (ImageMagick): je Art ein Bild 2029-<art>.png, alt links, neu rechts.
#   oben: Erschaffung am Handy (540x1170, halb), roter Pfeil von rechts neben den Kopf; darunter Ausschnitt des Kopfes aus demselben Bild
#   (zweifach); dann Kopfausschnitt vorn und von der Seite (Spielfigur, Toon-Licht, Tusche). Schrift im schwarzen Rand.
# Aufruf: tools/godot/kopfteil_bild_2029.sh <roh mit marken.txt> <ziel> <commit> <commit alt>
set -e
R=$1; Z=$2; C=$3; M=$4
mkdir -p $Z
T=$(mktemp -d)
GOLD='#D4AF6A'
schild() {   # Bild, Text, Ausgabe[, Hoehe]: Text oben auf schwarzem Streifen, umbrochen innerhalb der Bildbreite; feste Hoehe haelt alt und neu gleich
  local w; w=$(identify -format %w "$1")
  convert -background black -fill "$GOLD" -pointsize 15 -size $((w - 12))x${4:-} -gravity center caption:"$2" -bordercolor black -border 6x5 $T/cap.png
  convert $T/cap.png "$1" -background black -gravity center -append "$3"
}
declare -A TITEL=([haar]="Haar: Elf Mann, Wachsoldat" [bart]="Bart: Zwerg Mann, Wachsoldat" [helm]="Helm: Mensch Mann, Wachsoldat")
declare -A ALT=([haar]="Hair_Long" [bart]="Bart_Breit + Hair_Moustache" [helm]="great_helm (KNIGHT_HELM)")
declare -A NEU=([haar]="Haar_MH01" [bart]="Bart_Wikinger + Hair_Moustache" [helm]="helmet mit Helm_Templer")
declare -A FUSS=([haar]="alt: Hair_Long aus haare.bin (Kauf). neu: Haar_MH01 aus MakeHuman hair01 culturalibre_hair_01 (culturalibre, CC0), 800 Dreiecke (Mann), Bild 1024x1024" [bart]="alt: Bart_Breit und Hair_Moustache aus haare.bin (Kauf). neu: Bart_Wikinger aus MakeHuman bodyparts05 rehmanpolanski_beard_viking (RehmanPolanski, CC0), 799 Dreiecke, Bild 1024x1024; Schnauzbart weiter Hair_Moustache (Paketbart hat keinen)" [helm]="alt: Gegenstand great_helm, Schrankteil KNIGHT_HELM (Kauf). neu: Gegenstand helmet mit Helm_Templer aus MakeHuman hats02 templar_knight_helmet (javherre, CC0), 800 Dreiecke, Bild 1024x704; Haar darunter verborgen")
for a in haar bart helm; do
  sp=(); au=(); vo=(); se=()
  for w in alt neu; do
    f=$R/${a}_${w}_spiel.png
    [ -f $f ] || continue
    set -- $(grep -a "^MARKE ${a}_${w}_spiel.png " $R/marken.txt | tail -1); kx=$4; ky=$5
    # Pfeil von rechts auf die Seite des Kopfes, Spitze 22 px neben der Kopfmitte (nicht ueber dem Gesicht)
    convert $f -stroke red -strokewidth 3 -draw "line $((kx+80)),$((ky-30)) $((kx+30)),$((ky-6))" \
      -fill red -draw "polygon $((kx+22)),$((ky-2)) $((kx+38)),$((ky-2)) $((kx+30)),$((ky-16))" $T/p.png
    if [ $w = alt ]; then wo="alt: ${ALT[$a]}, main $M"; else wo="neu: ${NEU[$a]}, $C"; fi
    convert $T/p.png -resize 50% $T/k.png; schild $T/k.png "Spielkamera (Handy 540x1170) $wo" $T/sp_$w.png 60
    convert $T/p.png -crop 150x150+$((kx-75))+$((ky-60)) +repage -resize 270x270 $T/a.png; schild $T/a.png "Ausschnitt Spielkamera, Kopf" $T/au_$w.png
    convert $R/${a}_${w}_vorn.png -resize 270x270 $T/v.png; schild $T/v.png "Kopf vorn ($w)" $T/vo_$w.png
    convert $R/${a}_${w}_seite.png -resize 270x270 $T/s.png; schild $T/s.png "Kopf Seite ($w)" $T/se_$w.png
    sp+=($T/sp_$w.png); au+=($T/au_$w.png); vo+=($T/vo_$w.png); se+=($T/se_$w.png)
  done
  [ ${#sp[@]} -gt 0 ] || continue
  for r in sp au vo se; do eval "convert \"\${$r[@]}\" -background black -gravity north +append $T/z_$r.png"; done
  convert $T/z_sp.png $T/z_au.png $T/z_vo.png $T/z_se.png -background black -append $T/ganz0.png
  w=$(identify -format %w $T/ganz0.png)
  convert -background black -fill "$GOLD" -pointsize 14 -size $((w - 12))x -gravity west caption:"${FUSS[$a]}" -bordercolor black -border 6x6 $T/fuss.png
  convert $T/ganz0.png $T/fuss.png -background black -append $T/ganz.png
  schild $T/ganz.png "2029 ${TITEL[$a]}; links alt, rechts neu; Spiel-Shader mit Tusche" $T/g.png
  convert $T/g.png -bordercolor black -border 6 $Z/2029-$a.png
  echo "BILD $Z/2029-$a.png"
done
rm -rf $T
