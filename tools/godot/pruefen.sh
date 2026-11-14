#!/usr/bin/env bash
# 1123 (1109 C, Chef 13.11., 10:56): der Prüfschritt des Bauservers (godot.yml), vorher Zeile für Zeile im Schritt „Skripte pruefen“.
# Aufruf aus dem Arbeitsordner des Laufs: bash $GITHUB_WORKSPACE/tools/godot/pruefen.sh TEIL
#   TEIL alle: alles (wie vorher); a: Start, Import und erster Teil (Job apk, wenn alle Blöcke der Vorberechnung Treffer sind);
#   b: Start, Import und zweiter Teil (Job pruefen2, holt die Modelle aus der Vorberechnung, läuft daneben).
# Die Falle ERR liest die Zeile aus dieser Datei ($0), darum mit vollem Pfad aufrufen. Wie im Schritt vorher mit pipefail.
TEIL=${1:-alle}
set -o pipefail
echo "1123: Teil $TEIL"
set +e
ROT=$GITHUB_WORKSPACE/rot.txt; : > $ROT; STUFE=start
trap 'z=$(sed -n "${LINENO}p" "$0"); t=$(echo "$z" | grep -oE "tests/[a-z0-9_]+\.gd" | head -1); echo "$STUFE ${t:-Zeile $LINENO}: ${z:0:160}" >> $ROT; echo "::error::918 rot ($STUFE) ${t:-Zeile $LINENO}"' ERR
cd godot
~/godot/godot --headless --import --path . 2>&1 | tail -5 || true
timeout 120 ~/godot/godot --headless --path . --quit-after 300 2>&1 | tee check.log | tail -20
# 1136: „! grep“ löste die Falle ERR nie aus (bash zählt negierte Befehle nicht), die Prüfung lief nie; „ERROR:“ allein traf in
# Lauf 427 nur Speicherzeilen beim Beenden („RID allocations … leaked at exit“), echte Fehler 0
grep -E "SCRIPT ERROR|Parse Error|Failed to load" check.log | head -20 || :; [ "$(grep -cE "SCRIPT ERROR|Parse Error|Failed to load" check.log || :)" -eq 0 ]
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/skripte_pruefen.gd 2>&1 | grep -E "SKRIPTE|FALSCH"   # 399.1 Test 130
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/fackel_1140.gd 2>&1 | grep -E "^FEHLER|FACKEL1140|SCRIPT ERROR"   # 1140 eine Fackel für Welt, Ausrüstung, Kampfort
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/grak_1142.gd 2>&1 | grep -E "^FEHLER|GRAK1142|SCRIPT ERROR"   # 1142 Grak nur einmal
STUFE=test
# 909 (Chef 11.11., 08:52): die vier längsten Messungen laufen nebenher (Lauf 353: schild_406 491 s, wolf_mess_438 138 s,
# zustaende_563 85 s, strahl_mess_415 66 s von 1405 s); Befehl unverändert, Ausgabe und Ende kommen gesammelt vor „918: Ende“,
# rot wie vorher (Zeile in rot.txt). Keine der vier schreibt nach user://.
NEBEN=$GITHUB_WORKSPACE/nebenher; mkdir -p $NEBEN; : > $NEBEN/pids; echo "909: $(nproc) Kerne"
nebenher() { local n=$1; shift; ( s=$SECONDS; ( set -o pipefail; eval "$1" ); r=$?; echo "NEBENHER $n Ende $r nach $((SECONDS-s)) s"; exit $r ) > $NEBEN/$n.log 2>&1 & echo "$! $n" >> $NEBEN/pids; }
# 1123: erster Teil (Job apk; bei TEIL=b nur Start und Import oben)
if [ "$TEIL" != b ]; then
timeout 600 ~/godot/godot --headless --path . -s res://tests/drehteller_499.gd 2>&1 | grep -E "FEHLER|DREHTELLER499|KANDIDAT|^\[Haltung|^[A-Z]+:|^  |SCRIPT ERROR" | cut -c1-300 || true   # 499 Messung ohne Bild, vorn im Schritt (Lauf 282: brach vorher an auftraege_542 ab) (Schild-Spalt), noch nicht sperrend
timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/drehteller_film_499.gd 2>&1 | grep -E "FEHLER|DREHTELLER499|^Film|^  |SCRIPT ERROR" | cut -c1-300 || true   # 499 Schild im Gehen (Spalt, Oberkante gegen Schultern), Messung ohne Bild, noch nicht sperrend
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/film_wache_1062.gd 2>&1 | grep -E "^(FALSCH|FILMWACHE1062)|SCRIPT ERROR"   # 1062 Film ohne Argument hinter „--“ bricht ab (Tuffy)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/blende_594.gd 2>&1 | grep -E "BLENDE594|SCRIPT ERROR"   # 594 Gegner der Kampfblende wie alt
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/reihe_836.gd 2>&1 | grep -E "REIHE836|Hinweis|SCRIPT ERROR"   # 836 Reihenhinweis einmal je Spielstand
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/eingebung_840.gd 2>&1 | grep -E "EINGEBUNG840|Kampf|SCRIPT ERROR"   # 840 Eingebung Wolfssprung einmal je Spielstand
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/bericht_1031.gd 2>&1 | grep -E "BERICHT1031|Eingebung:|Schaden:|SCRIPT ERROR"   # 1031 ganzer Bericht in den Farben der Kampfzeilen
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/kampfklang_939.gd 2>&1 | grep -E "KAMPFKLANG939|Geheul|Ring:|Sieg|SCRIPT ERROR"   # 939 Kampfklang wie alt (Ring, Geheul, Sieg)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/eingebung_986.gd 2>&1 | grep -E "EINGEBUNG986|Kampf|SCRIPT ERROR"   # 986 Eingebungen nach BRS, Knurren, Gerufener sagt an, Leibwache ohne Einkreisen
# 536 t268.20 (Jerry): Abstand der Ansagen der Wölfe zum Kopf, ohne und mit Namen, Schrift 1,0 und 1,3; meldet nur
for f in 1.0 1.3; do SCHRIFT=$f timeout 300 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/abstand_536.gd 2>&1 | grep -E "ABSTAND536|FEHLER|SCRIPT ERROR" || true; done
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/ring_597.gd 2>&1 | grep -E "RING597|SCRIPT ERROR"   # 597 kein Ring ohne Ansage
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/ring_halt_1094.gd 2>&1 | grep -E "RINGHALT1094|FEHLER|SCRIPT ERROR"   # 1094 Ring steht nach dem Tippen
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/ring_949.gd 2>&1 | grep -E "RING949|FEHLER|SCRIPT ERROR"   # 949 perfekter Ring: erst der Schlag des Gegners, dann die Antwort
# 949 (Lauf 438, Film ohne perfekten Ring): Ring nach der Uhr des Kampforts, auch wenn die echte Zeit schneller läuft (Film 6 %)
RUNDEN=1 GEGNER=GRAK RING=PERFECT ZUG=heavy ZEILEN=1 BREMSE_MS=60 timeout 300 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/sollbild_784.gd > $RUNNER_TEMP/ring949_film.log 2>&1 || true
grep -q " EVADED" $RUNNER_TEMP/ring949_film.log && echo "RING949 Filmuhr gut" || { echo "RING949 Filmuhr FALSCH: kein Ausweichen mit langsamer Uhr"; grep -E "SCRIPT ERROR|Hieb" $RUNNER_TEMP/ring949_film.log | head; exit 1; }
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/ruhe_1007.gd 2>&1 | grep -E "RUHE1007|SCRIPT ERROR"   # 1007 Monster der Karte mit Ruhebewegung, Ruhelaut nur nah
set -o pipefail; SEEDS=1,2 timeout 300 ~/godot/godot --headless --path . -s res://tests/schalter_1024.gd 2>&1 | grep -E "^(gut|FALSCH)|SCHALTER1024|SCRIPT ERROR"   # 1024 t278.8 Schalter nie unter dem Kasten, auch wenn er im Zug wächst
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/ruhe_977.gd 2>&1 | grep -E "RUHE977|SCRIPT ERROR"   # 977 Grimmzahn mit Ruhebewegung
set -o pipefail; (cd .. && bash tools/godot/kauf_cache_probe.sh 2> /dev/null | grep -E "^FALSCH|KAUFCACHE854")   # 854 Kennung je Block (ohne Kaufrepo)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/platztausch_863.gd 2>&1 | grep -E "^(gut|FALSCH|     )|PLATZTAUSCH863|SCRIPT ERROR"   # 863 Nahkämpfer von hinten tauschen den Platz (alle Gegner)
set -o pipefail; HERO=CLERIC MERC=FIGHTER GEGNER=RATS SEEDS=1,2,3,4,5,6 timeout 600 ~/godot/godot --headless --path . -s res://tests/ruhe_863.gd 2>&1 | grep -E "^(gut|FALSCH)|RUHE863|SCRIPT ERROR"   # 863 t277.14 keine Ratte weicht in eine andere (Kaufratte; Seed 1 war rot)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/wurf_935.gd 2>&1 | grep -E "^(gut|FEHLER)|^  [A-Z]|WURF935|SCRIPT ERROR"   # 935 Flasche im Bogen
set -o pipefail; timeout 300 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/bausteine_806.gd 2>&1 | grep -E "^(gut|FEHLER)|BAUSTEINE806|SCRIPT ERROR"   # 806 Kampf messen, kein Bodennebel
set -o pipefail; timeout 300 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/ansage_597.gd 2>&1 | grep -E "ANSAGE597|FEHLER|SCRIPT ERROR"   # 597 t268.21 Ansage der Wölfe im Bild
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/tempo_600.gd 2>&1 | grep -E "TEMPO600|SCRIPT ERROR"   # 600 Tempoknopf im Kampfort
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/bewegung_997.gd 2>&1 | grep -E "BEWEGUNG997|SCRIPT ERROR"   # 997 Testkampf: laufende Bewegung und Fassung je Figur
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/raster_998.gd 2>&1 | grep -E "RASTER998|SCRIPT ERROR"   # 998 Kampfraster kräftiger wie 229.3
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/titel_585.gd 2>&1 | grep -E "TITEL585|SCRIPT ERROR"   # 585 Titel ausgewogen umgebrochen
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/sterben_596.gd 2>&1 | grep -E "STERBEN596|SCRIPT ERROR"   # 596 Sterben gespiegelt
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/tod_1141.gd 2>&1 | grep -E "TOD1141|SCRIPT ERROR"   # 1141 jeder Gegnerkörper hat „Tod“, Goblins drei, liegend und verschieden
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/pfeil_601.gd 2>&1 | grep -E "PFEIL601|SCRIPT ERROR"   # 601 Pfeil auch beim Ducken
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/am_zug_565.gd 2>&1 | grep -E "^(FEHLER|AMZUG565)|SCRIPT ERROR"   # 565 A Kasten am Zug
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/schirm_833.gd 2>&1 | grep -E "^(FEHLER|SCHIRM833|Gegnerzug)|SCRIPT ERROR"   # 833 Vorschlag A unterer Kampfschirm
set -o pipefail; SEEDS=4 timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/leiste_751.gd 2>&1 | grep -E "^  |LEISTE751"   # 751 A Knöpfe matt, keine Zeile „ist dran“ (1095), Zugleiste, kein verratener Ausgang (Jerry)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/auto_945.gd 2>&1 | grep -E "^  Seed|AUTO945|SCRIPT ERROR"   # 945 Held und Söldner Auto bleiben abschaltbar (Jerry)
set -o pipefail; timeout 400 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/wechsel_950.gd 2>&1 | grep -E "^(FEHLER|WECHSEL950|hero|merc|Abstand|Mira)|SCRIPT ERROR"   # 950 Platztausch mit Schritten
set -o pipefail; timeout 400 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/tausch_1041.gd 2>&1 | grep -E "^(FEHLER|TAUSCH1041|hero:|merc:|Abstand)|SCRIPT ERROR"   # 1041 Platztausch im selben Takt (Jägerkind/Wachsoldat); Umriss und Paar des Chefs mit 1072 (Bahnen), 1106
nebenher zustaende_563 'set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/zustaende_563.gd 2>&1 | grep -E "^(ZUSTAND563|Zustand|Leiste)|SCRIPT ERROR"'   # 563 A Zustände ohne Überlappen
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/tritt_1040.gd 2>&1 | grep -E "^(TRITT1040|Tritt|FEHLER)|SCRIPT ERROR"   # 1040 Monster der Geschichte tritt beim Wenden, auch wenn es dem Helden folgt
GEGNER=GRAK,KROGG,SKELETONS,BOARS,GRABHUNDE,GOBLINS timeout 400 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/tod_lage_1141.gd 2>&1 | grep -E "^TODLAGE1141|SCRIPT ERROR" | cut -c1-260 || true   # 1141.1 Messung: fallen sie um die Füße? (meldet nur)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/zustand_1036.gd 2>&1 | grep -E "^(ZUSTAND1036|Zustand|Aufflackern|Tafel|FEHLER)|SCRIPT ERROR"   # 1036 Zustände an den Figuren wie alt (Brennen, Gift …)
timeout 300 ~/godot/godot --headless --path . -s res://tests/held_klassen_376.gd 2>&1 | grep -E "HELDKLASSEN|FALSCH|SCRIPT ERROR"   # 376.1
timeout 120 ~/godot/godot --headless --path . -s res://tests/menuehelden_867.gd 2>&1 | tee menue867.log | grep -E "FEHLER|MENUEHELDEN867|SCRIPT ERROR"; grep -q "^MENUEHELDEN867 0 Fehler" menue867.log   # 867 Haarfarben der Vorgaben, Haltungen (Tom)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . -s res://tests/held_kampf_403.gd 2>&1 | grep -E "^(ok|FEHLER|Held 403)|SCRIPT ERROR"   # 403 (Jerry)
# 824: Held ohne Schild geht nach dem Hieb rückwärts im Schritttempo heim (nicht 3,8 m/s mit 1,6-facher Bewegung)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/angriff_824.gd 2>&1 | grep -E "^(ANGRIFF824|FEHLER|MASS)|SCRIPT ERROR"   # 824 (Jerry)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/atem_4531.gd 2>&1 | grep -E "^(ok|FEHLER|Held|Söldner|nach|in den|im Kampf|Atem 453)|SCRIPT ERROR"   # 453.1 (Tuffy)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/atem_rechnung_4531.gd 2>&1 | grep -E "^(ok|FEHLER|Anstrengung|Atemrechnung)|SCRIPT ERROR"   # 453.1 Feld 2 (Tuffy)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/atem_tiere_1166.gd 2>&1 | grep -E "^FEHLER|ATEMTIERE1166|SCRIPT ERROR"   # 1166 Atem für alle Tiere mit Rücken
# 406 b (Jerry): Schild im Kampf, auch linke Schulter und Oberarm gegen den Schild; 1136 (1128 A Laufnachweis): haelt an
# (Lauf 427: „SCHILD 406 gut“, Ende 0), traegt 1013 und 1014
nebenher schild_406 'timeout 900 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/schild_406.gd 2>&1 | grep -E "^(ok|FEHLER|  |SCHILD|Schild|Kampf )|SCRIPT ERROR"'
# 1136 (1128 A, für 904): Simulation 444 im Spielkampf, N=200 je Gegner, ohne Skriptfehler (am Rechner 92 s, 0 Fehler)
nebenher sim444_870 'python3 ../tools/sim444/sim.py --ohne-wirtschaft --json $RUNNER_TEMP/sim870.json > /dev/null && SIM=$RUNNER_TEMP/sim870.json N=200 timeout 900 ~/godot/godot --headless --path . -s res://tests/sim444_870.gd > sim870.log 2>&1; r=$?; tail -8 sim870.log; grep -E "SCRIPT ERROR" sim870.log | head -5; [ $r -eq 0 ] && [ "$(grep -c "SCRIPT ERROR" sim870.log)" -eq 0 ]'
# 1136 (1128 A, für 1054): Regeln des Kampfs, bisher nur in godot-kampf.yml; am Rechner „MARS Regeln: 0 abweichend“, 0 Skriptfehler
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/mars_regeln.gd 2>&1 | tee regeln.log | grep -E "^abweich|MARS Regeln|SCRIPT ERROR"; [ "$(grep -c "SCRIPT ERROR" regeln.log || :)" -eq 0 ]
# 406a G1 (Jerry): Kampfkamera des Schlussfilms ohne Bild, angeschnittene Figuren je Kampf; meldet nur
MESS=1 TEIL=kampf timeout 900 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/film_406.gd 2>&1 | grep -E "^Film 406|AUSSERHALB|SCRIPT ERROR" || true
nebenher wolf_mess_438 'set -o pipefail; SCHAU_SCHILD=1 SCHAU_709=1 timeout 900 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/wolf_mess_438.gd 2>&1 | grep -E "^(— |  |Befunde|Wolf 438|Kampf |438 DIAG|438 GLEIT|Schild |709 (Ziel|Hieb))|SCRIPT ERROR"'   # 900: SCHAU_SCHILD, SCHAU_709, GLEIT bis B1 grün   # 438, 439, 440 (Jerry): Wölfe ohne Gleiten, Reihenfolge, Tod
# 593 (Jerry): Ausweichen auch rückwärts (Ratten, Spinne, Grak, Wölfe); meldet, hält noch nicht an
timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/ausweichen_593.gd 2>&1 | grep -E "^(ok|FEHLER|  |AUSWEICHEN593)|SCRIPT ERROR" || true
# 864 (Jerry): kein Sprung der Gegner auf ihre Plätze, wenn der Held an den Zug kommt; meldet, hält noch nicht an
GEGNER=BATS,GRABHUNDE,WOLVES,RATS timeout 900 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/beam_864.gd 2>&1 | grep -E "^(  Sprung|Kampf |BEAM864)|SCRIPT ERROR" || true
set -o pipefail; SCHAU_1166=1 GEGNER=WOLVES,KOBOLDS,RATS,GRABHUNDE timeout 900 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/kamera_992.gd 2>&1 | grep -E "^(  Sprung|  Boden|KAMERA992|1166 Atem)|SCRIPT ERROR"   # 992 kein Sprung der Kamera (wiederholt zu 709)
# 784 A (Jerry): Kampftakt Wolfsrudel gegen DESIGN-KAMPF F9; meldet, hält erst nach dem ersten grünen Film an den Chef an (dann STRENG=1)
SCHAU_932=1 timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/sollbild_784.gd 2>&1 | grep -E "^(ÜBER|MISST|== |  Zug|  Held wartet|SOLLBILD784|932 Held)|SCRIPT ERROR" || true   # 932: Zug des Helden zerlegt
# 546, 703 A (Jerry): Wölfe weichen rasch aus und bleiben danach stehen; meldet, hält noch nicht an
timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/ausweichen_546.gd 2>&1 | grep -E "^(ok|FEHLER|AUSWEICHEN_546)|SCRIPT ERROR" || true
# 415 r3 (Jerry): Strahlenprobe ohne Bild, Stabspitze hinter dem Körper (F6), Strahl durch eine Figur (E3), Richtung (F2); meldet nur
nebenher strahl_mess_415 'timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/strahl_mess_415.gd 2>&1 | grep -E "^(Strahl|STRAHL)|SCRIPT ERROR" || true'
fi
# 1123: zweiter Teil (Job pruefen2; bei TEIL=a übersprungen)
if [ "$TEIL" != a ]; then
timeout 120 ~/godot/godot --headless --path . -s res://tests/klang_test.gd 2>&1 | grep -E "^(gut|FALSCH)|KLANG|SCRIPT ERROR"   # 399.3
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/klang_994.gd 2>&1 | grep -E "^FALSCH|KLANG994|SCRIPT ERROR"   # 994 kein stummer Tierlaut, Wiederholung als eine Zeile
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/staub_990.gd 2>&1 | grep -E "^FALSCH|STAUB990|SCRIPT ERROR"   # 990 Staub im Licht bleibt im Raum
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/parade_seite_662.gd 2>&1 | grep -E "PARADE662|FEHLER|SCRIPT ERROR"   # 662 Parade nach der Seite des Angreifers (Jerry)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/todesschrei_2963.gd 2>&1 | grep -E "^(ok|FEHLER|Todesschrei 296.3)|SCRIPT ERROR"   # 296.3 Todesschrei auch bei Zauber- und Zustandstod (Jerry)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/arkan_993.gd 2>&1 | grep -E "^(Arkan 993|  |FEHLER|ARKAN993)|SCRIPT ERROR"   # 993 Arkanpfeil aus R2 (Jerry)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/brs_473.gd 2>&1 | grep -E "FALSCH|BRS473|SCRIPT ERROR"   # 473 Monsterwerte BRS wie sim444
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/brs_kampf_478.gd 2>&1 | grep -E "^(ok|FALSCH)|BRS478|SCRIPT ERROR"   # 478 Kampf nach BRS wie sim444
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/handlungen_870.gd 2>&1 | grep -E "^(ok|FALSCH)|HANDLUNGEN870|SCRIPT ERROR"   # 870.5 Kampfhandlungen an Fertigkeiten
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/lohn_870.gd 2>&1 | grep -E "^FALSCH|LOHN870|SCRIPT ERROR"   # 870.5 Lohn nach BRS (Modell D, Topf, Grenze)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/brs_blatt_870.gd 2>&1 | grep -E "FALSCH|BRSBLATT|SCRIPT ERROR"   # 870.2 Kampfblatt nach BRS
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/begriffe_868.gd 2>&1 | grep -E "FALSCH|BEGRIFFE868|SCRIPT ERROR"   # 868 im Kampf keine Rüstungsklasse, kein W20, keine Würfelangabe (Jerry)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/brs_held_870.gd 2>&1 | grep -E "FALSCH|BRSHELD870|SCRIPT ERROR"   # 870.4 Held nach BRS (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/kraeutersammeln_875.gd 2>&1 | grep -E "FALSCH|KRAEUTERSAMMELN875|SCRIPT ERROR"   # 875 Kräutersammeln statt Kräuterkunde (Tom)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/gegenstaende_870.gd 2>&1 | grep -E "FALSCH|GEGENSTAENDE870|SCRIPT ERROR"   # 870.6 Gegenstände und Beute nach BRS (Tuffy)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/zustaende_870.gd 2>&1 | grep -E "FALSCH|ZUSTAENDE870|SCRIPT ERROR"   # 870.6 Zustände, Tränke, Spinnseide ohne SRD-Maß (Tuffy)
timeout 60 ~/godot/godot --headless --path . -s res://tests/masse_498.gd 2>&1 | tee masse498.log | grep -E "FEHLER|MASSE498|SCRIPT ERROR"; grep -q "^MASSE498 0 Fehler" masse498.log   # 498 Schrift wie alt
timeout 120 ~/godot/godot --headless --path . -s res://tests/gluehwuermchen_514.gd 2>&1 | tee glueh514.log | grep -E "FEHLER|GLUEH514|SCRIPT ERROR"; grep -q "^GLUEH514 0 Fehler" glueh514.log   # 514 Gluehwuermchen wie alt
timeout 300 ~/godot/godot --headless --path . -s res://tests/effekte_814.gd 2>&1 | tee effekte814.log | grep -E "FEHLER|EFFEKTE814|SCRIPT ERROR"; grep -q "^EFFEKTE814 0 Fehler" effekte814.log   # 814 Effekte Szene 1 Dorf (Spike)
timeout 300 ~/godot/godot --headless --path . -s res://tests/fussstaub_814.gd 2>&1 | grep -E "FUSS814|SCRIPT ERROR" | head -80 || true   # 814 t277.5: Fussstaub und Federn, nur Messung
timeout 300 ~/godot/godot --headless --path . -s res://tests/huhnflucht_814.gd 2>&1 | tee huhnflucht814.log | grep -E "FEHLER|HUHNFLUCHT814|SCRIPT ERROR"; grep -q "^HUHNFLUCHT814 0 Fehler" huhnflucht814.log   # 814 Chef 16:14: Huhn schreckt auf, auch eingeklemmt und unterwegs
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/brs_472.gd 2>&1 | grep -E "FALSCH|BRS472|SCRIPT ERROR"   # 472 Heldenstufe aus Erfahrung
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/brs_471.gd 2>&1 | grep -E "FALSCH|BRS471|SCRIPT ERROR"   # 471 Fertigkeiten durch Tun (BRS 1.2)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/kampfuebung_471.gd 2>&1 | grep -E "FALSCH|KAMPFUEBUNG471|SCRIPT ERROR"   # 471 Uebung im Kampf, gutgeschrieben nach dem Sieg
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/textkasten_583.gd 2>&1 | grep -E "FEHLER|TEXTKASTEN583|SCRIPT ERROR"   # 583 ▼ im Rand, Erzähltes schräg (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/flucht_591.gd 2>&1 | grep -E "^(ok|FEHLER|Flucht 591)|SCRIPT ERROR"   # 591 Huhn und Kaninchen fliehen (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/tierlaut_591.gd 2>&1 | grep -E "^FALSCH|TIERLAUT591|SCRIPT ERROR"   # 591 Huhn und Kaninchen fliehen mit Laut (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/tierflucht_591.gd 2>&1 | grep -E "^FALSCH|^Held bis|TIERFLUCHT591|SCRIPT ERROR"   # 591 im Spiel: Huhn flieht mit Gackern und Fluegel (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/nacht_607.gd 2>&1 | grep -E "^FALSCH|NACHT607|SCRIPT ERROR"   # 607 nachts drinnen (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/kamera_615.gd 2>&1 | grep -E "^FALSCH|KAMERA615|SCRIPT ERROR"   # 615 Kamera dreht und zoomt um den Helden (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/atemlos_592.gd 2>&1 | grep -E "^(ok|FEHLER|Atemlos 592)|SCRIPT ERROR"   # 592 atemlos kurz stehen (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/glas_608.gd 2>&1 | grep -E "^FALSCH|GLAS608|SCRIPT ERROR"   # 608 Fenster durchsichtiger Haeuser nach der Tageszeit (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/ruhe_test.gd 2>&1 | grep -E "RUHE|FEHLER|SCRIPT ERROR"   # 397, 592 Ruhebewegungen ohne Muede
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/ruhe_kauf_595.gd 2>&1 | grep -E "^(ok|FEHLER|RUHE595)|SCRIPT ERROR"   # 595 Ruhebewegungen Egel, Schnecke
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/stufe_538.gd 2>&1 | grep -E "FEHLER|STUFE|SCRIPT ERROR"   # 538 Stufengrenze Kapitel 1, Stufe in Gespraechen
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/licht_539.gd 2>&1 | grep -E "FEHLER|LICHT|SCRIPT ERROR"   # 539 Licht folgt der Uhr
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/klopfen_611.gd 2>&1 | grep -E "^FALSCH|KLOPFEN611|SCRIPT ERROR"   # 611 Klopfen hoerbar (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/schreib_78519.gd 2>&1 | grep -E "^FEHLER|SCHREIB78519|SCRIPT ERROR"   # 785.19 Text Zeichen für Zeichen (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/klopfen_629.gd 2>&1 | grep -E "^FALSCH|KLOPFEN629|SCRIPT ERROR"   # 629.1 Sprechernamen beim Klopfen (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/pim_verband_842.gd 2>&1 | grep -E "^FALSCH|PIM842|SCRIPT ERROR"   # 842 Pim überreden, Knopf im Gespräch, Verband (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/pim_rennt_1086.gd 2>&1 | grep -E "FEHLER|PIMRENNT1086|SCRIPT ERROR"   # 1086 Pim rennt nach dem Gold wirklich heim, die Mutter dankt (echter Ablauf, Spike)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/karten_regeln.gd 2>&1 | grep -E "FALSCH|KARTENREGELN|SCRIPT ERROR"   # 870.9 Kartenregeln der alten Kotlin-Tests (Karten von Hand, tools/karten)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/starttexte_540.gd 2>&1 | grep -E "FEHLER|STARTTEXTE|SCRIPT ERROR"   # 540 Suedrand, Schlagbaum, 12/5, Tipp
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/suedrand_540.gd 2>&1 | grep -E "FEHLER|SUEDRAND540|SCRIPT ERROR"   # 540 t274.12: auch schräg an den Südrand stoßen
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/auftraege_542.gd 2>&1 | grep -E "FEHLER|AUFTRAEGE|SCRIPT ERROR"   # 542 Fetzen, Gwennas Ring, Aldrics Ring
set -o pipefail; timeout 240 ~/godot/godot --headless --path . -s res://tests/lage_542.gd 2>&1 | grep -E "FEHLER|LAGE542|SCRIPT ERROR"   # 542 Weg der Prüfzeilen 285: Lage, Brett, Stein, Truhe, Abgabe, Aldrics Ring
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/startwerte_543.gd 2>&1 | grep -E "FEHLER|STARTWERTE|SCRIPT ERROR"   # 543 Startgold, Heiltraenke, Wiederkehrort
timeout 120 ~/godot/godot --headless --path . -s res://tests/zwischenbild_test.gd 2>&1 | grep -E "FALSCH|ZWISCHENBILD|SCRIPT ERROR"   # 399.1 Intro
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/kapitelende_537.gd 2>&1 | grep -E "FEHLER|KAPITELENDE|SCRIPT ERROR"   # 537 Kapitelende, Tempelszene, Morgen
timeout 120 ~/godot/godot --headless --path . -s res://tests/tasten_4161.gd 2>&1 | grep -E "FEHLER|TASTEN|SCRIPT ERROR"   # 416.1
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/rueckfrage_526.gd 2>&1 | grep -E "FEHLER|RUECKFRAGE|SCRIPT ERROR"   # 526 Rückfragen: daneben tippen, Zurück
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/protokoll_574.gd 2>&1 | tee p574.log | grep -E "FALSCH|PROTOKOLL574|SCRIPT ERROR"; [ "$(grep -cE "Lambda capture|buffer_size" p574.log || :)" -eq 0 ]   # 574 Fehler im Laufprotokoll; 1136: „! grep“ löst die Falle ERR nie aus
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/wischen_571.gd 2>&1 | grep -E "FALSCH|WISCHEN571|SCRIPT ERROR"   # 571 Wischen auf Knöpfen rollt jede Liste
timeout 300 ~/godot/godot --headless --path . -s res://tests/kamin_501.gd 2>&1 | grep -E "FEHLER|KAMIN501|Kamin|SCRIPT ERROR"   # 501 Flamme auf den Scheiten
timeout 120 ~/godot/godot --headless --path . -s res://tests/probeknoepfe_500.gd 2>&1 | grep -E "FEHLER|PROBEKNOEPFE500|SCRIPT ERROR"   # 500 Probeknoepfe weg
timeout 120 ~/godot/godot --headless --path . -s res://tests/lizenz_497.gd 2>&1 | grep -E "FEHLER|LIZENZ497|ENGINE|SCRIPT ERROR"   # 497 Lizenzen der Engine
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/lyra_635.gd 2>&1 | grep -E "^FALSCH|LYRA635|SCRIPT ERROR"   # 635 Lyra als Figur nach Aussehen (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/schlagbaum_636.gd 2>&1 | grep -E "^FALSCH|SCHLAGBAUM636|SCRIPT ERROR"   # 636 Schlagbaum auf mit Türgeräusch (Tom)
set -o pipefail; timeout 60 ~/godot/godot --headless --path . -s res://tests/truhe_632.gd 2>&1 | grep -E "^FALSCH|TRUHE632|SCRIPT ERROR"   # 632 Truhe cave_3 gibt die Waffe der Klasse (Tom)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/hoehle_492.gd 2>&1 | tee hoehle492.log | grep -E "^FEHLER|HOEHLE492|SCRIPT ERROR"; grep -q "^HOEHLE492 0 Fehler" hoehle492.log   # 492 Höhle begehbar, 1104 Kampf in der Höhle endet, die Welt ist wieder zu sehen (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/tragen_644a.gd 2>&1 | grep -E "^FALSCH|TRAGEN644A|SCRIPT ERROR"   # 644a.2 Mindeststufe, Gaben, Laden ohne Grundwert, Meldung (Spike)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/sperre_756.gd 2>&1 | grep -E "^FEHLER|SPERRE756|SCRIPT ERROR"   # 756 Sperre im Fenster, Güte und Zustand am Bild, Schlecht in vier Varianten (Spike)
timeout 120 ~/godot/godot --headless --path . -s res://tests/tresen_4167.gd 2>&1 | grep -E "FEHLER|TRESEN|SCRIPT ERROR"   # 416.7
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/wende_4168.gd 2>&1 | grep -E "FEHLER|WENDE|RUTSCHEN|ohne gebaute|SCRIPT ERROR"   # 416.8 Wenden mit Schritten
set -o pipefail; timeout 120 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/wendeschritt_10401.gd 2>&1 | grep -E "FEHLER|WENDESCHRITT|SCRIPT ERROR"   # 1040.1 Leute folgen dem gehenden Helden mit Wendeschritten (Spike)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/zoom_1118.gd 2>&1 | grep -E "^FEHLER|ZOOM1118|SCRIPT ERROR"   # 1118 Fingerzoom endet bei NAH, Held ganz im Bild
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/ausruestung_522.gd 2>&1 | grep -E "^(gut|FEHLER|AUSRUESTUNG522|ohne)|SCRIPT ERROR"   # 522 Figur nach Ausruestungswechsel
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/waffen_522.gd 2>&1 | grep -E "^FALSCH|^bekannt|WAFFEN522|SCRIPT ERROR"   # 522 jede baubare Waffe am Helden, Dolch nicht als Schild (Tom)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/waffe_948.gd 2>&1 | grep -E "^  |WAFFE948|SCRIPT ERROR"   # 948 B jede Klinge 3 cm an der Wurzel, 1 cm dick; Dolch in der Hand je Herkunft (Jerry)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/tasche_521.gd 2>&1 | grep -E "^(gut|FEHLER|TASCHE521)|SCRIPT ERROR"   # 521, 523 Ausruestungszeile wie alt
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/untersuchen_541.gd 2>&1 | grep -E "FEHLER|UNTERSUCHEN|SCRIPT ERROR"   # 541 Untersuchen, Angriff mit dem Knopf
timeout 120 ~/godot/godot --headless --path . -s res://tests/platzwechsel_4162.gd 2>&1 | grep -E "FEHLER|PLATZWECHSEL|SCRIPT ERROR"   # 416.2
set -o pipefail; timeout 600 ~/godot/godot --headless --path . -s res://tests/sprung_680.gd 2>&1 | grep -E "^FEHLER|^RUNDE|^WAISE|SPRUNG 680|SCRIPT ERROR"   # 680 Ortswechsel ohne Speicherzuwachs (Spike)
timeout 120 ~/godot/godot --headless --path . -s res://tests/ziege_4162.gd 2>&1 | grep -E "FEHLER|ZIEGE|^Seite|^Ziege|SCRIPT ERROR"   # 416.2 Ziege (146.5); 1079: Seiten und Schritte der Ziege ins Protokoll
timeout 120 ~/godot/godot --headless --path . -s res://tests/zeichen_425.gd 2>&1 | grep -E "FEHLER|ZEICHEN|SCRIPT ERROR"   # 425
timeout 120 ~/godot/godot --headless --path . -s res://tests/testmenue_mass_425.gd 2>&1 | grep -E "FEHLER|TESTMENUE|SCRIPT ERROR"   # 425 Befunde Testmenue
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/probekampf_1020.gd 2>&1 | grep -E "^FALSCH|PROBEKAMPF1020"   # 1020.2 B Probekampf-Baukasten, Nochmal, zurück ins Testmenü (Tuffy)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/einschuechtern_841.gd 2>&1 | grep -E "^FALSCH|EINSCHUECHTERN841|SCRIPT ERROR"   # 841 Goblin-Späher verjagen (Jerry)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/probekampf_1034.gd 2>&1 | grep -E "^FALSCH|PROBEKAMPF1034|SCRIPT ERROR"   # 1034 Spielheld oder Testheld, Söldnernamen, ohne Folgen (Tuffy)
timeout 120 ~/godot/godot --headless --path . -s res://tests/laden_4169.gd 2>&1 | grep -E "FEHLER|LADEN4169|SCRIPT ERROR"   # 416.9
timeout 120 ~/godot/godot --headless --path . -s res://tests/laden_503.gd 2>&1 | grep -E "FEHLER|LADEN503|SCRIPT ERROR"   # 503 Knopf und Rueckfrage wie alt
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/spielstaende_529.gd 2>&1 | grep -E "FEHLER|SPIELSTAENDE529|SCRIPT ERROR"   # 529 Heldenbild, Spielzeit, Ortszeit
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/spielstand_test.gd 2>&1 | grep -E "FEHLER|SPIELSTAND|870.8|SCRIPT ERROR"   # 399, 870.8 Spielstand Version 2, alter laedt nicht
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/ende_1021.gd 2>&1 | grep -E "FEHLER|ENDE1021|SCRIPT ERROR"   # 1021 Letztes Ende der App laut System
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/rast_557.gd 2>&1 | grep -E "FEHLER|RAST557|SCRIPT ERROR"   # 557 Stil B eingeschaltet, Rast als Rastfeld
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/laden_525.gd 2>&1 | grep -E "FEHLER|LADEN525|SCRIPT ERROR"   # 525 Brauen, Rueckkauf, Fleisch an der Theke
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/laden_582.gd 2>&1 | grep -E "FEHLER|LADEN582|SCRIPT ERROR"   # 582 Laden wie alt: Kurzangabe, Seltenheit, Platz, ▲/▼
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/held_karte_528.gd 2>&1 | grep -E "FEHLER|HELDKARTE528|SCRIPT ERROR"   # 528 Hoechststufe, Kartenzeichen, Auf der Karte
timeout 120 ~/godot/godot --headless --path . -s res://tests/schlagbaum_530.gd 2>&1 | tee schlagbaum530.log | grep -E "FEHLER|SCHLAGBAUM530|SCRIPT ERROR"; grep -q "^SCHLAGBAUM530 0 Fehler" schlagbaum530.log   # 530 Schlagbaum offen sichtbar
timeout 120 ~/godot/godot --headless --path . -s res://tests/dorf_sued_612.gd 2>&1 | tee dorfsued612.log | grep -E "FEHLER|DORFSUED612|SCRIPT ERROR"; grep -q "^DORFSUED612 0 Fehler" dorfsued612.log   # 612 Korn mit Tiefe, Heu, Beet bis zum Zaun
timeout 120 ~/godot/godot --headless --path . -s res://tests/menue_breite_581.gd 2>&1 | tee breite581.log | grep -E "FEHLER|MENUEBREITE581|SCRIPT ERROR"; grep -q "^MENUEBREITE581 0 Fehler" breite581.log   # 581 Ausruestung nicht breiter als der Schirm
timeout 120 ~/godot/godot --headless --path . -s res://tests/fertigkeiten_762.gd 2>&1 | tee fert762.log | grep -E "FEHLER|FERTIGKEITEN762|SCRIPT ERROR"; grep -q "^FERTIGKEITEN762 0 Fehler" fert762.log   # 762 Fertigkeiten nach BRS im Heldenreiter
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/doppeltipp_605.gd 2>&1 | grep -E "^FALSCH|DOPPELTIPP605|SCRIPT ERROR"   # 605, 617 ein Tipp loest einmal aus, ein Wisch nie
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/blende_619.gd 2>&1 | grep -E "^FALSCH|BLENDE619|SCRIPT ERROR"   # 619 der Tipp auf den Aktionsknopf beendet die Blende nicht
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/obergrenze_605.gd 2>&1 | grep -E "^FALSCH|OBERGRENZE605|SCRIPT ERROR"   # 605 Obergrenze auf leerem Feld
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/obergrenze_701.gd 2>&1 | grep -E "^FALSCH|OBERGRENZE701|SCRIPT ERROR"   # 701 Obergrenze einmal, nicht je Attribut (Tom)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/ring_vergleich_557.gd 2>&1 | grep -E "^FALSCH|RINGVERGLEICH557|SCRIPT ERROR"   # 557, 701 jede Aenderung eines Attributs sichtbar
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/finger_610.gd 2>&1 | grep -E "^FALSCH|FINGER610|SCRIPT ERROR"   # 610 Finger am Stab zucken nicht (Tom)
timeout 120 ~/godot/godot --headless --path . -s res://tests/fenster_519.gd 2>&1 | tee fenster519.log | grep -E "FEHLER|FENSTER519|SCRIPT ERROR"; grep -q "^FENSTER519 0 Fehler" fenster519.log   # 519 Gegenstandsfenster passt auf den Schirm
timeout 120 ~/godot/godot --headless --path . -s res://tests/funke_677.gd 2>&1 | tee funke677.log | grep -E "FEHLER|FUNKE677|SCRIPT ERROR"; grep -q "^FUNKE677 0 Fehler" funke677.log   # 677 Leuchtfunke über dem Kopf (Chef 08.11., 15:54)
timeout 120 ~/godot/godot --headless --path . -s res://tests/knopf_630.gd 2>&1 | tee knopf630.log | grep -E "FEHLER|KNOPF630|SCRIPT ERROR"; grep -q "^KNOPF630 0 Fehler" knopf630.log   # 630 „Abenteuer beginnen“ in einer Zeile (Chef 08.11., 15:11)
timeout 120 ~/godot/godot --headless --path . -s res://tests/gegenstand_524.gd 2>&1 | tee gegenstand524.log | grep -E "FEHLER|GEGENSTAND524|SCRIPT ERROR"; grep -q "^GEGENSTAND524 0 Fehler" gegenstand524.log   # 524 Inhalt wie GearDetails alt
timeout 120 ~/godot/godot --headless --path . -s res://tests/roben_524.gd 2>&1 | tee roben524.log | grep -E "FEHLER|ROBEN524|SCRIPT ERROR"; grep -q "^ROBEN524 0 Fehler" roben524.log   # 521, 523, 524 zwei Roben des Chefs: Vergleich, ◆, Wert, Klang
timeout 120 ~/godot/godot --headless --path . -s res://tests/groesse_520.gd 2>&1 | tee groesse520.log | grep -E "FEHLER|GROESSE520|SCRIPT ERROR"; grep -q "^GROESSE520 0 Fehler" groesse520.log   # 520 Held im Reiter Ausruestung so gross wie alt
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/klangschalter_489.gd 2>&1 | grep -E "FALSCH|KLANGSCHALTER489|SCRIPT ERROR"   # 489 Musik, Effekte im Hauptmenue
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/kampforte_493.gd 2>&1 | grep -E "FALSCH|KAMPFORTE493|Kampforte|SCRIPT ERROR"   # 493 Kampforte im Wald
timeout 200 ~/godot/godot --headless --path . -s res://tests/abstand_567.gd 2>&1 | tee abstand567.log | grep -E "FALSCH|ABSTAND567|SCRIPT ERROR"; grep -q "^ABSTAND567 0 Fehler" abstand567.log   # 567 Gegner im Kampfort nicht übereinander
timeout 120 ~/godot/godot --headless --path . -s res://tests/schatten_566.gd 2>&1 | tee schatten566.log | grep -E "FALSCH|SCHATTEN566|SCRIPT ERROR"; grep -q "^SCHATTEN566 0 Fehler" schatten566.log   # 566 im Schatten blass
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/gruppen_535.gd 2>&1 | grep -E "FEHLER|GRUPPEN_535|SCRIPT ERROR"   # 535 Ratten, Fledermäuse, Kobolde, Schamanen mit eigenen Regeln
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/faehigkeiten_534.gd 2>&1 | grep -E "FEHLER|FAEHIGKEITEN_534|SCRIPT ERROR"   # 534 Lebensraub, Schadensminderung, Unerbittlich, Einschüchtern
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/brs_470.gd 2>&1 | grep -E "FALSCH|BRS470|SCRIPT ERROR"   # 470 Erschaffung BRS 1.1
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/erklaerung_954.gd 2>&1 | grep -E "FALSCH|ERKLAERUNG954|SCRIPT ERROR"   # 954 Gedrückthalten erklärt in der Erschaffung
# 1122 (1109 D, Chef 13.11., 10:56): nur auf claude/build-…; ein Teamzweig hat älteren Code als die neueste Prüfliste von main (falsches Rot)
if [[ "$GITHUB_REF_NAME" == claude/build-* ]]; then set -o pipefail; timeout 180 ~/godot/godot --headless --path . -s res://tests/pruefliste_1020.gd 2>&1 | grep -E "FEHLER|PRUEFLISTE1020|SCRIPT ERROR"; else echo "PRUEFLISTE1020 aus (Teamzweig $GITHUB_REF_NAME, 1122)"; fi   # 1020.1 Prüfliste im Reiter „Test“
python3 ../tools/pruefliste.py --pruefe daten/pruefliste.json   # 1178 der Bau trägt seine gegengelesene Prüfliste ansehen/t<n> (Tom)
if [[ "$GITHUB_REF_NAME" == claude/build-* ]]; then set -o pipefail; timeout 240 ~/godot/godot --headless --path . -s res://tests/lage_1156.gd 2>&1 | grep -E "FEHLER|LAGE1156|SCRIPT ERROR"; else echo "LAGE1156 aus (Teamzweig $GITHUB_REF_NAME, 1122)"; fi   # 1156 Knopf „Lage herstellen“, jede Lage der Prüfliste herstellbar
timeout 120 ~/godot/godot --headless --path . -s res://tests/lage_modell_1180.gd 2>&1 | tee lagemodell1180.log | grep -E "FEHLER|^1180|LAGEMODELL1180|SCRIPT ERROR"; grep -q "^LAGEMODELL1180 gut" lagemodell1180.log   # 1180 Lage nur mit Gruppe, die ein Modell hat (Tom)
set -o pipefail; timeout 180 ~/godot/godot --headless --path . -s res://tests/breite_1027.gd 2>&1 | grep -E "FALSCH|BREITE1027|SCRIPT ERROR"   # 1027 jeder Reiter passt auf den Schirm
set -o pipefail; timeout 180 ~/godot/godot --headless --path . -s res://tests/rollstand_1030.gd 2>&1 | grep -E "FALSCH|ROLL1030|SCRIPT ERROR"   # 1030 Reiter „Test“ behält die Stelle, Prüfliste einklappbar
set -o pipefail; timeout 180 ~/godot/godot --headless --path . -s res://tests/zustaende_764.gd 2>&1 | grep -E "FEHLER|ZUSTAENDE764|SCRIPT ERROR"   # 764 Zustände im Heldenreiter mit Erklärung
set -o pipefail; timeout 180 ~/godot/godot --headless --path . -s res://tests/kasten_860.gd 2>&1 | grep -E "FEHLER|KASTEN860|SCRIPT ERROR"   # 860 Chronik und Kartenfilter ohne Kasten
set -o pipefail; timeout 200 ~/godot/godot --headless --path . -s res://tests/schnellstart_1020.gd 2>&1 | grep -E "FEHLER|SCHNELLSTART1020|SCRIPT ERROR"   # 1020.1 A Schnellstart, Lage merken/zurück
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/fortsetzen_1021.gd 2>&1 | grep -E "FEHLER|FORTSETZEN1021|SCRIPT ERROR"   # 1021 nach Ende im Hintergrund gleich weiter
timeout 120 ~/godot/godot --headless --path . -s res://tests/testmenue_470.gd 2>&1 | grep -E "FEHLER|TESTMENUE470"   # 470a B: Erschaffung BRS nur im Testmenue
timeout 180 ~/godot/godot --headless --path . -s res://tests/brs_held_834.gd 2>&1 | tee brs834.log | grep -E "FALSCH|BRS834|SCRIPT ERROR"; grep -q "^BRS834 0 Fehler" brs834.log   # 834 Testmenue: neues Spiel mit Held nach BRS
timeout 120 ~/godot/godot --headless --path . -s res://tests/testmenue_555.gd 2>&1 | tee testmenue555.log | grep -E "FEHLER|TESTMENUE555|SCRIPT ERROR"; grep -q "^TESTMENUE555 0 Fehler" testmenue555.log   # 555, 554 Testmenue wie alt und schneller
timeout 120 ~/godot/godot --headless --path . -s res://tests/notiz_550.gd 2>&1 | tee notiz550.log | grep -E "FEHLER|NOTIZ550|SCRIPT ERROR"; grep -q "^NOTIZ550 0 Fehler" notiz550.log   # 550 Notiz beim ersten Mal so gross wie danach
timeout 120 ~/godot/godot --headless --path . -s res://tests/uhr_licht_555.gd 2>&1 | tee uhrlicht555.log | grep -E "FEHLER|UHRLICHT555|SCRIPT ERROR"; grep -q "^UHRLICHT555 0 Fehler" uhrlicht555.log   # 555 Licht folgt der Uhr (Chef 17:20)
timeout 300 ~/godot/godot --headless --path . -s res://tests/tasche_532.gd 2>&1 | tee tasche532.log | grep -E "FEHLER|TASCHE532|SCRIPT ERROR"; grep -q "^TASCHE532 ok" tasche532.log   # 532 ganze Tasche im Kampf, rollbare Liste (t273.13)
timeout 120 ~/godot/godot --headless --path . --fixed-fps 30 -s res://tests/atem_4532.gd 2>&1 | grep -E "^(ok|FEHLER|ATEM)"   # 453.2 Atmen unterwegs
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/wildschwein_494.gd 2>&1 | grep -E "Wildschwein|WILDSCHWEIN|FEHLER|SCRIPT ERROR"   # 494 Wildschwein
set -o pipefail; timeout 400 ~/godot/godot --headless --path . -s res://tests/krogg_494.gd 2>&1 | grep -E "Krogg|KROGG|FEHLER|SCRIPT ERROR"   # 494 Krogg, Morwens Rauch
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/halt_872.gd 2>&1 | grep -E "^(gut|FALSCH)|HALT872|SCRIPT ERROR"   # 872 Klinge im Hiebplan nach Halt (Jerry)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/absicht_1049.gd 2>&1 | grep -E "^FALSCH|ABSICHT1049|SCRIPT ERROR"   # 1049 Absichten je Art aus werte.json gleich der alten Wahl (Jerry)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . -s res://tests/zweikampf_1025.gd 2>&1 | grep -E "^(ok|FALSCH)|ZWEIKAMPF1025|SCRIPT ERROR"   # 1025 ein Kampf zur Zeit, Kampfort danach abgebaut (Jerry)
set -o pipefail; timeout 600 ~/godot/godot --headless --path . -s res://tests/welt_548.gd 2>&1 | grep -E "^(gut|FEHLER)|WELT_548|SCRIPT ERROR"   # 548, 1025: Kampf aus der Welt, Bedienung; lief in keinem Bauablauf (Laufnachweis 1128 A)
set -o pipefail; timeout 400 ~/godot/godot --headless --path . -s res://tests/spinne_494.gd 2>&1 | grep -E "Spinne|SPINNE|FEHLER|SCRIPT ERROR"   # 494 Riesenspinne, drei Häute
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/skelett_506.gd 2>&1 | grep -E "Skelett 506|SKELETT506|FEHLER|RUHE|SCRIPT ERROR"   # 506 Skelette: Regeln, drei Kits; 1006: RUHE (Stellen der Schleife)
set -o pipefail; timeout 120 ~/godot/godot --headless --path . -s res://tests/versatz_1006.gd 2>&1 | grep -E "^(FEHLER|VERSATZ1006)|SCRIPT ERROR"   # 1006 Grundschleife nie im Gleichklang (ohne Kauf)
set -o pipefail; timeout 300 ~/godot/godot --headless --path . -s res://tests/untote_506.gd 2>&1 | grep -E "Untote 506|UNTOTE506|FEHLER|SCRIPT ERROR"   # 506 Wiedergänger, Grabhund: Regeln, Kits, Karte
set -o pipefail; timeout 200 ~/godot/godot --headless --path . -s res://tests/anmarsch_506_1.gd 2>&1 | tee anmarsch506.log | grep -E "Tempo|FALSCH|ANMARSCH506|SCRIPT ERROR"; grep -q "^ANMARSCH506 0 Fehler" anmarsch506.log   # 506.1 langsame Gegner näher am Helden
timeout 120 ~/godot/godot --headless --path . -s res://tests/varianten_504.gd 2>&1 | tee varianten504.log | grep -E "FEHLER|VARIANTEN504|SCRIPT ERROR"; grep -q "^VARIANTEN504 0 Fehler" varianten504.log   # 504.1 Gespraeche in Varianten
timeout 300 ~/godot/godot --headless --path . -s res://tests/wald_490.gd 2>&1 | tee wald490.log | grep -E "FEHLER|WALD490|SCRIPT ERROR"; grep -q "^WALD490 0 Fehler" wald490.log   # 490
timeout 120 ~/godot/godot --headless --path . -s res://tests/wenden_560.gd 2>&1 | tee wenden560.log | grep -E "FEHLER|WENDEN560|SCRIPT ERROR"; grep -q "^WENDEN560 0 Fehler" wenden560.log   # 560 Monster wenden mit Tritten
timeout 120 ~/godot/godot --headless --path . -s res://tests/gang_744.gd 2>&1 | tee gang744.log | grep -E "FEHLER|GANG744|SCRIPT ERROR"; grep -q "^GANG744 0 Fehler" gang744.log   # 744 A Bewegungsbaustein: Bogen, Verweilen, Ruhebewegung
timeout 120 ~/godot/godot --headless --path . -s res://tests/tritte_560.gd 2>&1 | tee tritte560.log | grep -E "FALSCH|TRITTE560|SCRIPT ERROR"; grep -q "^TRITTE560 gut" tritte560.log   # 560 Tritte auf der Karte nicht gebremst (Tom)
timeout 120 ~/godot/godot --headless --path . -s res://tests/position_518.gd 2>&1 | tee position518.log | grep -E "FEHLER|POSITION518|SCRIPT ERROR"; grep -q "^POSITION518 0 Fehler" position518.log   # 518 Shader setzen POSITION immer
timeout 300 ~/godot/godot --headless --path . -s res://tests/wald_491.gd 2>&1 | tee wald491.log | grep -E "FEHLER|WALD491|SCRIPT ERROR"; grep -q "^WALD491 0 Fehler" wald491.log   # 491
timeout 300 ~/godot/godot --headless --path . -s res://tests/rand_1022.gd 2>&1 | tee rand1022.log | grep -E "FEHLER|RAND1022|^  |SCRIPT ERROR"; grep -q "^RAND1022 0 Fehler" rand1022.log   # 1022 Kartenrand: Wald dicht, Wege enden im Wald, ins Dunkel
timeout 300 ~/godot/godot --headless --path . -s res://tests/nebel_505.gd 2>&1 | tee nebel505.log | grep -E "FEHLER|NEBEL505|SCRIPT ERROR"; grep -q "^NEBEL505 0 Fehler" nebel505.log   # 505
timeout 120 ~/godot/godot --headless --path . -s res://tests/kartennebel_505.gd 2>&1 | tee kartennebel505.log | grep -E "FEHLER|KARTENNEBEL505|SCRIPT ERROR"; grep -q "^KARTENNEBEL505 0 Fehler" kartennebel505.log   # 505 Karte im Menü
timeout 120 ~/godot/godot --headless --path . -s res://tests/rauch_1160.gd 2>&1 | tee rauch1160.log | grep -E "FEHLER|RAUCH1160|SCRIPT ERROR"; grep -q "^RAUCH1160 0 Fehler" rauch1160.log   # 1160 Rauch nach Niederlage gegen Krogg (Tom)
timeout 300 ~/godot/godot --headless --path . -s res://tests/tuer_495.gd 2>&1 | tee tuer495.log | grep -E "FEHLER|TUER495|SCRIPT ERROR"; grep -q "^TUER495 0 Fehler" tuer495.log   # 495 zweimal der Knopf an der Tuer
timeout 120 ~/godot/godot --headless --path . -s res://tests/tageslicht_1091.gd 2>&1 | tee tageslicht1091.log | grep -E "FEHLER|^1091|TAGESLICHT1091|SCRIPT ERROR"; grep -q "^TAGESLICHT1091 gut" tageslicht1091.log   # 1091 Tageslicht des Hoehlenausgangs reicht wie alt in den Gang (Tom)
timeout 120 ~/godot/godot --headless --path . -s res://tests/messen_1145.gd 2>&1 | tee messen1145.log | grep -E "FEHLER|^1145|MESSEN1145|SCRIPT ERROR"; grep -q "^MESSEN1145 gut" messen1145.log   # 1145 Testmenue: Tusche, Nebel, Schatten zum Messen aus und an (Tom)
timeout 120 ~/godot/godot --headless --path . -s res://tests/waffe_innen_1168.gd 2>&1 | tee waffeinnen1168.log | grep -E "FEHLER|^1168|WAFFEINNEN1168|SCRIPT ERROR"; grep -q "^WAFFEINNEN1168 gut" waffeinnen1168.log   # 1168 innen keine Waffe an der Figur (Tom)
timeout 120 ~/godot/godot --headless --path . -s res://tests/lyra_ketten_1144.gd 2>&1 | tee lyraketten1144.log | grep -E "FEHLER|LYRAKETTEN1144|SCRIPT ERROR"; grep -q "^LYRAKETTEN1144 0 Fehler" lyraketten1144.log   # 1144 Ketten: Klang und Lyra frei zur Zeile
fi
# 909: auf die Messungen nebenher warten, Ausgabe zeigen; rot wie eine eigene Zeile (wait in && || löst die Falle nicht aus)
while read pid n; do wait $pid && rc=0 || rc=$?; echo "── nebenher $n"; cat $NEBEN/$n.log; [ $rc -eq 0 ] || { echo "$STUFE tests/$n.gd: nebenher, Ende $rc" >> $ROT; echo "::error::918 rot ($STUFE) tests/$n.gd"; }; done < $NEBEN/pids
# 918: Ende; rot.txt geht mit den Bildern ins Artefakt (bornim-godot-bilder) und steht hier im Protokoll
trap - ERR
mkdir -p $GITHUB_WORKSPACE/bilder && cp $ROT $GITHUB_WORKSPACE/bilder/rot.txt
if [ -s $ROT ]; then echo "ROT: $(wc -l < $ROT) Zeilen"; cat $ROT; grep -q "^start " $ROT && echo "startrot" > $GITHUB_WORKSPACE/rot-stufe || echo "rot" > $GITHUB_WORKSPACE/rot-stufe; exit 1; fi
echo "ROT: keine"
