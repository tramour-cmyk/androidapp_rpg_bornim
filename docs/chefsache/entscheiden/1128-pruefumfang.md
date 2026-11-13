# 1128 · Prüfst du am Handy künftig nur noch, was nur das Handy zeigen kann, und den Rest am Bild oder Film?
Sokrates · 13.11., 11:52 · B Abläufe · aus deinem Wort 11:49
Kurz: je Vorgang in der Prüfliste eine Art: Handy (Ablauf, Bedienung), Bild/Film (Aussehen) oder ohne dich (Regeln und Technik mit grünem Bautest)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/94621abe7%5E/docs/chefsache/ansehen/t282-dorf.md (Prüfliste Build 282), Vorgangsarchiv 201a.1, `CLAUDE.md` Feste Regeln

**Frage:** Heute bekommt jeder fertige Muss-Vorgang eine Zeile in der Prüfliste, und du gehst jede am Handy ab: Build 282 hatte 21 Punkte, in Build 283 warten 55 fertige Vorgänge (Tom 17, Jerry 38). Die meisten davon sind Aussehen, das ein Bild oder Film genauso zeigt. Sollen wir die Prüfliste je Vorgang einer von drei Arten zuordnen, so dass du am Handy nur noch einen kurzen Spielweg gehst?

**Votum:** „1128 A“: ab Build 283 drei Arten je Vorgang, am Handy höchstens etwa sechs Punkte als ein zusammenhängender Weg.

**Berührt:** Tom und Jerry (Prüflisten ab 283), Perikles (Ablauf, Muster der Prüfliste), Diogenes (prüft „ohne dich“), Werkzeug `startbar.py` (die Sperre 620.1 zählt ein Urteil am Bild als getestet), Regel „kein Code auf main ohne Test des Chefs“.

**Begründung:** Dein Wort 11:49: „Warum muss ich denn das immer testen? … vieles … hätte man auch mit einem Bild oder mit einem Film klären können … wenn es mir auffällt als Fehler, dann fällt es mir halt auf. Aber das sind so viele Kleinigkeiten.“ Den Grundsatz hast du schon am 19.10. gesetzt (201a.1): „Gerätetest nur, wo er etwas finden kann“. Er steht im Archiv, die Prüflisten wenden ihn nicht an: dort bekommt jeder Vorgang einen Handypunkt.

**Sachverhalt:**
- Build 282, 21 Punkte, nach Art sortiert: **nur am Handy** 5 (Pim: Knöpfe und Gold, Met bis „Betrunken“ und Leiste antippen, Höhle: Krogg, Schlüssel, Gitter, Lyra); **Bild oder Film reicht** 15 (Startbild, Hauptmenü, Sicht im Dorf, Staub, Kartenrand, Röcke, Tische, Borin sitzt, Chronik, Osric, Nacht, Höhle ansehen, Lyras Stand, Lyra wendet sich, Wechselschirm); **ohne dich** 1 (Kurze Erholung gibt kein Leben: das prüft der Bautest `brs_held_870` schon genau).
- Deine 6 Funde in 282: 4 hätte ein Bild gezeigt (Weg am Schlagbaum, „Betrunken“ senkrecht, Damenstand, Karte), 1 nur das Handy (Pim bleibt stehen), 1 war Technik (Höhle nicht begehbar; der Bautest `hoehle_492` läuft seit heute im Bau mit).
- Bilder und Filme macht jeder Bau schon (Schritt „Standbilder“ im selben Lauf wie die APK). Damit ist es dasselbe Spiel, keine Probe nach anderer Methode.

**Auswertung:**
- **A (Empfehlung):** Der Entwickler ordnet beim Schreiben der Prüfliste jedem Vorgang eine Art zu. **Handy:** Ablauf, Bedienung, Kampfgefühl, Klang. Das wird ein zusammenhängender Weg mit höchstens etwa sechs Punkten, auf dem du frei spielst; was dir dabei auffällt, meldest du. **Bild/Film:** alles Aussehen und jede Bewegung, aus demselben Lauf, auf einer Seite in der Chefsache. Du sagst je Bild „passt“ oder „falsch“, das zählt als getestet. **Ohne dich:** Regeln, Zahlen, Technik, die ein Bautest prüft. Diogenes bestätigt, dass der Test genau das prüft, dann geht es mit auf `main`. Aufwand: Prüflisten wie bisher, ein Bildschritt je Bau schon vorhanden; die Seite mit den Bildern schreibt der Entwickler. Für 282 hätte das 5 Handypunkte statt 21 bedeutet.
- **B:** wie A, zusätzlich bekommen Kleinigkeiten am Aussehen (Nachbesserungen an schon gebilligten Stellen) gar kein Bild mehr. Sie gehen mit grünem Bautest auf `main`, und du findest sie beim Spielen, wenn etwas nicht stimmt. Das ist schneller, aber Rückschritte gegen alt sind unsere größte Schwäche (620), und die findest dann wieder du.
- **C:** alles bleibt am Handy wie heute.
- **Stärkstes Gegenargument gegen A:** Ein Bild zeigt nur, was wir zeigen wollen. Am Handy findest du, woran keiner gedacht hat (Pim bleibt stehen, Höhle nicht begehbar). Entkräftet so: Jeder Bau hat trotzdem einen Handyweg durch sein Thema, auf dem du frei spielst. Technisches Versagen fängt der Bautest, der den Ort durchspielt (`hoehle_492`). Was sich bewegt, kommt als Film, nicht als Standbild.

**Folgerungen:** Bei A: ich trage es beim Besitzer ein. Perikles setzt die Regel (ersetzt in `CLAUDE.md` Feste Regeln „kein Code auf main ohne Test des Chefs“ durch „ohne Urteil des Chefs am Handy oder am Bild; Regeln und Technik mit grünem Bautest und Diogenes“, 201a.1 geht darin auf) und das Muster der Prüfliste. Tom und Jerry wenden es ab der Prüfliste von 283 an. `startbar.py` zählt ein Bildurteil für die Sperre 620.1 als getestet. Ich lese die erste Prüfliste gegen. Bei B ebenso, ohne Bilder für Nachbesserungen. Bei C bleibt alles, wie es ist.

Antwort: …
