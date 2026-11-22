# 1727h · Wann schalten wir die neue Arbeitsweise scharf: wenn die Werkzeuge der Umstellung grün sind, ohne weiteren Falltest?
Sokrates · 22.11., 07:59 (Entwurf, Fassung 2 nach Nachprüfung 3d Nr. 2–4; wird vor 10:00 mit Spikes Stand zu 1871 fertig und gegengeprüft) · B Abläufe · aus deinem Wort 22.11., 07:25 („nicht so viel Energie in irgendwelche Tests“) gegen Archiv 21.11., 11:17 und 14:37
Kurz: Umschalten nach grünen Werkzeugen und deinem Wort zu den Texten; der Falltest endet mit Lauf 3.
Beim Chef, weil: Rollen und Accounts (die Rollen fallen mit dem Umschalten weg)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Am 21.11. hast du zweimal festgelegt, dass vor dem Umschalten ein Falltest besteht: 11:17 die Reihenfolge „herausziehen → umgemünzt fertig → Gegenprüfung → Falltest, Werkzeuge nebenher“, 14:37 „umgeschaltet erst nach Falltest und grünen Werkzeugen“. Heute 07:25: keine Testläufe mehr. Der Falltest steht nach Lauf 3 bei 6 bestanden, 9 teilweise, 1 nicht, 1 Fall schief (17 Fälle, `falltest-lauf3/ergebnis.md`). Endet der Falltest damit, sodass wir umschalten, sobald die Werkzeuge der Umstellung grün sind und dein Wort zu den Texten (1727i, 1727j) eingearbeitet ist?

**Votum:** „1727h A“: Falltest endet mit Lauf 3; Umschalten (Umschalt-Commit 1871 mit `tools/1727-SCHARF`), sobald die Werkzeuge mit „vor Umstellung: ja“ grün sind und 1727i, 1727j eingearbeitet sind.

**Berührt:** alle Rollen (fallen weg, Rufnamen); Spike (1871, 1739 Rufnamen, 1890 und die Lauf-3-Lücken wie `ergebnis.md` „Werkzeuglücken“: 1796, 1797, 1798, 1799, 1804, 1864, 1872, 1873, 1875–1879, 1887, 1888, 1892); Ford (wird Disponent); Vorräte (Umzug in Vorgangsdateien).

**Begründung:** Dein Wort 07:25 und 21.11., 22:16 („eher 5 Minuten“): der Nutzen der neuen Arbeitsweise kommt erst mit dem Umschalten.

**Sachverhalt:**
- Archiv 21.11., 11:17 (Reihenfolge mit Falltest) und 14:37 (im Eintrag A–D: „umgeschaltet erst nach Falltest und grünen Werkzeugen“).
- Lauf 3, die 9 „teilweise“: 3 Werkzeuglücken mit Vorgang (D1, D3, D5; D5 ungeprüft gegen 1760), 4 Gesprächsfragen (A3, A5, A7 in 1727j; A1 ohne Vorschlag), 2 an ungespielten Texten (P1, P7: Profil Prüfer F9 bzw. F11); dazu „nicht“ P6 (Text, ungespielt). Ungespielt insgesamt: Profil Prüfer F8–F11, V4 Feld 7, Profil Disponent F15.
- Werkzeuge mit „vor Umstellung: ja“ und noch nicht gebaut (`werkzeuge.md`): <Liste aus Spikes Stand 09:30>.
- Nachprüfungen dieses Entwurfs: 1: 18, 2: 13, 3a: 12, 3b: 12, 3c: 6, 3d: 6 neue Befunde.

**Auswertung:**
- **A (Empfehlung):** kein Lauf 4; umschalten nach grünen Werkzeugen und 1727i, 1727j. Kosten: nur die Werkzeuge.
- **B:** Lauf 4 nur für den Prüfertext (P1, P4, P6, P7 gegen F11), eine Sitzung, etwa 15 Minuten; dann wie A.
- **C:** Lauf 4 für alle ungespielten Texte (Prüfer F8–F11, V4 Feld 7, Disponent F15), zwei bis drei Sitzungen; dann wie A.
- **D:** heute umschalten mit dem, was steht; fehlende Werkzeuge als Muss danach. Ohne Rufnamen und ohne umgestellte Liste greifen Disponent und Arbeitsplaner ins Leere.
- **Stärkstes Gegenargument gegen A:** die Texte, an denen P1, P4, P6, P7 hängen, wurden viermal ungespielt geändert (F8–F11); jeder Fehler dort zeigt sich erst am echten Rückläufer, und den findest du als Erster (Haltung 7). Entkräftet nur teilweise: jede Fassung ging durch eine Nachprüfung, die die Soll-Fälle am Text nachvollzog (3d: P1, P4, P6, P7 liefern das Soll); gespielt ist das nicht. Wer das nicht hinnehmen will, nimmt B: eine Sitzung.
- **Rückweg:** `git revert` des Umschalt-Commits stellt Liste und Vorräte zurück, nicht aber die Einträge, die danach in Vorgangsdateien und in der neuen Liste entstehen. Darum gilt der Rückweg ohne Nacharbeit nur bis zum ersten neuen Eintrag; danach braucht er einen Rückumzug (Werkzeug 1871 an der Kopie mitbauen).

**Folgerungen:** bei A: Spike baut die Liste fertig, meldet „grün“ je Werkzeug; Sokrates arbeitet 1727i, 1727j ein und meldet dir den Umschalt-Commit zum Wort „scharf“. Bei B oder C vorher der Lauf heute Vormittag. Bei D Umschalt-Commit sofort, Spike baut nach.

Antwort: …
