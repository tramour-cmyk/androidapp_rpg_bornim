# 1727h · Wann schalten wir die neue Arbeitsweise scharf: wenn die Werkzeuge der Umstellung grün sind, ohne weiteren Falltest?
Sokrates · 22.11., 07:49 (Entwurf, wird vor 10:00 mit Spikes Stand zu 1871 fertig und gegengeprüft) · B Abläufe · aus deinem Wort 22.11., 07:25 („nicht so viel Energie in irgendwelche Tests“) gegen Archiv 21.11., 14:37
Kurz: Umschalten nach grünen Werkzeugen und deinem Wort zu den Texten, der Falltest gilt als erledigt mit Lauf 3.
Beim Chef, weil: Rollen und Accounts (die Rollen fallen mit dem Umschalten weg)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Am 21.11., 14:37 hast du entschieden: „umgeschaltet erst nach Falltest und grünen Werkzeugen“. Um 07:25 heute: keine Testläufe mehr. Der Falltest steht nach Lauf 3 bei 6 bestanden, 9 teilweise, 1 nicht, 1 Fall schief (17 Fälle, `falltest-lauf3/ergebnis.md`); fast alle Teilbefunde sind Werkzeuglücken mit Vorgang bei Spike. Gilt „nach Falltest“ damit als erfüllt, sodass wir umschalten, sobald die Werkzeuge der Umstellung grün sind und du die Texte abgenommen hast?

**Votum:** „1727h A“: Falltest mit Lauf 3 abgeschlossen; Umschalten (Umschalt-Commit 1871 mit `tools/1727-SCHARF`), sobald die Werkzeuge mit „vor Umstellung: ja“ grün sind und dein Wort zu den Texten V1–V6 eingearbeitet ist; Rückweg `git revert` des Umschalt-Commits.

**Berührt:** alle Rollen (fallen weg, Rufnamen); Spike (1871, 1739 Rufnamen, 1865, 1890 und die Lauf-3-Lücken 1797, 1864, 1872, 1873, 1875–1879, 1887, 1888, 1892); Ford (wird Disponent); Vorräte (Umzug in Vorgangsdateien).

**Begründung:** Dein Wort 07:25 und 21.11., 22:16 („eher 5 Minuten“): der Nutzen der neuen Arbeitsweise kommt erst mit dem Umschalten. Ein vierter Lauf prüft vor allem Werkzeuglücken, die als Vorgang schon bekannt sind.

**Sachverhalt:**
- Archiv 21.11., 14:37 D: „umgeschaltet erst nach Falltest und grünen Werkzeugen“.
- Lauf 3: 6 bestanden, 9 teilweise, 1 nicht (P6, Ursache ein inzwischen zurückgenommener Text), 1 Fall schief; ungespielt: Profil Prüfer F8–F10, V4 Feld 7, Profil Disponent F15.
- Werkzeuge mit „vor Umstellung: ja“ und noch nicht gebaut (`werkzeuge.md`): <Liste aus Spikes Stand 09:30: Rufnamen 1739, Umzug 1865, Umstellung Vorgangsliste 1871, `bereiche.py` 1890, `check-env.sh` 1855, `settings.json` 1859 (Schreiben braucht dich), …>.
- Nachprüfungen dieses Entwurfs: 1: 18, 2: 13, 3a: 12, 3b: 12, 3c: 6 neue Befunde.

**Auswertung:**
- **A (Empfehlung):** kein Lauf 4; umschalten nach grünen Werkzeugen und deinem Wort zu V1–V6. Kosten: nur die Werkzeuge.
- **B:** Lauf 4 nur für die ungespielten Texte (Prüfer F8–F10, V4 Feld 7), dann umschalten. Kosten etwa eine Stunde und vier Sitzungen.
- **C:** heute umschalten mit dem, was steht; fehlende Werkzeuge als Muss danach. Schnell, aber ohne Rufnamen und ohne umgestellte Liste greifen Disponent und Arbeitsplaner ins Leere.
- **Stärkstes Gegenargument gegen A:** 9 Fälle nur teilweise; der neue Ablauf startet danach falsch oder lässt Rückläufer liegen, und das findest du als Erster (Haltung 7). Entkräftet: die Teilbefunde haben je einen Vorgang, die meisten im Werkzeug, das vor dem Umschalten grün sein muss; ein Fehlstart nach dem Umschalten zeigt sich in `lauf.py` LIEGT binnen Minuten (1799), und der Rückweg ist ein Revert.

**Folgerungen:** bei A: Spike baut die Liste fertig, meldet „grün“ je Werkzeug; Sokrates arbeitet dein Wort zu V1–V6 ein, legt die Texte unter `docs/profile/` ab (Vorschlag), meldet dir den Umschalt-Commit zum Wort „scharf“. Bei B: Lauf 4 heute Vormittag. Bei C: Umschalt-Commit sofort, Spike baut nach.

Antwort: …
