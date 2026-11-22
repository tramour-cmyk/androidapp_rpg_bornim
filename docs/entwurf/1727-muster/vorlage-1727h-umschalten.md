# 1727h · Schalten wir die neue Arbeitsweise ohne weiteren Falltest scharf, sobald die Werkzeuge dafür fertig und grün sind?
Sokrates · 22.11., 08:29 · B Abläufe · aus deinem Wort 22.11., 07:25 („nicht so viel Energie in irgendwelche Tests“) gegen Archiv 21.11., 11:17 und 14:37
Kurz: Umschalten nach fertigen Werkzeugen und deinem Wort zu 1727i, 1727j, 1727k; der Falltest endet mit Lauf 3; frühestens heute Nachmittag.
Beim Chef, weil: Rollen und Accounts (die Rollen fallen mit dem Umschalten weg)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Die neue Arbeitsweise (Neustrukturierung, Vorgang 1727: Vorgangsdateien statt Vorräte, Disponent statt Ford, Fachprofile statt Rollen) ist bisher nur an einer Kopie gebaut. Den Plan, sie zuerst im Falltest durchzuspielen (gespielte Fälle mit echten Sitzungen), hast du am 21.11. zweimal bestätigt: 11:17 „Ja, mach es genauso. Gesamtbetrachtung und Reihenfolge.“ auf die Reihenfolge „herausziehen → umgemünzt fertig → Gegenprüfung → Falltest, Werkzeuge nebenher“ (`reihenfolge.md`), und 14:37 „A, B, C, D, ja.“ auf eine Vorlage mit dem Satz „umgeschaltet erst nach Falltest und grünen Werkzeugen“. Heute 07:25 sagtest du: „nicht so viel Energie in irgendwelche Tests“. Der Falltest hat drei Läufe hinter sich. Gilt er damit als erledigt, sodass wir umschalten, sobald die Werkzeuge unten fertig und grün sind und dein Wort zu 1727i, 1727j und 1727k eingearbeitet ist?

**Votum:** „1727h A“: der Falltest endet mit Lauf 3; umgeschaltet wird auf dein Wort „scharf“, sobald die fünf Bedingungen unten erfüllt sind. Um 10:00 ist das noch nicht so weit, frühestens heute Nachmittag.

**Berührt:** alle Rollen (fallen weg, Sitzungen bekommen Rufnamen); Spike (Umschalt-Commit 1871, Leser der neuen Liste 1893, Rufnamen 1739, Testbitte-Schreiber 1858, Größenprüfung 1866, `settings.json` 1859); Ford (wird Disponent); Jerry (Build-Werkzeug 1765, wirkt mit dem Umschalten); die gebauten Werkzeuge 1762 (Chefwort aus fremder Sitzung in die Vorgangsdatei), 1763 (Obergrenzen, Start Sokrates bei „steckt fest“), 1764 (Herzschlag) wirken ab dem Umschalten.

**Begründung:** Dein Wort 07:25 gegen weitere Testläufe; der Nutzen der neuen Arbeitsweise kommt erst mit dem Umschalten.

**Sachverhalt:**
- **Falltest Lauf 3** (`falltest-lauf3/ergebnis.md`): 17 Fälle, 6 bestanden, 9 teilweise, 1 nicht, 1 Fall falsch gestellt. Von den 9 „teilweise“ sind 3 Lücken in Werkzeugen (je mit Vorgang bei Spike), 4 offene Fragen fürs Gespräch (in 1727j), 2 hängen an Texten, die nach dem Lauf geändert und nicht mehr gespielt wurden; ebenso das eine „nicht“.
- **Ungespielt** sind die Änderungen nach Lauf 3: Profil Prüfer Fassungen 8 bis 11, Profil Disponent Fassung 15, im Kern Arbeitsplaner zwei Halbsätze (Ursache belegen und beheben in einem Auftrag; Commit des roten und des behobenen Stands), dazu aus 1727j der Satz im Kern Büro zur Lesart und der Halbsatz zu Deckel und Freigabe.
- **Bedingungen bis umschaltbar** (Spike, Nachricht an Sokrates 22.11., 08:23; Stand `docs/vorgang/1893.md`):
  1. Leser der neuen Vorgangsliste (1893): Teil 1 gebaut an der Kopie (`1f68ba0a4`: `startbar.py`, `vorgang.py`, Test grün); offen `lauf.py` (startet an der neuen Liste noch nichts) und Rollennamen in sechs Werkzeugen; etwa 2–3 Stunden.
  2. Ladetexte nach `docs/profile/`, Gedächtnis der Leitung `docs/leitung/gedaechtnis.md`, eine Zeile in `chefsache/MUSTER.md`: etwa 30 Minuten; erst nach deinem Wort zu 1727i und 1727j.
  3. Alte Routinen stilllegen (`werkzeuge.md` Teil C, zum Beispiel Spiegelzeilen und Rollenspiegel), damit sie nicht weiter Zeilen für Rollen schreiben, die es nicht mehr gibt: etwa 2 Stunden.
  4. Rest der Rufnamen (1739), Testbitte-Schreiber (1858), Größenprüfung (1866): zusammen etwa 2–3 Stunden.
  5. `settings.json` nach deinem Wort zu 1727k.
  „Grün“ heißt: die Werkzeugtests laufen am Umschalt-Commit grün, und Spike zeigt an der Kopie, dass `lauf.py` je Fachprofil startet. Spike meldet das, ich prüfe es und lege dir den Umschalt-Commit zum Wort „scharf“ vor. Die übrigen Werkzeuglücken aus Lauf 3 sind keine Bedingung; sie bleiben Vorgänge bei Spike.
- **Umschalt-Commit an der Kopie** (`docs/vorgang/1871.md`; Zweig `claude/spike-1871-umschalten`, `425c46a00`): Umzug von 220 Absätzen „Zu …“ aus den Vorräten in Vorgangsdateien, jeder offene Vorgang hat eine Vorgangsdatei (Spike 08:23; 1893 und 1894 kommen beim Umschalten dazu), Marke `tools/1727-SCHARF`, Build-Sperre nur für den Build-Macher; Werkzeugtests 48 von 48 grün an eigenen Daten.
- **Kosten:** 1727 bisher 454,65 $ (Vorgangsliste); die Bedingungen 1 bis 4 sind etwa 7–9 Stunden Arbeit für Spike (Summe seiner Schätzungen).

**Auswertung:**
- **A (Empfehlung):** kein weiterer Lauf; umschalten nach den fünf Bedingungen. Kosten: nur die Werkzeuge.
- **B:** vorher ein kurzer vierter Lauf nur für das Profil Prüfer (die vier Prüferfälle gegen Fassung 11), eine Sitzung; dann wie A.
- **C:** vorher ein vierter Lauf für alles Ungespielte oben, zwei bis drei Sitzungen; dann wie A.
- **D:** jetzt umschalten, ohne die Bedingungen: nicht machbar, ohne Bedingung 1 startet nach dem Umschalten keine Sitzung.
- **Stärkstes Gegenargument gegen A:** das Profil Prüfer wurde nach Lauf 3 viermal ungespielt geändert; ein Fehler dort zeigt sich erst am ersten echten Rückläufer, und den findest dann du als Erster. Entkräftet nur teilweise: jede Fassung ging durch eine frische Nachprüfung, die die Prüferfälle am Text nachvollzog; gespielt ist das nicht. Wer das nicht hinnehmen will, nimmt B: eine Sitzung.
- **Rückweg:** alles geht in einem Umschalt-Commit (Liste, Vorräte, `docs/profile/`, `settings.json`). Am selben Tag nimmt `git revert` das in etwa 30 Minuten zurück; nicht aber Einträge, die nach dem Umschalten in Vorgangsdateien entstehen. Später braucht es ein Rückumzug-Skript (nicht gebaut, etwa 1 Stunde; jeder umgezogene Absatz trägt seine Quelle) und 1–2 Stunden Nacharbeit je Tag Betrieb (Spike 08:23).

**Folgerungen:** bei A baut Spike die Bedingungen 1 bis 4, meldet „grün“; ich arbeite dein Wort zu 1727i, 1727j, 1727k ein, prüfe Spikes Meldung und lege dir den Umschalt-Commit zum Wort „scharf“ vor. Bei B oder C vorher der Lauf, heute Vormittag. Archivzeile mit deinem Wort.

Antwort: …
