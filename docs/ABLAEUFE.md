# Abläufe (selten gebraucht)

Nicht beim Start lesen. Nur, wenn der Anlass eintritt; der Auslöser steht jeweils in `CLAUDE.md`.

## Release vorschlagen (65.6)

Einmal „Zeit für ein Release?“ fragen (Rückfrage auf der Seite „Dein Zug“), sobald unter „## Unveröffentlicht“ in `CHANGELOG.md` fünf getestete Themen stehen oder sieben Tage seit dem letzten Release vergangen sind, was zuerst kommt. Nicht wiederholen, bis ein Release erfolgt ist oder der Nutzer neu fragen lässt.

## Release (nur wenn der Nutzer „Release“ sagt, Thema 21)

1. `gh workflow run android.yml -R tramour-cmyk/androidapp_rpg_bornim --ref main -f release=true` (Version 0.1.<Laufnummer>, Notizen aus „## Unveröffentlicht“ in `CHANGELOG.md`).
2. Danach in `CHANGELOG.md` „## Unveröffentlicht“ umbenennen in „## v0.1.X – TT.MM.JJJJ, HH:MM“ (X = Nummer des Release-Laufs).
3. Den Link nennen.
4. `wc -c docs/OFFEN.md`; über 20 KB aufräumen (Regel „OFFEN.md klein halten“).

Zusammengeführte PRs stehen bis dahin unter „## Unveröffentlicht“.

## Neustart (nach „ja“ des Nutzers, Thema 46)

1. Übergabe in `docs/OFFEN.md` schreiben und pushen.
2. Nachfolger selbst starten, in derselben Umgebung: `create_session` mit erster Nachricht „Start“ (wie `SELBST.md` 32.2), **immer mit** `source_url` des Repos, `outcome_branch` = neuer Zweig `claude/<name>-<nr>-<stichwort>` und Titel nach Thema („Tom: 27.4 Bäume, dann 5.6 Schlagbaum“). Ohne Zweig steht die Sitzung in der App unter „Sonstiges“ statt im Repo-Ordner.
3. Dem Nutzer nur den Namen der neuen Sitzung nennen; er wechselt bloß hinüber.
4. Gibt es `create_session` nicht (in gewöhnlichen Sitzungen nicht vorhanden): einmalige geplante Aufgabe in 2 Minuten (`create_trigger` mit `run_once_at`, eigenständiger Auftrag wie „Start“ plus Repo, Name = Titel); sie startet eine frische Sitzung.
5. **Hinweis an den Nutzer, jedes Mal:** Eine so gestartete Sitzung steht nicht in der Chatliste, sondern unter „Geplant“ → Aufgabe (Name = Titel) → „Verlauf“ → Eintrag mit der Uhrzeit; „Ausgeführt“/„Abgeschlossen“ heißt nur, dass die Startmeldung fertig ist.
6. Klappt beides nicht: melden, der Nutzer legt die Sitzung an.
