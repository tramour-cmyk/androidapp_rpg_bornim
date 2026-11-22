# 1727h · Schalten wir die neue Arbeitsweise ohne bestandenen Falltest scharf, sobald die Werkzeuge dafür fertig und grün sind?
Sokrates · 22.11., 08:40 · B Abläufe · aus deinem Wort 22.11., 07:25 („nicht so viel Energie in irgendwelche Tests“, steht im Vorrat Sokrates) gegen deine Bedingung vom 21.11., 11:17
Kurz: Umschalten nach fertigen Werkzeugen und deinem Wort zu 1727i, 1727j, 1727k; der Falltest endet mit Lauf 3, nicht bestanden; frühestens heute Nachmittag.
Beim Chef, weil: Rollen und Accounts (die Rollen fallen mit dem Umschalten weg)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Die neue Arbeitsweise (Neustrukturierung, Vorgang 1727: Vorgangsdateien statt Vorräte, Disponent statt Ford, Fachprofile statt Rollen) ist bisher nur an einer Kopie gebaut. Am 21.11., 11:17 hast du zur Reihenfolge gesagt „Ja, mach es genauso. Gesamtbetrachtung und Reihenfolge.“; in der Reihenfolge stand: „Umstellung erst, wenn Falltest bestanden und jedes Werkzeug grün.“ (`reihenfolge.md` an Commit `4cd80c7e0`, Zeile 18; Archiv 14:37 wiederholt das). Der Falltest (gespielte Fälle mit echten Sitzungen) hat drei Läufe hinter sich und ist nicht bestanden. Heute 07:25 sagtest du: „nicht so viel Energie in irgendwelche Tests“. Ersetzt du deine Bedingung vom 11:17 so: kein weiterer Falltest, und „jedes Werkzeug grün“ heißt nur die Werkzeuge, ohne die nach dem Umschalten nichts läuft (Liste unten)?

**Votum:** „1727h A“: ja, die Bedingung wird ersetzt; umgeschaltet wird auf dein Wort „scharf“, sobald die sechs Bedingungen unten erfüllt sind; dazu höchstens zwei Arbeitsplaner zugleich (Bedingung 1). Um 10:00 ist das noch nicht so weit, frühestens heute Nachmittag.

**Berührt:** alle Rollen (fallen weg, Sitzungen bekommen Rufnamen); Spike (Umschalt-Commit 1871, Leser der neuen Liste 1893, Rufnamen 1739, Bereiche 1890, Wiederwecken 1782, Testbitte-Schreiber 1858, Größenprüfung 1866, `settings.json` 1859); Ford (wird Disponent); Jerry (Build-Werkzeug 1765, wirkt mit dem Umschalten); gebaut und wartend: 1762 (Chefwort aus fremder Sitzung in die Vorgangsdatei) und 1763 (Obergrenzen, Start Sokrates bei „steckt fest“) wirken mit dem Umschalten, 1764 (Herzschlag bei Ausfall des Disponenten) erst mit 1894 (Herzschlag unabhängig von Ford).

**Begründung:** Dein Wort 07:25 gegen weitere Testläufe; der Nutzen der neuen Arbeitsweise kommt erst mit dem Umschalten. Die übrigen Werkzeuglücken sind Lücken in einem Ablauf, der dann läuft, keine Sperre.

**Sachverhalt:**
- **Falltest Lauf 3** (`falltest-lauf3/ergebnis.md`): 17 Fälle, 6 bestanden, 9 teilweise, 1 nicht, 1 Fall falsch gestellt. Von den 9 „teilweise“ sind 3 Lücken in Werkzeugen (je mit Vorgang bei Spike), 4 offene Fragen fürs Gespräch (in 1727j), 2 hängen an Texten, die nach dem Lauf geändert und nicht mehr gespielt wurden; ebenso das eine „nicht“.
- **Ungespielt** sind die Änderungen nach Lauf 3: Profil Prüfer Fassungen 8 bis 11, Profil Disponent Fassung 15, im Kern Arbeitsplaner die zwei Halbsätze aus V4 (1727j), dazu aus 1727j V6 und Frage 11.
- **Bedingungen bis umschaltbar** (Spike, Nachrichten an Sokrates 22.11., 08:23 und 08:36; Stand `docs/vorgang/1893.md`):
  1. **Leser der neuen Vorgangsliste (1893):** `startbar.py`, `vorgang.py` und `lauf.py` lesen sie an der Kopie (`1f68ba0a4`, `4f18404c1`). Offen: Rollennamen in sechs Werkzeugen; die bekannten roten Tests an der Kopie (zwei Werkzeugtests und `liegt.py`, Ursache die Schaltmarke); und wer die Aufträge schreibt. Heute hat keine Vorgangsdatei einen Auftrag, an der neuen Liste startet darum keine Fachkraft. Mein Vorschlag (an Spike 08:33, nach der Übergabekette, die du am 21.11., 10:11 mit „3.3 so“ entschieden hast): `lauf.py` startet für die oberste startbare Zeile je Fachprofil ohne Auftrag einen frischen Arbeitsplaner, **höchstens zwei zugleich**; Aufträge entstehen also kurz vor dem Bau, nicht auf Vorrat für über hundert startbare Muss-Zeilen. Etwa 2–3 Stunden.
  2. **Ladetexte** nach `docs/profile/`, Gedächtnis der Leitung `docs/leitung/gedaechtnis.md`, eine Zeile in `chefsache/MUSTER.md`: etwa 30 Minuten; erst nach deinem Wort zu 1727i und 1727j.
  3. **Alte Routinen stilllegen** (`werkzeuge.md` Teil C, etwa Spiegelzeilen und Mittwochsrunde), damit sie nicht weiter Zeilen für Rollen schreiben, die es nicht mehr gibt: etwa 2 Stunden.
  4. **Rest:** Rufnamen (1739), Testbitte-Schreiber (1858), Größenprüfung (1866): zusammen etwa 2–3 Stunden; dazu Bereiche für Kataloge und Regeln (1890, im Titel „vor der Umstellung“) und Wiederwecken bei abgelaufener Frist (1782, dein Wort 1727d am 21.11., 21:31), beide ohne Schätzung.
  5. **`settings.json`** nach deinem Wort zu 1727k (dort auch: der Probelauf-Haken bleibt, er läuft an der neuen Liste fehlerfrei).
  6. **Dein Wort** zu 1727i und 1727j eingearbeitet.
  „Grün“ heißt: alle Werkzeugtests laufen am Umschalt-Commit grün, und Spike zeigt an der Kopie, dass ein Arbeitsplaner startet und danach die Fachkraft. Spike meldet das, ich prüfe es und lege dir den Umschalt-Commit zum Wort „scharf“ vor.
- **Umschalt-Commit an der Kopie** (`docs/vorgang/1871.md`; Zweig `claude/spike-1871-umschalten`, `425c46a00`): Umzug von 220 Absätzen „Zu …“ aus den Vorräten in Vorgangsdateien; jeder offene Vorgang hat eine Vorgangsdatei (Spike 08:23; für die beiden danach angelegten Vorgänge 1893 und 1894 legt der Umschalt-Lauf sie an); Schaltmarke `tools/1727-SCHARF`; Build-Sperre nur für den Build-Macher; Rollenspiegel gestrichen; Werkzeugtests damals 48 von 48 grün an eigenen Daten.
- **Kosten:** 1727 bisher 454,65 $ (Vorgangsliste); Bedingungen 1 bis 4 sind etwa 6,5–8,5 Stunden Arbeit für Spike (Summe seiner Schätzungen) plus 1890 und 1782.

**Auswertung:**
- **A (Empfehlung):** Bedingung ersetzt, kein weiterer Lauf; umschalten nach den sechs Bedingungen. Kosten: nur die Werkzeuge.
- **B:** vorher ein kurzer vierter Lauf nur für das Profil Prüfer (die vier Prüferfälle gegen Fassung 11), eine Sitzung; dann wie A.
- **C:** deine Bedingung bleibt: vierter Lauf für alles Ungespielte (zwei bis drei Sitzungen) und alle Werkzeuglücken aus Lauf 3 vorher gebaut; umschalten frühestens morgen.
- **D:** jetzt umschalten, ohne die Bedingungen: nicht machbar, ohne Bedingung 1 startet keine Sitzung.
- **Stärkstes Gegenargument gegen A:** du hast „Falltest bestanden“ verlangt, und das Profil Prüfer wurde danach viermal ungespielt geändert; ein Fehler dort zeigt sich erst am ersten echten Rückläufer, und den findest dann du als Erster. Entkräftet nur teilweise: jede Fassung ging durch eine frische Nachprüfung, die die Prüferfälle am Text nachvollzog; gespielt ist das nicht. Wer das nicht hinnehmen will, nimmt B: eine Sitzung.
- **Gegenargument zu „höchstens zwei Arbeitsplaner“:** vor jeder Fachkraft liegt ein Arbeitsplaner-Lauf, das kostet Zeit je Vorgang. Entkräftet: der Auftrag ist ohnehin Pflicht, und auf Vorrat geschriebene Aufträge veralten, bis gebaut wird; die Zahl ist ein Wert in `lauf.py`, den du jederzeit änderst.
- **Rückweg:** alles geht in einem Umschalt-Commit (Liste, Vorräte, `docs/profile/`, `settings.json`). Am selben Tag nimmt `git revert` das in etwa 30 Minuten zurück; nicht aber Einträge, die nach dem Umschalten in Vorgangsdateien entstehen. Später braucht es ein Rückumzug-Skript (nicht gebaut, etwa 1 Stunde; jeder umgezogene Absatz trägt seine Quelle) und 1–2 Stunden Nacharbeit je Tag Betrieb (Spike 08:23).

**Folgerungen:** bei A baut Spike die Bedingungen 1 bis 4 (mit dem Wert „zwei Arbeitsplaner“), meldet „grün“; ich arbeite dein Wort zu 1727i, 1727j, 1727k ein, prüfe Spikes Meldung und lege dir den Umschalt-Commit zum Wort „scharf“ vor. Bei B vorher der Lauf heute Vormittag, bei C Lauf und Werkzeuge vorher. Archivzeile mit deinem Wort.

Antwort: …
