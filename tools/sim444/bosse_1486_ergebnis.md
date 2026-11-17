# 1486 Ergebnis (Jerry 17.11., 21:22)

**Befund:** nicht die Bosse sind zu leicht, sondern die Herkünfte liegen weit auseinander. Wachsoldat und Klosterschüler gewinnen gegen jeden Boss 93–100 je 100, auch eine Stufe darunter (Krogg auf Stufe 3: 97 und 100); Kräutersammler auf gleicher Stufe 56–62 (Krogg, Grimmzahn), eine darunter 12–20. Beide Rechner (MARS heute ohne Kerben, glut2 S mit Kerben) zeigen dasselbe Bild.

**Wirkung stärkerer Bosse:** Leben × 1,2 lässt Wachsoldat und Klosterschüler bei 96–100 und drückt den Kräutersammler gegen Krogg von 62 auf 46, gegen Grimmzahn von 56 auf 33; × 1,4 auf 28 und 20. Stufe + 1 wirkt wie × 1,2. Stärkere Bosse vergrößern also die Schere, statt die zwei starken Herkünfte zu fordern.

**Gegenprobe:** Wachsoldat ohne Mittlere Rüstung (Leichte) gegen Krogg weiter 100; die Stärke kommt nicht von der Rüstung (Schild, Leben aus Kraft und Zähigkeit 6/6; Klosterschüler über Heilung in langen Kämpfen, 18 Züge statt 6–8).

**Vorbehalte:** (1) Grak ruft im Spiel einen Goblin (870c 1 A), der Rechner nicht; Grak ist hier darum leichter als Krogg und Grimmzahn (Kräutersammler 88), das gilt nicht fürs Spiel. (2) Teil 2 von `sim.py` (alte Kampfmatrix ohne Handgemenge) rechnet viel härter (Grak gleiche Stufe: Kräutersammler 6, Zauberlehrling 61, Wachsoldat 99); `handgemenge.py` „heute“ ist der Rechner mit Gegenprobe im Spiel (930.6), Teil 2 taugt für Balance nicht, bis er angeglichen ist. (3) Held allein, ohne Tränke (Kapitel 1 ohne Gefährten, 168.1).

**Vorschlag an Sokrates:** A Bosswerte lassen; die Schere der Herkünfte als eigenen Vorgang rechnen (Ziel etwa 75–90 je 100 gegen Bosse auf gleicher Stufe für alle Herkünfte; Hebel bei Schild und Heilung oben, beim Kräutersammler unten). B Bosse + 20 % Leben: nicht empfohlen (Zahlen oben). Stärkstes Gegenargument gegen A: eine leichte Herkunft kann gewollt sein (Einstieg für Ungeübte); dann gehört das in den Schwierigkeitsgrad (39), nicht in die Herkunft. Balance entscheidet der Chef oder Sokrates per Vorentscheid (783 W5).



## Krogg (Stufe 4), Held Stufe 4

| Herkunft | heute | Leben ×1,2 | Leben ×1,4 | Stufe +1 |
|---|---|---|---|---|
| Wachsoldat | 100/100 | 100/99 | 99/99 | 100/99 |
| Jägerkind | 94/90 | 89/80 | 80/72 | 83/77 |
| Zauberlehrling | 85/82 | 75/69 | 63/58 | 68/62 |
| Klosterschüler | 100/100 | 100/100 | 100/100 | 100/100 |
| Kräutersammler | 62/56 | 46/32 | 28/24 | 41/32 |
| Schmiedelehrling | 91/90 | 83/81 | 77/71 | 81/75 |
| Herumtreiber | 88/86 | 78/74 | 66/62 | 71/68 |
| Wanderer | 94/94 | 90/84 | 82/78 | 84/82 |

## Grimmzahn (Stufe 5), Held Stufe 5

| Herkunft | heute | Leben ×1,2 | Leben ×1,4 | Stufe +1 |
|---|---|---|---|---|
| Wachsoldat | 99/100 | 98/99 | 96/97 | 96/97 |
| Jägerkind | 92/96 | 84/89 | 74/82 | 80/87 |
| Zauberlehrling | 84/85 | 72/74 | 54/54 | 68/70 |
| Klosterschüler | 100/100 | 100/100 | 100/100 | 100/99 |
| Kräutersammler | 56/54 | 33/35 | 20/20 | 30/34 |
| Schmiedelehrling | 86/91 | 78/79 | 66/67 | 71/77 |
| Herumtreiber | 83/85 | 74/74 | 60/58 | 64/66 |
| Wanderer | 93/93 | 83/88 | 79/79 | 83/84 |

## Grak (Stufe 6), Held Stufe 6

| Herkunft | heute | Leben ×1,2 | Leben ×1,4 | Stufe +1 |
|---|---|---|---|---|
| Wachsoldat | 100/100 | 100/100 | 100/99 | 100/100 |
| Jägerkind | 100/98 | 99/95 | 96/93 | 98/95 |
| Zauberlehrling | 98/91 | 93/81 | 85/66 | 90/77 |
| Klosterschüler | 100/100 | 100/100 | 100/100 | 100/100 |
| Kräutersammler | 88/68 | 74/47 | 60/29 | 72/38 |
| Schmiedelehrling | 99/93 | 96/86 | 91/74 | 95/82 |
| Herumtreiber | 98/90 | 95/81 | 87/69 | 93/74 |
| Wanderer | 99/97 | 98/91 | 96/84 | 96/88 |

## Krogg (Stufe 4), Held Stufe 3

| Herkunft | heute | Leben ×1,2 | Leben ×1,4 | Stufe +1 |
|---|---|---|---|---|
| Wachsoldat | 97/97 | 95/94 | 88/90 | 91/87 |
| Jägerkind | 66/61 | 52/39 | 39/30 | 45/39 |
| Zauberlehrling | 55/49 | 41/30 | 27/15 | 36/28 |
| Klosterschüler | 100/100 | 100/100 | 99/98 | 99/97 |
| Kräutersammler | 20/18 | 9/7 | 4/3 | 6/5 |
| Schmiedelehrling | 63/58 | 45/40 | 32/27 | 44/36 |
| Herumtreiber | 53/53 | 39/35 | 23/21 | 28/31 |
| Wanderer | 74/70 | 58/52 | 46/41 | 51/50 |

## Grimmzahn (Stufe 5), Held Stufe 4

| Herkunft | heute | Leben ×1,2 | Leben ×1,4 | Stufe +1 |
|---|---|---|---|---|
| Wachsoldat | 93/95 | 84/86 | 72/73 | 81/85 |
| Jägerkind | 69/77 | 51/63 | 32/50 | 45/59 |
| Zauberlehrling | 60/63 | 34/39 | 21/21 | 31/39 |
| Klosterschüler | 98/98 | 94/95 | 86/90 | 89/90 |
| Kräutersammler | 12/14 | 4/8 | 1/4 | 3/4 |
| Schmiedelehrling | 57/65 | 40/49 | 23/28 | 34/45 |
| Herumtreiber | 48/54 | 30/39 | 17/22 | 25/31 |
| Wanderer | 72/72 | 54/58 | 42/46 | 48/57 |

## Grak (Stufe 6), Held Stufe 5

| Herkunft | heute | Leben ×1,2 | Leben ×1,4 | Stufe +1 |
|---|---|---|---|---|
| Wachsoldat | 100/99 | 100/94 | 98/88 | 99/91 |
| Jägerkind | 94/86 | 84/76 | 75/60 | 80/70 |
| Zauberlehrling | 87/72 | 70/47 | 48/28 | 64/48 |
| Klosterschüler | 100/99 | 100/98 | 100/97 | 100/95 |
| Kräutersammler | 53/28 | 32/14 | 16/5 | 26/12 |
| Schmiedelehrling | 90/68 | 77/54 | 64/37 | 76/52 |
| Herumtreiber | 85/65 | 74/46 | 55/32 | 65/40 |
| Wanderer | 93/78 | 86/65 | 74/56 | 81/62 |
