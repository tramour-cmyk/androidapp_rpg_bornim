# Abläufe (selten gebraucht)

Nicht beim Start lesen. Nur, wenn der Anlass eintritt; der Auslöser steht jeweils in `CLAUDE.md` oder der Rollendatei.

## Release vorschlagen (65.6)

Einmal „Zeit für ein Release?“ fragen (Rückfrage auf der Seite „Dein Zug“), sobald unter „## Unveröffentlicht“ in `CHANGELOG.md` fünf getestete Themen stehen oder sieben Tage seit dem letzten Release vergangen sind, was zuerst kommt. Nicht wiederholen, bis ein Release erfolgt ist oder der Nutzer neu fragen lässt.

## Release (nur wenn der Nutzer „Release“ sagt, Thema 21)

1. `gh workflow run android.yml -R tramour-cmyk/androidapp_rpg_bornim --ref main -f release=true` (Version 0.1.<Laufnummer>, Notizen aus „## Unveröffentlicht“ in `CHANGELOG.md`).
2. Danach in `CHANGELOG.md` „## Unveröffentlicht“ umbenennen in „## v0.1.X – TT.MM.JJJJ, HH:MM“ (X = Nummer des Release-Laufs).
3. Den Link nennen.

Zusammengeführte PRs stehen bis dahin unter „## Unveröffentlicht“.

## Neustart (81r: Thema fertig oder zweite Erinnerung des Hakens; kein Ja nötig)

1. Übergabe mit „Nachfolger: <Titel>“ im eigenen Vorrat schreiben und pushen (oben im Vorrat, den der Kopf der Rollendatei nennt; D13.4, D14.1).
1a. `send_message` an Fords Sitzung (Kennung oben in `ARBEIT-BETRIEB.md`): „Neustart <Name>, <Commit>“. Ford startet und meldet den Link per Telegram; dem Nutzer im Chat nur „weiter in <Titel>“. Antwortet Ford nicht in 5 Minuten (oder Jerry ohne Ford): weiter mit 2; Diogenes startet nie selbst, sondern meldet `--laut`.
2. Nachfolger selbst starten (vorher Startmarke „HH:MM Start <Name> (selbst)“ ins Protokoll von `ARBEIT-BETRIEB.md` pushen, D5.2), in derselben Umgebung: `create_session` mit erster Nachricht = Startwort der Rolle mit Hut („Tom“, „Sokrates Projekt“, „Diogenes“), nie „Start“, **immer mit** `source_url` des Repos, `outcome_branch` = neuer Zweig `claude/<name>-<nr>-<stichwort>` und Titel nach Rolle und Thema mit Startzeit („Tom – 27.4 Bäume, dann 5.6 Schlagbaum (15.10., 13:40)“, „Sokrates Projekt – Nachprüfung 98 (16.10., 09:12)“, 81v); danach Vorgänger archivieren (`archive_session`, sonst Ford). Ohne Zweig steht die Sitzung in der App unter „Sonstiges“ statt im Repo-Ordner. Ford liest beim Start die erste Antwort (Rolle, Vorrat richtig?) und trägt die Sitzung in `ARBEIT-BESETZUNG.md` ein.
3. Dem Nutzer nur den Namen der neuen Sitzung nennen; er wechselt bloß hinüber.
4. Gibt es `create_session` nicht (in gewöhnlichen Sitzungen nicht vorhanden): einmalige geplante Aufgabe in 2 Minuten (`create_trigger` mit `run_once_at`, eigenständiger Auftrag mit Startwort plus Repo, Name = Titel); sie startet eine frische Sitzung.
5. **Hinweis an den Nutzer, jedes Mal:** Eine so gestartete Sitzung steht nicht in der Chatliste, sondern unter „Geplant“ → Aufgabe (Name = Titel) → „Verlauf“ → Eintrag mit der Uhrzeit; „Ausgeführt“/„Abgeschlossen“ heißt nur, dass die Startmeldung fertig ist.
6. Klappt beides nicht: melden, der Nutzer legt die Sitzung an.
