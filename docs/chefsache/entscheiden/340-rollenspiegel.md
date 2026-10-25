# 340 · Rollenspiegel, erster Durchgang: drei Änderungen
Sokrates · 25.10., 09:21 · B Abläufe · M

## Frage

Alle sieben Rollen haben am 23.10. geantwortet (`LISTE-ROLLENSPIEGEL.md`). Drei Muster, je eine Änderung, möglichst als Werkzeug. Sollen A und C kommen, B erst bei Bedarf?

## Was schon erledigt ist

- Vorrang zwischen Neustart-Haken und Pause (Sokrates, Perikles, Ford): durch 347 geklärt („Pause bis …“).
- Fremde Prüfung vor jeder Vorlage (Sokrates, Homer, Tom, Jerry): seit 338.2 Pflicht.
- Einzelbild ohne vollen Vorschau-Lauf (Tom, Jerry): mit Godot kommt ein Bild am Rechner in etwa 1 Minute (348).
- Kennzahl je Rolle (Sokrates, Perikles, Ford, Diogenes ohne Zielwert): offen. Die Probe an Perikles läuft bis 06.11. (341); danach wird für alle entschieden.

## Muster und Änderungen

**Muster 1: Der Helfer prüft Einzelheiten, der Chef sieht das Ganze** (5 von 7 Rollen mit ungeprüften oder halb geprüften Vorlagen). Das gilt auch nach 338.2: Heute um 08:57 fand der Chef bei den Wölfen zuerst „alle drei in exakt gleicher Haltung“, „nicht zum Gegner gedreht“ und „die Helden völlige Klone“. Keiner dieser Punkte stand in den sieben Befunden des Helfers (Runden 17–28, Commit 5c27d9818).
→ **A:** Die erste der festen Prüffragen (338.2) lautet künftig: „Was fällt einem Spieler im ganzen Bild als Erstes auf?“ Erst danach kommen die Einzelfragen. Ersetzt keine Regel, nur die Reihenfolge der Fragen. Erwartet: Der erste Befund des Chefs steht im Helferbefund. Prüfdatum 01.11. Besitzer: Perikles.

**Muster 2: Wegsehen bei fremden Pflegefehlern** (5 von 7: Sokrates, Perikles, Homer, Ford, Tom). Jerrys zu lange Zeilen standen vom 23.10. (15) bis heute früh (14, `notiz.sh` 08:59) und sind jetzt behoben; jetzt meldet `regelcheck` nur noch einen Fehler, in meinem eigenen Vorrat.
→ **B:** Fords Stundenlauf (`lauf.py`) schreibt jeden Pflegefehler aus `regelcheck` einmal als Zeile „von Ford: Pflegefehler …“ in den Vorrat des Besitzers. Dafür fällt die Liste fremder Pflegefehler in `notiz.sh` weg. Erwartet: 0 Pflegefehler am 01.11. Besitzer: Perikles.

**Muster 3: Der Spiegel selbst wird verfälscht** (4 von 7 haben vor dem Antworten fremde Antworten gelesen, weil die Datei sie beim Öffnen zeigt).
→ **C:** `tools/rollenspiegel.sh <Rolle>` zeigt nur die Fragen und die eigene Antwort der Vorwoche und hängt die neue Antwort an. Ersetzt den Satz „erst antworten, dann lesen“. Erwartet: 0 Hinweise „mitgelesen“ am 30.10. Besitzer: Sokrates.

Dazu der Freitagstermin in Fords Lauf (an Perikles), wie am 23.10. beschlossen.

## Empfehlung

A und C ja, B noch nicht. A kostet nichts. C ist ein kleines Werkzeug, etwa eine halbe Sitzung. B nur, wenn Pflegefehler am 01.11. wieder länger als einen Tag stehen; die Liste ist heute fast leer.

## Stärkstes Gegenargument

Mitten im Umzug nach Godot (348) zieht jede Ablaufarbeit Guthaben vom Spiel ab, und die oberste Direktive heißt Kapitel 1. Wer nur eines will, nimmt A, weil es Rückläufer beim Chef direkt spart.

## Berührte Vorgänge

340 (Vorrat Sokrates), 338.2, 341, 347, 348.
