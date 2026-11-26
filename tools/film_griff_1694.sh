#!/bin/bash
# 1694 (Auftrag 25.11., 20:36): Film alt neben neu aus den Bildfolgen von godot/tests/film_griff_1694.gd.
# Aufruf: tools/film_griff_1694.sh <ordner alt> <ordner neu> <commit alt> <commit neu> <ziel.mp4>
# Ablauf (12 s, 25 Bilder/s): Nahkamera von der Seite 3 s, dreimal (derselbe Moment), dann Spielkamera Handygröße 3 s; je Bild links
# alt, rechts neu, beschriftet mit Figur, Waffe und Commit.
set -e
A=$1; N=$2; CA=$3; CN=$4; Z=$5
T=$(mktemp -d)
schrift=$(fc-list : file | grep -m1 -i "DejaVuSans.ttf" | cut -d: -f1)
for teil in nah spiel; do
  ffmpeg -loglevel error -y -framerate 25 -i "$A/${teil}_%04d.png" -framerate 25 -i "$N/${teil}_%04d.png" -filter_complex \
    "[0]drawtext=fontfile=$schrift:text='alt $CA':x=10:y=10:fontsize=28:fontcolor=white:box=1:boxcolor=black@0.6[a];\
[1]drawtext=fontfile=$schrift:text='neu $CN':x=10:y=10:fontsize=28:fontcolor=white:box=1:boxcolor=black@0.6[b];\
[a][b]hstack,drawtext=fontfile=$schrift:text='WACHE_M Großaxt Stufe 1 Stehen – $([ $teil = nah ] && echo Nahkamera Seite rechte Hand || echo Spielkamera Handygröße)':x=10:y=h-40:fontsize=26:fontcolor=white:box=1:boxcolor=black@0.6" \
    -c:v libx264 -pix_fmt yuv420p "$T/$teil.mp4"
done
printf "file '%s'\n" "$T/nah.mp4" "$T/nah.mp4" "$T/nah.mp4" "$T/spiel.mp4" > "$T/liste.txt"
ffmpeg -loglevel error -y -f concat -safe 0 -i "$T/liste.txt" -c copy "$Z"
rm -rf "$T"
echo "FILM $Z"
