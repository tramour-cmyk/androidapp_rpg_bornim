# 438b · Wölfe: lange Pausen bei den Ansagen
Jerry · 01.11., 10:55 · E Kampf

**Frage:** Im Film r2 stand der Kampf 18 von 48 s still (Prüfer). Gemessen: fast nur bei den Ansagen der Wölfe. Jede Ansage sind zwei Zeilen, „Wolf 1 kündigt an: Anspringen (auf Ansgar).“ und „Er geht tief, die Hinterläufe gespannt …“, je 1,1 s, in denen sich nichts bewegt; zu Beginn drei Wölfe, also 7,7 s bis zum ersten Sprung. Was soll gelten?
1. Ansage und Beschreibung in einer Zeile, ein Halt von 1,1 s (zu Beginn 4,4 s statt 7,7 s).
2. Wie jetzt, aber der Wolf duckt sich während der beiden Zeilen langsam und knurrt (Bewegung statt Stillstand, gleich lang).
3. Wie jetzt.

**Votum Jerry:** 1. Die Beschreibung erklärt nur die Ansage; zwei Halte für einen Gedanken bremsen, und das Kampftempo im Menü bleibt für Langsamleser.
**Berührt:** `godot/kampf/kampfort.gd` (_play_say), Kampftempo.

## Sachverhalt

- Messung `tests/wolf_mess_438.gd` (Kleriker, SEED 7, 90 s): 36 s ohne jede Bewegung, Spannen nach „kündigt an“, nach der Beschreibung und nach „Anspringen!“; nach einem Biss oder Hieb nur bis zum Heimweg.
- Jede Zeile ohne Bewegung hält `SAY_MS` = 1,1 s; Anlauf, Biss und Heimweg dauern, so lange sie dauern.

## Auswertung

- Stärkstes Gegenargument gegen 1: zwei Zeilen in 1,1 s sind auf „Normal“ knapp zu lesen; wer liest, muss das Tempo senken. Dagegen: die zweite Zeile ist Stimmung, nicht Regel; verpasst man sie, fehlt nichts.
- Gegen 2: kostet eine eigene Bewegung (der Kaufwolf hat nur Ruhe, Gehen, Rennen, Angriff, Fressen, Heulen, Tod) und eine Prüfrunde; die Wartezeit bleibt.

## Stellungnahme Sokrates (01.11., 11:0x)

- *Stärkstes Gegenargument gegen 1:* Zwei Zeilen in 1,1 s sind knapp zu lesen; wer die Stimmungszeile mag, verliert sie.
- *Wie es zu entkräften ist:* Die Beschreibung bleibt vollständig im Kampfbericht (416.5), dort kann man sie nachlesen; wer langsam liest, stellt das Kampftempo im Menü niedriger. Damit geht nichts verloren, nur der Stillstand.
- *Widerspruch zu Entschiedenem:* keiner; „Kampf nie langweilig“ (Leitbild) spricht für 1.
- *Kosten:* gering, eine Stelle in `kampfort.gd`.
- *Empfehlung:* 1.
