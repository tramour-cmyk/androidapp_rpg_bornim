# Prüfen: Handwerk von Diogenes

Mechanik zu `ROLLE-PRUEFUNG.md`: wie geprüft wird, Klassen, Prüfbericht, Prüflisten je Bereich, Wochenzählung. Liest Diogenes beim Start den Abschnitt seines Auftrags; andere nur bei Anlass.

## Wochenzählung (QM, 106.1)

Montags ab 8 Uhr startet Ford Diogenes mit „Wochenzählung“ (Zeile in `ARBEIT-PRUEFUNG.md`); danach setzt Perikles das Wochenziel und bewertet die Zahlen. Diogenes zählt nur, er bewertet nicht. Fehlt eine Zahl, steht „fehlt“ (D18.5). Ergebnis als Tabelle oben im Prüfbericht, eine Spalte je Woche; Ausgangswert ist die Woche 18.–24.10. (Zielwerte setzt Perikles danach, D19.4).

| Kennzahl | Quelle |
|---|---|
| **Kosten der Woche** je Hauptthema (E, G, Q, B, M); Anteil Muss | Spalten „Bereich“, „Klasse“, „Kosten“ in `LISTE-VORGAENGE.md` (Differenz zur Vorwoche); **Anteil Spiel** (Tom, Jerry, Homer durch alle) aus `cost_usd` mit `tools/kosten.py`, Definition in `ROLLE-PROJEKT.md` (167.4) |
| **Guthaben:** Verbrauch je Account gegen die Woche | Zeilen „Guthaben:“ in `ARBEIT-BETRIEB.md` |
| **Fortschritt Meilenstein:** Wochenziel erreicht, Pflichtpunkte Kapitel 1 offen | `LISTE-ABNAHME-KAPITEL1.md` |
| **Testrunden des Chefs** und Rückläufer darunter (Entwickler) | `CHANGELOG.md` „(Rückläufer: n)“, gelöschte Dateien in `docs/chefsache/ansehen/` (`git log`) |
| **Ersparte Fragen** durch Vorentscheid (unter 5 je Woche fällt der Vorentscheid weg, 98.2) | Einträge „Vorentscheid“ in `VORGANGSARCHIV.md` |
| **Stillstand** in Stunden je Ursache (Ford) | Zeilen „Stillstand“ im Protokoll von `ARBEIT-BETRIEB.md` |
| **Zeilen „von Team …“ an Homer älter als 1 Tag** | `ARBEIT-KREATIV.md` |
| **Empfehlungen von Sokrates**, die nach einer Woche noch gelten | `VORGANGSARCHIV.md` |
| **Verwerfquote** und Fehler, die erst der Chef am Gerät fand (Diogenes selbst) | Prüfbericht, Rückläufer |


## Wie du prüfst

(1) **Blind zuerst:** gegen die Regeln (`DESIGN-LEITBILD.md`, `DESIGN-STIL.md`, „Ort fertig“ in `DESIGN-ABNAHME.md`, `STORY-…`, `DESIGN-BALANCE.md`, `VORGANGSARCHIV.md`), nicht gegen Übergaben; erst danach nachsehen, ob etwas Absicht ist. (2) **Wie ein Spieler, der nichts weiß:** findet man Ziel, Eingang, Händler nur mit dem, was das Spiel zeigt und sagt? Was, wenn er die Reihenfolge ändert, trödelt, nachts kommt, flieht, speichert und lädt? (3) **Wie einer, der es brechen will:** Ränder (wenig Trefferpunkte, volles Gepäck, Englisch, kleiner Bildschirm, jeder Schwierigkeitsgrad), Zufallsspieler mit mehreren Startwerten. (4) **Erst widerlegen, dann melden:** jeden Verdacht mit Code, zweitem Standbild oder Test zu entkräften versuchen; was übrig bleibt, meldest du. Standbilder kosten viel: erst Code und Tests, Bilder gezielt.

**Was ein Befund braucht:** Beleg (Datei und Zeile, Standbild mit Uhrzeit, Testausgabe oder Startwert); verletzte Regel mit Fundstelle; Wirkung auf den Spieler (hoch: Absturz, Festhängen, Quest unlösbar, falscher Text; mittel: sichtbar falsch; klein: Feinschliff); Sicherheit (sicher, wahrscheinlich, Verdacht); **Klasse**. Ohne Regel ist es eine Anregung, höchstens drei je Lauf. Gut: „D2.3 (13e, hoch, sicher): Zufallsspieler mit Startwert 4711 hängt in der Höhle auf Feld 12:7 fest, `CaveMap.kt:212`; verletzt ‚Ort fertig‘ 5. Klasse 1, Tom.“ Schlecht: „Die Höhle wirkt etwas leer.“

## Kosten und Nutzen (75h–75l, Chef 13.10., 20:51)

So viel prüfen wie nötig, so wenig wie möglich. Prüftiefe nach Risiko (Wahrscheinlichkeit mal Schaden): frisch Geändertes, Stellen beider Teams, große Umbauten, Speichern/Laden, Questsperren zuerst; Unverändertes und reine Optik zuletzt. Billigster passender Weg zuerst: Kerntests und Zufallsspieler, Texte mit `tools/story.sh`, Code lesen, erst dann Standbilder.
- **Budget je Lauf** (75j): höchstens 10 Standbilder, kein Film. Erreicht: aufhören, Abdeckung melden.
- **Kosten messen** (75k): am Ende im Prüfbericht Tokenzuwachs des Laufs (Meldung des Neustart-Hakens) und Zahl der bestätigten Befunde; Perikles wertet aus (Wochenzählung).
- **Kerntest statt Wiederholung** (75h): bestätigte Befunde „hoch“ prüfst du nach dem Beheben nur über den Kerntest, den das Team dazu schreibt.

## Klassen: wer liest, wer handelt (75g)

- **Klasse 1, Regelverstoß in einem Bereich:** du nennst das zuständige Team nach den Grenzen in `CLAUDE.md` und trägst eine Zeile mit den Befundnummern in dessen Vorrat. Das Team prüft und vermerkt im Prüfbericht „bestätigt“ oder „verworfen“ mit Grund; reiht sich hinter die Reihenfolge des Vorrats, nur Wirkung „hoch“ geht vor.
- **Klasse 2, grundsätzlich oder Ermessen** (Gestaltung, Spielgefühl, beide Teams, fragwürdige Regel): nur Vorschlag, eine Zeile mit Befundnummern im Vorrat von Homer (Spiel) oder Perikles (Abläufe); der Chef entscheidet, Homer oder Perikles nehmen auf seinen Zuruf Stellung (D21.1).
- **Klasse 3, am Gerät ansehen:** Datei in der Chefsache (`docs/chefsache/ansehen/`).

## Prüfbericht (`docs/PRUEFBERICHT.md`)

Eine Datei auf `main` (99g, seit 16.10.; Lauf 1–21 im abgelösten Artefakt), bearbeiten und pushen wie jede Notiz. Befunde stehen nur hier; im Chat nur Nummern.
- **Oben: nur Offenes**, je Lauf: (a) Geprüft: Bereich, Liste, Stand, Uhrzeit, **nicht Geprüftes mit Grund**; (b) Befunde `D<Lauf>.<n>` mit Vorgang, Wirkung, Sicherheit, Klasse, Beleg, Regel; Platz für den Vermerk des Teams; (c) **Offen für den Chef** (Klasse 3) ganz oben in der Datei, nummeriert.
- **Ausmisten:** ein Lauf, dessen Befunde alle einen Vermerk haben und nichts Offenes mehr tragen, wandert beim nächsten Lauf oben ins `PRUEFBERICHT-ARCHIV.md` (samt Kostenzeile; beim Start nicht lesen); unten „Kosten“ je Lauf. Datei höchstens etwa 30 KB.

## Prüflisten je Bereich

Wiederholbar statt nach Gefühl; du pflegst sie (neue Punkte mit Datum). Grundlage „Ort fertig“ in `DESIGN-ABNAHME.md`.

- **Jeder Ort:** Punkte aus „Ort fertig“; Leute, Questziele, Eingänge frei zur Kamera (43); Zufallsspieler ohne Absturz und ohne Festhängen (Kerntest); Standbild Tag und Nacht.
- **Jede Oberfläche (60):** neues Aussehen (schwarz, Gold, Serife, keine hellen Tafeln), Farben auf Schwarz lesbar, nichts bricht um oder läuft über, Deutsch und Englisch vollständig.
- **Texte (41):** Spieltexte gleich den Teildateien `docs/STORY-*.md` (Verzeichnis `STORY-REGELN.md`, Änderungen `tools/story.sh <Stand>`), keine fehlenden Übersetzungen, generisches Maskulinum.
- **Balance (38):** Kerntest-Messungen in den Zielen aus `DESIGN-BALANCE.md`.
- **Abläufe (Revisor):** Schlüssigkeit, Risiken, Übersehenes; jede Übernahme gegen die alte Fassung (schon da, präziser, gebraucht).
- **Bestandsprüfung (71, Chef 13.10.):** alle Orte auf aktuellem `main`, auch ohne Änderung. Drei Teile, je ein Lauf: **A** Gebiete Dorf, Wald, Tiefer Wald; **B** Grundrisse Schänke, Laden, Ältestenhaus, Tempel, Höhle; **C** Oberflächen (Menü, Laden, Karte, nach „Jede Oberfläche“). Je Ort:
  1. **Bestandsliste aus dem Code:** jedes Ding eine Zeile (Bäume, Felsen, Büsche, Häuser, Zäune, Möbel, Kleinkram, Wasser, Ufer, Boden, Wege): diagonal mit Volumen gezeichnet (`Sculpt`/SDF) oder noch flach bzw. alte Ansicht gekippt; Zahl der Varianten (Ziel ≥ 3); Schatten; Maßstab zum Helden.
  2. **Standbilder** aus Sicht des Helden, Tag und Nacht, je Ort mindestens Eingang, Mitte, Questort: gegen „Ort fertig“ 1–10 und `DESIGN-STIL.md` „Karte und Räume“ (nichts flach, Wichtiges frei, Durchsicht um den Helden, Ellipsen 2:1, Licht nur aus Quellen, nachts lesbar).
  3. **Abwechslung und Leben:** gleiche Dinge nebeneinander verschieden, keine sichtbaren Wiederholungsmuster oder Raster; Rauch, Wind, Tiere, Gebrauchsspuren je Ort vorhanden.
  4. **Klang je Quelle:** jedes sichtbare Ding und jede Figur, die in Wirklichkeit klingt (Feuer, Wasser, Tiere, Wind in Bäumen, Tür, Arbeit der Leute), eine Zeile: Klang ja/nein, echte Aufnahme, ≥ 3 Varianten, **entfernungsabhängig** (nah laut, fern leise, ab Hörweite stumm, ohne Sprung; Werte in Feldern aus dem Code, Lautstärke bei 0 Feldern, halber Hörweite, außerhalb nachrechnen). Vorbild Feuer (`Ambience`) und Teich (`PondSound`). Dazu Schritte je Untergrund, Ortsklang nur von dem, was da ist.
  5. Punkte aus „Jeder Ort“ (Kollision, Tippen, Zufallsspieler).
  Bericht je Ort als Tabelle (Ding | diagonal | Varianten | Schatten | Klang | Entfernung), Lücken als Befunde mit Empfehlung (Tom: Dorf, Leute, Innenräume; Jerry: Höhle, Monster, Klang). Fehlende Klänge als Vorschlagsliste, nichts bauen.
- **Werkzeug (13.10.):** Bestand aus dem Code am schnellsten mit drei Explore-Agenten parallel (Möbel, Höhle, Klang). Standbilder: `tools/t bild KARTENZOOM=1 ONLY=zoom_nah_p_ "HELDORT=ort:x:y:U:12;…:22"`, erster Lauf kalt über 10 Minuten, also im Hintergrund starten.
