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
# Runde 2 (Welt, Zauber, Tränke, Umgebung)
for f in magical_1_0.ogg magical_2.ogg magical_3.ogg magical_4.ogg magical_5.ogg magical_6_0.ogg magical_7_0.ogg dark_magic.7z flame_0.ogg \
         water-splash-slime-sfx.zip qubodup-PowerDrain.7z healing.ogg forest_birds.7z birdchirping071414.wav cricketsounds090613.wav \
         fire-1.wav atmosbasement.mp3_.flac Creepychanting.zip; do
    get "$O/$f" "$f"
done
# Freesound: Vorschau (128 kbit/s) der CC0-Aufnahmen; der Server lehnt zu schnelle Abrufe ab, daher Pause
for p in 465/465697_9159316 558/558396_556505 558/558398_556505 696/696438_8711646 348/348022_6142149 349/349873_6142149 181/181563_1857065 \
         370/370938_6621799 522/522299_9084007; do
    f="fs_$(basename "$p" | cut -d_ -f1).mp3"
    [ -s "$f" ] || { curl -sSfL -m 120 -A "Mozilla/5.0" -o "$f" "https://cdn.freesound.org/previews/$p-hq.mp3"; sleep 3; }
done
# Runde 3 (24.8 Ortsklänge: Wind, Halle, Knarren, Herzschlag; Schänke aus Einzelklängen)
for f in "wind%20background%20noise%202.wav" park_ambience_wind.wav tree_creak.flac heartbeat_slow_0.wav heartbeat_fast_reverb.wav heartbeat.mp3_.flac; do
    get "$O/$f" "$(echo "$f" | sed 's/%20/ /g')"
done
# BigSoundBank (CC0): Becher, Einschenken, Wischen, Stuhl, Husten
for n in 3202 0606 0627 1204 1205 1721 1156 1933 0689 1104 0666 3053 0518 0488 2183 0207 1103 1345; do
    get "https://bigsoundbank.com/UPLOAD/mp3/$n.mp3" "bsb_$n.mp3"
done
# Runde 4 (27j Waldweiher): Frösche, Libellen
get "$O/croak_03.mp3" croak_03.mp3
for p in 710/710246_10954437 426/426462_3597414 240/240549_4337854 511/511326_562829; do
    f="fs_$(basename "$p" | cut -d_ -f1).mp3"
    [ -s "$f" ] || { curl -sSfL -m 300 -A "Mozilla/5.0" -o "$f" "https://cdn.freesound.org/previews/$p-hq.mp3"; sleep 3; }
done
# Runde 5 (83c Hühner): BigSoundBank (CC0)
for n in 1039 0975 1040 0453 0840 2891 2894 3202 0163 0137; do
    get "https://bigsoundbank.com/UPLOAD/mp3/$n.mp3" "bsb_$n.mp3"
done
# 84 Umweltklang: fernes Wolfsgeheul, Grollen im Berg (Freesound); Flügel und Scharren kleiner Vögel (BigSoundBank)
for p in 500/500646_339183 143/143568_2140699 158/158780_229952 389/389303_5486695 675/675736_2524442 381/381645_5486695; do
    f="fs_$(basename "$p" | cut -d_ -f1).mp3"
    [ -s "$f" ] || { curl -sSfL -m 300 -A "Mozilla/5.0" -o "$f" "https://cdn.freesound.org/previews/$p-hq.mp3"; sleep 3; }
done
for n in 2891 2894 0840 3202; do get "https://bigsoundbank.com/UPLOAD/mp3/$n.mp3" "bsb_$n.mp3"; done
# Runde 7 (D6.4 Fluss): Weichsel (OpenGameArt, CC0), Bäche (BigSoundBank, CC0)
get "$O/VistulaShort_0.mp3" VistulaShort_0.mp3
for n in 0864 0823; do
    get "https://bigsoundbank.com/UPLOAD/mp3/$n.mp3" "bsb_$n.mp3"
done
# Runde 8 (69c.1 Nacht im Intro): Glocken, Schmerzensschrei (BigSoundBank, CC0); Rufe aus dem Stimmenpaket oben
for n in 0830 0135 0829 2361; do
    get "https://bigsoundbank.com/UPLOAD/mp3/$n.mp3" "bsb_$n.mp3"
done
python3 -m pip -q install py7zr numpy scipy soundfile >/dev/null 2>&1 || true
for z in *.zip; do d="x_${z%.zip}"; [ -d "$d" ] || { mkdir -p "$d"; unzip -qo "$z" -d "$d"; }; done
for z in *.7z; do d="x_${z%.7z}"; [ -d "$d" ] || { mkdir -p "$d"; python3 -I -m py7zr x "$z" "$d"; }; done
echo "fertig: $D"
