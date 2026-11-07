# 275.2 · Eine Liste statt Liste plus Vorräte · Sokrates · 07.11., 21:5x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-VORGAENGE.md

**Frage (Chef 07.11., 21:4x: „Das Problem mit den liegen gebliebenen Vorgängen, die nicht gelöscht oder richtig übergeben wurden, wäre das mit einer großen Liste besser gewesen, die wir ja auch schon überlegt hatten.“):** Führen wir 275 zu Ende: eine einzige Tabelle aller Vorgänge mit festen Feldern, die Vorräte behalten nur Übergabe und Einzelheiten?

**Votum Sokrates:** ja, mit zwei Automatiken (unten); allein die Liste hätte nur einen Teil verhindert.

**Berührt:** 275 (zentrale Liste, Stufe 1 seit 27.10., Stufe 2 heute als Warnung), `tools/vorgang.py`, `startbar.py`, `lauf.py`, `regelcheck.py`, alle Vorräte, 620.1.

## Sachverhalt

Heute führen wir jeden Vorgang doppelt: eine Zeile in `LISTE-VORGAENGE.md` und eine Zeile mit eigenem Stand im Vorrat des Besitzers. Die Inventur vom 07.11. fand drei Muster (Befunde der vier Helfer):
1. **Bestandenes wird nicht gestrichen** (t249, t257, t268: Code auf main, Zeile „wartet auf Test“).
2. **Wartegründe veralten** („bis Ende Umzug“, „altes SRD“, „bis 07.11.“), weil sie Freitext sind.
3. **Warten auf eine Rolle ohne Gegenzeile** („wartet auf Perikles“, bei Perikles nichts).
Dazu rund 40 Abweichungen zwischen Liste und Vorrat beim Stand und eine Nummer in zwei Vorräten (532).

## Auswertung: was eine Liste löst

| Muster | Nur eine Liste | Liste + Automatik |
|---|---|---|
| 3 Warten auf Rolle | **gelöst**: die Zeile erscheint beim Wartenden und beim Erwarteten | gelöst |
| Doppelte Stände, 532 doppelt | **gelöst**: nur ein Stand | gelöst |
| 2 veraltete Wartegründe | nicht gelöst | **gelöst** mit Feld „wartet auf“ als Nummer, Rolle oder Datum: ist die Nummer erledigt oder das Datum vorbei, wird die Zeile von selbst startbar |
| 1 Bestandenes nicht gestrichen | nicht gelöst | **gelöst**, wenn das Mischen eines Builds auf main jede bestandene Nummer der Prüfliste auf erledigt setzt (ein Befehl, `vorgang.py build <Nr>`) |

**Stärkstes Gegenargument:** Deine Bedingung von 275 („nur ja, wenn es nicht 1000 Tokens extra kostet“): Die Liste hat 39 KB, Toms Vorrat 128 KB. **Entkräftet:** Keine Sitzung liest die ganze Liste; `vorgang.py --rolle Tom` zeigt nur die eigenen Zeilen, kleiner als heute der Vorrat. **Zweites Gegenargument:** Umbau mitten in der Arbeit, alle Werkzeuge lesen heute die Vorräte. **Entkräftet:** Perikles baut es in einem Zweig, die Werkzeuge lesen beides, bis Diogenes eine Woche ohne Fehler zählt (wie Stufe 1).

## Folgerungen

- **Ja:** Perikles baut (275.2): Felder Nr, Titel, Besitzer, Kl., Stand, wartet auf, Zweig, Build; Vorräte nur noch Übergabe und „Zu“; die zwei Automatiken; einmal alles übertragen (die Inventur hat aufgeräumt). Schätzung 2–3 Sitzungen.
- **Nein:** Es bleibt bei Liste plus Vorrat; die Inventur wiederholt Diogenes jede Woche.

Antwort: „275.2 ja“ oder „nein“.
