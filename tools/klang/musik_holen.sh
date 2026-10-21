#!/usr/bin/env bash
# Lädt die Musikstücke und Klangflächen für Thema 28 (alle CC0 1.0, Lizenz geprüft 11.10.2026; Quellen in tools/klang/QUELLEN.md).
# Aufruf: tools/klang/musik_holen.sh <leerer Ordner außerhalb des Repositorys>. Der Name beginnt mit der Lage (grund = Klangfläche Höhle).
set -euo pipefail
D="${1:?Zielordner fehlt}"; mkdir -p "$D"; cd "$D"
O=https://opengameart.org/sites/default/files
while read -r n u; do case "$u" in http*) ;; *) u="$O/$u";; esac; [ -s "$n" ] || { curl -sSfL -m 300 -A "Mozilla/5.0" -o "$n" "$u"; sleep 1; }; done <<'L'
titel_adventure_intro.wav Adventure%20Theme%20Intro.wav
sieg_heros_reprise.ogg hero_reprise.ogg
ende_new_sunrise.wav new_sunrise_V2_0.wav
dorf_minstrel_dance.mp3 Minstrel_Dance_0.mp3
dorf_lament.mp3 Lament_for_a_Warriors_Soul_REUPLOAD.mp3
dorf_small_fire.wav a_small_fire_will_do.wav
wald_beautiful_forest.ogg beautiful_forest_16bit_44.1khz_1.ogg
wald_dark_forest.mp3 GameMusic_ForestTheme_24_0.mp3
wald_dark_woods.ogg dark_woods_in_game.ogg
wald_adventurers_path.mp3 adventurers_path_0.mp3
wald_eternal_light.mp3 eternal_light_v2_0.mp3
hoehle_mysterious.wav Mysterious.wav
hoehle_night_of_the_streets.mp3 Night%20of%20the%20Streets_0.mp3
hoehle_mysterious_orchestral.ogg mystery.ogg
hoehle_dark_theme.wav darktheme_0.wav
hoehle_graveyard.mp3 Kokopelli%27s%20Graveyard.mp3
hoehle_dark_castle.wav dark_castle_-_part1.wav
hoehle_arcanum.mp3 arcanum_0.mp3
grund_dark_cavern.ogg dark_cavern_ambient_002.ogg
grund_deep_humidity.ogg deep-humidity.ogg
grund_dungeon_ambience.ogg dungeon002_0.ogg
grund_forgotten_tombs.mp3 Forgoten_tombs_1.mp3
grund_loopable_dungeon.ogg dungeon_ambient_1.ogg
grund_eternal_sleep.ogg 10_eternal_sleep.ogg
grund_fs_38963.mp3 https://cdn.freesound.org/previews/38/38963_107780-hq.mp3
grund_fs_460459.mp3 https://cdn.freesound.org/previews/460/460459_9395330-hq.mp3
grund_fs_516566.mp3 https://cdn.freesound.org/previews/516/516566_2247456-hq.mp3
grund_fs_530161.mp3 https://cdn.freesound.org/previews/530/530161_2683450-hq.mp3
kampf_evil_approach.wav Evil%20Approach.wav
kampf_determined_pursuit.wav determined_pursuit_loop.wav
kampf_corrupted_minds.flac corrupted_minds.flac
kampf_eclipse_legion.mp3 eclipse_legion_0.mp3
kampf_battlefield.wav the_battlefield.wav
kampf_devils_dome.wav the_march_of_devils_dome.wav
boss_fall_of_nightmares.wav Fall%20of%20Nightmares%20%5Borchestral%5D_mastered.wav
boss_fantasy_choir1.mp3 Fantasy%20Choir%201.mp3
boss_fantasy_choir2.mp3 Fantasy%20Choir%202.mp3
boss_ancient_legend.mp3 the_ancient_legend_2.mp3
L
echo "fertig: $D"
