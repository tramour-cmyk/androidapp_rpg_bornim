#!/usr/bin/env bash
# 882.1 (Umzug BRS Schritt 8): Vergleichsbilder „alt“ (Kotlin-Fassung) liegen einmal gerendert im Zweig „bilder“ unter alt/, damit
# die Werkzeuge ohne Gradle und ohne tools/preview auskommen (core/ geht mit 870.10). Teile:
#   screens  Standardlauf von tools/preview (gradlew run): Schirme, Kampf, Karten nah/weit (vgl348.py, vorschau-Vergleich)
#   karte    KARTENZOOM=1 ONLY=zoom_nah_p mit HELDORT: Dorf zu fünf Tageszeiten und an den Prüfstellen, Wald, Tiefer Wald, Höhle,
#            die vier Grundrisse bei Tag und Nacht (vgl348.py, pruef348/raeume_blatt.py)
#   512b     MENUE512B=1: jeder Menüschirm mit seinen Fenstern, dazu je Bild <name>.txt (menues_512b_blatt.py)
#   leute    LEUTEALT=1: die dreizehn Leute des Dorfs von vorn und hinten (Abgleich alt 620.2, LISTE-ABGLEICH-ALT.md „Leute“)
# Aufruf: bash tools/alt_bilder.sh <teil> <ziel-ordner>   -> Bilder des Teils flach in <ziel-ordner>
# Wie gerendert: alt/LIESMICH.md im Zweig „bilder“.
set -e
teil=${1:?teil fehlt (screens, karte, 512b, leute)}; ziel=${2:?ziel-ordner fehlt}
R=$(cd "$(dirname "$0")/.." && pwd)
git -C "$R" fetch -q origin bilder 2>/dev/null || git -C "$R" fetch -q origin bilder
git -C "$R" cat-file -e "origin/bilder:alt/$teil" 2>/dev/null || { echo "alt_bilder: alt/$teil fehlt im Zweig bilder" >&2; exit 2; }
mkdir -p "$ziel"
git -C "$R" archive origin/bilder "alt/$teil" | tar -x -C "$ziel" --strip-components=2
echo "alt_bilder: $(ls "$ziel" | wc -l) Dateien aus alt/$teil nach $ziel"
