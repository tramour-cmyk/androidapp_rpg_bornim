# Vergleichsbilder „alt“ (Kotlin-Fassung)

882.1 (Umzug BRS Schritt 8): einmal gerendert, damit die Werkzeuge ohne Gradle und ohne `tools/preview` auskommen (`core/` geht mit 870.10). Lesen: `bash tools/alt_bilder.sh <teil> <ziel-ordner>`.

`leute` gerendert am 12.11. von Tom mit `tools/alt_bilder_rendern.sh` (Zweig `claude/tom-882-1-ohne-gradle`, Stand `05b8e2a2f`), `tools/preview` über `gradlew run`, Kotlin mit `-Xmx5g`.

`screens`, `karte`, `512b` ab 13.11. von Spike, Stand `24f215eb5`: Skia gibt den Speicher je Szene nicht frei (etwa 250 MB je Bild, auch nach GC), ein Lauf in einem Stück bricht nach etwa 75 Bildern ab. Daher einmal bauen (`installDist`), dann jeden Teil mit `WEITER=1 WEITER_MB=7000` starten: über 7000 MB endet der Lauf mit Exit 3, das Skript startet ihn neu, fertige Bilder werden übersprungen. Etwa ein Bild je Minute.

| Teil | Aufruf in `tools/preview` | Inhalt | Stand |
|---|---|---|---|
| `leute` | `LEUTEALT=1` | die dreizehn Leute des Dorfs von vorn und hinten (26 Bilder) | da |
| `screens` | Standardlauf | Schirme, Kampf, Karten | da (181 Bilder; 13.11. in zwei Läufen, Rest mit `VORHER=`, `d64b3559f`). Bekannt: Schirme nach einem Ortswechsel zeigen die Ortskarte (Name, Satz) statt der Welt, wie die alte Vorschau sie knipste |
| `karte` | `KARTENZOOM=1 ONLY=zoom_nah_p HELDORT=<Liste>` | Dorf, Wald, Höhle, Grundrisse | da (28 Bilder, 13.11.) |
| `512b` | `MENUE512B=1` | Menüschirme mit Fenstern | fehlt (läuft 13.11. ab 17:25 bei Spike; bricht er ab: neu mit `alt_bilder_rendern.sh <ablage> 512b`) |
