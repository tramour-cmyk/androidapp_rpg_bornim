# Vergleichsbilder „alt“ (Kotlin-Fassung)

882.1 (Umzug BRS Schritt 8): einmal gerendert, damit die Werkzeuge ohne Gradle und ohne `tools/preview` auskommen (`core/` geht mit 870.10). Lesen: `bash tools/alt_bilder.sh <teil> <ziel-ordner>`.

Gerendert am 12.11. von Tom mit `tools/alt_bilder_rendern.sh` (Zweig `claude/tom-882-1-ohne-gradle`, Stand `05b8e2a2f`), `tools/preview` über `gradlew run`, Kotlin mit `-Xmx5g`.

| Teil | Aufruf in `tools/preview` | Inhalt | Stand |
|---|---|---|---|
| `leute` | `LEUTEALT=1` | die dreizehn Leute des Dorfs von vorn und hinten (26 Bilder) | da |
| `screens` | `gradlew run` | Standardlauf: Schirme, Kampf, Karten | fehlt: der Lauf wird in der Cloud-Sitzung zweimal nach etwa 75 Bildern vom Speicher abgebrochen (Java über 10 GB, Exit 137) |
| `karte` | `KARTENZOOM=1 ONLY=zoom_nah_p HELDORT=<Liste>` | Dorf, Wald, Höhle, Grundrisse | fehlt (noch nicht gelaufen) |
| `512b` | `MENUE512B=1` | Menüschirme mit Fenstern | fehlt (Lauf vom Speicher abgebrochen, nicht geprüft) |
