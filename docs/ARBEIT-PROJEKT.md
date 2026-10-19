# Vorrat Perikles

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang, Muss oben. Größe höchstens etwa 15 KB.


**Gelesen bis:** `origin/main` 19.10., 07:15

**Übergabe (19.10., 08:58, „Perikles – 190.9 Kür nach Muss (19.10., 08:05)“):** getan und auf `main`: 190.9 (Homer/Perikles Kür, Nummer jetzt 196 durch Diogenes), 190.10 (Stufe „nach dem Meilenstein“ in `startbar.py`/`lauf.py`, Texte), 190.8 (offene „M?“ als Muss für Perikles), D31.2/D31.3 (`--nur-muss`)/D31.1 (Grenzen in „Zu 192“), 191 Teil (`abgleich.py`), 192.1 (`commit-pruefung.py`, Haken über `notiz.sh`), 192.2 Schritte 5 und 9, 192.3 Kerntest-Marke, 195 (Weiter-Haken ruft `startbar.py`, Neustart-Pflicht, ein Build je Sitzung). Offen: 191-Rest, 192 Rest (.2 Schritt 11, .3 Rest, .5 Diogenes). Nachfolger: Perikles – 192 Rest und 191 Rest (19.10., 08:58)

**Abgleich (18.10., 22:4x, Chef: „Überprüfe und gleiche ab“):** Zeile 90 fehlte (Schritt 11 verweist darauf), neu; 165 Tag 2 erst 20.10. (19.10. Rückblick Sokrates); 167 erledigt (.1, .4, .5, .8, .9, .2, .10 umgesetzt, .7 nein), 167.6 zu Sokrates (Wiedervorlage 26.10.); 99 ruht (Niederlassung, 159).

| Nr. | Kl. | Titel | Stand |
|---|---|---|---|
| D31.4 | K | **von Diogenes (Lauf 31):** 191/192.1 nur das Neue bauen, Vorhandenes (startbar, lauf, regelcheck) rufen; 192.2 nur rechenbare Schritte (5, 9, 10, 11) | offen |
| D31.5 | K | **von Diogenes (Lauf 31):** 194 berührt mehr Stellen als aufgeführt (Prüfbericht D31.5); erst nach Entscheid des Chefs bauen | wartet auf 194 |
| 191 | M | **Rest von 191:** `abgleich.py` steht (Vorratszeile ohne Liste, gebaut mit zusammengeführtem Zweig, Entschiedenes ohne Zeile, Aufruf aus `lauf.py`); Titel ohne Vorgangsnummer warnt (lauf.py); offen: Kosten ruhender Sitzungen buchen (braucht ein Buchungsverzeichnis, nur Differenz), Termin vorbei ohne Änderung | offen |
| 192 | M | **von Sokrates (Chef 19.10., 07:5x: „192 ja“):** Skripte am Ort der Handlung: .1 Commit-Prüfung steht (`commit-pruefung.py`, Haken über `notiz.sh`); .2 Schritte 5 (STILLSTAND) und 9 (VORRAT-LEER) stehen in `lauf.py`; offen: 11 (Wochenstart, Tagesrückblick: braucht Protokollmarke) und 10 als Text, .3 Kerntest-Marke (`tools/t logik` → Warnung im Commit-Haken) und Uhr beim Commit stehen; offen: Wortlaut des Chefs im Vorrat, Weckruf nach Push, Standzeile (schwer sicher zu erkennen, Haken nur bauen, wenn er öfter richtig als falsch meldet), .5 Diogenes prüft danach (Vorgangsarchiv 192; .4 ist mit dem Beschluss gefallen) | offen |
| 193 | K | **von Sokrates (regelcheck 19.10., 07:50):** tote Verweise: `LISTE-BETRIEB.md` → `docs/chefsache/entscheiden/110-ford-von-hand.md` (gibt es nicht mehr); `ROLLE-PROJEKT.md` „-ARCHIV.md“ (Falschmeldung des Prüfers, Kurzform von `LISTE-VORGAENGE-ARCHIV.md`); `tools/abgleich.py` entsteht mit 191 | offen |
| 90 | K | Tagesrückblick (Probe 18.–22.10.), Ford startet ihn (`LISTE-BETRIEB.md` Schritt 11) | ab 20.10. Tag 2 (19.10. einmalig Sokrates, 167.6), Bilanz 23.10.; weiter: offen bis Bilanz |
| 165 | M | Ablaufstichprobe, im Tagesrückblick 90 | ab 20.10. Tag 2 (Tag 1 getan 18.10.), Bilanz 23.10. |
| 185 | K | Ford-Grenze 400.000 Token (Chef 18.10., 19:0x, Wortlaut: „185 ja, aber erst messen. Dann ja.“) | ab 20.10. Auswertung an Sokrates (Grenze umgestellt 18.10., 22:4x; Messtag 19.10.; Ford meldet Tageskosten 17.–19.10. am 20.10.) |
| 177M | K | Messung: Wartezeit durch Stundenuhr (Chef Weg 2, 18.10.), Entscheid 21.10. | ab 21.10. Entscheid (Messung 20.–21.10.) |
| 99h.6 | K | Messung Leitung 20.–21.10. mit den Neustarts der Teams (99h, 99h.6) | ab 22.10. Auswertung |
| 163.1 | K | Kosten der Abläufe, Obergrenze Fords Läufe (Regelbilanz) | ruht bis 23.10. |

## Einzelheiten

- **Zu 192** (D31.1): Haken-Grenzen: Größe nur anhalten, wenn der Commit die Datei vergrößert und sie über 15000 liegt; Uhrzeit nur in neuen Zeilen, 5 Minuten Toleranz; D- und Unternummern kennen; Ausweg für zurückgezogene Chefsache.
- **Zu 165** (Chef Ja 18.10.): Schritt in `ROLLE-PROJEKT.md` Tagesrückblick, Zählung in `ROLLE-PRUEFUNG.md`; Bilanz 23.10.
- **165 Tag 1 (18.10., 17:1x):** Testdateien t25 (Tom) und t26 (Jerry) verglichen. Abweichung: t26 ohne Satz „Ein Weg …, über Build n installieren“ und Reihenfolge nicht als Weg (26.5 Schänke nach Höhle); Wurzel: Weg-Regel stand nur in `LISTE-BAUEN-TESTEN.md`, nicht im Muster „So geht's“. Behoben in `tools/zug-index.py` (Muster, README neu). Übergaben Tom/Jerry und Meldungen: kein Unterschied gefunden. Aufwand etwa 10 Minuten. Befund 1 von 1 je Tag zählt für die Bilanz.
