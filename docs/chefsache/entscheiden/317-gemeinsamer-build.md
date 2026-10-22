# 317 · Ein gemeinsamer Testbuild für Tom und Jerry?
Sokrates · 22.10., 21:3x · B Abläufe · M? (Chef 22.10., 21:24: Warum Toms kleine Startänderung nicht mit Jerrys MARS-Änderung bündeln? Wie viele Builds heute, was drin, hätte man bündeln können?)

## Befund 22.10.

11 Testbuilds, alle vom Chef anzusehen:
- **Jerry 7:** 66 (MARS-Effekte 249, Ladeblende 24.6, 285, 19e), 67 (Kampftexte 290, 279, 280.2), 71 (nur Rückläufer 249/24.6), 72 (Knien 288, Sturz 295), 74 (Kampfblende 24.6, Umzielen 301, 299), 75 (305, 303), 78 (Grak holt aus 310; offen).
- **Tom 4:** 70 (293, 294), 73 (Geste 297, Waldblende 267.2), 76 (Rowena 306, Hauptmenü Stufe 1 292.3), 77 (Über das Spiel 312, Entwurf A 292.3, Klanglogo 292.1).
- Je Build 1–4 Punkte. Toms 292.1 (Stille vor der Titelmusik) wartet jetzt, weil „nie ein Punkt allein“ und „nie mit Jerry“.

**Herkunft der Trennung:** Vorgangsarchiv 99h.5 (17.10.), Chef: „Tom und Jerry nicht mixen, passt auch …“, Empfehlung Perikles. Technischer Grund damals: zwei Zweige, zwei PRs, kein gemeinsamer Besitzer des Builds.

## Vorschlag

1. **Ein Tagesbuild für beide Teams**, höchstens zwei am Tag (etwa 13 und 19 Uhr), alles, was bis dahin fertig ist, bis 6 Punkte. Ein Sammelzweig, den abwechselnd ein Team baut; die Prüfliste nennt je Punkt Team und Vorgang.
2. **Rückläufer blockiert nicht:** fällt ein Punkt durch, wird nur er herausgenommen (Rückbau seines Commits), der Rest geht auf `main`.
3. „Nie ein Punkt allein“ bleibt; „Chef sagt jetzt“ bleibt.

Ersetzt in 99h.5 „Tom und Jerry bauen weiter getrennt“ (Regelbilanz).

## Stärkstes Gegenargument

Ein gemeinsamer Build bindet die Teams aneinander: fällt ein Punkt durch oder zerbricht der Build, warten beide; Zusammenführen kostet Zeit, wenn beide dieselbe Datei anfassen (`WorldScreen.kt`, `App.kt`). Antwort: Treffer im selben Code sind selten (Start/Hauptmenü gegen MARS), Git löst den Rest; Punkt 2 nimmt dem Durchfallen den Schaden.

## Empfehlung

**Ja, 1 bis 3.** Heute wären es statt 11 etwa 4 Builds gewesen.

Berührt: 99h.5, 292.1, 310, Perikles (Umsetzung in `ROLLE-ENTWICKLUNG.md`, `LISTE-RELEASE-NEUSTART.md`).
