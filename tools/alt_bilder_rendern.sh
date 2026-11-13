#!/usr/bin/env bash
# 882.1: Vergleichsbilder alt einmal rendern (tools/preview), danach in den Zweig bilder unter alt/<teil> legen (tools/alt_bilder.sh liest sie).
# Aufruf (über eine Stunde, im Hintergrund, nichts anderes daneben): PROBE=882.1 env -u PROBE bash tools/alt_bilder_rendern.sh <ablage> [teil …]
#   -> <ablage>/{screens,karte,512b,leute}; ohne Teil alle vier
# Kotlin braucht zum Bauen mehr Speicher als vorgegeben (OutOfMemory in SkirmishScreen.kt), daher -Pkotlin.daemon.jvmargs=-Xmx5g.
# Skia gibt den Speicher der Szenen nicht frei (je Bild etwa 250 MB, auch nach GC; ein Lauf in einem Stück bricht nach etwa 75 Bildern
# mit Exit 137 ab): gebaut wird einmal (installDist), dann läuft jeder Teil mit WEITER=1 WEITER_MB=7000; über 7000 MB endet der Lauf mit 3
# und wird neu gestartet, fertige Bilder überspringt er (shot, bild512 in tools/preview).
set -x
A=$(mkdir -p "${1:?ablage fehlt}" && cd "$1" && pwd); shift
T=${*:-screens karte 512b leute}
P=$(cd "$(dirname "$0")/preview" && pwd); cd $P
../../gradlew -q -Pkotlin.daemon.jvmargs=-Xmx5g -Dorg.gradle.jvmargs=-Xmx3g installDist || exit 1
../../gradlew -q --stop; pkill -f KotlinCompileDaemon
L() {  # L <teil> [VAR=wert …]: ein Teil, mit Neustarts
    local t=$1; shift; rm -rf build/screens; : > $A/$t.log
    while :; do env "$@" WEITER=1 WEITER_MB=7000 JAVA_OPTS=-Xmx1500m build/install/preview/bin/preview >> $A/$t.log 2>&1; e=$?; [ $e -eq 3 ] || break; done
    echo $t exit $e
}
V="village:19:13:u:8;village:19:13:u;village:19:13:u:17;village:19:13:u:20;village:19:13:u:23"
V="$V;village:6:6:u;village:17:3:u;village:28:7:u;village:15:24:u;village:31:22:u;village:31:22:u:8;village:31:22:u:17;village:31:22:u:20"
V="$V;village:19:13:u:12;forest:9:29:u:12;forest:9:29:u:20;forest:9:29:u:23;deep_forest:2:18:r:12;deep_forest:2:18:r:23;cave:10:17:u:12"
V="$V;inn:4:6:u;inn:4:6:u:23;shop:4:4:u;shop:4:4:u:23;elder:4:4:u;elder:4:4:u:23;temple:4:4:u;temple:4:4:u:23"
for t in $T; do
    case $t in
        screens) L screens ;;
        karte) L karte KARTENZOOM=1 ONLY=zoom_nah_p "HELDORT=$V" ;;
        512b) L 512b MENUE512B=1; rm -rf $A/512b; cp -r build/screens/512b $A/512b; continue ;;
        leute) L leute LEUTEALT=1 ;;
    esac
    rm -rf $A/$t; cp -r build/screens $A/$t
done
for t in $T; do echo $t $(ls $A/$t | wc -l); done
