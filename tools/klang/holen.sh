#!/usr/bin/env bash
# Lädt die CC0-Aufnahmen, aus denen tools/klang/rezepte.py die Klänge schneidet (Quellen: tools/klang/QUELLEN.md).
# Aufruf: tools/klang/holen.sh <leerer Ordner außerhalb des Repositorys>
set -euo pipefail
D="${1:?Zielordner fehlt}"; mkdir -p "$D"; cd "$D"
O=https://opengameart.org/sites/default/files
get() { [ -s "$2" ] || curl -sSfL -m 180 -o "$2" "$1"; }
get https://kenney.nl/media/pages/assets/rpg-audio/8e99002d76-1677590336/kenney_rpg-audio.zip kenney_rpg.zip
get https://kenney.nl/media/pages/assets/impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip kenney_impact.zip
for f in 100-CC0-SFX_0.zip 100-CC0-wood-metal-SFX.zip 80-CC0-RPG-SFX_0.zip sfx_breaking_and_falling.zip 80-CC0-creature-SFX_0.zip \
         qubodup-DoorSet.7z dog_0.7z dog-frieda-grunt-96khz-01.flac wet_towel_on_floor.7z coin_drop.ogg accessory.zip dog.7z \
         dog-growl.ogg goblins_0.zip "Voice%20Effects%20Zombie-Skeleton-Monster%20Human%20Male.zip" bones_rattle.zip; do
    get "$O/$f" "$(echo "$f" | sed 's/%20/_/g')"
done
python3 -m pip -q install py7zr numpy scipy soundfile >/dev/null 2>&1 || true
for z in *.zip; do d="x_${z%.zip}"; [ -d "$d" ] || { mkdir -p "$d"; unzip -qo "$z" -d "$d"; }; done
for z in *.7z; do d="x_${z%.7z}"; [ -d "$d" ] || { mkdir -p "$d"; python3 -I -m py7zr x "$z" "$d"; }; done
echo "fertig: $D"
