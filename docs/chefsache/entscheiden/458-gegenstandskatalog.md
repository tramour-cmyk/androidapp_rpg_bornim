# 458 · Ein Katalog aller Gegenstände für Spielsystem 2.0
Sokrates · 01.11., 13:1x · D Design

**Frage:** Legen wir einen Katalog aller Gegenstände an (Ausrüstung, Tränke, Rohstoffe, Werkzeug): eine Datendatei, aus der das Spiel liest und aus der ein Werkzeug die Übersicht `LISTE-GEGENSTAENDE.md` erzeugt? (Chef 01.11., 13:0x: „Gibt es da eine Übersicht? Was wir … in den Läden anbieten oder was wir … als sammelbar haben … Brauchen wir das noch? Wo kann da wer nachgucken? Wissen alle Bescheid?“)
**Votum Sokrates:** ja, als Teil von Stufe 3 (447), vor dem Bau von Herstellen, Abnutzung und Ruf-Preisen.
**Berührt:** Tom (Laden, Netze 455.2), Jerry (Beute, Werte 444), Homer (Namen, Texte), Perikles (Werkzeug), Bestiarium (Beute je Monster).

## Sachverhalt (nachgesehen 01.11.)

- **Was das Spiel heute kennt:** 46 Grundgegenstände aus der alten Fassung (`core/…/Gear.kt`, nach Godot als `held.json` ausgelesen): 21 Waffen (Dolch bis Zweihänder, Kurz- und Langbogen, Armbrust, Stäbe), 25 Rüstungsteile (Kopf, Oberkörper, Arme, Beine, Umhang), dazu Schilde, 2 Amulette, 2 Ringe; je sechs Seltenheiten mit zufälligen Zusätzen (wie Diablo); Tränke in `Items.kt` (Heiltrank klein bis überragend, Kräutertrank, Ausdauertrank u. a.). Werte und Preise nach dem alten SRD-System.
- **Woher die Modelle:** gekauft oder CC0 im Kaufrepo, Liste `LISTE-BESTAND.md` „Dinge, Möbel, Waffen“: rund 110 Waffen- und Schildmodelle (Omie 20, gekauft 1,99 $; Anker 62, Avramania 19, PolyMech 9 Schilde, alle CC0), Trachten von Quaternius (376.1, 455). Welcher Gegenstand welches Modell trägt, steht nirgends; das legt 455.2 je Platz an.
- **Was fehlt:** eine Übersicht, die alles zusammenführt. Heute steht ein Gegenstand an bis zu fünf Orten: Werte im Code, Modell in der Bestandsliste, Beute im Bestiarium, Ware im Laden-Skript, Text in den Spieltexten. Niemand sieht auf einen Blick, was es gibt, wo man es bekommt und wie es aussieht. Für Spielsystem 2.0 kommen Rohstoffe, Rezepte, Werkorte und Zustand dazu (Nachschlagewerk 10, 11), und die alten Werte gelten nicht mehr.

## Vorschlag

1. **Eine Datendatei** `daten/gegenstaende.json` (wie 418: jede Zahl aus einer Datendatei), je Gegenstand: Name DE/EN, Art (Waffe, Rüstung, Trank, Rohstoff, Werkzeug, Schmuck), Platz, Stufe, Preis, Netz × Material × Zeichen (455), Modellquelle, wo erhältlich (Laden welcher Händler, Beute welches Monster, Herstellen mit Rezept und Werkort, Fund, Sammeln), Zustand ja/nein.
2. **Die Übersicht wird erzeugt**, nicht geschrieben: ein Werkzeug baut `LISTE-GEGENSTAENDE.md` aus der Datendatei, nach Art und Ort sortiert. Dann stimmt sie immer, und jeder schaut dort nach (im Inhaltsverzeichnis `docs/README.md`).
3. **Wer füllt was:** Jerry Werte und Beute (mit 444), Tom Netze und Läden (455.2, 416), Homer Namen und Kurztexte, Perikles das Werkzeug.

## Auswertung

*Stärkstes Gegenargument:* Ein Katalog mit allen Spalten vor dem Bau ist viel Vorarbeit, und vieles ändert sich nach 444 noch. *Wie es zu entkräften ist:* Er wird nicht vorab vollständig geschrieben, sondern wächst mit dem Bau; zuerst nur die 46 Gegenstände, die es schon gibt, mit Modell und Ort. Die Zahlen kommen aus 444 in dieselbe Datei, ohne zweite Liste.

*Zweites:* Der alte Kotlin-Katalog ist die heutige Quelle; eine zweite Datei daneben wäre doppelt. *Lösung:* Die neue Datei ersetzt den Export aus `Gear.kt`; das Spiel liest nur noch sie (gehört zum Ablösen des SRD, Stufe 6, für Gegenstände schon in Stufe 3).

## Folgerung

Mit „458 ja“: Perikles nimmt es in 447.1 (Stufe 3) auf und baut das Werkzeug; Jerry, Tom und Homer bekommen je eine Zeile; die Übersicht kommt ins Inhaltsverzeichnis.

Erledigt: Antwort ins Vorgangsarchiv, Datei löschen (Sokrates).
