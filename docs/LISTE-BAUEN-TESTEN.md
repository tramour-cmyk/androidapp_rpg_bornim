# Bauen und Testen

Handwerk der Entwickler (`ROLLE-ENTWICKLUNG.md`) und Werkzeuge der Sitzung. „Handwerk“ lesen die Teams vor dem ersten Build ganz, den Rest bei Bedarf.

## Handwerk

### Prüftreppe (76e)

Jede Änderung auf der niedrigsten Stufe prüfen, die die Frage beantwortet; höher nur, wenn die Frage es verlangt.

1. **Logik** (Zeiten, Regeln, Abläufe): Kerntest = Godot-Logiksatz (`tools/t logik`, etwa 2 Minuten, mit Muster Sekunden; 882.2), Ergebnis am Exit-Code prüfen (`set -o pipefail`), nicht nur an gefilterter Ausgabe.
   Messungen mit Kaufmodellen (`wolf_mess_438`, `groesse_587` …) am Rechner statt auf dem Bauserver: `add_repo` bornim-kaufmodelle, Blender als Modul, dann `python3 tools/godot/bau_am_rechner.py --cache --laden` (854: holt die gebauten Modelle aus dem Kaufrepo, Zweig `bau/<Kennung>`, in unter einer Minute; nur wenn sich `tools/blender348`, die Bauschritte oder die Kaufdateien geändert haben: Laden 7 und Bau 39 Minuten, danach abgelegt; Ergebnis gleich dem Bauserver; 562, 854; bis zum Mischen auf `claude/jerry-854-kaufcache`).
2. **Sichtbar ohne Bewegung:** ein Standbild, nur der Ausschnitt (`CROP=`).
3. **Bewegung:** Film nach G4 (`DESIGN-ABNAHME.md`: nur der Prüfgegenstand, Länge, Kamera; `meldung.sh` hält über 20 s an); ereignislose Zeit mit `FROM=` überspringen (`WALKFILM`, `IDLEFILM`, `FILM=`). Filmzweig vorher mit `main` und dem laufenden `claude/build-<n>` zusammenführen, sonst sieht der Chef Behobenes wieder (758, 1039). Kampf, Bewegung, Effekte durch die echte Oberfläche filmen (`DESIGN-ABNAHME.md` „Selbst prüfen“). Dem Chef Bewegung nur als Film, nie als Bildfolge; Nachstellen am Rechner nur zur Ursache eines Fehlers, den der Chef gemeldet hat (646; `ROLLE-ENTWICKLUNG.md` „Zeigen statt messen“).
4. **Fremde Prüfung nur bei Text, vor dem Versand** (338.2, Chef 23.10., 09:23; 396a). Bild und Film sieht der Ersteller vor dem Senden selbst an und schickt sie dann sofort, ohne Helfer danach (655, Chef 08.11., 15:04; ersetzt 300); seine Fragen: zuerst „Was fällt einem Spieler im ganzen Bild als Erstes auf?“ (340.1), dann Hand an der Waffe, Ausrichtung (Blatt, Spitze, Blick), Größe, Verdeckung, Text im Bild; was er sieht, behebt er oder vermerkt es in der Vorlage, über die Wirkung urteilt nur der Chef. Text prüft vorher ein Helfer, der nicht erstellt hat, mit Auftrag „Fehler finden“. **Bewegung gleich als Film** (783 W1, Chef 09.11., 20:12; ersetzt 511, 511a, 578 und die Ausnahme 461a, 480): Animation, Ablauf, Kampf gehen ohne Probebild an den Chef. Vorher macht der Ersteller für sich ein Einzelbild am Rechner (`PROBEBILD=<Nr> <Befehl ohne Film>`, kein Probelauf) und sieht selbst nach, ob Inhalt da ist (kein Weißbild, richtiger Ort, Punkte mit „Prüfer: ja“ aus „Vor jeder Vorlage“, `DESIGN-ABNAHME.md`); kein Helfer, keine Freigabe. Aussehen eines Standes (Farbe, Form, Licht): Standbild als Vorlage, kein Film. Unklar: eine Zeile „Probebild oder gleich Film?“ in der Vorlage an den Chef. Die Zahl der Läufe begrenzt weiter 621 A (`probelauf.py`). Ein kaputter Film geht als eine Zeile an den Chef, zur Kenntnis, ohne Frage; als Film nur, wenn er ihn von sich aus sehen will (13:54); die Läufe zählen. Einen neuen Lauf über 621 A hinaus gibt Sokrates frei (Leitlinie 595); wer ihn braucht, fragt dafür nie den Chef, schreibt Sokrates in den Vorrat, keine Rückfrage an den Chef (Zusammenarbeit 8, 1200).
5. **Spielgefühl:** nur der Chef, mit guter Prüfliste.

**Kleine, sichere Schritte:** nach jedem fertigen Schritt Kerntests, Commit, Push auf den eigenen Zweig. Befund mit Wirkung „hoch“ (Absturz, Festhängen, Quest unlösbar, falscher Text) behoben: einen Kerntest schreiben, der ihn künftig fängt (75h). Token sind knapp: Dateien gezielt lesen (`grep`, Marken, `sed -n`).

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

`tools/check-env.sh` (Programme, Repository, Sekunden); `--full` dazu der Logiksatz. Am Ende „Ergebnis: … in Ordnung, 0 fehlen.“ Die Umgebung bringt alles mit (Godot wie `godot.yml`, ImageMagick, Python 3 mit yaml, git); ein Android-SDK ist nicht nötig, die APK baut GitHub Actions.

### Testen nach Anlass: `tools/t`

`tools/t` ohne Befehl zeigt die Übersicht. Grundsatz: das schnellste Werkzeug, das den Anlass abdeckt.

| Anlass | Befehl | Dauer |
|---|---|---|
| Regel, Wert, Ablauf, Bedienung | `tools/t logik [Muster]` (Godot-Logiksatz `godot/tests/logik.txt`: Tests aus `godot.yml` „Skripte pruefen“ ohne Kaufmodelle, Befehl und Kriterium von dort, 4 nebeneinander; rote einmal allein wiederholt, „WACKELIG“ heißt allein grün) | etwa 2 min, mit Muster Sekunden |
| Umgebung in Ordnung? | `tools/t pruef` | etwa 2 min |
| Messung mit Kaufmodellen | `tools/godot/bau_am_rechner.py` (Prüftreppe 1) | Minuten |
| Bild, Film | Zweig pushen, `godot.yml` (Prüftreppe 2, 3) | Minuten |

Neuer Godot-Test: sperrend in `godot.yml` „Skripte pruefen“; prüft er ohne Kaufmodelle in wenigen Sekunden, auch in `godot/tests/logik.txt`.

### Sitzungsstart

`.claude/settings.json` startet `tools/setup-session.sh --warm`: holt Godot, falls es fehlt (`~/godot/godot`, Fassung aus `godot.yml`), und bereitet im Hintergrund Daten und Import für `tools/t logik` vor (`/tmp/bornim-warm.log`). Solange `core/` da ist (bis 882.1, 870.10), legt es auch den Gradle-Spiegel für `wald_daten.sh` und `tools/pruef348/*.sh` an (Maven Central weist die Cloud mit 429 ab; 1207). Fehlt etwas: `tools/setup-session.sh` von Hand, dann `tools/t pruef`.

### Bauen (GitHub)

Die APK baut `godot.yml` (Punkt 4 in `LISTE-CHECK-BUILD-TEST.md`); der Kotlin-Bau `android.yml` ist mit 870.10 gestrichen. APK aus einem Lauf: `gh api repos/tramour-cmyk/androidapp_rpg_bornim/actions/artifacts/<id>/zip > a.zip && unzip a.zip`. Release nur von Hand (`LISTE-RELEASE-NEUSTART.md`).

### Vorschau und Spiel

- Alte Vorschau (`tools/preview`, Kotlin) gibt es hier nicht mehr (1279): Vergleichsbilder „alt“ mit `tools/alt_bilder.sh` aus dem Zweig `bilder`, Quelltext im Zweit-Repo `bornim-kaufmodelle` unter `kotlin-alt/` (Schalter und Kotlin-Tests: Git, Stand vor „1279“). Shell-Befehle brechen nach 10 Minuten ab, lange Läufe im Hintergrund mit `timeout`.
- **Im Spiel testen:** Testmodus (7× auf das Copyright im Hauptmenü tippen), Reiter „Test“: Stufe, Gold, Vorräte, Testkämpfe, „Kartenzoom“, „Monster beachten mich nicht“, „Sichtlinie aus“ u. a.
