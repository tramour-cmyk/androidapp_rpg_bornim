# Vorrat Perikles

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang, Muss oben. Größe höchstens etwa 15 KB.


**Gelesen bis:** `origin/main` 19.10., 07:15

**Übergabe (19.10., 07:4x, „Perikles – 190 Startsteuerung“):** 190 umgesetzt (190.1–190.7): `startbar.py` (gebaut = wartet auf Test, Muss durch wartende Muss-Zeilen, Zitate sperren nicht), `lauf.py` (`--ohne NR:Grund`, „wartet auf Chef“ hält nur die Sitzung der Zeile, Nachfolger-Start mit WARNUNG und WARNUNG-LAUT), `LISTE-BETRIEB.md`, `ROLLE-BETRIEB.md`, `CLAUDE.md` 6 nachgezogen; Wochenziel-Ausschlüsse im Vorrat (72u.1, 72.10a.8T/9T/11T), Sammelbuild-Zeile 190.9 bei Jerry, 84.1T.1 auf Muss. Offen für Ford: Kurzzeilen brauchen `created_at` (Spalte 6). Nachfolger: keiner (Tagesrückblick 20.10. startet Ford, Schritt 11).

**Abgleich (18.10., 22:4x, Chef: „Überprüfe und gleiche ab“):** Zeile 90 fehlte (Schritt 11 verweist darauf), neu; 165 Tag 2 erst 20.10. (19.10. Rückblick Sokrates); 167 erledigt (.1, .4, .5, .8, .9, .2, .10 umgesetzt, .7 nein), 167.6 zu Sokrates (Wiedervorlage 26.10.); 99 ruht (Niederlassung, 159).

| Nr. | Kl. | Titel | Stand |
|---|---|---|---|
| 190.9 | M | **von Sokrates (Chef 19.10., 07:4x: „190.9 ja … Kür vor Leerlauf“):** alle Rollen mit Vorrat Kür nach Muss: `lauf.py` MIT_KUER um Homer, Perikles; Kopf von `lauf.py`, `LISTE-BETRIEB.md` (Uhr, „nur Muss“) und `ROLLE-BETRIEB.md` („Kür … nur mit Wort des Chefs“) nachziehen (Vorgangsarchiv 190.9) | offen |
| RC19 | K | **von Sokrates (regelcheck 19.10., 07:50):** tote Verweise: `LISTE-BETRIEB.md` → `docs/chefsache/entscheiden/110-ford-von-hand.md` (gibt es nicht mehr); `ROLLE-PROJEKT.md` „-ARCHIV.md“ (Falschmeldung des Prüfers, Kurzform von `LISTE-VORGAENGE-ARCHIV.md`); `tools/abgleich.py` entsteht mit 191 | offen |
| 190.8 | M | **von Sokrates (Chef 19.10., 07:3x: „190.8 ja“):** `lauf.py` meldet jedes „M?“ als Muss für Perikles, Perikles entscheidet im nächsten Lauf (Vorgangsarchiv 190.8) | offen |
| 191 | M | **von Sokrates (Chef 19.10., 07:3x: „191 JAAAAAAA!“):** `tools/abgleich.py` in jedem Lauf (Kosten, Vorgänge, Stand, Zusagen), Ford trägt WARNUNG ein (Vorgangsarchiv 191, vier Prüfgruppen dort) | offen |
| 90 | K | Tagesrückblick (Probe 18.–22.10.), Ford startet ihn (`LISTE-BETRIEB.md` Schritt 11) | ab 20.10. Tag 2 (19.10. einmalig Sokrates, 167.6), Bilanz 23.10.; weiter: offen bis Bilanz |
| 165 | M | Ablaufstichprobe, im Tagesrückblick 90 | ab 20.10. Tag 2 (Tag 1 getan 18.10.), Bilanz 23.10. |
| 185 | K | Ford-Grenze 400.000 Token (Chef 18.10., 19:0x, Wortlaut: „185 ja, aber erst messen. Dann ja.“) | ab 20.10. Auswertung an Sokrates (Grenze umgestellt 18.10., 22:4x; Messtag 19.10.; Ford meldet Tageskosten 17.–19.10. am 20.10.) |
| 177M | K | Messung: Wartezeit durch Stundenuhr (Chef Weg 2, 18.10.), Entscheid 21.10. | ab 21.10. Entscheid (Messung 20.–21.10.) |
| 99h.6 | K | Messung Leitung 20.–21.10. mit den Neustarts der Teams (99h, 99h.6) | ab 22.10. Auswertung |
| 163.1 | K | Kosten der Abläufe, Obergrenze Fords Läufe (Regelbilanz) | ruht bis 23.10. |

## Einzelheiten

- **Zu 165** (Chef Ja 18.10.): Schritt in `ROLLE-PROJEKT.md` Tagesrückblick, Zählung in `ROLLE-PRUEFUNG.md`; Bilanz 23.10.
- **165 Tag 1 (18.10., 17:1x):** Testdateien t25 (Tom) und t26 (Jerry) verglichen. Abweichung: t26 ohne Satz „Ein Weg …, über Build n installieren“ und Reihenfolge nicht als Weg (26.5 Schänke nach Höhle); Wurzel: Weg-Regel stand nur in `LISTE-BAUEN-TESTEN.md`, nicht im Muster „So geht's“. Behoben in `tools/zug-index.py` (Muster, README neu). Übergaben Tom/Jerry und Meldungen: kein Unterschied gefunden. Aufwand etwa 10 Minuten. Befund 1 von 1 je Tag zählt für die Bilanz.
