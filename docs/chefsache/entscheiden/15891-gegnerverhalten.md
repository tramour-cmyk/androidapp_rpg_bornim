# 1589.1 · Gilt das Regelblatt Gegnerverhalten mit den Ergänzungen, und wird es in vier Stufen gebaut?
Sokrates · 17.11., 22:14 · E Kampf · aus deinem Wort 17:58/18:05 („gemeinsam, nicht im stillen Kämmerchen“), Schritt 4
Kurz: Regelblatt Gegnerverhalten nach dem Gegenlesen durch Jerry, Homer, Perikles und Tom; Bau in vier Stufen ab Sa 20:00; offen ist der Lohn, wenn Gegner fliehen.
Beim Chef, weil: neue Richtung im Spielgefühl

Geprüft an: fe160ec12 (`docs/DESIGN-GEGNER.md`, Abschnitt „Ergänzungen“: Tom 22:08, Jerry 22:08, Homer 22:14, Perikles 22:15)

**Frage:** Das Regelblatt sagt, was Gegner im Kampf wollen und wie sie sich bewegen. Entschieden hast du schon drei Teile: das Blatt als Grundlage (Kampf intern als 2D-Feld, 3D nur fürs Bild), die vier Denkweisen mit ihrem Ziel und die Flucht. Jerry, Homer, Perikles und Tom haben gegengelesen und ergänzt. Gilt das Blatt jetzt mit ihren Ergänzungen? Und soll es in vier Stufen gebaut werden? Offen ist außerdem eine Frage, die nur du entscheiden kannst: Was bekommt der Held, wenn ein Gegner flieht?

**Votum:** „1589.1 A“, dazu bei der Flucht „Lohn A“.

**Berührt:** 1589 Bau (Jerry), Rückwärtsgehen für Menschengestalten (Tom), Ansagen (Homer), Rechnung 444 (Jerry); 1526 (vorderer Wolf weicht ganz nach hinten) geht darin auf; 760 und 1068 kommen vorher in den nächsten Build; 1532 bleibt eigene Kür; Kamera bleibt 1402; Texte zu 915 (Homer), falls der Lohn sich ändert.

**Begründung:** Du hast gesagt „den Motor an sich … kein Schnellschuss“ (17:58) und „Wir ergänzen uns.“ (18:05). Alle vier Gegenleser bestätigen das Gerüst. Ihre Ergänzungen schließen Lücken, keiner von ihnen will einen anderen Weg. Zwei Gegenleser stoßen unabhängig auf denselben Widerspruch beim Lohn.

**Sachverhalt:**
- **Heute gibt es kein Blatt** (Jerry): Der Kampf kennt je Seite 4 Plätze (`mars.gd` 118) und 3 Abstände (`kerbe.gd` 17–19). Wie eine Figur geht, entscheidet das Bild (`figur.gd` 1809–2100). Das Ziel wählt der Gegner zufällig aus der vorderen Reihe (`dice.pick`, Perikles).
- **Bewegung fehlt** (Tom): Menschengestalten können nur vorwärts gehen und rennen und sich um 90 oder 180 Grad drehen. Rückwärts gehen und Seitschritte gibt es im gekauften Paket UAL2, eingebaut sind sie nicht.
- **Kerben** (Jerry, Perikles): Abschnitt 4 und 9 setzen das Kerbensystem voraus. Das ist im Spiel noch aus.
- **Widerspruch Lohn** (Homer, Perikles): Abschnitt 6 gibt für einen Geflohenen die volle Erfahrung und die halbe Beute. Entschieden und gebaut ist aber 870c 3 A/915: Wölfe, die vor Feuer fliehen, bringen weder Beute noch Erfahrung. Das steht in `LISTE-BESTIARIUM.md` Zeile 49, in `STORY-BRS-KAMPF.md` 51 und im Code (`mars.gd` 343).
- **Homers Funde:**
  - In der Tabelle je Art fehlen Skelett, Grabhund und Säureschnecke.
  - Der Kobold kämpft im Rudel.
  - Die Ratte flieht nach dem Blatt nie, obwohl sie allein feige ist.
  - Untote setzen sich nicht ab, sie drücken nach. Krogg versperrt, statt zurückzuweichen.
- **Kosten** (Jerry): etwa 10–13 Sitzungen. Ein kleiner Weg auf den heutigen 4 Plätzen kostet 2–3 Sitzungen, behebt aber nur, was du gesehen hast, nicht die Ursache.

**Auswertung:**
- **A (Empfehlung): das Blatt mit den Ergänzungen, gebaut in vier Stufen** (Perikles), ab Sa 20:00 nach dem Stillstand. Jede Stufe ist ein eigener Vorgang mit eigenem Build:
  1. Das Blatt läuft unsichtbar mit. Dazu kommen Zielwahl, Trägheit, Versperren und Flucht, und die Rechnung 444 lernt das Blatt. Prüfbar mit Logiktest.
  2. Daneben baut Tom Rückwärtsgehen und Seitschritt für Menschengestalten (bis 2 Felder rückwärts absetzen, Seitschritt nur als einzelner Ausweichschritt, Platztausch nacheinander).
  3. Die Figuren gehen auf dem Blatt: vorn bleibt vorn, 1526, Untote drücken nach, Krogg versperrt. Die alten Regeln im Bild fallen weg, es gibt einen Film.
  4. Die Reihenfolge der Bosse (Jerry mit Homer).

  Außerdem kommt in die Tabelle: Skelett, Grabhund (geht auf den Gelähmten) und Säureschnecke, alle stur. Der Kobold kämpft im Rudel. Die letzte Ratte flieht, sobald sie verwundet ist. Fällt Grak, fliehen die Goblins, wie das Rudel ohne Grimmzahn (Story, Homer). Das Blatt gilt auch ohne Kerben; das Kerbensystem bleibt ein eigener Entscheid. Homers Ansagen gelten als Entwurf, die Endfassung schreibt er beim Bau. Später als Kür: weitere Absprachen und Eigenarten (das Wildschwein geht auf den, der es zuletzt getroffen hat).
- **B: der kleine Weg**: Ziel, Trägheit, vorn bleibt vorn und 1526 auf den heutigen 4 Plätzen, 2–3 Sitzungen. Den Fehler, den du gesehen hast, behebt er schneller. Die Regeln blieben aber im Bild, und nach dem Blatt würde alles ein zweites Mal gebaut (Bekannte Fehler 302.3).
- **Stärkstes Gegenargument gegen A:** 10–13 Sitzungen bei Jerry, der schon die meisten Muss trägt, und du siehst lange nichts Neues im Kampf. Dagegen spricht: Für Kapitel 1 gibt es keinen Termin. Jede Stufe bringt einen eigenen Build. Tom baut die Bewegung parallel.

**Lohn, wenn ein Gegner flieht:**
- **Lohn A (Empfehlung):** Zwei Fälle, zwei Regeln. Treibt der Held Gegner mit Feuer in die Flucht, gibt es weder Beute noch Erfahrung, wie entschieden (915). Das ist der Preis des Feuers, und Feuer bleibt eine echte Wahl. Flieht ein Gegner von selbst (Rudel ohne Anführer, Goblin allein, Goblins ohne Grak), gibt es die volle Erfahrung und die halbe Beute. Wer ihn festhält, bekommt alles.
- **Lohn B:** Es gilt überall die Regel aus 915: Wer flieht, bringt nichts. Das ist einfacher. Dann wird aber jeder Fliehende zur Pflichtjagd, denn sonst geht der Lohn des Kampfs verloren.
- **Stärkstes Gegenargument gegen Lohn A:** Zwei Regeln für dasselbe Bild, ein Gegner läuft weg, muss der Spieler erst lernen. Dagegen spricht: Er sieht den Unterschied, weil die Flucht vor Feuer eine eigene Ansage und eine eigene Kampfzeile hat (705a B).

**Folgerungen:**
- Ich arbeite die Ergänzungen in `DESIGN-GEGNER.md` ein.
- Perikles legt die Stufen als Vorgänge 1589.2 bis 1589.5 an.
- Homer passt die Texte an, falls der Lohn sich ändert.
- 760 und 1068 kommen in den nächsten Build.
- Jerrys Halt vom 17.11., 18:15 endet mit dem Entscheid.

Antwort: …
