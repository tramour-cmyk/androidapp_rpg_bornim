# 340.12 · Rollenspiegel 18.11.: welche der drei Änderungen nimmst du an?
Sokrates · 18.11., 09:08 (Spielvorschläge und Frage 11 entschieden, Rest offen) · B Abläufe · Mittwochsrunde (dein Wort 18.11., 00:03), Auswertung am Tag der Runde (340.6 A)
Kurz: Alle sieben Rollen haben heute 07:52–07:57 geantwortet. Drei Muster, drei Änderungen, ein Widerspruch in Frage 10, sieben Spielvorschläge.
Beim Chef, weil: Rollen und Accounts

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/24cd0c94f (main; `LISTE-ROLLENSPIEGEL.md` Woche 18.11.; `LISTE-IDEEN.md` Zeilen 23–29; `tools/neustart-haken.py` Zeile 24)

**Frage:** Heute haben Sokrates, Perikles, Homer, Ford, Diogenes, Tom und Jerry den Fragebogen zur eigenen Arbeit beantwortet. Aus jeder Runde darf höchstens eine Änderung je Rolle kommen, und für jede neue Regel fällt eine alte. Welche der drei Änderungen sollen gelten, und welche der sieben Spielvorschläge sollen als Vorgang gebaut werden?

**Votum:** „340.12 A“: Änderungen 1 bis 3 und die Streichung in Frage 10 annehmen.

**Berührt:** alle Rollen; Perikles (Werkzeug Änderung 1), Ford und Diogenes (Änderung 3, deckt sich mit Vorgang 1624), Tom, Jerry, Diogenes und ich (Änderung 2), Spike (Prüfungen).

**Begründung:** Zum ersten Mal nennen alle sieben denselben Fehler: gesehen und nicht gemeldet, „weil ich es für bekannt hielt“. Das ist kein Fehler einer Rolle, sondern eine Lücke im Ablauf: die Startwarnungen haben keinen Besitzer. Und vier von sieben haben ihre Besserungsschritte vom 13.11. nie begonnen, weil Frage 10 dein Ja verlangt, das nie kam; das widerspricht unserer eigenen Regel „Wie du deine Aufgabe erledigst, entscheidest du“.

**Sachverhalt:**
- **Muster 1, gesehen, nicht gemeldet (7 von 7, Frage 6):** Perikles (fünf Vorräte zu groß, Vorgang 1608), Ford (Startwerkzeug hält „gebaut, wartet auf Sammelbuild“ für startbar), Tom (dasselbe nur als Statuszeile), Jerry (Kampfkette wartet auf Block 2), Homer (Vorratsgrößen, Inhaltsverzeichnis), Diogenes (Prüfart „ohne dich, am Film gebilligt“), ich (Bremse nach 1129 A nie umgestellt). Homer nennt die Ursache: „alle sehen sie, keiner trägt ein“. Die Änderung 340.3 vom 02.11. (Hinweise als Zeile in den Vorrat) hat nicht gewirkt: 4 statt höchstens 2 (Diogenes 09.11.). Dazu ein Widerspruch, den drei Rollen nennen: der Start-Haken warnt ab 15 KB, `CLAUDE.md` erlaubt 30 KB (`tools/neustart-haken.py` Zeile 24); heute früh warnte er sechsmal.
- **Muster 2, fertig gemeldet, ohne dort hinzusehen, wo du hinsiehst:** Tom meldete 1515 „Streifen weg“, ohne das Hauptmenü nachzustellen (du fandest ihn 17.11., 21:34); Jerry schickte den Film 385.2 mit offenem Punkt (du: „beginnt hinterm Kopf“) und prüfte 760 nur am Rechner; Diogenes schloss vier Filmpunkte auf dein Daumen-hoch, ohne selbst hinzusehen, dort lag 1619; ich entschied 1569.1 und 1613 nachts ohne Bild in Spielgröße. Zusammen sind das die Fehler, die du als Erster findest (Haltung 7).
- **Muster 3, Abläufe kosten, das Spiel wartet:** Ford: Nachtschleife an der Wache (1610 bis 1618, sechs Neustarts, gut 20 $); Diogenes: rund 124 Läufe seit 13.11., spielnah etwa 8, dazu drei Starts ohne Startbares (zusammen 5,37 $); Perikles: fünf Werkzeugbauten in vier Tagen rund um Ford; ich: vier Neustarts an der Kontextgrenze mitten im Gespräch mit dir (je 4 bis 6 $). Zugleich: Tom 8 gebaute Muss ohne Build, Jerry 760, 709, 601.1 nach einer Woche nicht abgenommen.
- **Frage 10:** „Keinen davon beginnen, bevor der Chef Ja sagt.“ Ford, Jerry, Homer, Diogenes schreiben, sie hätten 0 von 3 begonnen, weil kein Ja kam (Frage 0). Dein Ja vom 15.11. (340.6 A) galt nur meinen vier Änderungen, nicht den 21 eigenen Schritten.
- **Selbsturteil (Frage 10):** alle sieben „ernste Ansage“, keine Rauswurf-, keine Lobstimme.

**Auswertung:**
- **A (Empfehlung):** drei Änderungen, je mit Zahl, Prüfung Mi 25.11. (zählt Diogenes), dazu eine Streichung:
  - **Änderung 1, alle (Muster 1):** jede Startwarnung bekommt im Werkzeug einen festen Besitzer; steht sie länger als 6 Stunden, legt das Werkzeug selbst einen Vorgang bei ihm an. Die Haken-Grenze wird auf 30 KB angeglichen. Bau Perikles, etwa eine Sitzung (5 bis 8 $). Erwartet: am 25.11. keine Startwarnung älter als 6 Stunden ohne Vorgang. **Fällt weg:** 340.3 (Hinweise als Vorratszeile, nicht gewirkt).
  - **Änderung 2, Tom, Jerry, Diogenes, Sokrates (Muster 2):** „behoben“, „weg“, „fertig“ zu einem Fehler, den du gesehen hast, nur mit Bild oder Film von genau dem Ort und in der Größe, in der du ihn gesehen hast (Spielkamera, Handygröße); Diogenes schließt Filmpunkte nur nach eigenem Blick auf ein Standbild. Werkzeug klein: `meldung.sh` nimmt „behoben“ zu einem Rückläufer nur mit Bild oder Film (etwa 3 $). Erwartet: bis 25.11. kein Rückläufer nach „behoben“. **Fällt weg:** 340.4 als eigene Spiegelzeile (Wirkung wurde nie gezählt); „Geprüft an“ bleibt und zeigt künftig auf das Bild.
  - **Änderung 3, Ford, Perikles, Diogenes (Muster 3):** das Startwerkzeug startet keine Rolle ohne Startbares und zählt „gebaut, wartet auf Sammelbuild“ nicht als startbar (gebündelt mit Vorgang 1624, schon Muss); derselbe Vorgang nach zwei Neustarts in einer Nacht wird angehalten und als Zeile für den Morgen stehen gelassen; mein Neustart an der Kontextgrenze erst bei 400 000 statt 200 000, wie im Kaufrepo. Erwartet: in der Woche bis 25.11. kein Start „nichts startbar“, keine Schleife über zwei Neustarts. **Fällt weg:** die Regeln zu Uhr-Sitzung und Ford-Starter in `ROLLE-BETRIEB.md` (beide seit 17.11. archiviert).
  - **Streichung in Frage 10:** „Keinen davon beginnen, bevor der Chef Ja sagt“ wird zu „Schritte, die nur die eigene Arbeit betreffen, gelten sofort; was andere Rollen bindet oder beim Chef liegt, wartet auf dein Ja.“ Damit laufen die eigenen Schritte der sieben ab heute (meine: jede Sperre vor dem Befolgen gegen Rollendatei und Archiv; jede Bildvorlage zum Aussehen in Spielkamera und Handygröße; jede Vorstellung mit Votum und Antwort auf das Gegenargument).
- **B:** nur Änderung 1 und die Streichung in Frage 10, Änderungen 2 und 3 nach der Zählung am 23.11. Billiger (eine Sitzung), Muster 2 und 3 laufen eine Woche weiter.
- **C:** nichts Neues, erst die Zählung der Änderungen vom 15.11. am 23.11. abwarten.
- **Stärkstes Gegenargument gegen A:** die Änderungen vom 15.11. (340.7 bis 340.10) werden erst am 23.11. gemessen; neue Änderungen davor vermischen die Messung, und Änderung 1 und 3 sind wieder Werkzeugbau, also selbst Muster 3. Antwort: Änderung 1 ersetzt die gescheiterte 340.3, Änderung 3 ist zum größten Teil schon Muss (1624); neu gebaut werden nur die Besitzerzuordnung und zwei Zahlen. Die Streichung in Frage 10 kostet nichts.

**Schon entschieden (09:00–09:05, Vorgangsarchiv):** Spielvorschläge als Vorgänge 1627–1632, Homers verworfen; Frage 11 neu gefasst. Offen bleiben nur die drei Änderungen und die Streichung in Frage 10.

**Folgerungen:** Nach „340.12 A“ lege ich Änderung 1 bei Perikles, Änderung 2 bei Perikles (Werkzeug) und als Satz bei Tom, Jerry, Diogenes, mir, Änderung 3 zu 1624 bei Diogenes und Ford, die drei Prüfungen bei Spike und Tom an, ändere Frage 10 und trage die Zeilen in `LISTE-ROLLENSPIEGEL.md` „Änderungen“ ein. Danach mit dir 1625 (Startprompt, meine Rollendatei schlanker).

Antwort: …
