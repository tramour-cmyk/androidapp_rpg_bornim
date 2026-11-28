# Nachprüfung 3a zu 1727 (frischer Prüfer, 22.11., 07:20)

Geprüft an `4adc85374` (`main`). Grundlage `falltest-lauf2/nachpruefung-2.md` (13 Befunde), Diff `3b78ca005..HEAD` der Entwürfe, `ARBEIT-TEAM-SPIKE.md`, `LISTE-VORGAENGE.md`; dazu Vorgangsarchiv :5–30, :80, :96, :1411, :1462; Grobablauf 14.2–14.5; `tools/rueckmeldung.py`, `uebergabe.py`, `lauf.py` (Hilfe, `--ohne`, `--nur-muss`), `vorgang.py` (Wächter), `chefwort.py`, `nachtstarts.py`; `ARBEIT-BERATUNG.md` :5–12; Ladetexte `scratchpad/lt3/` (mit `bau_lt3.py` neu gebaut: alle sieben Dateien byte-gleich mit den Entwürfen).

## Byte- und Ladesummen (Prüfpunkte 4, 5)

Alle Zahlen stimmen nach Messregel: Disponent 3.642 → 3.761, Prüfer 2.481 → 2.730, Tester 2.606 → 2.626, Wache 949; Ladesummen Disponent 5.550, Prüfer 5.406 (6.282, 7.450), Tester 5.302 (6.178), Wache 2.058, Arbeitsplaner 4.438 (mit V3 und V4 4.542), Leitung 3.946 (mit V1 4.071). V1 +125 (2.837 → 2.962, Altwortlaut genau einmal im letzten Block von 2.1), V2 +20, V3 +49, V4 +55. Ausnahme siehe Befund 11 (Tabelle 0.1).

## Stand der 13 Befunde (Prüfpunkt 1)

| Nr. | erledigt? | was fehlt |
|---|---|---|
| 1 | ja | – |
| 2 | teilweise | Tabelle Lauf 2 unverändert (Befund 1) |
| 3 | teilweise | Tabelle unverändert; P8 und L10 „ins Gespräch“ ohne Träger (Befund 9); neue Lücke durch F7 (Befund 2) |
| 4 | teilweise | Kopfzeit `fachkraft.md` (23:40–23:55) und W8-Ursache „weil Feld 7 …“ nicht berichtigt |
| 5 | teilweise | Text ja; Titel 1794 nennt weiter „F8“, Empfänger fehlt in „Zu 1799“ (Befund 6) |
| 6 | ja, mit neuem Widerspruch | Befund 4 |
| 7 | ja | – |
| 8 | teilweise | Empfängerliste „Zu 1799“ unvollständig (Befund 6) |
| 9 | ja | Obergrenze „Beleg fehlt“ steht im Vorrat Sokrates für 10:00 |
| 10 | teilweise | D5 „Maß Betrieb steht“ ohne Wort; A4 ohne Grund „ohne Textwechsel“ |
| 11 | teilweise | Deckel-Votum entkräftet mit einer Ausnahme, die V1 nicht nennt (Befund 7) |
| 12 | teilweise | R2 weiter ohne Träger; „1801 mit 1792“ zu spät (Befund 10); Ruhendes nur halb (20:06 ist kein Stand „ruht“) |
| 13 | ja | – |

## Befunde

**1. Tabelle Lauf 2 widerspricht der Berichtigung** (`falltest-ergebnis-22-11.md`:111–130).
- Beleg: Zeilen „D1–D5 bestanden“, „D8, D9 bestanden“, „A1–A4 bestanden“, „P7 teilweise“, „P1, P2, P5, P6 bestanden … ‚steckt fest‘ nach Chef-Nein“, L10 Maßnahme „oder in die Chefsache geht“ stehen unverändert. Die Berichtigung :136 zählt neu, ändert aber keine Zeile. P6 „bestanden“ mit „steckt fest nach Chef-Nein“ ist nach Soll P6 neu (07:09) jetzt ein NICHT.
- Vorschlag: Spalte Urteil je Zeile nach Nachprüfung 2 setzen (D3, D4, D5, D1, A1, A3 teilweise; D9, P7 nicht; D2 Soll überholt; P1, P2 „steckt fest“ jetzt gegen K2.5); „teilweise 10 (… u. a.)“ mit allen zehn Namen. Keine Byte-Wirkung auf Ladetexte.

**2. Profil Prüfer F7 „zu diesem Auftrag“ gegen Werkzeug und Obergrenze A** (`profil-pruefer.md`:13; `rueckmeldung.py`:32–33, :62–67, :135–146).
- (a) `zaehlen()` zählt jedes „nein“ unter „Rückmeldungen“ **je Vorgang**. Das zweite davon gibt `rueckmeldung.py`:145–146 als „steckt fest (Laufbremse)“ an Sokrates, nicht an die Fachkraft. Hatte der Vorgang aus einem früheren Auftrag schon ein Prüfer-Nein, meldet der Prüfer nach F7 ein schlichtes „nein“, das Werkzeug aber „steckt fest“, und die Fachkraft bekommt keine Zeile. Das Ziel von F7 (K2.5) verfehlt das Werkzeug dann trotzdem. Zugleich fehlt der Satz „welche Handwerksregel fehlte“, und `z["steckt fest"]` steigt nicht, also verschiebt sich Obergrenze B.
- (b) Neins des Chefs stehen unter „Chefworte“ (`chefwort.py`), und kein Werkzeug zählt sie (`zaehlen` liest nur „Rückmeldungen“). Ein Chef-Nein „nach dem Datum des Auftrags“ kommt kaum vor, denn das Nein des Chefs erzeugt einen neuen Auftrag. Nach F7 zählt ein Nein des Chefs damit praktisch nie. Der Wiederholer „Prüfer ja, Chef nein, neuer Auftrag“ läuft ohne „steckt fest“ und ohne Obergrenze A („dritter abgelehnter Auftrag“, Archiv 14:37 A). Das ist genau der Fall, den Chef 22:13–22:15 prüfen ließ („wo gestoppt vor dem Chef?“), und gegen „Rückläufer … dürfen nicht durchrutschen“ (22:17, `ARBEIT-BERATUNG.md`:8). Vor F7 fing der Prüfer das über „Bisher“ ab.
- (c) „nach seinem Datum“: Der Auftrag hat kein Datumsfeld (Kern Arbeitsplaner, Felder 1–7). Das Datum steht nur in der Zeit der Rückmeldung „Auftrag steht“.
- Gegen Kern Arbeitsplaner („Jedes frühere Nein … steht wörtlich unter ‚Bisher‘“) und Prüfer Schritt 3 („prüfst du erneut“) kein Widerspruch: geprüft wird weiter, nur gezählt wird anders.
- Muss der Chef entscheiden? Der Wortlaut von A–D legt den Auslöser nicht fest, Profil Prüfer ist Entwurf. Ein Vorentscheid Sokrates wäre also möglich. Aber Archiv 14:37 A sagt „je Vorgang“, 19.11., 13:02 sagt „nach zweitem Nein Sokrates“, und `prozesspruefung-21-11.md` Nr. 1 (Grundlage von 14:37) nennt ausdrücklich das „Bisher“-Nein als Auslöser. F7 ändert also die Lesart einer Chef-Entscheidung. Darum **10:00 als eigene Zeile vorlegen (V5)**, nicht nur im Profil.
- Vorschlag: Text „(nach der Zeit von ‚Auftrag steht‘; …)“ statt „(nach seinem Datum; …)“ (+20 Byte). Vorgang an Spike als Rückläufer zu 1763: Ein Nein des Chefs unter „Chefworte“ zählt als abgelehnter Auftrag für A, und die Laufbremse zählt je Auftrag oder schreibt wie der Prüfer. Sonst den Prüfer-Text an die Werkzeugzählung je Vorgang angleichen.

**3. Profil Disponent :14 „ordnet das Werkzeug anders, gilt diese Folge“** (`profil-disponent.md`:14, :12).
- Beleg: `uebergabe.py`:292–294 ordnet Fund vor Eilt und erkennt einen Fund nur am Wort „fund des chefs“. `chefwort.py` schreibt aber „Chefwort … lesen“ (1796), und Themenblock kennt kein Werkzeug. Der Disponent muss also je Zeile die Vorgangsdatei lesen und Eilt, Fund und Themenblock selbst bestimmen. Das ist ein Urteil, das :12 ihm nicht gibt (wie Nachprüfung 2 Nr. 7), und es steht gegen „jede Zeile seiner Ausgabe und nicht mehr“ im selben Absatz. „Werkzeugfehler als Eingang“ legt bei jedem Wecker denselben Eingang nahe, den 1796 schon trägt.
- Vorschlag: „…; ordnet das Werkzeug anders, gilt diese Folge (Werkzeug 1796)“ statt „(Werkzeugfehler als Eingang)“ (−8 Byte). In „Offen“ vermerken, dass bis 1796 der Disponent die Vorgangsdatei liest.

**4. Profil Disponent :24 „nur Wache, Sokrates und Rückläufer des Chefs“ gegen Archiv :96** (Prüfpunkt 3).
- Beleg: Der einzige Vorgang im Archiv (:96, 18.11., 23:15) lautet „keine neuen Starts außer Ford-Wache; laufende Sitzungen übergeben und enden“. Sokrates deckt dasselbe Chefwort („Notfalls startest dir einen Sokrates“) und 1727c. „Rückläufer des Chefs“ deckt keines; die Ausnahme stammt aus der Stufe 95 % (287), nicht aus „weniger Laufen“.
- Neuer Widerspruch im Satz: Laufende Fachkräfte übergeben, auch die an einem Rückläufer des Chefs, während ein neuer Rückläufer des Chefs starten darf. „Laufende Fachkräfte“ statt „Sitzungen“ lässt Prüfer, Tester, Arbeitsplaner und Routinen laufen; :96 beendete alle.
- Enthält das Chefwort selbst den Umfang (1784 A: „höchstens acht weitere Spike-Starts …“), setzt nach :24 trotzdem Sokrates „Umfang und Ende“.
- Vorschlag: „…, Zeile an Sokrates (nennt das Wort keinen Umfang, setzt er Umfang und Ende); bis dahin startest du nur Wache, Sokrates und Rückläufer des Chefs; übrige Sitzungen übergeben.“ (+38 Byte). Die Ausnahme „Rückläufer des Chefs“ zur Vorlage 10:00 als Abweichung von :96 nennen.

**5. Vorgang 1804: zwei Themen, Quelle fehlt, Nähe zu 1792/1806** (`LISTE-VORGAENGE.md`:323; Prüfpunkt 6).
- Keine Doppelung mit 1766/1774 (Laufbremse, Höchstdauer), 1739 (Bauliste ohne Guthabenstufe, `werkzeuge.md`) oder 1520 (Neustart-Haken, 40 $, ruht).
- Teil „Laufsperre aus Chefwort“: Die Ausnahme mit Deckel aus einem Chefentscheid liest schon `nachtstarts.py` (`ausnahmen`, 1792 gebaut; Rückläufer 1806 offen). Eine Laufsperre in derselben Form („höchstens n …-Starts …, spätestens HH:MM“) wäre derselbe Leser.
- Teil Guthabenstufe: Den Prozentwert kennt nur der Chef (`profil-kosten.md`:7; 1727e: „Chef nennt die Nutzung nur Sokrates, Sokrates trägt sie ein“). 1804 nennt nicht, wo `lauf.py` ihn liest. `lauf.py --nur-muss` gibt es schon für die Stufe 80 %. „Rückläufer des Chefs“ setzt die Fund-Erkennung voraus (1796).
- Vorschlag: Titel teilen oder ergänzen: „Stufe aus dem Eintrag Sokrates (1727e, Ort nennen), aufbauend auf `--nur-muss`; Laufsperre im Format von 1792 mit 1806; wartet auf 1796“.

**6. „Zu 1799“: Empfängerliste unvollständig** (`ARBEIT-TEAM-SPIKE.md`:7; Grobablauf 14.2; `profil-disponent.md`:20, :26).
- Es fehlen: 14.2.4 Auftrag (Leichenprüfung, Disponent), 14.2.8 im Build (zurück ans Büro, beim zweiten Mal Sokrates), 14.2.11 ruht (am Datum zurück auf „Auftrag“), 14.2.13, 14.2.14 und vor allem „Werkzeug ‚fertig‘ nicht auf `main`“ → Zeile an die Fachkraft. Der Titel von 1799 nennt diesen Fall, das Profil :20 verlangt ihn. Mit „tu, was die Zeile nennt“ (:26) muss die Zeile ihn tragen.
- 14.2.7 „abgenommen“ geht laut 14.2 an das „Büro (nächster Build)“, nicht ausdrücklich an den Arbeitsplaner.
- Vorschlag: „Zu 1799“ um diese Fälle ergänzen. Den Titel von 1794 auf „Wortlaut F14“ ändern, :58 „seit Fassung 8“ → „Fassung 14“ (keine Ladetext-Wirkung).

**7. Deckel zu V1: die Entkräftung ist selbst ein Deckel** (`vorschlaege-10-00.md`:12).
- Beleg: „zum Termin lege ich mit den Restbefunden als ‚ungeprüft‘ vor“. V1 sagt „prüft vor der Vorlage … bis nichts Neues kommt“, ohne Ausnahme. Die Lehre Fehler 341 (`ARBEIT-BERATUNG.md`:12: „eingearbeitet, ungeprüft vorgelegt … erst dann vorlegen, auch bei ‚nur Kleinigkeiten‘“) und `CLAUDE.md` („Qualität vor Eile, kein Termin“) stehen dagegen.
- V1 hat als einziger Vorschlag kein stärkstes Gegenargument (Haltung 1). Naheliegend: Jede Runde kostet eine Helfersitzung, und ohne Grenze wächst das ohne Maß.
- Chef 21:37 steht nur im Vorrat Sokrates, nicht im Archiv (kein Entscheid, nur Wortlaut).
- Vorschlag: Entweder die Termin-Ausnahme in V1 schreiben, damit der Chef sie entscheidet („…; zu einem Termin mit den Restbefunden als ‚ungeprüft‘“, etwa +60 Byte → 3.022, über 3 KB). Oder die Entkräftung streichen: „Termin verschiebt sich“. Dazu das Gegenargument Kosten je Runde in die Zeile V1.

**8. V4 gegen Laufbremse und Feld 5** (`vorschlaege-10-00.md`:10; Prüfpunkt 4).
- Kein Widerspruch zum Wortlaut der Bekannten Fehler: Die Reihenfolge „erst nachstellen“ bleibt. Chef 18.11., 21:37 (Archiv :112) hat Nachstellen und neues Bild selbst in einem Auftrag verlangt.
- Aber: Archiv 19.11., 13:02 sagt „je Runde ein Bild- oder Filmlauf, den nächsten gibt der Prüfer frei“, und Feld 5 sagt „genau ein Beleglauf“. Ist „rot zeigen“ ein Bildlauf, sind es zwei Läufe ohne Freigabe dazwischen. Außerdem prüft dann nur noch die Fachkraft selbst, ob die Ursache belegt ist, bevor sie baut.
- Vorschlag: „…rot zeigen (Test, kein Beleglauf) und die Ursache mit Commit belegen, dann beheben, in einem Auftrag …“ (+28 Byte, 2.753 → 2.781). Die Rückmeldung nennt dann den roten Commit vor dem Bau-Commit, und der Prüfer sieht die Reihenfolge in Git.

**9. „Ins Gespräch“ ohne Träger** (`falltest-ergebnis-22-11.md`:138; `profil-pruefer.md`:1).
- Beleg: P8 (fehlenden Beleg durch eigene Prüfung ersetzen? doppelt mit Vollzugsprüfung?) und L10 („Kosten bisher“ ohne Träger) heißen „ins Gespräch“. Sie stehen aber weder in `vorschlaege-10-00.md` noch in der 10:00-Liste im Vorrat Sokrates (:8, dort nur „drittes ‚Beleg fehlt‘“). Ebenso R2 „Zahl in die Wochenzählung: offen bis Umstellung“, schon zum dritten Mal ohne Träger.
- Vorschlag: In `vorschlaege-10-00.md` einen Absatz „Fragen ohne Textwechsel“ mit P8, L10, drittes „Beleg fehlt“ und R2 anlegen (keine Ladetext-Wirkung).

**10. „Zu 1801 … mit 1792 zusammen bauen“ kommt zu spät, „Zu 1760“ zitiert ungenau** (`ARBEIT-TEAM-SPIKE.md`:6, :8).
- 1792 ist gebaut (`a112dcf55`) und wartet auf 1806 (Diogenes D333.1, derselbe `nachtstarts.py`). Gemeint ist „mit 1806“.
- `rueckmeldung.py`:213–216 druckt „KEINE SITZUNG“ nur für Sokrates. Für jede andere Rolle ohne Sitzung druckt es gar nichts. Nur `uebergabe.py`:184 druckt es allgemein.
- Je Thema ein Vorgang: 1760 als Rückläufer ohne neue Nummer stimmt (Profil Disponent :18; Thema „Nachricht nur Wecker“). Keine Doppelung mit 1795.
- Vorschlag: „mit 1806“; „`rueckmeldung.py`:213–216 druckt für andere Rollen nichts, für Sokrates nur ‚KEINE SITZUNG‘“.

**11. Tabelle 0.1 in `1727-gesamtbild.md` halb nachgezogen** (:23–35).
- Beleg: Kopf „Stand 20.11., 21:36“, drei Zeilen neu (Prüfer 2.730, Tester 2.626, Disponent 3.761). Dieselben Zeilen in der Tabelle sind veraltet: Kern Büro 2.352 (gemessen 680), Kern Arbeitsplaner 2.375 (2.649), Kern Abnahme 1.336 (1.567, so in den Ladesummen von `herausgezogen.md`), Sockel 1.110 (1.109). Wer die Ladesumme aus der Tabelle bildet, rechnet für den Prüfer 5.176 statt 5.406.
- Vorschlag: Kern Büro, Kern Arbeitsplaner, Kern Abnahme und Sockel nachziehen, Kopf „Stand 22.11., 07:05“ (keine Ladetext-Wirkung).

**12. Vorrat Spike über der Grenze** (`ARBEIT-TEAM-SPIKE.md`).
- Beleg: 30.401 Byte nach den drei neuen „Zu“-Zeilen (etwa 1,1 KB). Der eigene Kopf sagt „höchstens etwa 15 KB“, `CLAUDE.md` „höchstens etwa 30 KB“.
- Vorschlag: Hinweis an Spike, beim nächsten Übergeben Erledigtes zu kürzen (`CLAUDE.md`: nie als eigener Commit). Kein Textwechsel durch Sokrates.

## Was ich nicht prüfen konnte

- Ob Lauf 3 schon Antworten mit diesen Ladetexten hat (`falltest-lauf3/disponent.md`, `leitung.md`, `pruefer-1.md` liegen vor, nicht bewertet).
- Den Wortlaut von Chef 21.11., 21:37 (nur Vorrat Sokrates) und 22:13–22:17 außerhalb des Vorrats.
- Ob `vorgang.waechter` auf ein Nein des Chefs (Fund, `vorgang.py`:721) eine Eskalation ersetzt. Nachgesehen: Er legt nur „Systemlösung?“ an, er zählt nicht.
- Warum Kern Arbeitsplaner 2.649 Byte hat, das Archiv zu 1727f aber „etwa 2.558“ nennt (Fassung 4, 23:12, nach dem Entscheid; nicht im Diff dieser Runde).
- Ob `tools/1727-SCHARF` die Empfänger in `rueckmeldung.py`:213 (`alt`) ändert; Verhalten nicht nachgestellt.
