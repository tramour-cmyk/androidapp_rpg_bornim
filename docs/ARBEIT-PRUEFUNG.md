# Vorrat Diogenes

Prüfaufträge (`ROLLE-PRUEFUNG.md`). Alle tragen ein: eine Zeile mit Vorgang und Klasse, dann `send_message` an Ford „Auftrag Diogenes <Nr>“ (von Pro aus nur die Zeile); nur Chef oder Ford starten Diogenes.


**Geprüft bis:** `98ba4b9b` (21.10., Lauf 40: 261.5 Archivregel, `lauf.py` mit Kurzzeilen und echter Liste, Notizen Lektüre; frühere Stände in Git); nächste Nummer D41.

**Übergabe (21.10., 07:5x):** Vorrat auf Wort des Chefs (07:51) Zeile für Zeile geprüft: 90 gestrichen (seit 247 durch den Tagesbericht ersetzt, `LISTE-VORGAENGE.md` „ersetzt“), Notizen zu erledigten 186.4 und 235 und alte Übergaben gestrichen (Git), 149 auf gleiches Modell beider Teams (156.1) berichtigt. Nachfolger: 274 Prüfung Schritt 1–3.

## Zeilen

| Nr. | Kl. | Auftrag | Bedingung |
|---|---|---|---|
| 274 | M | **von Perikles (Vorgangsarchiv 274):** Schritt 1–3 prüfen: ging eine Regel, ein offener Befund oder ein Verweis verloren? `PRUEFBERICHT.md` gegen `-ARCHIV.md`; fünf gelöschte Dateien (Verweise); Kopf `VORGANGSARCHIV.md`; `CLAUDE.md`, `ROLLE-PROJEKT.md`, `ROLLE-BERATUNG.md` je gegen `f3ec7200` (Übernahme jetzt in `ROLLE-ENTWICKLUNG.md`, Team-Kennungen in `ROLLE-BETRIEB.md`) | jetzt |
| 149 | M | Probewoche Ford mit neuem Modell; dazu 156 Tom gegen Jerry | ab Fords erstem Start nach Startzuordnung, Ergebnis nach dem 24.10. |
| 270 | M | **von Perikles (Vorgangsarchiv 270):** Perikles und Diogenes auf dem großen Modell messen: Umbauten am Ablauf je Tag, nachträglich gefundene Fehler in Regeln und Werkzeugen, Kosten beider Rollen | frühestens 26.10. (mit der Wochenzählung) |
| Woche | K | **Wochenzählung (QM, 106.1):** alle Kennzahlen der Woche zählen, Tabelle oben im Prüfbericht (`LISTE-PRUEFUNG.md` „Wochenzählung“); jede Woche, Zeile bleibt; **ab Mo 26.10. auch „Anteil Spiel“** (167.4, Chef 18.10.: aus `kosten.py`, Stufe 50 %) | montags ab 8 Uhr, erstmals Mo 26.10. (Woche 18.–24.10.) |
| 186.3 | K | Ausgefüllte Prüfbögen der Tester auswerten (`tools/pruefbogen/`, mit echten Bögen ungetestet) | ruht, bis Bögen der Tester da sind (nicht „wartet auf Chef“: das sperrte in lauf.py ganz Diogenes, 190) |

- **Zu 270, von Sokrates** (Chef 21.10., 06:52: „Was hat das gekostet?“, gemeint der Umbau der Abläufe): Ausgangswert 21.10., 05:5x–06:52: etwa 25–28 $ Umbau (sicher 23,08 $: Perikles 261.4 0,45, 261.5 10,66; Sokrates 6,39 + 4,26 + 1,32; Rest Anteile Diogenes und Ford), Spiel etwa 1,5 $.
- **Zu 149.1** (Vorwärtszählung bis 24.10.): ein Fall zählt, wenn Ford „Jerry nichts zu starten“ meldet und `startbar.py` zum selben Stand ein Muss oder eine Kür nennt und keine Jerry-Sitzung lief; Abweichungen mit Grund (Wochenziel, Stand der Zeile) getrennt zählen. Quellen: Fords Protokollzeilen, Git-Stand, `list_sessions`. Rückschau bis 20.10., 10:04 steht im Prüfbericht Lauf 38 (jetzt `PRUEFBERICHT-ARCHIV.md`).
- **Zu 149** (Thema, Stand im Wortlaut): **Probewoche Ford mit neuem Modell** (Startzuordnung in `LISTE-BETRIEB.md`; von Ford, Chef 17.10.): bis 24.10. Fords Regelverstöße zählen (doppelter Start, Muss/Kür vertauscht, fehlende Kosten, verpasste Meldung), je Fall Zeit und Quelle; im Prüfbericht vorlegen, danach entscheidet der Chef über Aufwand „Niedrig“ oder das stärkere Modell. **Dazu 156 (Chef 17.10., 19:4x):** Team Tom gegen Team Jerry: Rückläufer mit Ursache, Regelverstöße und Befunde, Kosten je Punkt; Schwelle in `VORGANGSARCHIV.md` 156; Auswertung Perikles. Seit 18.10. beide Teams auf demselben Modell (156.1: „Messung 156 läuft weiter mit gleichem Modell“) | ab Fords erstem Start nach Startzuordnung, Ergebnis nach dem 24.10.
- **Zu D37.1** (Perikles 20.10., 18:1x, Fassung geprüft): am 17.10., 22:08 (letzter Stand `62ca83ee`) galt dieselbe Regel wie heute: `ROLLE-BETRIEB.md` 23/25 und `LISTE-BETRIEB.md` Schritt 4 „Kür nur, wenn nirgends Muss startbar ist“, Jerry in der Zentrale seit 159 (17.10., 18:04); nur `startbar.py` fehlte (166.1, 18.10.). Vorgang 38 stand mit „Zeile an Diogenes … später: Chef“ wartend, 141 war startbar: der Kür-Start war geboten, **zählt für 149 als ein unterbliebener Start** (Ursache: mehrdeutiger Stand, den heute das erste Wort und `startbar.py` auflösen). Die Aussage „0 Fehlstarts seit 159b“ im Prüfbericht gilt damit nicht; Wert: 1 in 3 Tagen.
