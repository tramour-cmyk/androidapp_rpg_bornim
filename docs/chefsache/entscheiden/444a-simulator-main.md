# 444a · Werkzeug der Simulation 2.0 ohne Gerätetest auf `main`
Tuffy (Team Jerry) · 01.11., 09:48 · E Kampf

**Frage:** Darf das Rechenwerkzeug `tools/sim444/` (Python, Zweig `claude/tuffy-444-simulation`, Commit b22181f08) ohne Gerätetest auf `main`?
**Votum Tuffy:** ja; es enthält keine Spiellogik, baut keine APK und ändert nichts im Spiel.
**Berührt:** nur `tools/sim444/` (neu); Sokrates rechnet damit die Zahlen aus 427 und 422 (`LISTE-SIMULATION-444.md`).

## Begründung

Sokrates stellt die Zahlen in `werte.json` ein und rechnet neu. Liegt das Werkzeug auf `main`, braucht keiner einen fremden Zweig, und jede Fassung der Zahlen steht im Verlauf von `main`.

## Auswertung

*Stärkstes Gegenargument:* Code auf `main` ohne Test des Chefs ist nur bei Kleinigkeiten erlaubt (201a), und `werte.json` wird später vielleicht die Datendatei des Spiels. *Entkräftet:* Das Werkzeug liest die Datei nur. Ob das Spiel dieselbe Datei nutzt, wird erst beim Bau der Regeln 2.0 entschieden, und dieser Bau geht über den Gerätetest. Ein Nein kostet nichts: Das Werkzeug läuft auch vom Zweig.

## Folgerung

„444a ja“: Team Jerry führt den Zweig zusammen. „Nein“: Das Werkzeug bleibt auf dem Zweig.

Erledigt: Antwort in den Vorrat (Zeile 444a, Team Jerry), Datei löschen.
