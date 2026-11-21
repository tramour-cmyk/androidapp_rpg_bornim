# 1727, Routine Tagesbericht (Fassung 2, Perikles 21.11., 20:19, nach Gegenprüfung 20:18)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`, schließt L-O8. **Nur Anschauung, nicht in Betrieb;** bis zur Umstellung schreibt Perikles nach `ROLLE-PROJEKT.md` „Tagesbericht“ (448).

Lädt: Sockel + dieser Auftrag, ohne Gruppe und Kern (Routine, VA 20.11., 07:53). Start: `lauf.py` gibt die Startzeile aus (täglich 7:30, Sa/So 9:30; besteht), der Disponent startet wie jede Sitzung.

Quellen: 448 (Chef 01.11., 11:09), `ARBEIT-TAGESBERICHT.md`, `tools/tagesbericht.py` (liest „Eingaben“ `:87`, `:235`; zählt „Wartet auf dich“ `:227`; hält bei Funden der Vorratsprüfung `:325–335`), Gesamtbild 4.4 Zeile Perikles „Tagesbericht“, VA 20.11., 08:19 (Wochenguthaben), 19.11., 17:44 (Wochenziel fällt), `ablauf.md` A3, A13, `werkzeuge.md` L-O16.

## Text

```markdown
Ziel: der Chef sieht morgens in einer Minute, wo das Spiel steht und was auf ihn wartet. Du schreibst nur, was das Werkzeug nicht rechnen kann.

1. In `docs/ARBEIT-TAGESBERICHT.md` unter „Eingaben“ zwei Sätze, je mit Quelle: **Wo stehen wir** (Themenblock oben in der Reihenfolge des Chefs, was seit gestern abgenommen ist, was als Nächstes kommt); **Größtes Risiko** (eins, mit Zahl).
2. `python3 tools/tagesbericht.py`; fehlt eine Zahl: „fehlt“ und warum.
3. Fällt dir etwas auf, das kein Werkzeug meldet: `tools/vorgang.py neu` mit Bereich und Beleg, Absender „Tagesbericht“, dann Wecker an den Disponenten.
4. Pushen, dann `python3 tools/tagesbericht.py --telegram` mit `tools/meldung.sh --laut`.

Du bewertest keine Arbeit und setzt keinen Vorrang.
```

## Werkzeug (Vorschlag, mit 1739)

- Halt bei Funden der Vorratsprüfung 1425 fällt mit den Vorräten.
- Zusätzlich zählen: Wochenguthaben (VA 08:19), Testbitten älter als 5 Tage (A13), Vorgänge ohne Auftrag älter als 1 Tag (A3), Fragen an den Chef ohne Antwort mit Alter (L-O16), getestete Themen unter „Unveröffentlicht“ und Alter des letzten Release (Profil Release).
- Zeile 3 „Rest geschätzt“ (Schätzungen von Tom und Jerry) fällt mit den Rollen; Ersatz: Stand je Themenblock.
- „Wartet auf dich“ zählt das Werkzeug schon (Zeile 4); kein Satz der Routine.

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Routine Tagesbericht** | `lauf.py`-Startzeile 7:30 (Sa/So 9:30), Disponent startet; fehlt er um 10 Uhr (Sa/So 12 Uhr), meldet die Wache, Disponent startet neu | `tagesbericht.py`, Vorgangsliste, Chefsache | `ARBEIT-TAGESBERICHT.md` gepusht; Sitzung endet | Telegram mit Ton | Chef liest; Befunde als Vorgang, Wecker an den Disponenten | offen L-O1 (Eingang ohne Ort; hier über `vorgang.py neu` umgangen); Werkzeugzahlen oben |

## Stärkstes Gegenargument

„Wartet auf dich“ und Zahlen liefert das Werkzeug; bleiben zwei Sätze, eine tägliche Sitzung dafür widerspricht dem Sparen. **Dagegen:** „Größtes Risiko“ verlangt Urteil über mehrere Zahlen; die Sitzung liest nur Bericht und Liste und endet. Maß: nach zwei Wochen fragt der Chef, ob er die zwei Sätze liest; sonst fällt die Sitzung und das Werkzeug meldet allein.

## Gegenprüfung 20:18, mein Wort

12 Starter widersprüchlich: **stimmt**, Disponent startet alle Routinen (auch im Profil Disponent) · 13 Reihenfolge, Halt 1425, „Wartet auf dich“ doppelt: **stimmt**, Eingaben vor dem Lauf, Halt ins Werkzeug, Satz gestrichen · 14 Befund ans Büro ohne Weg: **stimmt**, `vorgang.py neu` plus Wecker · Gegenargument (ein Satz reicht dem Werkzeug): **Einwand**, Risiko braucht Urteil; Maß nach zwei Wochen.
