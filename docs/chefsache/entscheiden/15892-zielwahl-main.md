# 1589.2 · Soll die neue Zielwahl der Gegner auf main warten, bis Stufe 3 (1589.4) die Bewegung im Kampfort richtet?
Sokrates · 24.11., 10:10 · E Kampf · zweites „steckt fest“ (Lutz 08:42)
Kurz: Zielwahl fertig und geprüft, aber zwei Bewegungstests werden mit ihr rot; warten statt rotes main.
Beim Chef, weil: Obergrenze B

Geprüft an: Zweig `claude/moritz-1589.2`, Spitze e06810179; Rückmeldung 24.11., 08:42 in `docs/vorgang/1589.2.md`

**Frage:** Vorgang 1589.2 „Gegnerverhalten Stufe 1“: Die Gegner wählen ihr Ziel jetzt nach Plan (Wolf auf den Nächsten, Goblin-Späher auf die Schwächste, Flucht mit Ansage). Das ist gebaut und geprüft. Dein Wort vom 23.11., 10:04: nach main „nach grünem Lauf“. Der Lauf wäre aber rot: Weil die Gegner jetzt andere Ziele angreifen, laufen die Figuren im Kampf andere Wege, und zwei Bewegungstests schlagen an. Sollen wir es trotzdem auf main bringen oder warten?

**Votum:** „1589.2 B“: 1589.2 bleibt auf dem Zweig; Stufe 3 (1589.4) baut auf diesem Zweig auf und bringt beides zusammen grün nach main.

**Berührt:** 1589.4 (Stufe 3, Figuren in die Arena; startet vom Zweig 1589.2 statt von main), Rolle Kampf. 1589.3 (Rückwärtsgehen) nicht.

**Begründung:** Chef 23.11., 10:04 auf Vorlage Punkt 3: „1589.2 … nach grünem Lauf auf main ohne Testbuild“. Ein roter Lauf auf main hält jeden anderen Zweig an.

**Sachverhalt:**
- Zielwahl-Test arena_15892: 395 Fälle, 0 falsch; Logiktests 194 gut, 0 rot (Lutz 08:42).
- Mit Kaufmodellen gemessen: main ohne Fehler; Zweig: Angriffstest 824 1 Fehler (Schurke geht 2,87 m/s, 1,35-fach statt höchstens 1,15-fach), Wolftest 438 4 Befunde (Wolf läuft durch Wolf, Klinge durch Wolf ohne Treffer).
- Ursache laut Lutz: Kampfbewegung ist auf Zweig und main gleich; nur der Verlauf ändert sich (Wolf beißt Osgar 14-mal statt 6). Die Fehler liegen in Plätzen und Wegen des Kampforts, die bis 1589.4 ruhen.
- Kosten 1589.2 bisher: 19,54 $.

**Auswertung:**
- **A:** Befunde hinnehmen, jetzt nach main, Bewegungsfehler an 1589.4. Kosten: Tests 824/438 müssten gelockert oder ausgesetzt werden, sonst ist main rot; das widerspricht „nach grünem Lauf“.
- **B (Empfehlung):** 1589.2 wartet; 1589.4 baut auf dem Zweig, beides zusammen grün nach main. Kosten: keine neuen jetzt; der Zweig muss main regelmäßig aufnehmen (zuletzt ohne Konflikt).
- **Stärkstes Gegenargument gegen B:** Fertige Arbeit liegt länger auf einem Zweig; er liegt heute 87 Commits hinter main.
- **Entkräftet:** Lutz hat main heute ohne Konflikt eingemischt; 1589.4 ist der nächste Kampfschritt nach 1589.3, der Zweig wird also bald gebraucht.

**Folgerungen:** Bei B: Arbeitsplaner schreibt 1589.4 (hat noch keinen Auftrag; die Arena `godot/regeln/arena.gd` gibt es nur auf dem Zweig) auf Zweig `claude/moritz-1589.2`; 1589.2 ruht bis dahin. Bei A: neuer Auftrag, wie 824/438 bis 1589.4 behandelt werden.

Antwort: …
