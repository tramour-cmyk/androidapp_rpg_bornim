#!/usr/bin/env bash
# Lädt die Musikstücke für Thema 28 (alle CC0 1.0, OpenGameArt, Lizenz geprüft 11.10.2026; Quellen in tools/klang/QUELLEN.md).
# Aufruf: tools/klang/musik_holen.sh <leerer Ordner außerhalb des Repositorys>
set -euo pipefail
D="${1:?Zielordner fehlt}"; mkdir -p "$D"; cd "$D"
O=https://opengameart.org/sites/default/files
while read -r n u; do [ -s "$n" ] || curl -sSfL -m 300 -o "$n" "$O/$u"; done <<'L'
titel_adventure_intro.wav Adventure%20Theme%20Intro.wav
dorf_minstrel_dance.mp3 Minstrel_Dance_0.mp3
dorf_lament.mp3 Lament_for_a_Warriors_Soul_REUPLOAD.mp3
dorf_small_fire.wav a_small_fire_will_do.wav
wald_beautiful_forest.ogg beautiful_forest_16bit_44.1khz_1.ogg
hoehle_mysterious.wav Mysterious.wav
hoehle_night_of_the_streets.mp3 Night%20of%20the%20Streets_0.mp3
hoehle_grund_dark_cavern.ogg dark_cavern_ambient_002.ogg
hoehle_grund_deep_humidity.ogg deep-humidity.ogg
hoehle_grund_dungeon_ambience.ogg dungeon002_0.ogg
hoehle_grund_forgotten_tombs.mp3 Forgoten_tombs_1.mp3
kampf_evil_approach.wav Evil%20Approach.wav
boss_fall_of_nightmares.wav Fall%20of%20Nightmares%20%5Borchestral%5D_mastered.wav
sieg_heros_reprise.ogg hero_reprise.ogg
ende_new_sunrise.wav new_sunrise_V2_0.wav
kampf_determined_pursuit.wav determined_pursuit_loop.wav
kampf_great_labyrinth.ogg great_labyrinth_bpm160_0.ogg
wald_dark_forest.mp3 GameMusic_ForestTheme_24_0.mp3
L
echo "fertig: $D"
