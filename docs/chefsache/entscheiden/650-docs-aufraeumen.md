# 650 · Notizen aufräumen: von 88 Dateien auf etwa 45 · Sokrates · 08.11., 13:3x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs

**Anlass (Chef 13:24):** „Ich weiß nicht, wie viele Dateien wir unter Dokumente haben. Viel zu viele. Die liest doch kein Mensch. Da könnte man einen Ordner machen, alte Dateien und dann einige reinschieben, dann haben wir sie noch im Petto“.

**Befund:** `docs/` hat 88 Dateien (ohne Chefsache). Davon wurden 16 seit dem 28.10. nicht mehr geändert und werden von höchstens einer anderen Datei erwähnt; mehrere Themen stehen in mehreren Dateien (Story-Plan in 3, Handbuch in 3, Varianten in 2, Prüfbogen in 2, Spielsystem in 2).

**Frage:** Aufräumen in drei Schritten?
1. **Ordner `docs/alt/`** für Erledigtes und Abgelöstes; Kandidaten (je Datei vor dem Verschieben geprüft, ob noch etwas gilt; Werkzeuge, die sie lesen, werden umgestellt): `LISTE-ABLAUF-274`, `LISTE-ZENTRALE-VORGAENGE-275` (Umstellung 274/275 erledigt), `LISTE-UMZUG-348` (Umzug nach Godot erledigt), `LISTE-GRUNDSTAND-461` (leer), `LISTE-FORD2` (Ford 2 ruht), `LISTE-PROXMOX-RUNNER`, `LISTE-ARBEITSORTE` (264 ruht), `LISTE-PRUEFBOGEN-TESTER`, `LISTE-AUSWERTUNG-PRUEFBOGEN` (Kotlin-Zeit), `DESIGN-KAMPF-SPIELANLEITUNG-72-10A`, `DESIGN-MARS-AUFSTELLUNG` (in `DESIGN-KAMPF.md` aufgegangen?), `LISTE-ENGLISCH-338-1B`, `LISTE-GRAFIKWEG`, `LISTE-CC0-MODELLE` (geht in `LISTE-QUELLEN.md` auf, 623.1), `PRUEFBERICHT-ARCHIV`.
2. **Zusammenlegen, was ein Thema ist:** Bestiarium und Figuren → Figurenkatalog (649); Story-Pläne, Handbücher, Varianten je zu einer Datei (Homer, Spieltexte wortgetreu, nur umziehen); Kapitel-2-Entwürfe in `docs/kapitel2/` (gebraucht erst nach Kapitel 1).
3. **Inhaltsverzeichnis `docs/README.md` neu:** je Datei ein Satz „wofür, wer liest sie wann“; ein Werkzeug meldet jede Datei, die nicht drinsteht, und jeden toten Link.

**Votum Sokrates: ja.** Wer: Perikles führt (Abläufe), Homer zieht die STORY-Dateien zusammen, ich lege Schritt 1 als Liste mit Prüfung je Datei vor, bevor etwas verschoben wird.

## Auswertung
- **Stärkstes Gegenargument:** Werkzeuge, Haken und alte Einträge verweisen auf Dateinamen (z. B. `PRUEFBERICHT-ARCHIV.md` in `notiz.sh` und `commit-pruefung.py`, `LISTE-UMZUG-348.md` in vier Blender-Werkzeugen); Verschieben bricht Verweise, und ein falsch verschobenes Blatt mit noch gültigen Regeln geht verloren. **Antwort:** erst Verweisprüfung (Werkzeug), dann je Datei verschieben und Werkzeuge im selben Schritt umstellen; nichts wird gelöscht, `docs/alt/` bleibt lesbar, Git hat den Verlauf.
- Gegenargument: Aufräumen ist Arbeit an Abläufen, nicht am Spiel (oberste Direktive). **Antwort:** klein halten (Schritt 1 und 3 etwa eine Sitzung); es spart danach jedem Start Lesezeit und dir Suchzeit; Schritt 2 für die STORY-Dateien darf warten, bis Homer ohnehin daran arbeitet.

## Folgerungen
„650 ja“: ich lege die geprüfte Liste für `docs/alt/` vor (Schritt 1), Perikles baut die Verweisprüfung und das neue Inhaltsverzeichnis, Homer Schritt 2 für STORY. „650 1 und 3, 2 später“ geht auch.
