# Nachprüfung 3d zu 1727 (frischer Prüfer, 22.11., 07:57)

Geprüft an `a87f37fe1` (`main`). Gelesen: `nachpruefung-3c.md`, Diff `b814aa79b..a87f37fe1` (Liste und `1727-muster`), `profil-pruefer.md` (F11), `ergebnis.md` (F3), `vorschlaege-10-00.md` (F5), `werkzeuge.md` Zeilen 7, 63, 81 und Schritt 8, `herausgezogen.md`:54–64, `vorlage-1727h-umschalten.md`, `docs/chefsache/MUSTER.md`, Soll `falltest-faelle-22-11.md` P1, P4, P6, P7, Lauf 3 `faelle.md` P1, P4, P6, P7, `pruefer-1.md` (P7, Lücken), `pruefer-2.md` (P1, P9), `disponent.md` L1, `arbeitsplaner.md` 13, `kern-arbeitsplaner.md` Feld 6, 7, A16 „Bisher“, `tools/rueckmeldung.py`:10–20, :101, :143–146, :216, `tools/lauf.py`:4–28, die Vorgänge 1760, 1796–1799, 1804, 1864, 1865, 1868, 1871–1879, 1887–1889, 1892, Archiv :6, :11, :23, :27.

## Byte- und Ladesummen (Prüfpunkt 2)

- Profil Prüfer F11 nach Messregel: **2.831**. Stimmt.
- `herausgezogen.md`:64: 1.109 + 1.567 + 2.831 = 5.507; + 876 = 6.383; + 1.168 = 7.551. Stimmt.
- Formmangel-Folge (Schritt 2 „fehlt eine Beschriftung, ein Maß aus dem Auftrag, eine Angabe aus Feld 7 oder die Testausgabe“ statt „… oder ein Maß aus dem Auftrag“): gemessen +41, im Text „etwa +45“. Plausibel.
- „Auftrag ohne Prüffragen“, Folge „… oder Prüffragen fehlen“: +24, im Text „etwa +20“. Plausibel.

Keine Abweichung.

## Soll-Fälle gegen F11 (Prüfpunkt 2)

| Fall | Schritt 1–3 und Meldung mit F11 | Soll erreicht? |
|---|---|---|
| P4 | Commit `7ffa71528` = „Bisher“: Belegmangel, weiter; Laufkopf `5b0e2c1` ist ein anderer Stand: „Beleg fehlt“ und Ende | ja |
| P7 | Commit `be2c0d8` = „Bisher“: Belegmangel, weiter; Film zeigt keinen Stand: Belegmangel, weiter; Neues nicht drin: „nein“; Schritt 2: Angriff 3 nicht beurteilbar, Satz mit seitlicher Kamera; Schritt 3: Angriff 1, 2 „nein“. Meldung „nein“, Belegmangel als Satz | ja (siehe Befund 6: dazu „steckt fest“) |
| P6 | Commit neu; Mangel sichtbar: „nein“; Chef-Nein unter „Chefworte“: „steckt fest“ mit Handwerksregel | ja mit F11; mit dem Votum „Auftrag ohne Prüffragen“ nicht (Befund 1) |
| P1 | kein Unterschied alt gegen neu: „nein“ mit Befund (Beule); Chefworte mit drei Funden: „steckt fest“ | ja |

## Stand der 6 Befunde aus 3c (Prüfpunkt 1)

| Nr. | erledigt? | was fehlt |
|---|---|---|
| 1 | ja | F11 wie vorgeschlagen, 2.831, `ergebnis.md` P4, P7, Prüfer-1 1, 2 auf F11. Folge für P7 nicht vorhergesagt (Befund 6). |
| 2 | teilweise | Vermerk zu 1880–1886 steht nur in `ergebnis.md`, nicht in Liste, Archiv oder `ARBEIT-BETRIEB.md` (grep: kein Treffer); 3c schlug Liste oder Archiv vor. Prüfer-1 L8 ist in 1879 nachgetragen: ja. |
| 3 | teilweise | D1 → 1877, 1873/1877 verwiesen, 1889 geschlossen, Arbeitsplaner 6 → 1864, Disponent L1 → 1892: ja. 1876 ist nicht gekürzt, trägt weiter „ohne Schalter ‚nur Rückläufer‘“; die Überschneidung mit 1804 steht nur in `ergebnis.md`. Arbeitsplaner 13: die Lesart steht nur in `ergebnis.md` (Befund 5). |
| 4 | ja | Zwei Fragen aufgenommen, drei Umstellungsfolgen in `werkzeuge.md` Schritt 8 (über 1871). Die neue Frage hat aber einen Fehler (Befund 1). |
| 5 | ja | 1760 „erledigt (greift Lauf 337)“, D5 „ungeprüft“. |
| 6 | ja | V1 „1: 18 …“, V4 „(erste Fassung, 2.753)“, Kopf F5 mit 07:43, Liegezeit mit Votum und 1868, Zählung „schlechter P6, P1“. |

Teilweise aus der 3c-Tabelle (zu 3b):

| 3b Nr. | erledigt? | was fehlt |
|---|---|---|
| 3 | ja | über 3c Nr. 1. |
| 6 | teilweise | über 3c Nr. 2–4 (siehe oben). |
| 8 | teilweise | Die fehlenden Fragen sind drin. Die Überschrift „Fragen, die Text oder Werkzeug ändern“ steht unverändert über Punkten mit „kein Textwechsel“ (Handypunkte, Rückläufer „so lassen“). Kein Wort dazu in `ergebnis.md`. |
| 9 | ja | über 3c Nr. 6. |
| 10 | nein | V4-Entkräftung „so sieht der Prüfer in Git, dass der rote vor dem behobenen liegt“ unverändert; Profil Prüfer Schritt 1 kennt weiter nur „den gemeldeten Commit“. Kein Wort dazu. |
| 12 | nein | Kopfzeile `disponent.md` unverändert (Eingriff nur in D4 vermerkt). Kein Wort dazu. |

## Neue Befunde

**1. Votum „Auftrag ohne Prüffragen“ bricht Soll P6 und beschreibt 1879 als gebaut** (`vorschlaege-10-00.md`:23; Soll `falltest-faelle-22-11.md`:59; Lauf 3 `faelle.md`:41; `ergebnis.md` Prüfer-1 8).
- Beleg: Der Auftrag in P6 hat Ziel, Bisher und Prüfart, aber keine Prüffragen (`pruefer-1.md`:30 „Prüffragen nennt der Fall nicht“; genau daher stammt Prüfer-1 L8). Votum: ohne Prüffragen „nein, Auftrag“. Das zählt nicht als Runde, löst kein „steckt fest“ aus und geht an den Arbeitsplaner. Soll P6 verlangt aber „nein … steckt fest“ an Sokrates („NICHT: nur ‚nein‘ an die Fachkraft“). Den sichtbaren Mangel (Hand im Stab) verschluckt das Votum. Profil Schritt 3 erlaubt „Nein, Auftrag“ heute nur, „ohne dass du einen Mangel siehst“. Das Gegenargument („eine Runde mehr“) trifft das nicht. Dazu: „bis dahin verhindert es das Werkzeug (1879 …)“. 1879 steht aber auf „startbar“, nicht gebaut. `ergebnis.md` Prüfer-1 8 sagt dagegen „bis dahin am Ziel prüfen“.
- Vorschlag: Votum „fehlen Prüffragen und siehst du keinen Mangel: ‚nein, Auftrag‘; siehst du einen, ‚nein‘ am Ziel, dazu ‚Hinweis: Prüffrage fehlt‘“. Das ist schon die Lesart von Schritt 3, dann wohl ohne Textwechsel. Stärkstes Gegenargument: Ein Mangel wird verschluckt und „steckt fest“ fällt aus (P6). „verhindert“ → „verhindern soll es künftig 1879“.

**2. Vorlage 1727h: „fast alle Teilbefunde sind Werkzeuglücken“ stimmt nicht** (`vorlage-1727h-umschalten.md` Frage und Auswertung; `ergebnis.md` Tabelle).
- Beleg: Von den 9 „teilweise“ haben nur D1, D3 und D5 einen Werkzeug-Träger (D5 dazu „ungeprüft“). A1 hat „offen fürs Gespräch, kein Vorschlag“. A3, A5 und A7 sind Gesprächsfragen. P7 und P1 hängen an ungespielten Texten (F11, F9). Das „nicht“ P6 ist ein Text. Die Entkräftung „die Teilbefunde haben je einen Vorgang, die meisten im Werkzeug“ ist damit zweimal falsch: A1 hat keinen Vorgang, und die meisten sind Text oder Frage. Gerade damit begründet A, dass kein Lauf 4 nötig ist.
- Vorschlag: „3 von 9 Teilbefunden sind Werkzeuglücken mit Vorgang, 4 Gesprächsfragen (A1 ohne Vorschlag), 2 ungespielte Texte; dazu P6 (Text)“. Als Gegenargument ehrlicher: Die Texte, an denen P1, P4, P6 und P7 hängen, sind ungespielt.

**3. Vorlage 1727h nach F11 nicht nachgezogen; Berührt unvollständig** (`vorlage-1727h-umschalten.md` Sachverhalt, Auswertung B, Berührt).
- Sachverhalt „ungespielt: Profil Prüfer F8–F10“ und B „Prüfer F8–F10, V4 Feld 7“: seit `a87f37fe1` gilt F8–F11 (so `ergebnis.md`). B nennt außerdem Profil Disponent F15 nicht, der Sachverhalt schon.
- Berührt nennt 1865, das seit `55c4b9375` „erledigt, doppelt zu 1871“ ist. Es fehlen 1796, 1798, 1799 und 1804, die `ergebnis.md` unter „Werkzeuglücken aus Lauf 3“ führt (1798 trägt Arbeitsplaner 1, 2). Dagegen ist 1797, ebenso alt, aufgenommen.
- Vorschlag: F8–F11 an beiden Stellen, F15 in B; 1865 streichen, 1796, 1798, 1799, 1804 ergänzen oder die Liste „wie `ergebnis.md` Werkzeuglücken“ nennen.

**4. Vorlage 1727h: Archiv 11:17 fehlt, ein Weg fehlt, Rückweg zu leicht** (`vorlage-1727h-umschalten.md`; Archiv :23, :27; `MUSTER.md` Checkliste 4).
- Beleg: Archiv 21.11., 11:17 legte die Reihenfolge fest: „herausziehen → umgemünzt fertig → Gegenprüfung → Falltest, Werkzeuge nebenher“. A ändert auch diese Entscheidung, den Falltest gibt es dann nicht mehr. Der Sachverhalt nennt nur 14:37. Zitiert ist „14:37 D“. Im Archiv steht „umgeschaltet erst nach …“ hinter D, im selben Satz wie „20:00 = Beginn der Arbeit“. Das ist vertretbar, aber nicht wörtlich D.
- Fehlender Weg zwischen A und B: Lauf 4 nur Prüfer (P1, P4, P6, P7 gegen F11), eine Sitzung. Der Prüfertext änderte sich viermal ungespielt (F8–F11), die anderen ungespielten Stücke nicht so oft. B setzt „vier Sitzungen, etwa eine Stunde“ ohne Beleg an. Für Prüfer und Arbeitsplaner (V4 Feld 7) reichen zwei.
- Entkräftung „der Rückweg ist ein Revert“: Nach dem Umschalten schreiben Disponent, Arbeitsplaner und Werkzeuge in umgezogene Vorgangsdateien und in die umgestellte Liste. Ein Revert des Umschalt-Commits nimmt den Umzug zurück, die späteren Einträge nicht. Dazu sagt die Vorlage nichts.
- Vorschlag: 11:17 in den Sachverhalt, Weg „B′: nur Prüferfälle, eine Sitzung“ mit Kosten, Rückweg mit Satz, was mit Einträgen nach dem Umschalten geschieht (oder „Rückweg nur bis zum ersten neuen Eintrag“).

**5. Zwei Lesarten stehen nur in `ergebnis.md`** (`ergebnis.md` Arbeitsplaner 13, Prüfer-1 8).
- Beleg: Arbeitsplaner 13 „ohne Vorgangsdatei gilt die Zeile der Liste als einzige Quelle, fehlt dort ein Ziel: ‚Frage‘“. Das sagt kein Ladetext (Kern Arbeitsplaner :3 „Lies zuerst die Vorgangsdatei“), und es steht auch nicht in den Gesprächsfragen. Das ist dieselbe Art Lücke wie 3c Nr. 4. Nach dem Umzug haben alle Vorgänge ohne „Zu“-Absatz keine Datei, das ist also der Regelfall. Ebenso stehen „bis dahin am Ziel prüfen“ (Prüfer-1 8) und das Votum in `vorschlaege-10-00.md` nebeneinander (Befund 1).
- Vorschlag: Arbeitsplaner 13 als Frage in `vorschlaege-10-00.md` (Folge Kern Arbeitsplaner „fehlt die Vorgangsdatei, gilt die Zeile der Liste“, etwa +50 Byte) oder als Werkzeugpunkt zu 1871 (Umzug legt für jeden offenen Vorgang eine Datei an).

**6. Kleinigkeiten.**
- P7 mit F11: „Bisher“ in A16 trägt „Film t300.11 Fail“ (Chef 18.11., 22:12). Nach Meldungsregel (Chef-Nein unter „Bisher“ zählt, F9) wird P7 jetzt „nein … steckt fest“ an Sokrates, schon beim ersten Prüfer-Nein. Das passt zu Archiv 14:37 B. `ergebnis.md` P7 und 3c Nr. 1 sagen das aber nicht voraus. Ob „Fail“ als „nein“ zählt, sagt kein Text. Vorschlag: In P7 „dazu ‚steckt fest‘ (Chef-Fail unter ‚Bisher‘)“ vermerken.
- 1797: Mit dem Umbau fiel „(keine Zeile, kein Wecker)“ weg; der Klammerzusatz beschreibt jetzt nur „Auftrag steht“, die Folge für „abgebrochen“ fehlt. Vorschlag: „abgebrochen → …; Auftrag steht → Disponent startet Fachkraft“.
- 1892 „gibt … vor bzw. führt sie aus“ lässt offen, was gebaut wird. `lauf.py`:10 nennt `--sperre` schon im Aufrufkopf, die Ausgabe START nicht. Den zweiten Teil von Disponent L1 („woher die Seiten für `lauf.py` kommen“) trägt kein Vorgang. Vorschlag: eine Wahl in den Titel; L1 Teil 2 an 1892 oder „kein Text, Werkzeug“.
- `ergebnis.md` gibt zu den 3c-Tabellenzeilen 8, 10, 12 kein Wort (siehe oben). Nach Haltung 1 gehört zu jedem Abschnitt eines.

## Prüfpunkte ohne Befund

- Prüfpunkt 3: Diese Zuordnungen stimmen gegen die Liste: 1760 (erledigt), 1797 (mit 1889), 1798, 1799 (gebaut), 1804 (gebaut, wartet auf 1796), 1864, 1872, 1873 (verweist auf 1877, `rueckmeldung.py`:101 stimmt), 1875, 1877 (:14 ist die Kopfbeschreibung, :101 der Code; beides „Hinweis → Disponent“), 1878, 1879 (mit Prüfer-1 L8), 1887, 1888, 1889 (geschlossen), 1892. Doppelt bleibt nur 1876/1804 (Tabelle 3c Nr. 3).
- Prüfpunkt 4, übrige Fragen: Formmangel mit Testausgabe. Das Gegenargument trifft, die Entkräftung über „drittes ‚Beleg fehlt‘ = nein“ greift, beide Fragen stützen sich gegenseitig. Liegezeit: Votum mit 1868 passt zum Titel von 1868 („aus den Übergabezeilen“), „vor Umstellung: unbelegt“ steht so in `werkzeuge.md`:81. V1 „sinkt, aber langsam“ stimmt mit 18, 13, 12, 12, 6. Kein Widerspruch zu Archiv :6, :11, :23, :27 oder `CLAUDE.md` außer Befund 1 (zu Soll P6, nicht zum Archiv).
- Prüfpunkt 5, Aufbau: Kopf, Kurz, „Beim Chef, weil: Rollen und Accounts“ (ein Punkt der Liste, passt), Frage als Frage, Votum „1727h A“, Berührt, Begründung, Sachverhalt mit Quelle, Auswertung mit Gegenargument, Folgerungen, Antwort: wie `MUSTER.md`. „Geprüft an“ und die Werkzeugliste sind Platzhalter (Entwurf, wie beauftragt). 1727h folgt 1727f/g (Archiv :6, :11).

## Was ich nicht prüfen konnte

- Wortlaut Chef 22.11., 07:25 und 21.11., 22:16 außerhalb des Vorrats Sokrates.
- Ob die Soll-Fälle mit F11 so ausgehen wie oben (nicht gespielt, nur am Text nachvollzogen).
- Kosten eines Laufs 4 (Befund 4), geschätzt aus der Zahl der Sitzungen.
