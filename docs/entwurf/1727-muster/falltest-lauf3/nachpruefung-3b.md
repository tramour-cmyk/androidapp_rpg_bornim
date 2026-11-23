# Nachprüfung 3b zu 1727 (frischer Prüfer, 22.11., 07:31)

Geprüft an `6e8b0aaff` (`main`; Entwürfe und Vorgangsdateien seit `53d244509` unverändert, nur `tools/rueckmeldung.py` neu, siehe Befund 12). Gelesen: `nachpruefung-3a.md`, `ergebnis.md`, alle Antworten in `falltest-lauf3/`, Soll `falltest-faelle-22-11.md`, Diff `4adc85374..HEAD` der genannten Dateien, Archiv :23 (14:37 A–D), :80 (19.11., 13:02), `prozesspruefung-21-11.md` Nr. 1, `tools/rueckmeldung.py`.

## Byte- und Ladesummen (Prüfpunkt 4)

Alle Zahlen stimmen nach Messregel. Profil Prüfer F8 2.849, F9 2.817; Profil Disponent F15 3.775 (+14); V1 2.837 → 2.962 (Altwortlaut genau einmal im letzten Codeblock von 2.1; Ergebnis byte-gleich mit `lt3/kern-leitung.md`); V3 2.698; V3 mit V4 erste Fassung 2.753 (byte-gleich mit `lt3/`), mit V4 neu 2.787. Ladesummen Disponent 5.564, Prüfer 5.493 (6.369, 7.537), Arbeitsplaner mit V3 und V4 4.576. Prüfsummen-Dateien in `lt3/`: Sockel 1.129, Kern Büro 680, Abnahme 1.567, Disponent 3.761, Prüfer 2.730 wie in `ergebnis.md`. Einzige Lücke: Befund 11.

## Stand der 12 Befunde aus 3a (Prüfpunkt 1)

| Nr. | erledigt wie „mein Wort“? | was fehlt |
|---|---|---|
| 1 | teilweise | Zeile „A6–A16 bestanden“ (`falltest-ergebnis-22-11.md`:122) enthält A7, das die Berichtigung :136 und Lauf 3 als „teilweise“ führen |
| 2 | teilweise | F7 zurück, Soll K2.5 berichtigt; aber 3a 2(b) offen (Befund 2) |
| 3 | teilweise | „(Werkzeug 1796)“ steht; der Vermerk „bis 1796 liest der Disponent die Vorgangsdatei“ fehlt |
| 4 | ja | – |
| 5 | teilweise | `docs/vorgang/1804.md` sagt „braucht die Fund-Erkennung aus 1796“ im Text; Feld „wartet auf“ in der Liste :323 leer (`CLAUDE.md`: Warten nur im Feld) |
| 6 | teilweise | `1799.md` vollständig; Titel 1794 in der Liste :198 nennt weiter „profil-disponent.md F8“ |
| 7 | ja | Gegenargument schwach entkräftet (Befund 9) |
| 8 | teilweise | Wortlaut V4 steht, die Sicherung „roter Commit vor Bau-Commit“ trägt kein Text (Befund 10) |
| 9 | teilweise | Absatz steht; Überschrift falsch, Gegenargumente fehlen (Befund 8) |
| 10 | ja | `1760.md` ist seit `6e8b0aaff` teils überholt (Befund 12) |
| 11 | ja | – |
| 12 | ja | Vorrat Spike 29.726 Byte; gekürzt hat Spike selbst in eigenem Commit `855d8aeaf` („nie als eigener Commit“, `CLAUDE.md`) – Hinweis an Spike |

## Befunde

**1. Bewertung P6 und P1 gegen ein zurückgenommenes Soll gezählt** (`ergebnis.md`:20, :24, :27).
- Beleg: Soll P6 (`falltest-faelle-22-11.md`:59) verlangt seit 07:22 „nein … steckt fest“, Prüffrage „Steht danach genau eine Zeile an Sokrates?“. `pruefer-1.md` P6: „‚steckt fest‘? Nein“, Zeile an den Macher. Soll K2.5 (:105) verlangt „nein … steckt fest“ an Sokrates; `pruefer-2.md` P1: „‚steckt fest‘: nein“, Zeile an die Fachkraft. Beide als „bestanden nach F7“ gezählt.
- Gegen das geltende Soll: P6 **nicht**, P1 **teilweise** (abgefangen ja, Empfänger falsch). Die Ursache ist der zurückgenommene Text, nicht die Sitzung; das macht den Fall ungespielt, nicht bestanden.
- Vorschlag: so werten und P1, P6 (F9) sowie P4, P7 (F8) neu spielen, bevor F8 und F9 als geprüft gelten; sonst bei der Vorlage „F8, F9 nicht gespielt“ in die Zählung. Keine Byte-Wirkung.

**2. 3a Nr. 2(b) offen: „Prüfer ja, Chef nein“ stoppt weiter nie** (`profil-pruefer.md`:1 F9; `rueckmeldung.py`:136; Archiv :23 A).
- Beleg: F9 begründet „Wiederholer mit Chef-Nein stoppten nie“. F9 greift nur, wenn der Prüfer „nein“ sagt. Sagt er „ja“ und der Chef „nein“, entsteht ein neuer Auftrag; `zaehlen` liest nur „Rückmeldungen“, Chef-Neins stehen unter „Chefworte“ (`chefwort.py`:114). Obergrenze A („dritter abgelehnter Auftrag“) zählt sie nicht. 3a schlug dafür einen Rückläufer an Spike zu 1763 vor; es gibt keinen (Liste :263 unverändert, kein neuer Vorgang).
- Vorschlag: Vorgang an Spike (Absender Sokrates, Rückläufer 1763): Chef-Nein unter „Chefworte“ zählt für A. Oder in V5 offen sagen, dass dieser Wiederholer ohne Werkzeug bleibt. Keine Ladetext-Wirkung.

**3. F8 „Commit neuer als ‚Bisher‘, sonst nein“ widerspricht Soll P4 und füttert „steckt fest“** (`profil-pruefer.md`:6, :13; Soll :57).
- Beleg: Im Fall P4 ist der gemeldete Commit der unter „Bisher“ (`pruefer-1.md` Nebenbefund) und der Beleg zeigt einen anderen Stand. Nach F8 gilt zuerst „nein“, dann „Beleg fehlt und Ende“; nach :13 „trifft ‚nein‘ mit einem Belegmangel zusammen, erstes Wort ‚nein‘“. Unter „Bisher“ steht „Film 15.11. ✗“ (Chef-Nein), also nach F9 „nein … steckt fest“ an Sokrates. Soll P4: „sonst ‚Beleg fehlt‘. NICHT: ‚ja‘“. Ein bloßer Meldefehler (falscher Commit) zählt so als Runde für A und als „steckt fest“ für B.
- Dazu: „neuer“ ist in Git über Zweige nicht festgelegt (Datum oder Nachfahre?); ohne Commit unter „Bisher“ (erster Auftrag) fehlt der Vergleich.
- Vorschlag: „Ist der gemeldete Commit derselbe wie unter ‚Bisher‘: ‚Beleg fehlt‘ und Ende.“ statt „Ist der gemeldete Commit neuer als der unter ‚Bisher‘? Sonst ‚nein‘.“ (etwa +5 Byte, 2.817 → etwa 2.822). Dann P4 neu spielen.

**4. Bewertung D1 und A1 zu günstig** (`ergebnis.md`:10, :15).
- D1: Soll :24 verlangt eine Zeile an den Besitzer des Hakens (Spike) und „Sokrates ‚Hinweis‘“. `disponent.md` D1 Schritt 4 trägt „Hinweis“ bei 1792 ein; nach `rueckmeldung.py`:14 geht „Hinweis“ an den Disponenten selbst (seine eigene Lücke L9, in `ergebnis.md`:31 als Werkzeuglücke geführt). Spike bekommt keine Zeile, Sokrates keinen Hinweis. Prüffrage halb erfüllt → **teilweise**.
- A1: Lauf 2 war „teilweise“ wegen „ohne Verknüpfung, ohne Prüffrage Umschließen“ (`falltest-ergebnis-22-11.md`:120). Lauf 3 hat die Prüffrage, verknüpft aber weiter nicht (`ergebnis.md` sagt es selbst). Gleiches Maß → **teilweise**. „Der Kern verlangt es nicht“ ist ein Grund für eine Textlücke, kein Bestehen.
- Zählung neu: bestanden 7 (L10, D4, D9, A7, P4, W7, W8), teilweise 8 (D1, D3, D5, A1, A3, A5, P7, P1), nicht 1 (P6), Fall schief 1 (P9) = 17. Gegen Lauf 2: von 13 jetzt 6 bestanden (L10, D4, D9, A7, P4, W8), nicht 8.
- Zusatz: W7 und W8 liefen ohne Profil Figur und Querprofil (`fachkraft.md`:3 „beide fehlen in `lt3/`“); im Ergebnis nicht vermerkt. D4 besteht nach Prüffrage, Soll :27 sagt aber „nur Wache läuft“, die Antwort startet Sokrates (Profil F15); hängt an der Frage „Rückläufer des Chefs“.

**5. Kette K2 „trägt“ ist zu günstig** (`ergebnis.md`:29).
- Beleg: Soll K2.5/K2.6: Prüfer-Nein an Sokrates, zweiter Versuch „von Sokrates freigegeben“. Gespielt ging P1 an die Fachkraft (F7), Sokrates kam nicht vor. Die Kette ist mit dem geltenden Text nicht gespielt.
- Vorschlag: „K2 nicht beurteilbar (F7 gespielt, F9 gilt)“; mit Befund 1 neu spielen.

**6. Prüfer-Lücken ohne Wort, eine davon jetzt zentral** (`pruefer-1.md` Lücken 3, 4, 8; `pruefer-2.md` Lücken 1, 3–6; `leitung.md` Lücken 1–9; `fachkraft.md` Lücken 1–7; `arbeitsplaner.md` Lücken außer 4, 7).
- Beleg: `ergebnis.md`:31 führt nur Disponent L4, L5, L9 und Arbeitsplaner L4, L7. Die übrigen Lücken haben kein Wort (Bekannte Fehler: „Nie einen Helferbefund verschweigen“).
- Zentral `pruefer-2.md` Lücke 1: bei „nein … steckt fest“ geht die Zeile nur an Sokrates (`rueckmeldung.py`:143), die Mängelsätze erreichen die Fachkraft nicht. Mit F9 trifft das jedes erste Prüfer-Nein auf einen Rückläufer. Ebenso Lücke 3: „Hinweis: Prüffrage fehlt“ landet beim Disponenten statt beim Arbeitsplaner. Lücke 4: A7 bearbeitet ein Kaufkleid, lädt Fremde Inhalte nicht.
- Vorschlag: je Lücke ein Wort in `ergebnis.md` (stimmt, Einwand, Frage) mit Träger; Lücke 1 in V5 als Gegenargument (Befund 7) und als Vorgang an Spike (Zeile auch an den Macher). Keine Ladetext-Wirkung.

**7. V5 „Das ist so entschieden“ überdehnt die Quelle** (`vorschlaege-10-00.md`:14).
- Beleg: Archiv :23 A–D nennt „Bisher“ nicht; der Auslöser steht nur in der Grundlage `prozesspruefung-21-11.md` Nr. 1 (3a: „Der Wortlaut von A–D legt den Auslöser nicht fest“). Gegenargument „Sokrates wird nach einem Fehlversuch gerufen“ lässt den stärkeren Einwand aus: die Fachkraft bekommt dann keine Zeile mit den Mängeln (Befund 6), und jeder Rückläufer ist nach zwei Fehlversuchen beim Chef. „Entkräftet“ mit 22:17 („nicht durchrutschen“) steht nur im Vorrat Sokrates, nicht im Archiv.
- Vorschlag: „So lese ich die Grundlage von 14:37 (Nr. 1); bitte bestätigen“ statt „Das ist so entschieden“, als Frage statt „zur Kenntnis“; Gegenargument um die fehlende Zeile an die Fachkraft ergänzen. Keine Ladetext-Wirkung.

**8. „Fragen ohne Textwechsel“ enthält Textwechsel, alle ohne Gegenargument** (`vorschlaege-10-00.md`:16–22).
- Beleg: Votum „drittes ‚Beleg fehlt‘ = nein: ja“ ändert Profil Prüfer und `rueckmeldung.py`:17. Votum Spracherkennung ändert Kern Büro (abgenommen 21.11., 11:46, „nie umformuliert“). „Rückläufer des Chefs“ steht schon im Text F15 :24; ein Nein des Chefs ändert ihn. Keine der sechs Zeilen hat ein stärkstes Gegenargument (`CLAUDE.md` Haltung 1); V1–V5 haben eins.
- Dazu fehlen zwei angekündigte Fragen: `ergebnis.md`:25 „Frage 10:00 (Formmangel beim zweiten Nein)“ steht nicht in der Liste; :16 A3 „Arbeitsplaner lädt Profil Technik (prüfen …)“ hat keinen Träger.
- Vorschlag: Spracherkennung als V6 mit Wortlaut und Byte (Kern Büro 680 → etwa 760, „Lesart in eckigen Klammern neben dem Wortlaut, wenn die Vorlage sie eindeutig macht“); drittes „Beleg fehlt“ als Frage mit Text- und Werkzeugfolge; Formmangel und A3 aufnehmen; je Zeile ein Gegenargument.

**9. V1: Entkräftung trifft das Gegenargument nicht** (`vorschlaege-10-00.md`:7).
- Beleg: Gegenargument „ohne Grenze wächst das ohne Maß“. Entkräftet wird mit „jede Runde fand echte Fehler“; das spricht für Runden, nicht gegen fehlendes Maß. „Lauf 3 brauchte drei Runden“: gemeint sind die Nachprüfungen 1, 2, 3a des Entwurfs, nicht Lauf 3.
- Vorschlag: „Nachprüfungen 1, 2, 3a“ und die Kosten je Runde in Dollar nennen; ehrlich: „Maß ist der Termin nicht; Maß ist, dass die Befundzahl sinkt“ oder offen lassen. Kein Widerspruch zu Archiv oder `CLAUDE.md` („kein Termin“). Keine Ladetext-Wirkung.

**10. V4: die Sicherung „roter Commit vor Bau-Commit“ trägt kein Text** (`vorschlaege-10-00.md`:10; `kern-arbeitsplaner.md`:14; `profil-pruefer.md`:6).
- Beleg: Entkräftung „der rote Commit vor dem Bau-Commit zeigt dem Prüfer die Reihenfolge in Git“. Feld 7 verlangt nur „mit Commit“, Profil Prüfer prüft keine Reihenfolge. Gespielt wurde V4 erste Fassung (`ergebnis.md`:3), die neue nicht.
- Vorschlag: Feld 7 „mit Commit (bei unbekannter Ursache: roter und behobener)“ (etwa +45 Byte, 2.787 → etwa 2.832) oder die Entkräftung auf das stützen, was der Text trägt.

**11. Kopfzeile Profil Prüfer F9 ohne Byte** (`profil-pruefer.md`:1).
- Beleg: F8 endet „2.730 → 2.849“; F9 nennt keine Größe, 2.817 steht nur in `herausgezogen.md` und Tabelle 0.1 (Chef 20.11., 16:49 „Größe nennen“).
- Vorschlag: „Ladetext 2.849 → 2.817 Byte“ an F9 anhängen (Kopfzeile, keine Ladetext-Wirkung).

**12. Kleinigkeiten.**
- `docs/vorgang/1760.md`: „`rueckmeldung.py`:213–216 druckt für andere Rollen nichts“ ist seit `6e8b0aaff` überholt (`ue.wecker(...)  # 1760`). Spike vermerkt den Stand selbst; `ergebnis.md` D5 „wer weckt mich um 22:44“ an 1760 prüfen.
- `disponent.md`:1 „Falldatum … von Sokrates auf 21.11. gesetzt“, `ergebnis.md`:12 „Antwort berichtigt“: die Antwort ist nicht mehr im Wortlaut der Sitzung; das Ursprungsdatum fehlt. Vorschlag: Eingriff als Anmerkung neben dem Wortlaut, nicht im Wortlaut.

## Was ich nicht prüfen konnte

- Wortlaut Chef 21.11., 21:37 und 22:17 außerhalb des Vorrats Sokrates.
- Ob P1, P6, P4, P7 mit F8 und F9 so ausgehen wie in Befund 1 und 3 vorhergesagt (nicht gespielt).
- Ob `ue.wecker` (neu in `rueckmeldung.py`) die Lücke D5 schließt; nicht nachgestellt.
- Kosten je Helferrunde (für Befund 9): keine Zahl gefunden.
