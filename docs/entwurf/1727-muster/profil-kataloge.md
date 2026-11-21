# 1727, Profil Kataloge (herausgezogen 21.11., Sokrates-Helfer, aus 1727-gesamtbild.md Abschnitt 5.3 Nr. 5, Zeilen 584–590 an Commit 4d67d1213)

**Ziel** (644 A, 649 A, 649b). Zwei Kataloge sind die eine Stelle; das Spiel liest nur sie, die Seiten werden erzeugt, das Bestiarium geht auf. **Figurenkatalog** (Monster, Leute, Held): je Art Name, Gruppe, Werte, Stärken, Schwächen, Handlungen, Klänge und Bewegungen je Anlass, Aussehen, Beute; je Auftritt Ort, Tagesablauf, Laden, Stimme. **Gegenstandskatalog**: je Stück Name, Art, Platz, Stufe, Preis, Seltenheit, Modell, Bezug, Text. Gruppen nur erzeugt; `werte.json` hat nur Formeln.

**Heute** (bis 649b Build 2 und 3): Monster in `tools/sim444/werte.json` „kennungen“ (Name `de`/`en`; „art“ ist nur Schlüssel), „monster“, „absichten“, Klänge `kampfklang.json`; Körper, Größe, Felle als Liste im Code, gespiegelt in „kennungen“: beide gleich ändern. Gegenstände `tools/gegenstaende/gegenstaende.json`, Namen noch `texte.json`. Leute, Herkünfte verstreut: nur auf Auftrag. Keine neue Liste im Code.

**Pflege.** Neues im selben Zweig in die Quelle. Erzeugte Seiten nie von Hand, nie im Zweig (Werkzeug auf `main` nach dem Mischen). Namen und Aussehenstexte sind Spieltext: nur aus der Quelle; fehlt einer oder gibt es zwei für eins: Befund zurückmelden. Neues Aussehen nur nach Chefwort. Seltenheit nach `DESIGN-BRS.md` 11.

**Beleg.** `python3 tools/figurenpruefung.py --pruefen`, `python3 tools/gegenstaende.py --daten` grün; `python3 tools/figuren.py --luecken` vor und nach, jede neue Zeile ein Befund.
