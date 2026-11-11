# Rechensimulation Spielsystem 2.0 (444)

Tuffy (Team Jerry) für Sokrates. Werkzeug `tools/sim444/sim.py`, alle Zahlen in `tools/sim444/werte.json` (Zweig `claude/tuffy-444-simulation`). Regeln: Nachschlagewerk Modell D und Abschnitt 4, Monster: Bestiarium „Werte 2.0“ (01.11.). Je Fall 1000 Kämpfe; Fortschritt 400 Läufe je Herkunft; Zufallskeim 444. Neu rechnen: `python3 tools/sim444/sim.py --aus docs/LISTE-SIMULATION-444.md`.

## Befund (Tuffy, 01.11.; nur Zahlen, Einstellen bei Sokrates)

1. **Kämpfe sehr kurz:** Held gegen Art gleicher Stufe meist 1,3 bis 4 Züge bis Sieg, Siegquote meist 95–100 % (Abschnitt 4). Länger nur Ockerschleim (5–12), Riesenspinne (4,5–13,5) und alles beim Klosterschüler (Heilung). Bosse auf ihrer Stufe 4,5 bis 9 Züge, beim Klosterschüler 13 bis 19.
2. **Kapitel 1 nach 19 bis 29 Kämpfen durch:** Stufe 6 im Median nach 19 (Klosterschüler) bis 29 (Kräutersammler) Kämpfen, Niederlagen mitgezählt, nur aus Kampf, ohne Quests (Abschnitt 1). Grund: Erfahrung je Gegner 10 × Stufe² gegen Bedarf 100 × Stufe; ab Stufe 2 bringt ein Gegner gleicher Stufe 40 von 200.
3. **Bewährungsprobe kommt in Kapitel 1 nicht vor:** in diesen Kämpfen erreicht keine Fertigkeit die Decke 24 (beste Waffe bei Stufe 6: 13 bis 20), Anteil Probe 0 %. Rang Geselle ist in Kapitel 1 damit nicht erreichbar.
4. **Deckel 40 % greift selten:** Anteil Erfahrung aus Fertigkeiten 10–30 %; der Deckel schneidet je Lauf 0 bis 55 Erfahrung ab, nennenswert nur beim Kräutersammler (55) und Klosterschüler (30).
5. **Bosse trennen die Herkünfte stark** (Abschnitt 2, je auf Bossstufe): Krogg 75 % Wachsoldat, 15–42 % die übrigen, 0 % Kräutersammler; Grimmzahn 60–99 %, Kräutersammler 8 %; **Grak** 86 % Wachsoldat, 27–36 % Jägerkind, Zauberlehrling, Klosterschüler, Wanderer, 9–12 % Schmiedelehrling und Herumtreiber, **0 % Kräutersammler**. Grak dauert 6 bis 9 Züge (Bestiarium-Prüfpunkt 1: nicht zu kurz, aber für die meisten zu stark).
6. **Wachsoldat überall vorn:** Schild (Abwehr und Abzug) plus mittlere Rüstung; gegen jede Art gleicher Stufe 99–100 %.
7. **Kräutersammler ohne Kampfweg:** gegen gleiche Stufe Riesenspinne 2 %, Ockerschleim 0 %, Ghul 38 %, Riesenfledermaus 48 %; Niederlagen beim Fortschritt 19 % (Stufe 1) bis 38 % (Stufe 5).
8. **21 statt 18 Punkte** ändert wenig: Mittel gegen gleiche Stufe +0 bis +3 Punkte, Kräutersammler 76 → 84 %; Kämpfe bis Stufe 6 −4 bis +1.

Was die Zahlen wenig belastbar macht: Waffen- und Rüstungswerte je Herkunft, Zauberzahlen und alle Übungszahlen sind Annahmen (unten); kein Rudel, kein Hinterhalt, keine Merkmale (Gift, Umreißen, Zäher Tod), Leben voll vor jedem Kampf. Neu rechnen überschreibt diese Datei; den Befund dann neu schreiben.

## Annahmen (im Nachschlagewerk ohne Zahl)

Jede steht in `werte.json` mit „A“ und lässt sich dort ändern.

- **Punkte:** 18 (6 frei über der Untergrenze 3); Spalte „21“ unten mit 9 frei (Vorschlag 422 a). Volk nicht gerechnet.
- **Herkunft:** Punkteverteilung, Waffe und Rüstung je Herkunft gesetzt (Tabelle unten). Wanderer als Kampfbau (Schwert, Ausweichen).
- **Rüstungswerte:** leicht 1, mittel 3, schwer 5, Schild 2; Abzug = Rüstung × (1 + Rüstungsfertigkeit/100) + Schild × (1 + Schild/100).
- **Zauber:** Funkenpfeil Grundschaden 6, 4 Mana; Wundsegen heilt (6 + Wille) × (1 + Heilmagie/100) unter halbem Leben, 5 Mana; Bannschild Rüstung +2 in Runde 1, 4 Mana. Ohne Mana Stab (Stumpfe Waffe, Fertigkeit 0).
- **Kampf:** eins gegen eins, Held schlägt zuerst, Streuung ±20 %, kein Hinterhalt, keine Merkmale außer Skelett (Stumpfes × 1,5) und Ockerschleim (Klingen × 0,5); Leben und Mana voll vor jedem Kampf; höchstens 60 Runden.
- **Üben:** 1 Übung je Treffer (Waffe, Zauber), je erlittenem Treffer (Rüstung, Schild), je Fehlschlag des Gegners (beste Abwehr); × (1 + (Gegnerstufe − Heldenstufe)/5), 0,2 bis 1,5. Bedarf für +1: (Wert + 10)/5.
- **Ränge Kapitel 1:** Decke 24, Bewährungsprobe = 3 Siege gegen Gegner mindestens der eigenen Stufe mit dieser Fertigkeit, dann Decke 49; Puffer 15 Übung.
- **Erfahrung aus Fertigkeiten:** je 5 Punkte 20 × Heldenstufe, Deckel 40 % des Stufenbedarfs; Probe 25 × Heldenstufe.
- **Fortschritt:** Zufallsbegegnung aus allen Arten mit Stufe Heldenstufe − 2 bis + 1 (ohne Bosse); Niederlage gibt nichts, der Held macht weiter; Erfahrungstopf, Quests und Hauptquest nicht gerechnet (der Topf hieße mehr Kämpfe, Quests weniger).

| Herkunft | Grundwerte (K G Z V Wi Wa) | Startfertigkeiten | Waffe | Rüstung |
|---|---|---|---|---|
| Wachsoldat | 6 3 6 3 3 3 | Schild, Mittlere Rüstung, Einhänder | Einhänder | Mittlere Rüstung + Schild |
| Jägerkind | 3 6 3 3 3 6 | Bogen, Wurfwaffen, Spähen | Bogen | Leichte Rüstung |
| Zauberlehrling | 3 3 3 4 8 3 | Evokation, Schutzmagie | Stumpfe Waffen + Bannschild, Funkenpfeil | keine |
| Klosterschüler | 3 3 4 5 6 3 | Heilmagie, Heilkunde, Kräuterkunde | Stumpfe Waffen + Wundsegen | Leichte Rüstung |
| Kräutersammler | 3 3 3 6 3 6 | Kräuterkunde, Alchemie, Spähen | Dolche | Leichte Rüstung |
| Schmiedelehrling | 6 3 4 5 3 3 | Schmieden, Bergbau | Stumpfe Waffen | Leichte Rüstung |
| Herumtreiber | 3 7 3 3 3 5 | Schleichen, Spähen, Dolche | Dolche | Leichte Rüstung |
| Wanderer | 7 3 5 3 3 3 | Einhänder, Ausweichen | Einhänder | Leichte Rüstung |

## 1. Fortschritt bis zur Kapitelgrenze (Stufe 6)

Kämpfe je Stufe: Median. Niederlagen: Anteil an den Kämpfen der Stufe. Anteil Fertigkeit: an aller Erfahrung (Deckel 40 % je Stufe). „Deckel“: wie oft je Lauf die 40 % erreicht wurden; „verfallen“: Erfahrung je Lauf, die der Deckel abschnitt.

| Herkunft | 1→2 | 2→3 | 3→4 | 4→5 | 5→6 | gesamt | erreicht % | Niederl. % (1→2 / 5→6) | Anteil Fertigk. % | Anteil Probe % | Deckel | verfallen | gesamt (21) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat | 4 | 5 | 5 | 4 | 3 | 20 | 100 | 0 / 0 | 15 | 0 | 0,8 | 3 | 20 |
| Jägerkind | 4 | 5 | 5 | 5 | 4 | 23 | 100 | 2 / 2 | 11 | 0 | 0,6 | 0 | 22 |
| Zauberlehrling | 4 | 5 | 6 | 5 | 4 | 24 | 100 | 2 / 2 | 10 | 0 | 0,2 | 0 | 23 |
| Klosterschüler | 4 | 3 | 5 | 4 | 3 | 19 | 100 | 0 / 0 | 23 | 0 | 2,0 | 30 | 19 |
| Kräutersammler | 4 | 4 | 7 | 7 | 6 | 29 | 100 | 19 / 38 | 30 | 0 | 3,0 | 55 | 25 |
| Schmiedelehrling | 4 | 4 | 6 | 5 | 4 | 23 | 100 | 4 / 6 | 18 | 0 | 1,0 | 4 | 22 |
| Herumtreiber | 4 | 5 | 5 | 6 | 4 | 25 | 100 | 4 / 17 | 19 | 0 | 1,2 | 12 | 24 |
| Wanderer | 4 | 5 | 5 | 5 | 4 | 23 | 100 | 1 / 10 | 13 | 0 | 0,6 | 1 | 24 |

**Fertigkeiten beim Erreichen von Stufe 3 und 6** (Mittel; gehen in die Kampfmatrix ein):

| Herkunft | Stufe 3 | Stufe 6 |
|---|---|---|
| Wachsoldat | Einhänder 13, Schild 13, Mittlere Rüstung 12 | Einhänder 18, Schild 18, Mittlere Rüstung 16 |
| Jägerkind | Bogen 13, Spähen 10, Wurfwaffen 10, Leichte Rüstung 3, Ausweichen 1 | Bogen 18, Spähen 10, Wurfwaffen 10, Leichte Rüstung 9, Ausweichen 4 |
| Zauberlehrling | Evokation 13, Schutzmagie 12, Ausweichen 2 | Evokation 18, Schutzmagie 14, Ausweichen 5 |
| Klosterschüler | Heilkunde 10, Heilmagie 10, Kräuterkunde 10, Leichte Rüstung 6, Stumpfe Waffen 6, Ausweichen 2 | Leichte Rüstung 15, Stumpfe Waffen 14, Heilmagie 13, Heilkunde 10, Kräuterkunde 10, Ausweichen 7 |
| Kräutersammler | Alchemie 10, Kräuterkunde 10, Spähen 10, Dolche 9, Leichte Rüstung 8, Ausweichen 3 | Dolche 20, Leichte Rüstung 19, Alchemie 10, Kräuterkunde 10, Spähen 10, Ausweichen 8 |
| Schmiedelehrling | Bergbau 10, Schmieden 10, Stumpfe Waffen 6, Leichte Rüstung 4, Ausweichen 1 | Stumpfe Waffen 13, Leichte Rüstung 11, Bergbau 10, Schmieden 10, Ausweichen 4 |
| Herumtreiber | Dolche 14, Schleichen 10, Spähen 10, Leichte Rüstung 4, Ausweichen 2 | Dolche 20, Leichte Rüstung 12, Schleichen 10, Spähen 10, Ausweichen 5 |
| Wanderer | Einhänder 13, Ausweichen 10, Leichte Rüstung 3 | Einhänder 19, Ausweichen 12, Leichte Rüstung 10 |

## 2. Bosse je Herkunft

Siegquote in % auf Heldenstufe 1–6 (Bossstufe fett). Zelle: Sieg % · Züge bis Sieg · Leben am Ende %.

**Krogg** (Stufe 4, Leben 41)

| Herkunft | 1 | 2 | 3 | **4** | 5 | 6 |
|---|---|---|---|---|---|---|
| Wachsoldat | 0 · 6,8 · 20 | 5 · 6,2 · 23 | 28 · 5,9 · 27 | 75 · 5,7 · 37 | 96 · 5,8 · 50 | 100 · 5,1 · 70 |
| Jägerkind | 0 · – · – | 1 · 5,9 · 51 | 10 · 5,0 · 25 | 26 · 4,5 · 34 | 66 · 4,5 · 37 | 91 · 4,2 · 49 |
| Zauberlehrling | 0 · – · – | 0 · 5,2 · 27 | 6 · 5,2 · 27 | 25 · 5,1 · 23 | 56 · 5,0 · 34 | 86 · 5,1 · 42 |
| Klosterschüler | 0 · – · – | 0 · – · – | 1 · 15,7 · 37 | 24 · 15,0 · 36 | 76 · 14,0 · 49 | 98 · 11,7 · 56 |
| Kräutersammler | 0 · – · – | 0 · – · – | 0 · – · – | 0 · 7,0 · 6 | 3 · 8,3 · 21 | 22 · 7,1 · 24 |
| Schmiedelehrling | 0 · – · – | 0 · – · – | 3 · 5,3 · 22 | 15 · 5,1 · 24 | 44 · 4,9 · 32 | 76 · 4,9 · 41 |
| Herumtreiber | 0 · – · – | 0 · 5,5 · 44 | 5 · 5,6 · 23 | 15 · 5,1 · 32 | 52 · 4,9 · 32 | 80 · 4,8 · 43 |
| Wanderer | 0 · 6,0 · 33 | 2 · 5,2 · 32 | 12 · 4,8 · 30 | 42 · 4,8 · 29 | 70 · 4,4 · 43 | 92 · 4,4 · 52 |

**Grimmzahn** (Stufe 5, Leben 39)

| Herkunft | 1 | 2 | 3 | 4 | **5** | 6 |
|---|---|---|---|---|---|---|
| Wachsoldat | 1 · 7,0 · 17 | 13 · 6,7 · 21 | 56 · 6,5 · 29 | 93 · 6,1 · 46 | 99 · 5,8 · 64 | 100 · 5,0 · 80 |
| Jägerkind | 0 · 6,0 · 40 | 2 · 5,6 · 15 | 12 · 4,9 · 32 | 48 · 4,7 · 30 | 80 · 4,6 · 39 | 95 · 4,3 · 55 |
| Zauberlehrling | 0 · 6,0 · 52 | 1 · 6,2 · 17 | 9 · 5,6 · 19 | 42 · 5,2 · 29 | 78 · 5,2 · 38 | 93 · 5,3 · 48 |
| Klosterschüler | 0 · – · – | 0 · 17,7 · 46 | 11 · 16,7 · 35 | 54 · 15,3 · 43 | 96 · 12,9 · 57 | 100 · 10,3 · 59 |
| Kräutersammler | 0 · – · – | 0 · – · – | 0 · – · – | 0 · 8,0 · 19 | 8 · 7,7 · 20 | 44 · 7,1 · 25 |
| Schmiedelehrling | 0 · – · – | 0 · 6,0 · 14 | 4 · 5,5 · 23 | 23 · 5,1 · 27 | 60 · 5,3 · 33 | 87 · 5,0 · 46 |
| Herumtreiber | 0 · – · – | 1 · 5,8 · 26 | 6 · 5,5 · 28 | 30 · 5,2 · 28 | 66 · 5,2 · 34 | 91 · 5,0 · 48 |
| Wanderer | 0 · 5,5 · 30 | 5 · 5,9 · 26 | 22 · 5,0 · 26 | 51 · 5,0 · 33 | 82 · 4,6 · 47 | 96 · 4,5 · 57 |

**Grak** (Stufe 6, Leben 58)

| Herkunft | 1 | 2 | 3 | 4 | 5 | **6** |
|---|---|---|---|---|---|---|
| Wachsoldat | 0 · – · – | 0 · – · – | 0 · – · – | 5 · 8,5 · 12 | 41 · 8,5 · 23 | 86 · 8,6 · 38 |
| Jägerkind | 0 · – · – | 0 · – · – | 0 · – · – | 0 · 7,8 · 27 | 4 · 6,5 · 20 | 27 · 6,4 · 21 |
| Zauberlehrling | 0 · – · – | 0 · – · – | 0 · – · – | 0 · 8,0 · 22 | 4 · 6,9 · 16 | 29 · 6,7 · 21 |
| Klosterschüler | 0 · – · – | 0 · – · – | 0 · – · – | 0 · – · – | 2 · 19,3 · 18 | 29 · 19,1 · 32 |
| Kräutersammler | 0 · – · – | 0 · – · – | 0 · – · – | 0 · – · – | 0 · – · – | 0 · – · – |
| Schmiedelehrling | 0 · – · – | 0 · – · – | 0 · – · – | 0 · – · – | 1 · 7,3 · 15 | 9 · 6,8 · 19 |
| Herumtreiber | 0 · – · – | 0 · – · – | 0 · – · – | 0 · – · – | 2 · 7,3 · 22 | 12 · 6,7 · 22 |
| Wanderer | 0 · – · – | 0 · – · – | 0 · – · – | 1 · 7,3 · 14 | 10 · 6,6 · 21 | 36 · 6,3 · 25 |

## 3. Kampfmatrix je Herkunft

Zelle: Sieg % · Züge bis Sieg · Leben am Ende % (nur Siege). Fett: Heldenstufe = Gegnerstufe.

### Wachsoldat

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 1,4 · 100** | 100 · 1,4 · 100 | 100 · 1,3 · 100 | 100 · 1,3 · 100 | 100 · 1,3 · 100 | 100 · 1,3 · 100 |
| Kobold (1) | **100 · 1,9 · 100** | 100 · 1,5 · 100 | 100 · 1,3 · 100 | 100 · 1,4 · 100 | 100 · 1,3 · 100 | 100 · 1,3 · 100 |
| Blutflügler (1) | **100 · 1,5 · 100** | 100 · 1,4 · 100 | 100 · 1,4 · 100 | 100 · 1,3 · 100 | 100 · 1,4 · 100 | 100 · 1,3 · 100 |
| Wolf (2) | 100 · 2,8 · 83 | **100 · 2,4 · 92** | 100 · 2,1 · 97 | 100 · 1,7 · 99 | 100 · 1,4 · 100 | 100 · 1,3 · 100 |
| Wildschwein (2) | 100 · 2,7 · 100 | **100 · 2,7 · 100** | 100 · 2,2 · 100 | 100 · 1,8 · 100 | 100 · 1,5 · 100 | 100 · 1,3 · 100 |
| Riesen-Hundertfüßer (2) | 100 · 2,3 · 100 | **100 · 1,9 · 100** | 100 · 1,5 · 100 | 100 · 1,4 · 100 | 100 · 1,4 · 100 | 100 · 1,4 · 100 |
| Goblin (2) | 100 · 2,2 · 93 | **100 · 1,8 · 98** | 100 · 1,4 · 99 | 100 · 1,4 · 100 | 100 · 1,4 · 100 | 100 · 1,4 · 100 |
| Goblin-Späher (2) | 100 · 2,3 · 93 | **100 · 1,9 · 97** | 100 · 1,6 · 99 | 100 · 1,4 · 100 | 100 · 1,4 · 100 | 100 · 1,4 · 100 |
| Skelett (2) | 100 · 3,1 · 88 | **100 · 2,9 · 95** | 100 · 2,7 · 98 | 100 · 2,8 · 99 | 100 · 2,5 · 100 | 100 · 2,2 · 100 |
| Zombie (2) | 100 · 4,3 · 100 | **100 · 4,0 · 100** | 100 · 3,8 · 100 | 100 · 3,3 · 100 | 100 · 2,8 · 100 | 100 · 2,6 · 100 |
| Riesenfledermaus (3) | 99 · 5,8 · 58 | 100 · 5,0 · 77 | **100 · 4,5 · 89** | 100 · 4,2 · 95 | 100 · 3,7 · 99 | 100 · 3,2 · 100 |
| Goblin-Schamane (3) | 100 · 4,1 · 98 | 100 · 3,3 · 100 | **100 · 2,9 · 100** | 100 · 2,8 · 100 | 100 · 2,8 · 100 | 100 · 2,7 · 100 |
| Riesenspinne (4) | 7 · 6,2 · 23 | 40 · 6,1 · 26 | 86 · 5,9 · 41 | **99 · 5,7 · 58** | 100 · 4,8 · 78 | 100 · 4,5 · 87 |
| Ghul (4) | 53 · 5,7 · 30 | 90 · 5,7 · 45 | 100 · 5,1 · 66 | **100 · 4,4 · 81** | 100 · 4,3 · 89 | 100 · 3,9 · 95 |
| Ockerschleim (5) | 0 · – · – | 2 · 11,9 · 11 | 49 · 12,2 · 20 | 98 · 11,8 · 42 | **100 · 10,5 · 68** | 100 · 9,4 · 86 |

### Jägerkind

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 1,3 · 97** | 100 · 1,2 · 98 | 100 · 1,2 · 99 | 100 · 1,3 · 99 | 100 · 1,2 · 99 | 100 · 1,2 · 100 |
| Kobold (1) | **100 · 1,7 · 92** | 100 · 1,5 · 97 | 100 · 1,2 · 99 | 100 · 1,2 · 99 | 100 · 1,2 · 99 | 100 · 1,2 · 100 |
| Blutflügler (1) | **100 · 1,3 · 96** | 100 · 1,3 · 98 | 100 · 1,3 · 98 | 100 · 1,2 · 99 | 100 · 1,3 · 99 | 100 · 1,3 · 100 |
| Wolf (2) | 94 · 2,4 · 63 | **99 · 2,2 · 78** | 100 · 1,8 · 89 | 100 · 1,5 · 95 | 100 · 1,3 · 98 | 100 · 1,2 · 99 |
| Wildschwein (2) | 100 · 2,6 · 80 | **100 · 2,4 · 87** | 100 · 2,0 · 94 | 100 · 1,7 · 97 | 100 · 1,4 · 99 | 100 · 1,2 · 99 |
| Riesen-Hundertfüßer (2) | 100 · 2,1 · 85 | **100 · 1,8 · 92** | 100 · 1,4 · 97 | 100 · 1,3 · 99 | 100 · 1,3 · 99 | 100 · 1,3 · 99 |
| Goblin (2) | 98 · 1,8 · 82 | **100 · 1,5 · 92** | 100 · 1,3 · 96 | 100 · 1,3 · 97 | 100 · 1,3 · 98 | 100 · 1,3 · 99 |
| Goblin-Späher (2) | 97 · 2,0 · 78 | **100 · 1,8 · 88** | 100 · 1,4 · 96 | 100 · 1,3 · 97 | 100 · 1,3 · 98 | 100 · 1,3 · 99 |
| Skelett (2) | 95 · 2,7 · 64 | **99 · 2,6 · 74** | 100 · 2,6 · 81 | 100 · 2,5 · 87 | 100 · 2,2 · 92 | 100 · 1,9 · 96 |
| Zombie (2) | 99 · 3,8 · 65 | **100 · 3,7 · 76** | 100 · 3,5 · 85 | 100 · 3,0 · 90 | 100 · 2,6 · 95 | 100 · 2,4 · 97 |
| Riesenfledermaus (3) | 36 · 4,2 · 38 | 78 · 4,1 · 45 | **97 · 3,9 · 59** | 100 · 3,8 · 69 | 100 · 3,3 · 81 | 100 · 2,9 · 89 |
| Goblin-Schamane (3) | 97 · 3,6 · 61 | 100 · 3,0 · 77 | **100 · 2,7 · 86** | 100 · 2,6 · 90 | 100 · 2,5 · 93 | 100 · 2,4 · 95 |
| Riesenspinne (4) | 0 · 5,0 · 38 | 8 · 4,9 · 21 | 32 · 4,6 · 30 | **65 · 4,5 · 36** | 94 · 4,2 · 51 | 99 · 4,1 · 63 |
| Ghul (4) | 9 · 4,7 · 23 | 30 · 4,3 · 35 | 76 · 4,1 · 41 | **95 · 3,9 · 55** | 100 · 3,9 · 64 | 100 · 3,4 · 76 |
| Ockerschleim (5) | 1 · 5,9 · 29 | 5 · 5,7 · 32 | 33 · 5,3 · 29 | 77 · 5,1 · 36 | **97 · 5,0 · 49** | 100 · 4,7 · 63 |

### Zauberlehrling

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 2,4 · 89** | 100 · 2,3 · 93 | 100 · 2,3 · 96 | 100 · 2,4 · 98 | 100 · 2,3 · 99 | 100 · 2,3 · 100 |
| Kobold (1) | **100 · 2,4 · 89** | 100 · 2,4 · 93 | 100 · 2,4 · 96 | 100 · 2,3 · 98 | 100 · 2,3 · 99 | 100 · 2,3 · 100 |
| Blutflügler (1) | **100 · 2,4 · 88** | 100 · 2,4 · 93 | 100 · 2,4 · 95 | 100 · 2,4 · 97 | 100 · 2,4 · 99 | 100 · 2,3 · 100 |
| Wolf (2) | 89 · 3,0 · 56 | **99 · 2,8 · 70** | 100 · 2,5 · 82 | 100 · 2,4 · 88 | 100 · 2,4 · 92 | 100 · 2,4 · 95 |
| Wildschwein (2) | 100 · 3,5 · 77 | **100 · 3,1 · 88** | 100 · 2,7 · 94 | 100 · 2,4 · 96 | 100 · 2,4 · 98 | 100 · 2,3 · 99 |
| Riesen-Hundertfüßer (2) | 100 · 2,8 · 82 | **100 · 2,5 · 90** | 100 · 2,4 · 94 | 100 · 2,4 · 96 | 100 · 2,4 · 98 | 100 · 2,4 · 99 |
| Goblin (2) | 98 · 2,5 · 71 | **100 · 2,5 · 81** | 100 · 2,4 · 86 | 100 · 2,4 · 90 | 100 · 2,4 · 94 | 100 · 2,4 · 96 |
| Goblin-Späher (2) | 97 · 2,7 · 68 | **100 · 2,5 · 81** | 100 · 2,5 · 86 | 100 · 2,4 · 91 | 100 · 2,4 · 94 | 100 · 2,3 · 96 |
| Skelett (2) | 91 · 3,7 · 50 | **98 · 3,8 · 62** | 100 · 3,7 · 74 | 100 · 3,3 · 84 | 100 · 2,9 · 92 | 100 · 2,6 · 95 |
| Zombie (2) | 100 · 5,0 · 64 | **100 · 4,8 · 77** | 100 · 4,1 · 89 | 100 · 3,7 · 93 | 100 · 3,6 · 97 | 100 · 3,5 · 98 |
| Riesenfledermaus (3) | 43 · 4,7 · 29 | 79 · 5,0 · 38 | **96 · 5,0 · 53** | 100 · 4,4 · 70 | 100 · 3,9 · 81 | 100 · 3,9 · 87 |
| Goblin-Schamane (3) | 99 · 4,1 · 64 | 100 · 3,9 · 77 | **100 · 3,8 · 84** | 100 · 3,8 · 89 | 100 · 3,5 · 94 | 100 · 3,0 · 97 |
| Riesenspinne (4) | 0 · 6,0 · 10 | 3 · 5,3 · 20 | 27 · 4,9 · 24 | **68 · 5,0 · 33** | 91 · 5,1 · 44 | 99 · 5,0 · 59 |
| Ghul (4) | 7 · 5,0 · 20 | 35 · 4,7 · 27 | 69 · 4,7 · 35 | **93 · 5,0 · 46** | 100 · 4,5 · 63 | 100 · 4,1 · 76 |
| Ockerschleim (5) | 1 · 6,7 · 18 | 5 · 6,3 · 20 | 36 · 5,9 · 22 | 77 · 6,1 · 32 | **96 · 5,9 · 48** | 100 · 5,2 · 65 |

### Klosterschüler

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 2,8 · 83** | 100 · 2,2 · 92 | 100 · 1,9 · 96 | 100 · 1,4 · 98 | 100 · 1,4 · 99 | 100 · 1,3 · 100 |
| Kobold (1) | **100 · 2,9 · 82** | 100 · 2,8 · 87 | 100 · 2,4 · 93 | 100 · 2,0 · 96 | 100 · 1,7 · 98 | 100 · 1,4 · 99 |
| Blutflügler (1) | **100 · 2,9 · 82** | 100 · 2,3 · 90 | 100 · 1,9 · 95 | 100 · 1,5 · 98 | 100 · 1,4 · 99 | 100 · 1,4 · 99 |
| Wolf (2) | 100 · 4,7 · 72 | **100 · 3,4 · 74** | 100 · 3,1 · 78 | 100 · 2,9 · 82 | 100 · 2,5 · 89 | 100 · 2,1 · 94 |
| Wildschwein (2) | 100 · 3,7 · 78 | **100 · 3,0 · 84** | 100 · 2,9 · 88 | 100 · 2,9 · 91 | 100 · 2,7 · 95 | 100 · 2,3 · 97 |
| Riesen-Hundertfüßer (2) | 100 · 3,3 · 78 | **100 · 2,9 · 83** | 100 · 3,0 · 87 | 100 · 2,3 · 94 | 100 · 1,9 · 97 | 100 · 1,6 · 99 |
| Goblin (2) | 100 · 4,0 · 76 | **100 · 3,3 · 75** | 100 · 2,8 · 83 | 100 · 2,2 · 90 | 100 · 1,7 · 96 | 100 · 1,4 · 98 |
| Goblin-Späher (2) | 100 · 3,8 · 75 | **100 · 3,1 · 76** | 100 · 3,0 · 81 | 100 · 2,3 · 89 | 100 · 2,0 · 94 | 100 · 1,7 · 97 |
| Skelett (2) | 100 · 4,0 · 76 | **100 · 3,2 · 75** | 100 · 3,0 · 80 | 100 · 2,6 · 86 | 100 · 2,2 · 92 | 100 · 1,9 · 96 |
| Zombie (2) | 100 · 7,7 · 72 | **100 · 5,9 · 68** | 100 · 5,4 · 75 | 100 · 4,3 · 85 | 100 · 4,0 · 91 | 100 · 3,9 · 94 |
| Riesenfledermaus (3) | 94 · 14,2 · 64 | 100 · 10,7 · 64 | **100 · 8,1 · 65** | 100 · 6,4 · 65 | 100 · 5,1 · 71 | 100 · 4,4 · 80 |
| Goblin-Schamane (3) | 100 · 7,4 · 72 | 100 · 5,1 · 70 | **100 · 4,6 · 76** | 100 · 3,9 · 83 | 100 · 3,2 · 91 | 100 · 2,9 · 94 |
| Riesenspinne (4) | 0 · – · – | 6 · 16,2 · 38 | 41 · 15,4 · 42 | **87 · 13,5 · 53** | 100 · 10,6 · 60 | 100 · 7,9 · 60 |
| Ghul (4) | 19 · 15,6 · 48 | 70 · 14,2 · 52 | 95 · 12,3 · 59 | **100 · 9,0 · 61** | 100 · 7,0 · 63 | 100 · 5,3 · 68 |
| Ockerschleim (5) | 2 · 18,3 · 30 | 34 · 17,5 · 42 | 80 · 16,3 · 52 | 99 · 13,1 · 58 | **100 · 10,0 · 61** | 100 · 8,1 · 61 |

### Kräutersammler

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 3,0 · 77** | 100 · 2,8 · 86 | 100 · 2,6 · 91 | 100 · 2,0 · 96 | 100 · 1,7 · 98 | 100 · 1,3 · 99 |
| Kobold (1) | **99 · 3,4 · 72** | 100 · 2,9 · 85 | 100 · 2,7 · 90 | 100 · 2,7 · 94 | 100 · 2,3 · 97 | 100 · 1,9 · 99 |
| Blutflügler (1) | **99 · 3,1 · 73** | 100 · 2,9 · 84 | 100 · 2,7 · 90 | 100 · 2,1 · 95 | 100 · 1,8 · 98 | 100 · 1,5 · 99 |
| Wolf (2) | 51 · 3,7 · 42 | **85 · 3,5 · 53** | 99 · 3,0 · 70 | 100 · 2,9 · 80 | 100 · 2,7 · 87 | 100 · 2,7 · 90 |
| Wildschwein (2) | 96 · 4,4 · 57 | **100 · 4,0 · 72** | 100 · 3,1 · 86 | 100 · 2,8 · 92 | 100 · 2,7 · 95 | 100 · 2,7 · 96 |
| Riesen-Hundertfüßer (2) | 95 · 4,0 · 58 | **100 · 3,2 · 78** | 100 · 2,9 · 86 | 100 · 2,8 · 91 | 100 · 2,7 · 94 | 100 · 2,2 · 97 |
| Goblin (2) | 71 · 3,6 · 45 | **97 · 3,2 · 65** | 100 · 3,0 · 76 | 100 · 2,8 · 84 | 100 · 2,4 · 91 | 100 · 1,9 · 96 |
| Goblin-Späher (2) | 71 · 3,6 · 47 | **97 · 3,2 · 65** | 100 · 2,9 · 77 | 100 · 2,8 · 84 | 100 · 2,7 · 89 | 100 · 2,2 · 95 |
| Skelett (2) | 34 · 4,9 · 27 | **80 · 4,7 · 42** | 98 · 4,3 · 60 | 100 · 4,2 · 71 | 100 · 3,5 · 84 | 100 · 2,9 · 91 |
| Zombie (2) | 54 · 7,4 · 28 | **97 · 6,8 · 47** | 100 · 6,1 · 67 | 100 · 5,3 · 80 | 100 · 4,8 · 88 | 100 · 4,1 · 93 |
| Riesenfledermaus (3) | 0 · 8,2 · 19 | 7 · 7,0 · 21 | **48 · 6,6 · 29** | 89 · 6,6 · 39 | 99 · 5,9 · 59 | 100 · 5,3 · 74 |
| Goblin-Schamane (3) | 45 · 6,3 · 28 | 90 · 5,9 · 46 | **100 · 5,3 · 64** | 100 · 4,5 · 79 | 100 · 4,2 · 86 | 100 · 3,6 · 92 |
| Riesenspinne (4) | 0 · – · – | 0 · – · – | 0 · – · – | **2 · 7,5 · 18** | 28 · 7,2 · 21 | 77 · 6,9 · 33 |
| Ghul (4) | 0 · – · – | 0 · 7,5 · 22 | 6 · 6,6 · 27 | **38 · 6,4 · 27** | 80 · 6,3 · 36 | 99 · 5,8 · 54 |
| Ockerschleim (5) | 0 · – · – | 0 · – · – | 0 · – · – | 0 · 14,0 · 3 | **0 · 12,0 · 2** | 9 · 12,7 · 11 |

### Schmiedelehrling

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 1,8 · 92** | 100 · 1,4 · 97 | 100 · 1,4 · 98 | 100 · 1,4 · 99 | 100 · 1,4 · 99 | 100 · 1,4 · 99 |
| Kobold (1) | **100 · 2,4 · 85** | 100 · 1,9 · 93 | 100 · 1,5 · 97 | 100 · 1,4 · 99 | 100 · 1,4 · 99 | 100 · 1,4 · 99 |
| Blutflügler (1) | **100 · 1,8 · 90** | 100 · 1,5 · 96 | 100 · 1,4 · 97 | 100 · 1,4 · 98 | 100 · 1,4 · 99 | 100 · 1,4 · 99 |
| Wolf (2) | 87 · 2,7 · 59 | **96 · 2,8 · 68** | 99 · 2,3 · 82 | 100 · 1,9 · 90 | 100 · 1,5 · 96 | 100 · 1,4 · 98 |
| Wildschwein (2) | 100 · 3,0 · 76 | **100 · 3,0 · 83** | 100 · 2,6 · 90 | 100 · 2,1 · 95 | 100 · 1,7 · 98 | 100 · 1,4 · 99 |
| Riesen-Hundertfüßer (2) | 99 · 2,9 · 76 | **100 · 2,4 · 87** | 100 · 1,8 · 94 | 100 · 1,4 · 98 | 100 · 1,4 · 98 | 100 · 1,4 · 99 |
| Goblin (2) | 94 · 2,4 · 71 | **99 · 2,0 · 85** | 100 · 1,6 · 93 | 100 · 1,5 · 96 | 100 · 1,5 · 97 | 100 · 1,5 · 98 |
| Goblin-Späher (2) | 92 · 2,7 · 64 | **98 · 2,3 · 80** | 100 · 1,8 · 91 | 100 · 1,5 · 96 | 100 · 1,5 · 97 | 100 · 1,4 · 98 |
| Skelett (2) | 94 · 2,8 · 62 | **98 · 2,6 · 75** | 100 · 2,2 · 87 | 100 · 1,7 · 94 | 100 · 1,5 · 97 | 100 · 1,4 · 98 |
| Zombie (2) | 95 · 5,1 · 51 | **100 · 4,3 · 71** | 100 · 4,1 · 80 | 100 · 3,7 · 88 | 100 · 3,1 · 93 | 100 · 2,8 · 96 |
| Riesenfledermaus (3) | 23 · 4,8 · 31 | 55 · 4,8 · 36 | **91 · 4,6 · 50** | 99 · 4,4 · 64 | 100 · 4,1 · 75 | 100 · 3,4 · 85 |
| Goblin-Schamane (3) | 92 · 4,5 · 51 | 100 · 3,9 · 70 | **100 · 3,1 · 84** | 100 · 2,9 · 88 | 100 · 3,0 · 91 | 100 · 2,9 · 94 |
| Riesenspinne (4) | 0 · – · – | 2 · 5,4 · 25 | 18 · 5,1 · 22 | **49 · 5,0 · 30** | 81 · 4,9 · 42 | 97 · 4,6 · 57 |
| Ghul (4) | 4 · 5,5 · 22 | 18 · 4,7 · 29 | 52 · 4,7 · 35 | **87 · 4,5 · 48** | 97 · 4,4 · 59 | 100 · 4,2 · 69 |
| Ockerschleim (5) | 0 · – · – | 2 · 6,5 · 14 | 20 · 5,9 · 22 | 57 · 5,8 · 30 | **91 · 5,7 · 43** | 98 · 5,5 · 56 |

### Herumtreiber

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 1,6 · 94** | 100 · 1,3 · 97 | 100 · 1,4 · 98 | 100 · 1,3 · 99 | 100 · 1,3 · 99 | 100 · 1,3 · 100 |
| Kobold (1) | **100 · 2,1 · 87** | 100 · 1,7 · 94 | 100 · 1,4 · 98 | 100 · 1,3 · 99 | 100 · 1,3 · 99 | 100 · 1,3 · 100 |
| Blutflügler (1) | **100 · 1,6 · 93** | 100 · 1,4 · 97 | 100 · 1,3 · 98 | 100 · 1,4 · 98 | 100 · 1,3 · 99 | 100 · 1,3 · 99 |
| Wolf (2) | 90 · 2,5 · 62 | **98 · 2,6 · 70** | 100 · 2,2 · 84 | 100 · 1,9 · 90 | 100 · 1,6 · 96 | 100 · 1,3 · 98 |
| Wildschwein (2) | 100 · 2,7 · 79 | **100 · 2,7 · 85** | 100 · 2,4 · 92 | 100 · 2,1 · 95 | 100 · 1,7 · 98 | 100 · 1,4 · 99 |
| Riesen-Hundertfüßer (2) | 100 · 2,6 · 78 | **100 · 2,2 · 89** | 100 · 1,8 · 95 | 100 · 1,5 · 98 | 100 · 1,4 · 99 | 100 · 1,4 · 99 |
| Goblin (2) | 96 · 2,3 · 73 | **99 · 1,9 · 86** | 100 · 1,6 · 94 | 100 · 1,4 · 96 | 100 · 1,4 · 98 | 100 · 1,4 · 98 |
| Goblin-Späher (2) | 95 · 2,5 · 68 | **100 · 2,1 · 82** | 100 · 1,8 · 90 | 100 · 1,4 · 96 | 100 · 1,4 · 98 | 100 · 1,3 · 98 |
| Skelett (2) | 87 · 3,1 · 57 | **99 · 2,9 · 70** | 100 · 2,7 · 80 | 100 · 2,7 · 85 | 100 · 2,6 · 90 | 100 · 2,3 · 94 |
| Zombie (2) | 97 · 4,6 · 56 | **100 · 4,1 · 72** | 100 · 3,8 · 82 | 100 · 3,6 · 88 | 100 · 3,0 · 93 | 100 · 2,7 · 96 |
| Riesenfledermaus (3) | 24 · 4,7 · 35 | 62 · 4,7 · 37 | **93 · 4,3 · 54** | 99 · 4,3 · 65 | 100 · 4,0 · 74 | 100 · 3,4 · 86 |
| Goblin-Schamane (3) | 93 · 4,0 · 54 | 99 · 3,6 · 71 | **100 · 3,0 · 83** | 100 · 2,8 · 89 | 100 · 2,7 · 93 | 100 · 2,6 · 95 |
| Riesenspinne (4) | 0 · 5,0 · 52 | 4 · 5,4 · 23 | 18 · 4,9 · 27 | **53 · 4,8 · 34** | 84 · 4,8 · 45 | 98 · 4,5 · 59 |
| Ghul (4) | 4 · 5,1 · 21 | 20 · 4,6 · 33 | 60 · 4,6 · 38 | **88 · 4,4 · 49** | 98 · 4,2 · 61 | 100 · 3,9 · 72 |
| Ockerschleim (5) | 0 · – · – | 0 · – · – | 0 · 10,0 · 23 | 2 · 10,0 · 18 | **28 · 9,0 · 20** | 74 · 8,9 · 27 |

### Wanderer

| Art (Stufe) | Held 1 | Held 2 | Held 3 | Held 4 | Held 5 | Held 6 |
|---|---|---|---|---|---|---|
| Riesenratte (1) | **100 · 1,3 · 97** | 100 · 1,4 · 98 | 100 · 1,4 · 98 | 100 · 1,3 · 99 | 100 · 1,3 · 99 | 100 · 1,3 · 100 |
| Kobold (1) | **100 · 1,6 · 95** | 100 · 1,4 · 98 | 100 · 1,4 · 98 | 100 · 1,3 · 99 | 100 · 1,3 · 99 | 100 · 1,3 · 100 |
| Blutflügler (1) | **100 · 1,4 · 96** | 100 · 1,4 · 97 | 100 · 1,4 · 98 | 100 · 1,4 · 99 | 100 · 1,3 · 99 | 100 · 1,3 · 99 |
| Wolf (2) | 96 · 2,4 · 70 | **99 · 2,1 · 82** | 100 · 1,8 · 90 | 100 · 1,4 · 96 | 100 · 1,4 · 97 | 100 · 1,4 · 98 |
| Wildschwein (2) | 100 · 2,8 · 82 | **100 · 2,3 · 90** | 100 · 1,9 · 95 | 100 · 1,6 · 98 | 100 · 1,4 · 99 | 100 · 1,3 · 99 |
| Riesen-Hundertfüßer (2) | 100 · 2,0 · 89 | **100 · 1,7 · 94** | 100 · 1,4 · 97 | 100 · 1,4 · 98 | 100 · 1,4 · 99 | 100 · 1,3 · 99 |
| Goblin (2) | 99 · 1,8 · 87 | **100 · 1,5 · 93** | 100 · 1,5 · 95 | 100 · 1,5 · 96 | 100 · 1,4 · 98 | 100 · 1,4 · 98 |
| Goblin-Späher (2) | 98 · 1,9 · 83 | **100 · 1,7 · 91** | 100 · 1,4 · 96 | 100 · 1,4 · 97 | 100 · 1,4 · 98 | 100 · 1,4 · 99 |
| Skelett (2) | 96 · 2,8 · 68 | **100 · 2,8 · 76** | 100 · 2,8 · 82 | 100 · 2,6 · 88 | 100 · 2,2 · 93 | 100 · 1,9 · 96 |
| Zombie (2) | 100 · 4,1 · 68 | **100 · 4,0 · 77** | 100 · 3,4 · 86 | 100 · 2,9 · 92 | 100 · 2,7 · 95 | 100 · 2,5 · 97 |
| Riesenfledermaus (3) | 57 · 4,5 · 36 | 88 · 4,2 · 50 | **98 · 4,2 · 60** | 100 · 3,8 · 73 | 100 · 3,2 · 84 | 100 · 2,8 · 89 |
| Goblin-Schamane (3) | 98 · 3,5 · 69 | 100 · 3,0 · 81 | **100 · 2,9 · 87** | 100 · 2,8 · 90 | 100 · 2,7 · 93 | 100 · 2,3 · 96 |
| Riesenspinne (4) | 2 · 5,7 · 20 | 10 · 5,0 · 27 | 43 · 4,8 · 28 | **77 · 4,6 · 41** | 95 · 4,3 · 54 | 99 · 4,3 · 64 |
| Ghul (4) | 20 · 4,7 · 29 | 48 · 4,4 · 34 | 83 · 4,1 · 46 | **94 · 4,2 · 55** | 99 · 3,9 · 67 | 100 · 3,3 · 79 |
| Ockerschleim (5) | 0 · – · – | 0 · – · – | 2 · 9,4 · 14 | 15 · 8,7 · 20 | **52 · 8,5 · 25** | 89 · 8,2 · 37 |

## 4. Überblick: Held gegen Art gleicher Stufe

Siegquote % · Züge bis Sieg, Heldenstufe = Gegnerstufe; Spalte „21“ = Mittel aller Arten mit 21 Punkten.

| Herkunft | Riesenratte | Kobold | Blutflügler | Wolf | Wildschwein | Riesen-Hundertfüßer | Goblin | Goblin-Späher | Skelett | Zombie | Riesenfledermaus | Goblin-Schamane | Riesenspinne | Ghul | Ockerschleim | Mittel | Mittel (21) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat | 100 · 1,4 | 100 · 1,9 | 100 · 1,5 | 100 · 2,4 | 100 · 2,7 | 100 · 1,9 | 100 · 1,8 | 100 · 1,9 | 100 · 2,9 | 100 · 4,0 | 100 · 4,5 | 100 · 2,9 | 99 · 5,7 | 100 · 4,4 | 100 · 10,5 | 100 | 100 |
| Jägerkind | 100 · 1,3 | 100 · 1,7 | 100 · 1,3 | 99 · 2,2 | 100 · 2,4 | 100 · 1,8 | 100 · 1,5 | 100 · 1,8 | 99 · 2,6 | 100 · 3,7 | 97 · 3,9 | 100 · 2,7 | 65 · 4,5 | 95 · 3,9 | 97 · 5,0 | 97 | 98 |
| Zauberlehrling | 100 · 2,4 | 100 · 2,4 | 100 · 2,4 | 99 · 2,8 | 100 · 3,1 | 100 · 2,5 | 100 · 2,5 | 100 · 2,5 | 98 · 3,8 | 100 · 4,8 | 96 · 5,0 | 100 · 3,8 | 68 · 5,0 | 93 · 5,0 | 96 · 5,9 | 97 | 98 |
| Klosterschüler | 100 · 2,8 | 100 · 2,9 | 100 · 2,9 | 100 · 3,4 | 100 · 3,0 | 100 · 2,9 | 100 · 3,3 | 100 · 3,1 | 100 · 3,2 | 100 · 5,9 | 100 · 8,1 | 100 · 4,6 | 87 · 13,5 | 100 · 9,0 | 100 · 10,0 | 99 | 100 |
| Kräutersammler | 100 · 3,0 | 99 · 3,4 | 99 · 3,1 | 85 · 3,5 | 100 · 4,0 | 100 · 3,2 | 97 · 3,2 | 97 · 3,2 | 80 · 4,7 | 97 · 6,8 | 48 · 6,6 | 100 · 5,3 | 2 · 7,5 | 38 · 6,4 | 0 · 12,0 | 76 | 84 |
| Schmiedelehrling | 100 · 1,8 | 100 · 2,4 | 100 · 1,8 | 96 · 2,8 | 100 · 3,0 | 100 · 2,4 | 99 · 2,0 | 98 · 2,3 | 98 · 2,6 | 100 · 4,3 | 91 · 4,6 | 100 · 3,1 | 49 · 5,0 | 87 · 4,5 | 91 · 5,7 | 94 | 96 |
| Herumtreiber | 100 · 1,6 | 100 · 2,1 | 100 · 1,6 | 98 · 2,6 | 100 · 2,7 | 100 · 2,2 | 99 · 1,9 | 100 · 2,1 | 99 · 2,9 | 100 · 4,1 | 93 · 4,3 | 100 · 3,0 | 53 · 4,8 | 88 · 4,4 | 28 · 9,0 | 90 | 93 |
| Wanderer | 100 · 1,3 | 100 · 1,6 | 100 · 1,4 | 99 · 2,1 | 100 · 2,3 | 100 · 1,7 | 100 · 1,5 | 100 · 1,7 | 100 · 2,8 | 100 · 4,0 | 98 · 4,2 | 100 · 2,9 | 77 · 4,6 | 94 · 4,2 | 52 · 8,5 | 95 | 95 |

## 5. Wirtschaft: Gold, Beute, Zerlegen, Abnutzung, Reparatur, Tränke, Tiere beruhigen (Stufe 3, 447.3)

**Befund (Jerry, 01.11., 14:3x; nur Zahlen, Einstellen bei Sokrates; neu rechnen: `python3 tools/sim444/sim.py --nur-wirtschaft`):**

1. **Einnahmen Kapitel 1: 155 bis 180 Gold** je Lauf bis Stufe 6 (ohne Quests; alte Aufträge brachten 40–60 Gold je Auftrag). Davon Beute-Gold rund 70 %, Zerlegen 25–27 %, Verkauf von Beute 4 %.
2. **Gold am Ende: Median 68 (Herumtreiber, beruhigt) bis 163 (Wachsoldat)**, bei 10 % der Läufe unter 11 bis 119. Gegen die alten Preise: ein Langbogen (50) ist für alle drin, ein Kettenpanzer (75) für alle außer dem Herumtreiber, die Brustplatte (400, Stufe 4) für keinen.
3. **Reparatur kostet fast nichts:** 0 bis 14 Gold je Kapitel (höchstens 8 % der Einnahmen), kein Kampf mit Warnung oder Defekt, weil der Held alle 8 Kämpfe ins Dorf geht. Mit dreifacher Abnutzung (Probelauf) 0 bis 42 Gold, Wachsoldat 31 % seines Endgolds. Für „spürbare Wirkung“ (Stufe 3.5) sind die Abnutzungszahlen der Hebel.
4. **Tränke sind der größte Posten:** 15 Gold (Wachsoldat, trinkt 0,4) bis 106 Gold (Herumtreiber, trinkt 5,8). Der Kräutersammler braut 6,4 Heiltränke (51 Gold), trinkt 8 und verliert trotzdem 10 % seiner Kämpfe.
5. **Tiere beruhigen spielt in Kapitel 1 kaum mit:** rund 4 Versuche je Kapitel, 42 % gelingen, die Fertigkeit bleibt bei 1 (keine Herkunft beginnt damit); spart 1 bis 2 Kämpfe und kostet 5 bis 15 Gold Endgold (keine Beute, kein Zerlegen).
6. **Jagd steigt nur auf 3 bis 4** (Start 0), Ausbeute damit 0,45 statt 0,4; die Fertigkeit merkt man in Kapitel 1 am Erlös kaum.

Was die Zahlen wenig belastbar macht: Abnutzung, Reparaturanteil, Trankwirkung, Teilepreise ohne alten Preis und das Dorf alle 8 Kämpfe sind Annahmen; Kopf, Arme, Beine, Umhang und Ruf fehlen; Preise wie alt bis 458.2a.

Fortschritt wie Abschnitt 1, aber mit 21 Punkten (Entscheidung 77), Gold und Beutel; 400 Läufe je Herkunft und Spielweise. „kämpft“: jede Begegnung wird gekämpft; „beruhigt“: bei Tieren (Riesenratte, Wolf, Wildschwein, Riesenfledermaus) erst Tiere beruhigen, misslingt es, Kampf mit Erstschlag des Tiers. Gold: Mittel je Lauf bis Stufe 6, Gold am Ende: Median (10 % der Läufe haben weniger als „p10“).

**Annahmen** (alle in `werte.json`, Block `wirtschaft`, Quelle je Zeile):

- **Gold und Beute** wie in der alten Fassung (Gold als Würfelspanne, Tränke, Alchemistenfeuer, Weihwasser mit Chance); Tierteile nur noch über Zerlegen. Start 20 Gold und 2 Heiltränke; Händler zahlt 50 % des Ladenpreises.
- **Zerlegen** nach jedem Sieg über Tier, Kriechtier, Skelett, Schleim (Teile nach Bestiarium): erstes Teil immer, weitere mit Chance = Ausbeute, Erlös × Ausbeute; Ausbeute = 0,4 + 0,6 × Jagd/49; übt Jagd (Start 0 bei allen Herkünften).
- **Tiere beruhigen:** Chance = 50 % + (Fertigkeit − Wachsamkeit des Tiers) × 0,5, 5 bis 95 %; Anfänger bis Tierstufe 2, Geselle bis 4; gelungen: Erfahrung wie Sieg, keine Beute, kein Zerlegen, keine Abnutzung; übt bei jedem Versuch.
- **Abnutzung:** Zustand 100; −1,0 je eigenem Waffentreffer, −1,0 je erlittenem Treffer (Rüstung und Schild), −1,0 je Abwehr mit dem Schild, × (1 + (Gegnerstufe − Heldenstufe)/5). Makellos ab 90, Benutzt ab 50 (Leistung 0,95), Beschädigt (Leistung 0,75), Defekt bei 0 (wirkt nicht).
- **Dorf und Reparatur:** alle 8 Kämpfe ins Dorf, sofort nach dem Kampf, in dem ein Stück „Beschädigt“ wird; dort verkaufen, „Alles reparieren“, Tränke auffüllen. Handwerker: von 0 auf 100 kostet 50 % des Ladenpreises; selbst (Schmieden bzw. Lederarbeit mit Rang nach Abschnitt 11): 20 % als Material. Ladenpreise alt: Langschwert 15, Kurzbogen 25, Dolch 2, Streitkolben 5, Kettenhemd 50, Lederrüstung 10, Schild 10.
- **Tränke:** Heiltrank heilt 12, großer 30 (Preis 25 und 75); getrunken statt Angriff unter 35 % Leben; im Dorf bis 3 im Beutel, wer Alchemie hat, braut für 8 Gold.

### 5.1 Gold je Lauf bis Stufe 6

| Herkunft | Spielweise | Kämpfe | Beute-Gold | Verkauf Beute | Zerlegen | Reparatur | davon selbst | Tränke | Gold am Ende (p10) | Gold bei Stufe 3 | Niederl. % |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat | kämpft | 20 | 120 | 6 | 44 | 13 | 0 | 15 | 163 (119) | 65 | 0 |
| Wachsoldat | beruhigt | 19 | 117 | 6 | 37 | 14 | 0 | 15 | 153 (105) | 64 | 0 |
| Jägerkind | kämpft | 21 | 124 | 6 | 45 | 6 | 0 | 52 | 139 (65) | 65 | 1 |
| Jägerkind | beruhigt | 20 | 120 | 5 | 39 | 6 | 0 | 53 | 127 (51) | 62 | 1 |
| Zauberlehrling | kämpft | 22 | 126 | 6 | 47 | 0 | 0 | 57 | 144 (77) | 65 | 1 |
| Zauberlehrling | beruhigt | 21 | 128 | 7 | 40 | 0 | 0 | 60 | 140 (62) | 63 | 1 |
| Klosterschüler | kämpft | 19 | 116 | 6 | 40 | 3 | 0 | 52 | 130 (58) | 62 | 0 |
| Klosterschüler | beruhigt | 18 | 109 | 6 | 35 | 3 | 0 | 52 | 115 (52) | 59 | 0 |
| Kräutersammler | kämpft | 22 | 111 | 5 | 39 | 4 | 0 | 51 | 117 (82) | 60 | 10 |
| Kräutersammler | beruhigt | 21 | 111 | 6 | 33 | 3 | 0 | 51 | 113 (77) | 58 | 11 |
| Schmiedelehrling | kämpft | 21 | 118 | 6 | 41 | 2 | 0 | 83 | 100 (24) | 63 | 3 |
| Schmiedelehrling | beruhigt | 19 | 114 | 5 | 34 | 2 | 0 | 80 | 88 (20) | 60 | 3 |
| Herumtreiber | kämpft | 22 | 120 | 6 | 42 | 3 | 0 | 106 | 74 (18) | 66 | 4 |
| Herumtreiber | beruhigt | 20 | 117 | 7 | 36 | 2 | 0 | 102 | 68 (11) | 62 | 4 |
| Wanderer | kämpft | 21 | 125 | 7 | 45 | 5 | 0 | 79 | 109 (31) | 67 | 2 |
| Wanderer | beruhigt | 20 | 121 | 6 | 38 | 5 | 0 | 81 | 98 (25) | 63 | 2 |

### 5.2 Tränke, Zustand, Fertigkeiten

| Herkunft | Spielweise | getrunken | gefunden | gekauft | gebraut | Dorfbesuche | Kämpfe mit Warnung % | mit Defekt % | Jagd am Ende | zerlegt | Tiere beruhigt (gelungen %) | Tiere beruhigen am Ende |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Wachsoldat | kämpft | 0,4 | 2,6 | 0,6 | 0,0 | 3,1 | 0 | 0 | 4 | 10,9 | – | – |
| Wachsoldat | beruhigt | 0,5 | 2,5 | 0,6 | 0,0 | 3,0 | 0 | 0 | 3 | 9,2 | 1,6 (41) | 1 |
| Jägerkind | kämpft | 2,9 | 2,9 | 2,1 | 0,0 | 3,2 | 0 | 0 | 4 | 11,2 | – | – |
| Jägerkind | beruhigt | 2,9 | 2,5 | 2,1 | 0,0 | 3,1 | 0 | 0 | 3 | 9,7 | 1,8 (42) | 1 |
| Zauberlehrling | kämpft | 3,2 | 2,8 | 2,3 | 0,0 | 3,3 | 0 | 0 | 4 | 11,6 | – | – |
| Zauberlehrling | beruhigt | 3,2 | 2,8 | 2,4 | 0,0 | 3,1 | 0 | 0 | 3 | 9,9 | 1,8 (42) | 1 |
| Klosterschüler | kämpft | 2,7 | 2,5 | 2,1 | 0,0 | 3,0 | 0 | 0 | 3 | 10,1 | – | – |
| Klosterschüler | beruhigt | 2,8 | 2,4 | 2,1 | 0,0 | 2,8 | 0 | 0 | 3 | 8,6 | 1,6 (42) | 1 |
| Kräutersammler | kämpft | 8,0 | 2,7 | 0,0 | 6,4 | 3,4 | 0 | 0 | 3 | 10,3 | – | – |
| Kräutersammler | beruhigt | 7,8 | 2,5 | 0,0 | 6,4 | 3,2 | 0 | 0 | 3 | 8,6 | 1,8 (43) | 1 |
| Schmiedelehrling | kämpft | 4,6 | 2,7 | 3,3 | 0,0 | 3,1 | 0 | 0 | 4 | 10,6 | – | – |
| Schmiedelehrling | beruhigt | 4,3 | 2,5 | 3,2 | 0,0 | 3,0 | 0 | 0 | 3 | 8,9 | 1,6 (41) | 1 |
| Herumtreiber | kämpft | 5,8 | 2,7 | 4,2 | 0,0 | 3,3 | 0 | 0 | 4 | 10,7 | – | – |
| Herumtreiber | beruhigt | 5,5 | 2,6 | 4,1 | 0,0 | 3,1 | 0 | 0 | 3 | 9,2 | 1,8 (42) | 1 |
| Wanderer | kämpft | 4,5 | 2,8 | 3,1 | 0,0 | 3,3 | 0 | 0 | 4 | 11,1 | – | – |
| Wanderer | beruhigt | 4,5 | 2,6 | 3,3 | 0,0 | 3,1 | 0 | 0 | 3 | 9,6 | 1,8 (42) | 1 |


## 6. Tränke im Bosskampf (481.1)

Jerry, 02.11.; neu gerechnet Tuffy, 11.11. (876, 857a A: Kräuterkunde heißt Kräutersammeln, die Trankwirkung hängt an Alchemie; Zweig `claude/tuffy-876-kraeutersammeln`). Nur dieser Teil: `python3 tools/sim444/sim.py --nur-traenke`; Werte heute (mit Grak nach 870c und 870.6), daher andere Bosszahlen als Abschnitt 2 oben.

**Befund (nur Zahlen, Einstellen bei Sokrates):**
1. **Zwei Heiltränke (50 Gold) tragen am meisten:** Herkünfte ab 50 % Krogg 2 → 6, Grimmzahn 5 → 6, Grak 7 → 7, Krogg mit Rauch 5 → 7.
2. **Kampftränke ohne Alchemie schaden** (Wirkung 0,5, jeder Trank ein Zug): schlechter als nur Heiltränke, etwa Zauberlehrling gegen Grimmzahn 85 → 37 %.
3. **Mit Alchemie beginnt nur der Kräutersammler.** Der Klosterschüler (bisher Kräuterkunde 10, Wirkung 1) braut jetzt mit Wirkung 0,5: mit Kampftränken gegen Grimmzahn 80 → 72 %, sonst ±2 (Krogg 94, Grak 98, Krogg mit Rauch 97); ohne Tränke unverändert 69–97 %.
4. **Kräutersammler bleibt fast chancenlos:** ohne 0–5 %, Heil 4–20 %, Kampf 10–30 %. In der Simulation übt nichts seine Alchemie (Brauen nicht gerechnet), sie bleibt bei 10.
5. **Erst Alchemie 24 (Decke Kapitel 1) und viel Feuer bringen ihn zur Mitte:** 6 Alchemistenfeuer (230 Gold) 62 / 58 / 72 %, mit Rauch 81 % (6b); mit dem Satz wie oben 24–54 %.

Offen: wie Alchemie in Kapitel 1 steigt (Brauen), Preise und Wirkung (alle A).

Held auf der Stufe des Bosses, Fertigkeiten aus Abschnitt 1 (18 Punkte); je Fall 1000 Kämpfe; Sieg in %. „ohne“ wie Abschnitt 2; „Heil“: 2 Heiltränke; „Kampf“: dazu 1 Steinhaut, 1 Berserkertrank, 2 Alchemistenfeuer (Beutel 190 Gold), Wirkung nach Alchemie wie gerechnet; „Kampf, Alch. 24“: nur wer mit Alchemie beginnt, geübt bis zur Decke von Kapitel 1.

- **Wirkung** = 0.5 + 0.05 × Alchemie, höchstens 2.0 (ohne 0,5, Startwert 10 = 1, 24 = 1,7). Steinhaut: 2 Runden Schaden × (1 − 0.5 × Wirkung), bei 2 unverwundbar; Berserkertrank: 3 Angriffe mit Waffenschaden × (1 + 0.5 × Wirkung), nicht für Zauberer; Alchemistenfeuer: geworfen, Grundschaden 10 × Wirkung, Feuer. Jeder Trank kostet einen Zug. Alle Zahlen Annahmen (`werte.json` „kampftraenke“).

**Krogg**

| Herkunft | Alchemie | ohne | Heil | Kampf | Kampf, Alch. 24 |
|---|---|---|---|---|---|
| Wachsoldat | 0 | **100** | **100** | **100** | – |
| Jägerkind | 0 | 26 | **66** | **55** | – |
| Zauberlehrling | 0 | 26 | **63** | 39 | – |
| Klosterschüler | 0 | **89** | **96** | **94** | – |
| Kräutersammler | 10 | 0 | 4 | 10 | 24 |
| Schmiedelehrling | 0 | 15 | 44 | 32 | – |
| Herumtreiber | 0 | 20 | **54** | 40 | – |
| Wanderer | 0 | 38 | **71** | **66** | – |
| ab 50 % | | 2 | 6 | 4 | |

**Grimmzahn**

| Herkunft | Alchemie | ohne | Heil | Kampf | Kampf, Alch. 24 |
|---|---|---|---|---|---|
| Wachsoldat | 0 | **100** | **100** | **100** | – |
| Jägerkind | 0 | **53** | **71** | **57** | – |
| Zauberlehrling | 0 | **65** | **85** | 37 | – |
| Klosterschüler | 0 | **69** | **79** | **72** | – |
| Kräutersammler | 10 | 1 | 4 | 10 | 26 |
| Schmiedelehrling | 0 | 33 | 46 | 36 | – |
| Herumtreiber | 0 | 37 | **58** | 47 | – |
| Wanderer | 0 | **56** | **75** | **62** | – |
| ab 50 % | | 5 | 6 | 4 | |

**Grak**

| Herkunft | Alchemie | ohne | Heil | Kampf | Kampf, Alch. 24 |
|---|---|---|---|---|---|
| Wachsoldat | 0 | **100** | **100** | **100** | – |
| Jägerkind | 0 | **74** | **90** | **87** | – |
| Zauberlehrling | 0 | **75** | **91** | **74** | – |
| Klosterschüler | 0 | **97** | **99** | **98** | – |
| Kräutersammler | 10 | 5 | 20 | 30 | 47 |
| Schmiedelehrling | 0 | **53** | **76** | **68** | – |
| Herumtreiber | 0 | **55** | **81** | **76** | – |
| Wanderer | 0 | **77** | **92** | **86** | – |
| ab 50 % | | 7 | 7 | 7 | |

**Krogg mit Rauch**

| Herkunft | Alchemie | ohne | Heil | Kampf | Kampf, Alch. 24 |
|---|---|---|---|---|---|
| Wachsoldat | 0 | **100** | **100** | **100** | – |
| Jägerkind | 0 | **64** | **90** | **85** | – |
| Zauberlehrling | 0 | **72** | **93** | **71** | – |
| Klosterschüler | 0 | **97** | **99** | **97** | – |
| Kräutersammler | 10 | 2 | 14 | 27 | **54** |
| Schmiedelehrling | 0 | 49 | **75** | **67** | – |
| Herumtreiber | 0 | 49 | **80** | **75** | – |
| Wanderer | 0 | **77** | **92** | **87** | – |
| ab 50 % | | 5 | 7 | 7 | |

### 6b. Kräutersammler mit anderem Beutel

Sieg in %, je 2 Heiltränke dazu; Alchemie gesetzt. Preis des Beutels in Gold.

| Alchemie | Beutel | Gold | Krogg | Grimmzahn | Grak | Krogg mit Rauch |
|---|---|---|---|---|---|---|
| 10 | Satz wie oben | 190 | 8 | 11 | 29 | 27 |
| 10 | 2 Steinhaut, 1 Berserker, 4 Feuer | 290 | 10 | 8 | 25 | 25 |
| 10 | 6 Feuer | 230 | 11 | 9 | 25 | 29 |
| 24 | Satz wie oben | 190 | 26 | 24 | 49 | **51** |
| 24 | 2 Steinhaut, 1 Berserker, 4 Feuer | 290 | 49 | 40 | **62** | **70** |
| 24 | 6 Feuer | 230 | **62** | **58** | **72** | **81** |
| 30 | Satz wie oben | 190 | 38 | 35 | **57** | **60** |
| 30 | 2 Steinhaut, 1 Berserker, 4 Feuer | 290 | **62** | **55** | **76** | **78** |
| 30 | 6 Feuer | 230 | **75** | **71** | **80** | **88** |

