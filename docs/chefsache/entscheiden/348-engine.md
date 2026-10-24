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

Berührt: 346, 267, Idee „Spiel-Engine“ in `LISTE-IDEEN.md`.
