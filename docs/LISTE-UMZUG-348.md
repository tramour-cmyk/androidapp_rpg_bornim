# Umzug nach Godot (348)

Entschieden 25.10., 00:30–01:04 (Vorgangsarchiv „348, Umstieg“, „348, Umzug Einzelheiten“, „338, Termin“): Umzug jetzt, altes Spiel ruht, kein Release-Termin. **Vorgabe ist das heutige Spiel**: was es zeigt und kann, muss es danach mindestens so gut zeigen und können. Der Chef prüft nur Vergleichsbilder alt/neu. Plan: Sokrates (Vertretung des Chefs, 25.10., 01:19), Abnahme und Wochenziel: Perikles.

## Grundsätze

- **Ein Projekt:** `godot/` im Repo (Arbeitszweige `claude/tom-348-…`, `claude/jerry-348-…`), App-Kennung bleibt `de.bornim.game`, Build über eigenen Workflow; `main` erst nach Test des Chefs.
- **Look aus der Probe** (`tools/godot348/`, Build 11): `toon.gdshader` (drei Lichtstufen), `tusche.gdshader` (Tusche nach Licht, ohne MSAA), gemalte Texturen aus `tools/blender348/v3/tex.py`. Keiner stellt seine eigene Tusche ein.
- **Modellregel** (Jerry legt fest, 348.7): 1 Feld = 1 m, Held 1,8 m; glTF aus Blender-Skripten in `tools/blender348/`, nie von Hand; Skelett wie `rig.py`; Texturen gemalt wie `tex.py`, höchstens 1024 px; Name = Name im alten Spiel.
- **Regeln** (`core`) nach GDScript mit denselben Testfällen; Tom Welt, Leute, Story, Läden, Spielstand; Jerry Kampf, MARS, Höhle, Klang.
- **Abgleich:** je Ort und Figur ein Vergleichsbild alt/neu; was fehlt oder schlechter ist, ist ein Fehler.

## Woche 1: Fundament (ab 25.10.)

| Nr. | Wer | Was | fertig, wenn |
|---|---|---|---|
| 348.6 | Tom | Godot-Projekt `godot/` mit Held, Steuerung (Tippen, Joystick), Kamera, Licht, Tusche aus der Probe; Kartenformat aus den heutigen Karten (Export aus `core`), Dorf Bornim als erste Gebietskarte mit Kollision und Ein- und Ausgängen | APK am Handy, Vergleichsbild Dorf alt/neu |
| 348.7 | Jerry | Modellregel (oben) schriftlich in dieser Datei; ein Kampfort in Godot: Wolfsrudel in MARS mit den echten Regeln (GDScript), Kamera, Ansagen, Ende | APK am Handy, Vergleichsbild Kampf alt/neu |
| 348.8 | Tom, Jerry | Bestandsliste: jede Gebietskarte, jeder Grundriss, jede Figur, jedes Tier, Monster, Ausrüstung, Gegenstand im alten Spiel, mit Quelle im Code; Spalte „Modell“, „Wer“ | Liste unten vollständig |

## Ab Woche 2: Modelle und Orte nach Bestandsliste

Aufteilung nach Bereich (Tom: Leute, Häuser, Innenräume, Dorftiere wie Hühner, Katzen, Hunde; Jerry: Monster, Wald- und Höhlentiere wie Frösche, Libellen, Schmetterlinge, Höhle, Waffen und Rüstungen), Reihenfolge wie Kapitel 1 gespielt wird.

## Bestandsliste (348.8)

(folgt)
