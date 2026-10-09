# Chroniken von Bornim

Rollenspiel für Android (Kotlin, Jetpack Compose), Regeln nach SRD 5.1. Module: `core` (Spielregeln, Kampf, Karten, Zeichnung von Figuren und Gegnern), `app` (Oberfläche), `tools/preview` (Vorschau- und Testwerkzeug am Rechner).

## Vor jeder Arbeit lesen

1. `docs/OFFEN.md`, zuerst die **Übergabe-Notiz** oben, dann: was in Arbeit, zu testen und zu entscheiden ist.
2. `docs/STIL.md`: Stil (düster, erwachsen), Abwechslung, selbst prüfen.
3. Den Anfang von `CHANGELOG.md`: was zuletzt umgesetzt wurde.

## Feste Regeln

- Antworten auf Deutsch, Zeiten in Berliner Zeit.
- Erklärungen kurz und präzise. Mutmaßungen klar als solche kennzeichnen; nur Gesichertes als gesichert wiedergeben (wenn möglich mit Quelle).
- Kein Smalltalk, Fokus auf die Aufgabe. Plaudern nur, wenn der Nutzer es ausdrücklich sagt.
- Vor jeder Antwort ein Zeitstempel „[TT.MM., HH:MM]“, immer von der Systemuhr abgelesen (`TZ=Europe/Berlin date "+%d.%m., %H:%M"`), nie geschätzt. Stempel und Korrekturen gehören in die Antwort am Ende, nicht in Zwischenmeldungen.
- Jede Meldung des Nutzers (Fehler, Idee, Frage zum Nachhalten) sofort in `docs/OFFEN.md` eintragen. Nach jeder erledigten Arbeit `docs/OFFEN.md` prüfen und Erledigtes in `CHANGELOG.md` übernehmen.
- Zu jedem Build den direkten Link (Release oder Artefakt) und eine Liste, worauf beim Testen zu achten ist. Bilder mit der Uhrzeit, zu der sie entstanden sind.
- Erst besprechen und vorschlagen; vor großen optischen Änderungen Entwürfe zeigen.
- Änderungen an Kampf, Bewegung oder Effekten selbst durch die echte Oberfläche filmen und die Bildfolge ansehen (Werkzeuge: siehe Übergabe-Notiz). Vor jedem Commit `./gradlew :core:test`.

## Technik und Sicherheit

- Keystore und Signatur-Passwort nie committen (liegen nur als GitHub-Secrets); `local.properties` und SDK-Pfad nie committen.
- Die App-Kennung `de.bornim.game` nie ändern.
- Commits mit `git -c user.name="tramour" -c user.email="tramour@gmail.com" commit …`, mit den vom System vorgegebenen Co-Author- und Sitzungszeilen. Keine Modellbezeichnungen in Dateien.
- Keine Verlaufsänderung, kein Force-Push. Nichts Halbfertiges auf `main`; größere Arbeiten auf eigenen Zweigen, nach dem Test des Nutzers auf `main`.
- Offene Änderungen am Ende einer Arbeit committen und pushen.
- Ein Push auf `main` erzeugt ein Release (Version 0.1.<Laufnummer>); ein Zweig-Build muss eine höhere Laufnummer als das installierte Release haben, sonst lässt er sich nicht installieren.
