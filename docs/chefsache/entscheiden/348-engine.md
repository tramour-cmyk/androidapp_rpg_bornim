# 348 · Fertige Spiel-Engine statt Selbstbau? Erst messen
Sokrates · 24.10., 16:50 · E Technik · K (Chef 24.10., 16:43 und 16:46: eine KI empfahl „Claude Code und Godot“; „griffige Alternative zu Godot“? Einwand: selbst gebaut heißt viele Fehler, die eine fertige Engine nicht hätte.)

## Befund

- **Heute keine Engine:** Kotlin mit Jetpack Compose, Welt im Code gezeichnet (eine PNG, etwa 86.000 Zeilen Kotlin). Regeln in `core` getrennt von der Oberfläche.
- **Selbstbau kostet Fehler:** grob ausgezählt etwa 35 von 1.231 CHANGELOG-Zeilen sind typische Engine-Aufgaben (Flackern, Kollision, Ruckeln, Absturz); dazu eigener Bildspeicher (Held zeichnet beim ersten Start 24 s neu), Speicher (346).
- **Engines mit Code statt Editor:** libGDX (Kotlin/Java, `core` bleibt, seit 2009, viele Android-Spiele); KorGE (Kotlin, kleiner); Godot (GDScript/C#, Szenen als Text, aber Regeln neu); Defold (Lua); Unity (nicht für uns).

## Vorschlag

1. **Messung (etwa eine halbe Sitzung je Team):** Tom und Jerry ordnen die Fehler, die du in den letzten zwei Wochen gefunden hast, ein: hätte libGDX ihn verhindert, ja/nein; dazu Schätzung der Umzugskosten (nur Zeichnen, Bewegung, Steuerung; `core` bleibt).
2. **Danach:** Anteil über etwa ein Drittel → Wechsel zu libGDX als eigene Chefsache; darunter → Kapitel 1 fertig, Frage nach dem Meilenstein neu.

## Stärkstes Gegenargument

Die Messung kostet Zeit vor Kapitel 1, und schöne Grafik machen Bilder, nicht die Engine (eigene oder offen lizenzierte, dafür niemand). Antwort: Warten macht den Umzug jede Woche teurer; die Messung ist billig gegen einen falschen Entscheid in beide Richtungen.

## Empfehlung

**1 jetzt** (Kür neben dem Wochenziel), 2 nach dem Ergebnis.

Berührt: 346, 267, 302.1, Idee „Spiel-Engine“ in `LISTE-IDEEN.md`.

## Nachtrag 24.10., 16:55 (Chef 16:49: „Bringt uns die Engine was? Wird unsere Grafik dadurch besser? … vektorbasiert? … geil zoomen? … weg von Pixel … Tusche-Vorhaben … Vergleichsbild … einmal in neu und einmal in alt“)

- **Pixel-Look ist eigene Wahl:** Welt 32 Bildpunkte je Kachel (`WorldArt.T`), am Handy etwa fünffach ohne Glättung (`FilterQuality.None`); Figuren als 3D-Puppen (`Sdf.kt`) vorab auf dem Rechenkern in kleine Bilder (`MapFigure`, Dichte 2).
- **Engine ist nicht vektorbasiert:** Godot, libGDX zeichnen Bilder oder 3D; Kopie des Alten sieht gleich aus.
- **Schärfer macht höhere Auflösung desselben Zeichners** (z. B. 128 je Kachel); auf dem Rechenkern 16-facher Speicher und Zeit (heute schon 509 von 512 MB, 346). Nutzen einer Engine: Grafikchip zeichnet je Bild in voller Auflösung; Grafikchip ginge auch ohne Engine in der jetzigen App.
- **Tusche** geht überall (im Zeichner); erst bei höherer Auflösung sichtbar (302.1).
- *Gegenargument:* Schärfe zeigt Schwächen, die Pixel verdecken; dann Nachzeichnen als eigentliche Arbeit.

**Neue Empfehlung (ersetzt 1 oben als ersten Schritt):** **348.1 Vergleichsbild** von Tom am Rechner (`tools/preview`): ein Ausschnitt Gebietskarte mit Held, alt (32 je Kachel) neben neu (128 je Kachel, mit Tusche), eigener Zeichner, keine Engine. Gefällt „neu“: Weg aufs Handy prüfen (Engine oder Grafikchip in der App), dann die Fehlermessung.
