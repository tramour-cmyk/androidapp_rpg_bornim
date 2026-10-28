#!/usr/bin/env bash
# 348.12i (Chef 26.10., 19:41, „348.12i B“): gekaufte Modelle im APK nur verschluesselt (Anbieter: „Encryption would be best“).
# Aufruf: verschluesseln.sh <schluessel, 64 Hexzeichen> <datei>...; ersetzt jede Datei durch „BKV1“, 16 Byte IV, AES-256-CBC
# (PKCS7). Godot entschluesselt beim Laden (Gebiet.lade_glb, Schluessel.KAUF).
set -euo pipefail
k=${1:?Schluessel fehlt}; shift
[[ $k =~ ^[0-9a-f]{64}$ ]] || { echo "Schluessel: 64 Hexzeichen"; exit 1; }
for f in "$@"; do
  [ "$(head -c 4 "$f")" = BKV1 ] && { echo "schon verschluesselt: $f"; continue; }
  iv=$(openssl rand -hex 16)
  { printf BKV1; printf "$(sed 's/../\\x&/g' <<< "$iv")"; openssl enc -aes-256-cbc -K "$k" -iv "$iv" -in "$f"; } > "$f.tmp"
  mv "$f.tmp" "$f"
  echo "verschluesselt: $f ($(stat -c %s "$f") Byte)"
done
