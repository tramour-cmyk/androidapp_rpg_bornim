#!/bin/bash
# 348.9 (Diogenes): Vergleichsblatt vor dem Chef zur Messung ablegen, ohne Telegram.
# Aufruf: bash tools/vorab.sh <bild> <Vorgang-Runde, z. B. 348.6-r11> [weitere Bilder …]
# Legt jedes Bild im Zweig „bilder“ unter pruefung/<Vorgang-Runde>[-n].<endung> ab (wie meldung.sh, 363) und druckt die Pfade.
set -e
[ $# -ge 2 ] || { echo "Aufruf: bash tools/vorab.sh <bild> <Vorgang-Runde> [weitere Bilder …]" >&2; exit 2; }
erst="$1"; marke="$2"; shift 2; bilder=("$erst" "$@")
repo="$(git rev-parse --show-toplevel)"
for versuch in 1 2 3; do
  eltern=""; git -C "$repo" fetch -q origin bilder 2>/dev/null && eltern=$(git -C "$repo" rev-parse FETCH_HEAD)
  idx=$(mktemp); rm -f "$idx"; pfade=()
  [ -n "$eltern" ] && GIT_INDEX_FILE=$idx git -C "$repo" read-tree "$eltern"
  n=0
  for b in "${bilder[@]}"; do
    [ -f "$b" ] || { echo "vorab: $b fehlt" >&2; exit 2; }
    s=""; [ $n -gt 0 ] && s="-$n"; n=$((n + 1))
    p="pruefung/$marke$s.${b##*.}"; pfade+=("$p")
    GIT_INDEX_FILE=$idx git -C "$repo" update-index --add --cacheinfo "100644,$(git -C "$repo" hash-object -w "$b"),$p"
  done
  baum=$(GIT_INDEX_FILE=$idx git -C "$repo" write-tree); rm -f "$idx"
  neu=$(git -C "$repo" commit-tree "$baum" ${eltern:+-p "$eltern"} -m "Vorab $marke")
  if git -C "$repo" push -q origin "$neu:refs/heads/bilder" 2>/dev/null; then printf '%s\n' "${pfade[@]}"; exit 0; fi
  sleep $((versuch * 2))
done
echo "vorab: Ablage fehlgeschlagen" >&2; exit 1
