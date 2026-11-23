# Nachprüfung 2 zu 1727, Änderungen 2bbec3741..HEAD (frischer Prüfer, 21.11., 23:56)

Stand: `3b78ca005`. Geprüft habe ich den Diff der sechs Entwurfsdateien und der Vorgänge 1798–1801. Dazu alle Antworten, Fälle und Aufträge in `falltest-lauf2/` sowie `nachpruefung-1.md`, das Soll in `falltest-faelle-22-11.md` und VORGANGSARCHIV :5–74, :96, :392. Weiter Grobablauf 14.1–14.5, `profil-werkzeug.md`, `herausgezogen.md`, die Ladetexte im Scratchpad (`lt/`, `lt2/` bis `lt5/` mit Dateizeiten), `tools/rueckmeldung.py`, `tools/lauf.py` (Hilfe, `--ohne`), `tools/notiz.sh` und `tools/uebergabe.py` (KEINE SITZUNG).

## Byte-Zahlen (Prüfpunkt 4)

| Text | angegeben | gemessen |
|---|---|---|
| Disponent F12 | 3.500 → 3.672 | stimmt |
| Disponent F13 | „siehe Größe“ | **3.642**; die Zeile Größe (:37) nennt noch 3.068 und Sockel 1.110 |
| Prüfer F5 | 2.294 → 2.379 | stimmt |
| Prüfer F6 | „siehe `falltest-ergebnis` Lauf 2“ | **2.481**; dort steht keine Zahl |
| Tester F5 | 2.617 → 2.606 | stimmt |
| Wache F5 | „Text wie Fassung 3“ | **949**; :28 nennt noch „950“ (altes Maß) |
| V1 Kern Leitung | 2.837 → 2.937 | stimmt (Altwortlaut einmal vorhanden) |
| V2 Sockel | 1.109 → 1.129 | stimmt |
| V3 Kern Arbeitsplaner | 2.649 → 2.698 | stimmt |

Die Ladesummen fehlen weiter in allen Köpfen (Archiv 20.11., 16:49). Ohne V2 gerechnet:
- Disponent: 1.109 + 680 + 3.642 = **5.431** (vorher 4.829)
- Prüfer: 1.109 + 1.567 + 2.481 = **5.157** (vorher 4.706)
- Tester: 1.109 + 1.567 + 2.606 = **5.282**
- Wache: 1.109 + 949 = **2.058**
- Mit V2 kommen je Sitzung 20 Byte dazu.

`herausgezogen.md`:58–65 ist weiter veraltet. Befund 12 aus Nachprüfung 1 ist damit nicht erledigt; durch „siehe …“ fehlen jetzt sogar Zahlen.

## Befunde

**1. Lauf 2 lief nicht mit den Texten, die die Bewertung nennt** (`falltest-ergebnis-22-11.md`:103; `vorschlaege-10-00.md`:3, „Lauf 2 spielte V1 und V2 in der ersten Fassung“).
- Beleg: `scratchpad/lt/` wurde um 23:39 überschrieben, mitten im Lauf. Danach standen dort Sockel 1.129 (V2 F2), Kern Leitung 2.937 (V1 F2), Prüfer 2.379 (F5), Tester 2.606 (F5), Wache 949 (F5).
- Die Fachkraft zitiert „Vor Sitzungsende nur Eigenes committen und pushen“ (`fachkraft.md` W1), also V2 F2.
- Der Prüfer zitiert Schritt 2 in F5 („zeigt ein Bild oder Film nicht die Spielansicht …, auch bei Vermerken wie ‚nur X zählt‘“, P5) und den Handy-Satz F5 (P3: „→ nein“).
- Leitung, Disponent und Tester waren vor 23:39 fertig (Dateizeiten 23:32/23:34).
- Damit sind P3, P5 und W1 mit F5 bzw. V2 F2 bestanden, nicht mit F4 bzw. V2 F1.
- **Vorschlag:** Den Satz :103 und `vorschlaege-10-00.md`:3 je Gruppe berichtigen. In Lauf 3 bekommt jede Gruppe einen eigenen, festen Ordner, der während des Laufs nicht überschrieben wird.

**2. Urteile zu milde, Disponent** (:116, :118).
- **D3** gilt als „bestanden“, obwohl der Befund selbst sagt „erst mit Stundenuhr bemerkt“. Die Prüffrage verlangt „binnen 5 Minuten eine Zeile an den Besitzer“; die Antwort sagt „bis zu 60 Minuten“. Das Soll „Liegezeit als Hindernis vermerken“ fehlt. → **teilweise**.
- **D4**: Die Antwort schließt „Laufende Sitzungen abbrechen“ aus, übergibt aber auch nicht. Das Soll D4 verlangt „laufende Sitzungen übergeben und enden“, die Antwort sperrt „bis zu seinem nächsten Wort“ statt bis 07:00 (Archiv :96). Nachprüfung 1 Nr. 2 hat das am Text festgestellt, F13 hat es geändert, die Bewertung zählt D4 trotzdem als bestanden. → **teilweise**, Maßnahme F13.
- **D5**: Die Antwort stellt fest, dass die Zeile 26 Minuten lag, meldet das aber nicht als Hindernis (Soll: „Liegezeit über 5 Minuten als Hindernis melden“). Die eigentliche Ursache steht in der Lücke: „Mich weckt niemand“, denn `rueckmeldung.py`:216 bzw. `uebergabe.py`:184 drucken nur „KEINE SITZUNG …“ und senden keinen Wecker an den Disponenten. Genau das sollte Lauf 2 prüfen („ob jede Übergabe sofort … einen Wecker erzeugt“, :103). → **teilweise**, mit Werkzeugbefund ohne Vorgang (siehe 12).
- **D9**: Der Disponent nimmt bewusst 1535 (Fund) vor 1801 (Eilt), weil `vorgang.py offen` es so ordnet. Soll K2.3 und Archiv :16 (20:51) verlangen „Eilt zuerst“. Das ist dasselbe Muster wie bei D10/D11. → „**nicht, gegen Werkzeug**“. Für Profil Disponent F12 sollte gelten: Widerspricht die Folge eines Werkzeugs dem Text, gilt der Text.
- **D1**: Die Antwort legt einen neuen Werkzeugvorgang an. 1792 deckt denselben Haken aber schon ab (LISTE :259). Damit ist die eigene Regel „Eingang. Gibt es ihn schon?“ verletzt; nebensächlich, aber im Befund fehlt es.
- **D2**: Soll und Prüffrage („verbietet den Reset ausdrücklich, verlangt zuerst die Prüfung auf Ungepushtes“) sind nicht getroffen. Die Bewertung ändert das Soll nachträglich („richtig nach 1727c“), obwohl das Soll um 23:12 nach 1727c (21:43) geschrieben wurde. → als „Soll überholt“ zählen, nicht als bestanden; gedeckt durch die Kette L5.

**3. Urteile zu milde, Arbeitsplaner, Prüfer, Leitung** (:120, :122, :125, :128, :129, :115).
- **A1**: Das Soll verlangt, die verwandten Vorgänge mit „wartet auf 1694“ zu verknüpfen, und eine Prüffrage, die das Umschließen misst. `A1.auftrag.md` verknüpft nichts, und keine Prüffrage misst das Umschließen. → teilweise.
- **A3**: Die Prüffrage „zählt er die verbleibenden Handypunkte?“ wird nicht beantwortet, `A3.auftrag.md` zählt keine. → teilweise.
- **A7 (K2.2)**: Das Soll verlangt einen Rückläufer-Auftrag mit „erst Ursache nachstellen“ und „Bild alt gegen neu mit Bedingungen“. A7 ist ein Nachstellauftrag „kein Bau“ (Kern Feld 3). Daraus folgt:
  - W7 behebt nicht (Soll K2.4: „beheben“);
  - P9 sagt „Beleg fehlt“;
  - die Kette K2 endet nicht beim Chef.
  „Fall schief“ (:129) schiebt das auf den Fall, Ursache ist aber A7 bzw. Kern Feld 3. A8 schreibt dagegen „Ursache nachstellen, dann … beheben“ in einen Auftrag. Der Kern lässt beide Lesarten zu.
  → A7 teilweise. Maßnahme: in Kern Feld 3 klären, ob ein Nachstellauftrag mit „dann beheben“ in einem Auftrag erlaubt ist (V4 ins Gespräch, da 1727f abgenommen ist).
- **P7**: Die Prüffrage („hält ‚nicht beurteilbar‘ getrennt und fordert eine andere Kamera“) ist in beiden Teilen verfehlt. → **nicht**.
- **P1, P2, P4, P7**: Alle vier melden „nein, steckt fest“, weil ein älteres Nein des Chefs unter „Bisher“ steht. Bei P1 widerspricht das Soll K2.5 („‚nein‘ …; Zeile zurück an Tom“): Die Zeile geht an Sokrates, die Fachkraft bekommt keine (P1 Lücke, `rueckmeldung.py`:143). Ein Rückläufer nach einem Fund des Chefs hat „Bisher“ immer mit dem Chef-Nein (Kern Arbeitsplaner: „steht wörtlich unter ‚Bisher‘“). Darum wird jedes erste Prüfer-Nein darauf ein „steckt fest“, und das zweite löst Obergrenze B aus (Chefsache). Das Soll widerspricht sich selbst (P6 gegen K2.5); die Bewertung erwähnt das nicht. → Befund ohne Maßnahme (siehe 12).
- **P8**: Der Befund nennt keinen Grund (nur P9). P8 wirft zwei echte Fragen auf: Darf der Prüfer einen fehlenden Beleg durch eigene Prüfung im Repo ersetzen? Und doppelt sich die Prüfung mit der Vollzugsprüfung des Empfehlers? Beides ohne Maßnahme.
- **L10**: Neben der fehlenden Nachprüfung fehlen „Kosten bisher“ aus dem Soll K3.6. Den Befund ergänzen; Träger offen (Kern Leitung nennt keine Kosten).
- **Ketten**: Das Soll verlangt das Urteil „je Übergabe … und das Ende der Kette“ (`falltest-faelle`:79). Für K1, K2 und K3 fehlt ein Urteil am Kettenende: K1 endet in P8 mit „Beleg fehlt“, K2 bricht an A7/K2.5, K3 bricht an W8. Ergänzen.
- Zählung nach meinen Urteilen (59): bestanden 43, teilweise 10 (L10, D1, D3, D4, D5, A1, A3, A5, A7, P4), nicht 3 (W8, P7, D9 gegen Werkzeug), Soll überholt 1 (D2), Fall schief 2 (P8, P9). D10 und D11 bleiben „bestanden gegen Werkzeug“. Am deutlichsten zu milde sind D3, D4, D9, A7 und P7.

**4. Zählung und Wortlaut.**
- „A6–A16 … 13 Aufträge gültig“ (:122): A6–A16 sind 11 Fälle mit 11 Auftragsdateien, davon 2 Entwürfe. Die 13 gültigen Prüfausgaben kommen nur mit A1 und A3 zustande. Richtig: „A6–A16: 11 Aufträge geprüft gültig, davon A12, A16 als Entwurf“.
- „ungültige Fälle 9 → 0“ (:134) ist zu günstig. P8 und P9 sind schief. Für W8 lag kein Auftrag vor („Zum Auftrag zu 1694 liegt keine Datei vor, also auch kein Feld 7“, `fachkraft.md` W8). D6 und D7 hatten kein vorab festgelegtes Soll (nicht in `falltest-faelle-22-11.md`; Zweck dort :3).
- W8 als „nicht“ mit der Ursache „weil Feld 7 das Wort nicht anbietet“: Für W8 selbst gab es kein Feld 7, gesagt hat es Sockel 3 („Frage zurückmelden“). Die Ursache stimmt allgemein (Ü2, W2-Lücke), der Fall war aber unvollständig gestellt.
- Die Kopfzeile `fachkraft.md` sagt „23:40–23:55“, die Datei ist von 23:47, die Bewertung sagt „23:28–23:47“.

**5. Profil Disponent F13 :20: Die Werkzeug-Ausnahme verliert den D3-Weg und „Prüfer danach“.**
- F11 hatte: „… der Prüfer danach; ist es nach ‚fertig‘ nicht auf `main`, Zeile an sie …“. F13 hat nur noch: „… selbst nach `main`, keine Testbitte“.
- Das Archiv :392 (1311) sagt „Diogenes prüft danach“, `profil-werkzeug.md`:36 sagt „‚fertig‘ mit dem Commit auf `main`. Der Prüfer prüft am Stand von `main`“. Zugleich sagt :20 „‚Fertig‘ mit Commit geht zuerst an den Prüfer“. Die Folge Prüfer und `main` für Werkzeug ist jetzt offen.
- Der Fall D3 (Commit nicht auf `main`) läuft nur noch über LIEGT → Arbeitsplaner (:26), also über einen neuen Auftrag. Das Soll D3 will eine Zeile an den Besitzer. Nachprüfung 1 Nr. 1 hatte das in ihrem Kürzungsvorschlag behalten.
- **Vorschlag** (+78 Byte): „Ausnahmen: Werkzeug ohne Spielinhalt meldet ‚fertig‘ mit Commit auf `main`, der Prüfer prüft danach, keine Testbitte; sonst Zeile an die Fachkraft ‚auf `main`, Vollzug mit Commit‘;“.
- 1794 (Perikles) und :33/:58 beschreiben weiter den Satz aus F8. Befund 13 aus Nachprüfung 1 ist nicht erledigt.

**6. Profil Disponent F13 :24: „keine Starts außer der Wache“ schadet.**
- (a) „Zeile an Sokrates (er setzt das Ende)“ verlangt, dass Sokrates gestartet wird, wenn er nicht läuft. Das verbietet derselbe Satz, und Archiv :9 (1727c: „jede offene Übergabezeile an Sokrates startet ihn“) verlangt es.
- (b) „laufende Sitzungen übergeben“ trifft auch Wache, Sokrates und den Disponenten selbst.
- (c) Muss-Rückläufer und neue Aufträge des Chefs in der Nacht (etwa „1535, ein Lauf frei“) blockiert der Satz bis zum Ende, das Sokrates setzt. Die Stufe 95 % lässt sie dagegen zu.
- (d) Die Wache-Ausnahme stammt aus Archiv :96. Dort steht aber auch, dass Sokrates entscheidet („Votum Sokrates“), was mit (a) nicht geht, solange er nicht läuft.
- **Vorschlag** (+38 Byte): „… Zeile an Sokrates (er setzt Umfang und Ende); bis dahin startest du nur Wache, Sokrates und Rückläufer des Chefs; laufende Fachkräfte übergeben.“
- Werkzeug fehlt weiter: `lauf.py` kennt keine Laufsperre aus einem Chefwort (Nachprüfung 1 Nr. 2), kein Vorgang dazu.

**7. Profil Disponent F12 :14: „‚steckt fest‘ in der Vorgangsdatei“ sperrt auch den freigegebenen zweiten Versuch.**
- Nach K3.3 gibt Sokrates einen zweiten Versuch frei (L9). Das erste „steckt fest“ steht aber weiter in der Vorgangsdatei, also hält der Disponent den START der Fachkraft (K3.4) an. Gemeint ist ein *offenes* „steckt fest“ (Zeile an Sokrates offen).
- „Vorgang mit Profil Werkzeug“: Vorgänge tragen nur den Bereich (Archiv :60), das Profil wählt der Arbeitsplaner.
- „Chefwort widerspricht START“ verlangt ein inhaltliches Urteil. :12 lässt dem Disponenten aber nur Eingang, Frage, steckt fest und Guthaben.
- **Vorschlag** (−14 Byte): „Widerspricht ein START einem Chefwort, offenem ‚steckt fest‘ oder ‚ruht‘: nicht starten, `lauf.py --ohne <Nr>:"<Grund>"`, Werkzeugfehler als Eingang.“ Die Folge bei D9 gleich mit aufnehmen (siehe 2).

**8. Profil Disponent F13 :26 LIEGT → „Zeile an den Arbeitsplaner“ passt nicht zu allen Ständen.**
- LIEGT gilt laut Text für jeden „Vorgang über der Frist seines Stands“. Grobablauf 14.2 nennt aber je Stand einen anderen Weg:
  - 14.2.5 in Arbeit → Sperre lösen, ein Neustart (Disponent);
  - 14.2.6 beim Prüfer → neuer Prüfer;
  - 14.2.9 Chef testet → Erinnerung im Tagesbericht;
  - 14.2.12 steckt fest → nach 48 h Chefsache (Sokrates).
- Eine Zeile an den Arbeitsplaner ist nur bei 14.2.3 und 14.2.7 richtig.
- Nachprüfung 1 Nr. 5 schlug „LIEGT <Nr> | Stand | Alter | an <Rolle>“ vor, also mit Empfänger in der Zeile.
- Der Halbsatz „‚wartet auf Chef‘ nur mit offener Testbitte oder Chefsache“ ist ohne Wache-Zusammenhang unklar: Wer setzt das, wann?
- **Vorschlag** (−71 Byte): „**LIEGT** (`lauf.py`): tu, was die Zeile nennt; ‚wartet auf Chef‘ setzt du nur bei offener Testbitte oder Chefsache.“ In 1799 den Empfänger je Stand nach Spalte „Bewegt weiter“ aus 14.2 aufnehmen.

**9. Profil Prüfer F6 :6, Schritt 1: „prüfe trotzdem weiter“ hat keine Grenze und keinen Vorrang.**
- (a) Ob nach „Beleg fehlt“ (anderer Stand) weitergeprüft wird, bleibt offen. Ziel und Prüffragen an einem Beleg vom falschen Stand zu prüfen, ergibt Scheinbefunde.
- (b) Treffen „nein“ und „Beleg fehlt“ zusammen (P7: Angriffe 1 und 2 nein, Angriff 3 verdeckt; P5/P9-Lücken), fehlt das erste Wort. Das Werkzeug nimmt das erste Wort und zieht „nein“ vor (`rueckmeldung.py`:92); der Text sagt es nicht.
- (c) F6 macht einen Beleg vom alten Stand (P4) zu „Beleg fehlt“, und das zählt nicht als Runde (`rueckmeldung.py`:17). Genau dieser Fall verbrauchte Läufe (Archiv 15.11., 22:46). Mit Schritt 2 „auch nur für einen Teil“ wächst die Schleife ohne Obergrenze. „Drittes ‚Beleg fehlt‘ = Nein“ ist laut :18 weiter offen.
- „Prüfe trotzdem weiter“ steht nicht gegen „steckt fest“ und die Laufbremse: Die Zählung hängt am ersten Wort, nicht am Umfang.
- **Vorschlag** (+65 Byte): „Sonst ‚Beleg fehlt‘ und Ende. … Sonst ‚nein‘, weiter mit 2–4. Trifft ‚nein‘ mit einem Belegmangel zusammen: erstes Wort ‚nein‘, der Belegmangel als Satz.“ Die Obergrenze für „Beleg fehlt“ als Frage ins Gespräch.

**10. Befunde aus Nachprüfung 1, die nicht oder nur halb erledigt sind.**
- **Nr. 8**: Schritt 2 F5 „nicht die Spielansicht (Spielkamera mit Tusche)“ macht fehlende Tusche weiter zu „Beleg fehlt“, auch wenn der Build die Tusche verloren hat (Rückschritt = „nein“ über Schritt 4). Vorschlag: „(Spielkamera, Spiel-Shader)“, fehlende Tusche in der Spielansicht = „nein“.
- **Nr. 9**: „mit dem Satz ‚ohne Prüffrage‘“ steht im „nein“, und das geht an die Fachkraft oder (bei „steckt fest“) an Sokrates. Der Arbeitsplaner erfährt weiter nicht, dass eine Prüffrage fehlt (P2 Lauf 2: „(4) Ohne Prüffrage …“ in „nein, steckt fest“). Vorschlag: zusätzlich eine Rückmeldung „Hinweis: Prüffrage fehlt: …“ (geht an das Büro).
- **Nr. 12, 13**: siehe Byte-Zahlen und Befund 5.
- **Nr. 14**: V1 nennt weiter keine Ladesumme (16:49: „Summe dessen, was die Sitzung lädt“) und hat keine Obergrenze für die Runden.
- **Nr. 17**: Ohne Träger bleiben:
  - L-O1 (:110 „im Gespräch“, steht nicht in `vorschlaege-10-00.md`; L-O1 ist laut Archiv :13 schon entschieden, offen ist nur der Werkzeugbefehl „Eingang“);
  - D5 (Maß „Betrieb steht“);
  - A4 (👎 ohne Wort, `chefwort` mit Emoji);
  - P6/P1 (Fachkraft erfährt „steckt fest“ nicht);
  - W5 (`add_repo`, gedeckt durch 1781? nicht vermerkt).
- Erledigt sind Nr. 1 halb (siehe 5), Nr. 3, 4, 7 (Wache F5) und Nr. 11, 15, 16. Nr. 2 ist im Wortlaut erledigt, hat aber neuen Schaden (siehe 6).

**11. V1 (`vorschlaege-10-00.md`:7): „oder in die Chefsache geht“ ist zu weit.**
- Unter `docs/chefsache/` liegen auch Testbitten unter `ansehen/`, die das Werkzeug schreibt (Archiv :68), Bilder zum Ansehen und Dateien in `billigen/`. Jede bekäme Helferrunden „bis nichts Neues kommt“, und das ohne Deckel.
- **Vorschlag**: „oder in `chefsache/entscheiden/` geht“, dazu „höchstens drei Runden, dann mit den Restbefunden“ und „Summe der Ladung“.
- **V2**: Byte und Wirkung stimmen. Das Gegenargument steht drin.
- **V3**: richtig gegen `rueckmeldung.py`:137 (B zählt nur „steckt fest“). Stärkstes Gegenargument fehlt: Werkzeugweg statt Textwechsel, etwa „Frage“ nach „Ursache und Behebung“ zu zählen. Sockel 3 („Frage zurückmelden“) lenkt eine Fachkraft ohne Feld 7 weiter auf „Frage“. Das ist im Vorschlag zu nennen.

**12. Befunde aus Lauf 2 ohne Maßnahme oder Träger.**
- D5/Ü3: Kein Wecker an den Disponenten bei einer Zeile an eine Rolle ohne Sitzung (`uebergabe.py`:184, `rueckmeldung.py`:216); wer WECKER sendet, steht in keinem Ladetext der Fachkraft. → Spike, mit 1760.
- Guthabenstufe: Das Profil sagt „Das Werkzeug gibt die Stufe aus“, `lauf.py` gibt keine aus (Disponent, Lücke Guthaben); kein Vorgang.
- „nein … steckt fest“ an Sokrates ohne Zeile an die Fachkraft; erstes Prüfer-Nein bei jedem Rückläufer = „steckt fest“ (Befund 3). → Sokrates (Text) oder Spike.
- Liegt 760 (L3) bzw. 1657 (P6): Teams arbeiten an Ruhendem. Die Vorrangregeln 1605, 1714 und 20:06 stehen in keinem Ladetext (Leitung, übergreifend 6).
- R2 „Zahl in die Wochenzählung“: weiter ohne Maßnahme (Nachprüfung 1 Nr. 6).
- W4 „Weg Kaufmodell → Bauserver nur im Profil Technik“ steht in der Spalte Maßnahme, hat aber keinen Träger.
- A-Querschnitt „Auftrag steht“ ohne Weiterleitung: steht in 1797 (Titel nennt „Auftrag steht“). Erledigt.
- 1801 betrifft denselben Haken `nacht()` wie 1792. Prüfen, ob „je Thema ein Vorgang“ hier „mit 1792“ verlangt.

**13. Kleinigkeiten.**
- `profil-tester.md`:11 F5: „Ladezeit ohne Vergleichswert“ fiel weg (F4 hatte „Bildrate oder Ladezeit“). Das sollte erhalten bleiben.
- `routine-wache.md`:34: Spalte 6 „Disponent (3, 4, 6)“ stimmt nach F5 wieder; :28 „950“ → 949.
- `profil-disponent.md`:1: Die Kopfzeile ist über 3 KB lang. Der Verlauf gehört nach Git (`CLAUDE.md` „Jeder Text an einem Ort“).

## Was ich nicht prüfen konnte

- Welchen Ordner (`lt/` oder einen Stand davor) jede Gruppe wirklich gelesen hat. Ich schließe es aus Zitaten und Dateizeiten. Disponent, Leitung und Tester zitieren F11/F4/V1 F1, Prüfer und Fachkraft F5/V2 F2. Beim Arbeitsplaner (23:39) ist es unklar.
- Den Wortlaut von Chef 21.11., 21:37 (nur Vorrat Sokrates).
- Ob die Werkzeugvorgänge 1798–1801 so gebaut werden, wie es die Titel sagen. Alle sind „startbar“; ihr Verhalten ließ sich nicht nachstellen.
- Ob in Lauf 2 eine Sitzung Repo-Dateien geändert hat (laut Antworten nicht; `git status` nicht nachgeprüft).
- Die Beschlusslage zu „Drittes ‚Beleg fehlt‘ = Nein“ (laut Prüfer :18 Chefsache; keine Datei gesucht).
