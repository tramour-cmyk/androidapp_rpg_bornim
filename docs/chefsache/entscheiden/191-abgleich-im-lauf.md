# 191 · Abgleich als Werkzeug in jedem Lauf statt auf Zuruf
Sokrates · 19.10., 07:24 · B Steuerung · setzt Perikles um (`tools/abgleich.py`, Aufruf in `tools/lauf.py`)

Kurz: was Sokrates gestern und heute auf Zuruf prüfte (Kosten, Vorgänge ohne Vorrat, Entschiedenes ohne Umsetzung), rechnet künftig ein Skript in jedem Lauf; kein Wecker, keine Sitzung

**Frage** (Chef 19.10., 07:21, Wortlaut): „Wieso kann das nicht automatisiert auch funktionieren? … irgendeiner, wenn läuft, kann doch da mal querchecken … Kann man da dafür einen Wecker stellen? Macht ein Wecker Sinn? … Dreimal am Tag Kosten querchecken … Gibt es wieder irgendwelche Aufträge ohne Vorgangsnummer? Gibt es wieder irgendwelche irgendwas?“

**Empfehlung: ja, als Skript, nicht als Wecker.** Ein Wecker weckt eine Sitzung (Geld, und sie deutet); ein Skript in Fords stündlichem Lauf kostet nichts und rechnet immer gleich (Leitlinie 166: was eine Maschine rechnen kann, nicht deuten lassen). `tools/abgleich.py`, von `lauf.py` in jedem Lauf gerufen, gibt WARNUNG-Zeilen aus; Ford trägt jede in den Vorrat des Besitzers ein (Eingang, wenn unklar), Kosten bucht das Werkzeug selbst:
1. **Kosten:** jede Sitzung mit `cost_usd`, die 60 Minuten ruht, wird gebucht, auch ohne Archivieren (von Hand gestartet, festgehalten); ein Buchungsverzeichnis (Sitzung → Vorgang, Betrag) bucht später nur die Differenz nach. Titel ohne Vorgangsnummer → WARNUNG.
2. **Vorgänge:** offen in `LISTE-VORGAENGE.md` ohne Vorrat (gibt es, 188); Zeile im Vorrat ohne Zeile in der Liste; Nummer im Vorgangsarchiv, deren Stand nicht „erledigt“ ist und keine Umsetzungszeile hat (Muster 168).
3. **Stand:** „gebaut/zu testen“, dessen Zweig laut `CHANGELOG.md` zusammengeführt ist → erledigt (Muster 93, 94, 96, 100); Termin vorbei, Zeile unverändert (Muster 99g).
4. **Zusagen:** „Nachfolger:“ nicht gestartet (190.7), „M?“ offen (190.8).

**Stärkstes Gegenargument:** ein Skript findet nur, was man ihm beigebracht hat; neue Fehlerarten fallen weiter dir auf. Dagegen: dafür gibt es die Ablaufstichprobe (165, Perikles im Tagesrückblick) und die Wochenzählung (Diogenes); was sie finden, wird eine neue Prüfung im Skript statt eine neue Regel (Regelbilanz).

**Berührt:** 166, 165, 188, 190, `tools/lauf.py`, `tools/vorgangskosten.py`, `LISTE-BETRIEB.md` Schritt 4.
