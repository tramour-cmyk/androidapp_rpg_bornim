# 620.1 · Grenze angefangener Arbeit je Team (B) · Perikles · 07.11., 21:0x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/VORGANGSARCHIV.md

**Rückfrage zu B (Chef 07.11., 21:00: „620.1 A und bei B gerne auch mehr rein in den Build mit sinnvoller Testreihenfolge“; A ist gebaut):** Richtig verstanden?

1. Hat ein Team 6 gebaute Pflichtaufgaben, die auf deinen Test warten, bittet es um den gemeinsamen Build.
2. In diesen Build kommt alles Fertige beider Teams, ohne Obergrenze (wie 317 seit heute 20:5x), die Prüfliste als Weg durchs Spiel.
3. Bis zu deinem Test fängt das Team keine neue Pflichtaufgabe an, nur Wiederholtes, „jetzt“ und Übernahmen vom anderen Team.

**Votum Perikles:** 1, 2, 3 ja.

**Berührt:** 620, 317, 625 (Sammelbuild 269), `tools/startbar.py`, `tools/lauf.py`, `LISTE-BAUEN-TESTEN.md`.

## Begründung

Ohne 3 ist B nur ein Auslöser für den Build; mit 3 wächst der Stapel ungetesteter Arbeit nicht weiter (heute laut Werkzeug Tom 21, Jerry 14, teils überholte Stände).

## Stärkstes Gegenargument

3 kann ein Team anhalten, wenn du ein paar Tage nicht testest. **Entkräftet:** es bleiben Wiederholtes, „jetzt“ und Übernahmen; ein siebter ungetesteter Punkt wäre Arbeit auf Vorrat, deren Fehler du später findest.

## Folgerungen

Bei „1, 2, 3 ja“: `startbar.py` und `lauf.py` sperren neues Muss ab 6 Wartenden je Team und melden die Bitte um den Build (Perikles, zusammen mit 317.1). Bei „1, 2 ja“: nur die Meldung, keine Sperre.

**Zu sagen:** „1, 2, 3 ja“, „1, 2 ja“ oder was anders sein soll.
