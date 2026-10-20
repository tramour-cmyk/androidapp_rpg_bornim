# Auswertung der Prüfbögen (186.2)

Vorlage für Diogenes, bevor die 12 Tester spielen. Bogen: Claude-Doc https://claude.ai/code/artifact/a189ca60-7068-4f07-97d6-474b1bb6cf7f (Teile A–E und M; Quelle des Wortlauts ist `tools/pruefbogen/bogen.md`, daraus das ausfüllbare `tools/pruefbogen/pruefbogen.pdf`, 250). Diogenes zählt und legt vor, er bewertet nicht (Spielgefühl gehört dem Chef, Zahlen bewertet Perikles).

## Bogen als PDF (250)

`python3 tools/pruefbogen/bogen_pdf.py bauen` erzeugt `pruefbogen.pdf` aus `bogen.md` (nach jeder Änderung des Wortlauts neu bauen und gegen „Stand:“ in `bogen.md` pflegen: Fußzeile „Bogen Stand TT.MM.“, verborgenes Feld `Bogenstand`; Bögen verschiedener Fassung getrennt auswerten). Die Tester füllen die Felder am Handy (Adobe Acrobat, Google Drive) oder am Rechner und schicken die Datei zurück; Druck bleibt möglich. `bogen_pdf.py lesen A.pdf B.pdf … --boegen boegen.csv --fehler fehler.csv` liest die Felder aus und schreibt beide Tabellen für `auswertung.py` (Stichwörter zu Skalen in Spalten `A1s` …). Echte Bögen nie nach `main`. Teil B und M gelten nur, solange MARS Probe ist; vor jedem Testerbuild Bogen gegen den Stand abgleichen.

## Erfassen (von Hand, falls kein PDF)

Tester tragen Kürzel statt Namen ein. Zwei Tabellen in `tools/pruefbogen/`:

- `boegen-vorlage.csv`: eine Zeile je Bogen; Spalten = Frage-Nummern des Bogens (A1–A5, B1–B7 …), Kopf (Kürzel, Gerät, Build, Datum, Stunden, Minuten, Erfahrung, Klasse, Schwierigkeit). Skalen als Zahl 1–5, Wahlfragen als Wortlaut des Bogens (genau so: `zu kurz`, `passend`, `zu lang`; B7 `nie`, `1-2`, `3-5`, `öfter`; M6 `1`, `2-3`, `mehr`; B8 `Wald`, `Höhle`, `Boss`, `anderer`; B9, C8 `nein`/`ja`; D6 `immer`, `manchmal`, `einmalig`, `nicht probiert`; E2, E3 `ja`, `vielleicht`, `nein`; E4 `zu leicht`, `genau richtig`, `zu schwer`; E5 `zu langsam`, `genau richtig`, `zu schnell`; E6 `Ende erreicht`, `Fehler`, `Langeweile`, `keine Zeit`, `anderer Grund`, Ort in `E6ort`; Erfahrung `keine`, `etwas`, `viel`). Stichworte und Freitexte wörtlich (A6, B8text, B9text, C7, C8text, E7–E9). Leer = nicht beantwortet.
- `fehler-vorlage.csv`: eine Zeile je Fehler aus Teil D: Tester, Nr, Ort, Getan, Passiert, Erwartet, Schwere (`Absturz`, `Spiel hängt`, `stört`, `Schönheitsfehler`), Wiederholbar (D6).

Kopien mit echten Antworten nie nach `main` (eigener Zweig oder lokal); in den Prüfbericht kommt nur die Auswertung.

## Auswerten

`python3 tools/pruefbogen/auswertung.py BOEGEN.csv FEHLER.csv` liefert Markdown:

1. **Skalenfragen:** n, Mittel, Median, Zahl der Wertungen 1–2 und 5, ohne Antwort. Bei 12 Testern Mittel nur mit n danebenstellen; Stichwörter zu 1, 2 und 5 (Pflicht laut Bogen) von Hand unter die Frage setzen.
2. **Wahlfragen:** Anzahl je Antwort, „andere“, ohne Antwort.
3. **Freitexte:** wörtlich je Frage mit Kürzel.
4. **Fehler nach Ort:** Meldungen, verschiedene Tester, schwerste Schwere, Absturz/hängt, wiederholbar; sortiert nach Zahl der Tester. Ein Ort mit mindestens 2 Testern ist bestätigt (Quervergleich), ein Fehler nur eines Testers ist Hinweis.
5. **Fehler einzeln** nach Schwere; Fehler ohne Ort oder Schritte werden gezählt, sie sind nicht nachstellbar.

Orte vorher vereinheitlichen (gleiche Schreibweise für Dorf, Wald, Höhle, Boss), sonst zählt das Skript sie getrennt.

## Weitergeben

Nach Befundregeln in `LISTE-PRUEFUNG.md`: Fehler eines Ortes → Klasse 1 an das Team des Ortes (Zeile mit Ort, Schritten, Häufigkeit); Spielgefühl und Story (B, C, E4, E5, Freitexte) → Zusammenfassung an Homer, Klasse 2; Zählung im Prüfbericht. Abbruchgründe (E6) und Absturz-Orte zuerst nennen. Ein Lauf, fünf wichtigste Befunde.
