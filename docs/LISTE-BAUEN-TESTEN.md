# Bauen und Testen

Handwerk der Entwickler (`ROLLE-ENTWICKLUNG.md`) und Werkzeuge der Sitzung. „Handwerk“ lesen die Teams vor dem ersten Build ganz, den Rest bei Bedarf.

## Handwerk

### Prüftreppe (76e)

Jede Änderung auf der niedrigsten Stufe prüfen, die die Frage beantwortet; höher nur, wenn die Frage es verlangt.

1. **Logik** (Zeiten, Regeln, Abläufe): Kerntest, Sekunden. `./gradlew -p core test`, Ergebnis am Exit-Code prüfen (`set -o pipefail`), nicht nur an gefilterter Ausgabe.
   Messungen mit Kaufmodellen (`wolf_mess_438`, `groesse_587` …) am Rechner statt auf dem Bauserver: `add_repo` bornim-kaufmodelle, Blender als Modul, dann `python3 tools/godot/bau_am_rechner.py --cache --laden` (854: holt die gebauten Modelle aus dem Kaufrepo, Zweig `bau/<Kennung>`, in unter einer Minute; nur wenn sich `tools/blender348`, die Bauschritte oder die Kaufdateien geändert haben: Laden 7 und Bau 39 Minuten, danach abgelegt; Ergebnis gleich dem Bauserver; 562, 854; bis zum Mischen auf `claude/jerry-854-kaufcache`).
2. **Sichtbar ohne Bewegung:** ein Standbild, nur der Ausschnitt (`CROP=`).
3. **Bewegung:** kurzer Film nur des Übergangs; ereignislose Zeit mit `FROM=` überspringen (`WALKFILM`, `IDLEFILM`, `FILM=`). Kampf, Bewegung, Effekte durch die echte Oberfläche filmen (`DESIGN-ABNAHME.md` „Selbst prüfen“). Dem Chef Bewegung nur als Film, nie als Bildfolge; Nachstellen am Rechner nur zur Ursache eines Fehlers, den der Chef gemeldet hat (646; `ROLLE-ENTWICKLUNG.md` „Zeigen statt messen“).
4. **Fremde Prüfung nur bei Text, vor dem Versand** (338.2, Chef 23.10., 09:23; 396a). Bild und Film sieht der Ersteller vor dem Senden selbst an und schickt sie dann sofort, ohne Helfer danach (655, Chef 08.11., 15:04; ersetzt 300); seine Fragen: zuerst „Was fällt einem Spieler im ganzen Bild als Erstes auf?“ (340.1), dann Hand an der Waffe, Ausrichtung (Blatt, Spitze, Blick), Größe, Verdeckung, Text im Bild; was er sieht, behebt er oder vermerkt es in der Vorlage, über die Wirkung urteilt nur der Chef. Text prüft vorher ein Helfer, der nicht erstellt hat, mit Auftrag „Fehler finden“. **Bewegung gleich als Film** (783 W1, Chef 09.11., 20:12; ersetzt 511, 511a, 578 und die Ausnahme 461a, 480): Animation, Ablauf, Kampf gehen ohne Probebild an den Chef. Vorher macht der Ersteller für sich ein Einzelbild am Rechner (`PROBEBILD=<Nr> <Befehl ohne Film>`, kein Probelauf) und sieht selbst nach, ob Inhalt da ist (kein Weißbild, richtiger Ort, Punkte mit „Prüfer: ja“ aus „Vor jeder Vorlage“, `DESIGN-ABNAHME.md`); kein Helfer, keine Freigabe. Aussehen eines Standes (Farbe, Form, Licht): Standbild als Vorlage, kein Film. Unklar: eine Zeile „Probebild oder gleich Film?“ in der Vorlage an den Chef. Die Zahl der Läufe begrenzt weiter 621 A (`probelauf.py`). Ein kaputter Film geht als eine Zeile an den Chef, als Film nur auf sein Wort (13:54); die Läufe zählen.
5. **Spielgefühl:** nur der Chef, mit guter Prüfliste.

**Kleine, sichere Schritte:** nach jedem fertigen Schritt Kerntests, Commit, Push auf den eigenen Zweig. App-Code: vor dem Push auch die Vorschau bauen (32.5). Befund mit Wirkung „hoch“ (Absturz, Festhängen, Quest unlösbar, falscher Text) behoben: einen Kerntest schreiben, der ihn künftig fängt (75h). Token sind knapp: Dateien gezielt lesen (`grep`, Marken, `sed -n`).

### Vor dem Bauen: Stil-Abgleich (88)

Jeder Vorschlag zu Grafik, Animation, Klang nennt kurz die berührten Punkte aus `DESIGN-STIL.md`, die entstehenden Übergänge (z. B. Stehen ↔ Hocken ↔ Gehen, Anführer dreht ↔ Rudel folgt) und wie sie geprüft werden; bei Spielablauf und Bedienung die vier Fragen „Spielerfreundlich, einfach, frei“ (33). In Stichworten in die Datei des Punkts in der Chefsache (sonst in den Commit).

### Test-Builds (78)

Alle Regeln zu Zweig, gemeinsamem Build, Prüfliste und Zusammenführen stehen seit 657 D nur in `LISTE-CHECK-BUILD-TEST.md`.

### Rückläufer (76f)

Fällt ein Punkt beim Chef durch, steht im `CHANGELOG.md`-Eintrag des späteren Erfolgs „(Rückläufer: n)“. Diogenes zählt sie einmal die Woche (Kennzahl der Entwickler). **Wiederholt** (620.1 A, Chef 07.11., 21:00): meldet der Chef einen Fund zum zweiten Mal, setzt wer ihn einträgt das Wort „wiederholt“ in den Titel der Zeile (der Stand bleibt, wie er ist); `startbar.py` und `lauf.py` stellen sie vor jedes andere Muss, nur „jetzt“-Zeilen oben bleiben davor. **Grenze und Sperre** (620.1 B, 779): `LISTE-CHECK-BUILD-TEST.md` 3.

### Nicht warten (54)

Ist der nächste Punkt freigegeben und nichts vom Chef zu entscheiden: sofort anfangen, ohne Ankündigung. Blockiert: aufschreiben, nächsten nehmen. „Leer“ erst nach Durchsicht aller eigenen Zeilen (auch Befunde) und `PROJEKTPLAN.md` (81n). Der Stop-Haken `tools/weiter-haken.py` hält jedes Zugende einmal auf; nur „Vorrat leer“ oder „an den Nachfolger übergeben“ lässt sofort durch.

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
| `ISODINGE=1` / `=aeltester` / `=laden` / `=tempel` | Bild aller Raum-Möbel diagonal, je drei Varianten |
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
