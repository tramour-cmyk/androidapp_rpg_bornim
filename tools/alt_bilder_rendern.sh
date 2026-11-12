#!/usr/bin/env bash
# 882.1: Vergleichsbilder alt einmal rendern (tools/preview, Gradle), danach in den Zweig bilder unter alt/<teil> legen (tools/alt_bilder.sh liest sie).
# Aufruf (über 30 min, im Hintergrund): PROBE=882.1 env -u PROBE bash tools/alt_bilder_rendern.sh <ablage>  -> <ablage>/{screens,karte,512b,leute}
# Kotlin braucht mehr Speicher als vorgegeben (OutOfMemory in SkirmishScreen.kt), daher -Pkotlin.daemon.jvmargs=-Xmx5g.
set -x
A=${1:?ablage fehlt}; mkdir -p $A
P=$(cd "$(dirname "$0")/preview" && pwd); cd $P
G="../../gradlew -q -Pkotlin.daemon.jvmargs=-Xmx5g -Dorg.gradle.jvmargs=-Xmx3g run"
rm -rf build/screens; $G > $A/screens.log 2>&1; echo screens $?; rm -rf $A/screens; cp -r build/screens $A/screens
V="village:19:13:u:8;village:19:13:u;village:19:13:u:17;village:19:13:u:20;village:19:13:u:23"
V="$V;village:6:6:u;village:17:3:u;village:28:7:u;village:15:24:u;village:31:22:u;village:31:22:u:8;village:31:22:u:17;village:31:22:u:20"
V="$V;village:19:13:u:12;forest:9:29:u:12;forest:9:29:u:20;forest:9:29:u:23;deep_forest:2:18:r:12;deep_forest:2:18:r:23;cave:10:17:u:12"
V="$V;inn:4:6:u;inn:4:6:u:23;shop:4:4:u;shop:4:4:u:23;elder:4:4:u;elder:4:4:u:23;temple:4:4:u;temple:4:4:u:23"
rm -rf build/screens; KARTENZOOM=1 ONLY=zoom_nah_p HELDORT="$V" $G > $A/karte.log 2>&1; echo karte $?; rm -rf $A/karte; cp -r build/screens $A/karte
rm -rf build/screens; MENUE512B=1 $G > $A/512b.log 2>&1; echo 512b $?; rm -rf $A/512b; cp -r build/screens/512b $A/512b
rm -rf build/screens; LEUTEALT=1 $G > $A/leute.log 2>&1; echo leute $?; rm -rf $A/leute; cp -r build/screens $A/leute
for t in screens karte 512b leute; do echo $t $(ls $A/$t | wc -l); done
