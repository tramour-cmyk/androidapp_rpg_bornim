# Arbeitsumgebung

Was eine Sitzung (oder ein zweiter Account) braucht, um an „Chroniken von Bornim“ weiterzuarbeiten, und wie man prüft, ob alles da ist. Stand: 09.10.2026, 11:32 (Berliner Zeit).

## Schnellprüfung

Im Hauptordner des Repositorys:

```
tools/check-env.sh          # Programme, Repository, Netz (wenige Sekunden)
tools/check-env.sh --full   # dazu Kerntests und ein Vorschaubild (warm etwa 10 s)
```

Am Ende steht „Ergebnis: … in Ordnung, 0 fehlen.“, wenn alles passt. Zuletzt geprüft am 09.10.2026, 21:45: 11 in Ordnung, 0 fehlen, 11 s.

## Sitzungsstart: schnell und sparsam (seit 09.10.2026)

Gilt für jede Cloud-Sitzung und jeden Account gleich, weil alles im Repository liegt:

- `.claude/settings.json` startet beim Sitzungsbeginn `tools/setup-session.sh --warm` (nur in Cloud-Sitzungen). Der Hook kehrt sofort zurück.
- `tools/setup-session.sh` legt `tools/gradle-mirror.gradle` nach `~/.gradle/init.d`. Gradle lädt Maven-Central-Dateien dann vom Google-Spiegel (`maven-central.storage-download.googleapis.com`). Grund: Maven Central weist Downloads aus der Cloud oft mit 429 („Too Many Requests“) ab, am 09.10. auch `repo1.maven.org`. GitHub Actions ist nicht betroffen.
- Mit `--warm` werden im Hintergrund `core` (mit Tests) und `tools/preview` übersetzt, Log in `/tmp/bornim-warm.log`. Gemessen am 09.10. ohne Cache: rund 2 min 10 s und 550 MB. Danach brauchen Kerntests ohne Änderung etwa 1–2 s, die Testläufe selbst etwa 11 s, ein Vorschaubild 4–8 s.
- **Kerntests immer mit `./gradlew -p core test`** (wie GitHub Actions). `./gradlew :core:test` aus dem Hauptordner lädt zusätzlich das Android-Plugin (über 70 MB), das ohne Android-SDK nichts nützt.
- Gerät der Spiegel aus dem Tritt: `tools/setup-session.sh` von Hand, dann `tools/check-env.sh`.

## Was gebraucht wird

| Was | Wofür | Stand in der Cloud-Sitzung (09.10.2026) |
|---|---|---|
| JDK 21 | Kerntests (`core`) und Vorschauwerkzeug (`tools/preview`, `jvmToolchain(21)`) | OpenJDK 21, vorinstalliert |
| Gradle | Bauen; der Wrapper `./gradlew` lädt Gradle 8.14.3 selbst | über den Wrapper |
| Netz zu Maven Central und Google Maven | Gradle lädt Kotlin 2.1.21, Compose Desktop 1.5.12 usw. | erreichbar (Standard-Netzregel der Umgebung) |
| ImageMagick (`montage`, `convert`) | Filmbilder zuschneiden und zu Übersichten zusammensetzen | 6.9.12, vorinstalliert |
| Python 3 | kleine, sichere Textänderungen an Dateien | 3.13, vorinstalliert |
| git | Versionsverwaltung | vorinstalliert |
| Android-SDK | nur zum Bauen der App selbst | **nicht nötig und nicht installiert**: die APK baut GitHub Actions bei jedem Push |

Betriebssystem der Cloud-Sitzung: Ubuntu 24.04. Fehlt etwas, lässt es sich so nachinstallieren:

```
sudo apt-get update && sudo apt-get install -y openjdk-21-jdk imagemagick python3 git
```

**Damit es in jeder neuen Sitzung da ist:** dieselbe Zeile in den Umgebungseinstellungen als Setup-Skript eintragen (Umgebungsmenü in der Titelleiste der Sitzung → Bearbeiten → Setup script). Neue Sitzungen führen es beim Start aus. Solange die Standard-Umgebung alles schon mitbringt, ist das nur eine Absicherung.

## Bauen und Veröffentlichen (GitHub)

- Workflow `.github/workflows/android.yml` („Build APK“): JDK 17, Android-SDK und Signatur laufen dort. Version `0.1.<Laufnummer>`.
- Push auf einen Zweig → Artefakt `bornim-apk`. Push auf `main` → Release mit `bornim.apk`. Reine `.md`-Änderungen bauen nicht.
- Signatur: Keystore und Passwort liegen nur als GitHub-Secrets. Nie committen, ebenso `local.properties`.
- Ein zweiter GitHub-Account braucht Zugriff auf das private Repository (Settings → Collaborators) und, um aus Claude heraus zu arbeiten, die verbundene GitHub-App bzw. die Freigabe des Repositorys in den Claude-Einstellungen.

## Werkzeuge im Repository

- `./gradlew -p core test`: Kerntests, vor jedem Commit.
- `tools/preview` (Aufruf: `cd tools/preview && VARIABLE=… ../../gradlew -q run`, Bilder unter `tools/preview/build/screens/`). Die wichtigsten Schalter stehen in der Übergabe-Notiz in `docs/OFFEN.md` (Kampffilme `FILMBATCH`, Bewegungsblätter `FOEANIM`/`VERMINANIM`, Effekte `ABILITYFX`/`STATUSFX`, Durchdringungen `CLASH`/`FOECLASH`).
- Filmläufe sind langsam (5 Kämpfe gut 4 Minuten). Einzelne Shell-Befehle brechen nach 10 Minuten ab, darum lange Läufe aufteilen oder im Hintergrund mit `timeout` starten.

## Was nicht im Repository liegt

- Die Werkzeuge der Cloud-Sitzung selbst (GitHub-Anbindung, Datei-Versand an dich, Zeitstempel über `TZ=Europe/Berlin date`) kommen von Claude Code, nicht aus dem Repository.
- Erinnerungen an frühere Gespräche: alles Wichtige steht in `CLAUDE.md`, `docs/OFFEN.md` (Übergabe-Notiz), `docs/STIL.md`, `docs/MERKLISTE.md` und `CHANGELOG.md`.
