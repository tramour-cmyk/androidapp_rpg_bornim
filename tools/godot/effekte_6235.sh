#!/usr/bin/env bash
# 623.5 (Jerry, Chef 08.11., 13:14, „jetzt“ 13:48): Gratisproben REEBOO Labs (Combat VFX Mega, Stylized Projectiles, Weapon Trails,
# VFX Pack 3, Character Shaders; dazu Status Effects und Stylized VFX aus der Version stufe1) aus bornim-kaufmodelle in den Bau.
# Die Lizenzen verbieten die Weitergabe der Dateien: nur nach godot/addons (in godot/.gitignore), nie committen, nie als Artefakt.
# Aufruf: effekte_6235.sh <kauf> <godot/addons>; <kauf> ist der Klon von bornim-kaufmodelle (kauf_laden.sh). Die neun Proben liegen
# auf dessen Zweig claude/brave-faraday-9mxupv (Sokrates 07.11.), nicht auf main: holt sie von dort, wenn sie fehlen.
set -uo pipefail
K=${1:?Kauf fehlt} Z=${2:?Ziel fehlt}
[ -d "$K" ] || { echo "Effektproben: kein Kauf, ohne"; exit 0; }
if [ ! -d "$K/anhang/reeboo" ] && [ -d "$K/.git" ]; then
  git -C "$K" fetch -q --depth 1 origin claude/brave-faraday-9mxupv && git -C "$K" checkout -q FETCH_HEAD -- anhang/reeboo || echo "Effektproben: Zweig nicht geholt"
  git -C "$K" reset -q 2> /dev/null || true
fi
find "$K/anhang" -name '*free-sample*.zip' -o -name '*Free_Sample*.zip' 2> /dev/null | while read -r z; do [ -d "${z%.zip}" ] || unzip -q -o "$z" -d "${z%.zip}"; done
mkdir -p "$Z"
# je Ordner der Pakete (reeboo_vfx teilen sich Pack 3, Status Effects und Stylized VFX: gleicher Kern laut README, zusammenlegen)
for a in reeboo_combat reeboo_projectiles reeboo_trails reeboo_vfx character_shaders; do
  n=0
  while read -r d; do
    [ -n "$d" ] || continue
    mkdir -p "$Z/$a" && cp -r "$d/." "$Z/$a/" && n=$((n + 1))
  done < <(find "$K/anhang" -type d -name "$a" -path "*addons/$a" -not -path '*/demo*' 2> /dev/null | sort)
  echo "Effektproben: $a aus $n Paket(en)"
done
ls "$Z"
