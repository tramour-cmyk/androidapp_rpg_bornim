# Prüfen: Handwerk von Diogenes

Mechanik zu `ROLLE-PRUEFUNG.md`: wie geprüft wird, Klassen, Prüfbericht, Prüflisten je Bereich, Wochenzählung. Liest Diogenes beim Start den Abschnitt seines Auftrags; andere nur bei Anlass.

## Wochenzählung (QM, 106.1)

Montags ab 8 Uhr legt `startbar.py` den Vorgang „Wochentermin TT.MM.: Wochenzählung“ bei Diogenes an, Ford startet ihn (719 A); danach setzt Perikles das Wochenziel und bewertet die Zahlen. Diogenes zählt nur, er bewertet nicht. Fehlt eine Zahl, steht „fehlt“ (D18.5). Ergebnis als Tabelle oben im Prüfbericht, eine Spalte je Woche; Ausgangswert ist die Woche 18.–24.10. (Zielwerte setzt Perikles danach, D19.4).

| Kennzahl | Quelle |
|---|---|
| **Kosten der Woche** je Hauptthema (E, G, Q, B, M); Anteil Muss | Spalten „Bereich“, „Klasse“, „Kosten“ in `LISTE-VORGAENGE.md` (Differenz zur Vorwoche); **Anteil Spiel** (Tom, Jerry, Homer durch alle) aus `cost_usd` mit `tools/kosten.py`, Definition in `ROLLE-PROJEKT.md` (167.4) |
| **Guthaben:** Verbrauch je Account gegen die Woche | Zeilen „Guthaben:“ in `ARBEIT-BETRIEB.md` |
| **Fortschritt Meilenstein:** Wochenziel erreicht; Abnahmeliste „ganze Punkte x von 41“ und daneben die Teilhaken je Punkt („2.13: 6 von 19“, 720 A) | `PROJEKTPLAN.md`, `DESIGN-ABNAHME.md` |
| **Testrunden des Chefs** | gelöschte Dateien in `docs/chefsache/ansehen/` (`git log`) |
| **Ersparte Fragen** durch Vorentscheid (unter 5 je Woche fällt der Vorentscheid weg, 98.2) | Einträge „Vorentscheid“ in `VORGANGSARCHIV.md` |
| **Zielvereinbarung 341 je Rolle:** „x von n erfüllt“, je Ziel die Zahl | unten |

### Zielvereinbarung 341 (alle Rollen; Chef 23.10., 09:53, Probe Perikles bestanden 07.11.; ersetzt „je Rolle eine Kennzahl“)

Je Rolle höchstens drei Ziele: **Z3** und **Z4** für alle, **Ze** eigen (Tabelle unter „Dein Maß“ der Rollendatei); Perikles behält Z1–Z6 der Probe (Maß und Quelle nur in `ROLLE-PROJEKT.md` „Dein Maß“). Gezählt ab der Woche 09.–15.11.; Zielwerte, wo keiner steht, setzt Perikles (D19.4).
- **Z3 Fehlerfrei:** 0 Fehler je Woche, die der Chef als Erster in der Arbeit der Rolle findet. Was der Chef „Fehler“ nennt, trägt die Rolle sofort mit Uhrzeit als Zeile „Fehler 341“ in ihren Vorrat; die Teams zählen stattdessen Rückläufer (`CHANGELOG.md`), Diogenes Fehler, die ein Lauf hätte finden können. Fehlt eine Zeile, die du im Chat oder Telegram findest, zählst du sie mit (Haltung 7).
- **Z4 Eigene Verbesserung:** mindestens 1 eigener Vorschlag je Woche mit Wirkung, Kosten, Gegenargument, vom Chef mit „ja“ oder „ja, aber“ angenommen (neue Chefsache-Datei laut `git log --diff-filter=A`, Wort im Vorgangsarchiv; gebilligter Vorentscheid zählt).
- **Folge:** zwei Wochen hintereinander dasselbe Ziel verfehlt → Sokrates legt dem Chef eine Vorlage vor (Rolle, Modell oder Ziel ändern); für Sokrates selbst Perikles.
- Diogenes zählt, Perikles meldet montags mit dem Wochenziel eine Zeile je Rolle, unverändert mit Link.


## Wie du prüfst

(1) **Blind zuerst:** gegen die Regeln (`DESIGN-LEITBILD.md`, `DESIGN-STIL.md`, „Ort fertig“ in `DESIGN-ABNAHME.md`, `STORY-…`, `DESIGN-BRS.md`, `VORGANGSARCHIV.md`), nicht gegen Übergaben; erst danach nachsehen, ob etwas Absicht ist. (2) **Wie ein Spieler, der nichts weiß:** findet man Ziel, Eingang, Händler nur mit dem, was das Spiel zeigt und sagt? Was, wenn er die Reihenfolge ändert, trödelt, nachts kommt, flieht, speichert und lädt? (3) **Wie einer, der es brechen will:** Ränder (wenig Trefferpunkte, volles Gepäck, Englisch, kleiner Bildschirm, jeder Schwierigkeitsgrad), Zufallsspieler mit mehreren Startwerten. (4) **Erst widerlegen, dann melden:** jeden Verdacht mit Code, zweitem Standbild oder Test zu entkräften versuchen; was übrig bleibt, meldest du. Standbilder kosten viel: erst Code und Tests, Bilder gezielt.

**Was ein Befund braucht:** Beleg (Datei und Zeile, Standbild mit Uhrzeit, Testausgabe oder Startwert); verletzte Regel mit Fundstelle; Wirkung auf den Spieler (hoch: Absturz, Festhängen, Quest unlösbar, falscher Text; mittel: sichtbar falsch; klein: Feinschliff); Sicherheit (sicher, wahrscheinlich, Verdacht); **Klasse**. Ohne Regel ist es eine Anregung, höchstens drei je Lauf. Gut: „D2.3 (13e, hoch, sicher): Zufallsspieler mit Startwert 4711 hängt in der Höhle auf Feld 12:7 fest, `CaveMap.kt:212`; verletzt ‚Ort fertig‘ 5. Klasse 1, Tom.“ Schlecht: „Die Höhle wirkt etwas leer.“

## Kosten und Nutzen (75h–75l, Chef 13.10., 20:51)

So viel prüfen wie nötig, so wenig wie möglich. Prüftiefe nach Risiko (Wahrscheinlichkeit mal Schaden): frisch Geändertes, Stellen beider Teams, große Umbauten, Speichern/Laden, Questsperren zuerst; Unverändertes und reine Optik zuletzt. Billigster passender Weg zuerst: Kerntests und Zufallsspieler, Texte mit `tools/story.sh`, Code lesen, erst dann Standbilder.
- **Budget je Lauf** (75j): höchstens 10 Standbilder, kein Film. Erreicht: aufhören, Abdeckung melden.
- **Kosten messen** (75k): am Ende im Prüfbericht Tokenzuwachs des Laufs (Meldung des Neustart-Hakens) und Zahl der bestätigten Befunde; Perikles wertet aus (Wochenzählung).
- **Kerntest statt Wiederholung** (75h): bestätigte Befunde „hoch“ prüfst du nach dem Beheben nur über den Kerntest, den das Team dazu schreibt.

## Klassen: wer liest, wer handelt (75g)

Klasse 1 und 2: je Befund ein Vorgang beim Besitzer (`ROLLE-PRUEFUNG.md` „Wen du ansprichst“, 722 A).
- **Klasse 1, Regelverstoß in einem Bereich:** Besitzer ist das zuständige Team nach den Grenzen in `CLAUDE.md`; nur Wirkung „hoch“ geht im Vorrang vor.
- **Klasse 2, grundsätzlich oder Ermessen** (Gestaltung, Spielgefühl, beide Teams, fragwürdige Regel): nur Vorschlag, Besitzer Homer (Spiel) oder Perikles (Abläufe); der Chef entscheidet.
- **Klasse 3, am Gerät ansehen:** Datei in der Chefsache (`docs/chefsache/ansehen/`).

## Prüfbericht (`docs/PRUEFBERICHT.md`)

Eine Datei auf `main` (99g, seit 16.10.; Lauf 1–21 im abgelösten Artefakt), bearbeiten und pushen wie jede Notiz. Befunde stehen nur hier; im Chat nur Nummern.
- **Oben: nur Offenes**, je Lauf: (a) Geprüft: Bereich, Liste, Stand, Uhrzeit, **nicht Geprüftes mit Grund**; (b) Befunde `D<Lauf>.<n>` mit Vorgang, Wirkung, Sicherheit, Klasse, Beleg, Regel; den Stand trägt der Befundvorgang (722 A); (c) **Offen für den Chef** (Klasse 3) ganz oben in der Datei, nummeriert.
- **Ausmisten:** ein Lauf, dessen Befunde alle einen Vermerk haben und nichts Offenes mehr tragen, wandert beim nächsten Lauf oben ins `PRUEFBERICHT-ARCHIV.md` (samt Kostenzeile; beim Start nicht lesen); unten „Kosten“ je Lauf. Datei höchstens etwa 30 KB.

## Prüflisten je Bereich

Wiederholbar statt nach Gefühl; du pflegst sie (neue Punkte mit Datum). Grundlage „Ort fertig“ in `DESIGN-ABNAHME.md`.

- **Jeder Ort:** Punkte aus „Ort fertig“; Leute, Questziele, Eingänge frei zur Kamera (43); Zufallsspieler ohne Absturz und ohne Festhängen (Kerntest); Standbild Tag und Nacht.
- **Jede Oberfläche (60):** neues Aussehen (schwarz, Gold, Serife, keine hellen Tafeln); Menüs, Schirme und Fenster nach `DESIGN-STIL.md` „Fenster und Schirme ohne Kasten“ (549a: Aufbau, Ausrichtung, Knöpfe, Schrift, Farben, Prüfpunkte dort), Farben auf Schwarz lesbar, nichts bricht um oder läuft über, Deutsch und Englisch vollständig.
- **Texte (41):** Spieltexte gleich den Teildateien `docs/STORY-*.md` (Verzeichnis `STORY-REGELN.md`, Änderungen `tools/story.sh <Stand>`), keine fehlenden Übersetzungen, generisches Maskulinum.
- **Balance (38):** Kerntest-Messungen in den Zielen aus `DESIGN-BRS.md` (Zahlen nach 444; alte Zielkurve `alt/DESIGN-BALANCE.md`, 650.2).
- **Abläufe (Revisor):** Schlüssigkeit, Risiken, Übersehenes; jede Übernahme gegen die alte Fassung (schon da, präziser, gebraucht).
- **Bestandsprüfung (71, Chef 13.10.):** alle Orte auf aktuellem `main`, auch ohne Änderung. Drei Teile, je ein Lauf: **A** Gebiete Dorf, Wald, Tiefer Wald; **B** Grundrisse Schänke, Laden, Ältestenhaus, Tempel, Höhle; **C** Oberflächen (Menü, Laden, Karte, nach „Jede Oberfläche“). Je Ort:
  1. **Bestandsliste aus dem Code:** jedes Ding eine Zeile (Bäume, Felsen, Büsche, Häuser, Zäune, Möbel, Kleinkram, Wasser, Ufer, Boden, Wege): diagonal mit Volumen gezeichnet (`Sculpt`/SDF) oder noch flach bzw. alte Ansicht gekippt; Zahl der Varianten (Ziel ≥ 3); Schatten; Maßstab zum Helden.
  2. **Standbilder** aus Sicht des Helden, Tag und Nacht, je Ort mindestens Eingang, Mitte, Questort: gegen „Ort fertig“ 1–10 und `DESIGN-STIL.md` „Karte und Räume“ (nichts flach, Wichtiges frei, Durchsicht um den Helden, Ellipsen 2:1, Licht nur aus Quellen, nachts lesbar).
  3. **Abwechslung und Leben:** gleiche Dinge nebeneinander verschieden, keine sichtbaren Wiederholungsmuster oder Raster; Rauch, Wind, Tiere, Gebrauchsspuren je Ort vorhanden.
  4. **Klang je Quelle:** jedes sichtbare Ding und jede Figur, die in Wirklichkeit klingt (Feuer, Wasser, Tiere, Wind in Bäumen, Tür, Arbeit der Leute), eine Zeile: Klang ja/nein, echte Aufnahme, ≥ 3 Varianten, **entfernungsabhängig** (nah laut, fern leise, ab Hörweite stumm, ohne Sprung; Werte in Feldern aus dem Code, Lautstärke bei 0 Feldern, halber Hörweite, außerhalb nachrechnen). Vorbild Feuer (`Ambience`) und Teich (`PondSound`). Dazu Schritte je Untergrund, Ortsklang nur von dem, was da ist.
  5. Punkte aus „Jeder Ort“ (Kollision, Tippen, Zufallsspieler).
  Bericht je Ort als Tabelle (Ding | diagonal | Varianten | Schatten | Klang | Entfernung), Lücken als Befunde mit Empfehlung (Tom: Dorf, Leute, Innenräume; Jerry: Höhle, Monster, Klang). Fehlende Klänge als Vorschlagsliste, nichts bauen.
- **Werkzeug (13.10.):** Bestand aus dem Code am schnellsten mit drei Explore-Agenten parallel (Möbel, Höhle, Klang). Standbilder: `tools/t bild KARTENZOOM=1 ONLY=zoom_nah_p_ "HELDORT=ort:x:y:U:12;…:22"`, erster Lauf kalt über 10 Minuten, also im Hintergrund starten.
