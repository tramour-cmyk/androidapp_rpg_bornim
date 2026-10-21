# 283 · Grasbüschel im hohen Gras: weg oder stillhalten?
Sokrates · 21.10., 17:55 · G Stil · M? (Chef 21.10., 17:51, Wortlaut: „Also das Laufen durch hohes Gras oder das Gehen durch hohes Gras, wenn dann dieser hochgestellte Grasbüschel hier so pseudo-animiert ist, das sieht echt nicht gut aus. Also ich glaube, dann lassen wir es lieber ganz weg, wenn das so aussehen soll dauerhaft. Was meinst du?“)

## Befund

Vor die Füße des Helden im hohen Gras wird ein Büschel gezeichnet (`WorldScreen.kt`, „Feet hidden in tall grass“); es wechselt alle 400 ms und bei jedem Schritt zwischen zwei Bildern.

## Frage

- **A:** Büschel ganz weg; Füße sichtbar wie auf dem Weg.
- **B:** ein Bild, still; Füße stecken im Gras. Gefällt es im nächsten Build nicht: A.

- **C (Chef 17:52: „eine Alternative C … schöner hinkriegt“):** Gras bleibt am Boden statt mit dem Helden mitzurutschen: die Halme des Feldes vor der Fußlinie stehen vor ihm; Halme dicht am Helden biegen sich zur Seite und federn zurück. Mehr Arbeit (Tom, etwa ein Tag), mehr Zeichenlast (267 Ruckeln).

**Empfehlung Sokrates:** B jetzt, C nach dem Meilenstein; das Springen und Mitrutschen stört, nicht das Verdecken.
**Stärkstes Gegenargument:** Stört das Büschel selbst (Höhe, Form), hilft B nicht, und es kostet einen Testdurchgang; C jetzt verdrängt Fehler vor Kapitel 1 (oberste Direktive).

**Berührt:** Team Tom (Welt), `WorldScreen.kt` (nur nach Absprache).
