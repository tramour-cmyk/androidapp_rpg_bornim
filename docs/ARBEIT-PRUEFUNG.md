# Vorrat Diogenes

Prüfaufträge (`ROLLE-PRUEFUNG.md`). Alle tragen ein: eine Zeile mit Vorgang und Klasse, dann `send_message` an Ford „Auftrag Diogenes <Nr>“ (von Pro aus nur die Zeile); nur Chef oder Ford starten Diogenes.


**Geprüft bis:** `c4af6147` (18.10., Lauf 30: 71 Teil A, Dorf, Wald, Tiefer Wald; Notizen unberührt) · vorher `fe6317ce` (Lauf 28: 167 Ablaufentwurf, Trockentest `startbar.py`/`kosten.py`, Regelwidersprüche) · vorher `dad278aa` (Lauf 27: 166.1 `startbar.py`, nur Lektüre und Probetexte) · vorher `c2f9267c` (Lauf 26: 164) · vorher `45a68a18` (Lauf 25: 159) · vorher `799f7cf4` (17.10., Lauf 23: D4.1 neu gemessen, nur Messung; Lauf 22 Notizen bis 5338741b, Lauf 9 Code bis 8836512); nächste Nummer D30.

**Übergabe (18.10., 23:5x, Lauf 30):** 71 Teil A geprüft, Prüfbericht Lauf 30, Befunde D29.1/D29.2 an Jerry, D29.3/D29.4 an Tom, D29.5 an Homer (Zeilen in deren Vorräten). Offen in 71: Teil C (Oberflächen). Vorlage Prüfbogen (186.2) steht, wartet auf Bögen. Nachfolger: 71 Teil C, nur wenn nichts Wichtigeres.

**Vorher (18.10., Lauf 29):** Release geprüft (Prüfbericht Lauf 29): Freigabe ja, Befunde keine aufhaltend; Zeile gestrichen. Nachfolger: keiner.

**Vorher (17.10., 09:2x, Lauf 23):** 38 D4.1 neu gemessen, Prüfbericht Lauf 23: Ziel verfehlt (über Morwen Stufe 1, Median 24 Tode; mit Stufe 3 Höhle 3,5). Befunde D23.1, D23.3 an Jerry, D23.2 an Tom; Zeile 38 gestrichen. Mess-Spieler mit Rohausgabe auf Zweig `claude/diogenes-d41-messung` (`tools/messung/`), zum Nachmessen nach `core/src/test/…` kopieren, nie nach `main`. Nachfolger: keiner nötig bis zum nächsten Auftrag.

## Zeilen

| Nr. | Kl. | Auftrag | Bedingung |
|---|---|---|---|
| 192.5 | M | **von Sokrates (Chef 19.10., 07:5x: „192 ja“; geteilt 19.10., 08:2x):** Anlassprüfung „Umbau 19.10.“ auf dem Papier, **vor** dem Bau: greifen die Beschlüsse 190, 190.8–190.10, 191, 192, 194 ineinander (Vorgangsarchiv gegen `CLAUDE.md`, Rollendateien, `LISTE-BETRIEB.md`, `startbar.py`, `lauf.py`; `regelcheck.py --anlass 1a467a0e`): Widersprüche, doppelte Regeln, Handarbeit, die ein Skript schon rechnet; Befunde an Perikles, bevor er baut | offen |
| 192.5b | M | **von Sokrates:** zweiter kurzer Lauf nach dem Bau: Probelauf `lauf.py`/`startbar.py` mit echten Vorräten | wartet auf 191 |
| 149.1 | M | **von Sokrates (Chef 17.10., 23:2x: „Ja“ auf Empfehlung Sokrates):** in die Zählung 149 aufnehmen: Kür-Starts Jerry nach 159b. Verdacht: Lauf 17.10., 22:08 „Jerry 39 wartet auf 38; nichts zu starten“, obwohl Kür startbar schien (140, 141, 72.10b); Start erst 23:06 für 72.10a. Prüfen, ob die Zeilen wirklich startbar waren | mit 149, bis 24.10. |
| 149 | M? | Probewoche Ford mit neuem Modell; dazu 156 Tom gegen Jerry | ab Fords erstem Start nach Startzuordnung, Ergebnis nach dem 24.10. |
| Woche | K | **Wochenzählung (QM, 106.1):** alle Kennzahlen der Woche zählen, Tabelle oben im Prüfbericht (`LISTE-PRUEFUNG.md` „Wochenzählung“); jede Woche, Zeile bleibt; **ab Mo 26.10. auch „Anteil Spiel“** (167.4, Chef 18.10.: aus `kosten.py`, Stufe 50 %) | montags ab 8 Uhr, erstmals Mo 26.10. (Woche 18.–24.10.) |
| 90 | K | Tagesrückblick der Woche gegen die Quellen prüfen | nach dem 22.10., 9 Uhr |
| 71 | K | Bestandsprüfung Stil und Klang: Teil C (Oberflächen); B getan (Lauf 1), A getan (Lauf 30) | offen (Chef 18.10., 22:58: „71 so lassen“); Vorgehen `LISTE-PRUEFUNG.md` „Bestandsprüfung“ |
| 186.3 | K | Ausgefüllte Prüfbögen der Tester auswerten (`tools/pruefbogen/`, mit echten Bögen ungetestet) | ruht, bis Bögen der Tester da sind (nicht „wartet auf Chef“: das sperrte in lauf.py ganz Diogenes, 190) |

- **Zu 149** (Thema, Stand im Wortlaut): **Probewoche Ford mit neuem Modell** (Startzuordnung in `LISTE-BETRIEB.md`; von Ford, Chef 17.10.): bis 24.10. Fords Regelverstöße zählen (doppelter Start, Muss/Kür vertauscht, fehlende Kosten, verpasste Meldung), je Fall Zeit und Quelle; im Prüfbericht vorlegen, danach entscheidet der Chef über Aufwand „Niedrig“ oder das stärkere Modell. **Dazu 156 (Chef 17.10., 19:4x):** Team Tom (opus) gegen Team Jerry (sonnet): Rückläufer mit Ursache, Regelverstöße und Befunde, Kosten je Punkt; Schwelle in `VORGANGSARCHIV.md` 156; Auswertung Perikles | ab Fords erstem Start nach Startzuordnung, Ergebnis nach dem 24.10.
- **Zu 90** (Thema, Stand im Wortlaut): Tagesrückblick: die Rückblicke der Woche (Telegram, Sitzungen „Perikles – Tagesrückblick“) gegen die Quellen in `ROLLE-PROJEKT.md` prüfen: stimmten die Fakten, wurden Empfehlungen umgesetzt, was hat die Woche gekostet; Ergebnis im Prüfbericht vor der Bilanz am 23.10. Dazu (Chef 15.10., 19:5x „auch nachts einiges geschafft“): je Nacht 22–7 Uhr Sitzungen und Commits zählen, Leerlauf mit Ursache | nach dem 22.10., 9 Uhr
