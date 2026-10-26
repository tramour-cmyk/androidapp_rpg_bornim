#!/bin/bash
# 348.6 Leute Runde 4b: Pruefblatt je Figur (Ruhelage vier Seiten, Kopf nah, Stehen vorn/rechts/links, Gehen) fuer Fremdpruefungen; Aufruf: pb_alle.sh <ordner> <ids…> (Ordner wie bau: <ordner>/<id>/held3-rig.blend)
# Pruefblatt fuer Figuren in $1 (Ordner mit <id>/held3-rig.blend), IDs $2..; Blatt <ordner>/pb_<id>.png
O=$1; shift
S=$(cd $(dirname $0) && pwd)
pb() { OUT=$O/$1 ~/bl/bin/python -I $S/pruefblatt.py > $O/$1/pb.log 2>&1 || { echo "FEHLER $1"; return 1; }
  cd $O/$1/pb && montage a_vorn.png b_rechts.png c_hinten.png d_links.png -tile 4x1 -geometry +2+2 -background '#222' r1.png \
   && montage e_kopf_vorn.png f_kopf_seite.png h_stehen0.png h_stehen1.png h_stehen2.png -tile 5x1 -geometry +2+2 -background '#222' r2.png \
   && montage h_gehen0.png h_gehen1.png h_gehen2.png -tile 3x1 -geometry +2+2 -background '#222' r3.png \
   && { ls i_*.png j_*.png > /dev/null 2>&1 && montage i_*.png j_*.png -tile 7x1 -geometry +2+2 -background '#222' r4.png || true; } \
   && convert r1.png r2.png r3.png $(ls r4.png 2>/dev/null) -background '#222' -append -gravity northwest -fill white -pointsize 20 -annotate +6+4 "$1" ../../pb_$1.png; echo "pb $1"; }
export -f pb; export O S
printf '%s\n' "$@" | xargs -P 4 -I{} bash -c 'pb {}'
