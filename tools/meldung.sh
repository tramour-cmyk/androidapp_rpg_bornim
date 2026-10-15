#!/usr/bin/env bash
# Meldung an den Nutzer über Telegram (81r): Telegram ist das Protokoll, jeder meldet selbst.
#   tools/meldung.sh <Name> "<Nummer> <Stand>"          lautlos (Arbeitsstand, auch nachts)
#   tools/meldung.sh --laut <Name> "<Nummer> <Stand>"   mit Ton und ⚠ (der Nutzer ist dran; nicht 22–7 Uhr)
#   tools/meldung.sh --bild <datei> <Name> "<Text>"     Standbild mit der Zeile als Unterschrift (Telegram verkleinert)
#   tools/meldung.sh --datei <datei> <Name> "<Text>"    Bild in voller Auflösung als Datei (Pixelprüfung)
# Kostet in der Sitzung nichts: das Bild wird nur hochgeladen, nicht gelesen. Optionen kombinierbar, --laut zuerst.
# Form: „Name TT.MM. HH:MM: Inhalt“, eine Zeile, nur Nummern und Stichworte, nie Spieltexte.
# Schlüssel nur aus der Umgebungsvariable TELEGRAM_BOT_TOKEN, nie ins Repo oder in den Chat.
laut=0
bild=""; art=""
[ "$1" = "--laut" ] && { laut=1; shift; }
case "$1" in --bild) art=photo; bild="$2"; shift 2 ;; --datei) art=document; bild="$2"; shift 2 ;; esac
if [ -n "$art" ] && [ ! -f "$bild" ]; then echo "meldung: Bild $bild fehlt" >&2; exit 2; fi
name="$1"; text="$2"
if [ -z "$name" ] || [ -z "$text" ]; then echo "Aufruf: tools/meldung.sh [--laut] <Name> \"<Text>\"" >&2; exit 2; fi
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then echo "meldung: TELEGRAM_BOT_TOKEN fehlt in dieser Umgebung, Meldung nicht gesendet" >&2; exit 1; fi
zeit=$(TZ=Europe/Berlin date "+%d.%m. %H:%M"); stunde=$(TZ=Europe/Berlin date +%H)
if [ $laut = 1 ]; then
  text="⚠ $text"
  case $stunde in 22|23|0[0-6]) laut=0 ;; esac  # nachts nur lautlos
fi
still=true; [ $laut = 1 ] && still=false
zeile="$name $zeit: $text"
if [ -n "$art" ]; then
  methode=sendPhoto; [ $art = document ] && methode=sendDocument
  antwort=$(curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/$methode" \
    -F "chat_id=8965432899" -F "disable_notification=$still" -F "$art=@$bild" -F "caption=$zeile" 2>&1)
else
  antwort=$(curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=8965432899" --data-urlencode "disable_notification=$still" \
    --data-urlencode "text=$zeile" 2>&1)
fi
case "$antwort" in *'"ok":true'*) echo "meldung: gesendet" ;; *) echo "meldung: Fehler: ${antwort:0:200}" >&2; exit 1 ;; esac
