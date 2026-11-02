# 427 · Monsterwerte Kapitel 1: neue Startwerte nach Messung?
Sokrates · 02.11., 15:12 · E Kampf

**Frage:** Sollen die Monsterwerte im Bestiarium („Werte 2.0“) durch die gemessenen neuen Werte unten ersetzt werden? Danach übernimmt Jerry sie in `godot/regeln/brs.gd` (473).
**Votum Sokrates:** ja. Ein Zug ist ein Schlagabtausch (du, dann der Gegner). Gewöhnliche Kämpfe dauern im Mittel je Herkunft 3,4 bis 6,3 statt 2,3 bis 4,0 Züge; mindestens jeden zweiten Bosskampf (alle drei Bosse, Held auf Bossstufe) gewinnen neu vier Herkünfte statt einer, das Jägerkind knapp darunter (46 % gegen Grak).
**Berührt:** 427, 444 (Simulation), 473 (Daten im Spiel), 447.4 (Lehrmeister), Herkünfte (Befund unten).

## Was sich ändert

| Was | Heute | Neu |
|---|---|---|
| Leben gewöhnlicher Arten | wie im Bestiarium | Stufe 1 × 2,0 · Stufe 2 × 1,8 · Stufe 3 × 1,4 · Stufe 4 × 1,1 · Stufe 5 × 0,9 |
| Schaden gewöhnlicher Arten | wie im Bestiarium | Stufe 1–2 × 0,8 · Stufe 3 × 0,9 · Stufe 4–5 × 0,85 |
| Einzeln | – | Zombie Leben 44 (statt 61), sonst Kämpfe bis 11 Züge; Riesenspinne Angriff 25 (statt 30) |
| Krogg (Stufe 4) | Leben 41, Rüstung 3, Schaden 11, Angriff 25 | Leben 55, Rüstung 2, Schaden 7, Angriff 20 |
| Grimmzahn (Stufe 5) | Leben 39, Rüstung 2, Schaden 8, Angriff 30 | Leben 55, Rüstung 2, Schaden 7, Angriff 22 |
| Grak (Stufe 6) | Leben 58, Rüstung 3, Schaden 8, Angriff 40 | Leben 75, Rüstung 2, Schaden 7, Angriff 25 |

Neue Werte je Art (Abwehr und Wachsamkeit bleiben):

| Art | Stufe | Leben | Rüstung | Schaden | Angriff |
|---|---|---|---|---|---|
| Riesenratte | 1 | 20 | 1 | 3 | 10 |
| Kobold | 1 | 24 | 1 | 3 | 10 |
| Blutflügler | 1 | 18 | 2 | 3 | 15 |
| Wolf | 2 | 25 | 1 | 6 | 15 |
| Wildschwein | 2 | 29 | 0 | 3 | 10 |
| Riesen-Hundertfüßer | 2 | 22 | 1 | 3 | 15 |
| Goblin | 2 | 18 | 2 | 5 | 15 |
| Goblin-Späher | 2 | 22 | 1 | 5 | 15 |
| Skelett | 2 | 36 | 1 | 5 | 15 |
| Zombie | 2 | 44 | 0 | 3 | 10 |
| Riesenfledermaus | 3 | 46 | 1 | 5 | 20 |
| Goblin-Schamane | 3 | 29 | 1 | 4 | 15 |
| Riesenspinne | 4 | 43 | 2 | 7 | 25 |
| Ghul | 4 | 37 | 1 | 6 | 25 |
| Ockerschleim | 5 | 44 | 0 | 5 | 30 |
| Krogg (Boss) | 4 | 55 | 2 | 7 | 20 |
| Grimmzahn (Boss) | 5 | 55 | 2 | 7 | 22 |
| Grak (Boss) | 6 | 75 | 2 | 7 | 25 |

## Gemessen (Simulation 444, je Fall 1000 Kämpfe, 400 Läufe je Herkunft)

Held auf der Stufe des Bosses (Krogg 4, Grimmzahn 5, Grak 6), Anteil gewonnener Kämpfe:

| Herkunft | Krogg heute → neu | Grimmzahn heute → neu | Grak heute → neu | Kämpfe bis Stufe 6 |
|---|---|---|---|---|
| Wachsoldat | 75 % → 100 % | 99 % → 100 % | 86 % → 100 % | 20 → 19 |
| Jägerkind | 26 % → 66 % | 80 % → 77 % | 27 % → 46 % | 23 → 21 |
| Zauberlehrling | 25 % → 73 % | 78 % → 82 % | 29 % → 54 % | 24 → 22 |
| Klosterschüler | 24 % → 96 % | 96 % → 98 % | 29 % → 81 % | 19 → 18 |
| Kräutersammler | 0 % → 2 % | 8 % → 5 % | 0 % → 0 % | 29 → 27 |
| Schmiedelehrling | 15 % → 47 % | 60 % → 60 % | 9 % → 29 % | 23 → 21 |
| Herumtreiber | 15 % → 46 % | 66 % → 66 % | 12 % → 32 % | 25 → 22 |
| Wanderer | 42 % → 72 % | 82 % → 84 % | 36 % → 57 % | 23 → 22 |

- Bosskämpfe dauern neu 6 bis 10,5 Züge (heute 4,5 bis 8,6); Ausnahmen Klosterschüler 16 bis 21 (Heilung) und Kräutersammler 10 bis 14 (verliert fast immer).
- Gewöhnliche Gegner, Held auf ihrer Stufe: Arten der Stufe 1 heute 1,3 bis 2,9 Züge, neu 2,5 bis 5 (ohne Kräutersammler; mit ihm bis 6,3). Länger bleiben Ockerschleim (8 bis 12) und Klosterschüler gegen Riesenspinne (13). Gewonnen im Mittel aller Arten 95 bis 100 %, Kräutersammler 74 %.
- Bis Stufe 6 (Ende Kapitel 1) braucht der Held nur aus Kämpfen weiter 18 bis 27 Kämpfe; Erfahrung aus Quests kommt dazu.

## Was Monsterwerte nicht lösen (Herkünfte, eigener Vorgang nach deinem Wort)

Die Unterschiede zwischen den Herkünften liegen am Helden, nicht am Monster: jede Stellschraube am Monster trifft alle gleich.
1. **Wachsoldat** gewinnt jeden Kampf (Schild und mittlere Rüstung von Anfang an).
2. **Kräutersammler** hat keinen Kampfweg: 0 bis 5 % gegen jeden Boss, 10 % gegen die Riesenspinne. Die Simulation lässt ihn ohne Tränke und Alchemistenfeuer kämpfen; im Spiel hätte er sie.
3. **Klosterschüler** heilt sich in lange Kämpfe (bis 21 Züge gegen Grak).
4. **Bewährungsprobe** kommt in Kapitel 1 weiter nicht vor (beste Fertigkeit bei Stufe 6 neu 15 bis 23, heute 13 bis 20; die Decke liegt bei 24); damit läuft 447.4 weiter leer, wenn auch knapper. Stellschraube: Übung je Treffer, nicht die Monster.

## Auswertung

- **Stärkstes Gegenargument:** Die Simulation rechnet eins gegen eins, ohne Rudel, ohne Hinterhalt, ohne Merkmale (Gift, Umreißen, Zäher Tod), ohne Tränke, mit vollem Leben vor jedem Kampf. Im Spiel kann es also deutlich härter (Wolfsrudel) oder leichter (Tränke) sein.
- **Entkräftet:** Die Werte sind Startwerte für den ersten spielbaren Stand; gemessen wird danach im Spiel mit dem Kampflog, und die Simulation bekommt Rudel und Tränke, bevor die Herkünfte angepasst werden. Die Richtung (längere Kämpfe, schaffbare Bosse) hängt nicht an diesen Lücken.
- **Gegen „gleich die Herkünfte mitmachen“:** Herkünfte berühren Erschaffung (470), Ausrüstung und Aussehen; das ist eine eigene Entscheidung.

**Zu sagen:** „427 ja“ (Werte ins Bestiarium, Jerry übernimmt), „427 ja, Herkünfte auch“ (zusätzlich Vorschlag zu 1–4), oder was anders sein soll.
