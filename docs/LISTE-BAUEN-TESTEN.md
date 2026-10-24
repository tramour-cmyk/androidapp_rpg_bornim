# Bauen und Testen

Handwerk der Entwickler (`ROLLE-ENTWICKLUNG.md`) und Werkzeuge der Sitzung. „Handwerk“ lesen die Teams vor dem ersten Build ganz, den Rest bei Bedarf.

## Handwerk

### Prüftreppe (76e)

Jede Änderung auf der niedrigsten Stufe prüfen, die die Frage beantwortet; höher nur, wenn die Frage es verlangt.

1. **Logik** (Zeiten, Regeln, Abläufe): Kerntest, Sekunden. `./gradlew -p core test`, Ergebnis am Exit-Code prüfen (`set -o pipefail`), nicht nur an gefilterter Ausgabe.
2. **Sichtbar ohne Bewegung:** ein Standbild, nur der Ausschnitt (`CROP=`).
3. **Bewegung:** kurzer Film nur des Übergangs; ereignislose Zeit mit `FROM=` überspringen (`WALKFILM`, `IDLEFILM`, `FILM=`). Kampf, Bewegung, Effekte durch die echte Oberfläche filmen (`DESIGN-ABNAHME.md` „Selbst prüfen“).
4. **Fremde Prüfung vor jeder Vorlage an den Chef** (338.2, Chef 23.10., 09:23): ein Helfer, der nicht erstellt hat, mit Auftrag „Fehler finden“ und festen Fragen: Hand an der Waffe, Ausrichtung (Blatt, Spitze, Blick), Größe, Verdeckung, Text im Bild, gegen `DESIGN-STIL.md`. Jeder Negativbefund ist behoben oder steht in der Vorlage; zum Chef kommen nur Geschmacksfragen.
5. **Spielgefühl:** nur der Chef, mit guter Prüfliste.

**Kleine, sichere Schritte:** nach jedem fertigen Schritt Kerntests, Commit, Push auf den eigenen Zweig. App-Code: vor dem Push auch die Vorschau bauen (32.5). Befund mit Wirkung „hoch“ (Absturz, Festhängen, Quest unlösbar, falscher Text) behoben: einen Kerntest schreiben, der ihn künftig fängt (75h). Token sind knapp: Dateien gezielt lesen (`grep`, Marken, `sed -n`).

### Vor dem Bauen: Stil-Abgleich (88)

Jeder Vorschlag zu Grafik, Animation, Klang nennt kurz die berührten Punkte aus `DESIGN-STIL.md`, die entstehenden Übergänge (z. B. Stehen ↔ Hocken ↔ Gehen, Anführer dreht ↔ Rudel folgt) und wie sie geprüft werden; bei Spielablauf und Bedienung die vier Fragen „Spielerfreundlich, einfach, frei“ (33). In Stichworten in die Datei des Punkts in der Chefsache (sonst in den Commit).

### Test-Builds (78)

- **Zweig nach Inhalt** (`claude/tom-<thema>`, `claude/jerry-<thema>`) gleich beim Start, nie den Zufallsnamen der Umgebung.
- **Gemeinsamer Build** (317, ersetzt 99h.5 „getrennt“): ein Build bündelt 4–6 fertige Punkte **beider Teams** (Chef 24.10., 21:17: „nicht wieder … mit zwei Teilen bloß“); höchstens 6 Testbuilds am Tag für Tom und Jerry zusammen; unter 4 nur, wenn der älteste 2 Tage wartet (dann mindestens 3), unter 3 nur, wenn der Chef „jetzt“ sagt. Jedes Team baut auf eigenen Zweigen, je Punkt ein Commit, Stand „gebaut, fährt im nächsten Build“. Wer bei 4 fertigen Punkten (beider Teams) oder wenn der älteste 2 Tage wartet zuerst bittet, legt `claude/build-<n>` von `main` an, mischt alle fertigen Zweige beider Teams hinein, öffnet einen PR und schreibt die Prüfliste (je Punkt Team und Vorgang; ein Weg durchs Spiel in der Reihenfolge, in der der Chef auf die Punkte trifft); läuft schon ein offener Build ohne Test, kommt der Punkt dort hinein statt in einen neuen. **Hat der Chef einen Build getestet, ist er zu:** Nachträge kommen in einen neuen Build mit eigener Nummer und Prüfliste nur der neuen Punkte, auch wenn der getestete noch nicht auf `main` ist (Chef 22.10., 23:26; 324). Konflikt beim Mischen: der Besitzer des späteren Zweigs löst ihn. **Fällt ein Punkt durch, fliegt nur er per `git revert` heraus, der Rest geht auf `main`;** der Punkt geht als Rückläufer an sein Team.
- Gebaut wird nur bei PR, auf `main` oder per Knopfdruck (78d). Keine festen Testzeiten (78b).
- **Vor jedem Build `main` holen:** `git fetch origin main && git merge origin/main`, Kerntests, pushen.
- **Nummern nur aufsteigend** (Chef 14.10.): Android installiert keine niedrigere Version über eine höhere. Testbitte nur mit einem Build über der zuletzt getesteten Version (102); wird ein früher zu testender Build neu gebaut, die späteren danach neu bauen. Vor jedem Testangebot im Vorrat des anderen Teams nachsehen und dem Chef die Reihenfolge sagen.
- **Weckruf nach jedem Push, der baut:** PR abonnieren (`subscribe_pr_activity`) oder `send_later` (~6 Minuten). Nie „ich melde mich“ ohne Weckruf.
- **Zu jedem Build:** direkter Link (Release oder Artefakt), nie die APK im Chat, dazu eine **Prüfliste** in der Chefsache (`docs/chefsache/ansehen/t<build>-….md`), **nur, was ein Mensch sehen muss** (78c): Tabelle mit Testnummer (Build.Punkt), Vorgang (123), wo und wann, was tun, woran richtig, woran falsch; Überschrift „Build n · Version · Thema · PR“.
- **Nach „passt“ oder „freigegeben“ (235):** wer das Wort des Chefs hört, auch wenn der Build nicht seiner ist (meist Sokrates), führt den PR selbst zusammen, sobald er grün ist; bei Konflikt geht er ans Team zurück, das Team holt danach `main`. Sonst: PR selbst zusammenführen, sobald er grün ist (Merge, nie Squash/Rebase; 108a.1), Datei aus der Chefsache löschen, Ergebnis in `CHANGELOG.md`.

### Rückläufer (76f)

Fällt ein Punkt beim Chef durch, steht im `CHANGELOG.md`-Eintrag des späteren Erfolgs „(Rückläufer: n)“. Diogenes zählt sie einmal die Woche (Kennzahl der Entwickler).

### Nicht warten (54)

Ist der nächste Punkt freigegeben und nichts vom Chef zu entscheiden: sofort anfangen, ohne Ankündigung. Blockiert: aufschreiben, nächsten nehmen. „Leer“ erst nach Durchsicht aller eigenen Zeilen (auch Befunde) und `LISTE-ABNAHME-KAPITEL1.md` (81n). Der Stop-Haken `tools/weiter-haken.py` hält jedes Zugende einmal auf; nur „Vorrat leer“ oder „an den Nachfolger übergeben“ lässt sofort durch.

### Befunde von Diogenes (75g)

Jeder Befund ist ein **Verdacht**. Bei **Klasse 1** (Regelverstoß in deinem Bereich) prüfst du ohne Absegnen und vermerkst im Prüfbericht „bestätigt“ oder „verworfen“ mit Grund, hinter der Reihenfolge des Vorrats (nur Wirkung „hoch“ vor).

### Release

Nur auf Zuruf (`CLAUDE.md`); wann vorschlagen (65.6) und Ablauf: `LISTE-RELEASE-NEUSTART.md`.

## Werkzeuge

### Schnellprüfung

`tools/check-env.sh` (Programme, Repository, Netz, Sekunden); `--full` dazu Kerntests und ein Vorschaubild. Am Ende „Ergebnis: … in Ordnung, 0 fehlen.“ Die Umgebung bringt alles mit (JDK 21, ImageMagick, Python 3, git); ein Android-SDK ist nicht nötig, die APK baut GitHub Actions.

### Testen nach Anlass: `tools/t`

`tools/t` ohne Befehl zeigt die Übersicht. Grundsatz: das schnellste Werkzeug, das den Anlass abdeckt.

| Anlass | Befehl | Dauer (warm) |
|---|---|---|
| Regel, Wert, Ablauf | `tools/t logik [Muster]` (Kerntests) | 2–11 s |
| Bedienung, Spielfluss, Abstürze | `tools/t spieler [Eingaben]` (Zufallsspieler `PlayerSimTest`: tippt, redet, kauft, kämpft mit festem Seed; prüft Absturz, Hängen, Speichern/Laden) | 3–5 s |
| Aussehen, Kollision | `tools/t bild SCHALTER=…` | 5 s |
| Fluss einer Bewegung | `tools/t film FILM…=…` | Echtzeit |
| Umgebung in Ordnung? | `tools/t pruef` | ~10 s |

### Sitzungsstart

`.claude/settings.json` startet `tools/setup-session.sh --warm`: legt den Gradle-Spiegel (`tools/gradle-mirror.gradle`, Google-Spiegel statt Maven Central, das aus der Cloud oft 429 meldet) nach `~/.gradle/init.d` und übersetzt `core` im Hintergrund (`/tmp/bornim-warm.log`). **Kerntests mit `./gradlew -p core test`**, nicht `:core:test` (lädt das Android-Plugin). Spiegel aus dem Tritt: `tools/setup-session.sh` von Hand, dann `tools/t pruef`.

### Bauen (GitHub)

Workflow `.github/workflows/android.yml` („Build APK“, Version `0.1.<Laufnummer>`), nur bei PR, auf `main` und per Knopfdruck (78d); Änderungen nur an `docs/**`, `.md`, `tools/`, `.claude/` bauen nicht. APK aus einem Lauf: `gh api repos/tramour-cmyk/androidapp_rpg_bornim/actions/artifacts/<id>/zip > a.zip && unzip a.zip`. Release nur von Hand (`LISTE-RELEASE-NEUSTART.md`).

### Vorschau und Spiel

- Vorschau direkt: `cd tools/preview && SCHALTER=… ../../gradlew -q run`, Bilder unter `tools/preview/build/screens/`. Filmläufe sind langsam; Shell-Befehle brechen nach 10 Minuten ab, lange Läufe im Hintergrund mit `timeout`.
- **Im Spiel testen:** Testmodus (7× auf das Copyright im Hauptmenü tippen), Reiter „Test“: Stufe, Gold, Vorräte, Testkämpfe, „Kartenzoom“, „Monster beachten mich nicht“, „Sichtlinie aus“ u. a.

| Schalter | Wofür |
|---|---|
| `KARTENZOOM=1` (+ `ONLY=zoom_nah_…`, `DIAG=1`, `RAIN=1`, `ZOOMSTUFE=`) | Karte im echten Spiel: Wald, Dorf, Schänke (`i1`, `i2`), Ältester `e`, Laden `l`, Tempel `t`, Tag und Abend |
| `KARTENZOOM=1 HELDORT=ort:x:y:R:stunde` | Held an einem Ort zur Stunde (Tagesablauf der Bewohner, 5l) |
| `ISODINGE=1` / `=aeltester` / `=laden` / `=tempel` | Blatt aller Raum-Möbel diagonal, je drei Varianten |
| `FEUER=1` | alle Bilder des Kaminfeuers |
| `WALKFILM=karte:x:y` (+ `CROP=x0:y0:x1:y1`, `FROM=`), `IDLEFILM=` | Laufen bzw. Stehen durch die echte Oberfläche filmen |
| `FLORA=karte:x0:y0:breite:höhe` | Kartenausschnitt in voller Auflösung |
| `UNERKUNDET=1` (mit `KARTENZOOM=1 HELDORT=…`) | Rand der Sicht gegen das Schwarz (13e) |
| `KATZE=1`; `KATZEINN=<ms>` | Katze: Haltungen; in der Schänke zum Zeitpunkt ihrer Runde |
| `HUND=1`; `HUNDDORF=<ms>` (mit `KARTENZOOM=1`) | Dorfhund (D29.3): Haltungen; im Dorf zum Zeitpunkt seiner Runde |
| `SWINGBILD=1` (+ `SWINGMORE=1`, `SWINGWHO=…`) | Nachschwingen (17), auch Haare und Köcher |
| `FIREFLIES=1`, `SQUATDRAFT=1`, `MAPFIGYAWS=1 WEAPONS=…` | Glühwürmchen, Garrick hocken/schüren/dösen, Waffen in allen Richtungen |
| `MAPFOE=scene\|dirs\|walk\|yaws\|others\|cave\|wood`, `FOEFILM=1` (`FOEIDLE=1`) | Monster auf der Karte: Entwürfe, Film |
| `FILM=klasse:gegner FILMTAPS=…`, `FILMBATCH=datei FILMSTEP=40` | Kampffilme |
| `KAMPFORT=forest:7:14:8,12` | Kampfort aus der Karte (72u; Ort, Zoomstufen) |
| `SPRUNGBILD=` | Standbilder rund um eine Fundstelle des Sprungtests |
| `FOEANIM=`, `VERMINANIM=`, `CLASH=1`, `FOECLASH=1`, `ABILITYFX=1`, `STATUSFX=1` | Bewegungsblätter, Kollisionsprüfung, Effekte |
| `SOUNDS=NAME,…`, `KLANGPROBEN=…` | Hörproben |
| `SIM=1 ./gradlew -p core test --tests '*ChapterSimTest*'` | Kapitelsimulation (Balance) |

Kerntests mit eigenem Zweck: `JumpTest`/`BattleJumpTest` (Sprünge), `InnCornerTest`, `FireFlickerTest`, `HitWeightTest`, `MissStreakTest`, `RoamerTest`, `PlayerSimTest`.
