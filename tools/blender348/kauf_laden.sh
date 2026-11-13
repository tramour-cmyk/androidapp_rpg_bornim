#!/usr/bin/env bash
# 348.12e gekaufte Modelle holen: Rohdateien nur im privaten Repo bornim-kaufmodelle (348.12c a), nie in dieses
# oeffentliche Repo, nie als Artefakt. Aufruf: kauf_laden.sh <ziel>; Lesezugang in GH_TOKEN (Build: Geheimnis KAUF_TOKEN),
# ohne ihn nichts geholt, Ende 0. Groessere Dateien liegen als Anhang einer Version (Releases), Zip und Rar werden entpackt.
set -euo pipefail
K=${1:?Ziel fehlt} R=tramour-cmyk/bornim-kaufmodelle
[ -n "${GH_TOKEN:-}" ] || { echo "kein Zugang (GH_TOKEN), ohne Kaufmodelle"; exit 0; }
[ -d $K/.git ] || git clone -q --depth 1 https://tramour-cmyk:$GH_TOKEN@github.com/$R.git $K
for t in $(gh release list -R $R --json tagName -q '.[].tagName'); do
  # 431 (Tom 01.11.): MUSTER="<glob> …" holt nur passende Anhänge (Probefilme brauchen nicht alle 1,5 GB)
  gh release download $t -R $R -D $K/anhang/$t --skip-existing $(for m in ${MUSTER:-}; do printf -- '-p %s ' "$m"; done) || [ -n "${MUSTER:-}" ]
done
if [ -d $K/anhang ]; then
  find $K/anhang -name '*.zip' | while read -r z; do [ -d "${z%.zip}" ] || unzip -q -o "$z" -d "${z%.zip}"; done
  # Sokrates 26.10.: Protofactor liefert .rar (Ratte, Version stufe1); 7z, sonst bsdtar oder unrar; ein Archiv, das keiner oeffnet, meldet sich.
  # Lauf 82: GiantRat.4.14.rar liess 7z abstuerzen, bsdtar scheiterte, unrar fehlt: zuerst unar (RAR5), auf dem Runner nachinstalliert
  if [ -n "$(find $K/anhang -name '*.rar' | head -1)" ] && ! { command -v unar && command -v unrar; } > /dev/null && command -v sudo > /dev/null; then
    # 595 (Lauf 352: unar und unrar fehlten danach, die Installation schlug still fehl): dreimal versuchen, sonst sagen
    for i in 1 2 3; do
      { sudo apt-get install -y -qq unar unrar-free || { sudo apt-get update -qq && sudo apt-get install -y -qq unar unrar-free; }; } > /dev/null 2>&1 && break
      echo "unar/unrar nicht installiert (Versuch $i)"; sleep 10
    done
  fi
  # 595 (Lauf 352: 7z stürzte mitten im Auspacken ab, die halbe Kopie blieb liegen, DARKNESS_SPIDER.FBX darin kaputt, Blender: „ASCII
  # FBX files are not supported“): vor jedem weiteren Versuch und am Ende ohne Erfolg die halbe Kopie weg
  find $K/anhang -name '*.rar' | while read -r z; do d="${z%.rar}"; [ -d "$d" ] && continue; mkdir -p "$d"
    # 494 (Jerry 03.11.): GIANT.SLUG.RAW.FILES.1.rar bricht unar ab (Ende 1, Grundfarbe zu 98 % geschrieben, Netz „Attempted to read more
    # data than was available“), unrar-free packt es ganz aus: halbe Dateien weg, dann unrar
    unar -q -f -D -o "$d" "$z" > /dev/null 2>&1 || { rm -rf "$d"; mkdir -p "$d"; unrar x -o+ -inul "$z" "$d/" > /dev/null 2>&1; } \
      || { rm -rf "$d"; mkdir -p "$d"; 7z x -y -bd -o"$d" "$z" > /dev/null 2>&1; } || { rm -rf "$d"; mkdir -p "$d"; bsdtar -xf "$z" -C "$d" 2> /dev/null; } \
      || { rm -rf "$d"; mkdir -p "$d"; unrar x -o+ -inul "$z" "$d/"; } \
      || { echo "nicht entpackt: ${z#$K/}"; rm -rf "$d"; }
  done
  # Chef 26.10.: Janpec liefert .unitypackage (tar.gz, je Ding ein Ordner <guid> mit asset und pathname); nach dem Rar, das selbst eines
  # enthalten kann. Ausgepackt unter <name>/ mit den Pfaden aus pathname, ohne .meta; Pfade, die aus dem Ziel fuehren, werden uebergangen.
  find $K/anhang -name '*.unitypackage' | while read -r z; do d="${z%.unitypackage}"; [ -d "$d" ] && continue
    python3 - "$z" "$d" << 'PY' || { echo "nicht entpackt: ${z#$K/}"; rm -rf "$d"; }
import os, sys, tarfile
z, d = sys.argv[1:3]; pfad, inhalt = {}, {}
with tarfile.open(z, 'r:*') as t:
    for m in t:
        teil = m.name.lstrip('./').split('/')
        if len(teil) != 2 or not m.isfile(): continue
        if teil[1] == 'pathname': pfad[teil[0]] = t.extractfile(m).read().decode('utf-8', 'replace').splitlines()[0].strip()
        elif teil[1] == 'asset': inhalt[teil[0]] = t.extractfile(m).read()
n = 0
for g, b in inhalt.items():
    p = os.path.normpath(pfad.get(g, g))
    if p.startswith(('..', '/')): continue
    os.makedirs(os.path.dirname(os.path.join(d, p)) or d, exist_ok=True); open(os.path.join(d, p), 'wb').write(b); n += 1
print('unitypackage %s: %d Dateien' % (os.path.basename(z), n))
PY
  done
fi
find $K -type f -not -path '*/.git/*' | sed "s|$K/||" | sort | sed -n 1,200p  # Lauf 95: head schloss die Leitung, sort endete mit 2
