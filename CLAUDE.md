# Chroniken von Bornim

Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung von Figuren und Gegnern), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner).

## Vor jeder Arbeit lesen

1. `docs/OFFEN.md`, zuerst die **Übergabe-Notiz** oben, dann: was in Arbeit, zu testen und zu entscheiden ist.
2. `docs/STIL.md`: Stil (düster, erwachsen), Abwechslung, selbst prüfen.
3. Den Anfang von `CHANGELOG.md`: was zuletzt umgesetzt wurde.
4. `docs/UMGEBUNG.md`: was installiert sein muss; mit `tools/check-env.sh` prüfen, ob die Sitzung alles hat.

## Feste Regeln

- Antworten auf Deutsch, Zeiten in Berliner Zeit.
- Jede Nachricht an den Nutzer bekommt einen Zeitstempel „[TT.MM., HH:MM]“, auch Zwischenmeldungen (er liest sie mit), immer von der Systemuhr abgelesen (`TZ=Europe/Berlin date "+%d.%m., %H:%M"`), nie geschätzt.
- Erst auf Rückmeldungen und Fragen des Nutzers antworten und besprechen, dann arbeiten; nicht still und lange umsetzen.
- Jede Meldung des Nutzers (Fehler, Idee, Frage zum Nachhalten) sofort in `docs/OFFEN.md` eintragen. Nach jeder erledigten Arbeit `docs/OFFEN.md` prüfen und Erledigtes in `CHANGELOG.md` übernehmen.
- Zu jedem Build den direkten Link (Release oder Artefakt) und eine Liste, worauf beim Testen zu achten ist. Bilder mit der Uhrzeit, zu der sie entstanden sind.
- Erst besprechen und vorschlagen; vor großen optischen Änderungen Entwürfe zeigen.
- Rückfragen gebündelt am Ende der Antwort, nummeriert und mit Empfehlung, damit der Nutzer kurz antworten kann („1 ja, 2 nein“).
- Änderungen an Kampf, Bewegung oder Effekten selbst durch die echte Oberfläche filmen und die Bildfolge ansehen (Werkzeuge: siehe Übergabe-Notiz). Vor jedem Commit `./gradlew :core:test`.
- Filme sparsam (Wunsch des Nutzers, 09.10.): Logik (Zeiten, Regeln, Abläufe) mit Kerntests prüfen, die in Sekunden laufen; filmen nur, wenn sich eine Bewegung sichtbar ändert. Beim Filmen nur die gespeicherten Bilder zeichnen, mit `CROP=` nur den Ausschnitt speichern und ereignislose Zeit mit `FROM=` überspringen (`WALKFILM`, `IDLEFILM` in `tools/preview`).

## Technik und Sicherheit

- Keystore und Signatur-Passwort nie committen (liegen nur als GitHub-Secrets); `local.properties` und SDK-Pfad nie committen.
- Die App-Kennung `de.bornim.game` nie ändern.
- Commits mit `git -c user.name="tramour" -c user.email="tramour@gmail.com" commit …`, mit den vom System vorgegebenen Co-Author- und Sitzungszeilen. Keine Modellbezeichnungen in Dateien.
- Keine Verlaufsänderung, kein Force-Push. Nichts Halbfertiges auf `main`; größere Arbeiten auf eigenen Zweigen, nach dem Test des Nutzers auf `main`.
- Offene Änderungen am Ende einer Arbeit committen und pushen.
- Ein Push auf `main` erzeugt ein Release (Version 0.1.<Laufnummer>); ein Zweig-Build muss eine höhere Laufnummer als das installierte Release haben, sonst lässt er sich nicht installieren.

## Testen

- Je Anlass das schnellste passende Werkzeug: `tools/t` (Übersicht ohne Befehl; Logik, Zufallsspieler, Bild, Film). Kerntests gehen auch mit `./gradlew -p core test`, ohne Android-Plugin. Einzelheiten in `docs/UMGEBUNG.md`.
