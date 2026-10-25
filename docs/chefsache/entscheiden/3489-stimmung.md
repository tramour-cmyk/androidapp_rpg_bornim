# 348.9 · Stimmung je Ort und Tageszeit im neuen Spiel
Homer · 25.10., 13:04 · G Stil · Muss
Kurz: Wie dunkel, welches Licht, welche Farben je Ort und Tageszeit? Vorschlag: wie im alten Spiel, dazu die Sonne nach 3486-sonne; Diogenes misst jedes neue Bild gegen das alte.

## Frage

1. Grundton:
   - a: Helligkeit und Farbe wie im alten Spiel, Tafel unten (Vorgabe „mindestens so gut wie alt“);
   - b: wie a, aber am Tag in Dorf und Wald eine Stufe gedämpfter: Ziel 10 % unter dem alten Wert, Himmel verhangen, Herbst;
   - c: deutlich dunkler, wie die Zwischensequenzen (halbe Fläche fast schwarz).
2. Messlatte für Diogenes. Er vergleicht jedes neue Bild mit dem alten an derselben Stelle zur selben Uhrzeit, in der Grundansicht. Dabei gilt:
   - Bildmittel höchstens 5 % (mindestens 2 Stufen) vom Ziel entfernt;
   - Streuung höchstens ein Viertel über alt;
   - Farbe gleich gerichtet: Rot minus Blau mit gleichem Vorzeichen, „neutral“ heißt ±3.

   Ein Bild außerhalb der Messlatte geht nicht weiter, sondern zurück an das Team. Ja / anders.

## Votum

1 a, 2 ja. Erst das alte Bild sicher treffen, danach höchstens einzeln nachdunkeln, wo du es beim Ansehen willst.

## Berührt

348.6 (Dorf, Licht in `licht.gd`), jede weitere Gebietskarte und jeder Grundriss in Godot (Tom), Höhle und Kampforte (Jerry), Messung Diogenes (`LISTE-UMZUG-348.md`, Arbeitsteilung 3).

## Begründung

- Du hast 12:12 gesagt, das neue Dorf sei „viel zu hell … zu freundlich“, das alte gedämpfter. Das alte Bild ist also schon die gewünschte Richtung. Das alte Dorf misst am Tag 53 bis 65, das neue 78 bis 104 (Tom, 3486-sonne).
- Leitbild „Düster, erwachsen“, dazu `DESIGN-STIL.md`: „Grundstimmung düster durch Licht und Schatten, nicht durch Dunkelheit“. Düster heißt darum gedämpfte Farben, warme Lichtinseln gegen kaltes Umfeld und dunkle Schatten, nicht ein schwarzes Bild.

## Tafel: Stimmung je Ort und Tageszeit

Die Tageszeiten sind wie im alten Spiel:
- Morgen bis 10 Uhr (Dämmerung 5 bis 7 Uhr);
- Mittag 10 bis 15 Uhr;
- Nachmittag 15 bis 19 Uhr;
- Abenddämmerung 19 bis 21 Uhr;
- Nacht 21 bis 5 Uhr.

Die Sonne steht nach 3486-sonne wie in der Natur, mittags mit Gegenlicht (12:28: „Gegenlicht mittags passt“). In Klammern stehen Messwerte des alten Bildes als Mittel/Streuung (0 = schwarz, 255 = weiß), ohne Leiste und in der Grundansicht.

| Ort | Morgen | Mittag | Nachmittag | Abenddämmerung | Nacht |
|---|---|---|---|---|---|
| **Dorf** | Sonne tief im Osten, blasses Gold, lange Schatten nach Westen, Schatten blaugrau; Rauch aus den Kaminen (64/21) | gedämpft, leicht verhangen, Erdfarben, Moos und Ruß statt Bunt; Gegenlicht: Vorderseiten und Gesichter im Schatten, kurze dunkle Schatten zum Betrachter (65/21) | Sonne im Westen, warmes Kupfer, lange Schatten nach Osten, Schattenseiten kühl (66/20) | rötlich-violett, Fenster und Laternen gehen an: erste warme Inseln (51/15) | kaltes Blauschwarz, Mond als Gegenlicht; Laternen und Fenster als warme Kegel mit Abfall, Wege bleiben lesbar (28/14) |
| **Flüsterwald** | wie Dorf, unter den Kronen grüner und dunkler | grünlich gefiltert, Lichtflecken durch die Kronen (33/24) | wie Mittag, wärmer | rötlich-violett, dunkler als das Dorf (23/16) | blau, sehr dunkel; Glühwürmchen, Garricks Feuer als einzige warme Insel (12/8) |
| **Tiefer Flüsterwald** | schattig, kaum Sonne | schattig-grün, nie sonnig; Held immer ganz sichtbar (Vorgang 353a) (21/21) | wie Mittag | früher dunkel, rötlich-düster | dunkler als der Wald; Morwens Fenster als warme Insel (10/10) |
| **Gasthaus** | grauer Fensterschein, Kamin warm, Ecken dunkel | wie Morgen (18/24) | wie Morgen | Kerzen und Kamin tragen | nur Kamin und Kerzen, warm, Ecken fast schwarz (11/19) |
| **Laden, Ältester** | grauer Fensterschein, Kerze am Pult oder Tisch | wie Morgen (Laden 18/26, Ältester 12/20) | wie Morgen | Kerzen | Kerzen, sonst dunkel |
| **Tempel** | kühles, helles Fensterlicht, Altarkerzen gold | wie Morgen (26/37) | wie Morgen | Altarkerzen tragen | dunkel und etwas kälter als die anderen Räume |
| **Höhle** | immer fast schwarz; nur Fackeln warm, Pilze türkis, Kristalle violett, Lichtspalt am Tag weiß, nachts Mond (18/19) | | | | |

Bei Räumen, Höhle, Wald und Tiefem Wald zählt schwarzer Rand außerhalb der Karte mit. Die Werte gelten darum nur für genau denselben Ausschnitt.

## Sachverhalt

- **Alt:** Über das gemalte Bild legt das alte Spiel zwei Schichten.
  - Lichtfaktor (`MapLight.ambient`, `Game.daylight`):
    - Dorf am Tag 1,0, leicht warm; in der Dämmerung rötlich (0,88 / 0,68 / 0,60), nachts blau (0,26 / 0,31 / 0,47);
    - Wald am Tag 0,96; Tiefer Wald am Tag 0,86 bis 0,92, nachts blau (0,38 / 0,45 / 0,66);
    - Räume mit Kamin am Tag 0,31, nachts 0,13; Tempel am Tag 0,62;
    - Höhle 0,05.
  - Tönung und Randabdunklung (`MapGrade`):
    - die Dämmerung ist violett getönt, die Nacht blau, die Höhle kalt-grünlich;
    - die Ränder sind am Tag um 0,18 bis 0,22 dunkler, nachts bis etwa 0,36.
  - Die Bilder selbst sind schon gedämpft gemalt. Mit beiden Schichten misst das Dorf mittags darum nur 65.
- **Gemessen** (alte Vorschau, 16 Bilder, 25.10., 13:00): Die Werte stehen in der Tafel.
  - Morgen, Mittag und Nachmittag sind im Dorf gleich hell (64 bis 66). Nur Schatten und Farbe ändern sich.
  - Am Tag ist das Dorf warm (Rot minus Blau 18 bis 26), nachts neutral (−1).
- **Neu** (`licht.gd`, Zweig `claude/tom-348-fundament`):
  - Es gibt nur Tag und Nacht, keine Dämmerung, keine Tönung, keine Randabdunklung und noch keine Räume.
  - Das Dorf misst am Tag 78 bis 104 (Tom, 3486-sonne). Nachts ist es schon auf das alte Mittel geeicht.

## Auswertung

- Für a: Das ist die Vorgabe des Umzugs, und sie ist messbar. Diogenes kann jedes Bild prüfen, ohne Geschmack.
- Für b: Du hast „zu freundlich“ gesagt. Ein verhangener Herbsthimmel passt zu Kapitel 1 (Wölfe, Goblins, verschwundene Leute).
- Für c: Das ist am nächsten an den Zwischensequenzen, die du als „Maß aller Dinge“ bezeichnet hast.
- **Stärkstes Gegenargument gegen a:** Godot macht mit echtem Licht und Tusche mehr Kontrast. Bei gleichem Mittel kann das Bild darum immer noch freundlicher wirken als alt, denn die Streuung ist heute doppelt so hoch. Deshalb steht die Streuung in der Messlatte.
- Gegen c: Am Handy im Freien sieht man auf der Gebietskarte zu wenig, und man spielt dort die meiste Zeit. Die Zwischensequenzen sind Standbilder, man muss dort nichts suchen.

## Folgerungen

- 1 a: Tom eicht `licht.gd` je Tageszeit auf die Tafel, mit Dämmerung, Tönung und Randabdunklung wie `MapGrade`. Räume, Wald und Höhle folgen je Ort, wenn sie gebaut werden.
- 1 b: wie a, aber Dorf und Wald am Tag mit dem Ziel 10 % unter dem alten Wert.
- 1 c: Homer legt in einer neuen Chefsache neue Zielwerte nach `tools/bildmass.py` (Intro) vor.
- 2 ja: Homer trägt die Messlatte und das Messverfahren in `LISTE-UMZUG-348.md` ein, Diogenes misst danach.

Antwort: …
