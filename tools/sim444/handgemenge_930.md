# 930.3: Handgemenge und Abstand mit 444 gerechnet

`tools/sim444/handgemenge.py` (Zahlen `handgemenge.json`, A), je Zelle 1000 Kämpfe, Held mit 21 Punkten und den mittleren Fertigkeiten aus 444 (100 Läufe), Autopilot, ohne Ring, ohne Tränke (wie 444). Zelle: Sieg % heute / Rückfall / Punkte.

## A Prüfung: „heute“ dieses Modells gegen sim.kampf (Sieg %)

| Fall | sim.kampf | heute hier |
|---|---|---|
| Wachsoldat St. 1 gegen Rudel | 100 | 100 |
| Zauberlehrling St. 1 gegen Rudel | 97 | 97 |
| Jägerkind St. 2 gegen Goblin | 100 | 100 |
| Wachsoldat St. 4 gegen Krogg | 100 | 100 |
| Wanderer St. 5 gegen Grimmzahn | 61 | 61 |
| Klosterschüler St. 6 gegen Grak | 98 | 98 |

## B Siegquote je Herkunft (heute / Rückfall / Punkte), Heldenstufe = Stufe des Gegners, Rudel auch Stufe 2

| Herkunft (Tempo, Ausdauer St. 1) | Rudel St. 1 | Rudel St. 2 | Goblin St. 2 | Zombie St. 2 | Skelett St. 2 | Goblin-Späher St. 2 | Krogg St. 4 | Grimmzahn St. 5 | Grak St. 6 |
|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat (normal, 16) | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 |
| Jägerkind (schnell, 14) | 90 / 91 / 90 | 99 / 99 / 99 | 100 / 100 / 100 | 100 / 100 / 100 | 75 / 90 / 60 | 100 / 100 / 100 | 40 / 57 / 37 | 61 / 60 / 60 | 83 / 92 / 82 |
| Zauberlehrling (normal, 19) | 96 / 98 / 99 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 36 / 54 / 50 | 73 / 73 / 83 | 82 / 93 / 92 |
| Klosterschüler (normal, 17) | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 95 / 97 / 100 | 85 / 82 / 100 | 98 / 98 / 100 |
| Kräutersammler (normal, 13) | 41 / 34 / 71 | 86 / 84 / 96 | 97 / 96 / 100 | 100 / 100 / 100 | 7 / 5 / 39 | 98 / 96 / 100 | 5 / 6 / 38 | 12 / 9 / 49 | 28 / 22 / 72 |
| Schmiedelehrling (normal, 15) | 78 / 72 / 89 | 94 / 94 / 98 | 100 / 99 / 100 | 100 / 100 / 100 | 99 / 99 / 100 | 100 / 99 / 100 | 24 / 22 / 62 | 42 / 36 / 71 | 59 / 58 / 85 |
| Herumtreiber (schnell, 14) | 82 / 82 / 93 | 96 / 97 / 99 | 100 / 100 / 100 | 100 / 100 / 100 | 51 / 50 / 91 | 100 / 100 / 100 | 27 / 26 / 70 | 47 / 44 / 79 | 68 / 65 / 93 |
| Wanderer (normal, 14) | 88 / 87 / 96 | 98 / 99 / 100 | 100 / 100 / 100 | 100 / 100 / 100 | 99 / 99 / 100 | 100 / 100 / 100 | 45 / 43 / 78 | 60 / 56 / 83 | 79 / 74 / 92 |

Runden bis zum Sieg (heute / Punkte) und Atem-Züge je Kampf (Punkte):

| Herkunft | Rudel St. 1 | Rudel St. 2 | Goblin St. 2 | Zombie St. 2 | Skelett St. 2 | Goblin-Späher St. 2 | Krogg St. 4 | Grimmzahn St. 5 | Grak St. 6 |
|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat | 4.1 / 3.2 · 0.0 | 3.4 / 2.9 · 0.0 | 2.9 / 2.6 · 0.0 | 5.0 / 3.7 · 0.0 | 4.5 / 3.5 · 0.0 | 2.9 / 2.6 · 0.0 | 8.1 / 5.8 · 0.1 | 8.6 / 6.1 · 0.1 | 8.5 / 6.1 · 0.0 |
| Jägerkind | 3.5 / 3.6 · 0.0 | 3.0 / 3.0 · 0.0 | 2.6 / 2.6 · 0.0 | 4.6 / 4.7 · 0.1 | 7.9 / 7.9 · 0.5 | 2.7 / 2.6 · 0.0 | 6.2 / 6.3 · 0.0 | 6.3 / 6.3 · 0.0 | 7.0 / 7.0 · 0.0 |
| Zauberlehrling | 3.7 / 2.8 · 0.0 | 3.4 / 2.4 · 0.0 | 3.9 / 2.9 · 0.0 | 3.9 / 2.9 · 0.0 | 5.3 / 4.2 · 0.0 | 3.8 / 2.8 · 0.0 | 6.4 / 5.9 · 0.0 | 7.5 / 6.7 · 0.0 | 7.7 / 6.9 · 0.0 |
| Klosterschüler | 6.7 / 4.0 · 0.0 | 5.2 / 3.5 · 0.0 | 3.7 / 3.0 · 0.0 | 5.9 / 4.2 · 0.0 | 4.5 / 3.3 · 0.0 | 4.1 / 3.1 · 0.0 | 15.1 / 8.5 · 0.2 | 16.2 / 8.8 · 0.2 | 14.6 / 8.5 · 0.1 |
| Kräutersammler | 4.7 / 3.8 · 0.0 | 4.4 / 3.4 · 0.0 | 4.3 / 3.4 · 0.0 | 6.8 / 4.7 · 0.0 | 11.4 / 7.8 · 0.0 | 4.3 / 3.4 · 0.0 | 8.6 / 5.8 · 0.0 | 8.4 / 6.4 · 0.0 | 9.4 / 7.2 · 0.0 |
| Schmiedelehrling | 4.0 / 3.2 · 0.0 | 3.8 / 3.1 · 0.0 | 3.1 / 2.9 · 0.0 | 5.7 / 4.2 · 0.0 | 3.7 / 3.0 · 0.0 | 3.3 / 2.9 · 0.0 | 6.9 / 4.9 · 0.0 | 7.1 / 5.4 · 0.0 | 7.9 / 6.2 · 0.0 |
| Herumtreiber | 3.8 / 3.0 · 0.0 | 3.7 / 2.9 · 0.0 | 3.0 / 2.6 · 0.0 | 5.2 / 3.8 · 0.0 | 8.8 / 6.4 · 0.0 | 3.2 / 2.7 · 0.0 | 6.7 / 4.9 · 0.0 | 7.1 / 5.3 · 0.0 | 7.9 / 5.9 · 0.0 |
| Wanderer | 3.4 / 2.8 · 0.0 | 3.0 / 2.6 · 0.0 | 3.0 / 2.6 · 0.0 | 4.5 / 3.4 · 0.0 | 4.3 / 3.2 · 0.0 | 2.8 / 2.5 · 0.0 | 6.1 / 4.4 · 0.0 | 6.3 / 4.9 · 0.0 | 7.2 / 5.4 · 0.0 |

Punkte abgestimmt (Schwung gegen dasselbe Ziel mit Ungunst, Ausdauer-Kosten doppelt), Sieg % heute / abgestimmt:

| Herkunft | Rudel St. 1 | Rudel St. 2 | Goblin St. 2 | Zombie St. 2 | Skelett St. 2 | Goblin-Späher St. 2 | Krogg St. 4 | Grimmzahn St. 5 | Grak St. 6 |
|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 |
| Jägerkind | 90 / 78 | 99 / 96 | 100 / 100 | 100 / 100 | 75 / 38 | 100 / 100 | 40 / 26 | 61 / 44 | 83 / 71 |
| Zauberlehrling | 96 / 99 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 36 / 50 | 73 / 84 | 82 / 90 |
| Klosterschüler | 100 / 94 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 95 / 100 | 85 / 98 | 98 / 100 |
| Kräutersammler | 41 / 53 | 86 / 90 | 97 / 98 | 100 / 100 | 7 / 10 | 98 / 98 | 5 / 15 | 12 / 27 | 28 / 46 |
| Schmiedelehrling | 78 / 66 | 94 / 93 | 100 / 100 | 100 / 100 | 99 / 98 | 100 / 99 | 24 / 26 | 42 / 38 | 59 / 56 |
| Herumtreiber | 82 / 89 | 96 / 97 | 100 / 100 | 100 / 100 | 51 / 63 | 100 / 100 | 27 / 51 | 47 / 65 | 68 / 79 |
| Wanderer | 88 / 84 | 98 / 98 | 100 / 100 | 100 / 100 | 99 / 95 | 100 / 100 | 45 / 46 | 60 / 60 | 79 / 77 |

Höchste Fertigkeit je Herkunft auf Heldenstufe 6 (444; Zurückdrängen ab Rang Geselle = 25, Rangdecke Kapitel 1: 24 bis zur Bewährungsprobe):

Wachsoldat 21, Jägerkind 20, Zauberlehrling 19, Klosterschüler 14, Kräutersammler 18, Schmiedelehrling 14, Herumtreiber 21, Wanderer 20

## C Schütze und Magier: Eröffnung fern gegen weit (Punkte), Sieg % · Schläge der Gegner je Kampf

| Held | Gegner | heute | Rückfall | Punkte fern | Punkte weit | Rückzüge je Kampf (weit) |
|---|---|---|---|---|---|---|
| Zauberlehrling St. 1 | Rudel | 97 · 5.0 | 97 · 5.0 | 99 · 3.2 | 100 · 2.3 | 0.0 |
| Zauberlehrling St. 2 | Goblin | 100 · 2.8 | 100 · 2.9 | 100 · 1.9 | 100 · 0.9 | 0.0 |
| Zauberlehrling St. 2 | Zombie | 100 · 2.9 | 100 · 0.6 | 100 · 0.0 | 100 · 0.0 | 0.9 |
| Zauberlehrling St. 2 | Skelett | 100 · 4.2 | 100 · 4.2 | 100 · 3.3 | 100 · 2.2 | 0.0 |
| Zauberlehrling St. 6 | Grak | 83 · 7.3 | 93 · 7.3 | 90 · 6.3 | 96 · 5.2 | 0.0 |
| Jägerkind St. 1 | Rudel | 91 · 4.7 | 91 · 4.7 | 90 · 4.6 | 96 · 3.8 | 0.0 |
| Jägerkind St. 2 | Goblin | 100 · 1.7 | 100 · 1.6 | 100 · 1.6 | 100 · 0.7 | 0.0 |
| Jägerkind St. 2 | Zombie | 100 · 3.6 | 100 · 1.0 | 100 · 0.3 | 100 · 0.2 | 2.5 |
| Jägerkind St. 2 | Skelett | 73 · 7.1 | 89 · 7.2 | 66 · 7.4 | 76 · 6.7 | 0.0 |
| Jägerkind St. 6 | Grak | 81 · 6.5 | 93 · 6.5 | 82 · 6.4 | 88 · 5.5 | 0.0 |

## D Woher der Unterschied (Punkte zerlegt), Sieg % · Runden

Spalten: heute; Punkte wie oben; ohne Schwung; Schwung nur gegen ein anderes nahes Ziel; Schwung gegen dasselbe Ziel mit Ungunst; streng eine Handlung je Zug (Zauber oder Heilen statt des Schlags, wie heute); Gegner ohne Ausdauer; Ausdauer-Kosten doppelt; Schwung mit Ungunst und doppelte Kosten.

| Held | Gegner | heute | Punkte | ohne Schwung | Schwung anderes Ziel | Schwung mit Ungunst | eine Handlung | Gegner ohne Ausdauer | Kosten ×2 | Ungunst und Kosten ×2 |
|---|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat St. 1 | Rudel | 100 · 4.2 | 100 · 3.2 | 100 · 4.1 | 100 · 4.2 | 100 · 3.4 | 100 · 3.2 | 100 · 3.2 | 100 · 3.9 | 100 · 4.5 |
| Kräutersammler St. 1 | Rudel | 40 · 4.8 | 70 · 3.8 | 44 · 4.9 | 43 · 4.8 | 62 · 4.1 | 72 · 3.8 | 72 · 3.8 | 60 · 3.8 | 54 · 4.1 |
| Schmiedelehrling St. 1 | Rudel | 78 · 4.0 | 90 · 3.2 | 81 · 3.9 | 77 · 4.1 | 86 · 3.6 | 88 · 3.2 | 88 · 3.2 | 71 · 3.8 | 65 · 3.9 |
| Kräutersammler St. 2 | Skelett | 6 · 11.6 | 42 · 8.0 | 6 · 11.1 | 6 · 10.8 | 24 · 8.7 | 43 · 7.9 | 40 · 8.1 | 17 · 9.6 | 10 · 10.0 |
| Kräutersammler St. 4 | Krogg | 5 · 8.1 | 33 · 6.1 | 8 · 8.9 | 6 · 9.2 | 25 · 6.6 | 33 · 5.9 | 34 · 5.8 | 28 · 6.1 | 17 · 6.8 |
| Herumtreiber St. 4 | Krogg | 27 · 6.9 | 68 · 5.0 | 29 · 6.9 | 30 · 7.1 | 55 · 5.2 | 65 · 4.9 | 66 · 4.9 | 65 · 4.8 | 49 · 5.5 |
| Wanderer St. 5 | Grimmzahn | 63 · 6.3 | 84 · 4.8 | 63 · 6.3 | 58 · 6.2 | 78 · 5.2 | 84 · 4.8 | 84 · 4.9 | 69 · 5.4 | 59 · 5.9 |
| Klosterschüler St. 5 | Grimmzahn | 85 · 16.1 | 100 · 8.7 | 99 · 11.0 | 99 · 12.0 | 100 · 10.2 | 98 · 11.5 | 99 · 9.1 | 99 · 12.2 | 98 · 13.1 |
| Zauberlehrling St. 6 | Grak | 83 · 7.7 | 91 · 6.9 | 89 · 7.1 | 89 · 7.0 | 90 · 6.9 | 86 · 7.7 | 89 · 6.9 | 88 · 6.9 | 91 · 7.0 |
| Schmiedelehrling St. 6 | Grak | 58 · 7.8 | 81 · 6.2 | 60 · 8.1 | 60 · 8.0 | 74 · 6.9 | 85 · 6.2 | 84 · 6.1 | 66 · 7.3 | 56 · 7.8 |
| Kräutersammler St. 6 | Grak | 28 · 9.4 | 69 · 7.1 | 29 · 9.7 | 30 · 9.6 | 56 · 7.8 | 69 · 7.0 | 70 · 7.2 | 58 · 7.4 | 45 · 8.4 |

## E Schwere Rüstung (I.3, Tempo eine Stufe langsamer), Punkte, Sieg % · Leben am Ende % · Runden

| Held | Gegner | mittlere bzw. leichte Rüstung | schwere Rüstung |
|---|---|---|---|
| Wachsoldat St. 1 | Rudel | 100 · 87 · 3.2 (normal) | 100 · 98 · 3.9 (langsam) |
| Wachsoldat St. 2 | Goblin-Späher | 100 · 99 · 2.6 (normal) | 100 · 100 · 2.9 (langsam) |
| Wachsoldat St. 5 | Grimmzahn | 100 · 80 · 6.1 (normal) | 100 · 95 · 6.8 (langsam) |
| Wachsoldat St. 6 | Grak | 100 · 81 · 6.1 (normal) | 100 · 95 · 6.9 (langsam) |
| Wanderer St. 1 | Rudel | 95 · 65 · 2.8 (normal) | 100 · 85 · 3.6 (langsam) |
| Wanderer St. 2 | Goblin-Späher | 100 · 84 · 2.5 (normal) | 100 · 97 · 2.8 (langsam) |
| Wanderer St. 5 | Grimmzahn | 84 · 50 · 4.9 (normal) | 100 · 75 · 6.4 (langsam) |

## F Deckung (I.5): nach einem Treffer decken statt Schwung; Anteil des Schadens angesagter Schläge, der durch die Deckung geht

Zelle: Sieg % · Leben am Ende %. Mit Ring eines mittleren Spielers (handgemenge.json ring_spieler) gegen angesagte Schläge; „Schwung“: zweiter Schlag nach jedem Treffer, Deckung nur nach Fehlschlag; „decken x“: nach einem Treffer immer decken.

| Held | Gegner | Schwung | decken 1.00 | decken 0.75 | decken 0.50 | decken 0.25 | decken 0.00 |
|---|---|---|---|---|---|---|---|
| Wachsoldat St. 1 | Rudel | 100 · 96 | 100 · 95 | 100 · 98 | 100 · 98 | 100 · 98 | 100 · 98 |
| Wanderer St. 1 | Rudel | 99 · 78 | 99 · 72 | 100 · 76 | 100 · 80 | 100 · 84 | 100 · 86 |
| Kräutersammler St. 1 | Rudel | 95 · 61 | 84 · 47 | 96 · 53 | 100 · 63 | 100 · 74 | 100 · 78 |
| Wachsoldat St. 4 | Krogg | 100 · 87 | 100 · 85 | 100 · 92 | 100 · 94 | 100 · 95 | 100 · 94 |
| Wanderer St. 5 | Grimmzahn | 97 · 65 | 93 · 51 | 98 · 57 | 100 · 68 | 100 · 76 | 100 · 79 |
| Schmiedelehrling St. 6 | Grak | 99 · 66 | 97 · 53 | 100 · 64 | 100 · 77 | 100 · 90 | 100 · 92 |

## G Ausdauer im Kampf: Vorrat je Stufe (Leben daneben) und Anteil Kämpfe mit „erschöpft“ (Punkte)

| Herkunft | Ausdauer St. 1 / 3 / 6 | Leben St. 1 / 3 / 6 | Kosten Schlag | erschöpft Rudel St. 1 | Atem-Züge Grak St. 6 |
|---|---|---|---|---|---|
| Wachsoldat | 16 / 20 / 26 | 27 / 37 / 52 | 2 | 1 % | 0.0 |
| Jägerkind | 14 / 18 / 24 | 25 / 35 / 50 | 2 | 0 % | 0.0 |
| Zauberlehrling | 19 / 23 / 29 | 25 / 35 / 50 | 2 | 0 % | 0.0 |
| Klosterschüler | 17 / 21 / 27 | 25 / 35 / 50 | 2 | 2 % | 0.1 |
| Kräutersammler | 13 / 17 / 23 | 23 / 33 / 48 | 1 | 0 % | 0.0 |
| Schmiedelehrling | 15 / 19 / 25 | 27 / 37 / 52 | 2 | 0 % | 0.0 |
| Herumtreiber | 14 / 18 / 24 | 25 / 35 / 50 | 1 | 0 % | 0.0 |
| Wanderer | 14 / 18 / 24 | 25 / 35 / 50 | 2 | 2 % | 0.0 |

Ausdauer-Kosten verändert (alle Kosten mal Faktor), Punkte: Sieg % · Atem-Züge je Kampf

| Held | Gegner | Kosten ×1.0 | Kosten ×1.5 | Kosten ×2.0 | Kosten ×3.0 |
|---|---|---|---|---|---|
| Wachsoldat St. 1 | Rudel | 100 · 0.0 | 100 · 0.1 | 100 · 0.6 | 100 · 1.4 |
| Wanderer St. 1 | Rudel | 95 · 0.0 | 91 · 0.1 | 83 · 0.4 | 74 · 0.9 |
| Jägerkind St. 1 | Rudel | 89 · 0.0 | 84 · 0.1 | 80 · 0.4 | 69 · 1.0 |
| Wachsoldat St. 6 | Grak | 100 · 0.1 | 100 · 0.5 | 100 · 1.1 | 100 · 2.3 |
| Wanderer St. 5 | Grimmzahn | 84 · 0.0 | 74 · 0.3 | 66 · 0.8 | 55 · 1.8 |
| Schmiedelehrling St. 6 | Grak | 84 · 0.0 | 76 · 0.5 | 66 · 1.1 | 55 · 2.2 |

## H Was je Runde geschieht (Rudel St. 1, Mittel über alle Runden): Schläge und Wege

| Herkunft | heute: Held-Schläge · Gegner-Schläge | Punkte: Held-Schläge · Held-Wege · Gegner-Schläge · Gegner-Wege | Runden heute / Punkte |
|---|---|---|---|
| Wachsoldat | 1.00 · 1.34 | 1.29 · 0.31 · 1.20 · 0.48 | 4.1 / 3.2 |
| Jägerkind | 1.00 · 1.30 | 1.00 · 0.00 · 1.30 · 0.68 | 3.6 / 3.7 |
| Zauberlehrling | 0.74 · 1.31 | 1.00 · 0.00 · 1.16 · 0.86 | 3.8 / 2.8 |
| Klosterschüler | 0.73 · 1.50 | 1.22 · 0.25 · 1.30 · 0.37 | 6.8 / 4.0 |
| Kräutersammler | 1.00 · 1.51 | 1.36 · 0.26 · 1.37 · 0.38 | 4.5 / 3.9 |
| Schmiedelehrling | 1.00 · 1.37 | 1.30 · 0.30 · 1.24 · 0.44 | 4.2 / 3.4 |
| Herumtreiber | 1.00 · 1.36 | 1.32 · 0.32 · 1.22 · 0.49 | 3.9 / 3.1 |
| Wanderer | 1.00 · 1.27 | 1.24 · 0.34 · 1.16 · 0.52 | 3.6 / 2.9 |

