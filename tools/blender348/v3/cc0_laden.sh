#!/bin/bash
# 348.12: laedt die drei freien Quaternius-Pakete (CC0 1.0, Lizenzdatei je Paket) von itch.io fuer cc0.py.
# Aufruf: tools/blender348/v3/cc0_laden.sh <ordner>   (danach CC0=<ordner> fuer cc0.py; andere Pakete: PAKETE="<spiel> …")
set -e
O=${1:-$HOME/cc0}; mkdir -p "$O"
lade() {   # <spiel> : freier Download ohne Konto (wie der Knopf „No thanks, just take me to the downloads“)
  local B="https://quaternius.itch.io/$1" J; J=$(mktemp)
  local T; T=$(curl -sS -m 30 -c $J -b $J "$B" | grep -oE 'name="csrf_token" value="[^"]+"' | head -1 | sed 's/.*value="//;s/"$//')
  local DL; DL=$(curl -sS -m 30 -c $J -b $J -X POST --data-urlencode "csrf_token=$T" "$B/download_url" | python3 -c 'import json,sys;print(json.load(sys.stdin)["url"])')
  local ID
  for ID in $(curl -sS -m 30 -c $J -b $J "$DL" | grep -oE 'data-upload_id="[0-9]+"' | grep -oE '[0-9]+' | sort -u); do
    local U; U=$(curl -sS -m 30 -c $J -b $J -X POST --data-urlencode "csrf_token=$T" "$B/file/$ID?source=game_download" | python3 -c 'import json,sys;print(json.load(sys.stdin)["url"])')
    curl -sS -L -m 900 "$U" -o "$O/$1.zip"
    mkdir -p "$O/$1" && unzip -q -o "$O/$1.zip" -d "$O/$1" && rm "$O/$1.zip"
    grep -l "CC0 1.0" "$O/$1"/*/License*.txt > /dev/null || { echo "Lizenz nicht CC0: $1"; exit 1; }
  done
  rm -f $J
}
for p in ${PAKETE:-universal-base-characters modular-character-outfits-fantasy universal-animation-library}; do lade $p; done   # 376: PAKETE=medieval-village-megakit
echo "fertig: $O"
