# 340.2 · Rollenspiegel 02.11.: drei Werkzeuge gegen drei Muster?
Sokrates · 02.11., 19:4x · B Abläufe

**Frage:** Alle sieben Rollen haben geantwortet (`LISTE-ROLLENSPIEGEL.md`, Woche 06.11.). Sollen gegen die drei Muster unten drei Werkzeuge gebaut werden (Bau Perikles), jedes mit einer Zahl, die Diogenes am Montag 09.11. prüft?

**Votum Sokrates:** ja zu A, B und C.

**Berührt:** `tools/notiz.sh`, `tools/zug-index.py`, Prüfprogramme der Sitzungen (`.claude/settings.json`), `DESIGN-ABNAHME.md`, `CLAUDE.md` „Bekannte Fehler“.

## Die drei Muster

Zusammen erklären sie, warum du diese Woche fünfmal etwas als Erster gefunden oder nachfragen musstest (Diogenes, Perikles, Jerry, Tom, ich).

1. **Gesehen und geschwiegen, oder nicht nachgesehen:** alle sieben. Gesehen und nicht gemeldet: Tom und Homer die zu großen Vorräte (Homer zum zweiten Mal), Ford den Fehler in `lauf.py`, Jerry, dass ein Messlauf ohne Film als Probelauf zählt, Perikles falsche Zählungen, die er still entfernte. Nicht nachgesehen: Diogenes zählte den ausgefallenen Rollenspiegel vom 30.10. nicht; ich sah erst auf deine Frage, dass 466 seit 11:20 bei Homer lag.
2. **Als fertig gemeldet, ohne an dem zu prüfen, was du siehst:** fünf von sieben. Tom filmte ein Raster mit sechs Feldern statt den Dorf-Film, den du gut fandest; Jerry maß die Strahlen im Raum, nicht durch die Spielkamera; Perikles prüfte 407 an gebauten Fällen statt an echten Läufen, und 407 griff nicht; Diogenes prüfte Werkzeuge nur in einer Kopie; Homer meldete 461d ohne fremde Prüfung fertig.
3. **Uhrzeit geschätzt:** drei von sieben (Tom 19:22 statt 19:10, Perikles 11:33 und 11:38, ich 19:24 statt 19:21), obwohl das der erste „bekannte Fehler“ in `CLAUDE.md` ist. Bei mir geschah es am Ende eines langen Arbeitsschritts, als die letzte Uhrzeile schon alt war.

## Die drei Werkzeuge

**A, Hinweise gehen selbst an den Besitzer.** Was `notiz.sh` beim Start meldet (Datei zu groß, Zeile zu lang; heute 8 Hinweise), schreibt das Werkzeug einmal am Tag als Zeile „von Werkzeug“ in den Vorrat des Besitzers; die Zeile ersetzt die vom Vortag. Dann muss das keiner mehr melden, und jeder sieht seine eigenen.
- Erwartet: von 8 Hinweisen auf höchstens 2 am 09.11.
- Gegenargument: noch mehr Zeilen in Vorräten, die schon zu groß sind. Lösung: eine Zeile je Besitzer.
- Was ein Werkzeug nicht sieht (`lauf.py`, 466), fängt A nicht; dafür bleibt Haltung 4.

**B, „Geprüft an“ als Pflichtfeld.** Jede Datei in der Chefsache und jeder Stand „gebaut“ nennt in einer Zeile „Geprüft an: <Link auf Film, Bild oder echten Lauf>“; ohne diese Zeile nimmt `zug-index.py` das Hochladen nicht an. Vor jeder neuen Probe die Frage aus Toms Antwort: gibt es schon ein Bild, das du gut fandest? Dann wird nur die Abweichung gezeigt.
- Erwartet: höchstens zwei Runden je Aussehensfrage bis „passt“ (Toms eigener Vorschlag; 417 brauchte fünf), Diogenes zählt aus dem Archiv.
- Gegenargument: ein Pflichtfeld wird mechanisch gefüllt („Geprüft an: Messung“). Lösung: das Werkzeug verlangt einen Link, kein Wort.
- Dafür fällt in `DESIGN-ABNAHME.md` „Vor jeder Vorlage“ ein Satz weg, der dasselbe nur verlangt (Perikles wählt ihn).

**C, Uhrzeit nach jedem Arbeitsschritt.** Jedes Ergebnis eines Arbeitsschritts bekommt die Zeile „Uhr: HH:MM“ angehängt. Dann steht auch in langen Schritten die echte Zeit da.
- Erwartet: kein falscher Zeitstempel in der Woche bis 09.11. (Zähler im Prüfprogramm `zug-haken.py`).
- Gegenargument: jede Ausgabe wird eine Zeile länger; das kostet fast nichts.
- Dafür wird der erste bekannte Fehler in `CLAUDE.md` kürzer: „Nie die Uhrzeit schätzen; stattdessen die letzte Uhrzeile.“

## Stärkstes Gegenargument

Vier Rollen sagen selbst, dass sie zu viel an Abläufen und zu wenig am Spiel arbeiten (Diogenes 80 %, Perikles 60 %, Tom, ich). Drei neue Werkzeuge sind noch mehr Abläufe. **Entkräftet:** A und C nehmen Handarbeit weg (Melden, Uhr nachsehen), nur B fügt ein Feld hinzu, und für B und C fällt je ein Satz weg. Der Bau ist klein (geschätzt eine Sitzung Perikles für alle drei). Gemessen wird am 09.11.; wirkt eines nicht, fällt es wieder weg.

## Dazu für dich (aus Fords Antwort)

Ford darf alte Sitzungen nicht archivieren; die Prüfung der Sitzung lehnt es ab (02.11., 15:33, 16:08). Drei alte Sitzungen (Ford, Tom, Jerry) bleiben offen, die Kosten des alten Ford (9,57 $) sind nicht gebucht. Das kannst nur du lösen: die drei von Hand archivieren oder die Ablehnung aufheben.

**Zu sagen:** „340.2 ja“ (A, B, C an Perikles) oder einzeln, etwa „340.2 A und C“.
