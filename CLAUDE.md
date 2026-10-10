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
- Code kommt auf `main` nur über einen Pull Request, den der Nutzer nach seinem Test freigibt.

## Vor jeder Arbeit lesen

1. `docs/OFFEN.md`: zuerst „Wer macht was“ und die Übergabe-Notiz, dann die eigenen Themen.
2. `docs/STIL.md`: Stil (düster, erwachsen), Abwechslung, selbst prüfen.
3. Den Anfang von `CHANGELOG.md`: was zuletzt umgesetzt wurde.
4. `docs/UMGEBUNG.md`: was installiert sein muss; mit `tools/check-env.sh` prüfen, ob die Sitzung alles hat.

## Feste Regeln

- Antworten auf Deutsch, Zeiten in Berliner Zeit.
- Jede Nachricht an den Nutzer bekommt Namen und Zeitstempel „**Tom** [TT.MM., HH:MM]“, auch Zwischenmeldungen (er liest sie mit), immer von der Systemuhr abgelesen (`TZ=Europe/Berlin date "+%d.%m., %H:%M"`), nie geschätzt.
- Erst auf Rückmeldungen und Fragen des Nutzers antworten und besprechen, dann arbeiten; nicht still und lange umsetzen. Eine Rückfrage ist keine Freigabe.
- Jede Meldung des Nutzers (Fehler, Idee, Frage zum Nachhalten) sofort in `docs/OFFEN.md` auf `main` eintragen. Nach jeder erledigten Arbeit `docs/OFFEN.md` prüfen und Erledigtes in `CHANGELOG.md` übernehmen.
- **Nummern:** Jedes Thema bekommt eine Nummer aus einer gemeinsamen Folge für Tom und Jerry (Zähler „Nächste freie Themennummer“ oben in `docs/OFFEN.md`), Vorschläge als 7.1, 7.2 …, Rückfragen als 7a, 7b …. Neues Thema: erst die Nummer auf `main` eintragen und pushen, dann dem Nutzer nennen, damit keine Nummer doppelt vergeben wird. Die Nummer bleibt fest, auch wenn das Thema später wieder aufkommt.
- Rückfragen gebündelt am Ende der Antwort, mit Empfehlung; offene Rückfragen aus früheren Antworten wiederholen, nicht neue Listen neben alte stellen.
- Zu jedem Build den direkten Link (Release oder Artefakt), die APK auch direkt im Chat, und eine Liste, worauf beim Testen zu achten ist. Bilder mit der Uhrzeit, zu der sie entstanden sind.
- Erst besprechen und vorschlagen; vor großen optischen Änderungen Entwürfe zeigen. Keine Bildfolgen (Filmstreifen) an den Nutzer, nur Standbilder.
- Änderungen an Kampf, Bewegung oder Effekten selbst durch die echte Oberfläche filmen und die Bildfolge ansehen (Werkzeuge: siehe Übergabe-Notiz). Vor jedem Commit von Code `./gradlew -p core test`.
- Filme sparsam (Wunsch des Nutzers, 09.10.): Logik (Zeiten, Regeln, Abläufe) mit Kerntests prüfen, die in Sekunden laufen; filmen nur, wenn sich eine Bewegung sichtbar ändert. Beim Filmen nur die gespeicherten Bilder zeichnen, mit `CROP=` nur den Ausschnitt speichern und ereignislose Zeit mit `FROM=` überspringen (`WALKFILM`, `IDLEFILM` in `tools/preview`).
- Änderungshistorie: neue Einträge unter „## Unveröffentlicht“, bei Veröffentlichung umbenannt in „## v0.1.X – TT.MM.JJJJ, HH:MM“ (X = Nummer des Build-Laufs).
- Weniger Rückfragen zur Freigabe von Aktionen steuert der Freigabe-Modus im Eingabefeld der App (Manuell/Automatisch), nicht der Code.
- Vor dem Commit das Testergebnis prüfen (`set -o pipefail` bzw. Exit-Code), nicht nur die gefilterte Ausgabe.
- Vor einer längeren Pause schreibt die Sitzung eine kurze Übergabe in ihren Abschnitt von `docs/OFFEN.md`: Stand, Offenes, offene Rückfragen.

## Technik und Sicherheit

- Keystore und Signatur-Passwort nie committen (liegen nur als GitHub-Secrets); `local.properties` und SDK-Pfad nie committen.
- Die App-Kennung `de.bornim.game` nie ändern.
- Commits mit `git -c user.name="tramour" -c user.email="tramour@gmail.com" commit …`, mit den vom System vorgegebenen Co-Author- und Sitzungszeilen. Keine Modellbezeichnungen in Dateien.
- Keine Verlaufsänderung, kein Force-Push. Kein Code auf `main` ohne Test des Nutzers; Code auf eigenen Zweigen.
- Offene Änderungen am Ende einer Arbeit committen und pushen.
- Ein Push von Code auf `main` erzeugt ein Release (Version 0.1.<Laufnummer>); ein Zweig-Build muss eine höhere Laufnummer als das installierte Release haben, sonst lässt er sich nicht installieren.

## Testen

- Je Anlass das schnellste passende Werkzeug: `tools/t` (Übersicht ohne Befehl; Logik, Zufallsspieler, Bild, Film). Kerntests gehen auch mit `./gradlew -p core test`, ohne Android-Plugin. Einzelheiten in `docs/UMGEBUNG.md`.
