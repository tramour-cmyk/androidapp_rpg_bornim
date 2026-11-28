# Nachprüfung 1 zu 1727, Änderungen 8c65fea83..HEAD (frischer Prüfer, 21.11., 23:35)

Stand: `2bbec3741`. Geprüft: Diff der fünf Dateien, Bewertung und Fälle des Falltests, VORGANGSARCHIV (1727 vom 19.–21.11., 1311, 18.11. 23:15), Grobablauf 14.1/14.2, Gesamtbild (Sockel, 2.1, 6.2), `kern-buero.md`, `kern-abnahme.md`, `kern-arbeitsplaner.md`, `profil-werkzeug.md`, `profil-technik.md`, `herausgezogen.md`, `tools/rueckmeldung.py`, `tools/auftrag.py`, `tools/lauf.py`, `tools/chefwort.py`, LISTE-VORGAENGE (aktiv und Archiv).

## Byte-Zahlen (Prüfpunkt 4): alle stimmen

| Text | angegeben | gemessen |
|---|---|---|
| Profil Disponent, Ladetext | 3.040 → 3.500 | 3.040 → 3.500 |
| Profil Prüfer | 2.030 → 2.294 | 2.030 → 2.294 |
| Profil Tester | 2.473 → 2.617 | 2.473 → 2.617 |
| Routine Wache | 1.144 | 1.144 (vorher 949; Kopfzahl „950“ war altes Maß) |
| V1 Kern Leitung | 2.837 → 2.928 | 2.837 → 2.928 (Altwortlaut einmal gefunden) |
| V2 Sockel | 1.109 → 1.145 | 1.109 → 1.145 (Altwortlaut einmal gefunden) |

## Befunde

**1. D3 nicht gelöst: Werkzeug-„fertig“ erreicht den Disponenten gar nicht, und :28 schickt nach „ja“ trotzdem eine Testbitte.** `profil-disponent.md`:20 sagt: „ist es nach ‚fertig‘ nicht auf `main`, Zeile an sie“. Aber `rueckmeldung.py` `weitergabe` gibt „fertig“ mit Commit an den Prüfer (`if COMMIT.search(text): return PRUEFER`). Der Disponent bekommt keine Zeile, also kommt auch die Zeile „binnen 5 Minuten“ aus der Prüffrage D3 nicht. Auf das „ja“ des Prüfers antwortet das Werkzeug weiter mit „an den Chef vorlegen (Testbitte), nicht selbst nach main“ (:100). Dazu passt `profil-disponent.md`:28 („nach ‚ja‘ des Prüfers die Testbitte“), ebenfalls ohne Ausnahme. Damit ist das NICHT aus D3 verfehlt: Werkzeug als Spielcode zum Test geben. 1790 (Spike, startbar) deckt nur das „ja“. Den Weg „Werkzeug fertig“, den die Bewertung D3 verlangt, deckt kein Vorgang. „Liegezeit als Hindernis vermerken“ aus dem Soll fehlt ganz. **Vorschlag:** in :28 „nach ‚ja‘ des Prüfers die Testbitte, außer bei Werkzeug“. Den Satz in :20 kürzer fassen, gleiche Wirkung, -48 Byte: „Ausnahmen: Werkzeug ohne Spielinhalt bekommt keine Testbitte; fehlt es nach ‚fertig‘ auf `main`, Zeile an die Fachkraft: ‚auf `main`, Vollzug mit Commit‘;“. Wer was nach `main` bringt, steht schon in `profil-werkzeug.md`:36 und muss hier nicht doppelt stehen. Werkzeug: `weitergabe` gibt Werkzeug-„fertig“ zusätzlich als Zeile an den Disponenten, wenn der Commit nicht auf `main` ist. Das gehört zu 1790 oder in einen eigenen Vorgang.

**2. D4 nur halb gelöst; „geht vor“ ist zu weit gefasst; Ende und laufende Sitzungen fehlen.** `profil-disponent.md`:24: „Ein Chefwort zum Laufen … geht vor … bis zu seinem nächsten Wort startest du nur, was es erlaubt“.
- „Geht vor“ gilt auch für ein Chefwort, das *mehr* Laufen erlaubt, und hebelt dann die Guthabenstufe aus. Gemeint ist nur ein engeres Wort.
- Was „nicht zu viel laufen“ erlaubt, muss der Disponent selbst deuten, obwohl er laut :12 nur über Eingang, Frage, steckt fest und Guthaben urteilt.
- „Bis zu seinem nächsten Wort“ widerspricht dem Vorbild: Archiv 18.11., 23:15 legte „bis 19.11., 07:00“ fest (Votum Sokrates), weil der Chef morgens „noch Luft“ wollte. Nach dem neuen Text stünde der Betrieb, bis der Chef wieder schreibt.
- Der Kernpunkt „laufende Sitzungen übergeben und enden“ aus Soll D4 und Archiv fehlt.

**Vorschlag** (214 statt 184 Byte, +30): „Ein Chefwort, das weniger Laufen verlangt (etwa ‚nicht zu viel laufen‘), geht vor: wörtlich mit Zeit ins Protokoll, Zeile an Sokrates (er setzt das Ende); bis dahin keine Starts, laufende Sitzungen übergeben.“ Dass die Wache weiterläuft, folgt schon aus `routine-wache.md`:10 (einmal gestartet). Werkzeug fehlt: `lauf.py` kennt keine Laufsperre aus einem Chefwort, nur `--nur-muss` und den Nachtstopp 1643. Nach einem Neustart des Disponenten hängt die Sperre allein an der Protokollzeile.

**3. R2/R3: Fall 7 weicht von der Maßnahme der Bewertung und vom Grobablauf 14.2 ab.** Die Bewertung verlangt: „Vorgang über der Frist seines Stands (14.2) → Wecker an den Disponenten“. `routine-wache.md`:25 setzt stattdessen zwei neue Fristen (6 h, 1 h) für zwei Stände.
- Grobablauf 14.2.7 sagt für „abgenommen“: Frist „bis zum nächsten Build“, Wächter „Tagesmeldung“. 14.1 sagt: „Der Wächter ist Code, nicht eine Sitzung.“
- Einen Stand „vom Chef freigegeben“ gibt es in 14.2 nicht.
- R2 („gebaut“ ohne Build) kann nach neuer Ordnung auch „beim Prüfer“ liegen (14.2.6, 1 Tag). Fall 7 fängt das nicht.

**Vorschlag**, kürzer und vollständig: „7. **Liegt:** ein Vorgang über der Frist seines Stands (Ausgabe `vorgang.py`) → Wecker ‚Liegt‘ an den Disponenten mit Nummer, Stand, Alter.“ Die Fristen gehören dann nach 14.2 bzw. ins Werkzeug 1799.

**4. Wache 7 und 1799 stimmen nicht überein.** In 1799 (`LISTE-VORGAENGE.md`:316) steht dazu „Werkzeug ‚fertig‘ nicht auf main“, in `routine-wache.md`:25 nicht. Gerade dieser Fall wäre die Netzlösung für D3 (Befund 1). **Vorschlag:** angleichen, am besten über die allgemeine Fassung aus Befund 3.

**5. „Liegt“ widerspricht dem Takt des Disponenten; kürzer über `lauf.py`.** `profil-disponent.md`:14: „Bei jedem Wecker … `tools/lauf.py`, dann tust du jede Zeile seiner Ausgabe und nicht mehr“. Ein Wecker „Liegt“ der Wache ist keine Ausgabezeile von `lauf.py`, der Absatz :26 steht also gegen „und nicht mehr“. Zudem soll die Wache laut Ziel :16 nur Hänger finden, und sie ruft den Disponenten, der ohnehin stündlich `lauf.py` laufen lässt. **Vorschlag:** 1799 gibt „LIEGT <Nr> | Stand | Alter | an <Rolle>“ direkt in `lauf.py` aus. Dann entfallen Fall 7 der Wache (+195 Byte) und der Absatz :26 bis auf den Halbsatz „‚wartet auf Chef‘ nur mit offener Testbitte oder Chefsache“. Wenn die Wache bleibt: „je Fall höchstens eine Meldung je Stunde“ weckt bei einem liegenden Vorgang stündlich ohne Ende. Dann „einmal je Vorgang und Stand“, wie die WÄCHTER-Marken in `lauf.py`.

**6. „Zeile an den, der den nächsten Schritt hat“ (`profil-disponent.md`:26) bleibt bei R3 offen.** Nach `profil-technik.md`:23 führt der Build-Macher nur zusammen, „wenn dein Auftrag es nennt“. Dessen Sitzung ist nach dem Build meist weg. Eine Zeile an eine Rolle ohne Sitzung startet sie nur, wenn `lauf.py` das ausgibt; sonst liegt die Zeile. **Vorschlag:** „Zeile an das Profil, das den nächsten Schritt hat (Build-Macher: Auftrag ‚nach `main`‘ über den Arbeitsplaner)“, oder es so in 1799 festlegen. Soll R2 „Zahl in die Wochenzählung“ hat keine Maßnahme (`routine-wochenzaehlung.md` unverändert).

**7. Quellen zu den Fristen der Wache sind schief.** `routine-wache.md`:1 nennt „6 h wie `CLAUDE.md` Haltung 4“. Dort geht es um *Gesehenes, das nicht gemeldet wurde* („was gesehen über 6 h lag; 1462“), nicht um Abgenommenes ohne Build. Passender wäre Grobablauf 14.5 „Startwarnung nach 6 h als Vorgang (1642)“. „1 h nach Chef 15.11., 19:13 zu 1311“: Der Chef sagte „Gleich auf main“, und zwar über *Werkzeug ohne Chef* (Archiv :392). Die 1 h stammt aus der Aufstellung von Fall D3 („Eine Stunde später“), und Fall 7 wendet sie auf *vom Chef freigegebenen* Spielcode an. Als Annahme gekennzeichnet ist das zulässig, die Quelle trägt es aber nicht. **Vorschlag:** „1 h Annahme (Fall D3)“.

**8. P5: Schritt 2 macht jede fehlende Tusche zu „Beleg fehlt“, auch wenn das Spiel selbst sie verloren hat.** `profil-pruefer.md`:7: „ist er nicht in Spielansicht mit Signatur (Spielkamera, Tusche) … ‚Beleg fehlt‘ … Die Arbeit lehnst du damit nicht ab“. Fehlt die Tuschelinie im Build wirklich (Rückschritt), ist das ein Mangel der Arbeit (Schritt 4, Querprofil Signatur). „Beleg fehlt“ zählt dann nicht als Runde (`rueckmeldung.py`:17) und läuft unter Obergrenze A ohne Ende. Bei Belegen ohne Bild (Testausgabe, Textabgleich, Hörprobe) passt die Bedingung gar nicht. Das NICHT aus P5 („wegen Vermerk freigeben“) steht nirgends. **Vorschlag:** „ist Bild oder Film nicht in Spielansicht (Spielkamera, Spiel-Shader, auch bei Vermerk ‚nur X zählt‘)“ → „Beleg fehlt“; fehlende Tusche *in* der Spielansicht → „nein“ über Schritt 4. Nebenbei: „Signatur“ heißt laut Glossar Toon-Licht, Tusche, Schablone, schwarz-gold; die Spielkamera gehört nicht dazu.

**9. P2: „Hinweis: Prüffrage fehlt“ kommt nirgends an und widerspricht der eigenen Meldeform.** `profil-pruefer.md`:8: „als ‚nein‘, dazu ‚Hinweis: Prüffrage fehlt‘“. :13 sagt dagegen „Anderes Gesehenes als eigene Rückmeldung ‚Hinweis: was, wo‘“. `rueckmeldung.py` `worte()` erkennt „Hinweis“ nur als erstes Wort (:56, so auch 1797). Hängt der Hinweis an einem „nein“, geht er nur an die Fachkraft, und der Arbeitsplaner erfährt nie, dass eine Prüffrage fehlt. Neu ist auch „oder das Ziel selbst falsch ist“. Wegfällt der bisherige Fall „Prüffragen fragen am Ziel vorbei“ ohne sichtbaren Mangel: der Prüfer meldet jetzt „ja“, und der schlechte Auftrag bleibt. **Vorschlag:** „…trotzdem als ‚nein‘; die fehlende Prüffrage als eigene Rückmeldung ‚Hinweis‘.“ Die Herkunft von „Ziel selbst falsch“ nennen oder den Halbsatz streichen. Gesamtbild 6.2 :797 und :834 trägt noch die alte Fassung; das ist hinnehmbar, solange das Muster maßgeblich ist, sollte aber vermerkt werden.

**10. P3: Wie die Wörter „stimmt, Einwand, Frage“ zum ersten Wort der Meldung stehen, sagt der Text nicht.** `profil-pruefer.md`:11: „je Punkt ein Wort (stimmt, Einwand, Frage) mit Codestelle“. Erste Wörter sind laut :13 nur „ja, nein, Beleg fehlt, nein, Auftrag“. Kern Abnahme sagt „statt ‚Frage‘ meldest du mit den Wörtern deines Profils“, und „Frage“ als erstes Wort leitet das Werkzeug an Sokrates (`worte()`). Im Soll P3 ist 299.4 ein „Einwand“. Offen bleibt, ob daraus ein „nein“ an die Fachkraft wird oder ein „nein, Auftrag“, weil die Lage im Build-Auftrag steht. Offen bleibt auch, ob „Testbitte gegenlesen“ (Lücke P3) überhaupt ein Handy-Auftrag ist. **Vorschlag:** „…mit Codestelle; ein Einwand = ‚nein‘, nur Fragen = ‚Beleg fehlt‘“, oder eine Rückfrage an Sokrates. Dazu im Falltest Lauf 2 den Fall P3 mit Auftrag spielen.

**11. T2: Der Satz steht unter der falschen Nummer, und das Maß trägt eine geborgte Quelle.** `profil-tester.md`:11 bestimmt unter Nr. 4 „Fehler“, was ein *Rückschritt* ist (Nr. 1). Der Kopf :1 nennt als Maß „Chef 09.11., 21:12 ‚Bilder/s nicht unter heute‘, Vorgänge 804, 805“. In den Vorgangstiteln heißt es „(Chef 09.11., 21:12, über Sokrates)“, das ist kein Wortlaut des Chefs, im Archiv steht es nicht. 805 ist „doppelt: geht in 806 auf“, und alle drei gelten für Gras und Kampforte, nicht allgemein. Die Bewertung wollte das „Maß aus der Abnahmeliste“, aber dort steht keines (`PROJEKTPLAN.md` ohne Bilder/s). Allgemein steht das Maß in den Profilen: „Bilder/s nie schlechter“ in `profil-welt.md`:13 und Gesamtbild :616, :636. **Vorschlag:** Den Rückschritt-Halbsatz nach Nr. 1, in Nr. 4 nur „ohne Vergleichswert: Bildrate oder Ladezeit als Fehler mit Messwert, Grafikstufe und Lage“. Quelle: Profil Welt bzw. Gesamtbild statt „Chef … wörtlich“. Soll T2 ist sonst getroffen („Fehler“ wird nach „Meldung“ gezählt, Nummer durch das Büro).

**12. Die Ladesummen fehlen (Chef 20.11., 16:49: „Summe dessen, was die Sitzung lädt“), und die Begleittexte sind veraltet.** Alle vier Köpfe nennen nur die Größe des Teils.
- Neu wären: Disponent 1.109 + 680 + 3.500 = **5.289** (vorher 4.829); Prüfer 1.109 + 1.567 + 2.294 = **4.970** (4.706); Tester 1.109 + 1.567 + 2.617 = **5.293** (5.149); Wache 1.109 + 1.144 = **2.253**; V2 erhöht *jede* Sitzung um 36 Byte.
- Veraltet: `herausgezogen.md`:58, :64, :65; `profil-disponent.md`:37 („Größe Text: 3.068 … Sockel (1.110 Byte, `1727-sockel.md`) … 4.858“); `routine-wache.md`:29 („950 Byte“); Raster `routine-wache.md`:35 (Spalte 3 ohne Vorgangsliste, Spalte 6 „Disponent (3, 4, 6)“ ohne 7).

**13. Profil Disponent wächst um 15 % (+460 Byte).** Mit den Vorschlägen aus 1, 2 und 5 kommt man auf etwa −48 +30 −160 = **−178 Byte gegenüber jetzt**, also etwa 3.322 statt 3.500, bei gleicher oder besserer Wirkung. Dazu ein Widerspruch im Ablauf: `profil-disponent.md`:33 und Offen 5 (:58) beschreiben weiter den Wortlaut der Fassung 8, den Perikles unter 1794 prüft. Der Satz wurde in F11 erneut geändert, ohne Vermerk bei 1794. **Vorschlag:** :33 und 1794 nachziehen, oder den Satz bis zum Ergebnis von 1794 nicht anfassen.

**14. V1 (Kern Leitung) trifft L1. Die Größenangabe ist schwächer als 16:49, und eine Grenze für die Runden fehlt.** `vorschlaege-10-00.md`:7: „die Größe in Byte“. Das Archiv 20.11., 16:49 verlangt „Größe des Teils vorher/nachher und Summe dessen, was die Sitzung lädt“. „Bis eine Runde nichts Neues findet“ hat keine Obergrenze (Kosten). Die Quelle 21.11., 21:37 steht nur in `ARBEIT-BERATUNG.md`:11, nicht im Archiv. Nach Kern Leitung („steht etwas nur in einem Paket oder Entwurf, sag das“) sollte die Fundstelle mitgenannt werden. **Kürzere Fassung** (+73 statt +91 Byte, zusätzlich mit vorher/nachher): „…ohne deine Begründung, nach jedem Einarbeiten neu, bis nichts Neues kommt; im Chat ‚Gegengeprüft: <Datei>‘, Byte vorher/nachher und je Befund …“.

**15. V2 (Sockel 7) trifft W1 nur zum Teil; es geht kürzer.** „Eigenes committen und pushen, nie fremde Dateien“ (+36 Byte). „Nie fremde Dateien“ lässt sich so lesen, als dürfe niemand mehr gemeinsame Dateien wie `CHANGELOG.md` oder einen Vorrat anfassen. Gemeint sind fremde Änderungen. Gleiche Wirkung, +20 Byte, 1.129: „Vor Sitzungsende nur Eigenes committen und pushen.“ Stärkstes Gegenargument gegen V2 überhaupt: Die Ursache ist im Werkzeug gesperrt (1776 und 1778, „greift Lauf 329“). Kern Leitung sagt selbst: „Wiederholt sich eine Lehre, schlag eine Werkzeugsperre vor“. Was bleibt, ist nur die Mehrdeutigkeit von „alles“. Soll W1 verlangt außerdem anhalten, Index prüfen und einen „Hinweis“ an die Technik; das deckt V2 nicht und braucht es dank Halt auch nicht.

**16. V3 ist kein Vorschlag für das Gespräch.** `vorschlaege-10-00.md`:9 sagt „kein Textwechsel“. Der Werkzeugvorgang 1798 (Spike, startbar) ist schon angelegt, der Chef muss nichts entscheiden. Nach Haltung 5 streichen oder als „zur Kenntnis“ führen. Die Richtung ist richtig (das Werkzeug folgt dem abgenommenen Kern 1727f, bestätigt an `auftrag.py`:19 `FELDER`). Der zweite Teil desselben Befunds „A (alle)“, die *Ablage der Profile in die Bauliste* (Profilpfade für Feld 4), hat keine Maßnahme, siehe 17.

**17. Befunde der Bewertung ohne Maßnahme in diesem Commit:**
- A (alle): Ablage der Profile bzw. Profilpfade für Feld 4: kein Vorgang, keine Zeile in der Bauliste.
- D5: Kern Büro soll ein Maß für „Betrieb steht“ nennen: nichts.
- A4: Kern Büro 👎/👍: nichts.
- P6: Werkzeug „Fachkraft erfährt ‚steckt fest‘“: kein Spike-Vorgang gefunden.
- L4: L-O1 „im Gespräch 10:00“: fehlt in `vorschlaege-10-00.md`.
- W5: `add_repo`, laut Bewertung „Gespräch“, fehlt in den Vorschlägen. Möglicherweise schon gedeckt durch 1781 (KAUFREPO-Satz in jedem Start, Chef 21.11., 21:22/21:38 „Sockel, ja“). Das sollte in der Bewertung vermerkt werden.
- D3: Werkzeugweg „Werkzeug fertig“, siehe Befund 1.

Kern Büro ist abgenommen (Archiv 21.11., 11:46). Gehören D5 und A4 dorthin, müssen sie als V4/V5 in die Vorschläge.

**18. Zitate, Kleinigkeiten.**
- `profil-disponent.md`:1: „Archiv 18.11., 23:15 ‚Nacht sparsam‘“. Der Eintrag heißt „Nacht 18./19.11. sparsam“; Zeit und Inhalt stimmen.
- `routine-wache.md`:1 und `vorschlaege-10-00.md`: 1311 (Archiv :392, „Gleich auf main“, „Da braucht ihr mich doch nicht dafür …“) stimmt wörtlich. Vorfall 21.11., 20:59, `023edc9b7`: stimmt (Commit 20:59:24). 1776 „erledigt, greift Lauf 329“: stimmt, der Halt selbst kam mit 1778.

## Was ich nicht prüfen konnte

- Ob die neuen Sätze im Falltest Lauf 2 tatsächlich bestehen: keine blinden Helfer gestartet. Die Antworten aus Lauf 1 sind nicht im Wortlaut gesichert, die Bewertung stützt sich auf eine Zusammenfassung.
- Den Wortlaut von Chef 21.11., 21:37 außerhalb von `ARBEIT-BERATUNG.md`; Chat oder Telegram liegen mir nicht vor.
- Ob ein Gespräch um 10:00 vereinbart ist.
- Wie 1790, 1798 und 1799 gebaut werden: alle noch „startbar“, Verhalten nicht nachstellbar.
- Ob Gesamtbild 6.2 neben den Musterdateien noch maßgeblich ist: kein Vermerk gefunden.
