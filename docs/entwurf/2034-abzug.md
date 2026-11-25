# 2034 Teil 0: Abzug der MakeHuman-Stücke (Liste)

Vorgang 2034 Teil 0 (Chef 25.11., 17:27; Sokrates 17:29). Erzeugt von `tools/godot/abzug_2034_liste.py` aus `tools/blender348/v3/abzug_mh.py` (Stand 666fc20ce). Pakete neu geladen von `files.makehumancommunity.org` (25.11., 18:12–18:21, HTTP 200; fünf CC-BY-Pakete heißen dort `*_cc-by.zip`). Stücke je Paket: alle `.mhclo` (M1 nur `hair/`), Häute alle `.mhmat` unter `skins/`. Dreiecke: Flächen der `.obj` (n-Eck = n−2), nicht ausgedünnt; Bild: Größe des `diffuseTexture`.

**F6 ✗ Sichtung:** nur, wenn ein in der Sichtung mit ✗ genanntes Wort in Name, Ordner oder Paketbeschreibung steht (Suchwörter in `abzug_2034_liste.py`); nicht gezeichnet, der Chef kann nachfordern. Alles andere ist gezeichnet, auch wenn die Sichtung das Paket „meist modern“ nannte.

**Lizenz:** Spalte 1 = Paketseite (maßgeblich, LISTE-QUELLEN.md); „AGPL3“ im Kopf der .mhclo ist die MakeClothes-Vorgabe, „AGPLv3“ im Kopf der .mhmat die Materialvorlage (LISTE-QUELLEN.md). NC an irgendeiner Stelle: nie gezeigt.

## Summe je Paket gegen die Sichtung

| Nr. | Paket | Sichtung Stück | gefunden | gezeichnet | nicht gezeichnet |
|---|---|---|---|---|---|
| M1 | makehuman_system_assets | 9 (Haare) | 10 | 10 | 0 |
| M15 | skins01 | 23 | 23 | 23 | 0 |
| M16 | skins02 | 13 | 13 | 13 | 0 |
| M17 | skins03 | 20 | 20 | 13 | 7 |
| M20 | bodyparts05 | 5 | 5 | 5 | 0 |
| M21 | dress01 | 13 | 13 | 12 | 1 |
| M26 | gloves01 | 9 | 9 | 4 | 5 |
| M27 | hair01 | 25 | 25 | 16 | 9 |
| M29 | hats02 | 6 | 6 | 4 | 2 |
| M31 | pants01 | 4 | 4 | 3 | 1 |
| M34 | skirts01 | 6 | 6 | 3 | 3 |
| M36 | suits02 | 21 | 21 | 11 | 10 |
| M41 | bodyparts06 | 4 | 4 | 4 | 0 |
| M42 | dress02 | 24 | 24 | 24 | 0 |
| M43 | dress03 | 19 | 19 | 19 | 0 |
| M47 | hats03 | 19 | 19 | 17 | 2 |
| M48 | hats04 | 8 | 8 | 7 | 1 |
| M49 | hair02 | 21 | 21 | 19 | 2 |
| M50 | hair03 | 14 | 14 | 14 | 0 |
| M51 | masks02 | 4 | 4 | 2 | 2 |
| M54 | shirts02 | 13 | 13 | 11 | 2 |
| M57 | shoes03 | 12 | 12 | 9 | 3 |
| **Summe** | | 292 | 293 | 243 | 50 |

## Signatur-Probe (vorn, Spiel-Shader)

- **M29-04**: Messung (vorn): Umriss 5042 px, davon 74 % mit Tusche; Kanten innen 4231 px Tusche; Tonstufen 3 (Helligkeit 0.39, 0.41, 0.53); Lichtstufen weiß 0.85, 0.93, 1.00; Stufen gegen Bild 0.39 (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel 0.729; Pixel über Glanzgrenze (heller als weißes mattes Stück) 0
- **M27-09**: Messung (vorn): Umriss 7272 px, davon 68 % mit Tusche; Kanten innen 2172 px Tusche; Tonstufen 3 (Helligkeit 0.44, 0.52, 0.56); Lichtstufen weiß 0.85, 0.93, 0.99; Stufen gegen Bild 0.31 (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel 1.000; Pixel über Glanzgrenze (heller als weißes mattes Stück) 0
- **M27-05**: Messung (vorn): Umriss 8009 px, davon 65 % mit Tusche; Kanten innen 5134 px Tusche; Tonstufen 3 (Helligkeit 0.41, 0.42, 0.49); Lichtstufen weiß 0.85, 0.93, 0.99; Stufen gegen Bild 0.14 (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel 0.720; Pixel über Glanzgrenze (heller als weißes mattes Stück) 0
- **M36-05**: Messung (vorn): Umriss 5962 px, davon 55 % mit Tusche; Kanten innen 480 px Tusche; Tonstufen 3 (Helligkeit 0.09, 0.10, 0.14); Lichtstufen weiß 0.85, 0.93, 0.99; Stufen gegen Bild 0.44 (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel 0.577; Pixel über Glanzgrenze (heller als weißes mattes Stück) 0
- **M36-06**: Messung (vorn): Umriss 4475 px, davon 46 % mit Tusche; Kanten innen 359 px Tusche; Tonstufen 3 (Helligkeit 0.06, 0.08, 0.11); Lichtstufen weiß 0.85, 0.93, 0.99; Stufen gegen Bild 0.92 (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel 0.287; Pixel über Glanzgrenze (heller als weißes mattes Stück) 0
- **M57-09**: Messung (vorn): Umriss 5230 px, davon 54 % mit Tusche; Kanten innen 29 px Tusche; Tonstufen 3 (Helligkeit 0.11, 0.13, 0.16); Lichtstufen weiß 0.85, 0.93, 1.00; Stufen gegen Bild 0.77 (kleinster Stufenabstand / Streuung des Bildes); hellster Pixel 0.484; Pixel über Glanzgrenze (heller als weißes mattes Stück) 0

## Stücke

| Nummer | Name | Paket | Art | Lizenz (Seite; Kopf; Paketdatei) | Dreiecke | Bild px | F6 Sichtung | gezeichnet |
|---|---|---|---|---|---|---|---|---|
| M1-01 | afro01 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 2192 | 2048x2048 | – | ja |
| M1-02 | bob01 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 8474 | 2048x2048 | – | ja |
| M1-03 | bob02 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 2248 | 2048x2048 | – | ja |
| M1-04 | Braid01 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 5518 | 2048x2048 | – | ja |
| M1-05 | long01 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 4108 | 2048x2048 | – | ja |
| M1-06 | ponytail01 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 5352 | 2048x2048 | – | ja |
| M1-07 | short01 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 3678 | 2048x2048 | – | ja |
| M1-08 | short02 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 3344 | 2048x2048 | – | ja |
| M1-09 | short03 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 1922 | 2048x2048 | – | ja |
| M1-10 | short04 | makehuman_system_assets | Haar | CC0; Kopf –; Paketdatei CC0 | 1050 | 2048x2048 | – | ja |
| M15-01 | skin_texture | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-02 | Grey Skinned Person | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-03 | young_african_female | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-04 | summerglow | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-05 | summerglow | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-06 | darthfurby_caucasian_female | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-07 | RedHeadSkin | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-08 | Zoey Skin | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-09 | middleage_eurasian_female | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-10 | old_eurasian_female | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-11 | young_eurasian_female | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-12 | young_caucasian_female_genitals | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-13 | creamy_female | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-14 | Alana_Caucasian_Female_with_Genitals_skin | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-15 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-16 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-17 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-18 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-19 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-20 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-21 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-22 | light_skin_makeupMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M15-23 | lightfemaleskinMaterial | skins01 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-01 | Jartur_mid_old_Slavic_Male_with_Genitals_and_Beard_lsdif_lighter | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-02 | Jartur_old_Slavic_Male_with_Genitals_and_beard_lsdif | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-03 | Caucasion_TatooedMale_Skin_Diffuse | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-04 | aksel_skin | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-05 | skin_male_african_middleage | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-06 | old_eurasian_male | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-07 | viking_male | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-08 | lightskinmaleMaterial | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-09 | lightskinmaleMaterial | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-10 | lightskinmaleMaterial | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-11 | lightskinmaleMaterial | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-12 | lightskinmaleMaterial | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M16-13 | lightskinmaleMaterial | skins02 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-01 | Grey Skinned Person | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | Alien ✗ | nein: ✗ Sichtung (Alien) |
| M17-02 | elfskinsohlen | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-03 | skin_male_african_middleage | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-04 | material.001Material | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 4096x4096 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-05 | material.001Material | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | Tigra ✗ | nein: ✗ Sichtung (Tigra) |
| M17-06 | material.001Material | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | Tigra ✗ | nein: ✗ Sichtung (Tigra) |
| M17-07 | annotated_skin | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 4096x4096 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-08 | ZombieMaterial | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-09 | BlueLeopardSkin | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 4050x4050 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-10 | MyCoolSkin | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-11 | material | skins03 | Haut | CC0; Kopf CC0; Paketdatei CC0 | – | 4096x4096 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-12 | oRKSKIN | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-13 | Gray_Alien_Armor_skin_001 | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | Alien ✗ | nein: ✗ Sichtung (Alien) |
| M17-14 | Green_Alien_skin | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | Alien ✗ | nein: ✗ Sichtung (Alien) |
| M17-15 | Green_Alien_skin_002 | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | Alien ✗ | nein: ✗ Sichtung (Alien) |
| M17-16 | old_caucasian_male_detailed | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | Flagge ✗ | nein: ✗ Sichtung (Flagge) |
| M17-17 | BlackKameri | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-18 | middleage_african_female_special_suit_green | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-19 | young_asian_female_body_suit_gold | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M17-20 | young_asian_female_special_suit_red | skins03 | Haut | CC0; Kopf –; Paketdatei CC0 | – | 2048x2048 | – | ja: Hautbild ohne Körper, Weg H erst 2031 |
| M20-01 | faun_beard | bodyparts05 | Bart | CC0; Kopf CC-0; Paketdatei CC0 | 10432 | 2048x2048 | – | ja |
| M20-02 | Beard_Sigmund | bodyparts05 | Bart | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 878 | 1024x1024 | – | ja |
| M20-03 | BeardViking | bodyparts05 | Bart | CC0; Kopf CC0; Paketdatei CC0 | 5682 | 1024x1024 | – | ja |
| M20-04 | MoustacheViking | bodyparts05 | Bart | CC0; Kopf CC0; Paketdatei CC0 | 1364 | 512x512 | – | ja |
| M20-05 | Scruffy_Beard | bodyparts05 | Bart | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 2760 | 1024x1024 | – | ja |
| M21-01 | Flapper_Dress_1 | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 12846 | 2048x2048 | – | ja |
| M21-02 | F_Kimono | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 6922 | 2048x2048 | – | ja |
| M21-03 | Dress_Bodice_Ruffle_Skirt | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 8840 | 2048x2048 | – | ja |
| M21-04 | Dress_Camisole_Full_Skirt | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 10792 | 2048x2048 | – | ja |
| M21-05 | Dress_Cut_Outs | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 6156 | 2048x2048 | – | ja |
| M21-06 | DressTierSkirt | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 18896 | 2040x2048 | – | ja |
| M21-07 | Dress_Knee_Halter | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 3936 | 2048x2048 | – | ja |
| M21-08 | Dress_Midi_Halter | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 5184 | 2048x2048 | – | ja |
| M21-09 | Dress_Long_Fluted_Skirt | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 6432 | 2048x2048 | – | ja |
| M21-10 | Dress_Keyhole_Neck | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 17888 | 1024x1024 | – | ja |
| M21-11 | Dress_Shift | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 13568 | 2048x2048 | – | ja |
| M21-12 | Dress_Strapless_Ruffle_Top | dress01 | Kleid | CC0; Kopf CC0; Paketdatei CC0 | 10336 | 2048x2048 | Blumen ✗ | nein: ✗ Sichtung (Blumen) |
| M21-13 | Mycenaean_Tunic | dress01 | Kleid | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 2660 | 1024x1024 | – | ja |
| M26-01 | hero-heroine_gloves_1 | gloves01 | Handschuhe | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 4528 | 2048x2048 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M26-02 | hero-heroine_gloves_2 | gloves01 | Handschuhe | CC0; Kopf CC-0; Paketdatei CC0 | 14464 | 1024x1024 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M26-03 | hero-heroine_gloves_3 | gloves01 | Handschuhe | CC0; Kopf CC-0; Paketdatei CC0 | 14536 | 1024x1024 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M26-04 | hero-heroine_gloves_4 | gloves01 | Handschuhe | CC0; Kopf CC-0; Paketdatei CC0 | 16544 | 1024x1024 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M26-05 | hero-heroine_gloves_5 | gloves01 | Handschuhe | CC0; Kopf CC-0; Paketdatei CC0 | 5212 | 1024x1024 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M26-06 | mma_gloves | gloves01 | Handschuhe | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 4392 | 1024x1024 | – | ja |
| M26-07 | Gloves_Long | gloves01 | Handschuhe | CC0; Kopf CC0; Paketdatei CC0 | 6864 | 1024x1024 | – | ja |
| M26-08 | Gloves_Medium | gloves01 | Handschuhe | CC0; Kopf CC0; Paketdatei CC0 | 5744 | 1024x1024 | – | ja |
| M26-09 | Gloves_Hand | gloves01 | Handschuhe | CC0; Kopf CC0; Paketdatei CC0 | 4544 | 1024x1024 | – | ja |
| M27-01 | shaggy_green | hair01 | Haar | CC0; Kopf –; Paketdatei CC0 | 1284 | 512x512 | – | ja |
| M27-02 | short_messy | hair01 | Haar | CC0; Kopf –; Paketdatei CC0 | 1092 | 512x512 | – | ja |
| M27-03 | straight_bangs | hair01 | Haar | CC0; Kopf –; Paketdatei CC0 | 1128 | 512x512 | – | ja |
| M27-04 | strawberry_cloud | hair01 | Haar | CC0; Kopf –; Paketdatei CC0 | 576 | 512x512 | Pink ✗ | nein: ✗ Sichtung (Pink) |
| M27-05 | fhair01 | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 4228 | 2048x2048 | – | ja |
| M27-06 | mhair02 | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 3460 | 2048x2048 | – | ja |
| M27-07 | hair_05 | hair01 | Haar | CC0; Kopf CC-0; Paketdatei CC0 | 4948 | 1024x1024 | – | ja |
| M27-08 | hair_06 | hair01 | Haar | CC0; Kopf CC-0; Paketdatei CC0 | 14688 | 1024x1024 | – | ja |
| M27-09 | double_mhbraid | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 9866 | 2048x2048 | – | ja |
| M27-10 | frenchbraid1mh01 | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 8152 | 2048x2048 | – | ja |
| M27-11 | rev_fr_braidbun1 | hair01 | Haar | CC0; Kopf CC_by; Paketdatei CC0 | 7622 | 2048x2048 | – | ja |
| M27-12 | unkempt_mhbraidfr | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 8200 | 2048x2048 | – | ja |
| M27-13 | hair1 | hair01 | Haar | CC0; Kopf –; Paketdatei CC0 | 836 | 512x1024 | – | ja |
| M27-14 | animehair | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 91392 | 1024x1024 | Anime ✗ | nein: ✗ Sichtung (Anime) |
| M27-15 | LITTLERIGHT_hair_BobCut | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 2692 | 1024x1024 | Bob ✗ | nein: ✗ Sichtung (Bob) |
| M27-16 | o4saken_long01 | hair01 | Haar | CC0; Kopf CC BY 4.0; Paketdatei CC0 | 13268 | 2048x2048 | – | ja |
| M27-17 | Hair_bun_brown | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 4432 | 2048x2048 | – | ja |
| M27-18 | blondwithheadband | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 2054 | 2048x2048 | – | ja |
| M27-19 | junglebookhair | hair01 | Haar | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 8576 | 2048x2048 | – | ja |
| M27-20 | Bob_Blunt | hair01 | Haar | CC0; Kopf CC0; Paketdatei CC0 | 2858 | 3600x3600 | Bob ✗ | nein: ✗ Sichtung (Bob) |
| M27-21 | Bob_Blunt_Bangs | hair01 | Haar | CC0; Kopf CC0; Paketdatei CC0 | 4976 | 3600x3600 | Bob ✗ | nein: ✗ Sichtung (Bob) |
| M27-22 | Bob_Curled_Under | hair01 | Haar | CC0; Kopf CC0; Paketdatei CC0 | 2852 | 3600x3600 | Bob ✗ | nein: ✗ Sichtung (Bob) |
| M27-23 | Bob_Curled_Under_Bangs | hair01 | Haar | CC0; Kopf CC0; Paketdatei CC0 | 4976 | 3600x3600 | Bob ✗ | nein: ✗ Sichtung (Bob) |
| M27-24 | Bob_Inverted | hair01 | Haar | CC0; Kopf CC0; Paketdatei CC0 | 2856 | 3600x3600 | Bob ✗ | nein: ✗ Sichtung (Bob) |
| M27-25 | Bob_Inverted_bangs | hair01 | Haar | CC0; Kopf CC0; Paketdatei CC0 | 4996 | 3600x3600 | Bob ✗ | nein: ✗ Sichtung (Bob) |
| M29-01 | motorcyclehelmet | hats02 | Helm | CC0; Kopf creative commons zero (public domain); Paketdatei CC0 | 44608 | 1024x1024 | Motorrad ✗ | nein: ✗ Sichtung (Motorrad) |
| M29-02 | skull_helmet | hats02 | Helm | CC0; Kopf CC-0; Paketdatei CC0 | 8504 | 2048x2048 | – | ja |
| M29-03 | warrior_helmet | hats02 | Helm | CC0; Kopf CC-0; Paketdatei CC0 | 2712 | 2048x2048 | – | ja |
| M29-04 | Corinthian_helmet | hats02 | Helm | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 296 | 1024x1024 | – | ja |
| M29-05 | casco_templario | hats02 | Helm | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 6420 | 1600x1100 | – | ja |
| M29-06 | M1Helmet | hats02 | Helm | CC0; Kopf CC0; Paketdatei CC0 | 72292 | 4096x4096 | M1 ✗ | nein: ✗ Sichtung (M1) |
| M31-01 | cargo_pants | pants01 | Hose | CC0; Kopf –; Paketdatei CC0 | 392 | 2048x2048 | – | ja |
| M31-02 | jean_shorts | pants01 | Hose | CC0; Kopf –; Paketdatei CC0 | 500 | 2048x2048 | Jeans ✗ | nein: ✗ Sichtung (Jeans) |
| M31-03 | Pants_Harem | pants01 | Hose | CC0; Kopf CC0; Paketdatei CC0 | 10912 | 2048x2048 | – | ja |
| M31-04 | Pants_Wool | pants01 | Hose | CC0; Kopf CC0; Paketdatei CC0 | 2674 | 2048x2048 | – | ja |
| M34-01 | Mini_Skirt_01 | skirts01 | Rock | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 1720 | 2048x2048 | Mini ✗ | nein: ✗ Sichtung (Mini) |
| M34-02 | Mini_Skirt_02 | skirts01 | Rock | CC0; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC0 | 2600 | 2048x2048 | Mini ✗ | nein: ✗ Sichtung (Mini) |
| M34-03 | Skirt_Full_Long | skirts01 | Rock | CC0; Kopf CC0; Paketdatei CC0 | 5848 | 2048x2048 | – | ja |
| M34-04 | Skirt_Full_Lace_Ruffle | skirts01 | Rock | CC0; Kopf CC0; Paketdatei CC0 | 5576 | 2048x2048 | – | ja |
| M34-05 | Tier_Skirt_Mini | skirts01 | Rock | CC0; Kopf CC0; Paketdatei CC0 | 10656 | 2048x2048 | Mini ✗ | nein: ✗ Sichtung (Mini) |
| M34-06 | Tier_Skirt | skirts01 | Rock | CC0; Kopf CC0; Paketdatei CC0 | 12960 | 2048x2048 | – | ja |
| M36-01 | hero_suit_1 | suits02 | Ganzanzug | CC0; Kopf CC-0; Paketdatei CC0 | 15460 | 4096x4096 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M36-02 | hero_suit_2 | suits02 | Ganzanzug | CC0; Kopf CC-0; Paketdatei CC0 | 11316 | 1024x1024 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M36-03 | hero_suit_3 | suits02 | Ganzanzug | CC0; Kopf CC-0; Paketdatei CC0 | 29244 | 4096x4096 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M36-04 | heroine_suit_2 | suits02 | Ganzanzug | CC0; Kopf CC-0; Paketdatei CC0 | 14204 | 2048x2048 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M36-05 | Monks Robe | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 19820 | 4096x4096 | – | ja |
| M36-06 | Monks Hood | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 9008 | 4096x4096 | – | ja |
| M36-07 | Monks Hood Down | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 9010 | 4096x4096 | – | ja |
| M36-08 | Monks Hood Off | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 9054 | 4096x4096 | – | ja |
| M36-09 | Rei_Ayanami | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 11368 | 4096x4096 | – | ja |
| M36-10 | Yoko_Tsuno | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 5348 | 4096x4096 | – | ja |
| M36-11 | Cyborg_suit | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 2380 | 4096x4096 | Sci-Fi ✗ | nein: ✗ Sichtung (Sci-Fi) |
| M36-12 | MC-BodySuit-2021 | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 55352 | 4096x4096 | – | ja |
| M36-13 | MC-SciFi-Armor_Guardian | suits02 | Ganzanzug | CC0; Kopf –; Paketdatei CC0 | 18020 | 4096x4096 | Sci-Fi ✗ | nein: ✗ Sichtung (Sci-Fi) |
| M36-14 | MC-SciFi-Armor_Helios | suits02 | Ganzanzug | CC0; Kopf –; Paketdatei CC0 | 142468 | 4096x4096 | Sci-Fi ✗ | nein: ✗ Sichtung (Sci-Fi) |
| M36-15 | MC-SciFi-Armor_Jupiter7 | suits02 | Ganzanzug | CC0; Kopf –; Paketdatei CC0 | 26598 | 4096x4096 | Sci-Fi ✗ | nein: ✗ Sichtung (Sci-Fi) |
| M36-16 | MC-SkinSuit_2022 | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 19620 | 4096x4096 | – | ja |
| M36-17 | BootsViking | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 6320 | 1024x1024 | – | ja |
| M36-18 | PantsViking | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 2544 | 1024x1024 | – | ja |
| M36-19 | TunicViking | suits02 | Ganzanzug | CC0; Kopf CC0; Paketdatei CC0 | 6568 | 2048x2048 | – | ja |
| M36-20 | Spider Gwen | suits02 | Ganzanzug | CC0; Kopf –; Paketdatei CC0 | 42800 | 2000x2000 | Superheld ✗ | nein: ✗ Sichtung (Superheld) |
| M36-21 | Glactic_Warrior_02 | suits02 | Ganzanzug | CC0; Kopf –; Paketdatei CC0 | 10193 | 2048x2048 | Sci-Fi ✗ | nein: ✗ Sichtung (Sci-Fi) |
| M41-01 | dali_moustache | bodyparts06 | Bart | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 1672 | 1024x1024 | – | ja |
| M41-02 | elvs_beard1_longscruffy3 | bodyparts06 | Bart | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 792 | 2048x2048 | – | ja |
| M41-03 | Full_beard | bodyparts06 | Bart | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 748 | 1024x1024 | – | ja |
| M41-04 | Moustache | bodyparts06 | Bart | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 120 | 1024x1024 | – | ja |
| M42-01 | babydoll_elvruff1a | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 45701 | 2048x2048 | – | ja |
| M42-02 | doublechiefhalterdress1 | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 21954 | 1024x1024 | – | ja |
| M42-03 | westernized_quipoa | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 39027 | 1024x1024 | – | ja |
| M42-04 | frill_partydress1 | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 18881 | 1024x1024 | – | ja |
| M42-05 | elvs_fringe_dress1 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 6768 | 2048x2048 | – | ja |
| M42-06 | elvs_leather_fringedress1 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 11762 | 2048x2048 | – | ja |
| M42-07 | elvs_offshoulder_fringedress2_p | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 14733 | 2048x2048 | – | ja |
| M42-08 | elvs_goddessdress1 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 10059 | 2048x2048 | – | ja |
| M42-09 | elvs_goddess_dress2 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 14873 | 2048x2048 | – | ja |
| M42-10 | elvs_goddess_dress3 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 63026 | 2048x2048 | – | ja |
| M42-11 | elvs_goddess_dress4 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 36675 | 2048x2048 | – | ja |
| M42-12 | elvs_goddess_dress5 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 23275 | 2048x2048 | – | ja |
| M42-13 | elvs_goddess_dress6 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 28039 | 2048x2048 | – | ja |
| M42-14 | elvs_goddessdress7 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 13069 | 2048x2048 | – | ja |
| M42-15 | elvs_goddessdress8 | dress02 | Kleid | CC-BY; Kopf –; Paketdatei CC-BY | 65094 | 2048x2048 | – | ja |
| M42-16 | elvs_short_halterdress1 | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 9596 | 1024x1024 | – | ja |
| M42-17 | elvs_long_halterdress1 | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 15548 | 1024x1024 | – | ja |
| M42-18 | elvs_mini_halterdress | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 15492 | 1024x1024 | – | ja |
| M42-19 | tieredhalterdress1 | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 21076 | 1024x1024 | – | ja |
| M42-20 | elvs_lady_apron1 | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 54594 | 1024x1024 | – | ja |
| M42-21 | sarong_coverup1 | dress02 | Kleid | CC-BY; Kopf CC-by; Paketdatei CC-BY | 2930 | 1024x1024 | – | ja |
| M42-22 | elvs_hippydress1 | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 2904 | 1024x1024 | – | ja |
| M42-23 | elv_simple_fashiondress1a | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 1800 | 1024x1024 | – | ja |
| M42-24 | elv_simple_fashiondressd | dress02 | Kleid | CC-BY; Kopf CC_by; Paketdatei CC-BY | 2150 | 1024x1024 | – | ja |
| M43-01 | Ballet_dress_The_Swan | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 4360 | 4096x4096 | – | ja |
| M43-02 | F_Dress_01 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 3548 | 4096x4096 | – | ja |
| M43-03 | F_Dress_02 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 3274 | 4096x4096 | – | ja |
| M43-04 | F_Dress_03 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 21904 | 8192x8192 | – | ja |
| M43-05 | F_Dress_04 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 3220 | 4096x4096 | – | ja |
| M43-06 | F_Dress_05 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 12852 | 4096x4096 | – | ja |
| M43-07 | F_Dress_06 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 4508 | 4096x4096 | – | ja |
| M43-08 | F_Dress_07 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 3608 | 4096x4096 | – | ja |
| M43-09 | F_Dress_08 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 1406 | 4096x4096 | – | ja |
| M43-10 | F_Dress_09 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 15920 | 4096x4096 | – | ja |
| M43-11 | F_Dress_10 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 5068 | 4096x4096 | – | ja |
| M43-12 | F_Dress_11 | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 2570 | 4096x4096 | – | ja |
| M43-13 | Cocktaildress | dress03 | Kleid | CC-BY; Kopf CC-BY 3.0; Paketdatei CC-BY | 3406 | 2048x2048 | – | ja |
| M43-14 | EveningGown | dress03 | Kleid | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 5150 | 2048x2048 | – | ja |
| M43-15 | figure_skating_dress | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 4274 | 2048x2048 | – | ja |
| M43-16 | MedievalDress | dress03 | Kleid | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 7852 | 2048x2048 | – | ja |
| M43-17 | Qipao | dress03 | Kleid | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 7826 | 2048x2048 | – | ja |
| M43-18 | TubeDress | dress03 | Kleid | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 2596 | 2048x2048 | – | ja |
| M43-19 | Coat | dress03 | Kleid | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 7400 | 2048x2048 | – | ja |
| M47-01 | cl_bowler_hat | hats03 | Hut | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 2368 | 1024x1024 | Melone ✗ | nein: ✗ Sichtung (Melone) |
| M47-02 | cl_don_quixote_hat | hats03 | Hut | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 2872 | 1024x1024 | – | ja |
| M47-03 | brave_feathers | hats03 | Hut | CC-BY; Kopf cc-by; Paketdatei CC-BY | 5852 | 1024x1024 | – | ja |
| M47-04 | elvs_charity_veil_m1a_over | hats03 | Hut | CC-BY; Kopf –; Paketdatei CC-BY | 4109 | 2048x2048 | – | ja |
| M47-05 | elv_maidonnet1 | hats03 | Hut | CC-BY; Kopf CC_by; Paketdatei CC-BY | 3118 | 1024x1024 | – | ja |
| M47-06 | elvs_male_flat_cap1 | hats03 | Hut | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 2632 | 1024x1024 | – | ja |
| M47-07 | m_trilby_hat | hats03 | Hut | CC-BY; Kopf CC-by; Paketdatei CC-BY | 28602 | 1024x1024 | – | ja |
| M47-08 | elvs_santa_hat | hats03 | Hut | CC-BY; Kopf CC-by; Paketdatei CC-BY | 3200 | 2048x2048 | Weihnachten ✗ | nein: ✗ Sichtung (Weihnachten) |
| M47-09 | elvs_beanie_slouch | hats03 | Hut | CC-BY; Kopf –; Paketdatei CC-BY | 1180 | 2048x2048 | – | ja |
| M47-10 | tophat1 | hats03 | Hut | CC-BY; Kopf CC-by; Paketdatei CC-BY | 1168 | 1024x1024 | – | ja |
| M47-11 | elvs_unisex_chef_hat1 | hats03 | Hut | CC-BY; Kopf –; Paketdatei CC-BY | 8160 | 2048x2048 | – | ja |
| M47-12 | witchy_hat1_elv | hats03 | Hut | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 1219 | 1024x1024 | – | ja |
| M47-13 | wizard_hat | hats03 | Hut | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 472 | 1024x1024 | – | ja |
| M47-14 | Fishing_Hat_01 | hats03 | Hut | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 2488 | 2048x2048 | – | ja |
| M47-15 | Knitted_Hat_01 | hats03 | Hut | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 448 | 2048x2048 | – | ja |
| M47-16 | Patrol_Cap | hats03 | Hut | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 724 | 2048x2048 | – | ja |
| M47-17 | Sherpa_Hat | hats03 | Hut | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 2032 | 2048x2048 | – | ja |
| M47-18 | SunVisor | hats03 | Hut | CC-BY; Kopf CC  BY 3.0; Paketdatei CC-BY | 812 | 1024x1024 | – | ja |
| M47-19 | swim-cap | hats03 | Hut | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 924 | 1024x1024 | – | ja |
| M48-01 | warrior_helmet_02 | hats04 | Helm | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 7131 | 1024x1024 | – | ja |
| M48-02 | pith_helmet | hats04 | Helm | CC-BY; Kopf CCBY; Paketdatei CC-BY | 4676 | 1024x1024 | – | ja |
| M48-03 | M1951-72 | hats04 | Helm | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 4748 | 2048x2048 | – | ja |
| M48-04 | helmet_horn | hats04 | Helm | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 432 | 1024x1024 | – | ja |
| M48-05 | Leather_Helmet | hats04 | Helm | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 928 | 1024x1024 | – | ja |
| M48-06 | Helmet_KZ45 | hats04 | Helm | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 18996 | 2048x2048 | – | ja |
| M48-07 | BikeHelmet | hats04 | Helm | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 4170 | 2048x2048 | Fahrrad ✗ | nein: ✗ Sichtung (Fahrrad) |
| M48-08 | riding_helmet | hats04 | Helm | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 5356 | 1024x1024 | – | ja |
| M49-01 | elv_50supdo1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 2677 | 1024x1024 | 50er ✗ | nein: ✗ Sichtung (50er) |
| M49-02 | elvs_adrienne_hair1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 9381 | 1024x1024 | – | ja |
| M49-03 | elvs_ashley_mayhair1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 8467 | 1024x1024 | – | ja |
| M49-04 | elvs_braid_bun_q1 | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 21016 | 2050x2050 | – | ja |
| M49-05 | cornrowsofelv5 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 40928 | 1024x1024 | – | ja |
| M49-06 | elvs_daisyhair1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 6639 | 1024x1024 | – | ja |
| M49-07 | elvs_grumphair | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 12332 | 2048x2048 | – | ja |
| M49-08 | elvs_hazel_hair | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 4181 | 1024x1024 | – | ja |
| M49-09 | elvs_inverted_curlybob1 | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 2980 | 2048x2048 | – | ja |
| M49-10 | elvs_island_princess1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 8954 | 1024x1024 | – | ja |
| M49-11 | elvs_katherinehair1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 5041 | 1024x1024 | – | ja |
| M49-12 | elvs_keylth_hair_m1 | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 4334 | 1024x1024 | – | ja |
| M49-13 | elvs_ladies_hippyhair1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 5020 | 1024x1024 | – | ja |
| M49-14 | elvs_laracroft_hair1a | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 27816 | 2048x2048 | – | ja |
| M49-15 | maxwell_hair_mh | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 1468 | 1024x1024 | – | ja |
| M49-16 | elvs_mickey_afro | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 1675 | 2048x2048 | – | ja |
| M49-17 | elvs_short_daisyh1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 3571 | 1024x1024 | – | ja |
| M49-18 | elvs_thejournalist1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 98660 | 1024x1024 | – | ja |
| M49-19 | elvs_that80sbabe_m1 | hair02 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 6004 | 1024x1024 | 80er ✗ | nein: ✗ Sichtung (80er) |
| M49-20 | elvscurly_bob1 | hair02 | Haar | CC-BY; Kopf CC_by; Paketdatei CC-BY | 4288 | 1024x1024 | – | ja |
| M49-21 | witchybob_elv2 | hair02 | Haar | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 1513 | 1024x1024 | – | ja |
| M50-01 | hair_01 | hair03 | Haar | CC-BY; Kopf cc-by; Paketdatei CC-BY | 44046 | 1024x1024 | – | ja |
| M50-02 | hair_02 | hair03 | Haar | CC-BY; Kopf –; Paketdatei CC-BY | 45584 | 1024x1024 | – | ja |
| M50-03 | hair_03 | hair03 | Haar | CC-BY; Kopf CC-by; Paketdatei CC-BY | 34425 | 1024x1024 | – | ja |
| M50-04 | hair_04 | hair03 | Haar | CC-BY; Kopf CC-by; Paketdatei CC-BY | 23491 | 1024x1024 | – | ja |
| M50-05 | hair_07 | hair03 | Haar | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 13392 | 1024x1024 | – | ja |
| M50-06 | hair_08 | hair03 | Haar | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 7992 | 1024x1024 | – | ja |
| M50-07 | wig_bow_tie | hair03 | Haar | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 992 | 1024x1024 | – | ja |
| M50-08 | Wig_bun_blonde | hair03 | Haar | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 5372 | 1024x1024 | – | ja |
| M50-09 | o4saken_chinesebob01 | hair03 | Haar | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 10108 | – | – | ja |
| M50-10 | o4saken_curly01 | hair03 | Haar | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 120022 | 2048x2048 | – | ja |
| M50-11 | curly | hair03 | Haar | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 11304 | 1024x1024 | – | ja |
| M50-12 | curly2 | hair03 | Haar | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 6026 | 1024x1024 | – | ja |
| M50-13 | long_alpha7 | hair03 | Haar | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 3888 | 2048x2048 | – | ja |
| M50-14 | long2_alpha7 | hair03 | Haar | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 3596 | 1024x1024 | – | ja |
| M51-01 | bandana_mask | masks02 | Maske | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 1428 | 2048x2048 | – | ja |
| M51-02 | elvs_covidmask1_uni | masks02 | Maske | CC-BY; Kopf –; Paketdatei CC-BY | 3688 | 2048x2048 | Corona ✗ | nein: ✗ Sichtung (Corona) |
| M51-03 | elvs_plague_doctor_mask1 | masks02 | Maske | CC-BY; Kopf –; Paketdatei CC-BY | 31094 | 2048x2048 | – | ja |
| M51-04 | Gas Mask | masks02 | Maske | CC-BY; Kopf –; Paketdatei CC-BY | 4714 | 2048x2048 | Gas ✗ | nein: ✗ Sichtung (Gas) |
| M54-01 | ladieshoodiedown1 | shirts02 | Oberteil | CC-BY; Kopf CC_by; Paketdatei CC-BY | 19574 | 1024x1024 | Hoodie ✗ | nein: ✗ Sichtung (Hoodie) |
| M54-02 | mens_boho_top1elv | shirts02 | Oberteil | CC-BY; Kopf CC_by; Paketdatei CC-BY | 3422 | 1024x1024 | – | ja |
| M54-03 | mens_shirt_tie_tuck_elv1f | shirts02 | Oberteil | CC-BY; Kopf CC_by; Paketdatei CC-BY | 4666 | 1024x1024 | Krawatte ✗ | nein: ✗ Sichtung (Krawatte) |
| M54-04 | mens_shirt_untuck_elvbhp1f | shirts02 | Oberteil | CC-BY; Kopf CC_by; Paketdatei CC-BY | 8056 | 1024x1024 | – | ja |
| M54-05 | Striped_Shirt | shirts02 | Oberteil | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 7880 | 2048x2048 | – | ja |
| M54-06 | Worn out sweater | shirts02 | Oberteil | CC-BY; Kopf CC0; Paketdatei CC-BY | 3112 | 2048x2048 | – | ja |
| M54-07 | F_Cardigan_Long_Open_Front | shirts02 | Oberteil | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 8984 | 4096x4096 | – | ja |
| M54-08 | Knitted_Sweater_01 | shirts02 | Oberteil | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 2628 | 2048x2048 | – | ja |
| M54-09 | Knitted_Sweater_02 | shirts02 | Oberteil | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 2524 | 2048x2048 | – | ja |
| M54-10 | F_Lusekofta | shirts02 | Oberteil | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 2608 | 4096x4096 | – | ja |
| M54-11 | Deathnote | shirts02 | Oberteil | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 24780 | 2500x2500 | – | ja |
| M54-12 | lace_up_blouse | shirts02 | Oberteil | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 4954 | 2048x2048 | – | ja |
| M54-13 | offshoulder_top | shirts02 | Oberteil | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 4496 | 2048x2048 | – | ja |
| M57-01 | elvs_heelboot1 | shoes03 | Stiefel | CC-BY; Kopf CC_by; Paketdatei CC-BY | 73476 | 1024x1024 | – | ja |
| M57-02 | slouchbootwedgey_feather | shoes03 | Stiefel | CC-BY; Kopf CC_by; Paketdatei CC-BY | 43695 | 2048x2048 | – | ja |
| M57-03 | leather_boots | shoes03 | Stiefel | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 1272 | 1024x1024 | – | ja |
| M57-04 | exy_leather_boots | shoes03 | Stiefel | CC-BY; Kopf CC-BY; Paketdatei CC-BY | 1504 | 2048x2048 | – | ja |
| M57-05 | Shoes_Biker_Boots_female | shoes03 | Stiefel | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 15844 | 2048x2048 | Biker ✗ | nein: ✗ Sichtung (Biker) |
| M57-06 | Shoes_Biker_Boots_male | shoes03 | Stiefel | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 15844 | 2048x2048 | Biker ✗ | nein: ✗ Sichtung (Biker) |
| M57-07 | HalfBoots | shoes03 | Stiefel | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 4632 | 1024x1024 | – | ja |
| M57-08 | KneeBoots | shoes03 | Stiefel | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 3496 | 1024x1024 | – | ja |
| M57-09 | MedievalBoots | shoes03 | Stiefel | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 6884 | 1024x1024 | – | ja |
| M57-10 | riding_boots | shoes03 | Stiefel | CC-BY; Kopf CC BY 4.0; Paketdatei CC-BY | 3800 | 1024x1024 | – | ja |
| M57-11 | WinterBoots | shoes03 | Stiefel | CC-BY; Kopf CC BY 3.0; Paketdatei CC-BY | 4044 | 2048x2048 | Winter ✗ | nein: ✗ Sichtung (Winter) |
| M57-12 | BotasTaconBajo | shoes03 | Stiefel | CC-BY; Kopf AGPL3 (MakeClothes-Vorgabe); Paketdatei CC-BY | 6200 | 1024x1024 | – | ja |
