#!/usr/bin/env bash
# 348.12e gekaufte Modelle holen: Rohdateien nur im privaten Repo bornim-kaufmodelle (348.12c a), nie in dieses
# oeffentliche Repo, nie als Artefakt. Aufruf: kauf_laden.sh <ziel>; Lesezugang in GH_TOKEN (Build: Geheimnis KAUF_TOKEN),
# ohne ihn nichts geholt, Ende 0. Groessere Dateien liegen als Anhang einer Version (Releases), Zip und Rar werden entpackt.
set -euo pipefail
K=${1:?Ziel fehlt} R=tramour-cmyk/bornim-kaufmodelle
[ -n "${GH_TOKEN:-}" ] || { echo "kein Zugang (GH_TOKEN), ohne Kaufmodelle"; exit 0; }
[ -d $K/.git ] || git clone -q --depth 1 https://tramour-cmyk:$GH_TOKEN@github.com/$R.git $K
for t in $(gh release list -R $R --json tagName -q '.[].tagName'); do
  gh release download $t -R $R -D $K/anhang/$t --skip-existing
done
if [ -d $K/anhang ]; then
  find $K/anhang -name '*.zip' | while read -r z; do [ -d "${z%.zip}" ] || unzip -q -o "$z" -d "${z%.zip}"; done
  # Sokrates 26.10.: Protofactor liefert .rar (Ratte, Version stufe1); 7z, sonst bsdtar oder unrar; ein Archiv, das keiner oeffnet, meldet sich
  find $K/anhang -name '*.rar' | while read -r z; do d="${z%.rar}"; [ -d "$d" ] && continue; mkdir -p "$d"
    7z x -y -bd -o"$d" "$z" > /dev/null 2>&1 || bsdtar -xf "$z" -C "$d" 2> /dev/null || unrar x -o+ -inul "$z" "$d/" \
      || { echo "nicht entpackt: ${z#$K/}"; rmdir "$d" 2> /dev/null || true; }
  done
fi
find $K -type f -not -path '*/.git/*' | sed "s|$K/||" | sort | head -200
