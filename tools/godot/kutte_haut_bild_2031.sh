#!/bin/bash
# 2031 Beleg aus den Rohbildern von godot/tests/kutte_haut_bild_2031.gd (ImageMagick): 2031-kutte.png, 2031-haut-m.png, 2031-haut-w.png.
#   je Spalte ein Fall (alt links, neu rechts): Erschaffung am Handy (540x1170, halb) mit rotem Pfeil neben der Figur auf die Stelle,
#   darunter die Ansichten (Spielfigur, Toon-Licht, Tusche, Schatten). Schrift im schwarzen Rand: Volk, Figur, Stueck/Haut, Dreiecke,
#   Bildgroesse, Commit.
# Aufruf: tools/godot/kutte_haut_bild_2031.sh <roh mit marken.txt> <ziel> <commit neu> <commit alt (main)>
set -e
R=$1; Z=$2; C=$3; M=$4
mkdir -p $Z
T=$(mktemp -d)
GOLD='#D4AF6A'
schild() {   # Bild, Text, Ausgabe[, Hoehe]
  local w; w=$(identify -format %w "$1")
  convert -background black -fill "$GOLD" -pointsize 14 -size $((w - 12))x${4:-} -gravity center caption:"$2" -bordercolor black -border 6x5 $T/cap.png
  convert $T/cap.png "$1" -background black -gravity center -append "$3"
}
dreieck() { grep -a "^DREIECKE $1 " $R/marken.txt | tail -1 | awk '{print $3}'; }
spalte() {   # Fall, Titel, Ansichten..., Ausgabe ist $T/sp_<fall>.png
  local f=$1 titel=$2; shift 2
  set -- $(grep -a "^MARKE ${f}_spiel.png " $R/marken.txt | tail -1 | cut -d' ' -f3,4) "$@"
  local kx=$1 ky=$2; shift 2
  convert $R/${f}_spiel.png -stroke red -strokewidth 4 -draw "line $((kx+130)),$((ky-40)) $((kx+60)),$((ky-6))" \
    -fill red -draw "polygon $((kx+48)),$((ky)) $((kx+66)),$((ky+4)) $((kx+62)),$((ky-14))" -resize 50% $T/s.png
  schild $T/s.png "$titel; Spielkamera (Handy 540x1170); $(dreieck $f) Dreiecke sichtbar" $T/a_$f.png 64
  local teile=($T/a_$f.png)
  for an in "$@"; do
    convert $R/${f}_${an}.png -resize 270x $T/v.png
    schild $T/v.png "$an" $T/b_${f}_$an.png
    teile+=($T/b_${f}_$an.png)
  done
  convert "${teile[@]}" -background black -gravity north -append $T/sp_$f.png
}
bild() {   # Ausgabe, Kopf, Fuss, Spalten (Dateien)
  local aus=$1 kopf=$2 fuss=$3; shift 3
  convert "$@" -background black -gravity north +append $T/g0.png
  local w; w=$(identify -format %w $T/g0.png)
  convert -background black -fill "$GOLD" -pointsize 13 -size $((w - 12))x -gravity west caption:"$fuss" -bordercolor black -border 6x6 $T/fuss.png
  convert $T/g0.png $T/fuss.png -background black -append $T/g1.png
  schild $T/g1.png "$kopf" $T/g2.png
  convert $T/g2.png -bordercolor black -border 6 $Z/$aus.png
  echo "BILD $Z/$aus.png $(identify -format %wx%h $Z/$aus.png)"
}
# Kutte: Mensch Mann Klosterschueler
spalte kutte_alt1 "alt 1: Novizenkutte (wie main $M)" vorn seite hieb
spalte kutte_alt2 "alt 2: Robe des Zauberlehrlings, Schrankteil ROBE (wie main $M; Haende stechen durch, offen 1657)" vorn seite hieb
spalte kutte_neu "neu: Kutte MH_KUTTE aus suits02 donitz_monk_robe + _hood ($C)" vorn seite hieb
bild 2031-kutte "2031 Kutte: Mensch Mann Klosterschueler, Gegenstand novice_habit; links alt, rechts neu; vorn, Seite, Hieb-Endbild; Spiel-Shader mit Tusche und Schatten" \
  "neu: Kutte 3.000 Dreiecke (Paket 28.286), Bild 1024x1024; Haar unter der Kapuze, Beine barfuss unter dem Rock, Arme der Tracht verdeckt. Pruefung kutte_haut_2031: 30 Kuttenfaelle, 28 ok, 2 mit je 1 Kinn-Ecke vor der Kapuze im Hieb-Endbild (Frau Mensch, Frau Halbling). Lizenz CC0 (Donitz; Seite, Paketdatei, .mhclo)" \
  $T/sp_kutte_alt1.png $T/sp_kutte_alt2.png $T/sp_kutte_neu.png
# Haeute: Mensch Wachsoldat
for g in m w; do
  if [ $g = m ]; then H="jartur69_mitte jartur69_alt rehman_wikinger"; GN="Mann"; Q="skins02: jartur69_middleage_slavic_male (jartur69), jartur69_old_slavic_male (jartur69), rehmanpolanski_skin_viking_tattoos (RehmanPolanski)"
  else H="ghosts_jung ghosts_mitte ghosts_alt"; GN="Frau"; Q="skins01: onlytheghosts_young/middle_aged/old_eurasian_female (OnlyTheGhosts)"; fi
  sp=()
  spalte haut_${g}_alt "alt: Kaufhaut (wie main $M)" vorn gesicht; sp+=($T/sp_haut_${g}_alt.png)
  for h in $H; do spalte haut_${g}_$h "neu: $h ($C)" vorn gesicht; sp+=($T/sp_haut_${g}_$h.png); done
  bild 2031-haut-$g "2031 Haut: Mensch $GN Wachsoldat; links alt, rechts drei neue zur Wahl; Ganzfigur und Gesicht vorn; Hautton der Erschaffung (getoent wie heute)" \
    "neu aus $Q, CC0 (Seite, Paketdatei); gebacken auf die Kauf-UV, Kopf und Leib je 1024x1024 JPG. Pruefung kutte_haut_2031: 15 Hautfaelle $GN (5 Voelker x 3), 0 falsch, Hautton am Gesicht hoechstens 5 %% vom heutigen" \
    "${sp[@]}"
done
rm -rf $T
