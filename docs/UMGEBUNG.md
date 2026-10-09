# Arbeitsumgebung

Was eine Sitzung (oder ein zweiter Account) braucht, um an „Chroniken von Bornim“ weiterzuarbeiten, und wie man prüft, ob alles da ist. Stand: 09.10.2026, 11:32 (Berliner Zeit).

## Schnellprüfung

Im Hauptordner des Repositorys:

```
tools/check-env.sh          # Programme, Repository, Netz (wenige Sekunden)
tools/check-env.sh --full   # dazu Kerntests und ein Vorschaubild (warm etwa 10 s)
```

Am Ende steht „Ergebnis: … in Ordnung, 0 fehlen.“, wenn alles passt. Zuletzt geprüft am 09.10.2026, 21:31: 11 in Ordnung, 0 fehlen, 11 s.

## Testen nach Anlass: `tools/t`

Ein Einstieg für alle Prüfungen, gleich für jeden Account. `tools/t` ohne Befehl zeigt die Übersicht. Jede Ausgabe endet mit Dauer und Uhrzeit.

| Anlass | Befehl | Dauer (warm, gemessen 09.10.) |
|---|---|---|
| Regel, Wert, Ablauf der Meldungen | `tools/t logik [Muster]` (Kerntests, mit Muster nur die passenden) | 2–3 s gezielt, 11 s alle |
| Bedienung, Spielfluss, Abstürze | `tools/t spieler [Eingaben]` (Zufallsspieler `PlayerSimTest`) | 3 s, 10 000 Eingaben je Spieler 5 s |
| Aussehen einer Haltung, Kollision | `tools/t bild SCHALTER=…` (Vorschau, listet die neuen Bilder) | 5 s |
| Fluss einer Bewegung | `tools/t film FILM…=…` | Echtzeit (siehe „Film-Uhr“ in `docs/OFFEN.md`) |
| Umgebung in Ordnung? | `tools/t pruef` | ~10 s |
| Gesamteindruck am Gerät | Zweig pushen, Build von GitHub, Test durch den Nutzer | Minuten |

Grundsatz: das schnellste Werkzeug, das den Anlass abdeckt. Filmen nur, wenn sich eine Bewegung sichtbar ändert.

**Zufallsspieler (`core/src/test/.../PlayerSimTest.kt`):** spielt ohne Bild wie ein Tester. Er tippt Ziele an (Türen, Leute, Monster, irgendwohin), läuft über die Wegfindung des Spiels, redet, kauft, kämpft (Angriff, Abwehr, Fähigkeiten, Tränke), alles mit festem Seed. Einmal von Spielbeginn an (Dorf) und einmal in jedem Gebiet mit Begegnungen auf Stufe 2 oder 5. Nach jeder Eingabe prüft er: kein Absturz, kein hängender Dialog, TP, Gold und Ort im erlaubten Bereich; alle 250 Eingaben ergeben Speichern und Laden denselben Stand. Bei einem Fund nennt er Klasse, Seed und die letzten Eingaben. Er prüft die Spiellogik, nicht das Bild.

## Sitzungsstart: schnell und sparsam (seit 09.10.2026)

Gilt für jede Cloud-Sitzung und jeden Account gleich, weil alles im Repository liegt:

- `.claude/settings.json` startet beim Sitzungsbeginn `tools/setup-session.sh --warm` (nur in Cloud-Sitzungen). Der Hook kehrt sofort zurück.
- `tools/setup-session.sh` legt `tools/gradle-mirror.gradle` nach `~/.gradle/init.d`. Gradle lädt Maven-Central-Dateien dann vom Google-Spiegel (`maven-central.storage-download.googleapis.com`). Grund: Maven Central weist Downloads aus der Cloud oft mit 429 („Too Many Requests“) ab, am 09.10. auch `repo1.maven.org`. GitHub Actions ist nicht betroffen.
- `--warm` übersetzt im Hintergrund nur `core` mit Tests (Log `/tmp/bornim-warm.log`), denn das braucht jede Sitzung vor dem Commit. Die Vorschau übersetzt `tools/t bild` erst bei Bedarf. Kaltstart mit `core` und Vorschau zusammen gemessen (09.10.): rund 2 min 10 s, 550 MB. Wie viel der Teil nur für `core` braucht, ist nicht getrennt gemessen.
- **Kerntests mit `./gradlew -p core test`** (wie GitHub Actions, auch über `tools/t logik`). `./gradlew :core:test` aus dem Hauptordner lädt zusätzlich das Android-Plugin (über 70 MB), das ohne Android-SDK nichts nützt.
- Gerät der Spiegel aus dem Tritt: `tools/setup-session.sh` von Hand, dann `tools/t pruef`.

## Android-SDK in der Sitzung?

Nicht nötig, Stand 09.10. Die Vorschau übersetzt die ganze Oberfläche aus `app/src/main/java` am Rechner, ohne SDK; ausgenommen sind nur `MainActivity.kt`, `MusicPlayer.kt` und `SfxPlayer.kt` (`tools/preview/build.gradle.kts`). Ein Emulator ginge nur ohne Hardware-Beschleunigung, die Sitzung hat kein `/dev/kvm`; er wäre also sehr langsam (nicht gemessen). Das SDK würde nur die Übersetzung dieser drei Dateien, der Ressourcen und des Manifests vor dem Push prüfen. Das macht GitHub Actions bei jedem Push ohnehin.

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
