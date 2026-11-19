# 1727: Gegenprüfung Katalog fester Werte (19.11., 21:04)

Auftrag Chef 21:00: „lasst den Katalog mal gegenprüfen … über den kompletten Neuentwurf“. Frischer Helfer, gelesen: alle `1727-*.md`, `1727-muster/`, Kopf `LISTE-VORGAENGE.md`, `vorgang.py`, `bereiche.py`. Grundlage: Gesamtbild 0a „Feste Werte“ plus Ergänzungen 20:54–20:58 (Stand des Vorgangs nur zum Teil eintragbar; Art „Build“; Prüfarten mit Kerntest und Handy). Befund ungekürzt, je Punkt Wort Sokrates.

## 1 Fehlt

1. Build als eigenes Ding: Nr. B<n>, Zweck (Testbuild, nach `main`, Release), Auslöser (3.19.1), Stand (läuft, grün, rot; „Build rot“ ist laut 14.2.8 eigener Stand). — **stimmt**
2. Urteil des Chefs („gut“, „nein/Fund“; A14/A15, S14 👍/👎); Eintragsart im Archiv: Entscheid, Vorentscheid, Vertretung, Testurteil. — **stimmt**
3. Wer abnimmt (Prüfer oder Chef): 3.2.3–3.2.9 und 14.3 gegen A11–A14 (dort jeder Vorgang durch Build). Ohne Feld weiß das Werkzeug nicht, ob ein Vorgang in die Warteschlange gehört. — **stimmt**, hängt mit der Rangfolge der Prüfarten zusammen (Chef 21:04)
4. Herkunft (Chefwort, Fund des Chefs, Fund Macher, Fund Prüfer, Werkzeug, Sokrates); 9001 schreibt notdürftig „Muss (Fund des Chefs)“. — **stimmt**
5. Abgeleiteter Stand lückenhaft: Arbeitsvorbereitung schreibt; nach Nein oder Nachstellen vor dem nächsten Auftrag; Konflikt beim Zusammenführen; Chefsache bzw. Frage an Sokrates. — **stimmt**, Einwand zur Zahl: „nach Nein“ ist wieder „Auftrag wird geschrieben“, Konflikt ist Stand des Builds; neu also nur „Auftrag wird geschrieben“ und „Chefsache“
6. Auftrag ohne „abgebrochen“ (14.2.5, A6). — **stimmt**
7. Prüfart ohne Rechnung, Durchspielprotokoll (3.2.6, 3.2.9), „Code“ (Gesamtbild 0). — **stimmt**; Einwand zu „Code“: geht in „Prüfung“ auf
8. „wartet auf“ ohne Katalog; Grund bei „ruht“ Pflicht (14.2.11). — **stimmt**
9. Ersatznummer bei doppelt, überholt (14.3, A17). — **stimmt**
10. Rolle als Katalog: Büro, Arbeitsvorbereitung, Macher, Prüfer, Sokrates, Chef. — **stimmt**
11. Feste Stichworte der Meldung ans Büro: steht, fertig, ja, nein, gut, Fund, Frage, abgebrochen (S5–S15; braucht der Ende-Haken). — **stimmt**
12. Umzug alter Stände (Dauer, nach Meilenstein, aufgeteilt, gebaut, zu testen). — **stimmt**, Umzugstabelle in Bauliste 7.1

## 2 Überflüssig oder widersprüchlich

1. Prüfart steht in keiner Feldliste des Auftrags (0a, Muster 1535, 1694, 9001), nur im Kern AV; Feldzahl dreifach verschieden (7, 11, 8). — **stimmt**
2. Themenblock-Datei `themenbloecke.md` gibt es noch nicht; Muster nutzt alte Blöcke und den erfundenen „Dorf und Innenräume“. — **stimmt**
3. Profil: kaum Profile vorhanden, 9001 nennt `DESIGN-WELT.md`, Auftrag kann zwei Profile haben, Namen auseinander (7.1 gegen 3.17, 5.3). — **stimmt**
4. „steckt fest“ entsteht von selbst (2. Nein, 2. Abbruch), darf nicht zusätzlich eingetragen werden; Eintragen nur Sokrates. — **stimmt**
5. „Handy“ ist keine Prüfart des Auftrags (kein Prüfer am Gerät), gehört zum Build. — **stimmt**
6. „Kerntest“ zu eng, besser „Prüfung“ (Befehl mit Ausgabe, etwa `griff_sicht_1694`). — **stimmt**
7. „Text“ zweideutig → „Textabgleich“. — **stimmt**
8. Bereich = die 17 Werte aus `bereiche.py`, Erklärungen nennen wegfallende Rollen. — **stimmt**
9. Kürzel: „E“ (Eilt) kollidiert mit Bereich E; nur volle Wörter. — **stimmt**

## 3 Gleiche Sache, verschiedene Wörter

1. „Stand“ dreifach (Vorgang, Auftrag, Auftragsfeld). — **stimmt**, löst „Bisher“
2. „Akte“ und `docs/akte/` in Kern Büro, Kern AV, Bauliste gegen „Vorgangsdatei“, `docs/vorgang/`. — **stimmt**, nachziehen mit dem Wort des Chefs
3. angenommen, abgenommen, ja, Abnahme; abgelehnt, nein, Rückläufer, Fund. — **stimmt**: Prüfer „angenommen/abgelehnt“, Chef „gut/Fund“
4. „Runde“ fünffach verschieden. — **stimmt**; Vorschlag: Runde = Nein des Prüfers je Vorgang, ein Fund des Chefs beginnt neu zu zählen
5. Folge nach erstem Prüfer-Nein: Nachstellen, Nachbessern oder derselbe Macher. — **stimmt**; Vorschlag: neuer Auftrag „Nachbessern“, neuer Macher (Gesamtbild 0, Prüfer-Zeile)
6. „Auftrag“ dreifach (Stand, Chef 3.11.4 „Vorgänge sind die Aufträge“, Auftrag im Eingang). — **stimmt**; Eingang heißt „Chefwort“
7. „Fund“ dreifach. — **stimmt**: Herkunft „Fund des Chefs“, Meldung „Hinweis“, Urteil „Fund“
8. Klasse und Herkunft vermischt (9001). — **stimmt**
9. „Profil Build“ und Art „Build“ doppelt. — **Einwand**: Profil ist die Anleitung, Art die Sorte; Art „Build“ setzt das Profil Build von selbst, eingetragen wird nur die Art

## 4 Vorschlag des Prüfers, vollständiger Katalog

**Vorgang:** Klasse (Eilt, Muss, Kür; eingetragen) · Herkunft (Chefwort, Fund des Chefs, Fund Macher, Fund Prüfer, Werkzeug, Sokrates; eingetragen) · Themenblock (1–11 aus `themenbloecke.md`, erst anlegen) · Bereich (17 Werte `bereiche.py`) · Abnahme bei (Prüfer, Chef) · wartet auf (Nummer, Datum, Chef <Datei>, Build B<n>) · Stand eingetragen: ruht (Datum, Grund), erledigt, verworfen, doppelt (Ersatznr.), überholt (Ersatznr.) · Stand abgeleitet: neu, Auftrag wird geschrieben, Auftrag offen, in Arbeit, beim Prüfer, nachzuarbeiten, Warteschlange, im Build, Chef testet, Chefsache, Konflikt, steckt fest · Sitzung, Runde, Kosten abgeleitet.

**Auftrag:** Art (Nachstellen, Bauen, Nachbessern, Varianten, Build) · Profil (ein oder mehrere Pfade) · Prüfart (Bild, Film, Hörprobe, Prüfung, Rechnung, Durchspielprotokoll, Textabgleich, Code) · Stand abgeleitet (offen, in Arbeit, abgebrochen, beim Prüfer, angenommen, abgelehnt) · Prüferurteil je Frage (Ja, Nein) · schreibt/baut/prüft (Sitzung plus Rolle).

**Build:** Zweck (Testbuild, nach `main`, Release) · Auslöser (Anzahl, Alter, Fund des Chefs, Eilt, Wort des Chefs) · Stand abgeleitet (läuft, grün, rot, beim Chef, erledigt) · Prüfart fest Handy.

**Vorgangsarchiv:** Eintragsart (Entscheid, Vorentscheid, Vertretung, Testurteil gut/nein).

**Meldung ans Büro:** Pflichtwort am Anfang: steht, fertig, ja, nein, gut, Fund, Frage, abgebrochen.

Unsicher (Prüfer): ob „nachzuarbeiten“ und „Auftrag wird geschrieben“ eigene Werte brauchen (hängt an 3.5). Wort Sokrates: einer reicht („Auftrag wird geschrieben“), siehe 1.5.
