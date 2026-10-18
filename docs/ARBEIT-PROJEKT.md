# Vorrat Perikles

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang, Muss oben. Größe höchstens etwa 15 KB.


Pause aufgehoben 18.10., 21:2x, 187 erledigt (Chef: „Heute Nacht sollen alle arbeiten“, „Perikles soll das Werkzeug ergänzen“, Vorgang 187; 165 Tag 2 erst am 19.10.).

**Gelesen bis:** `origin/main` 18.10., 22:3x (`0ea69153`)

**Übergabe (18.10., 21:3x, „Perikles – 187“): 187 getan, `lauf.py` gibt `source_url` in jeder START-Zeile aus (Feld 4), `LISTE-BETRIEB.md` Schritt 4 angepasst. Nachfolger: keiner nötig (Wochenziel Mo 26.10.).

**Davor (18.10., 16:15, „Perikles – 167.2“) – Nachfolger: Perikles – Wochenziel 26.–31.10. (Mo 26.10., nach Wochenzählung):** 167.2 geprüft und behoben (`lauf.py` schreibt immer nach `bornim-main`, Kosten auch im Archiv, Besetzung ohne Archivierte); `tools/vorgangskosten.py` (Kosten je Hauptthema und Klasse, `--gesamt` Abgleich gegen Sitzungen, im Morgenlauf von Ford); 178 entschieden (Ford prüft Freigaben ohne Merge), Jerry hat 154/155 (#106) und 39 (#107) als Muss, Ford startet ihn ab etwa 16:22. Offen: 177 (Chef, Kosten Ford-Lauf messen), 165. Wochenziel 18.–24.10. (16.10.) gilt; die erste Wochenzählung ist Mo 26.10., ein neues Ziel vorher wäre ungezählt (Start So 18.10., 16:12 war zu früh, nichts getan). Muss-Anteil nur über die Wochenzeilen rechnen.

| Nr. | Kl. | Titel | Stand |
|---|---|---|---|
| 165 | M | Ablaufstichprobe | Dauerzeile, Tag 1 von 5 getan (18.10.), Bilanz 23.10. |
| 185 | K | Ford-Grenze 400.000 Token (Chef 18.10., 19:0x, Wortlaut: „185 ja, aber erst messen. Dann ja.“) | Messung 19.10. (Grenze umgestellt 18.10., 22:4x; Ford meldet Tageskosten 17.–19.10. am 20.10.), dann Auswertung 20.10. an Sokrates |
| 177M | K | Messung: Wartezeit durch Stundenuhr (Chef Weg 2, 18.10.), Entscheid 21.10. | Messung 20.–21.10. |
| 188 | K | von Jerry: `regelcheck`/`startbar` meldet Vorgänge, die in `LISTE-VORGAENGE.md` nicht „erledigt“ sind, aber in keinem Vorrat mehr stehen (Anlass: Chef 18.10. fand 51, 36 noch offen; heute 19 solche) | offen |

## Einzelheiten

- **Zu 165** (Chef Ja 18.10.): Schritt in `ROLLE-PROJEKT.md` Tagesrückblick, Zählung in `ROLLE-PRUEFUNG.md`; Bilanz 23.10.
- **165 Tag 1 (18.10., 17:1x):** Testdateien t25 (Tom) und t26 (Jerry) verglichen. Abweichung: t26 ohne Satz „Ein Weg …, über Build n installieren“ und Reihenfolge nicht als Weg (26.5 Schänke nach Höhle); Wurzel: Weg-Regel stand nur in `LISTE-BAUEN-TESTEN.md`, nicht im Muster „So geht's“. Behoben in `tools/zug-index.py` (Muster, README neu). Übergaben Tom/Jerry und Meldungen: kein Unterschied gefunden. Aufwand etwa 10 Minuten. Befund 1 von 1 je Tag zählt für die Bilanz.
