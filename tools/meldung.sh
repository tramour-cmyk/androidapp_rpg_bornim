#!/usr/bin/env bash
# Meldung an den Nutzer über Telegram (81r): Telegram ist das Protokoll, jeder meldet selbst.
#   tools/meldung.sh <Name> "<Nummer> <Stand>"          lautlos (Arbeitsstand, auch nachts)
#   tools/meldung.sh --laut <Name> "<Nummer> <Stand>"   mit Ton und ⚠ (der Nutzer ist dran; nicht 22–7 Uhr)
# Form: „Name TT.MM. HH:MM: Inhalt“, eine Zeile, nur Nummern und Stichworte, nie Spieltexte.
# Schlüssel nur aus der Umgebungsvariable TELEGRAM_BOT_TOKEN, nie ins Repo oder in den Chat.
laut=0
[ "$1" = "--laut" ] && { laut=1; shift; }
name="$1"; text="$2"
if [ -z "$name" ] || [ -z "$text" ]; then echo "Aufruf: tools/meldung.sh [--laut] <Name> \"<Text>\"" >&2; exit 2; fi
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then echo "meldung: TELEGRAM_BOT_TOKEN fehlt in dieser Umgebung, Meldung nicht gesendet" >&2; exit 1; fi
zeit=$(TZ=Europe/Berlin date "+%d.%m. %H:%M"); stunde=$(TZ=Europe/Berlin date +%H)
if [ $laut = 1 ]; then
  text="⚠ $text"
  case $stunde in 22|23|0[0-6]) laut=0 ;; esac  # nachts nur lautlos
fi
still=true; [ $laut = 1 ] && still=false
antwort=$(curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=8965432899" --data-urlencode "disable_notification=$still" \
  --data-urlencode "text=$name $zeit: $text" 2>&1)
case "$antwort" in *'"ok":true'*) echo "meldung: gesendet" ;; *) echo "meldung: Fehler: ${antwort:0:200}" >&2; exit 1 ;; esac
