# 1727h · Wann schalten wir die neue Arbeitsweise scharf: wenn die Werkzeuge der Umstellung grün sind, ohne weiteren Falltest?
Sokrates · 22.11., 07:59 (Entwurf, Fassung 2 nach Nachprüfung 3d Nr. 2–4; wird vor 10:00 mit Spikes Stand zu 1871 fertig und gegengeprüft) · B Abläufe · aus deinem Wort 22.11., 07:25 („nicht so viel Energie in irgendwelche Tests“) gegen Archiv 21.11., 11:17 und 14:37
Kurz: Umschalten nach grünen Werkzeugen und deinem Wort zu den Texten; der Falltest endet mit Lauf 3.
Beim Chef, weil: Rollen und Accounts (die Rollen fallen mit dem Umschalten weg)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Am 21.11. hast du zweimal festgelegt, dass vor dem Umschalten ein Falltest besteht: 11:17 die Reihenfolge „herausziehen → umgemünzt fertig → Gegenprüfung → Falltest, Werkzeuge nebenher“, 14:37 „umgeschaltet erst nach Falltest und grünen Werkzeugen“. Heute 07:25: keine Testläufe mehr. Der Falltest steht nach Lauf 3 bei 6 bestanden, 9 teilweise, 1 nicht, 1 Fall schief (17 Fälle, `falltest-lauf3/ergebnis.md`). Endet der Falltest damit, sodass wir umschalten, sobald die Werkzeuge der Umstellung grün sind und dein Wort zu den Texten (1727i, 1727j) eingearbeitet ist?

**Votum:** „1727h A“: Falltest endet mit Lauf 3; Umschalten (Umschalt-Commit 1871 mit `tools/1727-SCHARF`), sobald die Werkzeuge mit „vor Umstellung: ja“ grün sind (zuerst 1893, Leser der neuen Liste) und 1727i, 1727j eingearbeitet sind. Um 10:00 ist das noch nicht so weit.

**Berührt:** alle Rollen (fallen weg, Rufnamen); Spike (1871, 1739 Rufnamen, 1890 und die Lauf-3-Lücken wie `ergebnis.md` „Werkzeuglücken“: 1796, 1797, 1798, 1799, 1804, 1864, 1872, 1873, 1875–1879, 1887, 1888, 1892); Ford (wird Disponent); Vorräte (Umzug in Vorgangsdateien).

**Begründung:** Dein Wort 07:25 und 21.11., 22:16 („eher 5 Minuten“): der Nutzen der neuen Arbeitsweise kommt erst mit dem Umschalten.

**Sachverhalt:**
- Archiv 21.11., 11:17 (Reihenfolge mit Falltest) und 14:37 (im Eintrag A–D: „umgeschaltet erst nach Falltest und grünen Werkzeugen“).
- Lauf 3, die 9 „teilweise“: 3 Werkzeuglücken mit Vorgang (D1, D3, D5; D5 ungeprüft gegen 1760), 4 Gesprächsfragen (A3, A5, A7 in 1727j; A1 ohne Vorschlag), 2 an ungespielten Texten (P1, P7: Profil Prüfer F9 bzw. F11); dazu „nicht“ P6 (Text, ungespielt). Ungespielt insgesamt: Profil Prüfer F8–F11, V4 Feld 7, Profil Disponent F15.
- Umschalt-Commit an der Kopie (Spike 08:00, `docs/vorgang/1871.md`; Zweig `claude/spike-1871-umschalten`, `425c46a00`): Umzug von 220 „Zu“-Absätzen, `1727-SCHARF`, Build-Sperre nur Build-Macher; Werkzeugtests 48/48 grün, aber an eigenen Daten. **Befund: die umgestellte Liste ist nicht lesbar** für `startbar.py`, `vorgang.py --rolle` und die Commit-Prüfung (verlangen die Spalte Besitzer); Umbau von rund 15 Werkzeugen als 1893, der größte Brocken: **ohne 1893 startet nach dem Umschalten nichts.** `probelauf.py` fällt erst mit `settings.json` (1859), das schreibt nur du.
- Rest bis umschaltbar (Spike 08:12, Schätzung): 1893 etwa 4 h; Ladetexte nach `docs/profile/`, `docs/leitung/gedaechtnis.md`, Grund „Obergrenze A/B“ in `MUSTER.md` 30 Min.; Stilllegung der alten Routinen (C, Rest) 2 h; übrige Muss aus `werkzeuge.md` (Rufnamen Rest 1739, Testbitte-Schreiber 1858, Größen-Skript 1866) 2–3 h; `settings.json` dein Wort (1727k). Summe etwa 8–9 h: frühestens heute Nachmittag. **Mindestfassung** (nur 1893 und Ladetexte, Rest danach): etwa 13:00; dann laufen alte Spiegelzeilen und die Mittwochsrunde weiter und schreiben falsche Zeilen an Perikles, bis C fertig ist.
- Umzug an der Kopie: 325 offene Vorgänge, jeder bekommt eine Vorgangsdatei (fehlende legt der Umschalt-Lauf an).
- Nachprüfungen dieses Entwurfs: 1: 18, 2: 13, 3a: 12, 3b: 12, 3c: 6, 3d: 6 neue Befunde.

**Auswertung:**
- **A (Empfehlung):** kein Lauf 4; umschalten nach grünen Werkzeugen und 1727i, 1727j. Kosten: nur die Werkzeuge.
- **B:** Lauf 4 nur für den Prüfertext (P1, P4, P6, P7 gegen F11), eine Sitzung, etwa 15 Minuten; dann wie A.
- **C:** Lauf 4 für alle ungespielten Texte (Prüfer F8–F11, V4 Feld 7, Disponent F15), zwei bis drei Sitzungen; dann wie A.
- **A′ (Mindestfassung):** wie A, aber umschalten schon nach 1893 und den Ladetexten (etwa 13:00), C und Rest danach. Schneller; bis C fertig ist, falsche Zeilen an Perikles.
- **D:** jetzt umschalten mit dem, was steht. Nicht machbar: ohne 1893 kann kein Werkzeug die neue Liste lesen, es startet nichts.
- **Stärkstes Gegenargument gegen A:** die Texte, an denen P1, P4, P6, P7 hängen, wurden viermal ungespielt geändert (F8–F11); jeder Fehler dort zeigt sich erst am echten Rückläufer, und den findest du als Erster (Haltung 7). Entkräftet nur teilweise: jede Fassung ging durch eine Nachprüfung, die die Soll-Fälle am Text nachvollzog (3d: P1, P4, P6, P7 liefern das Soll); gespielt ist das nicht. Wer das nicht hinnehmen will, nimmt B: eine Sitzung.
- **Rückweg:** `git revert` des Umschalt-Commits stellt Liste und Vorräte zurück, nicht aber die Einträge, die danach in Vorgangsdateien und in der neuen Liste entstehen. Am selben Tag reicht der Revert (30 Min.); danach braucht es ein Rückumzug-Skript (nicht gebaut, etwa 1 h; jeder umgezogene Absatz trägt seine Quelle, jede Vorgangsdatei die alte Listenzeile), Nacharbeit 1–2 h je Tag Betrieb (Spike 08:12).

**Folgerungen:** bei A: Spike baut die Liste fertig, meldet „grün“ je Werkzeug; Sokrates arbeitet 1727i, 1727j ein und meldet dir den Umschalt-Commit zum Wort „scharf“. Bei B oder C vorher der Lauf heute Vormittag. Bei A′ Umschalten gegen 13:00 auf dein Wort „scharf“.

Antwort: …
