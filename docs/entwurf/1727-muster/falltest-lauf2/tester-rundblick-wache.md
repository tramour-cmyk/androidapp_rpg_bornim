# Antworten Tester, Rundblick, Wache (Falltest, 21.11., 23:3x)

Gespielt nur nach den Ladetexten der jeweiligen Rolle. Nichts ausgeführt, was schreibt; alle Schreibbefehle stehen nur hier. Werkzeugstellen habe ich lesend nachgesehen (`vorgang.py --help`, `tools/rueckmeldung.py`, `tools/uebergabe.py`, `tools/auftrag.py`, `tools/lauf.py`), weil die Ladetexte auf diese Befehle verweisen.

---

## T1 Tester: „Gehen nach Ausschlag wie vorgesehen“, Held zu schnell, Testmenü „Schnell“ an

**1. Was ich tue**
1. Kein Urteil mit Schalter an. Profil: „Vor jedem Urteil schaltest du die Testhilfen aus und nennst ihren Zustand im Beleg.“ Also schalte ich „Schnell“ aus (auch jede andere Testhilfe), starte den Weg neu und teste noch einmal: Joystick ganz und halb ausgeschlagen, auf dem Gerät, in Spielkamera und Handygröße.
2. Ich nehme einen Film auf, weil es um Bewegung geht. Dazu der Weg: „Hauptmenü → Neues Spiel → Dorf, Joystick 100 % / 50 %, Testhilfen alle aus (Schnell aus)“.
3. Danach urteile ich nach dem, was ich sehe:
   - **a) Mit „Schnell“ aus stimmt das Tempo:** kein Befund zum Testpunkt. „Schnell“ war nur eine Testhilfe, das ist kein Mangel im Spiel. Steht „Schnell“ beim Start des Builds schon an, gebe ich dazu einen Hinweis (nicht gezählt): „Hinweis: Testmenü ‚Schnell‘ steht beim Start an, Dorf“.
   - **b) Auch mit „Schnell“ aus zu schnell:** Was „wie vorgesehen“ heißt, kann ich nur mit einer Zahl aus der Quelle entscheiden (Kern: „Zahl stimmt mit dem Regelwerk“). Also suche ich den Sollwert in den Vorgängen, die das Ganze mitbringt (offene und behobene), und in der Quelle, die der Auftrag nennt.
     - Weicht die gemessene Zahl vom Sollwert ab und ging es im vorigen Build: **Rückschritt**, mit der Nummer des behobenen Vorgangs, falls es einen gibt.
     - Ging es auch im vorigen Build nicht: **Fehler**.
     - Gibt es keinen Sollwert, ist „zu schnell“ eine Frage des Spielgefühls, und darüber urteilt der Chef: dann nur „Hinweis: Gehtempo wirkt zu schnell, Dorf, Film …“.
4. Ich melde unter der Nummer, die der Auftrag nennt. **Hier nennt der Fall keine Nummer.** Darum halte ich die Meldung an (Sockel 3: „Ist der Auftrag unklar … anhalten, Frage zurückmelden“) und frage den Auftraggeber im Chat nach der Nummer. Sobald ich sie habe (Fall b, Fehler):
   ```
   cd /home/user/bornim-main && python3 tools/vorgang.py rueckmeldung <Nr> "Befunde: 1
   Fehler, Dorf (Gehen nach Ausschlag): Held geht bei vollem Ausschlag <x> m/s statt <Soll> m/s (<Quelle>), Testhilfen alle aus (Schnell aus), Film <Pfad>, Weg: Hauptmenü → Neues Spiel → Dorf, Joystick 100 %
   Abnahmeliste: <je Punkt des Ganzen erfüllt / nicht erfüllt <Nr>|ohne Vorgang / nicht prüfbar, Beleg>
   Hinweis: Testmenü ‚Schnell‘ stand beim Start an, Dorf
   Nicht prüfbar: <…>" --sitzung Tester
   ```
   Danach schicke ich die WECKER-Zeile, die das Werkzeug ausgibt, als Nachricht. Erwartet ist laut Werkzeug aber keine (siehe 5).

**2. Was ich nicht tue:** Ich urteile nicht, solange „Schnell“ an ist. Ich ändere am Tempo nichts und baue nichts („Du baust und reparierst nichts“). Ich lege keinen Vorgang an (das macht das Büro). Ohne Sollwert melde ich „zu schnell“ nicht als Mangel, weil Spielgefühl Sache des Chefs ist. Ohne Gerät gibt es kein Urteil, dann „nicht prüfbar“.

**3. Quellen:** Build, Testmenü, Belege des vorigen Builds, die mitgegebenen Vorgänge des Ganzen. Die Abnahmeliste in `docs/PROJEKTPLAN.md` (Abschnitt „Abnahmeliste Kapitel 1“) habe ich nur nach Punkten zum Gehen durchsucht und keinen Punkt mit Gehtempo gefunden. `docs/chefsache/themenbloecke.md` (vom Profil genannt) habe ich nicht geöffnet, weil der Test es verbietet.

**4. Nächster Schritt:** Gleich nach dem zweiten Durchgang mit „Schnell“ aus. Die Meldung geht raus, sobald die Nummer da ist.

**5. Lücken und Widersprüche**
- Was „wie vorgesehen“ bedeutet, sagt der Text nicht. Er nennt weder die Quelle für den Sollwert des Tempos noch, ob dafür eine Zahl oder ein Film des Chefs gilt.
- Der Text sagt nicht, ob eine Testhilfe, die beim Start an ist, ein Befund ist.
- Im Fall fehlt die Nummer. Der Sockel verlangt dann „Frage zurückmelden“, das Kern sagt aber: „statt ‚Frage‘ meldest du mit den Wörtern deines Profils“. Das Profil hat kein Wort für eine Rückfrage, und `rueckmeldung` braucht eine Nummer. Es bleibt also offen, wie und an wen der Tester fragt.
- **Text gegen Werkzeug:** Das Kern sagt: „das Werkzeug trägt sie ein und nennt den Empfänger; die ausgegebene Zeile WECKER schickst du als Nachricht“. Das Profil verlangt als erstes Wort „Befunde: n“. `rueckmeldung.py` kennt aber nur „steckt fest“, „Frage“, „wirkt nein“, „nein, Auftrag“, „nein“, „Beleg fehlt“, „fertig“, „ja“, „Hinweis“ (`worte()`). Bei „Befunde: 1“ gilt: `EINGETRAGEN <Nr>: eingetragen, kein Signalwort zum Weitergeben`. Es entsteht keine Übergabezeile und kein WECKER, das Büro erfährt also nichts. (Offen dazu ist 1797, worte() erkennt Wörter nicht, das betrifft dieselbe Stelle.)
- Der Text sagt nicht, mit welchem Namen ich mich eintrage (`--sitzung`). Ohne den Schalter liest das Werkzeug die Rolle aus der Besetzung, sonst steht dort „unbekannt“.

---

## T2 Tester: Build 300, Kampf auf Grafik Hoch 18–24 Bilder/s, vorige Belege ohne Bildrate

**1. Was ich tue**
1. Ich schalte die Testhilfen aus und messe die Bildrate auf dem Gerät noch einmal: dieselbe Lage, Grafik Hoch, mindestens 30 s. Zum Vergleich messe ich Grafik Mittel daneben, aber nur als Angabe. Dazu ein Film in Spielkamera und Handygröße, damit das Ruckeln sichtbar ist (Kern: „Widersprechen sich Messung und Bild, gilt das Bild“).
2. Die Art bestimmt das Profil Nr. 4: „Bildrate … ohne Vergleichswert ein Fehler mit Messwert, Grafikstufe und Lage“. Weil die Belege des vorigen Builds keine Bildrate nennen, ist es ein **Fehler**, kein Rückschritt. Nach dem Kern ist Ruckeln ein Bruch des Eintauchens, also ein Mangel und kein Hinweis. Es zählt mit.
3. Ich prüfe, ob einer der mitgegebenen Vorgänge die Bildrate betrifft. Wenn ja, nenne ich dessen Nummer, sonst bleibt der Befund ohne Nummer und das Büro legt einen Vorgang an.
4. Die Punkte 300.1 bis 300.11 prüfe ich wie gefordert. Zur Abnahmeliste gebe ich je Punkt des getesteten Ganzen ein Urteil.
5. Meldung unter 300:
   ```
   cd /home/user/bornim-main && python3 tools/vorgang.py rueckmeldung 300 "Befunde: <n>
   Fehler, Kampf (<Kampfort, Gegner, Zug>): 18–24 Bilder/s auf Grafik Hoch (Mittel: <x>), Gerät <Modell>, Testhilfen alle aus, Film <Pfad>, Weg: <…>; kein Vergleichswert im vorigen Build
   <weitere Befunde zu 300.1–300.11, je eine Zeile>
   Abnahmeliste: <Punkt: erfüllt / nicht erfüllt <Nr>|ohne Vorgang / nicht prüfbar, Beleg>
   Hinweis: Belege des vorigen Builds ohne Bildrate, Vergleich nicht möglich
   Nicht prüfbar: <…>" --sitzung Tester
   ```
   Danach schicke ich die WECKER-Zeile, falls das Werkzeug eine ausgibt (laut Werkzeug keine, siehe T1).

**2. Was ich nicht tue:** Ich suche nicht nach der Ursache, ändere keine Grafikstufe im Code und baue nichts. Ich nenne den Befund keinen Rückschritt, weil der Vergleichswert fehlt. Er fällt auch nicht weg, weil er „nebenbei“ kam: Die Bildrate gehört zum Ganzen, und der Sockel sagt: „Fund außerhalb des Auftrags: zurückmelden, nicht beheben“. Eine Messung am Rechner gilt nicht. Ohne Gerät heißt es „nicht prüfbar“.

**3. Quellen:** Build 300, die Belege des vorigen Builds, die Vorgänge des Ganzen, die Punkte 300.1 bis 300.11 aus der Testaufgabe unter 300. Für die Abnahmeliste `docs/PROJEKTPLAN.md`; einen Punkt mit fester Bildrate habe ich dort beim Durchsuchen nicht gefunden.

**4. Nächster Schritt:** Ich messe noch in derselben Testsitzung neu. Die Meldung geht nach dem ganzen Test raus, also eine Meldung für alle Befunde.

**5. Lücken und Widersprüche**
- Es gibt keine Grenze, ab der eine Bildrate ein Fehler ist (30? 60?). Der Text sagt nur „schlechter als im vorigen Build“, und dieser Vergleich fehlt hier.
- Der Text sagt nicht, wie die Bildrate gemessen wird (Werkzeug, Dauer, Gerät).
- Das Profil sagt „Du testest ein Ganzes, nicht einen Auftrag“. Der Fall nennt aber Build-Punkte 300.1 bis 300.11. Ob der Tester sie einzeln beurteilt oder nur die Abnahmeliste, sagt der Text nicht.
- Text gegen Werkzeug, wie bei T1: „Befunde: n“ ist kein Signalwort, also keine Weitergabe und kein WECKER.

---

## R1 Rundblick: 1289 dritter Fund des Chefs, 1296 zweiter; Routine unter 1734

**1. Was ich tue**
1. Eingang lesen:
   - die neueste Spalte der Wochenzählung (`docs/PRUEFBERICHT.md`, dort 09.–15.11.),
   - die „Systemlösung?“-Zeilen (`grep -n "Systemlösung?" docs/LISTE-VORGAENGE.md docs/LISTE-VORGAENGE-ARCHIV.md`),
   - die Kosten (`docs/LISTE-KOSTEN.md`, Spalte „Kosten“),
   - zu jedem Kandidaten `python3 tools/vorgang.py 1289 1296 1736`.
2. Drei Schwächen auswählen, in der Folge des Texts (Funde des Chefs, dann Wiederholfunde, dann Kosten):
   - **S1: 1289 Höhle dunkel**, der dritte Fund des Chefs. Das Bild auf dem Handy (Renderer Mobile) weicht vom Probebild am Rechner (Compatibility) ab, und das hat der Chef zuerst gesehen.
   - **S2: 1296 Eingebung**, der zweite Fund des Chefs. Der Hinweis rät „Wechsel“, aber kein Knopf dafür ist da: Hinweis und Knöpfe kommen aus verschiedenen Quellen.
   - **S3: Wiederholfund „Umhang“, 1736 („Systemlösung? Umhang: 19 frühere Vorgänge“).** Es ist der größte Wiederholfund und deckt sich mit dem Beispiel des Chefs zu 1734 („Kleidung hält nicht“). Prüfen statt zustimmen: 1736 wartet schon auf eine „Systemlösung Federknochen (Sokrates 07:04)“. Mein Vorschlag muss sich daran messen und darf sie nicht doppeln.
3. Je Schwäche nachsehen, wie andere es lösen, mit Quellen im Netz (vor dem Senden mit Datum belegen):
   - S1: Godot-Doku „Overview of renderers“ (Unterschiede Mobile/Compatibility). Bildvergleich im Bauprozess nach dem Muster „Golden Image“ (etwa Unity Graphics Test Framework oder Playwright `toHaveScreenshot`).
   - S2: Hinweise werden aus derselben Liste erlaubter Aktionen erzeugt wie die Knöpfe („single source of truth“, datengetriebene Oberfläche) und mit einem Test für jeden Hinweis geprüft.
   - S3: Godot 4 `SpringBoneSimulator3D` / Federknochen, die Muster aus VRM-Spring-Bone und Kleidung am Skelett mit Kollisionskapseln.
4. Die Vorschläge gehen ans Büro, einer je Aufruf:
   ```
   cd /home/user/bornim-main
   python3 tools/vorgang.py uebergabe 1734 Disponent "Vorschlag: Schwäche 1289 (Höhle am Handy anders als Probebild; dritter Fund des Chefs). Quelle: Godot-Doku Renderer, Golden-Image-Vergleich (Unity Graphics Test Framework). Probe: Prüfbilder nur im Renderer des Handys (Mobile), Bildvergleich gegen abgenommenes Bild im Lauf; Maß: Funde des Chefs zu ‚sieht am Handy anders aus‘ je Woche, vorher 3, Ziel 0. Kosten: ca. 1 Sitzung Technik. Entscheidung (ändert Ablauf Prüfbild)."
   python3 tools/vorgang.py uebergabe 1734 Disponent "Vorschlag: Schwäche 1296 (Hinweis rät Aktion ohne Knopf; zweiter Fund des Chefs). Quelle: datengetriebene Oberfläche, eine Quelle für Hinweis und Knöpfe. Probe: Test, der je Kampflage jeden Hinweis gegen die sichtbaren Knöpfe prüft; Maß: Hinweis ohne Knopf, vorher ≥1 (1296), nachher 0 im Test. Kosten: ca. 1 Sitzung Kampf."
   python3 tools/vorgang.py uebergabe 1734 Disponent "Vorschlag: Schwäche Umhang (1736, 19 Wiederholfunde). Quelle: Godot SpringBoneSimulator3D, VRM Spring Bone mit Kollisionskapseln. Probe: ein Umhang an einer Figur, Durchstechprüfung vorher/nachher; Maß: Durchstich-Ecken und neue Umhang-Vorgänge je Woche. Kosten: ca. 1–2 Sitzungen Figuren. Abgleich mit Systemlösung Federknochen (1736) vor Bau."
   python3 tools/vorgang.py rueckmeldung 1734 "fertig"
   ```
   Laut Werkzeug geben die Übergaben „KEINE SITZUNG Disponent läuft“ aus. Für die Rückmeldung nennt das Werkzeug den Empfänger Disponent mit Ersatz Ford, und die WECKER-Zeile dafür. Der Text sagt nicht, dass ich WECKER schicke, darum tue ich es nicht.

**2. Was ich nicht tue:** Ich baue nichts und lege keine Vorgänge an (das Büro macht aus den Vorschlägen Vorgänge). Ich mache nicht mehr als drei Vorschläge. Ich löse 1736 nicht selbst und wiederhole die Federknochen-Lösung nicht unbesehen. Ich melde nicht an den Chef: Der Text kennt nur den Weg ans Büro, Telegram nennt er nicht.

**3. Quellen:** `docs/PRUEFBERICHT.md` (Wochenzählung), die „Systemlösung?“-Zeilen in `docs/LISTE-VORGAENGE.md` und `docs/LISTE-VORGAENGE-ARCHIV.md`, `docs/LISTE-KOSTEN.md` (Kopf), `vorgang.py 1289 1296 1734`, Hilfe zu `vorgang.py`, und lesend `tools/rueckmeldung.py`, `tools/uebergabe.py`, `tools/auftrag.py`, `tools/lauf.py`. Fremde Quellen im Netz habe ich nicht geöffnet; das täte die echte Sitzung vor dem Senden.

**4. Nächster Schritt:** Gleich nach dem Lesen kommen die drei Übergaben und dann „fertig“. Danach ist die Sitzung zu Ende. Der nächste Rundblick kommt in einer Woche.

**5. Lücken und Widersprüche**
- **Die Quellen sind veraltet:** Die neueste Spalte im Prüfbericht ist „09.–15.11.“, die laufende Woche fehlt. `LISTE-KOSTEN.md` ist am „08.11., 16:45“ erzeugt. Die Kosten „der Woche“ stehen also nirgends, und die dritte Schwäche nach Kosten lässt sich nicht belegen. Darum habe ich den Wiederholfund genommen.
- Was eine „kleine Probe“ ist, wenn ich nichts baue, sagt der Text nicht. Ich habe die Probe nur beschrieben.
- Wo „Entscheidung“ stehen soll, sagt der Text nicht; ich habe es in den Vorschlag geschrieben.
- **Text gegen Werkzeug (1):** `rueckmeldung "fertig"` ohne Commit läuft nur dann über die Routine, wenn der Titel „(Routine, Auftrag …md[ Teil X])“ enthält (`auftrag.py` ROUTINE). Der Titel von 1734 lautet „Von Chef (20.11., 06:46, Idee): Forschung und Entwicklung bei Sokrates …“, ohne diese Marke. Das Werkzeug schickt also „„fertig“ ohne Commit …: nicht annehmen, Macher nennt Commit und Beleg (1739)“ an den Disponenten statt „Routine fertig … Vorschläge … anlegen, dann schliessen“. Auch `lauf.py` sucht den Wochentermin unter „Rundblick (Routine“ und nicht unter 1734.
- **Text gegen Werkzeug (2):** Für `uebergabe … Disponent` sucht `uebergabe.besetzung("Disponent")` in `ARBEIT-BESETZUNG.md` eine Zeile „Disponent“. Dort steht nur „Ford“, und anders als bei `rueckmeldung` gibt es keinen Ersatz. Die Ausgabe ist also „KEINE SITZUNG Disponent läuft“, und die Vorschläge warten, bis jemand sie aufnimmt.
- 1734 ist Kür beim Besitzer Sokrates („startbar“). Ob die Routine darunter laufen soll, ist nach dem Vorgangsarchiv offen („ersetzt durch Routine (20.11., 07:53)“).

---

## R2 Wache: 1650, 1653, 1654 seit 7–9 h „abgenommen“, in keinem Build, ohne Termin

**1. Was ich tue**
1. Regel 7 trifft zu: „ein Vorgang ist abgenommen und seit 6 h in keinem Build“. Das gilt für alle drei. Vorher prüfe ich es: `python3 tools/vorgang.py 1650 1653 1654` (Stand, Feld Build, Zeit des Abnehmens).
2. Mein Stand (die Datei „deiner Datei“): Gab es zu diesen Vorgängen in der letzten Stunde schon eine Meldung „Liegt“, melde ich nicht noch einmal.
3. Ich schicke einen Wecker „Liegt“ an den Disponenten, mit allen drei Vorgängen in einer Nachricht. Den Disponenten vertritt laut `vorgang.py --help` bis zur Umschaltung Ford, also geht der Wecker an die Ford-Sitzung aus `docs/ARBEIT-BESETZUNG.md`, erstes Wort „Liegt“:
   ```
   send_message an Ford (Kennung frisch aus ARBEIT-BESETZUNG.md, Zeile „Ford“):
   "Liegt: 1650 (Stand abgenommen, Alter <9> h, kein Build) · 1653 (abgenommen, <8> h, kein Build) · 1654 (abgenommen, <7> h, kein Build). Wache 21.11., <HH:MM>."
   ```
4. Danach schreibe ich die Zeitmarke und den Stand je Fall in meine Datei und warte auf den nächsten Wecker.

**2. Was ich nicht tue:** Ich nehme die Vorgänge in keinen Build auf und ändere keinen Stand („du behebst nichts“). Ich melde nicht an den Chef, weil Regel 7 nur einen Wecker an den Disponenten verlangt. Ich schicke keine drei getrennten Wecker. Dass die Vorgänge keinen Termin haben, ändert nichts, denn Regel 7 nennt keine Ausnahme für Termine. Bei einem Termin hätte ich trotzdem gemeldet und den Termin dazugeschrieben.

**3. Quellen:** Vorgangsliste über `vorgang.py 1650 1653 1654`, `docs/ARBEIT-BESETZUNG.md` (Kennung Ford), meine eigene Datei mit dem Stand.

**4. Nächster Schritt:** Beim nächsten Wecken meiner Uhr. Dieselben drei melde ich frühestens nach einer Stunde wieder, wenn sie dann noch liegen.

**5. Lücken und Widersprüche**
- „Abgenommen“ ist kein Wort der Vorgangsliste. Im Kopf von `LISTE-VORGAENGE.md` steht: „ein Wort aus offen, startbar, in Arbeit, wartet, Chef, ruht, gebaut, zu testen, … erledigt“. Die echten Zeilen zeigen etwa „gebaut, Geprüft an …“ (1650) und „startbar, gebilligt 18.11. 22:37, in nächsten Build“ (1653). Woran die Wache „abgenommen“ und dessen Zeitpunkt erkennt, sagt der Text nicht. Ein Werkzeug für die Zählung gibt es noch nicht: Offen ist 1799 „Zählung für Wache 7 ‚Liegt‘ … Test“ bei Spike.
- Was „je Fall“ heißt (je Regel oder je Vorgang), sagt der Text nicht. Ich habe es als „je Vorgang“ gelesen und die drei gebündelt.
- Der Text sagt nicht, welche Datei „deine Datei“ ist und wo die Zeitmarke steht. Er sagt auch nicht, wie oft die Uhr weckt.
- Wie ein Wecker aussieht, sagt der Text nicht: `send_message` mit Inhalt oder `vorgang.py uebergabe` mit „sieh in NR (Kennung)“. Die Wache hat keine eigene Nummer. Für `uebergabe … Disponent` gibt das Werkzeug „KEINE SITZUNG Disponent läuft“ aus (`uebergabe.besetzung` ohne Ersatz Ford). Darum habe ich direkt an Ford geschrieben.

---

## R3 Wache: Builds 286–292 freigegeben, seit 3 h keiner auf `main`; Lauf 293 rot (einer in der Stunde)

**1. Was ich tue**
1. **Regel 7, zweiter Teil:** „vom Chef freigegeben und seit 1 h nicht auf `main`“. Seit 3 h liegen sie, also trifft die Regel zu. Ich prüfe es, ohne etwas zu schreiben:
   - `git -C /home/user/bornim-main log origin/main --since="3 hours ago" --oneline` (nach `git fetch`, das ich nur aufschreibe),
   - `git -C /home/user/bornim-main log origin/main --oneline --grep="t28[6-9]\|t29[0-2]"`,
   - die Archiveinträge t286 bis t292 im Vorgangsarchiv (Zeit der Freigabe).
   Die Vorgänge je Build hole ich mit `vorgang.py <Nr>` (Feld Build).
2. Wecker „Liegt“ an den Disponenten, also an die Ford-Sitzung aus der Besetzung:
   ```
   send_message an Ford: "Liegt: Builds 286–292 vom Chef freigegeben (Archiv t286–t292, <Zeiten>), seit <3> h nicht auf main; Vorgänge <Nr, Stand, Alter je Build>. Wache 21.11., <HH:MM>."
   ```
3. **Regel 4, rote Läufe:** Es gibt einen roten Lauf (293) in der Stunde, die Schwelle liegt bei 3. Also keine Meldung an den Chef und kein Wecker dazu. Ich schreibe den Lauf nur in meinen Stand, damit die Zahl in der nächsten Stunde stimmt.
4. Zeitmarke schreiben, dann warten.

**2. Was ich nicht tue:** Ich bringe nichts nach `main`, mische nichts zusammen und starte keinen Lauf neu („du behebst nichts“; Sockel: nie Spielcode ohne Test des Chefs nach `main`). Ich melde den einen roten Lauf nicht, weil er unter der Schwelle liegt. Ich rate nicht, ob der rote Lauf der Grund für das Liegen ist. Ich melde nicht laut an den Chef, weil Regel 7 an den Disponenten geht.

**3. Quellen:** Vorgangsarchiv (t286–t292), `git log origin/main`, GitHub-Läufe der letzten Stunde (`gh run list --limit 50 --json conclusion,createdAt,headBranch,url`), `vorgang.py` zu den Vorgängen der Builds, `docs/ARBEIT-BESETZUNG.md`.

**4. Nächster Schritt:** Beim nächsten Wecken. „Liegt“ für dieselben Builds melde ich frühestens in einer Stunde wieder. Kommen zwei weitere rote Läufe in derselben Stunde dazu, folgt nach Regel 4 die laute Meldung an den Chef und ein Wecker an den Disponenten.

**5. Lücken und Widersprüche**
- Regel 7 spricht von „ein Vorgang“, der Fall von Builds. Ob die Meldung Build-Nummern oder die Vorgänge der Builds nennt, sagt der Text nicht. Ich nenne beides.
- Woher die Wache „vom Chef freigegeben“ liest (Archiv, Prüfliste, Telegram), sagt der Text nicht. Auch dafür gibt es noch keine Zählung (1799, offen).
- Regel 4 sagt „in der Stunde“, aber nicht, ob gleitend oder je volle Stunde.
- Wie bei R2 fehlen der Weg des Weckers, „deine Datei“ und die Zeitmarke.
