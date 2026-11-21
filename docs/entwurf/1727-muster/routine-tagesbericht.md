# 1727, Routine Tagesbericht (Entwurf Perikles 21.11., 20:15, ungeprüft)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`, schließt L-O8. **Nur Anschauung, nicht in Betrieb;** bis zur Umstellung schreibt Perikles nach `ROLLE-PROJEKT.md` „Tagesbericht“ (448).

Lädt: Sockel + dieser Auftrag, ohne Gruppe und Kern (Routine, VA 20.11., 07:53). Muster 6b/6d.

Quellen: 448 (Chef 01.11., 11:09), `ARBEIT-TAGESBERICHT.md` (zehn Zeilen), `tools/tagesbericht.py`, Gesamtbild 4.4 Zeile Perikles „Tagesbericht“ (Werkzeug, Sitzung nur für Wertungssätze), VA 20.11., 08:19 (Wochenguthaben im Tagesbericht), 19.11., 17:44 (Wochenziel fällt, Reihenfolge der Themenblöcke), `ablauf.md` A3 (Vorgang ohne Auftrag nach 1 Tag), A13 (Testbitte 5 Tage), `werkzeuge.md` L-O16 (Frage an den Chef ohne Erinnerung).

## Text

```markdown
Ziel: der Chef sieht morgens in einer Minute, wo das Spiel steht und was auf ihn wartet. Du schreibst nur, was das Werkzeug nicht rechnen kann.

1. `python3 tools/tagesbericht.py` schreibt die Zahlen in `docs/ARBEIT-TAGESBERICHT.md`. Hält es an oder fehlt eine Zahl: „fehlt“ und warum, weiter.
2. Du schreibst drei Sätze, je mit Quelle: **Wo stehen wir** (Themenblock oben in der Reihenfolge des Chefs, was seit gestern abgenommen ist, was als Nächstes kommt); **Größtes Risiko** (eins, mit Zahl); **Wartet auf dich** (älteste Testbitte, Frage, Chefsache mit Alter, Link).
3. Fällt dir etwas auf, das kein Werkzeug meldet (Vorgang ohne Bewegung, Widerspruch zwischen Zahlen): Befund mit Beleg ans Büro, nicht in den Bericht.
4. Pushen, dann `python3 tools/tagesbericht.py --telegram` mit `tools/meldung.sh --laut`.

Du bewertest keine Arbeit und setzt keinen Vorrang.
```

## Was das Werkzeug dafür zusätzlich zählen muss (Vorschlag)

Wochenguthaben (VA 08:19), Testbitten älter als 5 Tage (A13), Vorgänge ohne Auftrag älter als 1 Tag (A3), Fragen an den Chef ohne Antwort mit Alter (L-O16), „getestet unter Unveröffentlicht“ und Alter des letzten Release (Profil Release Frage 1). Zeile 3 „Rest geschätzt“ (Schätzungen von Tom und Jerry) fällt mit den Rollen; Ersatz: Stand je Themenblock aus der Vorgangsliste.

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Routine Tagesbericht** | `lauf.py` „Tagesbericht anstoßen“, täglich 7:30, Sa/So 9:30 (448; besteht, G:919); Disponent startet | `tagesbericht.py`, Vorgangsliste, Chefsache | `ARBEIT-TAGESBERICHT.md` gepusht; Sitzung endet | Telegram mit Ton (morgens, nicht nachts) | Chef liest; Befunde → Büro (Eingang) | offen: neue Zahlen im Werkzeug (oben); Fehlt-Meldung um 10 Uhr (heute Ford) trägt künftig die Routine Wache |

## Offen, Fragen

1. **Startet der Disponent oder das Werkzeug?** Heute gibt `lauf.py` die Zeile an Perikles aus. Routinen startet laut G:475 „ein Werkzeug, nicht das Büro“ (dort für Wache und Uhr). Vorschlag: `lauf.py` gibt die Startzeile aus, der Disponent führt sie aus wie jeden Start (Startsperre); eine eigene Startart nur für Routinen wäre Mechanik mehr.
2. **Vorratsprüfung 1425** fällt mit den Vorräten (4.4); prüft das Werkzeug künftig Vorgangsdateien, gehört sein Ergebnis als Zahl in den Bericht, nicht als Arbeit der Routine.
3. **Roadmap, Wer hinkt, Prioritäten** (heute von Hand) fallen: Vorrang setzt der Chef mit der Reihenfolge der Themenblöcke, Rollen fallen.

## Stärkstes Gegenargument

Eine eigene Sitzung je Tag für drei Sätze ist teuer; das Werkzeug allein könnte melden. **Dagegen:** „Wo stehen wir“ und „Größtes Risiko“ verlangen Urteil über Zahlen, das kein Skript liefert; die Routine liest nur den Bericht und die Liste, nicht den Verlauf, und endet danach. Maß: sinkt die Zahl „Chef fragt nach dem Stand“ nicht, fällt die Sitzung und das Werkzeug meldet allein.
