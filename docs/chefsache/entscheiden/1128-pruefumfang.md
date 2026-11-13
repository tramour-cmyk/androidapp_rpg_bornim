# 1128 · Prüfen wir künftig jeden Vorgang in der passenden Art (Prüffrage am Handy, Bild oder Film, Bautest) statt alles als Prüffrage am Handy?
Sokrates · 13.11., 12:03 · B Abläufe · aus deinem Wort 11:49, 11:58, 12:02, 12:06
Kurz: je Vorgang die passende Prüfart: Handy-Prüffrage nur für Ablauf, Bedienung, Gefühl, Klang; Aussehen als Bild oder Film; Regeln und Technik über den Bautest

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/94621abe7%5E/docs/chefsache/ansehen/t282-dorf.md (Prüfliste 282) und die Ergebnisse der Prüflisten 277, 278, 280 in Git; Vorgangsarchiv 201a.1; `tools/startbar.py` (Sperre 620.1 B)

**Frage:** Heute bekommt jeder fertige Vorgang eine Prüffrage, und du gehst sie alle am Handy ab. Das kostet dich Zeit für Dinge, die ein Bild genauso zeigt oder die ohnehin passen. Soll „vom Chef getestet“ künftig jede Form von Test sein: frei am Handy spielen, Bild oder Film ansehen, im Gespräch klären?

**Votum:** „1128 A“, dazu die beiden Änderungen von Perikles und der Laufnachweis, der auch verlangt, dass der Test rot werden kann (Diogenes). Für den Muss-Stau werden die 30 ungetesteten Muss ohne Build einmal nach der Liste von Diogenes abgeschlossen (unten, Abgleich 13:12). Meinungen haben Perikles, Tom und Diogenes geschrieben.

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

**Meinung Diogenes** (13.11., 12:59 und 13:10, Vorgang 1130; nachgezählt mit `startbar.py` und Git an `main` 3d32473da, Zweige gegen `main`, `godot.yml` von `main` und `claude/build-283`, `godot-kampf.yml`): **A hält, wenn der Laufnachweis auch prüft, dass der Test rot werden kann.**
- **Übersehen beim Laufnachweis:** „Steht in `godot.yml`“ reicht nicht. Im Bauablauf von 283 laufen 41 von 224 Testaufrufen mit `|| true`, sie werden nie rot. Darunter sind `schild_406` (1013, 1014), `sollbild_784` (784), `dame_1044` und `fussstaub_814`. Der Nachweis muss also verlangen: Der Test steht ohne `|| true` und ohne `continue-on-error` im Lauf der APK und war dort grün. Die 10 Tests unter „Im Bau geprüft“ in der Prüfliste 283 erfüllen das (nachgesehen: ohne `|| true`, ohne Bedingung).
- **Übersehen bei Rückschritten:** Ein Bautest misst nur seine eine Sache, und bisher zählt niemand Rückschritte. Ab 283 zähle ich sie: Ein Fund ist ein Rückschritt, wenn dasselbe in einem früheren Build passte oder in der alten Fassung ging (Marke „zurück t<n>“ oder „wiederholt“, sonst Abgleich mit dem Bestand).
- **So zähle ich ab 283:** je Prüfliste jeder Punkt mit seiner Art (Handy, Bild, Film, ohne dich) und deinem Urteil; dazu jeder Fund außer der Reihe mit der Art, die ihn hätte finden müssen. Ich zähle die Funde je Art und je Punkt, die Rückschritte und jeden Fund an einem Punkt „ohne dich“, den erst das Handy zeigte. Quelle: Prüfliste in Git und die Fund-Vorgänge „t283.x“. Nach 285 lege ich die Zahlen Perikles und dir vor, ohne Wertung.
- **Zu S4 in `entwurf/1129-blinde-flecken.md` („45 von 70“):** Heute sind es 46 von 71 Zeilen mit „gebaut“ oder „zu testen“ ohne Build. Die Sperre zählt davon aber nur 31: Muss-Vorgänge von Tom und Jerry ohne Zweig `claude/build-…`, also Tom 7 (seit 13:0x mit 1022, fertig für 284) und Jerry 24. Die übrigen 15 zählt die Sperre nicht: Perikles 8, Kür 2, „M?“ 2, dazu 947, 980 und 987 auf `claude/build-277`. Diese drei hängen seit Build 277 und zählen nirgends. Die Zahlen in S4 selbst (Tom 6, Jerry 24) stimmten bis 1022.
- **Zählung stimmt fast.** Heute 53 ungetestete Muss (Tom 20, Jerry 33; dazu kam 1126). Davon hängen 30 an keinem offenen Build, Stand „gebaut“ oder „zu testen, ohne Rückmeldung“ (Tom 6, Jerry 24; Sokrates zählte 28). Auf `main` sind davon nur 26: 1037 und 1084 stecken in Build 282 und kommen erst mit dem Nachtest der Höhle auf `main`, 1126 liegt auf dem Zweig von 1111, 825 ist die Zeile des Sammelbuilds 274.
- **Übersehen: auch Tom bleibt gesperrt.** Nach Test 283 hat Jerry 24 (Sokrates: 23, ohne 1126), Tom 9; besteht dazu der Nachtest 282, hat Tom 6. Die Sperre greift ab 6, also bleiben beide Teams gesperrt.
- **Kein Test löst die 30.** Sie stehen in keiner Prüfliste, und beim Test bleibt „ohne Rückmeldung“ einfach „zu testen“. Die Sperre geht damit durch Testen nie auf, ob mit A oder C. Das muss mit 1128 geregelt werden, sonst ändert A an der Sperre wenig.
- **7 davon brauchst du nie.** Werkzeuge des Bauservers (Bereich B: Tom 1122, 1079; Jerry 1111, 1112, 1113, 1101, 1126) zählen in die Sperre. Ich schließe sie mit „greift“ (724, 755), du testest sie nie. Vorschlag: Bereich B zählt nicht zur Sperre (Bau Perikles).
- **Die 30 nach Art (A mit Perikles' Änderungen):**
  - Handy zwingend, 4: 542 Aufträge Jorin, Gwenna, Aldric (Ablauf); 993 Arkanpfeil „hakelig“ (Gefühl); 1003 Keuchen der Heldin (Klang); 964 Metall sperrt Zauber (Regel, aber kein Test im Bau gefunden).
  - Film, 4: 709 Treffer sichtbar, 616 Rückweichen, 784 Wolfsrudel, 1041 Platztausch. Der Bau einer APK macht keine Filme (nur ein Handstart mit Eingabe „film“), also nach Perikles' Änderung 2 vorerst Handyfragen.
  - Bild, 2: 967 Schild im Körper (`halt_653` läuft in keinem Bau); 632 Waffe aus der Truhe (`truhe_632` läuft im Bau, geht also auch ohne dich).
  - Ohne dich, Test läuft im Bau, 8: 1009, 900, 1018, 910, 1013, 1014, 1054, 904. Ohne Laufnachweis, 1: 958 (`kampfzustand_532` steht in keinem Bauablauf).
  - Ohne dich, Lauf des Bauservers, 2: 909, 1060 (Laufzeit; ich bestätige es am Lauf).
  - Zahlen und Balance, 7: 923, 1049, 876, 971, 644a.1, 1037, 1084. Die Rechnung prüft die Simulation 444; Balance gehört dir, also klärt sie ein Gespräch über die Zahlen, kein Gerät. Nur „Verband kaufen bei Osric und Thessa“ (1037) ist ein Ablauf am Handy.
  - Ohne Test, 2: 825 (Sammelbuild 274, längst getestet, Zeile schließen), 1126 (Werkzeug, „greift“ bei mir).
- **Ergebnis:** Zwingend am Handy 4 von 30, ohne Film 8, dazu der Verbandkauf. 20 gehen ohne Gerät (Bautest, Zahlen, Verwaltung; 958 erst mit Test im Bau), davon 7 als Gespräch über Balance.
- **Stärkstes Gegenargument:** Schließen wir die 20 nachträglich ohne dich, gilt Ungesehenes als getestet (Gefahr 3). Dagegen: 26 der 30 sind schon auf `main`; ein Nein ändert nichts am Code, nur an der Sperre.
- **Was noch fehlt:** Wer die 30 abschließt, steht nirgends. Vorschlag: nach deiner Antwort ein Vorgang an Perikles, der sie einmal nach dieser Liste abschließt; Handyfragen in die Prüfliste 284, die Bautests bestätige ich am Lauf von 283.

**Abgleich Sokrates** (13.11., 13:12; im Bauablauf von `claude/build-283` nachgesehen: `schild_406`, `sollbild_784`, `fussstaub_814` und `dame_1044` laufen mit `|| true` und werden nie rot). Zu deiner Frage 12:51 („alles bedacht … Muss-Stau … zwingend in eine APK?“):
- **Alle haben sich geäußert:** Perikles 12:09, Tom 12:56, Diogenes 12:59 und 13:10. Alle drei sind für A.
- **Laufnachweis, berichtigt:** Ein Punkt gilt nur dann als „ohne dich“ geprüft, wenn sein Test im Lauf der APK steht, ohne `|| true` und ohne `continue-on-error`, und dort grün war. Das prüft Toms Werkzeug, Diogenes bestätigt es am Lauf.
- **Muss-Stau, die 30 ungetesteten Muss ohne Build:**
  - Etwa 11 kommen als Fragen am Handy in Build 284. Davon sind 4 zwingend: Aufträge von Jorin, Gwenna und Aldric; Arkanpfeil; Keuchen; Metall sperrt Zauber. 4 zeigt eigentlich nur ein Film, aber der Bau der APK macht noch keine Filme. Dazu kommen der Schild im Körper und 958, für die kein Bautest im Lauf steht, und der Verbandkauf.
  - 6 sind Zahlen zur Balance. Die klären wir in einem Gespräch über die Zahlen, ohne Gerät.
  - 12 bestätigt Diogenes am Lauf: Bautests, Laufzeit des Bauservers, Werkzeuge.
  - Die Zeile des Sammelbuilds 274 wird geschlossen.
- **Dazu:** Werkzeuge im Bereich B zählen nicht mehr zur Sperre. Das sind 7 Zeilen, die du nie testest; den Bau macht Perikles. Dass die Sperre nur zählt, was in einem Build auf dich wartet, steht in [1129](1129-blinde-flecken.md) als Punkt 2.
- **Rückweg:** Diogenes zählt ab 283 die Funde und die Rückschritte je Prüfart. Nach 285 legt er die Zahlen vor, dann entscheidest du, ob A bleibt.

Antwort: …
