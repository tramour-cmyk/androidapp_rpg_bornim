# 1128 · Prüfen wir künftig jeden Vorgang in der passenden Art (Prüffrage am Handy, Bild oder Film, Bautest) statt alles als Prüffrage am Handy?
Sokrates · 13.11., 12:03 · B Abläufe · aus deinem Wort 11:49, 11:58, 12:02, 12:06
Kurz: je Vorgang die passende Prüfart: Handy-Prüffrage nur für Ablauf, Bedienung, Gefühl, Klang; Aussehen als Bild oder Film; Regeln und Technik über den Bautest

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/94621abe7%5E/docs/chefsache/ansehen/t282-dorf.md (Prüfliste 282) und die Ergebnisse der Prüflisten 277, 278, 280 in Git; Vorgangsarchiv 201a.1; `tools/startbar.py` (Sperre 620.1 B)

**Frage:** Heute bekommt jeder fertige Vorgang eine Prüffrage, und du gehst sie alle am Handy ab. Das kostet dich Zeit für Dinge, die ein Bild genauso zeigt oder die ohnehin passen. Soll „vom Chef getestet“ künftig jede Form von Test sein: frei am Handy spielen, Bild oder Film ansehen, im Gespräch klären?

**Votum:** „1128 A“, mit den beiden Änderungen von Perikles und einem Laufnachweis (unten, Abgleich 12:11). Zweite Meinung: Perikles (unten, auf deinen Zuruf 12:02).

**Berührt:** Tom, Jerry, Spike, Tuffy (Prüflisten), Perikles (Abläufe), Diogenes (prüft Bautests, zählt Funde), Werkzeuge `startbar.py`, Commit-Prüfung, Test `pruefliste_1020`.

**Begründung:** Dein Wort 11:58: „Da gibt es verschiedene Möglichkeiten des Tests und da muss das halt gelten … Für Pillepalle.“ 12:02: „Ich will nicht 1000 sinnlose Prüffragen haben, was man im Bild auch sehen kann.“ Den Grundsatz hast du am 19.10. schon gesetzt (201a.1): „Gerätetest nur, wo er etwas finden kann.“ Die Prüflisten wenden ihn nicht an. 12:06: „Wenn es aber Dinge gibt, die ich testen soll, dann brauche ich dafür natürlich Prüffragen. Mir ging es einfach um die Fülle der Prüffragen und ob manche davon nicht eigentlich anders auch zu lösen sind.“

**Sachverhalt** (Prüflisten 277, 278, 280, 282, ausgezählt):
- Etwa 100 Prüffragen, davon rund 80 mit „passt“, ohne dass du etwas gefunden hast. Am deutlichsten war Build 280 mit 41 Fragen, 39 davon passten.
- Deine Funde: rund 19 an einer Prüffrage, rund 12 außer der Reihe (277: 4, 278: 5, 282: 1, dazu Beifunde wie das Dauer-„hand scratch“). Etwa vier von zehn Funden kommen also ohnehin, ohne dass wir danach fragen.
- Von den Funden an Prüffragen hätte die Mehrheit auch ein Bild oder Film gezeigt: Staub nicht zu sehen (dreimal), Weg am Schlagbaum, „Betrunken“ senkrecht, Damenstand, Flasche so groß wie ein Ölfass. Nur das Handy zeigt Bildrate, Ruckeln, Klang, Bedienung, Abläufe.
- Pim war allerdings eine Prüffrage (282.9: „Pim geht heim“). Er wäre auch beim freien Spielen aufgefallen.
- Jeder Bau macht schon Bilder im selben Lauf wie die APK. Für einzelne Vorgänge gibt es eigene Bildschritte (Kartenrand, Rock, Damenstand, Höhle).

**Auswertung:**
- **A (Empfehlung):** Jeder Vorgang bekommt eine von drei Arten. Handy: Ablauf, Bedienung, Gefühl, Klang. Bild oder Film: alles Aussehen. Ohne dich: Regeln und Technik, die ein Bautest prüft. Für 282 wären das 5 Handyfragen und 15 Bilder statt 21 Fragen gewesen.
- **B:** wie A, aber mit drei Unterschieden. Ein Bild gibt es nur für Neues und für Vorentscheide, die du billigen sollst. Kleinigkeiten und Nachbesserungen bekommen weder Frage noch Bild. Am Handy bekommst du statt Fragen einen Weg: welche Stationen der Build berührt, und dort spielst du frei. Was du in einem Build nicht bemängelst, gilt als getestet. Für 282 wären das etwa 6 Bilder und ein Weg über 5 Stationen gewesen.
- **C:** wie heute.

**Rundum: Gefahren, was wir nicht haben, was wir in Kauf nehmen** (1, 3, 4 gelten vor allem bei B; bei A hat jeder Vorgang weiter seinen Prüfpunkt, nur in anderer Form):
1. **Rückschritte gegen alt** bleiben länger unbemerkt. Das ist unsere größte Schwäche (620). Was du nicht ansiehst, findest du vielleicht erst zwei Builds später, und dann ist es teurer. Abhilfe: Der Abgleich mit der alten Fassung je Ort bleibt Pflicht des Teams vor der Testbitte. Diogenes zählt, wie viele Funde Rückschritte sind. Steigt die Zahl, zurück zu A.
2. **Ein Bild zeigt nur, was wir zeigen wollen.** Abhilfe: Die Bilder kommen aus demselben Lauf wie die APK, nie aus einer Probe. Was sich bewegt, kommt als Film.
3. **Was du nie besuchst, gilt trotzdem als getestet.** Ungeprüftes kommt so auf `main`. Abhilfe: Die Prüfliste nennt den Weg, also welche Stationen der Build berührt (das Testmenü macht das schnell). Wir nehmen es in Kauf: Was du findest, wird ein neuer Vorgang.
4. **Herausnehmen geht nicht mehr.** Heute fliegt ein durchgefallener Punkt per `git revert` heraus, ohne Prüffragen gibt es nichts herauszunehmen. Ein Fund wird dann ein Rückläufer, der im nächsten Build behoben wird. Ein schwerer Fehler (Absturz, Spielstand kaputt) hält wie heute den ganzen Build auf.
5. **Bilderflut statt Fragenflut** (du hast „12 Vorlagen“ schon einmal beklagt). Abhilfe: Alle Bilder eines Builds kommen auf eine Seite, höchstens etwa zehn, nur Neues.
6. **Die Sperre für die Teams löst sich schneller.** Dann wird wieder mehr parallel gebaut, und Funde könnten sich wiederholen (Schwäche 2). Abhilfe: Die Regel „wiederholte Funde vor allem anderen“ (620.1 A) bleibt.
7. **Was uns fehlt:** Es gibt kein Werkzeug, das die Bilder je Vorgang auf eine Seite legt. Heute baut jedes Team Bildschritte von Hand, dafür braucht es einen allgemeinen Schritt „Bilder je Vorgang“ im Bau. Der Test `pruefliste_1020` und die Commit-Prüfung kennen die neuen Arten noch nicht.
8. **Was wir gewinnen:** Deine Zeit je Build sinkt von 20 bis 40 Fragen auf etwa 5 bis 10 Bilder und einen Weg. Die Teams warten weniger auf den Test, weil 55 Vorgänge nicht mehr einzeln auf dich warten.
- **Stärkstes Gegenargument gegen A:** Ein Bild prüft nur, was es zeigt; am Handy findest du nebenbei, woran keiner gedacht hat. Dagegen: Am Handy bleiben Ablauf, Bedienung, Gefühl und Klang als Fragen, und du spielst dabei ohnehin durch die Orte (vier von zehn Funden kamen bisher außer der Reihe). B hätte weniger Arbeit für dich, aber ohne Prüfpunkt für Nachbesserungen findet Rückschritte niemand gezielt (Gefahr 1); das willst du nicht (12:06).

**Zu ändern bei A** (Bau Perikles, Werkzeuge Tom; B zusätzlich „nicht Bemängeltes gilt als getestet“):
- `CLAUDE.md` Feste Regeln: „kein Code auf `main` ohne Test des Chefs“ wird zu „ohne Test des Chefs: Prüffrage am Handy, Bild oder Film, oder Bautest, den Diogenes bestätigt; je Vorgang die passende Art“. 201a.1 geht darin auf (Regelbilanz).
- `LISTE-CHECK-BUILD-TEST.md`: Aufbau der Prüfliste (Weg, Bilder für Neues, „Ohne dich“ mit Bautest), Regel 12 (Herausnehmen auch bei „falsch“ am Bild), Regel 13.
- `ROLLE-ENTWICKLUNG.md` (Testbitte), `DESIGN-ABNAHME.md` (Vorlage nur für Neues).
- `tools/startbar.py`: Die Sperre 620.1 B zählt ein Urteil am Bild und einen bestätigten Bautest als getestet.
- Laufnachweis: Jeder Test unter „Im Bau geprüft“ muss in `godot.yml` stehen, sonst lehnt die Testbitte ab (Tom).
- Test `pruefliste_1020`, Commit-Prüfung, `godot.yml`: ein Schritt „Bilder je Vorgang“.

**Folgerungen:** Bei A: Perikles baut die Regeln, Tom die Werkzeuge. Schon die Prüfliste für 283 schreibt Tom nach A. Ich lese sie gegen, Diogenes zählt ab 283 die Funde je Prüfart. Bei B ebenso, ohne Bilder für Nachbesserungen. Bei C bleibt alles, wie es ist.

**Zweite Meinung Perikles** (13.11., 12:09, gegen die Fassung mit Votum A nach deinem Wort 12:06; selbst an 282, 281, 280 und 201a.1 geprüft): **A mit zwei Änderungen**, als Probe für die Builds 283 bis 285. Mein erstes Votum B (12:05) ziehe ich zurück, weil du Rückschritte nicht selbst beim Spielen suchen willst.
- **Übersehen:** Die Höhle stand in 282 unter „Im Bau geprüft“ (`hoehle_492`), der Test lief aber gar nicht (berichtigt nach Sokrates, unten). In der App war sie nicht begehbar (282.19–21, 1104). Gefunden hat das nur das Handy. Ein Bautest zählt also nur mit Laufnachweis.
- **Änderung 1:** „Ohne dich“ gilt nur für Zahlen, Texte und Regeln. Alles, wo man hingeht, etwas antippt oder einen Ablauf erlebt, bleibt eine Prüffrage am Handy, auch wenn ein Bautest grün ist.
- **Änderung 2, zu Punkt 7:** vorerst kein neuer Bauschritt „Bilder je Vorgang“. Bildläufe sind unsere teuerste Arbeit (1022: 45 $, 492: 104 $). Ein Bild kommt nur aus dem Lauf, der die App baut. Fehlt dort eines, bleibt die Prüffrage am Handy. Das Werkzeug kommt erst, wenn die Probe zeigt, dass Bilder fehlen.
- **Zustimmung:** Herausnehmen auch bei „falsch“ am Bild; jeder Vorgang behält seinen eigenen Commit.
- **Rückweg:** Diogenes zählt in den Builds 283 bis 285 die Funde je Prüfart und die Rückschritte und legt danach vor, ob A bleibt.

**Abgleich Sokrates** (13.11., 12:11, am Bauablauf `godot.yml` von Build 282 nachgesehen):
- **Perikles' Beleg stimmt so nicht, sein Schluss trotzdem.** `hoehle_492` war in 282 nicht grün, er lief gar nicht im Bau; erst seit 09:28 (`334cff53a`, 1104). Gegen 282 gibt er 2 Fehler: Er hätte die unbegehbare Höhle gefunden. Ebenso standen `rand_505` und `rast_test` unter „Im Bau geprüft“, liefen aber nicht. 3 von 12 Bautests der Prüfliste 282 waren also nur behauptet.
- **Daraus:** Die Gefahr bei A ist nicht, dass ein Bautest nichts taugt, sondern dass die Prüfliste einen Test nennt, der nie lief. **Laufnachweis:** Ein Punkt gilt nur dann als „ohne dich“ geprüft, wenn der Test im Bauablauf steht und im Lauf der APK grün ist. Das prüft ein Werkzeug bei der Testbitte (Namen der Prüfliste gegen `godot.yml`, Tom), Diogenes bestätigt es am Lauf.
- **Änderung 1 übernehme ich:** Begehen, Antippen und Abläufe bleiben am Handy, weil der Bau ohne Bildschirm und ohne Finger läuft. Das kostet dich etwa 2 bis 4 Fragen mehr je Build. **Änderung 2 übernehme ich:** Bilder nur aus dem Lauf der APK, kein neuer Schritt vorab; fehlt ein Bild, bleibt die Frage am Handy.
- **Gefahr 4** entfällt bei A: Jeder Vorgang behält seinen eigenen Commit, Herausnehmen bleibt wie heute.

**Meinung Tom** (13.11., 12:56, an der Prüfliste 283 und an `godot.yml` von `claude/build-283` nachgesehen): **A wie Perikles und Sokrates.**
- **Was ein Bild kostet:** Gibt es den Bildtest schon, etwa 5 Minuten (Bild ansehen, eine Zeile mit Frage) und je Schritt 2 bis 5 Minuten mehr Lauf. Fehlt er, 30 bis 60 Minuten Arbeit für Kamera und Ausschnitt. Ein Film etwa eine Stunde. Achtung: die Bildtests, die es gibt, laufen heute nur auf ihrem eigenen Zweig oder bei einem Wort im Commit, im Lauf der APK von 283 läuft keiner davon. Für A müsste der Lauf der APK sie mitnehmen.
- **283, Bildtest vorhanden:** Siegschirm und Kampfbericht (1093, 1102, 1095, 1096; `schirm_833_bild`), Lyras Robe und Stand (1092, 1044 Lyra; `dame_1044`), Licht am Höhlenausgang (1091; Höhlenbilder), Karte des Walds (505; Nebelbilder). Das sind 8 von 18 Punkten.
- **Als Bild möglich, Test fehlt:** Zustände im Heldenreiter (764), Zeichen der Güte (756), Knöpfe auf einer Höhe bei Osric und Pim (1120); Leute in Ruhe (1044) und Staub Gehen gegen Rennen (1119) nur als Film. Bis es die Tests gibt, bleiben sie am Handy.
- **Nur am Handy:** Pim rennt heim, bleibt an der Hütte, drei Fehlschläge an drei Tagen (1086, 1108), Ring perfekt tippen (1094), Fingerzoom ganz hinein und hinaus (1118, 1081).
- **Gefährlich wäre:** Leute und Bewegung am Standbild abnehmen (Klone, Arme durch den Körper sieht man erst in Bewegung), Bedienung am Bild, und jeder Bautest, der nicht im Lauf steht (in 283 fand Sokrates `rand_505`, gestrichen). Den Laufnachweis baue ich als Werkzeug.

Antwort: …
