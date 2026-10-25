# 348.6 · Wo steht die Sonne, und wie hell soll das Dorf sein?
Tom · 25.10., 12:15 · G Stil · Muss
Kurz: Sonne in Godot: mit der Uhr wie in der Natur? Helligkeit dämpfen wie alt?

## Frage

1. Wo steht die Sonne?
   - a: wie im alten Spiel: morgens im Osten, mittags etwa im Norden (Schatten fallen zum Betrachter), abends im Westen;
   - b: wie in der Natur: morgens im Osten, mittags etwas westlich von Süden, abends im Westen;
   - c: eine feste Sonne für alle Tageszeiten, schräg von der Seite (etwa Südwest), ohne Lauf über den Tag;
   - so wie heute in Godot (feste Sonne fast genau hinter dem Betrachter) empfehle ich nicht.
2. Soll das Dorf am Tag gedämpfter wirken? ja (etwa wie alt) / etwas / nein.

## Votum

1 b, 2 ja. Die Sonne wechselt wie im alten Spiel nur an einem Schnitt (Kartenwechsel, Rasten, Laden), nie, während man hinsieht.

## Berührt

348.6 (Umzug Godot, Dorf; danach jede Gebietskarte).

## Begründung

- Zu 1: Die Windrose oben zeigt jetzt, wo Norden ist. Eine Mittagssonne aus Norden fällt damit auf, wie dir am Schatten der Kirche. Seitliches Licht gibt den Häusern eine helle und eine dunkle Seite.
- Zu 2: Das alte Spiel wirkt düsterer, das entspricht dem Leitbild („Düster, erwachsen“).

## Sachverhalt

- **Alt** (Werkzeug `MapSun.kt`): Die Sonne hat drei Stände.
  - morgens (bis 10 Uhr): lange Schatten nach Westen;
  - mittags (10–15 Uhr): kurze Schatten etwa nach Süden, also zum Betrachter; die Sonne steht dann etwa im Norden;
  - ab 15 Uhr: lange Schatten nach Osten.
- **Neu** (`licht.gd`): Es gibt eine feste Sonne aus Süd-Südost, 50° hoch. Die Kamera blickt in der Grundansicht nach Nordwest. Damit steht die Sonne fast im Rücken des Betrachters: Fassaden sind flach und hell, Schatten fallen nach hinten weg. Darum wirkt es neben dem alten Bild umgekehrt.
- **Helligkeit am Tag**, gemessen in der Bildmitte ohne Leiste (0 = schwarz, 255 = weiß; Ausschnitte nicht ganz deckungsgleich):

  | Bild | alt: Mittel | neu: Mittel | alt: Streuung | neu: Streuung |
  |---|---|---|---|---|
  | Marktplatz | 65 | 104 | 21 | 40 |
  | Kirche | 57 | 81 | 24 | 44 |
  | Laden | 53 | 78 | 23 | 43 |
  | Fluss | 62 | 97 | 23 | 40 |

  Neu ist etwa anderthalbmal so hell und hat etwa doppelt so viel Kontrast (Streuung). Nachts ist es ähnlich wie alt.

## Auswertung

- Für b: Es ist glaubwürdig und passt zur Windrose. Die Wanderung über den Tag gibt es schon im alten Spiel, sie zieht nur mit um. Mittags steht die Sonne gegen die Grundansicht etwa 65° seitlich, nicht im Rücken.
- Für a: Gegenlicht macht die Vorderseiten dunkler, und die Schatten liegen gut sichtbar vor den Dingen. Das trägt zur gedämpften Stimmung des alten Bildes bei.
- Für c: Eine feste Sonne ist billiger und behebt das flache Licht ebenso, aber die Tageszeit sieht man dann nur an der Farbe.
- Stärkstes Gegenargument gegen b: Dreht der Spieler die Karte, steht die Sonne doch wieder im Rücken, und das Bild wird flacher. Mit der gedämpften Helligkeit fällt das weniger auf.
- Gegen 2 „ja“: Am Handy draußen in der Sonne ist ein dunkles Bild schwerer zu erkennen. Darum gilt: „etwa wie alt“, aber das Gesicht des Helden und die Wege bleiben lesbar.

## Folgerungen

- 1 b oder 1 c: Tom baut das in Runde 11 und legt ein Vergleichsbild alt/neu vor, bei b zu drei Tageszeiten.
- 1 a: wie b, nur mittags aus Norden.
- 2 ja oder etwas: Tom senkt die Tageshelligkeit auf den alten Wert oder halb dorthin.
- 2 nein: Die Helligkeit bleibt.

Antwort: …
