# 1260 · Wie heißen die drei Punkte, die der Held in jedem Zug ausgibt?
Homer · 14.11., 23:40 · E Kampf · aus deinem Wort 22:47 („Homer soll ein paar vorschlagen.“)
Kurz: Name der drei Kampfpunkte je Zug samt Folgewörtern; Votum Takt / Beat, Lohe behielte das schon gebaute Glutbild.
Beim Chef, weil: Story (Name im Spiel, in jedem Kampf sichtbar)

Geprüft an: 773b89549 (Glutbild Stufe 2 auf `claude/tuffy-930-7-bedienung`; `DESIGN-GLUT.md` Abschnitte 2, 3, 8; Spieltexte und Glossar auf Zusammenstöße durchsucht)
Beim Chef, weil: Story

**Frage:** Im neuen Kampf hat der Held je Zug drei Punkte. Mit ihnen geht er Felder, führt eine Handlung aus (Schlag, Schuss, Zauber); was übrig bleibt, macht die Handlung stärker oder wartet als Haltung auf den Gegnerzug (Gegenschlag, Wachschuss, Wehr). Im Entwurf hießen sie „Glut“, das stößt sich mit Glutkugel, Glutstrahlen, Glutstab. Welcher Name soll es sein? Mit ihm wechseln drei Folgewörter: **Nachlegen** (übrige Punkte in die Handlung), **Verglimmen** (Ungenutztes verfällt am Zugbeginn), **Funke** (einmal je Kampf ein vierter Punkt, nach perfektem Ring oder unter halbem Leben; stößt sich mit Funkenpfeil).

**Votum:** „1260 A“: die Punkte heißen **Takt** (Beat), „drei Takte“; dazu Nachdruck, Verklingen, Aufbäumen. Willst du das gebaute Bild behalten: „1260 C“.

**Berührt:** 930 Glutsystem (Sokrates; Begriffe in `DESIGN-GLUT.md` und Glossar), 930.7 Bedienung und Bild (Tuffy, Film Lauf 476), Handbuchtexte zum Kampf (Homer), Name „Glutsystem“ in den Notizen.

**Begründung:** Die drei Punkte sind der Rhythmus eines Zugs, kein Vorrat wie Leben oder Mana. Ein Wort aus dem Takt passt zu dem, was schon da ist: der Ring wird im Takt getroffen, und beim Übergang in den Kampf schlägt schon ein Herz (`kampfblende.gd`, Herzschlag). Kurz, einsilbig in beiden Sprachen, zählbar, nirgends vergeben. Und es trennt die Punkte im Bild von den Feuerzaubern: wer Glutkugel wirft, soll nicht Feuer mit Feuer bezahlen.

**Sachverhalt:**
- Regeln und Begriffe: `DESIGN-GLUT.md` 2 (Tabelle), 3 (Regeln 1, 7, 12), Bild und Klang 8.
- **Schon gebaut (Stufe 2, 930.7, Tuffy `773b89549`, noch nicht auf `main`):** `glutbild.gd` (491 Zeilen) zeigt glimmende Glutstücke im Fußring, Asche nach dem Verbrauch, Aufflammen der Antwort, Zerfall in Funken, Glimmen der Waffe nach Nachlegen; Film Lauf 476. Feuergebunden davon sind Farben, Form der Kohlestücke, Funkenzerfall und Glimmen der Waffe (rund ein Drittel der Datei); Lage im Fußring, Zeichen der Haltung, Ziehen zur Waffe und Bedienung sind vom Namen unabhängig.
- Vergeben und daher nicht genommen: Glut, Funke (Zauber), die sechs Grundwerte, Schwung, Wucht (Wuchtschlag), Atem (Merkmal „Letzter Atemzug“), Zug (der Zug selbst), englisch Ember (Glutstrahlen = Ember Rays), Press (Knopftexte „Press …“).
- Keiner der Vorschläge steht bisher in einem Spieltext oder im Glossar.

**Auswertung:**
- **A Takt / Beat (Empfehlung):** „Du hast drei Takte.“ Bild: drei goldene Schläge im Fußring, die im Herzschlag pulsieren, verbraucht matt. Klang: ein dumpfer Schlag je gesetztem Takt. Folgewörter: **Nachdruck** / Weight („zwei Takte Nachdruck“), **Verklingen** / Fade, **Aufbäumen** / Surge. Kosten: Zeichnung der Marken in `glutbild.gd` neu (Farben, Form, Verklingen statt Funken, Waffe pulsiert statt glimmt), Klänge für Setzen, Nachdruck und Verklingen neu, Film 930.7 neu; Bedienung und Regeln bleiben.
- **B Herzschlag / Heartbeat (Vorschlag Sokrates):** „drei Herzschläge“. Bild: das Herz schlägt in jedem Zug dreimal. Folgewörter: Nachdruck / Weight, **Verebben** / Ebb, Aufbäumen / Surge. Kosten wie A. Stark im Bild, aber lang im Plural (13 Zeichen, eng auf dem Handy), und ein Herz liest man als Leben.
- **C Lohe / Blaze:** „drei Lohen“, altes Wort für Flamme. Das gebaute Bild bleibt ganz, ebenso der Klang aus Abschnitt 8 (Knistern, Fauchen, Zischen); **Nachlegen** und **Verglimmen** bleiben wörtlich, Funke wird **Stichflamme** / Flare. Kosten: nur Texte. Name, Bild und Klang passen genau zusammen, düster im Ton. Aber wieder Feuer neben Glutkugel, Flammenfächer und Glutstrahlen, im Wort wie im Bild, also dieselbe Verwechslung, die „Glut“ hatte; vielen ist das Wort fremd.
- **D Kerbe / Notch:** „drei Kerben“, wie auf dem Kerbholz einer Chronik, schwarz mit Goldrand (unsere Signatur: Tuschelinie, Gold als einziger Glanz). Folgewörter: **Vertiefen** / Deepen, **Verblassen** / Fade, **Goldkerbe** / Gold Notch. Kosten wie A. Am meisten Bornim im Bild, aber eine Kerbe ruht, sie treibt nichts an; als Währung des Handelns klingt sie träge.
- **Stärkstes Gegenargument gegen A:** C ist fertig und in sich stimmig; A kostet einen zweiten Durchgang am Bild und einen neuen Film, nur damit Punkte und Feuerzauber verschieden aussehen. Antwort: Qualität vor Eile (Oberste Direktive); die Punkte sieht man in jedem Zug jedes Kampfs, die Verwechslung mit Feuerzaubern also auch; und „Takt“ ist abstrakt, das Bild (pulsierendes Gold, Herzschlag) muss es spürbar machen.

**Folgerungen:** Sokrates trägt den Namen in `DESIGN-GLUT.md` (Begriffe, Regeln, Bild und Klang) und ins Glossar ein und benennt das System; bei A, B, D baut Tuffy das Bild von 930.7 um (bei C nichts); Homer schreibt die Handbuchtexte zum Kampf damit, ohne das Wort „Aktionspunkte“, sondern sagt, wofür die Punkte da sind (dein Wort 22:49).

Antwort: …
