# Arbeitsumgebung

Was eine Sitzung (oder ein zweiter Account) braucht, um an „Chroniken von Bornim“ weiterzuarbeiten, und wie man prüft, ob alles da ist. Stand: 09.10.2026, 11:32 (Berliner Zeit).

## Schnellprüfung

Im Hauptordner des Repositorys:

```
tools/check-env.sh          # Programme, Repository, Netz (wenige Sekunden)
tools/check-env.sh --full   # dazu Kerntests und ein Vorschaubild (beim ersten Mal einige Minuten, danach unter einer Minute)
```

Am Ende steht „Ergebnis: … in Ordnung, 0 fehlen.“, wenn alles passt. Zuletzt geprüft am 09.10.2026, 11:31: 11 in Ordnung, 0 fehlen.

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

**Maven Central sperrt zeitweise (429 „Too Many Requests“):** Am 09.10.2026, 21:05, lehnten `repo.maven.apache.org` und `repo1.maven.org` Gradle-Downloads ab; die Anfrage auf die Startseite, mit der `check-env.sh` prüft, ging trotzdem durch. Abhilfe nur für die Sitzung (nicht im Repository): ein Init-Skript, das Gradle auf den Google-Spiegel von Maven Central umleitet:

```
mkdir -p ~/.gradle/init.d && cat > ~/.gradle/init.d/maven-mirror.gradle <<'X'
def fix = { RepositoryHandler repos ->
    repos.withType(MavenArtifactRepository).configureEach { r ->
        if (r.url.toString().startsWith("https://repo.maven.apache.org/maven2")) r.url = "https://maven-central.storage-download.googleapis.com/maven2/"
    }
}
beforeSettings { s -> fix(s.pluginManagement.repositories); fix(s.buildscript.repositories)
    s.dependencyResolutionManagement.repositories.whenObjectAdded { fix(s.dependencyResolutionManagement.repositories) } }
allprojects { p -> fix(p.buildscript.repositories); fix(p.repositories)
    p.repositories.whenObjectAdded { fix(p.repositories) }; p.buildscript.repositories.whenObjectAdded { fix(p.buildscript.repositories) } }
X
```

Damit liefen am 09.10. Kerntests und Vorschau durch (`check-env.sh --full`: 11 in Ordnung, 0 fehlen).

**Damit es in jeder neuen Sitzung da ist:** dieselbe Zeile in den Umgebungseinstellungen als Setup-Skript eintragen (Umgebungsmenü in der Titelleiste der Sitzung → Bearbeiten → Setup script). Neue Sitzungen führen es beim Start aus. Solange die Standard-Umgebung alles schon mitbringt, ist das nur eine Absicherung.

## Bauen und Veröffentlichen (GitHub)

- Workflow `.github/workflows/android.yml` („Build APK“): JDK 17, Android-SDK und Signatur laufen dort. Version `0.1.<Laufnummer>`.
- Push auf einen Zweig → Artefakt `bornim-apk`. Push auf `main` → Release mit `bornim.apk`. Reine `.md`-Änderungen bauen nicht.
- Signatur: Keystore und Passwort liegen nur als GitHub-Secrets. Nie committen, ebenso `local.properties`.
- Ein zweiter GitHub-Account braucht Zugriff auf das private Repository (Settings → Collaborators) und, um aus Claude heraus zu arbeiten, die verbundene GitHub-App bzw. die Freigabe des Repositorys in den Claude-Einstellungen.

## Werkzeuge im Repository

- `./gradlew :core:test`: Kerntests, vor jedem Commit.
- `tools/preview` (Aufruf: `cd tools/preview && VARIABLE=… ../../gradlew -q run`, Bilder unter `tools/preview/build/screens/`). Die wichtigsten Schalter stehen in der Übergabe-Notiz in `docs/OFFEN.md` (Kampffilme `FILMBATCH`, Bewegungsblätter `FOEANIM`/`VERMINANIM`, Effekte `ABILITYFX`/`STATUSFX`, Durchdringungen `CLASH`/`FOECLASH`).
- Filmläufe sind langsam (5 Kämpfe gut 4 Minuten). Einzelne Shell-Befehle brechen nach 10 Minuten ab, darum lange Läufe aufteilen oder im Hintergrund mit `timeout` starten.

## Was nicht im Repository liegt

- Die Werkzeuge der Cloud-Sitzung selbst (GitHub-Anbindung, Datei-Versand an dich, Zeitstempel über `TZ=Europe/Berlin date`) kommen von Claude Code, nicht aus dem Repository.
- Erinnerungen an frühere Gespräche: alles Wichtige steht in `CLAUDE.md`, `docs/OFFEN.md` (Übergabe-Notiz), `docs/STIL.md`, `docs/MERKLISTE.md` und `CHANGELOG.md`.
