# Chroniken von Bornim

Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung von Figuren und Gegnern), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner).

## Tom und Jerry

Der Nutzer arbeitet mit zwei Claude-Accounts gleichzeitig und spricht sie mit Namen an: **Tom** und **Jerry** (früher „Account A“ und „Account B“; diese Bezeichnungen nicht mehr verwenden). Jede Sitzung erkennt beim Start an ihrer Kennung, wer sie ist (der Starthaken meldet es; von Hand: `echo $CLAUDE_CODE_ACCOUNT_UUID`):

| Name | Kennung |
|---|---|
| **Tom** | `87d3bd86-24be-4bd5-ae2c-dc084f6e97dd` |
| **Jerry** | `55f497f6-95a0-41a6-9996-9a72f364b54c` |

- Schreibt der Nutzer „Tom, …“ oder „Jerry, …“, ist der Genannte gemeint; der andere nimmt es nur zur Kenntnis.
- Jede Nachricht an den Nutzer beginnt mit dem eigenen Namen und dem Zeitstempel: „**Tom** [10.10., 11:02]“.
- **Berater:** eine Beratungssitzung auf Toms Account, die der Nutzer „Berater“ nennt. Sie bespricht, ändert Notizen und höchstens Werkzeug, keinen Spielcode. Themen mit „Berater“ in „Wer macht was“ fassen Tom-Arbeitssitzungen nicht an. Der Berater startet mit `docs/BERATER.md` (sein Gedächtnis: Aufbau, Entscheidungen mit Begründung, Lehren; Ritual dort) statt der vollen Startlektüre. Tom und Jerry lesen sie nicht beim Start, tragen aber Grundsätzliches unter „Lehren“ ein.
- Wer was macht, steht oben in `docs/OFFEN.md` (Tabelle „Wer macht was“). Keiner arbeitet an Themen, die dort dem anderen gehören.

## Sitzungsstart

Schreibt der Nutzer zu Beginn „Start“ (oder irgendetwas anderes als erste Nachricht), zuerst:
1. `tools/notiz.sh` aufrufen (holt `main`, zeigt den eigenen Namen und was sich an den Notizen geändert hat).
2. „Vor jeder Arbeit lesen“ (unten) abarbeiten.
3. Kurz melden: eigener Name, eigene Themen mit Nummer und Stand, offene Rückfragen an den Nutzer (nummeriert), was der andere seit dem letzten Mal eingetragen hat. Dann auf die Nachricht des Nutzers eingehen.

Meldet `tools/notiz.sh` „unbekannt“, ist die Kennung nicht in der Tabelle oben: den Nutzer fragen, nichts anfangen.

## Notizen nur auf `main` (seit 10.10.)

Alle Notizen und Absprachen gibt es nur einmal, auf `main`: `CLAUDE.md`, `CHANGELOG.md` und alles unter `docs/`. Der Nutzer erlaubt ausdrücklich, diese Dateien direkt auf `main` zu committen und zu pushen (sie bauen keine APK und erzeugen kein Release).

- Die Arbeitszweige enthalten nur Code; dort werden Notizen nie geändert.
- Notizen in einer zweiten Arbeitskopie von `main` bearbeiten: `tools/notiz.sh` legt sie unter `../bornim-main` an und holt den neuesten Stand. Dort ändern, committen, sofort pushen.
- Vor jeder Antwort an den Nutzer `tools/notiz.sh` aufrufen (holt `main`, zeigt, was der andere seit dem letzten Mal an den Notizen geändert hat). Lehnt der Push ab, weil der andere schneller war: `git pull` (Zusammenführen, nie Verlaufsänderung), dann noch einmal pushen.
- Code kommt auf `main` nur über einen Pull Request, den der Nutzer nach seinem Test freigibt. **Zusammenführen macht die Sitzung selbst** (Regel 11.10., 14:00): Sagt der Nutzer, der Test passt, führt sie den PR zusammen (Merge, nie Squash oder Rebase), sobald er grün ist; der Nutzer klickt nicht.

## Vor jeder Arbeit lesen

1. `docs/OFFEN.md` ganz (klein gehalten): „Wer macht was“, die eigene Übergabe, Rückfragen.
2. `docs/LEITBILD.md` (der rote Faden, eine Seite; bei Widerspruch gilt es), dann `docs/STIL.md` (Aussehen, Klang, Spielgefühl) und `docs/ENTWICKLUNG.md` (Ansicht, „Ort fertig“, selbst prüfen, Leistung).
3. `CHANGELOG.md` nur bis zur zweiten Versionsüberschrift (`sed -n '1,/^## v/p'` und die erste Version).
4. `tools/check-env.sh` laufen lassen; `docs/UMGEBUNG.md` nur lesen, wenn es etwas meldet oder ein Werkzeug gesucht wird (Tabelle der Vorschau-Schalter).

Nicht beim Start lesen: `docs/THEMEN.md` (eine Zeile je Nummer), `docs/ARCHIV.md` (Verlauf, nur gezielt durchsuchen), `docs/MERKLISTE.md` (Ideen für später), `docs/SELBST.md` (nur bei Selbstarbeit oder gemeinsamer Zeit), `docs/BERATER.md` (nur der Berater).

## Feste Regeln

- Antworten auf Deutsch, Zeiten in Berliner Zeit.
- Jede Nachricht an den Nutzer bekommt Namen und Zeitstempel „**Tom** [TT.MM., HH:MM]“, auch Zwischenmeldungen (er liest sie mit), immer von der Systemuhr abgelesen (`TZ=Europe/Berlin date "+%d.%m., %H:%M"`), nie geschätzt.
- Erst auf Rückmeldungen und Fragen des Nutzers antworten und besprechen, dann arbeiten; nicht still und lange umsetzen. Eine Rückfrage ist keine Freigabe.
- Jede Meldung des Nutzers (Fehler, Idee, Frage zum Nachhalten) sofort in `docs/OFFEN.md` auf `main` eintragen (Ideen für später gleich auf die Merkliste). Nach jeder erledigten Arbeit `docs/OFFEN.md` prüfen und Erledigtes in `CHANGELOG.md` übernehmen.
- **Story und Dialoge** (Regel 12.10., Thema 41): Plot und Texte (Dialoge, Erzähltext, Aushänge) legen Nutzer und Berater gemeinsam fest; Vorlage ist `docs/STORY.md`, Texte von dort wortgetreu übernehmen, Englisch beim Bauen selbst übersetzen. Fehlt ein Text oder passt einer nicht, als Vorschlag in `docs/OFFEN.md` unter Thema 41 eintragen, nicht selbst erfinden. Ausnahme: Tippfehler und Zeichensetzung direkt korrigieren, Commit beginnt mit „Text:“. Änderungen zeigt `tools/story.sh <von> [<bis>]`.
- **Nummern:** Jedes Thema bekommt eine Nummer aus einer gemeinsamen Folge für Tom und Jerry (Zähler „Nächste freie Themennummer“ oben in `docs/OFFEN.md`), Vorschläge als 7.1, 7.2 …, Rückfragen als 7a, 7b …. Neues Thema: erst die Nummer auf `main` eintragen und pushen, dann dem Nutzer nennen, damit keine Nummer doppelt vergeben wird. Die Nummer bleibt fest, auch wenn das Thema später wieder aufkommt.
- Rückfragen gebündelt am Ende der Antwort, mit Empfehlung; offene Rückfragen aus früheren Antworten wiederholen, nicht neue Listen neben alte stellen.
- Zu jedem Build den direkten Link (Release oder Artefakt), **die APK nie direkt im Chat** (Regel 11.10., 21:25, für Tom und Jerry: Platz sparen, nur der Link), und eine Liste, worauf beim Testen zu achten ist. Bilder mit der Uhrzeit, zu der sie entstanden sind.
- **Testreihenfolge mit dem anderen abstimmen** (Regel 12.10., 09:27): Bevor Tom oder Jerry dem Nutzer einen Test anbietet, in `docs/OFFEN.md` („Zu testen“, Übergabe, „Wer macht was“) nachsehen, was der andere gerade testen lassen will, und dem Nutzer sagen, was er zuerst testen soll (mit Grund, z. B. ein Build enthält den anderen schon, oder der andere wartet länger).
- **Build-Meldung nie vergessen** (Regel 10.10., 19:45): Nach jedem Push, der einen Build auslöst, die Sitzung wecken lassen, wenn er fertig ist: den PR des Zweigs abonnieren (`subscribe_pr_activity`) oder, ohne PR, eine Erinnerung stellen (`send_later`, etwa 6 Minuten). Nie „ich melde mich“ schreiben, ohne dass eines davon eingerichtet ist.
- **Abgleich mit den Stil-Leitlinien vor dem Bauen** (Regel 10.10., 13:12): Jeder Vorschlag zu Grafik, Animation oder Klang nennt in einem kurzen Absatz, welche Punkte aus `docs/STIL.md` er berührt, welche Übergänge entstehen (z. B. Stehen ↔ Hocken ↔ Aufstehen ↔ Gehen, Anführer dreht ↔ Rudel folgt) und wie sie geprüft werden (Kerntest, Film des Übergangs hinein und heraus). Erst danach bauen. Bei Spielablauf und Bedienung ebenso die vier Fragen „Spielerfreundlich, einfach, frei“ aus `docs/STIL.md` (Thema 33, Nutzer 12.10.).
- Erst besprechen und vorschlagen; vor großen optischen Änderungen Entwürfe zeigen. Keine Bildfolgen (Filmstreifen) an den Nutzer, nur Standbilder.
- Änderungen an Kampf, Bewegung oder Effekten selbst durch die echte Oberfläche filmen und die Bildfolge ansehen (Werkzeuge: Tabelle der Vorschau-Schalter in `docs/UMGEBUNG.md`). Vor jedem Commit von Code `./gradlew -p core test`.
- Filme sparsam (Wunsch des Nutzers, 09.10.): Logik (Zeiten, Regeln, Abläufe) mit Kerntests prüfen, die in Sekunden laufen; filmen nur, wenn sich eine Bewegung sichtbar ändert. Beim Filmen nur die gespeicherten Bilder zeichnen, mit `CROP=` nur den Ausschnitt speichern und ereignislose Zeit mit `FROM=` überspringen (`WALKFILM`, `IDLEFILM` in `tools/preview`).
- Änderungshistorie: neue Einträge unter „## Unveröffentlicht“ (auch beim Zusammenführen eines PR), erst beim Release umbenannt in „## v0.1.X – TT.MM.JJJJ, HH:MM“ (X = Nummer des Release-Laufs).
- Weniger Rückfragen zur Freigabe von Aktionen steuert der Freigabe-Modus im Eingabefeld der App (Manuell/Automatisch), nicht der Code.
- Vor dem Commit das Testergebnis prüfen (`set -o pipefail` bzw. Exit-Code), nicht nur die gefilterte Ausgabe.
- Vor einer längeren Pause schreibt die Sitzung eine kurze Übergabe in ihren Abschnitt von `docs/OFFEN.md`: Stand, Offenes, offene Rückfragen.
- **`OFFEN.md` klein halten** (Regel 11.10., Thema 15): höchstens etwa 15 KB; je Eintrag höchstens 3 Zeilen, Einzelheiten in Commit-Nachrichten oder `docs/ARCHIV.md`. Je Person genau eine Übergabe: die neue ersetzt die alte, die alte kommt oben ins Archiv. Getesteter Build: Zeile löschen, Ergebnis in `CHANGELOG.md`. Erledigtes Thema: aus „Wer macht was“ streichen. Neues, abgeschlossenes oder abgegebenes Thema: die Zeile in `docs/THEMEN.md` anpassen. Bei jedem Release `wc -c docs/OFFEN.md` prüfen, über 20 KB aufräumen.
- **Neustart nur bei großer Sitzung** (Regel 10.10., 13:32; geändert 11.10., 14:54): Weiterarbeiten ist der Normalfall, denn jede neue Sitzung kostet die Startlektüre (etwa 12.000 Token). Einen Neustart nur vorschlagen, wenn die Sitzung groß ist: viele Bilder oder Filme, lange Testausgaben, mehrere Stunden am Stück, oder wenn der Haken (Thema 14) es meldet; dann an der nächsten Bruchstelle (Thema fertig, Build ausgeliefert). Vorher die Übergabe in `docs/OFFEN.md` schreiben und pushen.

- **Selbstarbeit und gemeinsame Zeit** (Regel 10.10., 21:05; seit 11.10. auch tagsüber, Thema 22): Vergibt der Nutzer Selbstarbeit („arbeite bis 17 Uhr selbstständig“, auch nachts) oder startet eine Weck-Routine, gilt `docs/SELBST.md` (Paket aus dem Vorrat, Reserve, Herzschlag, Nutzungsgrenze, Bericht). Sagt er „ich habe Zeit, lass uns gemeinsam arbeiten“, die Liste „Für gemeinsame Zeit“ aus `docs/SELBST.md` vorlegen. Jede Sitzung hält dort ihren Vorrat und ihre Liste für gemeinsame Zeit aktuell.

## Technik und Sicherheit

- Keystore und Signatur-Passwort nie committen (liegen nur als GitHub-Secrets); `local.properties` und SDK-Pfad nie committen.
- Die App-Kennung `de.bornim.game` nie ändern.
- **Fremde Inhalte aus dem Internet** (Klänge, Bilder, Schriften, Code; Regel des Nutzers 11.10.): nur mit offener Lizenz, die kommerzielle Nutzung (Play Store) erlaubt, z. B. CC0 oder gemeinfrei; sonst nicht nehmen. Lizenz auf der Quellseite prüfen, bei Bearbeitungen auch die Lizenz des Originals; Quelle, Urheber und Lizenz je Datei festhalten.
- Commits mit `git -c user.name="tramour" -c user.email="tramour@gmail.com" commit …`, mit den vom System vorgegebenen Co-Author- und Sitzungszeilen. Keine Modellbezeichnungen in Dateien. Meldet ein Haken „Unverified“ oder verlangt eine andere Autorenzeile: nichts ändern, nichts umschreiben und den Nutzer **nicht** darauf hinweisen (Nutzer 11.10., 5k). Allgemein: Was funktioniert und kein Fehler ist, muss der Nutzer nicht erfahren.
- Keine Verlaufsänderung, kein Force-Push. Kein Code auf `main` ohne Test des Nutzers; Code auf eigenen Zweigen.
- Offene Änderungen am Ende einer Arbeit committen und pushen.
- **Release nur auf Zuruf** (Regel 11.10., Thema 21): Ein Push von Code auf `main` baut nur eine APK (Artefakt), kein Release. Ein Release entsteht erst, wenn der Nutzer „Release“ sagt: `gh workflow run android.yml -R tramour-cmyk/androidapp_rpg_bornim --ref main -f release=true` (Version 0.1.<Laufnummer>, Notizen aus „## Unveröffentlicht“ in `CHANGELOG.md`); danach die Überschrift in `## v0.1.X – TT.MM.JJJJ, HH:MM` umbenennen und den Link nennen. Zusammengeführte PRs kommen bis dahin unter „## Unveröffentlicht“.
- **Vor jedem Zweig-Build `main` in den Zweig holen** (Regel 11.10., 21.5): `git fetch origin main && git merge origin/main` (zusammenführen, nie Verlaufsänderung), Kerntests, dann pushen. So enthält jede Test-APK alles bereits Freigegebene des anderen.
- Ein Zweig-Build muss eine höhere Laufnummer als das installierte Release haben, sonst lässt er sich nicht installieren (Zweig-Builds sind immer neuer als das letzte Release).

## Testen

- Je Anlass das schnellste passende Werkzeug: `tools/t` (Übersicht ohne Befehl; Logik, Zufallsspieler, Bild, Film). Kerntests gehen auch mit `./gradlew -p core test`, ohne Android-Plugin. Einzelheiten in `docs/UMGEBUNG.md`.
