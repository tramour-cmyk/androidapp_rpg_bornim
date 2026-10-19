# 216 · Aktionstaste nach Nähe; Felder kleiner?
Sokrates · 19.10., 13:46 · G Bedienung · M? (Bau Tom)

Chef 13:41: „Können wir die jetzigen Felder, auf denen alles steht und der Held und die NPC gehen, verkleinern, damit der Held näher an Sachen/NPC ran kann und es nicht er nicht so weit entfernt ist? Oder eben auch Garrick am Feuer? Kann die Funktions-/Aktionstaste beim Helden "besser"/unsensibler reagieren? teilweise muss man ziemlich rumeiern, um ein Gespräch zu beginnen... Kann die Aktionstaste den Kamp (neben "Umrennen" des Gegners auf der Karte) ebenfalls auslösen?“

**Heute** (nachgesehen in `Navigation.kt` `actionAhead`, `Game.kt` `interact`, `FreeWalk.kt`): Der Held geht frei in jede Richtung, die Welt liegt aber auf Feldern. Die Aktionstaste prüft genau ein Feld: das Feld, das von dem Feld unter den Füßen des Helden in einer der vier Hauptrichtungen vorn liegt. Steht jemand schräg davor, einen halben Schritt daneben, oder blickt der Held leicht diagonal, findet die Taste nichts. Das ist das Rumeiern. **Kampf über die Taste gibt es schon** (`ActionKind.FIGHT`): Er scheitert am selben Problem, weil ein Monster selten genau auf dem Feld davor steht.

**Frage 216.1 (Aktionstaste):** Soll die Taste nach Nähe statt nach dem Feld davor greifen?
Vorschlag: Die Taste nimmt das nächste Ziel im Umkreis von etwa 1,3 Feldern, gemessen von der wirklichen Stelle des Helden. Bei mehreren Zielen gewinnt das, was in Blickrichtung liegt (Fächer von etwa 120°). Der Held dreht sich zum Ziel. Gilt für Gespräch, Truhe, Schild, Feuer und Monster (Kampf mit Vorteil von hinten wie heute).
**Empfehlung: ja, als Muss.** Es ist ein Bedienfehler, der jedes Gespräch trifft, und damit Fehlerbehebung im Sinne von 179. Der Umfang ist klein: zwei Stellen im Kern, Tests dazu, kein neues Bild. Der Kampf über die Taste kommt dadurch von selbst.
*Stärkstes Gegenargument:* Stehen zwei Ziele nah beieinander (Händler hinter der Theke, daneben ein Fass), greift die Taste vielleicht das falsche. Ausgleich: Personen und Monster gehen vor Dingen, und das Zeichen auf der Taste zeigt vor dem Tippen, was kommt.

**Frage 216.2 (Felder kleiner):** Sollen die Felder kleiner werden?
**Empfehlung: nein.** Alle Karten, Bilder, Wege, Sichtweiten, Monsterwege und die Kampforte hängen an der Feldgröße. Kleinere Felder wären ein Umbau über alle Orte und beide Teams, wochenlang, und sie würden Kapitel 1 aufhalten (179). Die Nähe lässt sich billiger erreichen:
- Mit 216.1 muss der Held nicht mehr genau davor stehen.
- Der Abstand zu Leuten lässt sich verkleinern (heute bleibt der Held etwa 0,7 Felder von ihrer Mitte, 152).
- Garrick kann dichter ans Feuer und der Held dichter an ihn.

Das ist eine Stellschraube je Figur, kein Umbau.
*Stärkstes Gegenargument:* Kleinere Felder machen die Welt feiner, auch für spätere Kapitel. Das gilt, aber dann erst nach dem Meilenstein und als eigene Frage, mit Kosten.

**Berührt:** 152 (Umrunden von Leuten), 215 (Aktionstaste wird auch Übergang: zusammen bauen), Garricks Feuer (Wald, 27).
