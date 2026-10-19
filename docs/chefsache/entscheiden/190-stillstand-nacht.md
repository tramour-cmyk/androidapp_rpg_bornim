# 190 · Stillstand Nacht 19.10.: lauf.py und startbar.py anpassen
Sokrates · 19.10., 07:05 · B Steuerung · setzt Perikles um (`tools/lauf.py`, `tools/startbar.py`)

Kurz: 03–07 Uhr lief nichts, obwohl Jerry, Homer und Diogenes Startbares hatten; sechs Änderungen am Werkzeug, Empfehlung alle

**Frage** (Chef 19.10., 07:03, Wortlaut): „warum wieder die letzten 5 Stunden keiner mehr was gemacht hat, obwohl noch sicherlich was da gewesen wäre. Und wie wir lauf.py anpassen können, damit das nicht wieder passiert … Oder halt Abhängigkeiten voneinander. Wie können wir die auflösen?“

**Ursachen:** (1) `startbar.py` hält „gebaut“ für startbar; `lauf.py` nimmt nur die oberste Kür, Ford lehnt sie ab, die nächste (Jerry D29.1, 27o, D3, 86.11, 141) kommt nie dran. (2) Homer laut `lauf.py` nur Muss; seine Texte 72.10a.8T/.9T/.11T, auf die Jerry wartet, sind Kür (Regel 162 nicht im Werkzeug). (3) Diogenes' Zeile 186.3 „wartet auf Chef“ hielt die fertige Sitzung 71 als Hindernis fest, Diogenes belegt (behoben 19.10., 07:0x). (4) Wochenziel schließt 72u, 72.10 aus, der Vorrat führt sie als startbare Kür; Ford urteilt selbst. (5) Übernahme gesperrt, solange die Niederlassung ruht (159), obwohl Jerry in der Zentrale läuft. (6) Uhr aus 03–06 (99h) auf Grund von (1). (7) Build 31 und 32 warten auf den Test des Chefs.

**Empfehlung: 190.1–190.6 ja.**
- **190.1** `startbar.py`: Stand „gebaut…“ = wartet auf Test/Build.
- **190.2** `lauf.py`: oberste startbare Zeile, die Ford nicht ausgeschlossen hat (Ausschluss mit Grund im Protokoll).
- **190.3** `lauf.py`: Zeile, auf die ein anderer Vorrat wartet, wird Muss (162 im Werkzeug); Homer sonst weiter nur Muss.
- **190.4** `lauf.py`: „wartet auf Chef“ hält nur die Sitzung dieser Zeile, nicht die Rolle.
- **190.5** Was das Wochenziel ausschließt, setzt Perikles im Vorrat auf „nach dem Meilenstein“.
- **190.6** Übernahme zwischen den Teams wieder erlaubt, solange beide in der Zentrale laufen; Uhr aus nur, wenn alle Vorräte leer sind.
- Zu (7): Jerry baut einen Sammelbuild 31 + 72.10a.9 + .11, ein Test statt zwei.

**Stärkstes Gegenargument:** mehr Starts in der Nacht kosten Guthaben (Homer-Texte, Übernahmen); ein größerer Sammelbuild ist schwerer zu prüfen. Dagegen: eine leere Nacht kostet Zeit bis zum Meilenstein, und Kür bleibt unter Direktive 179 auf Kapitel 1 beschränkt.

**Berührt:** 99h, 159, 162, 118, 186.3, 72u.1, 72.10a.8–.11, `LISTE-BETRIEB.md`, `CLAUDE.md` 6 (Übernahme).
