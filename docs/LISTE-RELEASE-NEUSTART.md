# Release und Neustart

Nicht beim Start lesen. Nur, wenn der Anlass eintritt; der Auslöser steht jeweils in `CLAUDE.md` oder der Rollendatei.

## Release vorschlagen (65.6)

Einmal „Zeit für ein Release?“ fragen (Rückfrage auf „Chefsache“), sobald unter „## Unveröffentlicht“ in `CHANGELOG.md` fünf getestete Themen stehen oder sieben Tage seit dem letzten Release vergangen sind, was zuerst kommt. Nicht wiederholen, bis ein Release erfolgt ist oder der Nutzer neu fragen lässt.

## Release (nur wenn der Nutzer „Release“ sagt, Thema 21)

0. **Prüfung zuerst** (75i, 163): Zeile in `ARBEIT-PRUEFUNG.md` „Release“, dann `send_message` an Ford „Auftrag Diogenes Release“; weiter erst nach seinem Prüfbericht (Befunde, die das Release aufhalten, nennt er dort). Ohne Prüfbericht kein Release.
1. `gh workflow run android.yml -R tramour-cmyk/androidapp_rpg_bornim --ref main -f release=true` (Version 0.1.<Laufnummer>, Notizen aus „## Unveröffentlicht“ in `CHANGELOG.md`).
2. Danach in `CHANGELOG.md` „## Unveröffentlicht“ umbenennen in „## v0.1.X – TT.MM.JJJJ, HH:MM“ (X = Nummer des Release-Laufs).
3. Den Link nennen.

Zusammengeführte PRs stehen bis dahin unter „## Unveröffentlicht“.

## Neustart (81r: Thema fertig oder zweite Erinnerung des Hakens; kein Ja nötig; nie, solange der Chef einen Build dieser Sitzung testet, auch nicht auf Haken, 812, 865)

0. Zählung sichern (347): `python3 /home/user/bornim-main/tools/zug-haken.py --summe <Rolle>` und die Zeile unten an die Tabelle in `docs/LISTE-REGELTREUE.md` anhängen (mit dem Push von 1).
1. Übergabe mit „Nachfolger: <Titel>“ im eigenen Vorrat schreiben und pushen (oben im Vorrat, den der Kopf der Rollendatei nennt; D13.4, D14.1); hat der Chef seit seiner letzten Nachricht eine Antwort bekommen, steht sie als „Letzte Antwort: …“ wörtlich darin, der Nachfolger nennt sie in der Startmeldung (849, Chef 10.11., 11:59).
1a. `send_message` an Fords Sitzung (Kennung oben in `ARBEIT-BETRIEB.md`, unmittelbar vorher mit `git pull` frisch gelesen, nie aus dem eigenen Start: Ford startet sich selbst neu, 165; Ford 2 gibt es nicht mehr, alle an Ford, 650.1): „Neustart <Name>, <Commit>“. Ford startet und meldet den Link per Telegram; dem Nutzer im Chat genau „Weiter in <Titel>: <Link>“ (`CLAUDE.md` Zusammenarbeit 9; 783 W4). Antwortet Ford nicht in 5 Minuten: weiter mit 2; Diogenes startet nie selbst, sondern meldet `--laut`.
2. Nachfolger selbst starten (nur im Notfall; liegt eine Ebene tiefer als ein Start durch Ford, 110; **nur bis Tiefe 6** (`lineage.depth` der eigenen Sitzung, `get_session`), sonst läge der Nachfolger auf 8 ohne Weckruf: dann `--laut` melden, der Chef startet, D16.1; vorher Zeile „- HH:MM TT.MM.: Startsperre HH:MM Start <Name> (selbst)“ ins Protokoll von `ARBEIT-BETRIEB.md` pushen, D5.2; ohne sie hält der Haken 750 A `create_session` an), in Umgebung und mit `model` nach „Startzuordnung“ in `LISTE-BETRIEB.md` („Bei Anlass“, 928): `create_session` mit erster Nachricht = Startwort der Rolle („Tom“, „Perikles“, „Homer“, „Diogenes“), nie „Start“, **immer mit** `source_url` des Repos und `source_revision` `main` (382), `outcome_branch` = neuer Zweig `claude/<name>-<nr>-<stichwort>` und Titel „<Rolle> – <Vorgang>: <Thema> (TT.MM., HH:MM)“ („Tom – 27.4: Bäume (15.10., 13:40)“; 81v, 436); danach Vorgänger archivieren (`archive_session`, sonst Ford). Ohne Zweig steht die Sitzung in der App unter „Sonstiges“. Ford trägt die Sitzung in `ARBEIT-BESETZUNG.md` ein.
3. Dem Nutzer genau „Weiter in <Titel>: <Link>“; er wechselt bloß hinüber (783 W4).
4. Gibt es `create_session` nicht (gewöhnliche Sitzungen, Tiefe 8): einmalige geplante Aufgabe in 2 Minuten (`create_trigger` mit `run_once_at`, Umgebung wie in 2, eigenständiger Auftrag mit Startwort plus Repo, Name = Titel); dem Nutzer jedes Mal sagen, dass sie unter „Geplant“ → Aufgabe → „Verlauf“ steht, nicht in der Chatliste. Klappt auch das nicht: melden, der Nutzer legt die Sitzung an.
