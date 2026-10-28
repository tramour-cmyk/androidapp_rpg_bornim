# Chroniken von Bornim in Godot (Umzug 348)

Plan und Regeln: `docs/LISTE-UMZUG-348.md` (auf `main`). Bau: `.github/workflows/godot.yml` (Artefakt `bornim-godot-apk`).

## Aufbau

- `skripte/spiel.gd`: Hauptszene; betritt eine Karte, verbindet Held, Kamera, Licht, Steuerung; Ausgänge, Schilder, Texte.
- `skripte/karte.gd`: eine Karte aus `daten/karten.json` (Export aus `core`, `MapExport.kt`): Kacheln, Begehbarkeit wie `MapDef.walkable`, Ausgänge, Wegsuche, Bodentempo.
- `skripte/gebiet.gd`: Gebietskarte aus Blender (`daten/dorf.bin`) mit dem Look der Probe Build 11, Lampen, Gras, Falter, Rauch.
- `skripte/held.gd`: Held (`daten/held.bin`), Gehen/Stehen, Fackel, Kollision, Tempo wie `FreeWalk`.
- `skripte/kamera.gd`, `licht.gd`, `steuerung.gd`: Blick schräg von oben mit Tusche; Tag und Nacht; Tippen, Joystick, zwei Finger, Knöpfe, Textfeld.
- `skripte/heldwerte.gd` (390): der Held wie `Hero.kt` (Werte, RK, Angriff, Schaden, Stufen, Ausruestung anlegen); Gegenprobe `tests/held_golden.gd`.
- `skripte/geschichte.gd`, `skript.gd`, `zustand.gd`, `sprache.gd` (390): Gespraeche und Auftraege wie `Story.kt` (Texte wortgleich, `tools/pruef348/story_texte.py`), Spielstand, Deutsch/Englisch.
- `shader/`: `toon` (drei Lichtstufen), `tusche` (nach Licht), `boden`, `halm`, `wasser`; keiner stellt seine eigene Tusche ein.

## Maße

1 Godot-Einheit = 1 m; eine Kachel der alten Karte = 1,16 m (`Karte.TS`, wie Probe Build 11); Held 1,8 m. Kachel (Spalte, Zeile) liegt ab (Spalte · 1,16; 0; Zeile · 1,16), Norden = −z.

## Am Rechner

```
./gradlew -p core exportMaps -Pout=$PWD/godot/daten/karten.json
./gradlew -p core exportTexts -Pout=$PWD/godot/daten/texte.json   # 390: Oberflaeche, Dinge (Sprache.gd)
./gradlew -p core exportHero -Pout=$PWD/godot/daten/held.json -Pproben=$PWD/godot/daten/held_proben.json   # 390: Held, Proben fuer tests/held_golden.gd
OUT=/tmp/out KARTEN=$PWD/godot/daten/karten.json python -I tools/blender348/v3/{tex,held3,rig,dorf}.py   # je Skript ein Aufruf
# Ausgaben nach godot/daten kopieren wie im Workflow (Schritt „Modelle bauen“)
godot --path godot -- --bilder=/tmp/bilder   # Standbilder Tag, Gehen, Nacht, Tür, Schlagbaum
```
