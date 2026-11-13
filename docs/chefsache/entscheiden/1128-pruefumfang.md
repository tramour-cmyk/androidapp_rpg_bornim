# 1128 · Was heißt „vom Chef getestet“ künftig: am Handy frei spielen und Bilder ansehen statt jede Prüffrage abgehen?
Sokrates · 13.11., 12:03 · B Abläufe · aus deinem Wort 11:49, 11:58, 12:02
Kurz: Prüffragen nur noch für Neues, und zwar als Bild oder Film; am Handy spielst du frei; was du nicht bemängelst, gilt als getestet

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/94621abe7%5E/docs/chefsache/ansehen/t282-dorf.md (Prüfliste 282) und die Ergebnisse der Prüflisten 277, 278, 280 in Git; Vorgangsarchiv 201a.1; `tools/startbar.py` (Sperre 620.1 B)

**Frage:** Heute bekommt jeder fertige Vorgang eine Prüffrage, und du gehst sie alle am Handy ab. Das kostet dich Zeit für Dinge, die ein Bild genauso zeigt oder die ohnehin passen. Soll „vom Chef getestet“ künftig jede Form von Test sein: frei am Handy spielen, Bild oder Film ansehen, im Gespräch klären?

**Votum:** „1128 B“. Zweite Meinung: Perikles (unten, auf deinen Zuruf 12:02).

**Berührt:** Tom, Jerry, Spike, Tuffy (Prüflisten), Perikles (Abläufe), Diogenes (prüft Bautests, zählt Funde), Werkzeuge `startbar.py`, Commit-Prüfung, Test `pruefliste_1020`.

**Begründung:** Dein Wort 11:58: „Da gibt es verschiedene Möglichkeiten des Tests und da muss das halt gelten … Für Pillepalle.“ 12:02: „Ich will nicht 1000 sinnlose Prüffragen haben, was man im Bild auch sehen kann.“ Den Grundsatz hast du am 19.10. schon gesetzt (201a.1): „Gerätetest nur, wo er etwas finden kann.“ Die Prüflisten wenden ihn nicht an.

**Sachverhalt** (Prüflisten 277, 278, 280, 282, ausgezählt):
- Etwa 100 Prüffragen, davon rund 80 mit „passt“, ohne dass du etwas gefunden hast. Am deutlichsten war Build 280 mit 41 Fragen, 39 davon passten.
- Deine Funde: rund 19 an einer Prüffrage, rund 12 außer der Reihe (277: 4, 278: 5, 282: 1, dazu Beifunde wie das Dauer-„hand scratch“). Etwa vier von zehn Funden kommen also ohnehin, ohne dass wir danach fragen.
- Von den Funden an Prüffragen hätte die Mehrheit auch ein Bild oder Film gezeigt: Staub nicht zu sehen (dreimal), Weg am Schlagbaum, „Betrunken“ senkrecht, Damenstand, Flasche so groß wie ein Ölfass. Nur das Handy zeigt Bildrate, Ruckeln, Klang, Bedienung, Abläufe.
- Pim war allerdings eine Prüffrage (282.9: „Pim geht heim“). Er wäre auch beim freien Spielen aufgefallen.
- Jeder Bau macht schon Bilder im selben Lauf wie die APK. Für einzelne Vorgänge gibt es eigene Bildschritte (Kartenrand, Rock, Damenstand, Höhle).

**Auswertung:**
- **A:** Jeder Vorgang bekommt eine von drei Arten. Handy: Ablauf, Bedienung, Gefühl, Klang. Bild oder Film: alles Aussehen. Ohne dich: Regeln und Technik, die ein Bautest prüft. Für 282 wären das 5 Handyfragen und 15 Bilder statt 21 Fragen gewesen.
- **B (Empfehlung):** wie A, aber mit drei Unterschieden. Ein Bild gibt es nur für Neues und für Vorentscheide, die du billigen sollst. Kleinigkeiten und Nachbesserungen bekommen weder Frage noch Bild. Am Handy bekommst du statt Fragen einen Weg: welche Stationen der Build berührt, und dort spielst du frei. Was du in einem Build nicht bemängelst, gilt als getestet. Für 282 wären das etwa 6 Bilder und ein Weg über 5 Stationen gewesen.
- **C:** wie heute.

**Rundum: Gefahren, was wir nicht haben, was wir in Kauf nehmen (bei B):**
1. **Rückschritte gegen alt** bleiben länger unbemerkt. Das ist unsere größte Schwäche (620). Was du nicht ansiehst, findest du vielleicht erst zwei Builds später, und dann ist es teurer. Abhilfe: Der Abgleich mit der alten Fassung je Ort bleibt Pflicht des Teams vor der Testbitte. Diogenes zählt, wie viele Funde Rückschritte sind. Steigt die Zahl, zurück zu A.
2. **Ein Bild zeigt nur, was wir zeigen wollen.** Abhilfe: Die Bilder kommen aus demselben Lauf wie die APK, nie aus einer Probe. Was sich bewegt, kommt als Film.
3. **Was du nie besuchst, gilt trotzdem als getestet.** Ungeprüftes kommt so auf `main`. Abhilfe: Die Prüfliste nennt den Weg, also welche Stationen der Build berührt (das Testmenü macht das schnell). Wir nehmen es in Kauf: Was du findest, wird ein neuer Vorgang.
4. **Herausnehmen geht nicht mehr.** Heute fliegt ein durchgefallener Punkt per `git revert` heraus, ohne Prüffragen gibt es nichts herauszunehmen. Ein Fund wird dann ein Rückläufer, der im nächsten Build behoben wird. Ein schwerer Fehler (Absturz, Spielstand kaputt) hält wie heute den ganzen Build auf.
5. **Bilderflut statt Fragenflut** (du hast „12 Vorlagen“ schon einmal beklagt). Abhilfe: Alle Bilder eines Builds kommen auf eine Seite, höchstens etwa zehn, nur Neues.
6. **Die Sperre für die Teams löst sich schneller.** Dann wird wieder mehr parallel gebaut, und Funde könnten sich wiederholen (Schwäche 2). Abhilfe: Die Regel „wiederholte Funde vor allem anderen“ (620.1 A) bleibt.
7. **Was uns fehlt:** Es gibt kein Werkzeug, das die Bilder je Vorgang auf eine Seite legt. Heute baut jedes Team Bildschritte von Hand, dafür braucht es einen allgemeinen Schritt „Bilder je Vorgang“ im Bau. Der Test `pruefliste_1020` und die Commit-Prüfung kennen die neuen Arten noch nicht.
8. **Was wir gewinnen:** Deine Zeit je Build sinkt von 20 bis 40 Fragen auf etwa 5 bis 10 Bilder und einen Weg. Die Teams warten weniger auf den Test, weil 55 Vorgänge nicht mehr einzeln auf dich warten.
- **Stärkstes Gegenargument gegen B:** Du bist bisher unser bester Prüfer. Weniger gezielte Fragen heißen weniger gefundene Fehler je Build. Dagegen spricht: Vier von fünf Fragen finden nichts, vier von zehn Funden kommen ohne Frage. Und bei Gefahr 1 ist der Rückweg zu A festgelegt.

**Zu ändern bei B** (Bau Perikles, Werkzeuge Tom):
- `CLAUDE.md` Feste Regeln: „kein Code auf `main` ohne Test des Chefs“ wird zu „ohne Test des Chefs: frei am Handy, Bild oder Film, Gespräch; nicht Bemängeltes gilt als getestet“. 201a.1 geht darin auf (Regelbilanz).
- `LISTE-CHECK-BUILD-TEST.md`: Aufbau der Prüfliste (Weg, Bilder für Neues, „Ohne dich“ mit Bautest), Regel 12 (Rückläufer statt Herausnehmen), Regel 13.
- `ROLLE-ENTWICKLUNG.md` (Testbitte), `DESIGN-ABNAHME.md` (Vorlage nur für Neues).
- `tools/startbar.py`: Die Sperre 620.1 B zählt nach dem Test eines Builds alle Vorgänge darin als getestet.
- Test `pruefliste_1020`, Commit-Prüfung, `godot.yml`: ein Schritt „Bilder je Vorgang“.

**Folgerungen:** Bei B: Perikles baut die Regeln, Tom die Werkzeuge. Schon die Prüfliste für 283 schreibt Tom nach B. Ich lese sie gegen, Diogenes zählt ab 283 die Rückschritte. Bei A ebenso, nur mit einem Bild je Vorgang. Bei C bleibt alles, wie es ist.

**Zweite Meinung Perikles:** …

Antwort: …
