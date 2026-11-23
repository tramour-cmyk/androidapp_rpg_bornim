# 1727, Übergabekette 3.3 (herausgezogen 21.11., aus 1727-gesamtbild.md 3.3, Zeilen 369–377 an Commit 4d67d1213; Fassung 3 21.11., 22:18: 1727d L-S2 mit L-U8 in Nr. 3, L-U15 in Nr. 7, Byte 2.134 → 2.290 · Fassung 4 21.11., 22:25 (Gegenprüfung 22:22 B3, B8): Nr. 7 Freigabewörter wie Profil Technik 13, einheitlich mit abgenommenem Profil Technik F12 (Chef 21.11., 15:15); Überschrift um 1727d ergänzt; Byte 2.290 → 2.399 · Fassung 5 21.11., 22:39 (Nachprüfung 22:29 U1–U3): Nr. 7 „oder Ergebnis nach Checkliste 11, 12“, Überschrift „(Fassung 3, 4/5)“, Abschnitt Nachprüfung; Text (Überschrift bis Nr. 8) 2.399 → 2.442, ganze Datei 2.399 → 3.193 · Fassung 6 21.11., 22:51 (Nachprüfung 22:47): U2 „vermerkt (nur im Abschnitt Nachprüfung; Werkzeug 1782)“; Text unverändert 2.442, ganze Datei 3.193 → 3.502 · Messregel: ohne Kopfzeile, ohne Leerzeile, ohne letztes Zeilenende, UTF-8) · Fassung 7 (21.11., 23:12): Ladetext bereinigt (Nachprüfungen 23:00/23:03), nur zwei Vermerke unter Nr. 4 und Nr. 5; Ladetext (Überschrift bis Nr. 8) Byte 2.442 → 2.622 (Messregel: ohne Kopfzeile und Leerzeile danach, ohne letztes Zeilenende)

**Fassung 2 (21.11., 09:47), ersetzt 1–7; mit 1727d Nr. 3, 7 (Fassung 3, 4/5):**
1. **Büro:** Kern Büro (Gemeinsames), Profil Disponent, Profil Arbeitsplaner; Größen vorher und nachher mit dem Text.
2. **Übergabe:** Zeile in der Vorgangsdatei, nur über `vorgang.py` (Verfahren des Zählers gegen zwei Schreiber); drei Zustände: offen · angenommen (Sitzung, Frist) · erledigt. Die Nachricht ist nur Wecker („sieh in <Nr>“); doppeltes Wecken schadet nicht. Kennung des Empfängers holt `vorgang.py` beim Senden frisch.
3. **Frist:** läuft sie ab und ist der Empfänger `idle`, wird die Zeile wieder offen und einmal neu gestartet, beim zweiten Mal „steckt fest“, ebenso nach „abgebrochen“; solange er `working` ist, wird gewartet. Wer seine Übergabe mit „Nachfolger:“ geschrieben hat, quittiert nichts mehr; die neue Sitzung liest alle offenen Zeilen. Verlorene Wecker fängt die Stundenrunde.
4. **Wer läuft:** der Disponent dauerhaft (wie heute Ford); eine Fachkraft nur für die Nachbesserung ihres eigenen Auftrags (Regel `WEITER`, Grenze für Fachkräfte niedriger, etwa 100 Tsd., misst 1760); Arbeitsplaner, Prüfer, Tester frisch je Auftrag.
   - *Vermerk:* Nr. 4 Ausnahme Wache (Archiv 21.11., 20:50).
5. **Weitergabe:** `vorgang.py` gibt nach dem ersten Wort die nächste Zeile aus; der Absender schickt den Wecker; Starts bleiben beim Disponenten (Startsperre). Der Disponent urteilt nur über Eingang, „Frage“, „steckt fest“, Guthaben; Büro-Liste abgeleitet aus offenen Zeilen (Fund des Chefs, „Eilt“, Eingangszeit).
   - *Vermerk:* Nr. 5 Folge ersetzt durch Archiv 21.11., 20:51 (Eilt, Fund, Themenblock, Eingangszeit); Werkzeug 1796.
6. **Rückläufer:** Nein des Prüfers an dieselbe Fachkraft (läuft noch); Fund des Chefs nach „ja“ sofort an eine neue Sitzung aus der Vorgangsdatei, vor allem außer „Eilt“.
7. **Chefwort in einer anderen Sitzung:** wörtlich mit Zeit über `vorgang.py` in die Vorgangsdatei, offene Zeile an den Arbeitsplaner, bei Freigabe des Builds („gut“, „passt“, „freigegeben“) oder Ergebnis nach Checkliste 11, 12 (wie Profil Technik 13) an den Disponenten, der den Build-Macher startet; keine Fachkraft baut es am Prüfer vorbei.
8. **Folgen:** Kern Büro „Jede Rückmeldung weckt dich“ und „die Sitzung, die dich gestartet hat“ (Kern Arbeitsplaner, Kern Abnahme) ändern; Falltest zählt Übergaben wie Prüfung 20.11. (mit Build, Merge, Testbitte, „gut“); 1760 testet Neustart während offener Übergabe, doppelten Wecker, Quittung und danach Tod, zwei Schreiber, Wecker während eines Zugs von 40 Minuten.

## Nachprüfung 22:29/22:30, mein Wort

Mein Wort (Sokrates): alle **stimmt**. U1 Nr. 7: **stimmt, eingearbeitet**, „bei Freigabe des Builds („gut“, „passt“, „freigegeben“) oder Ergebnis nach Checkliste 11, 12 (wie Profil Technik 13) an den Disponenten“; gedeckt durch abgenommenes Profil Technik F12 (Chef 21.11., 15:15) und 1727d „einheitlich“ · U2: **stimmt**, vermerkt (nur im Abschnitt Nachprüfung; Werkzeug 1782): Werkzeug zu Nr. 3 und Nr. 7 (Freigabewörter und Ergebnis nach Checkliste 11, 12 an den Disponenten) bei Spike nachgetragen · U3 Überschrift: **stimmt, eingearbeitet**, „(Fassung 3, 4/5)“ · Hinweis `kern-buero.md`:11 (nur „gut“, Beleg): **stimmt, eingearbeitet**, in `herausgezogen.md` unter „3.3 Nr. 8 offen“.

## Nachprüfung 22:47, mein Wort

Mein Wort (Sokrates): alle **stimmt**. U2 hieß „eingearbeitet“, steht aber nur im Abschnitt Nachprüfung: **stimmt, eingearbeitet**, „vermerkt (nur im Abschnitt Nachprüfung; Werkzeug 1782)“; Text (Überschrift bis Nr. 8) unverändert 2.442 Byte.

## Runde 23:05, mein Wort

Beide Vermerke **zur Vorlage 10:00**: sie stehen im entschiedenen Text 3.3 Fassung 2 (Archiv 21.11., 10:11 „3.3 so“); der Wortlaut von Nr. 4 und Nr. 5 bleibt, die Vermerke zeigen nur, was spätere Entscheide ersetzen.
- Unter Nr. 4: „Nr. 4 Ausnahme Wache (Archiv 21.11., 20:50).“ (Archiv: Wache bleibt dauerhafte Sitzung mit Uhr, startet künftig den Disponenten, „Ausnahme zu 3.3 F2 Nr. 4“).
- Unter Nr. 5: „Nr. 5 Folge ersetzt durch Archiv 21.11., 20:51 (Eilt, Fund, Themenblock, Eingangszeit); Werkzeug 1796.“ (1796 an Spike, Muss, startbar, `vorgang.py 1796` geprüft).
- Ladetext 2.442 → 2.622 Byte.
