# Umzug nach Godot (348)

Entschieden 25.10., 00:30–01:04 (Vorgangsarchiv „348, Umstieg“, „348, Umzug Einzelheiten“, „338, Termin“): Umzug jetzt, altes Spiel ruht, kein Release-Termin. **Vorgabe ist das heutige Spiel**: was es zeigt und kann, muss es danach mindestens so gut zeigen und können. Der Chef prüft nur Vergleichsbilder alt/neu. Plan: Sokrates (Vertretung des Chefs, 25.10., 01:19), Abnahme und Wochenziel: Perikles.

## Grundsätze

- **Ein Projekt:** `godot/` im Repo (Arbeitszweige `claude/tom-348-…`, `claude/jerry-348-…`), App-Kennung bleibt `de.bornim.game`, Build über eigenen Workflow; `main` erst nach Test des Chefs.
- **Look aus der Probe** (`tools/godot348/`, Build 12, b71b9a47f): `toon.gdshader` (drei Lichtstufen, `fill` hellt den Helden im Schatten auf), `tusche.gdshader` (Tusche nach Licht, ohne MSAA; Schablone: 1 = ohne Linie wie Blüten, 2 = feinere Linie wie Held, `main.gd` `toon_mark`), Gras `halm.gdshader` ohne Linie, gemalte Texturen aus `tools/blender348/v3/tex.py`. Keiner stellt seine eigene Tusche ein.
- **Modellregel** (Jerry, 348.7): unten im Abschnitt „Modellregel“.
- **Regeln** (`core`) nach GDScript mit denselben Testfällen; Tom Welt, Leute, Story, Läden, Spielstand; Jerry Kampf, MARS, Höhle, Klang.
- **Abgleich:** je Ort und Figur ein Vergleichsbild alt/neu; was fehlt oder schlechter ist, ist ein Fehler.

## Woche 1: Fundament (ab 25.10.)

| Nr. | Wer | Was | fertig, wenn |
|---|---|---|---|
| 348.6 | Tom | Godot-Projekt `godot/` mit Held, Steuerung (Tippen, Joystick), Kamera, Licht, Tusche aus der Probe; Kartenformat aus den heutigen Karten (Export aus `core`), Dorf Bornim als erste Gebietskarte mit Kollision und Ein- und Ausgängen | APK am Handy, Vergleichsbild Dorf alt/neu |
| 348.7 | Jerry | Modellregel (oben) schriftlich in dieser Datei; ein Kampfort in Godot: Wolfsrudel in MARS mit den echten Regeln (GDScript), Kamera, Ansagen, Ende | APK am Handy, Vergleichsbild Kampf alt/neu |
| 348.8 | Tom, Jerry | Bestandsliste: jede Gebietskarte, jeder Grundriss, jede Figur, jedes Tier, Monster, Ausrüstung, Gegenstand im alten Spiel, mit Quelle im Code; Spalte „Modell“, „Wer“ | Liste unten vollständig |

## Modellregel (348.7, Jerry, 25.10.)

Gilt für jedes Modell im neuen Spiel: Figur, Tier, Monster, Ausrüstung, Ding, Gebäude.

1. **Maß:** 1 Godot-Einheit = 1 m = 1 Feld der alten Karte. Held 1,8 m; alle anderen im Verhältnis wie im alten Spiel (Vorgabe: Vergleichsbild alt/neu nebeneinander), Tiere nach echter Größe (Wolf 0,8 m Schulterhöhe). Export in Metern; `held.glb` der Probe ist in Zentimetern und wird beim Übernehmen umgestellt, nie im Spiel mit 0,01 skaliert.
2. **Herkunft:** jedes Modell ist ein Python-Skript in `tools/blender348/` (Blender als Modul, Version wie im Workflow), das die `.glb` erzeugt; nie von Hand in Blender, nie eingecheckte `.glb` ohne Skript. Fremde Teile nur nach „Fremde Inhalte“ (`CLAUDE.md`).
3. **Ausrichtung:** Ursprung am Boden unter dem Schwerpunkt (Mensch: zwischen den Füßen), Blick nach glTF +Z (Blender −Y), oben +Y.
4. **Skelett:** Menschen und Menschenähnliche (Goblin, Grak, Zombie) mit dem Skelett aus `rig.py` und dessen Knochennamen; Tiere ein Skelett je Bauart (Vierbeiner, Vogel, Insekt, Spinne), in allen Modellen dieser Bauart gleich benannt. Waffen, Schilde, Fackel als eigene `.glb`, im Spiel an den Handknochen gehängt, nicht ins Netz gebacken; Griffpunkt = Ursprung.
5. **Bewegungen:** im Skript erzeugt, 30 Bilder je Sekunde, deutsche Namen wie im alten Spiel (Stehen, Gehen, Ausholen, Hieb, Stich, Biss, Sprung, Treffer, Ausweichen, Abwehr, Sturz, Aufstehen, Tod …); Schleifen nahtlos; Füße am Boden, Gehtempo in `<name>-info.json` (wie `held-info.json`), damit nichts gleitet. Schlagzeiten wie `DESIGN-ABNAHME.md` (Biss, Stich 0,6 s; Hieb 0,8 s).
6. **Aussehen:** Farbe gemalt wie `tex.py` (Textur oder in Eckfarben gebacken), höchstens 1024 px; kein Glanz außer Gold (Signatur); Licht und Tusche nur aus `toon.gdshader` und `tusche.gdshader`, nie im Modell. Mindestens drei Varianten (Fell, Statur, Kleidung) als Schalter im Skript.
7. **Größe:** Figur höchstens 6000 Dreiecke, Ausrüstung höchstens 800, Ding höchstens 2000 (Samsung A56, `DESIGN-ABNAHME.md` Leistung); mehr nur nach Messung.
8. **Name:** Datei = Kennung im alten Spiel (`wolf.glb`, `hobgoblin_captain.glb`, `shortsword.glb`), angezeigter Name aus den Regeln, nie im Modell.
9. **Geprüft vor Abgabe:** Kontaktblatt aller Bewegungen (`blatt.py`), Durchdringung Waffe/Körper 0, Fußgleiten gemessen, Vergleichsbild alt/neu in der Bestandsliste vermerkt (Spalte „Modell“: Skript, Stand).

## Ab Woche 2: Modelle und Orte nach Bestandsliste

Aufteilung nach Bereich (Tom: Leute, Häuser, Innenräume, Dorftiere wie Hühner, Katzen, Hunde; Jerry: Monster, Wald- und Höhlentiere wie Frösche, Libellen, Schmetterlinge, Höhle, Waffen und Rüstungen), Reihenfolge wie Kapitel 1 gespielt wird.

## Bestandsliste (348.8)

(folgt)
