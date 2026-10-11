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

## Chat-Sitzung (claude.ai)

Die Chat-Sitzung hat eine eigene Netzregel. Ohne Freigabe sind Maven Central, Google Maven und Gradle gesperrt, dann laufen weder Kerntests noch Vorschau (nur über GitHub Actions). Freigabe: Einstellungen → Capabilities → „Allow network egress“, mit allen Domains oder mit diesen: `repo.maven.apache.org`, `repo1.maven.org`, `dl.google.com`, `maven.google.com`, `services.gradle.org`, `downloads.gradle.org`, `plugins.gradle.org`. Am 09.10.2026, 12:36 freigegeben und geprüft. Maven Central antwortet beim ersten Laden oft mit 429 (zu viele Anfragen); dafür leitet `tools/setup-session.sh` auf den Google-Spiegel um, der zusätzlich `maven-central.storage-download.googleapis.com` braucht (seit 09.10. abends).

## Bauen und Veröffentlichen (GitHub)

- Workflow `.github/workflows/android.yml` („Build APK“): JDK 17, Android-SDK und Signatur laufen dort. Version `0.1.<Laufnummer>`.
- Push auf einen Zweig → Artefakt `bornim-apk`. Push auf `main` → nur Artefakt (seit 11.10., Thema 21); Release nur von Hand: `gh workflow run android.yml --ref main -f release=true`. Pull Requests bauen nicht doppelt. Reine Änderungen an `.md`-Dateien, `tools/` und `.claude/` bauen nicht (seit 09.10.); auf `main` entsteht dann auch kein Release.
- Signatur: Keystore und Passwort liegen nur als GitHub-Secrets. Nie committen, ebenso `local.properties`.
- Ein zweiter GitHub-Account braucht Zugriff auf das private Repository (Settings → Collaborators) und, um aus Claude heraus zu arbeiten, die verbundene GitHub-App bzw. die Freigabe des Repositorys in den Claude-Einstellungen.

## Werkzeuge im Repository

- `./gradlew -p core test`: Kerntests, vor jedem Commit (Exit-Code prüfen).
- `tools/t` (Übersicht ohne Befehl), z. B. `tools/t bild SCHALTER=…`. Vorschau direkt: `cd tools/preview && SCHALTER=… ../../gradlew -q run`, Bilder unter `tools/preview/build/screens/`.
- Filmläufe sind langsam (5 Kämpfe gut 4 Minuten); Shell-Befehle brechen nach 10 Minuten ab, lange Läufe aufteilen oder im Hintergrund mit `timeout`.
- **Im Spiel testen:** Testmodus (7× auf das Copyright im Titel tippen), Reiter „Test“: Stufe, Gold, Vorräte, Testkämpfe, „Sicht: diagonal“, „Dorf und Räume“, „Kartenzoom“, „Monster beachten mich nicht“, „Sichtlinie aus“ u. a.

### Vorschau-Schalter (Auswahl, vorher verstreut in den Übergaben)

| Schalter | Wofür |
|---|---|
| `KARTENZOOM=1` (+ `ONLY=zoom_nah_…`, `DIAG=1`, `TOWNDRAFT=1`, `RAIN=1`, `ZOOMSTUFE=`) | Bildschirmfotos der Karte im echten Spiel: Wald, Dorf, Schänke (`i1`, `i2`), Entwürfe Ältester `e`, Laden `l`, Tempel `t`, Tag und Abend |
| `ISODINGE=1` / `=aeltester` / `=laden` / `=tempel` | Blatt aller Raum-Möbel diagonal, je drei Varianten |
| `FEUER=1` | alle Bilder des Kaminfeuers |
| `WALKFILM=karte:x:y` (+ `CROP=x0:y0:x1:y1`, `FROM=`), `IDLEFILM=` | Laufen bzw. Stehen durch die echte Oberfläche filmen |
| `FLORA=karte:x0:y0:breite:höhe` | Kartenausschnitt in voller Auflösung |
| `FIREFLIES=1`, `SQUATDRAFT=1`, `MAPFIGYAWS=1 WEAPONS=…` | Glühwürmchen, Garrick hocken/schüren/dösen, Waffen in allen Richtungen |
| `MAPFOE=scene\|dirs\|walk\|yaws\|others\|cave\|wood`, `FOEFILM=1` (`FOEIDLE=1`) | Monster auf der Karte: Entwürfe, Film |
| `FILM=klasse:gegner FILMTAPS=…`, `FILMBATCH=datei FILMSTEP=40` | Kampffilme (S Szene, F Kampf, A Angriff, D Abwehr) |
| `SPRUNGBILD=` | Standbilder rund um eine Fundstelle des Sprungtests |
| `FOEANIM=`, `VERMINANIM=`, `CLASH=1`, `FOECLASH=1`, `ABILITYFX=1`, `STATUSFX=1` | Bewegungsblätter, Kollisionsprüfung, Effekte |
| `SOUNDS=NAME,…`, `KLANGPROBEN=…` | Hörproben |
| `SIM=1 ./gradlew -p core test --tests '*ChapterSimTest*'` | Kapitelsimulation (Balance) |

Kerntests mit eigenem Zweck: `JumpTest`/`BattleJumpTest` (Sprünge), `InnCornerTest` (Laufen im Raum), `FireFlickerTest`, `HitWeightTest`, `MissStreakTest`, `RoamerTest`.

## Was nicht im Repository liegt

- Die Werkzeuge der Cloud-Sitzung selbst (GitHub-Anbindung, Datei-Versand an dich, Zeitstempel über `TZ=Europe/Berlin date`) kommen von Claude Code, nicht aus dem Repository.
- Erinnerungen an frühere Gespräche: alles Wichtige steht in `CLAUDE.md`, `docs/OFFEN.md` (Übergaben), `docs/STIL.md`, `docs/MERKLISTE.md`, `CHANGELOG.md`; der Verlauf in `docs/ARCHIV.md`.

## Notizen auf `main` (seit 10.10.)

`tools/notiz.sh` holt `main`, legt die Arbeitskopie `../bornim-main` für Notizen an, meldet den Namen der Sitzung (Tom oder Jerry, aus der Tabelle in `CLAUDE.md`) und zeigt, was sich seit dem letzten Aufruf an `CLAUDE.md`, `CHANGELOG.md` und `docs/` geändert hat. Der Starthaken ruft es mit `--kurz` auf.
