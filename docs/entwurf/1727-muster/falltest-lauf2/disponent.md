# Antworten Disponent (Falltest, 21.11., 23:32)

Allgemein, gilt in allen Fällen: Jeder Lauf heißt bei mir zuerst `list_sessions` (mine, alle Seiten bis has_more falsch) in eine Kurzform-Datei `/tmp/s.txt` schreiben, dann `cd /home/user/bornim-main && python3 tools/lauf.py --sperre --besetzung /tmp/s.txt`, Notizen pushen, dann jede Ausgabezeile ausführen und nicht mehr. Schreibbefehle unten stehen nur hier, ausgeführt habe ich keinen.

Allgemeine Lücken (gelten für mehrere Fälle):
- **Profilnamen gegen Rollennamen im Werkzeug.** Der Text nennt Disponent, Arbeitsplaner, Prüfer, Fachkraft Technik, Figur, Werkzeug. Das Werkzeug kennt nur Rollen aus der Besetzung. `lauf.py:606` `ALT_EMPFAENGER = {"Arbeitsplaner": "Ford", "Disponent": "Ford", "Prüfer": "Diogenes"}` gilt bis `tools/1727-SCHARF`, und die Datei gibt es nicht. Für „Technik“, „Figur“ und „Werkzeug“ steht nirgends eine Zuordnung. `uebergabe.besetzung(an)` sucht AN in Spalte 1 von ARBEIT-BESETZUNG.md. Ich trage deshalb Rollennamen ein: Technik/Werkzeug → `Spike`, Figur → `Tom` (Besitzer von 1535). Woher ich das weiß, sagt mir der Text nicht.
- **Guthaben.** Der Text sagt: „Das Werkzeug gibt die Stufe aus: ab 80 % nur Muss …“. `lauf.py` gibt keine Guthabenstufe aus. Ein grep nach „Guthaben“ in `tools/lauf.py` findet nichts. Es gibt nur den Handschalter `--nur-muss` (Hilfe: „Ford setzt es bei `allowed_warning` …“).
- **„Protokoll“** (Profil, Guthaben-Absatz) ist im Text nicht verortet. Ich nehme an, gemeint ist das Protokoll in `docs/ARBEIT-BETRIEB.md`, weil die Haken dort lesen.
- **`startbar.py --help`** kennt keinen Hilfe-Schalter (`startbar.py:1401 ff.` liest nur `--alle`, `--stand`, `--md`, `--liegt`, `--leichen`). Der Aufruf hat deshalb die ganze Startbar-Liste ausgegeben. Die Auftragsregel „nur mit Hilfe-Schalter“ lässt sich damit für startbar.py nicht einhalten.
- **Bei mir „urteilen“ gegen „an Sokrates geben“.** Das Profil sagt „Du urteilst nur über Eingang, „Frage“, „steckt fest“ und Guthaben“. Weiter unten steht aber „Sokrates startest du bei jeder offenen Übergabezeile an ihn (etwa „steckt fest“ …; „Frage“ …)“, und `rueckmeldung.py` gibt beides an Sokrates. Mein „Urteil“ verstehe ich darum nur als Weiterleiten, nicht als inhaltliche Antwort.

---

## D1 – Nachtstopp bei Spike-Start 4/8 an 1739

1. Schritte:
   1. Beleg prüfen: `grep -n "1784" docs/VORGANGSARCHIV.md`. Ergebnis: Zeile 5, „1784, Nachtstopp Spike (21.11., 21:54 …) → heute Nacht höchstens acht weitere Spike-Starts an 1739, spätestens 03:00; Ford startet von Hand nur, wenn die letzte Übergabe einen Commit unter `tools/` oder `.github/` nennt; sonst Nachtstopp“.
   2. Bedingung prüfen: Nennt die letzte Übergabe der Spike-Sitzung zu 1739 einen Commit unter `tools/` oder `.github/`? Das prüfe ich mit `git -C /home/user/bornim-main show --stat <Commit>`. Steht keiner drin, starte ich nicht (Nachtstopp laut 1784 A). Ab hier nehme ich an, die Bedingung ist erfüllt und es ist 23:xx, also vor 03:00.
   3. Der Startsperre-Haken weist `create_session` mit Exit 2 ab: „Nachtstopp (1643): Spike auf Vorgang 1739 ist in dieser Nacht schon nach zwei Neustarts …“. Ursache im Code: `nachtstarts.py` `GRENZE = 3`. Der Haken (`startsperre-haken.py`, `nacht()`) kennt keine Ausnahme für 1784 A, und ein grep nach „1784“ in `tools/` findet nichts. Das Werkzeug setzt also einen Chefentscheid nicht um. Das ist ein Werkzeugfehler.
   4. Ich umgehe ihn nicht. Den Start lasse ich liegen.
   5. Ich lege einen Werkzeug-Vorgang an: `python3 tools/vorgang.py neu "Von Disponent (21.11., 23:35, 1784 A): startsperre-haken.py/nachtstarts.py hält Spike-Start 4 an 1739 als Nachtstopp 1643 an (GRENZE 3); 1784 A erlaubt bis 03:00 acht weitere – Ausnahme fehlt" "B Werkzeuge" M "Spike"`. Danach committen und pushen.
   6. Die Protokollzeile, die der Haken verlangt, schreibe ich mit Edit in `docs/ARBEIT-BETRIEB.md`: „- 23:35 21.11.: Morgen 1643: Spike 1739 nach zwei Neustarts in der Nacht angehalten, Ursache ansehen (Haken gegen 1784 A, Werkzeugvorgang <neu>)“. Dann pushen.
   7. Stillstand an einer Entscheidung gebe ich als Zeile an Sokrates: `python3 tools/vorgang.py uebergabe 1784 Sokrates "Stillstand an Entscheidung 1784 A: Spike-Start 4/8 an 1739 vom Startsperre-Haken (Nachtstopp 1643) angehalten; Werkzeugvorgang <neu>; nicht umgangen"`. Danach lauf.py, damit der Sokrates-Start oder -Wecker kommt.
2. Was ich nicht tue:
   - Keine Startsperre mit „(selbst)“ eintragen.
   - Den Titel nicht ohne „1739“ schreiben, um die Zählung zu umgehen.
   - Den Haken nicht abschalten.
   - Den Werkzeugcode nicht selbst ändern, denn das Büro baut nichts.
   - Nicht laut melden: Der Betrieb steht nicht, nur 1739 hängt.
   - Keine Meldung an den Chef, weil keine der drei erlaubten Meldungsarten passt.
3. Geöffnete Quellen: VORGANGSARCHIV.md Zeile 5, `tools/startsperre-haken.py`, `tools/nachtstarts.py`.
4. Zeitpunkt: Alles sofort, Anhalt 5 Minuten. Sokrates wird über lauf.py geweckt (WEITER) oder gestartet. Der Werkzeugvorgang startet erst über lauf.py, wenn er Spike zuteilt. Bei mir liegt danach nichts mehr.
5. Lücken:
   - Laut Profil „tust jede Zeile seiner Ausgabe und nicht mehr“. 1784 A verlangt aber einen Start „von Hand“, der in keiner lauf.py-Zeile steht. Wie man von Hand startet (Startsperre „(Neustart <Commit>, 1739)“, wie `nachtstarts.py` im Kopf sagt), steht nicht im Text.
   - Wo „die letzte Übergabe“ steht, sagt der Text nicht. `docs/vorgang/1739.md` gibt es nicht, `docs/vorgang/` enthält nur `1789.md`.
   - Ob „Stillstand an einer Entscheidung“ auch einen Werkzeughalt meint, ist offen.
   - Ein Werkzeugvorgang für Spike konkurriert mit 1739 in Spikes Vorrang.

## D2 – „steckt fest: Notizkopie alt … Reset auf origin/main?“

1. Schritte:
   1. Die Nummer hole ich aus der Besetzung oder dem Titel der Sitzung (im Fall nicht genannt).
   2. Hat die Sitzung selbst `vorgang.py rueckmeldung` benutzt, steht die Zeile schon da. Prüfen mit `python3 tools/vorgang.py offen Sokrates`.
   3. Kam sie nur als Nachricht, trage ich sie wörtlich ein: `python3 tools/vorgang.py rueckmeldung <Nr> "steckt fest: Notizkopie alt, 51 eigene Commits, 603 fehlen. Reset auf origin/main?" --sitzung <Rolle>`.
   4. Das Werkzeug legt die Zeile „steckt fest: Rückmeldung … lesen (1763 C)“ an Sokrates an.
   5. Sofort lauf.py ausführen. Je nach Ausgabe folgt `WEITER <id> | Sokrates | 1763 C | …`, also `send_message` an die Sokrates-Sitzung (laut Besetzung läuft sie, 21:52), oder `START Sokrates …`, dann `create_session` mit allen Feldern.
2. Was ich nicht tue:
   - Die Frage „Reset?“ beantworte ich nicht. Ein Reset würfe 51 eigene, ungepushte Commits weg (Sockel 7, 8), und die Lösung ist Sokrates' Sache.
   - Ich setze nichts selbst zurück.
   - Ich schreibe nicht an den Chef.
3. Geöffnete Quellen: `tools/rueckmeldung.py` (`weitergabe`, `eintragen`) und ARBEIT-BESETZUNG.md.
4. Zeitpunkt: Sofort, höchstens 5 Minuten. Sokrates wird per WEITER/`send_message` oder per Start geweckt. Die Sitzung, die feststeckt, wartet bis dahin.
5. Lücken:
   - Ob ich der wartenden Sitzung „nicht zurücksetzen, Sokrates ist dran“ schreiben darf, sagt der Text nicht. Erlaubt sind nur Wecker.
   - Der Text sagt nicht, ob eine 603 Commits alte Notizkopie den Betrieb betrifft: Übergaben gehen über origin/main, `uebergabe.atomar` verlangt `main`.

## D3 – „fertig“ zu Werkzeug, eine Stunde später nicht auf `main`

1. Schritte:
   1. Die Rückmeldung muss eingetragen sein: `python3 tools/vorgang.py rueckmeldung <Nr> "fertig: Lauf grün, Geprüft an: a1b2c3d" --sitzung Spike`. Das Werkzeug erkennt den Commit und legt eine Zeile „prüfen“ an den Prüfer (Diogenes) an.
   2. Beleg prüfen: Was verlangt das Feld „Beleg“ im `## Auftrag` von `docs/vorgang/<Nr>.md`? Verlangt es eine Lauf-Nummer oder einen Link und steht nur „Lauf grün“ ohne Nummer da, nehme ich „fertig“ nicht an. Ich schreibe dann eine Zeile an die Fachkraft: „Beleg fehlt: Lauf-Nummer/Link zum grünen Lauf“.
   3. Eine Stunde später (Nachlese der Stundenuhr) prüfe ich: `git -C /home/user/bornim-main fetch -q origin main && git -C /home/user/bornim-main merge-base --is-ancestor a1b2c3d origin/main; echo $?`. Ergebnis 1 heißt nicht auf `main`.
   4. Dann geht eine Zeile an die Fachkraft: `python3 tools/vorgang.py uebergabe <Nr> Spike "auf main, Vollzug mit Commit"` (erstes Wort „auf“). Danach lauf.py ausführen. Läuft Spike, folgt NACHRICHT/`send_message` mit dem Wecker „sieh in <Nr> (<Nr>-Ün)“, sonst ein START.
2. Was ich nicht tue:
   - Selbst nach `main` mergen (das Büro baut nichts).
   - Den Prüfer zusätzlich anstoßen; seine Zeile steht schon.
   - An den Chef melden: Werkzeug braucht keinen Test des Chefs.
3. Geöffnete Quellen: `tools/rueckmeldung.py` und Git.
4. Zeitpunkt: Die Rückmeldung bearbeite ich sofort. Dass der Zweig fehlt, merke ich erst mit der Stundenuhr, also bis zu 60 Minuten. Den Wecker schicke ich sofort danach.
5. Lücken:
   - Der Text sagt „Werkzeug ohne Spielinhalt führt die Fachkraft nach grünem Lauf selbst nach `main`, der Prüfer danach“. Das Werkzeug macht es anders: `rueckmeldung.py` `weitergabe()`: `if COMMIT.search(text): return PRUEFER, "prüfen: „fertig“ …"`. Der Prüfer bekommt also die Zeile, bevor der Zweig auf `main` ist.
   - Keine Zeile in lauf.py prüft „fertig, aber nicht auf `main`“. Ich merke es nur, wenn ich daran denke. Wann „eine Stunde“ beginnt, sagt der Text nicht.

## D4 – Chef 23:15 „nicht zu viel laufen“, 01:10 Kür-START

1. Schritte:
   1. Um 23:15 schreibe ich das Chefwort wörtlich mit Zeit ins Protokoll (`docs/ARBEIT-BETRIEB.md`, Edit, pushen): „- 23:15 21.11.: Chef: „Lass mal heute Nacht nicht zu viel laufen, dass wir vielleicht morgen früh noch Luft haben.““
   2. Laut Kern gehört es außerdem in eine Vorgangsdatei. Eine passende Nummer gibt es nicht, also lege ich als Eingang einen Vorgang an: `python3 tools/vorgang.py neu "Von Chef (21.11., 23:15): Nachtlauf sparsam" "B Steuerung" M "Ford"`. Dann `python3 tools/vorgang.py chefwort <neu> "Lass mal heute Nacht nicht zu viel laufen, dass wir vielleicht morgen früh noch Luft haben." --zeit "21.11., 23:15"`.
   3. Das Wort erlaubt nichts genau Benanntes. Nach Text gilt deshalb: „bis zu seinem nächsten Wort startest du nur, was es erlaubt, sonst nur die Wache“, also nur die Wache.
   4. Um 01:10 führe ich die START-Zeile der Kür nicht aus. Ich lasse lauf.py erneut laufen: `python3 tools/lauf.py --sperre --besetzung --ohne <Nr>:"Chef 21.11., 23:15: nicht zu viel laufen, bis zu seinem nächsten Wort nur Wache" /tmp/s.txt`. Ich schreibe die Zeile aus, damit keine Warnung „Start nicht angekommen“ (837) kommt. Dasselbe gilt für Muss-Starts.
2. Was ich nicht tue:
   - Die Kür starten.
   - „nicht zu viel“ als „nur Muss“ auslegen.
   - Den Chef fragen, was erlaubt ist (keine der drei erlaubten Meldungsarten).
   - Laufende Sitzungen abbrechen.
3. Geöffnete Quellen: VORGANGSARCHIV.md Zeile 96. Dort stehen dieselben Worte am 18.11., damals mit dem Vorentscheid „bis 07:00 keine neuen Starts außer Ford-Wache“. Das passt zu meiner Auslegung. Außerdem die Hilfe von lauf.py zu `--ohne`.
4. Zeitpunkt: Das Chefwort schreibe ich sofort um 23:15 ein. Um 01:10 starte ich nichts. Die Sperre gilt bis zum nächsten Wort des Chefs. Bei mir liegt nur die Kürzeile, und die liegt bewusst.
5. Lücken:
   - Sockel 3 sagt „Ist der Auftrag unklar …: anhalten, Frage zurückmelden“. Das Profil erlaubt an den Chef aber nur dreierlei, eine Rückfrage gehört nicht dazu. „Nicht zu viel“ bleibt ungeklärt.
   - Ort des Chefworts: Kern sagt „Vorgangsdatei“, Profil sagt „Protokoll“.
   - `chefwort.py` legt zusätzlich eine Zeile an den Arbeitsplaner an, und das bin bis zur Umschaltung ich selbst (`ALT_EMPFAENGER`).

## D5 – Zwei „Frage“-Zeilen an Sokrates (22:44, 23:08), Sokrates läuft nicht, 23:10

1. Schritte:
   1. `python3 tools/vorgang.py offen Sokrates` bestätigt beide Zeilen.
   2. `list_sessions` → Kurzform → `python3 tools/lauf.py --sperre --besetzung /tmp/s.txt`. `sokrates_zeilen()` gibt genau eine `START Sokrates | <Modell> | … | Sokrates – 1763 C: offene Zeilen (21.11., 23:10) | Sokrates\n\nOffene Zeilen an dich (1763 C): <K1> Frage …; <K2> Frage …` aus, mit beiden Zeilen in einem Start.
   3. Notizen pushen (die Startsperre steht dann auf `main`).
   4. `create_session` mit allen Feldern der Zeile (source_url, source_revision main, environment_id, Titel, erste Nachricht).
2. Was ich nicht tue:
   - Zwei Sokrates-Sitzungen starten.
   - Die Fragen zur Lauffreigabe selbst beantworten.
   - Ohne lauf.py starten (der Haken würde es auch abweisen).
3. Geöffnete Quellen: `tools/lauf.py` `sokrates_zeilen` und `tools/rueckmeldung.py`.
4. Zeitpunkt: Jetzt um 23:10, sofort. Die erste Zeile liegt schon 26 Minuten, also weit über den 5 Minuten Anhalt. Sokrates wird durch die neue Sitzung geweckt.
5. Lücken:
   - Warum lag die Zeile? Ohne Sokrates-Sitzung druckt `rueckmeldung.py` nur „KEINE SITZUNG Sokrates läuft: lauf.py startet ihn (1763 C)“. Mich weckt niemand, außer der Absender schreibt mir oder die Stundenuhr schlägt. Der Text sagt „Bei jedem Wecker (Nachricht oder Stundenuhr)“, aber nicht, wer mir bei einer Sokrates-Zeile die Nachricht schickt.
   - Möglicher Folgefehler: Der Titel jedes Sokrates-Starts heißt „Sokrates – 1763 C …“. Der Nachtstopp-Haken (`nacht()`, Regex auf die Nummer im Titel) zählt 1763. Wenn die Startsperre-Zeilen dieser Nacht 1763 nennen, hält der vierte Sokrates-Start der Nacht an. Ob sie es tun, habe ich nicht belegt.
   - Ob nachts nur bestimmte Rollen laufen dürfen, sagt der Text nicht.

## D6 (Wache 7) – „Liegt: 1650, 1653, 1654 abgenommen seit 7–9 h, in keinem Build“

1. Schritte:
   1. Belegen: `python3 tools/vorgang.py 1650 1653 1654`.
      - 1650: Stand „gebaut, Geprüft an: 6ab87322b (Bild 👍)“, Feld Build „–“. Archiv: „1650 gebilligt (18.11., 17:12) → Hose im Stiefel so in den Sammelbuild“.
      - 1653, 1654: Stand „startbar, gebilligt 18.11. 22:3x, in nächsten Build“, Build „–“. Archiv: „aus `claude/jerry-1653-kleid` so lassen, in den nächsten Build“.
      Abgenommen und ohne Build ist damit belegt.
   2. Der nächste Schritt ist der Build, also schreibe ich je Vorgang eine Zeile an die Fachkraft Technik:
      - `python3 tools/vorgang.py uebergabe 1650 Spike "in den nächsten Sammelbuild: abgenommen (Archiv 18.11., 17:12), Zweig claude/tom-1650-stiefel, liegt seit 7–9 h ohne Build (Wache)"`
      - `python3 tools/vorgang.py uebergabe 1653 Spike "in den nächsten Sammelbuild: abgenommen (Archiv 18.11., 22:37), Zweig claude/jerry-1653-kleid, liegt ohne Build (Wache)"`
      - `python3 tools/vorgang.py uebergabe 1654 Spike "in den nächsten Sammelbuild: abgenommen (Archiv 18.11., 22:38), Zweig claude/jerry-1653-kleid, liegt ohne Build (Wache)"`
   3. Danach lauf.py ausführen: NACHRICHT an die laufende Technik-Sitzung oder START.
2. Was ich nicht tue:
   - Selbst bauen.
   - „wartet auf Chef“ setzen, weil es keine offene Testbitte gibt.
   - Dem Chef schreiben.
3. Geöffnete Quellen: `vorgang.py 1650 1653 1654` und VORGANGSARCHIV.md.
4. Zeitpunkt: Sofort auf den Wecker der Wache. Je Zeile höchstens 5 Minuten, dann ist die Sache bei Technik.
5. Lücken:
   - Wer den Build macht, sagt der Text nicht (nur „Build“ als nächster Schritt). Den Build-Macher kenne ich nur aus der Fallbeschreibung D8.
   - Ein Sammelbuild hat keine Vorgangsnummer. Laut Text gibt es keinen „Start ohne Auftrag mit Feld Zurück“, und `lauf.py` `auftrag_fehlt(nr)` prüft je Vorgang. Wer den Auftrag für den Build schreibt (der Arbeitsplaner?), sagt der Text nicht. Ebenso offen ist, ob drei Zeilen oder eine richtig sind.

## D7 (Wache 7) – „Liegt: Builds 286–292 vom Chef freigegeben, seit 3 h nicht auf `main`; Lauf 293 rot“

1. Schritte:
   1. Belegen, bevor ich etwas tue:
      - `git -C /home/user/bornim-main branch -r --merged origin/main | grep -E "build-(28[6-9]|29[0-4])"` → 286, 287, 289, 290, 291, 292, 293, 294 sind auf `main`. 288 fehlt nur als Zweig.
      - `git log origin/main..origin/claude/build-288` → 6 Commits fehlen, darunter Reverts von 785.8, 1000, 1145 und ein Merge.
      - Archiv Zeile 280 (16.11., 20:28): „286–292 auf `main`, 293 … Lauf rot … „Ok, 294 abwarten“ → das Bestandene aus 293 kommt mit Build 294 auf `main`“.
   2. Ergebnis: Die Meldung der Wache stimmt für 286, 287, 289–292 nicht. 293 soll laut Chefwort nicht allein auf `main`, und 294 ist dort. Dafür gibt es keine Zeile an Technik.
   3. Werkzeugfehler: `python3 tools/vorgang.py neu "Von Disponent (21.11., 23:40, Wache 7): Wache meldet „Liegt: Builds 286–292 nicht auf main“, obwohl auf origin/main gemergt (git branch --merged) und Archiv 16.11., 20:28; Lauf 293 bewusst nicht auf main" "B Werkzeuge" K "Spike"`.
   4. Fund außerhalb des Auftrags (build-288 hat 6 Commits nicht auf `main`, Reverts von 785.8, 1000, 1145) melde ich zurück und behebe ihn nicht. Der nächste Schritt wäre `main`, also geht eine Zeile an Technik: `python3 tools/vorgang.py uebergabe 1724 Spike "Hinweis: claude/build-288 hat 6 Commits nicht auf main (Reverts 785.8, 1000, 1145); prüfen, ob etwas fehlt; nur mit Freigabe nach main"`. Unter welcher Nummer das richtig steht, ist offen (siehe Lücke).
2. Was ich nicht tue:
   - Zeilen „286–292 auf `main`“ verteilen.
   - 293 nach `main` schieben (nicht freigegeben, Chef „294 abwarten“).
   - Laut melden: Es liegt weder ein fremder Commit im Build noch fehlt ein früherer Build, sondern die Meldung ist falsch.
3. Geöffnete Quellen: Git (`branch --merged`, `log`) und VORGANGSARCHIV.md Zeile 280.
4. Zeitpunkt: Sofort auf den Wecker. Bei mir bleibt nichts liegen.
5. Lücken:
   - Wie ich eine „Liegt“-Meldung belege, die sich als falsch herausstellt, sagt der Text nicht. Er kennt nur „Zeile an den, der den nächsten Schritt hat“.
   - Unter welche Nummer ein Fund ohne Vorgang gehört, sagt er auch nicht.

## D8 (K1.3) – Zeile an Technik zu 1724, Technik läuft an anderem Vorgang

1. Schritte:
   1. Freigabe belegen: Archiv Zeile 92: „Build 300 freigegeben ohne 760 (19.11., 07:24, Chef an Sokrates: „wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist …“) → PR 221 auf `main` ohne 760, 1724 (Spike)“. Das ist ein Freigabewort mit Beleg. Der Auftrag mit Feld „Zurück“ steht laut Fall in `docs/vorgang/1724.md`.
   2. lauf.py ausführen. Weil eine Spike-Sitzung läuft, gibt `uebergabe_zeilen()` `NACHRICHT Spike | <session_id> | Offene Zeilen an Spike (1739): 1724-Ün Build 300 auf main, 760 per Revert heraus, Quelle Archiv 19.11., 07:24. Je Zeile `vorgang.py annehmen <Kennung>`, Vorgangsdatei `docs/vorgang/<Nr>.md` lesen; fertig: `vorgang.py erledigt <Kennung>`.` aus.
   3. Diese Nachricht schicke ich per `send_message` an die Sitzung, ohne den Wortlaut zu ändern.
2. Was ich nicht tue:
   - Eine zweite Technik-Sitzung starten (je Bereich eine Sitzung).
   - Die laufende Sitzung unterbrechen.
   - Selbst mergen.
3. Geöffnete Quellen: VORGANGSARCHIV.md Zeile 92, `vorgang.py 1724`, Git, `lauf.py` `uebergabe_zeilen`.
4. Zeitpunkt: Wecker sofort. Danach liegt die Zeile bei Technik, bis sie sie annimmt. Nimmt die Sitzung nicht an, sehe ich die Zeile im nächsten Lauf wieder offen.
5. Lücken:
   - Fund: Laut `vorgang.py 1724` steht der Vorgang im Archiv als „erledigt, Geprüft an: 3db05d4e5“. `git merge-base --is-ancestor 3db05d4e5 origin/main` ist wahr, und `claude/build-300` ist gemergt. Die Zeile könnte also schon erfüllt sein. Ich wecke trotzdem, wie die Werkzeugzeile es verlangt, und gebe den Fund mit, statt ihn zu beheben.
   - Der Text sagt nicht, ob ich zuerst warten soll, bis die laufende Sitzung ihren anderen Vorgang beendet hat.

## D9 (K2.3) – Offen: 1535 (Rückläufer, Fund des Chefs), 1801 (Eilt), 1270 (Muss)

1. Schritte:
   1. `python3 tools/vorgang.py offen` zeigt die Werkzeugfolge. `uebergabe.offen()` `rang()`: `(0 if "fund des chefs" in w else 1 if "eilt" in w else 2, seit)`. Die Folge ist also 1535 → 1801 → 1270.
   2. Ich nehme die Zeilen „in der Folge des Werkzeugs“, eine nach der anderen. 1535 an Figur (Tom): lauf.py ausführen. Hat 1535 einen gültigen Auftrag mit „Zurück“ (sonst setzt `auftrag_fehlt` aus), führe ich START oder NACHRICHT für Tom sofort aus.
   3. Dann 1801, dann 1270, je höchstens 5 Minuten.
   4. Den Widerspruch melde ich als Werkzeugvorgang: `python3 tools/vorgang.py neu "Von Disponent (21.11.): Folge offener Übergabezeilen – Profil „Eilt, Fund des Chefs, Themenblock, Eingangszeit“, vorgang.py offen „Fund vor Eilt“, lauf.py NACHRICHT nach Dateiname; Themenblock nirgends" "B Werkzeuge" K "Spike"`.
2. Was ich nicht tue:
   - Drei Starts gleichzeitig für dieselbe Rolle.
   - Selbst „Eilt“ setzen oder wegnehmen (das setzt nur der Chef).
   - 1535 ohne Auftrag mit „Zurück“ starten.
3. Geöffnete Quellen: `tools/uebergabe.py` `offen()` und `tools/lauf.py` `uebergabe_zeilen()` und `auftrag_fehlt()`.
4. Zeitpunkt: Sofort, eine Zeile nach der anderen, je etwa 5 Minuten. Die letzte liegt bis zu etwa 15 Minuten bei mir.
5. Widerspruch: Der Text sagt „in der Folge des Werkzeugs (Eilt, Fund des Chefs, Themenblock, Eingangszeit)“. Das Werkzeug kennt drei verschiedene Folgen:
   - Text: 1801 → 1535 → 1270.
   - `vorgang.py offen` (`uebergabe.py` `rang`): Fund vor Eilt, also 1535 → 1801 → 1270.
   - `lauf.py` `uebergabe_zeilen`: gruppiert nach Empfänger und reiht nach Dateiname (`sorted(os.listdir(d))`), also 1270 → 1535 → 1801. Die NACHRICHT nennt die Zeilen in dieser Folge.
   „Themenblock“ kommt in keinem Werkzeug vor. Ich folge `vorgang.py offen`, weil der Text ausdrücklich auf das Werkzeug verweist. Sicher ist das nicht.

## D10 (K3.2) – Erstes „steckt fest“ zu 1694, Technik danach idle

1. Schritte:
   1. Prüfen, ob die Rückmeldung eingetragen ist (`python3 tools/vorgang.py offen Sokrates`). Sonst trage ich sie ein: `python3 tools/vorgang.py rueckmeldung 1694 "steckt fest: <Wortlaut>" --sitzung Spike`. Ergebnis: Zeile „steckt fest: Rückmeldung … lesen (1763 C)“ an Sokrates (erste, also unter Obergrenze B).
   2. lauf.py ausführen: WEITER an Sokrates, wenn er unter 200 Tsd. Token läuft, sonst START Sokrates. Das führe ich sofort aus.
   3. Gibt lauf.py im selben Lauf einen START der Fachkraft auf 1694 aus, obwohl die Zeile bei Sokrates offen ist, führe ich ihn nicht aus. Ich lasse lauf.py mit `--ohne 1694:"steckt fest, bei Sokrates (1694-Ün), 1763 C"` erneut laufen.
2. Was ich nicht tue:
   - Die idle Technik-Sitzung von Hand archivieren (das regelt die Archivregel von lauf.py).
   - Ihr eine Lösung schicken.
   - Selbst über den Weg urteilen.
3. Geöffnete Quellen: `tools/rueckmeldung.py` (`MAX_FEST = 2`, `eintragen`) und `vorgang.py 1694`.
4. Zeitpunkt: Sofort, höchstens 5 Minuten bis Sokrates geweckt ist. Bei mir liegt danach nichts mehr.
5. Lücken:
   - `rueckmeldung.py` setzt bei „steckt fest“ weder Stand noch Feld „wartet auf“. Der Vorgang bleibt damit für lauf.py startbar, und eine neue Fachkraft-Sitzung kann auf denselben Fehler laufen.
   - Ob ich dann `vorgang.py warte 1694 Sokrates` setzen oder `--ohne` nehmen soll, sagt der Text nicht. Er sagt nur „tust jede Zeile seiner Ausgabe und nicht mehr“.

## D11 (K3.5) – Zweites „steckt fest“ zu 1694, lauf.py gibt noch START für eine Fachkraft

1. Schritte:
   1. Eintragen (falls nicht schon geschehen): `python3 tools/vorgang.py rueckmeldung 1694 "steckt fest: <Wortlaut>" --sitzung Spike`. Das Werkzeug meldet „OFFEN 1694-Ün an Sokrates (Obergrenze B: 2. „steckt fest“ → ruht, beim Chef)“. Es schreibt „Zustand: ruht, beim Chef“ in `docs/vorgang/1694.md`, und `liste_ruht()` ändert `docs/LISTE-VORGAENGE.md` nur lokal: „LISTE … geändert: committen und pushen“.
   2. Die Liste committen und pushen (Notiz auf `main`).
   3. lauf.py erneut ausführen. Steht der START für eine Fachkraft auf 1694 noch da, führe ich ihn nicht aus. Ich rufe `python3 tools/lauf.py --sperre --besetzung --ohne 1694:"ruht, beim Chef (Obergrenze B, 1763), zweites steckt fest" /tmp/s.txt` auf.
   4. Werkzeugvorgang: `python3 tools/vorgang.py neu "Von Disponent (21.11.): lauf.py gibt START für 1694 trotz „Zustand: ruht, beim Chef“ in docs/vorgang/1694.md (Obergrenze B); liest nur die Liste, rueckmeldung.liste_ruht ändert sie ungepusht" "B Werkzeuge" M "Spike"`.
   5. Die Sokrates-Zeile „an den Chef: Chefsache anlegen, nicht selbst lösen“ führe ich per lauf.py aus (WEITER oder START Sokrates).
   6. Wenn Sokrates die Chefsache-Datei angelegt hat und der Chef jetzt etwas tun kann, schicke ich lautlos eine Zeile: `/home/user/bornim-main/tools/meldung.sh Ford "1694 Griff für alle Dinge: zweimal festgefahren, neue Chefsache [<Nr>](cs:<marke>) zum Entscheiden"`.
2. Was ich nicht tue:
   - Den START der Fachkraft ausführen (es gäbe einen dritten Versuch ohne Chef).
   - Selbst eine Chefsache anlegen (das macht Sokrates).
   - Laut melden.
3. Geöffnete Quellen: `tools/rueckmeldung.py` (`MAX_FEST`, `liste_ruht`, `haupt`) und die Hilfe von `vorgang.py`.
4. Zeitpunkt: Sofort. Sokrates wird über lauf.py geweckt. Die Meldung an den Chef geht, sobald die Chefsache-Datei auf `main` steht. Bis dahin liegt 1694 bei Sokrates, nicht bei mir.
5. Widerspruch:
   - Der Text sagt „tust jede Zeile seiner Ausgabe und nicht mehr“ und „das zweite desselben Vorgangs geht als Chefsache an den Chef“. Das Werkzeug gibt trotzdem einen START aus. Ursache: `rueckmeldung.py` `liste_ruht()` druckt nur „committen und pushen“, und lauf.py zieht auf origin/main und sieht die ungepushte Liste nicht.
   - Ob ich mit `--ohne` gegen eine Werkzeugzeile handeln darf, sagt der Text nicht ausdrücklich. Ich tue es, weil der Sockel (Chef entscheidet) und die Obergrenze vorgehen.
   - Wann der Chef „jetzt etwas tun kann“ (23 Uhr nachts?), ist nicht bestimmt.
