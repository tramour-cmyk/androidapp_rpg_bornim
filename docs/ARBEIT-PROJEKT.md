# Vorrat Perikles

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang, Muss oben. Größe höchstens etwa 15 KB.


**Gelesen bis:** `origin/main` 20.10., 00:04

**206 (19.10., 12:1x):** M (Wunsch des Chefs), gebaut: „Vorgang“ statt „Zeile“ in Startauftrag und Hindernistext (`lauf.py`), Weiter-Haken, Besetzung (Spalte), `CLAUDE.md`; Tabellenzeile und interne Kommentare bleiben „Zeile“. Wirkt ab nächstem Lauf von Ford.

**202 (19.10., 12:2x):** gebaut: `startbar.py` nennt am Ende „Übernahme für Tom/Jerry: <Nr> …“, wenn das Team nichts Startbares hat (oberste freie Zeile des anderen, ohne Test/Gerät/Build bevorzugt, nichts bei mehr als 4 Wartenden auf Test). `lauf.py` startet noch nicht danach; Ford sieht den Hinweis, 202 Rest: lauf.py anbinden nur, wenn Ford es von Hand tun muss.

**M?-Abgleich (19.10., 11:1x):** 198, 199, 200 (Fehler des Chefs, Direktive 179) und 149 (Probewoche läuft, Chef „Ja“ zu 149.1, Frist 24.10.) auf M.

**Übergabe (20.10., 00:1x, „Perikles – 165 Tag 2“):** 165 Tag 2 getan (Stichprobe, siehe unten); `regelcheck.py` meldet Übergaben über 700 Zeichen. Offen: 192.5b Diogenes prüft das Zusammenspiel; Ford bucht Rest-Sokrates-Sitzungen von 18.10. Nachfolger: keiner

**Abgleich (18.10., 22:4x, Chef: „Überprüfe und gleiche ab“):** Zeile 90 fehlte (Schritt 11 verweist darauf), neu; 165 Tag 2 erst 20.10. (19.10. Rückblick Sokrates); 167 erledigt (.1, .4, .5, .8, .9, .2, .10 umgesetzt, .7 nein), 167.6 zu Sokrates (Wiedervorlage 26.10.); 99 ruht (Niederlassung, 159).

| Nr. | Kl. | Titel | Stand |
|---|---|---|---|
| 90 | K | Tagesrückblick (Probe 18.–22.10.), Ford startet ihn (`LISTE-BETRIEB.md` Schritt 11) | ab 20.10. Tag 2 (19.10. einmalig Sokrates, 167.6), Bilanz 23.10.; weiter: offen bis Bilanz |
| 165 | M | Ablaufstichprobe, im Tagesrückblick 90 | ab 21.10. Tag 3 (Tag 1 18.10., Tag 2 20.10. getan), Bilanz 23.10. |
| 185 | K | Ford-Grenze 400.000 Token (Chef 18.10., 19:0x, Wortlaut: „185 ja, aber erst messen. Dann ja.“) | ab 20.10. Auswertung an Sokrates (Grenze umgestellt 18.10., 22:4x; Messtag 19.10.; Ford meldet Tageskosten 17.–19.10. am 20.10.) |
| 177M | K | Messung: Wartezeit durch Stundenuhr (Chef Weg 2, 18.10.), Entscheid 21.10. | ab 21.10. Entscheid (Messung 20.–21.10.) |
| 99h.6 | K | Messung Leitung 20.–21.10. mit den Neustarts der Teams (99h, 99h.6) | ab 22.10. Auswertung |
| 163.1 | K | Kosten der Abläufe, Obergrenze Fords Läufe (Regelbilanz) | ruht bis 23.10. |

## Einzelheiten

- **Zu 192/191 (19.10., gebaut):** 192.2 Schritte 5, 9, 10 (`--morgen`), 11 in `lauf.py`; Schritte 6 und 8 sind Urteil, bleiben Text. 192.3: Wortlaut des Chefs im Vorrat, Weckruf nach Push, Standzeile nicht als Haken gebaut (nicht sicher erkennbar, Leitlinie 192: Haken, der öfter falsch meldet, wird abgeschaltet; D31.4). 191 komplett (Kosten als Differenz, Termin vorbei). Diogenes prüft in 192.5b.
- **Zu 192** (D31.1): Haken-Grenzen: Größe nur anhalten, wenn der Commit die Datei vergrößert und sie über 15000 liegt; Uhrzeit nur in neuen Zeilen, 5 Minuten Toleranz; D- und Unternummern kennen; Ausweg für zurückgezogene Chefsache.
- **Zu 165** (Chef Ja 18.10.): Schritt in `ROLLE-PROJEKT.md` Tagesrückblick, Zählung in `ROLLE-PRUEFUNG.md`; Bilanz 23.10.
- **165 Tag 1 (18.10., 17:1x):** Testdateien t25 (Tom) und t26 (Jerry) verglichen. Abweichung: t26 ohne Satz „Ein Weg …, über Build n installieren“ und Reihenfolge nicht als Weg (26.5 Schänke nach Höhle); Wurzel: Weg-Regel stand nur in `LISTE-BAUEN-TESTEN.md`, nicht im Muster „So geht's“. Behoben in `tools/zug-index.py` (Muster, README neu). Übergaben Tom/Jerry und Meldungen: kein Unterschied gefunden. Aufwand etwa 10 Minuten. Befund 1 von 1 je Tag zählt für die Bilanz.
- **165 Tag 2 (20.10., 00:1x):** Testdateien t39 (Tom) und t40 (Jerry): gleiches Muster, kein Unterschied. Übergaben Tom (318 Zeichen) und Jerry (964, mit Stand, Branchnamen, Zitat): Abweichung gegen `CLAUDE.md` „was getan ist und der Nachfolger, kein Stand“. Wurzel: kein Maß, kein Haken; behoben in `tools/regelcheck.py` (Übergabe über 700 Zeichen wird gemeldet, Jerrys Vorrat steht jetzt drin; kürzen macht Jerry). Chefsache-Dateien `entscheiden/` leer, Meldungen (Telegram) nicht lesbar. Aufwand etwa 10 Minuten. Befund 2 von 2 Tagen.
