# 602 · Gemeinsamer Build nach Tom 591/592 und Jerry 548–544? · Ford · 06.11., 08:10

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/5ad877d3a/tools/startbar.py

**Frage:** Soll nach dem Ende der beiden laufenden Sitzungen (Tom 591, 592; Jerry 548, 545, 562, 544) ein gemeinsamer Build für deinen Test gebaut werden?

**Votum Ford:** ja; `startbar.py` zählt 56 gebaute Vorgänge, die auf Test warten (Tom 39, Jerry 17; Grenze 317: höchstens 6 je Build, ab 4 bittet der Erste). Der Build kostet vor allem Bauzeit am Bauserver, wenig Guthaben; ohne ihn bleiben die Rückläufer ungeprüft.

**Berührt:** Team Tom, Team Jerry, 287 (Woche über 95 %), 468e.

## Stärkstes Gegenargument

Woche über 95 %: auch das Zusammenführen der Zweige und die Testbitte kosten eine Sitzung; wird das Guthaben vorher leer, bleibt der Build halb liegen. Dann besser nach der Zurücksetzung Sa 20:00.

## Folgerung

Antwort „602 ja“: Ford startet nach Ende der laufenden Sitzungen den Build beim Team mit den meisten wartenden Vorgängen (Tom). „602 Sa“: nach der Zurücksetzung.
