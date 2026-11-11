# Chroniken von Bornim in Godot (Umzug 348)

Plan und Regeln: `docs/LISTE-UMZUG-348.md` (auf `main`). Bau: `.github/workflows/godot.yml` (Artefakt `bornim-godot-apk`).

## Aufbau

- `skripte/spiel.gd`: Hauptszene; betritt eine Karte, verbindet Held, Kamera, Licht, Steuerung; Ausgänge, Schilder, Texte.
- `skripte/karte.gd`: eine Karte aus `daten/karten.json` (Export aus `core`, `MapExport.kt`): Kacheln, Begehbarkeit wie `MapDef.walkable`, Ausgänge, Wegsuche, Bodentempo.
- `skripte/gebiet.gd`: Gebietskarte aus Blender (`daten/dorf.bin`) mit dem Look der Probe Build 11, Lampen, Gras, Falter, Rauch.
- `skripte/held.gd`: Held (`daten/held.bin`), Gehen/Stehen, Fackel, Kollision, Tempo wie `FreeWalk`.
- `skripte/kamera.gd`, `licht.gd`, `steuerung.gd`: Blick schräg von oben mit Tusche; Tag und Nacht; Tippen, Joystick, zwei Finger, Knöpfe, Textfeld.
- `regeln/brs_held.gd` (470, 870.4): der Held nach dem BRS (Erschaffung, Grundwerte, Fertigkeiten, Leben, Mana, Schutzwert, Schaden, Ausruestung anlegen, Kampfblatt); Zahlen aus `daten/werte.json`; Gegenproben `tests/brs_470.gd`, `tests/brs_blatt_870.gd`, `tests/brs_held_870.gd`.
- `skripte/geschichte.gd`, `skript.gd`, `zustand.gd`, `sprache.gd` (390): Gespraeche und Auftraege wie `Story.kt` (Texte wortgleich, `tools/pruef348/story_texte.py`), Spielstand, Deutsch/Englisch.
- `kampf/` (Jerry, 348.7): Kampfort mit MARS, `kampf/aufruf.gd` startet ihn aus der Welt; 399.1: der Weg in den Wald fuehrt dorthin (`spiel.gd` `kampf_im_wald`), Grundrisse aus `tools/blender348/v3/raum.py` (`daten/<id>.bin`).
- `regeln/brs.gd` (473): Monsterwerte Kapitel 1 nach dem BRS und Rechenmodell D wie die Simulation 444, Zahlen nur aus `daten/werte.json` (Kopie von `tools/sim444/werte.json`); Gegenprobe `tests/brs_473.gd`. Der Kampf rechnet bis 2.3 noch nach SRD (`regeln/tabellen.json`).
- `shader/`: `toon` (drei Lichtstufen), `tusche` (nach Licht), `boden`, `halm`, `wasser`; keiner stellt seine eigene Tusche ein.

## Maße

1 Godot-Einheit = 1 m; eine Kachel der alten Karte = 1,16 m (`Karte.TS`, wie Probe Build 11); Held 1,8 m. Kachel (Spalte, Zeile) liegt ab (Spalte · 1,16; 0; Zeile · 1,16), Norden = −z.

## Am Rechner

```
# 870.9: Karten, Texte, Held, Intro, Kartenblaetter, Bilder der Dinge und Klang sind eingecheckt (godot/daten, ohne Gradle);
# Karten von Hand bearbeiten, danach: python3 tools/karten/karten.py ableiten (bewuchs, ring) und tests/karten_regeln.gd
cp tools/gegenstaende/gegenstaende.json godot/daten/   # 458.2: Stufe und Preis aller Gegenstaende (skripte/katalog.gd)
cp tools/sim444/werte.json godot/daten/   # 473: Monsterwerte BRS (regeln/brs.gd)
OUT=/tmp/out KARTEN=$PWD/godot/daten/karten.json python -I tools/blender348/v3/{tex,held3,rig,dorf}.py   # je Skript ein Aufruf
# Ausgaben nach godot/daten kopieren wie im Workflow (Schritt „Modelle bauen“)
godot --path godot -- --bilder=/tmp/bilder   # Standbilder Tag, Gehen, Nacht, Tür, Schlagbaum
```
