#!/bin/bash
# 2032 (Finja): ein Beleglauf alt gegen neu, Hand in der Hüfte. Bilder mit godot/tests/bild_2028.gd (Spielkamera Handy 1080x2340, Kamera.NAH,
# von vorn, Stehen Bild 0): alt = heldfigur.gd vom Stand cf7d57d45, neu = Arbeitskopie; gleicher Kaufbau. Rowena (Schenke) im Spiel und
# als Lagenbild (--lagen: Kleid-Innenseite gelb), Bram (Dorf, rechte Hand in der Hüfte, nicht im Test rot, zeigt die geänderte Haltung).
# Aufruf im Repo unter der Laufsperre: PROBE=2032 bash tools/godot/beleg_2032.sh <Ausgabeordner>
set -e
A=$(realpath -m "${1:-/tmp/beleg_2032}"); mkdir -p "$A"
R=$(git rev-parse --show-toplevel); H=$R/godot/skripte/heldfigur.gd
cp "$H" "$A/heldfigur_neu.gd"
git -C "$R" show cf7d57d45:godot/skripte/heldfigur.gd > "$A/heldfigur_alt.gd"
trap 'cp "$A/heldfigur_neu.gd" "$H"' EXIT
bild() {   # Stand, Figur, Karte, Zusatz
  cp "$A/heldfigur_$1.gd" "$H"
  (cd "$R/godot" && xvfb-run -a ~/godot/godot --rendering-driver opengl3 --path . --resolution 1080x2340 -s res://tests/bild_2028.gd -- \
    --aus="$A/$2_$1$4.png" --wer=$2 --karte=$3 ${4:+--${4#_}} 2>&1 | grep '^BILD2028' | tee "$A/$2_$1$4.txt")
}
# 2032-Ü3 (Ines): Rowena im Spiel, ohne Tusche und als Lagenbild; Bram nicht mehr (Haltung beim Chef)
for s in alt neu; do
  bild $s rowena inn ""
  bild $s rowena inn _ohnetusche
  bild $s rowena inn _lagen
done
