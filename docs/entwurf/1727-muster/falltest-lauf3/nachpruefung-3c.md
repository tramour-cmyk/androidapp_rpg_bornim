# Nachprüfung 3c zu 1727 (frischer Prüfer, 22.11., 07:50)

Geprüft an `a62694550` (`main`). Eingearbeitet wurde 3b in `880b3656c`, `d80f52949` und `3abc343a0`. Nach `1abf58cf9` kamen nur 1804 „gebaut“, 1807, 1890, der Nachtrag in `werkzeuge.md` und `vorlage-1727h-umschalten.md` dazu; diese sind nicht Gegenstand dieser Prüfung. Gelesen: `nachpruefung-3b.md`, Diff `89c0620eb..HEAD` der genannten Dateien, `vorschlaege-10-00.md`, `ergebnis.md`, die Abschnitte „## Lücken“ aller sechs Antwortdateien, `profil-pruefer.md`, `kern-arbeitsplaner.md`, `kern-buero.md`, `herausgezogen.md`:55–66, Soll `falltest-faelle-22-11.md` P1, P4, P6, P7, `tools/rueckmeldung.py`:1–20, :101, :143, `docs/vorgang/1760.md`, `werkzeuge.md` Schritte 1–8, die Vorgänge 1760, 1763, 1794, 1796–1799, 1804, 1865, 1871–1879 und 1887–1889 (`vorgang.py`), dazu Archiv :23, :25, :30, :35, :45, :80.

## Byte- und Ladesummen (Prüfpunkt 2)

Alle Zahlen stimmen nach der Messregel. Gemessen:
- Profil Prüfer 2.826.
- Kern Arbeitsplaner 2.649, mit V3 2.698, mit V3 und V4 Feld 3 2.787, dazu V4 Feld 7 2.834, dazu der Deckel-Halbsatz („Zweig und Commit; Deckel und Freigabe mit Quelle.“) 2.866.
- Kern Büro 680, mit V6 759.
- V1 „bei Ladetexten “ ist +15 Byte, also 2.977.
- `herausgezogen.md`:60: 1.109 + 680 + 2.834 = 4.623. Ohne V-Texte sind die Zusätze Profil Werkzeug 5.541 und Fremde Inhalte 5.606 auf 4.438 gerechnet; das steht so da.
- `herausgezogen.md`:64: 5.502, 6.378 und 7.546.

Keine Abweichung.

## Stand der 12 Befunde aus 3b (Prüfpunkt 1)

| Nr. | erledigt? | was fehlt |
|---|---|---|
| 1 | ja | P6 ist „nicht“, P1 „teilweise“; „nicht gespielt“ steht in der Zählung. Das Neuspiel entfällt (Chef 07:25, Wortlaut nur im Vorrat Sokrates). |
| 2 | ja | 1872 angelegt, in V5 genannt. |
| 3 | teilweise | F10 ist eingebaut (2.826), widerspricht aber Soll P7 (neuer Befund 1). |
| 4 | ja | D1 und A1 „teilweise“; W7/W8 ohne Profil Figur sind im Kopf vermerkt; D4 hängt an der Frage. |
| 5 | ja | – |
| 6 | teilweise | Jede Lücke hat ein Wort. Mehrere Träger sind aber falsch oder fehlen (neue Befunde 2–4). |
| 7 | ja | – |
| 8 | teilweise | V6, Gegenargumente und Folgen stehen da. Die Überschrift „Fragen, die Text oder Werkzeug ändern“ passt auf drei Punkte nicht, die selbst „kein Textwechsel“ sagen (Beleg ersetzen, Handypunkte, Bauskript). Zwei neue „Frage“-Worte in `ergebnis.md` fehlen in der Liste (neuer Befund 4). |
| 9 | teilweise | „sank bisher nicht (2: 13, 3a: 12, 3b: 12)“ stimmt nicht ganz: Nachprüfung 1 hatte 18 Befunde (`falltest-lauf2/nachpruefung-1.md`), die Zahl sank also 18 → 13 → 12 → 12 (neuer Befund 6). |
| 10 | teilweise | Feld 7 verlangt jetzt beide Commits (2.834). Die Entkräftung „so sieht der Prüfer in Git, dass der rote vor dem behobenen liegt“ trägt aber weiter kein Prüfertext: Profil Prüfer Schritt 1 kennt nur „den gemeldeten Commit“ (Einzahl) und prüft keine Reihenfolge. |
| 11 | ja | Die Kopfzeile von F9 nennt „2.849 → 2.817“. |
| 12 | teilweise | Der Eingriff in `disponent.md` ist in `ergebnis.md` D4 vermerkt; die Kopfzeile von `disponent.md` steht unverändert. Bei 1760 fehlt der Stand (neuer Befund 5). Den Hinweis an Spike in der Nachricht kann ich nicht sehen. |

Rest aus 3a: :122 ist berichtigt, Profil Disponent hat „Offen“ 7, 1804 wartet auf 1796, der Titel von 1794 nennt F14. Alles ja.

## Neue Befunde

**1. F10 stellt „Ende“ für genau den Fall P7 wieder her** (`profil-pruefer.md`:5; Soll `falltest-faelle-22-11.md`:60; `ergebnis.md` P7 und Lücke Prüfer-1 1).
- Beleg: Im Fall P7 ist der gemeldete Commit `be2c0d8` genau der unter „Bisher“ (`pruefer-1.md`:46). F10: „Ist der gemeldete Commit derselbe wie unter ‚Bisher‘: ‚Beleg fehlt‘ und Ende.“ Damit endet die Prüfung vor Angriff 1 und 2, wie in Lauf 3. Soll P7 verlangt aber „‚Beleg fehlt‘ für Angriff 3, ‚nein‘ für 1 und 2“. `ergebnis.md` führt bei P7 als Maßnahme weiter F8 („Ende nur bei anderem Stand“) und bei Prüfer-1 Lücke 1 „stimmt, F8“. Beides ist seit F10 überholt. Bei P4 genügt schon der zweite Satz („anderer Stand: ‚Beleg fehlt‘ und Ende“).
- Vorschlag: „Ist der gemeldete Commit derselbe wie unter ‚Bisher‘, ist das ein Belegmangel, weiter.“ Damit ist P4 weiter „Beleg fehlt“ (über Satz 2), und P7 wird „nein“ mit dem Belegmangel als Satz. Ein bloßer Meldefehler ohne sichtbaren Mangel bleibt „Beleg fehlt“, damit ist auch 3b Nr. 3 gewahrt. Profil Prüfer 2.826 → 2.831 (+5), Ladesumme Prüfer 5.502 → 5.507. Dazu in `ergebnis.md` P7 und Prüfer-1 1 auf F11 verweisen.

**2. Vergebene Nummern 1880–1886 ohne Zeile; Prüfer-1 Lücke 8 hat damit keinen Träger** (`880b3656c`, Merge `f0e0adafa`, `d80f52949`; `ergebnis.md` „Werkzeuglücken“ und Prüfer-1 8).
- Beleg: `880b3656c` legte 1880–1886 an („1880–1886 an Spike“, Zählercommits `5feb8fb0c`…`ab83821e5`). Der Merge `f0e0adafa` entfernte alle sieben Zeilen. Danach wurden 1884–1886 als 1887–1889 neu angelegt; 1880–1883 waren doppelt zu Spikes 1875–1879. `vorgang.py 1880` bis `1886` liefert „nichts gefunden“, im Archiv und in `ARBEIT-BETRIEB.md` steht kein Vermerk. Die Regel sagt „die Nummer bleibt fest“, und die Commit-Nachricht nennt Nummern, die es nicht gibt. Dabei ging Inhalt verloren: 1883 trug „Prüfer-1 L8“ (Zahl der Prüffragen). 1879 trägt nur Arbeitsplaner L7. Trotzdem steht in `ergebnis.md` „1879 (… dazu Prüfer-1 L8: Zahl der Prüffragen)“ und bei Prüfer-1 8 „Frage, 1879“.
- Vorschlag: 1880–1886 als Zeilen „verworfen, doppelt zu 1875–1879 bzw. neu als 1887–1889“ nachtragen (über `vorgang.py`) oder im Archiv vermerken. Prüfer-1 L8 an 1879 anhängen (Titel ergänzen) oder einen eigenen Vorgang anlegen. Keine Ladetext-Wirkung.

**3. Falsche oder doppelte Träger bei den Lücken** (`ergebnis.md` Tabelle D1, „Werkzeuglücken“, „Lücken der Sitzungen“; Liste).
- D1-Zeile: „1873 trägt ‚Hinweis‘-Empfänger“. Die Lücke Disponent L9 trägt aber 1877 (so steht es auch zwei Absätze tiefer); 1873 betrifft „Hinweis: Prüffrage fehlt“ an den Arbeitsplaner. Dazu: 1877 leitet zum Besitzer (Spike), Soll D1 :24 verlangt auch „Sokrates ‚Hinweis‘“. Das trägt kein Vorgang.
- 1873 und 1877 ändern beide den Empfänger von „Hinweis“ in derselben Zeile `rueckmeldung.py`:101; keiner verweist auf den anderen. Ebenso doppelt: **1889** und **1797** („`worte()` erkennt ‚abgebrochen‘ und ‚Auftrag steht‘ nicht“). **1876** (Schalter „nur Rückläufer“ in `lauf.py`) und **1804** (Laufsperre aus Chefwort, „Rückläufer des Chefs frei“, seit HEAD „gebaut“) überschneiden sich teilweise.
- Arbeitsplaner 6 „Build-Auftrag ohne Nummer an 1798“: Der Titel von 1798 nennt keinen Build-Auftrag, `docs/vorgang/1798.md` gibt es nicht. Der passende Vorgang ist 1864 („Build-Auftrag B<n> … Auftrag mit Commit je Vorgang“).
- Disponent L1 „mit 1871“: Weder 1871 noch `werkzeuge.md` Schritt 8 nennt `lauf.py --sperre` in der Wecker-Ausgabe. Kein Träger.
- Arbeitsplaner 13 „1865 (Umzug)“: 1865 steht „wartet, doppelt, geht in 1871 auf“. Der Umzug legt außerdem nur Dateien für Vorgänge mit „Zu“-Absätzen an. Was gilt, wenn keine Vorgangsdatei da ist (die Lücke), sagt kein Text.
- Vorschlag: Die D1-Zeile auf 1877 ändern; 1873 und 1877 gegenseitig verweisen oder zusammenlegen; 1889 mit 1797 zusammenlegen (eine als „doppelt“); 1876 auf den Empfänger Sokrates kürzen, den Schalter bei 1804 lassen; Arbeitsplaner 6 → 1864; Disponent L1 an 1875 oder einen eigenen Vorgang; Arbeitsplaner 13 → 1871, dazu „ohne Datei: Frage“ als Lesart. Keine Ladetext-Wirkung.

**4. „Frage“ und „mit der Umstellung“ ohne Ort** (`ergebnis.md` Prüfer-1 8, Prüfer-2 5, Leitung 2, 5, Arbeitsplaner 3; `vorschlaege-10-00.md`).
- Beleg: Prüfer-2 5 („fehlende Testausgabe = ‚Beleg fehlt‘; nach dem Gespräch in Profil Prüfer Schritt 2“) und Prüfer-1 8 („Frage … bis dahin am Ziel prüfen“) stehen nicht in den Gesprächsfragen von `vorschlaege-10-00.md`. Die Frage „Formmangel“ nennt nur „Zahl, Quelle“ aus Feld 7, keine Testausgabe. Das ist dieselbe Art Lücke wie 3b Nr. 8. „Mit der Umstellung“ (Grund „Obergrenze A/B“ in `MUSTER.md`, `docs/leitung/gedaechtnis.md`, `docs/profile/<Name>.md`) hat weder einen Vorgang noch eine Zeile in `werkzeuge.md` (grep: kein Treffer zu `MUSTER`, `gedaechtnis`).
- Vorschlag: Beide Fragen mit Gegenargument in `vorschlaege-10-00.md` aufnehmen. Profil Prüfer Schritt 2 „… oder eine Angabe aus Feld 7 oder die Testausgabe“ lässt sich mit der Formmangel-Frage verbinden (etwa +45 statt +30 Byte). Die drei Umstellungsfolgen als Punkte zu 1871 oder in `werkzeuge.md` Schritt 8. Ladetext nur nach dem Gespräch.

**5. 1760 ist erledigt; das Ergebnis führt es als offene Lücke** (`ergebnis.md` D5, D3, „Werkzeuglücken“, Disponent L8).
- Beleg: 1760 steht „erledigt, greift Lauf 337“ (Diogenes `6b1b08aff`); `rueckmeldung.py`:216 `ue.wecker(...)  # 1760: läuft keine Sitzung, Wecker an den Disponenten`. `docs/vorgang/1760.md` hat nur den Rückläufer 07:22, aber keinen Stand. Ob D5 „wer weckt mich um 22:44“ damit zu ist, sagt kein Text (3b Nr. 12).
- Vorschlag: In `ergebnis.md` „1760 erledigt (greift Lauf 337), D5 gegen `ue.wecker` ungeprüft“; oder Spike vermerkt den Stand in `1760.md`. Keine Ladetext-Wirkung.

**6. Kleinigkeiten.**
- V1: „die Befundzahl … sank bisher nicht (2: 13, 3a: 12, 3b: 12)“. Mit Nachprüfung 1 (18) sank sie; flach war nur 3a → 3b. Vorschlag: „18, 13, 12, 12: sie sinkt, aber langsam“. Das stärkt das Gegenargument nicht und schwächt es nicht, ist aber richtig.
- V4 „Lauf 3 A7 mit Feld 3: wirkt“: gespielt wurde die erste Fassung (2.753, Kopf `ergebnis.md`), nicht der Wortlaut in der Tabelle (2.787). Vorschlag: „(erste Fassung)“ einfügen.
- Kopf `vorschlaege-10-00.md` „Fassung 4 … 07:40 nach Nachprüfung 3b Nr. 7–10“: Die Ergänzungen aus `3abc343a0` (07:43: V1 „bei Ladetexten“, Deckel, Bauskript; aus 3b Nr. 6) fehlen im Kopf.
- Gesprächsfrage „Liegezeit in die Wochenzählung“: ohne Votum und ohne die Nummer 1868, die es dafür gibt (Liste, „Kennzahlen Wochenzählung“). Die Entkräftung „`lauf.py` LIEGT misst schon“ passt nicht zu 1868 (Median aus den Übergabezeilen).
- Zählung (Prüfpunkt 4): nachgezählt stimmt alles (17 Fälle; 6, 9, 1, 1; gegen Lauf 2 von 13 nun 5 bestanden). Dass P6 (bestanden → nicht) und P1 (bestanden → teilweise) gegen Lauf 2 schlechter stehen, nennt der Satz „Gegen Lauf 2“ nicht. Vorschlag: „; schlechter P6, P1 (Soll geändert)“.

## Prüfpunkte ohne Befund

- Prüfpunkt 5 (Widersprüche): Kein Vorschlag widerspricht dem Archiv (:23, :25, :30, :35, :45, :80 geöffnet) oder `CLAUDE.md`. V6 lässt den Wortlaut stehen („Nie ein Urteil des Chefs umformulieren“ bleibt gewahrt). Die Formmangel-Frage und „drittes ‚Beleg fehlt‘ = nein“ greifen ineinander, ohne sich zu widersprechen. Jede Frage hat ein Gegenargument mit Entkräftung, die es trifft. Ausnahmen: die Liegezeit (Befund 6) und V4 (3b Nr. 10, siehe Tabelle).
- Quellen: Diese Stellen stimmen: `rueckmeldung.py`:14, :17, :143; Checkliste 3 „ab 4 Handypunkten“; `ROLLE-TECHNIK.md`:18; Archiv 18.11., 16:24 („Spike ist die Stelle“); Profil Disponent :24; 1797 („abgebrochen“); 1872, 1873, 1875–1879 und 1887–1889 wie zitiert; 406 $ für 1727 zur Zeit des Schreibens (jetzt 434,12 $).

## Was ich nicht prüfen konnte

- Wortlaut Chef 22.11., 07:25, 21.11., 21:37 und 22:17 außerhalb des Vorrats Sokrates.
- Ob P7 und P4 mit F10 bzw. dem Vorschlag in Befund 1 so ausgehen wie vorhergesagt (nicht gespielt).
- Ob `ue.wecker` D5 schließt (nicht nachgestellt).
- Den Hinweis an Spike „nie als eigener Commit“ (Nachricht, nicht im Repo).
- `vorlage-1727h-umschalten.md` (neu nach `1abf58cf9`, nicht beauftragt). Sie übernimmt „Nachprüfungen 2: 13, 3a: 12, 3b: 12“ und „Lücken 1872–1889“ (dazu Befunde 2 und 6).
