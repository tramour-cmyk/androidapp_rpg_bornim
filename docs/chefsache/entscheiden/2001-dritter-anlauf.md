# 2001 · Laufsperre als Obergrenze: ein letzter, enger Nachbesserungslauf?
Sokrates · 23.11., 16:15 · B Werkzeuge · Obergrenze A (3. Nein, 2001-Ü12)
Kurz: 2001 fiel zum dritten Mal durch; eine unbekannte Sitzung zählt still als frei; Votum: ein letzter enger Lauf.
Beim Chef, weil: Obergrenze A

Geprüft an: main 451a914a7 (grün), Nein Prüfer 23.11., 16:13 in docs/vorgang/2001.md

**Frage:** Das Werkzeug, das höchstens drei Fachkräfte zugleich laufen lässt (2001), ist zum dritten Mal von der Prüferin abgelehnt worden. Die ersten beiden Fehler sind behoben. Jetzt fand sie: Eine Fachkraft mit unbekanntem Namen (Isolde, 1694) zählt das Werkzeug still als „frei“. Dann könnte ein vierter starten. Soll es einen letzten, engen Nachbesserungslauf geben?

**Votum:** „2001 A“: ein letzter Lauf, nur dieser Fehler: Eine laufende Sitzung mit Vorgangsnummer im Titel zählt nach dem Bereich des Vorgangs; unbekannt zählt nie als frei; ein Testfall mit einem Namen außerhalb der Liste. Fällt er wieder durch: anhalten, Neuplanung.

**Berührt:** 2002 (Eilt auch über der Zahl, gleicher Code), Disponent Uwe, Alter Ego.

**Begründung:** Chef 14:37: „Und auf jeden Fall gegenprüfen lassen, bevor es losgeht.“ Die Prüfung greift; jeder Fehler war ein anderer, kein Kreis.

**Sachverhalt:**
- Nein 1 (14:43): Auftrag lückenhaft, nachgebessert. Nein 2 (15:54): Prüfsitzungen zählten als Fachkraft (R11), behoben 451a914a7. Nein 3 (16:13): unbekannter Name zählt als frei.
- Tests grün an 451a914a7: guthaben_test 0 Fehler, tools/t logik 193 gut.

**Auswertung:**
- **A (Empfehlung):** ein letzter enger Lauf, etwa 1 bis 2 $.
- **B:** 2001 anhalten, neu planen (Zählung nur aus Startsperren und Besetzung). Kostet einen Tag.
- **Stärkstes Gegenargument gegen A:** Drei Nein zeigen, dass die Zählung über Namen brüchig ist; ein vierter Fehler ist wahrscheinlich.
- **Was es entkräftet:** A dreht die Regel um: unbekannt zählt mit statt frei. Das Werkzeug irrt dann zur sicheren Seite, startet eher einen zu wenig als einen zu viel.

## Abgleich

`vorgang.py lehre suche 2001 obergrenze`: R11 (zweites Nein 2001, Prüfsitzungen zählten als Fachkraft; behoben 451a914a7, in A berücksichtigt).
Archiv 2001 obergrenze: 2001 Laufsperre als Obergrenze, Eilt

**Folgerungen:** Bei A startet Uwe eine Werkzeug-Fachkraft, Auftrag aus dem Nein 16:13; Prüfer prüft. Bei B plant der Arbeitsplaner neu.

Antwort: …
