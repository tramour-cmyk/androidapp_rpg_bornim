# Regelwerte (erzeugt, nicht von Hand ändern)

Nachschlagen (969, Chef 11.11., 15:49): jede Zahl des Bornimer Rollenspielsystems, mit der das Spiel heute rechnet, je Block die Regel als Satz (`DESIGN-BRS.md`), Formel und Erläuterung, die heutige Zahl und wo sie im Spiel gelesen wird. Aus `tools/sim444/werte.json` mit `python3 tools/regelwerte.py`.

**Stand:** `werte.json` aus Commit `8a07045f8` auf `main`; 25 Blöcke.

- **Ändern:** nur in `werte.json` auf einem Arbeitszweig (das Spiel liest die Datei, also testet der Chef); nach dem Mischen auf `main` das Werkzeug laufen lassen und die Seite committen. Wer Einfluss nehmen will, nennt Block und Wert (z. B. `ueben.bedarf_teiler`).
- **Herkunft** je Block: N = Nachschlagewerk DESIGN-BRS.md, B = LISTE-BESTIARIUM.md 'Werte 2.0', A = Annahme (im Nachschlagewerk ohne Zahl, hier gesetzt, damit gerechnet werden kann).
- **wirkt in:** Fundstellen des Schlüssels in Dateien, die den Block lesen (Spielcode ohne Tests, dazu die Simulation `tools/sim444`); Pfade unter `godot/`, „Sim.“ = die Simulation `tools/sim444` liest den Wert auch; „–“ heißt: im Code nicht unter diesem Namen gefunden (oft nur Simulation, über eine Hilfsfunktion gelesen oder noch nicht gebaut).

**Blöcke:** [lauf](#lauf), [held](#held), [kampf](#kampf), [proben](#proben), [gegenwirkung](#gegenwirkung), [erfahrung](#erfahrung), [ueben](#ueben), [waffen](#waffen), [zauber](#zauber), [handlungen](#handlungen), [ruestungen](#ruestungen), [herkuenfte](#herkuenfte), [monster](#monster), [merkmale](#merkmale), [wirtschaft](#wirtschaft), [fortschritt](#fortschritt), [erschaffung](#erschaffung), [kampftraenke](#kampftraenke), [kampftasche](#kampftasche), [welt](#welt), [zustaende](#zustaende), [gegenstaende](#gegenstaende), [monsterregeln](#monsterregeln), [absicht_zusatz](#absicht_zusatz), [kennungen](#kennungen)

## lauf

- **Herkunft der Zahlen:** Auftrag 444: je Fall 1000 Kaempfe; Fortschritt: Laeufe je Herkunft (A)
- **Gelesen von:** `tools/sim444/sim.py`, `tools/sim444/handlungen.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `kaempfe_je_fall` | 1000 | – | Sim. |
| `fortschritt_laeufe` | 400 | – | Sim. |
| `stufen` | 1, 2, 3, 4, 5, 6 | – | Sim. |
| `zufallskeim` | 444 | – | Sim. |
| `max_runden` | 60 | – | Sim. |

## held

- **Regel** (`DESIGN-BRS.md` „2. Der Held“): Abgeleitet: Leben aus Zähigkeit und Stufe, Ausdauer aus Zähigkeit, Wille und Stufe, je Stufe langsamer steigend als das Leben (930 Frage 10, Chef 11.11., 14:45; Zahlen Jerry mit 444), Mana aus Wille.
- **Regel** (`DESIGN-BRS.md` „4. Heldenstufe und Erfahrung“): Leben des Helden – 10 + 5 × Stufe + 2 × Zähigkeit
- **Herkunft der Zahlen:** N 2 und 4; Startwert Fertigkeit 10 (N 2); Punkte 18 (Entscheidung 64), 21 (Vorschlag 422 a)
- **Gelesen von:** `regeln/brs.gd`, `regeln/brs_fertigkeit.gd`, `regeln/brs_held.gd`, `regeln/brs_kampf.gd`, `regeln/mars.gd`, `skripte/menue.gd`, `tools/sim444/sim.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `grundwert_min` | 3 | – | `regeln/brs_held.gd:104`, `regeln/brs_kampf.gd:65`, Sim. |
| `grundwert_max` | 8 | – | `regeln/brs_held.gd:105`, `regeln/brs_kampf.gd:71`, Sim. |
| `punkte_frei` | 6 | – | – |
| `punkte_frei_variante` | 9 | – | – |
| `startfertigkeit` | 10 | – | `regeln/brs_held.gd:211`, `regeln/brs_kampf.gd:73`, Sim. |
| `leben_basis` | 10 | – | `regeln/brs_held.gd:231`, `regeln/brs_kampf.gd:107`, Sim. |
| `leben_je_stufe` | 5 | – | `regeln/brs_held.gd:231`, `regeln/brs_kampf.gd:107`, Sim. |
| `leben_je_zaehigkeit` | 2 | – | `regeln/brs_held.gd:231`, `regeln/brs_kampf.gd:107`, +1, Sim. |
| `mana_basis` | 10 | – | `regeln/brs_held.gd:232`, `regeln/mars.gd:594`, Sim. |
| `mana_je_wille` | 5 | – | `regeln/brs_held.gd:232`, `regeln/mars.gd:594`, +1, Sim. |
| `kapitelgrenze` | 6 | – | `regeln/brs.gd:147`, Sim. |
| `rangdecken_kapitel` | 24, 49 | Kapitel 1: Anfaenger bis 24, Bewaehrungsprobe, dann Geselle bis 49 (N 3, N 5 Tabelle 'Kapitel als Takt') | `regeln/brs_fertigkeit.gd:18`, Sim. |

## kampf

- **Regel** (`DESIGN-BRS.md` „Entwurf A zur Entscheidung: Rechenmodelle für den Kampf“): Gemeinsam ist allen: Schaden = (Waffe + Grundwert + Fertigkeit) × Faktor − Rüstung, kleine Streuung.
- **Regel** (`DESIGN-BRS.md` „4. Heldenstufe und Erfahrung“): Wahrnehmung – Trefferchance im Fernkampf + 1 Prozentpunkt je Punkt
- **Herkunft der Zahlen:** Modell D (N Entwurf A) und N 4; Streuung und Erstschlag A
- **Gelesen von:** `regeln/brs.gd`, `regeln/brs_held.gd`, `regeln/brs_kampf.gd`, `regeln/mars.gd`, `skripte/menue.gd`, `tools/sim444/sim.py`, `tools/sim444/handlungen.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `trefferchance_basis` | 70 | – | `regeln/brs.gd:79`, Sim. |
| `trefferchance_je_punkt` | 0,5 | – | `regeln/brs.gd:79`, Sim. |
| `trefferchance_min` | 5 | – | `regeln/brs.gd:80`, Sim. |
| `trefferchance_max` | 95 | – | `regeln/brs.gd:80`, Sim. |
| `stufenfaktor_je_stufe` | 0,1 | – | `regeln/brs.gd:74`, Sim. |
| `fertigkeit_im_schaden_je_punkt` | 0,01 | – | `regeln/brs.gd:90`, `regeln/brs_held.gd:252`, Sim. |
| `ruestungsfertigkeit_im_abzug_je_punkt` | 0,01 | – | `regeln/brs_held.gd:299`, `regeln/brs_kampf.gd:149`, +1, Sim. |
| `glueckstreffer_anteil` | 0,01 | – | `regeln/brs.gd:88`, `regeln/brs_kampf.gd:169`, Sim. |
| `kritisch_faktor` | 1,5 | – | `regeln/brs.gd:92`, `regeln/mars.gd:2158`, Sim. |
| `kritisch_prozent_je_gewandtheit` | 1 | – | `regeln/brs_held.gd:243`, `regeln/mars.gd:2154`, Sim. |
| `ausweichen_je_gewandtheit` | 2 | – | `regeln/brs_kampf.gd:130`, `skripte/menue.gd:406`, Sim. |
| `fernkampf_treffer_je_wahrnehmung` | 1 | – | `regeln/mars.gd:2148`, `skripte/menue.gd:407`, Sim. |
| `parieren_anteil_waffenfertigkeit` | 0,5 | – | `regeln/brs_kampf.gd:135`, Sim. |
| `streuung` | 0,2 | A: Schaden x gleichverteilt 0,8 bis 1,2 ('kleine Streuung') | `regeln/brs.gd:93`, Sim. |
| `held_schlaegt_zuerst` | ja | – | – |
| `schaden_runden` | ja | – | `regeln/brs.gd:101`, Sim. |
| `leicht_ab` | 4 | 870.6 (LISTE-UMZUG-BRS.md 5: leichter Gegner nach Stufenunterschied statt Herausforderungsgrad): ab so vielen Heldenstufen ueber dem staerksten Gegner (kein Boss) ist der Kampf leicht; der Held verliert dann nur die Haelfte, ab 'leicht_null_ab' nichts (alt EASY_GAP 4, 7, 10 nach CR, A) | `regeln/mars.gd:423` |
| `leicht_halb_ab` | 7 | – | `regeln/mars.gd:689` |
| `leicht_null_ab` | 10 | – | `regeln/mars.gd:689` |

- **erstschlag:** A: Held beginnt jede Runde; Hinterhalt (Schleichen) nicht gerechnet

## proben

- **Regel** (`DESIGN-BRS.md` „7. Kampf“): (5) Proben als Prozent wie die Trefferchance: Initiative und Flucht nach Gewandtheit, Abwehrprobe mit Zähigkeit (Gift, Krankheit), Wille (Furcht, Zauber), Gewandtheit (Flächen)
- **Herkunft der Zahlen:** 870.5 (870a 5 A, DESIGN-BRS.md 7): Proben als Prozent wie die Trefferchance; alle Zahlen vorlaeufig (A, Jerry), die Simulation kennt sie noch nicht; Werte-Vorlage an den Chef vor B1
- **Gelesen von:** `regeln/mars.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `basis` | 50 | – | `regeln/mars.gd:539`, `regeln/mars.gd:569` |
| `je_punkt` | 5 | – | `regeln/brs_held.gd:308`, `regeln/mars.gd:539`, +2 |
| `je_stufe` | 5 | – | `regeln/mars.gd:540`, `regeln/mars.gd:559` |
| `min` | 5 | – | `regeln/mars.gd:541` |
| `max` | 95 | – | `regeln/mars.gd:541` |
| `gegner_grundwert` | 5 | – | `regeln/mars.gd:533` |
| `abwehr_mitte` | 11 | Abwehrprobe gegen einen Zustand mit Zaehigkeit (Gift, Betaeubung, Blindheit), Wille oder Gewandtheit gegen den staerksten stehenden Gegner; je Punkt Schwere des alten Rettungswurfs ueber abwehr_mitte ein Grundwertpunkt mehr dagegen | `regeln/mars.gd:1512` |
| `initiative_streuung` | 100 | Reihenfolge nach je_punkt x Gewandtheit + je_stufe x Stufe + Zufall 0 bis initiative_streuung; ausser Atem minus initiative_atemlos | `regeln/mars.gd:560` |
| `initiative_atemlos` | 25 | – | `regeln/mars.gd:562` |
| `ueberreden_basis` | 35 | 1037 (807 A, Pim heimschicken; vorlaeufig A, Jerry, Vorentscheid Sokrates): Ueberreden hat keinen Grundwert, also Chance = ueberreden_basis + ueberreden_je_punkt x Fertigkeitswert Ueberreden - Gegenwert der Figur (ueberreden_gegen, sonst 0), begrenzt auf min bis max; ohne Fertigkeit 35 %, Startwert 10 = 45 %, Kapitel-1-Decke 24 = 59 %; Uebung je Versuch wie ueben uebung_je_benutzung, gelungen oder nicht | – |
| `ueberreden_je_punkt` | 1 | – | – |

- **formel:** Chance = basis + je_punkt x (eigener Grundwert - Grundwert dagegen) + je_stufe x (eigene Stufe - Stufe dagegen), begrenzt auf min bis max; Gegner ohne Grundwerte zaehlen mit gegner_grundwert
- **flucht:** Gewandtheit des Helden gegen die des schnellsten stehenden Gegners (Stufe dazu); betrunken mit Ungunst (merkmale umreissen)

| Eintrag | Pim |
|---|---|
| ueberreden_gegen | 0 |

## gegenwirkung

- **Herkunft der Zahlen:** 870.5 (870a 8 A, LISTE-BESTIARIUM.md): das falsche Mittel staerkt oder kostet, nie toedlich; Zahlen A (Jerry), Werte-Vorlage an den Chef vor B1; Simulation kennt sie noch nicht
- **Gelesen von:** `regeln/mars.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `rasend_schaden` | 1,5 | – | `regeln/mars.gd:1770` |
| `blut_schaden` | 1,5 | – | `regeln/mars.gd:1772` |
| `teilen_leben` | 0,5 | – | `regeln/mars.gd:2273` |

## erfahrung

- **Regel** (`DESIGN-BRS.md` „4. Heldenstufe und Erfahrung“): Deckel: Höchstens 40 Prozent der Erfahrung für die nächste Stufe dürfen aus Fertigkeitsaufstiegen stammen.
- **Regel** (`DESIGN-BRS.md`, Tabelle): Heldenstufe – Leben, Größenordnung im Kampf, Zugang zu Gebieten – 1, 2, 3 …; jedes Kapitel setzt eine Grenze (weich, bis zwei darüber) – Erfahrung aus Kampf, Quests, Story und Fertigkeitsaufstiegen. Bis zur nächsten Stufe 100 × jetzige Stufe; Sieg 10 × Gegnerstufe² (Boss × 3; Held höher um d: × (1 − d/9), ab 9 null; Gegner höher um d: × (1 + d/10), höchstens × 2); Topf je Gebiet 10 × Stufe² je Art, leer 10 %; je 5 Fertigkeitspunkte 20 × Heldenstufe, höchstens 40 % einer Stufe; Bewährungsprobe 25 × Heldenstufe; über der Kapitelgrenze ein Viertel (Regelwerte erfahrung, Seite 969)
- **Herkunft der Zahlen:** N 4 Tabelle 'Zahlen fuer die Simulation', Modell D; Fertigkeits- und Proben-Erfahrung A
- **Gelesen von:** `regeln/brs.gd`, `regeln/brs_fertigkeit.gd`, `tools/sim444/sim.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `je_gegner_faktor` | 10 | – | `regeln/brs.gd:128`, `regeln/brs.gd:162`, Sim. |
| `boss_faktor` | 3 | – | `regeln/brs.gd:130`, Sim. |
| `bis_naechste_stufe_je_stufe` | 100 | – | `regeln/brs.gd:152`, Sim. |
| `hoeher_null_ab` | 9 | – | `regeln/brs.gd:134`, Sim. |
| `tiefer_teiler` | 10 | – | `regeln/brs.gd:136`, Sim. |
| `tiefer_hoechstens` | 2 | – | `regeln/brs.gd:136`, Sim. |
| `fertigkeit_schritt` | 5 | A: je 5 Punkte Fertigkeitsaufstieg 20 x Heldenstufe Erfahrung (bei Stufe 1 also 20 von 100) | `regeln/brs_fertigkeit.gd:92`, Sim. |
| `fertigkeit_schritt_erfahrung_je_heldenstufe` | 20 | – | `regeln/brs_fertigkeit.gd:93`, Sim. |
| `fertigkeit_deckel` | 0,4 | – | `regeln/brs.gd:187`, `regeln/brs.gd:207`, Sim. |
| `probe_erfahrung_je_heldenstufe` | 25 | A: Bewaehrungsprobe bestanden = 25 x Heldenstufe Erfahrung (Tat) | `regeln/brs_fertigkeit.gd:115`, Sim. |
| `weich_stufen` | 2 | N 4, E 18: ab der Kapitelgrenze bis zu 2 Stufen darueber, dort nur ein Viertel der Erfahrung (472; die Simulation rechnet noch mit harter Grenze) | `regeln/brs.gd:148` |
| `weich_faktor` | 0,25 | – | `regeln/brs.gd:185` |
| `topf_rest_anteil` | 0,1 | E 19, E 21: Topf je Gebiet = 10 x Stufe^2 jeder Art des Gebiets einmal (ohne Bosse, A); leer: nur noch dieser Anteil (A, 'kleiner Anteil', 'kaum'); 472 | `regeln/brs.gd:179` |

## ueben

- **Regel** (`DESIGN-BRS.md` „Wie Fertigkeiten wachsen“): Jede Benutzung gegen ein passendes Ziel bringt Übung.
- **Herkunft der Zahlen:** N 3 'Wie Fertigkeiten wachsen'; alle Zahlen A
- **Gelesen von:** `regeln/brs_fertigkeit.gd`, `tools/sim444/sim.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `uebung_je_benutzung` | 1 | – | `regeln/brs_fertigkeit.gd:76`, Sim. |
| `bedarf_basis` | 10 | Uebung fuer +1 Punkt = (Wert + 10) / 5: bei 10 sind es 4, bei 24 rund 7, bei 49 rund 12 | `regeln/brs_fertigkeit.gd:63`, Sim. |
| `bedarf_teiler` | 5 | – | `regeln/brs_fertigkeit.gd:63`, Sim. |
| `leicht_teiler` | 5 | Uebung x (1 + (Gegnerstufe - Heldenstufe) / 5), begrenzt 0,2 bis 1,5 ('zu leichte Ziele bringen kaum etwas') | `regeln/brs_fertigkeit.gd:67`, Sim. |
| `leicht_min` | 0,2 | – | `regeln/brs_fertigkeit.gd:67`, Sim. |
| `leicht_max` | 1,5 | – | `regeln/brs_fertigkeit.gd:67`, Sim. |
| `puffer_uebung` | 15 | an der Rangdecke werden bis zu 15 Uebung gemerkt | `regeln/brs_fertigkeit.gd:99`, Sim. |
| `probe_siege` | 3 | Bewaehrungsprobe: 3 Siege gegen Gegner mindestens der eigenen Stufe, in denen die Fertigkeit benutzt wurde | `regeln/brs_fertigkeit.gd:111`, `regeln/brs_fertigkeit.gd:122`, Sim. |

## waffen

- **Regel** (`DESIGN-BRS.md` „4. Heldenstufe und Erfahrung“): Grundschaden der Waffe – Faustkampf 2, Dolch und Wurfwaffe 4, Einhänder, Stumpfe Waffe und Bogen 6, Stangenwaffe und Armbrust 8, Zweihänder 10
- **Herkunft der Zahlen:** N 4: Grundschaden und Grundwert; Klingen fuer Schleim-Widerstand A
- **Gelesen von:** `regeln/brs_held.gd`, `regeln/brs_kampf.gd`, `regeln/mars.gd`, `skripte/beute.gd`, `skripte/menue.gd`, `tools/sim444/sim.py`, `tools/sim444/handlungen.py`

| Eintrag | schaden | grundwert | art | typ |
|---|---|---|---|---|
| Faustkampf | 2 | kraft | nah | wucht |
| Dolche | 4 | gewandtheit | nah | stich |
| Wurfwaffen | 4 | gewandtheit | fern | stich |
| Einhänder | 6 | kraft | nah | schnitt |
| Stumpfe Waffen | 6 | kraft | nah | wucht |
| Bogen | 6 | gewandtheit | fern | stich |
| Stangenwaffen | 8 | kraft | nah | stich |
| Armbrust | 8 | – | fern | stich |
| Zweihänder | 10 | kraft | nah | schnitt |

## zauber

- **Regel** (`DESIGN-BRS.md` „4. Heldenstufe und Erfahrung“): Zauber – Schaden wie Waffe mit Grundschaden des Zaubers, Fertigkeit = Schule
- **Herkunft der Zahlen:** N 4: Zauber wie Waffe, Grundwert Wille, Fertigkeit = Schule; Grundschaden, Kosten, Heilung A
- **Gelesen von:** `regeln/brs_held.gd`, `regeln/brs_kampf.gd`, `regeln/mars.gd`, `tools/sim444/sim.py`, `tools/sim444/handlungen.py`

- **neu:** 870.3 (870a 3 A, Namen STORY-BRS-KOENNEN.md [870.14.zauber.*]): Zahlen A, gemessen mit 444 Teil 7; 'ab' = Fertigkeitswert der Schule; 'ziele': eins, reihe (vordere oder gewaehlte Reihe), drei (drei Strahlen, je ein Ziel)

| Eintrag | schule | schaden | kosten | art | typ | ab | ziele |
|---|---|---|---|---|---|---|---|
| Funkenpfeil | Evokation | 6 | 4 | zauber | feuer |  |  |
| Glutstrahlen | Evokation | 4 | 6 | zauber | feuer | 25 | drei |
| Flammenfächer | Evokation | 5 | 6 | zauber | feuer | 25 | reihe |
| Glutkugel | Evokation | 8 | 10 | zauber | feuer | 40 | reihe |
| Gleißstrahl | Heilmagie | 5 | 4 | zauber | licht | 10 | eins |

### zauber.Wundsegen

Gelesen in: `regeln/mars.gd:177`, `regeln/mars.gd:182`, +1, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schule` | Heilmagie | – | `regeln/brs_held.gd:444`, `regeln/mars.gd:588`, +2, Sim. |
| `heilung` | 6 | Heilung = (6 + Wille) x (1 + Heilmagie / 100), wenn Leben unter der Haelfte | `regeln/mars.gd:1483`, Sim. |
| `kosten` | 5 | – | `regeln/mars.gd:515`, Sim. |
| `heilen_unter` | 0,5 | – | Sim. |

### zauber.Bannschild

Gelesen in: `regeln/mars.gd:177`, `regeln/mars.gd:182`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schule` | Schutzmagie | – | `regeln/brs_held.gd:444`, `regeln/mars.gd:588`, +2, Sim. |
| `ruestung` | 2 | – | `regeln/brs_held.gd:452`, `regeln/brs_held.gd:457`, +10, Sim. |
| `kosten` | 4 | – | `regeln/mars.gd:515`, Sim. |

- **bannschild:** A: einmal je Kampf in Runde 1, Ruestung +2, Abzug mit Schutzmagie als Fertigkeit

### zauber.Arkanpfeil

Gelesen in: `regeln/mars.gd:176`, `regeln/mars.gd:180`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schule` | Evokation | – | `regeln/brs_held.gd:444`, `regeln/mars.gd:588`, +2, Sim. |
| `schaden` | 5 | – | `regeln/brs_held.gd:251`, `regeln/brs_held.gd:486`, +12, Sim. |
| `kosten` | 3 | – | `regeln/mars.gd:515`, Sim. |
| `art` | zauber | – | `regeln/brs_held.gd:271`, `regeln/brs_held.gd:283`, +12, Sim. |
| `typ` | – | – | `regeln/mars.gd:945`, `regeln/mars.gd:1469`, +6, Sim. |
| `ab` | 10 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `ziele` | eins | – | – |

- **arkan:** ohne Schadensart: keine Schwaeche, keine Staerke

### zauber.Arkanhaut

Gelesen in: `regeln/mars.gd:177`, `regeln/mars.gd:181`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schule` | Schutzmagie | – | `regeln/brs_held.gd:444`, `regeln/mars.gd:588`, +2, Sim. |
| `ruestung` | 2 | – | `regeln/brs_held.gd:452`, `regeln/brs_held.gd:457`, +10, Sim. |
| `kosten` | 5 | – | `regeln/mars.gd:515`, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |

- **arkanhaut:** A: bis Kampfende Ruestung +2 (mit Schutzmagie wie Bannschild), zusammen mit Bannschild

### zauber.Beistand

Gelesen in: `regeln/mars.gd:177`, `regeln/mars.gd:182`, +1, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schule` | Heilmagie | – | `regeln/brs_held.gd:444`, `regeln/mars.gd:588`, +2, Sim. |
| `treffer` | 25 | – | `regeln/brs_kampf.gd:162`, `regeln/mars.gd:1349`, +5, Sim. |
| `runden` | 4 | – | `regeln/mars.gd:1330`, Sim. |
| `kosten` | 4 | – | `regeln/mars.gd:515`, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |

- **beistand:** A: eigene Trefferchance +25 Prozentpunkte fuer 4 Runden

## handlungen

- **Regel** (`DESIGN-BRS.md` „7. Kampf“): (3) Kampfhandlungen hängen an Fertigkeiten: für alle Kraft schöpfen (einmal je Kampf, Leben zurück)
- **Herkunft der Zahlen:** 870.3 (870a 3 A, DESIGN-BRS.md 7): Kampfhandlungen haengen an Fertigkeiten, frei ab Rang Geselle ('ab' 25 = erste Rangdecke + 1, held rangdecken_kapitel); Kraft schoepfen fuer alle; Namen STORY-BRS-KOENNEN.md [870.14.hand.*]; alle Zahlen A, gemessen mit 444 Teil 7, dann Chef
- **Gelesen von:** `regeln/brs_held.gd`, `regeln/mars.gd`, `tools/sim444/handlungen.py`

### handlungen.Wuchtschlag

Gelesen in: `regeln/mars.gd:162`, `regeln/mars.gd:168`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Zweihänder | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `schaden_faktor` | 1,5 | – | `regeln/mars.gd:1347`, `regeln/mars.gd:1349`, +2, Sim. |
| `treffer` | -15 | – | `regeln/mars.gd:1349`, `regeln/mars.gd:1352`, +4, Sim. |

### handlungen.Schädelstoß

Gelesen in: `regeln/mars.gd:163`, `regeln/mars.gd:168`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Stumpfe Waffen | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `treffer` | -10 | – | `regeln/mars.gd:1349`, `regeln/mars.gd:1352`, +4, Sim. |
| `betaeubt_chance` | 0,3 | – | `regeln/mars.gd:1356`, Sim. |
| `betaeubt_zuege` | 1 | – | `regeln/mars.gd:1357`, Sim. |

### handlungen.Durchschlag

Gelesen in: `regeln/mars.gd:164`, `regeln/mars.gd:170`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Armbrust | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `ruestung_anteil` | 0,5 | – | `regeln/mars.gd:1362`, Sim. |

### handlungen.Zwei auf einmal

Gelesen in: `regeln/mars.gd:164`, `regeln/mars.gd:170`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Wurfwaffen | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `wuerfe` | 2 | – | `regeln/mars.gd:1365`, Sim. |
| `schaden_faktor` | 0,6 | – | `regeln/mars.gd:1347`, `regeln/mars.gd:1349`, +2, Sim. |

### handlungen.Kraft schöpfen

Gelesen in: `regeln/mars.gd:162`, `regeln/mars.gd:167`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | – | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `alle` | ja | – | `regeln/brs_held.gd:439`, `regeln/mars.gd:507`, Sim. |
| `ab` | 0 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `je_kampf` | 1 | – | `regeln/mars.gd:510`, Sim. |
| `heilung_anteil` | 0,25 | – | `regeln/mars.gd:1339`, Sim. |
| `unter` | 0,5 | – | `regeln/mars.gd:904`, Sim. |

- **kraft:** einmal je Kampf, ganzer Zug: Leben + 25 % des Hoechstwerts, wenn unter der Haelfte

### handlungen.Finte

Gelesen in: `regeln/mars.gd:162`, `regeln/mars.gd:167`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Einhänder | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `naechster_treffer` | 30 | – | `regeln/mars.gd:1343`, Sim. |

- **finte:** ganzer Zug ohne Schaden, der naechste Schlag +30 Prozentpunkte

### handlungen.Stich aus dem Hinterhalt

Gelesen in: `regeln/mars.gd:162`, `regeln/mars.gd:167`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Dolche | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `schaden_faktor` | 1,5 | – | `regeln/mars.gd:1347`, `regeln/mars.gd:1349`, +2, Sim. |
| `nur_erster` | ja | – | – |

- **hinterhalt:** der erste eigene Schlag im Kampf (oder gegen einen Ueberraschten) x 1,5

### handlungen.Auf Abstand

Gelesen in: `regeln/mars.gd:163`, `regeln/mars.gd:168`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Stangenwaffen | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `treffer` | -10 | – | `regeln/mars.gd:1349`, `regeln/mars.gd:1352`, +4, Sim. |
| `gegenstoss_faktor` | 0,5 | – | `regeln/mars.gd:1743`, Sim. |

- **abstand:** Schlag mit -10 Prozentpunkten, dazu Haltung bis zum naechsten Zug: wer den Helden im Nahkampf angreift, laeuft zuerst in die Spitze (Schlag x 0,5)

### handlungen.Griff

Gelesen in: `regeln/mars.gd:163`, `regeln/mars.gd:169`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Faustkampf | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |

- **griff:** Ziel kann bis zum naechsten Zug des Helden nicht den Platz wechseln oder fliehen; Schlag x 0,5

### handlungen.Schildwall

Gelesen in: `regeln/mars.gd:163`, `regeln/mars.gd:169`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Schild | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |

- **schildwall:** Vorform von Decken (Waechter): eine Runde lang faengt der Schild einen Schlag gegen den Gefaehrten daneben ab (Abwehr mit Schild)

### handlungen.Ruhige Hand

Gelesen in: `regeln/mars.gd:164`, `regeln/mars.gd:169`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | Bogen | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 25 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `naechster_treffer` | 30 | – | `regeln/mars.gd:1343`, Sim. |

- **ruhig:** Vorform von Zielschuss (Scharfschuetze): ganzer Zug, der naechste Schuss +30 Prozentpunkte

### handlungen.Wehrhaltung

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeit` | – | – | `regeln/brs_held.gd:276`, `regeln/brs_held.gd:300`, +4, Sim. |
| `ab` | 0 | – | `regeln/brs_held.gd:439`, `regeln/brs_held.gd:444`, +2 |
| `abwehr` | 15 | Haltung bis zum naechsten Zug: Abwehr +15, eigener Treffer -15 (alte 'Kampfstil Verteidigung'; Homer: nur wenn behalten); 444 Teil 7: ohne Wirkung, darum nicht frei (kein 'alle'), Chef entscheidet | `regeln/brs_held.gd:454`, `regeln/mars.gd:1513`, +1, Sim. |
| `treffer` | -15 | – | `regeln/mars.gd:1349`, `regeln/mars.gd:1352`, +4, Sim. |

## ruestungen

- **Herkunft der Zahlen:** A: Ruestungswerte nicht im Nachschlagewerk; Beispiel Modell D rechnet mit 2 und 3
- **Gelesen von:** `regeln/brs_held.gd`, `regeln/brs_kampf.gd`, `skripte/kampfuebung.gd`, `tools/sim444/sim.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schild_wert` | 2 | A: Abzug = Ruestung x (1 + Ruestungsfertigkeit/100) + Schildwert x (1 + Schild/100) | `regeln/brs_held.gd:283`, `regeln/brs_held.gd:302`, +2, Sim. |

| Eintrag | wert | fertigkeit |
|---|---|---|
| keine | 0 | – |
| Leichte Rüstung | 1 | Leichte Rüstung |
| Mittlere Rüstung | 3 | Mittlere Rüstung |
| Schwere Rüstung | 5 | Schwere Rüstung |

## herkuenfte

- **Regel** (`DESIGN-BRS.md` „2. Der Held“): Klosterschüler – Heilmagie, Heilkunde, Kräutersammeln – Heiler, Paladin
- **Herkunft der Zahlen:** Startfertigkeiten N 2; Punkteverteilung, Waffe, Ruestung A (die Herkunft verteilt die Punkte vor, N 2)
- **Gelesen von:** `regeln/brs_held.gd`, `regeln/brs_kampf.gd`, `tools/sim444/sim.py`, `tools/sim444/handlungen.py`

| Eintrag | fertigkeiten | plus | plus_variante | waffe | ruestung | schild | zauber |
|---|---|---|---|---|---|---|---|
| Wachsoldat | Schild, Mittlere Rüstung, Einhänder | kraft 3; zaehigkeit 3 | gewandtheit 1; wille 1; wahrnehmung 1 | Einhänder | Mittlere Rüstung | ja | – |
| Jägerkind | Bogen, Wurfwaffen, Spähen | gewandtheit 3; wahrnehmung 3 | zaehigkeit 2; kraft 1 | Bogen | Leichte Rüstung | nein | – |
| Zauberlehrling | Evokation, Schutzmagie | wille 5; verstand 1 | zaehigkeit 2; gewandtheit 1 | Stumpfe Waffen | keine | nein | Bannschild, Funkenpfeil |
| Klosterschüler | Heilmagie, Heilkunde, Kräutersammeln | wille 3; zaehigkeit 1; verstand 2 | kraft 2; zaehigkeit 1 | Stumpfe Waffen | Leichte Rüstung | nein | Wundsegen |
| Kräutersammler | Kräutersammeln, Alchemie, Spähen | verstand 3; wahrnehmung 3 | gewandtheit 2; zaehigkeit 1 | Dolche | Leichte Rüstung | nein | – |
| Schmiedelehrling | Schmieden, Bergbau | kraft 3; zaehigkeit 1; verstand 2 | zaehigkeit 2; gewandtheit 1 | Stumpfe Waffen | Leichte Rüstung | nein | – |
| Herumtreiber | Schleichen, Spähen, Dolche | gewandtheit 4; wahrnehmung 2 | zaehigkeit 2; kraft 1 | Dolche | Leichte Rüstung | nein | – |

### herkuenfte.Wanderer

Gelesen in: `regeln/brs_held.gd:19`, `regeln/brs_kampf.gd:54`, +2, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `fertigkeiten` | Einhänder, Ausweichen | – | `regeln/brs_held.gd:186`, `regeln/brs_held.gd:196`, +2, Sim. |
| `waffe` | Einhänder | – | `regeln/brs_held.gd:452`, `regeln/brs_held.gd:457`, +5, Sim. |
| `ruestung` | Leichte Rüstung | – | `regeln/brs_held.gd:452`, `regeln/brs_held.gd:457`, +6, Sim. |
| `schild` | nein | – | `regeln/brs_held.gd:452`, `regeln/brs_held.gd:458`, +6, Sim. |
| `zauber` | – | – | `regeln/brs_held.gd:441`, `regeln/brs_held.gd:454`, +4, Sim. |

- **wanderer:** A: der Wanderer waehlt selbst; gerechnet ist ein Kampfbau (Schwert, Ausweichen)

#### herkuenfte.Wanderer.plus

Gelesen in: `regeln/brs_held.gd:123`, `regeln/brs_held.gd:144`, +2, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `kraft` | 4 | – | `regeln/brs_held.gd:168`, `regeln/brs_held.gd:314`, Sim. |
| `zaehigkeit` | 2 | – | `regeln/brs_held.gd:168`, `regeln/brs_held.gd:231`, +2, Sim. |

#### herkuenfte.Wanderer.plus_variante

Gelesen in: `regeln/brs_held.gd:123`, `regeln/brs_kampf.gd:68`, +1, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `gewandtheit` | 2 | – | `regeln/brs_held.gd:168`, `regeln/brs_held.gd:243`, +2, Sim. |
| `wahrnehmung` | 1 | – | `regeln/brs_held.gd:168`, `regeln/brs_held.gd:328`, Sim. |

## monster

- **Herkunft der Zahlen:** B 'Werte 2.0' (427, Chef 02.11., 18:54; Krogg, Grimmzahn vorlaeufig bis 427.1); art nah/fern/zauber und Schwaechen A nach B-Spalte 'Angriff' und Hinweis Schwaechen +-50 %
- **Gelesen von:** `regeln/brs.gd`, `tools/sim444/sim.py`, `tools/sim444/handlungen.py`

- **schwaeche:** 870.5 (870a 8 A, LISTE-BESTIARIUM.md): Schwaeche x1,5, Staerke x0,5, immun 0 je Schadensart (schnitt, stich, wucht, feuer, gift, saeure, licht); Waffen tragen ihre Art (Dolche, Speere, Boegen stechen, Schwerter schneiden, Stumpfes und Faust wucht), A

| Eintrag | stufe | leben | ruestung | schaden | angriff | abwehr | wachsamkeit | art | gebiet | schwaeche | boss | ueberfall | rudel | umreissen |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Riesenratte | 1 | 20 | 1 | 3 | 10 | 5 | 10 | nah | Wald, Höhle | feuer 1,5 |  |  |  |  |
| Kobold | 1 | 24 | 1 | 3 | 10 | 5 | 0 | nah | Wald, Tiefer Wald |  |  |  |  |  |
| Blutflügler | 1 | 18 | 2 | 3 | 15 | 9 | 0 | nah | Wald, Tiefer Wald | feuer 1,5 |  |  |  |  |
| Wolf | 2 | 25 | 1 | 6 | 15 | 12 | 30 | nah | Wald, Tiefer Wald | feuer 1,5 |  |  |  |  |
| Wildschwein | 2 | 29 | 0 | 3 | 10 | 8 | 10 | nah | Wald, Tiefer Wald | stich 1,5; schnitt 0,5 |  |  |  |  |
| Riesen-Hundertfüßer | 2 | 22 | 1 | 3 | 15 | 12 | 0 | nah | Wald, Tiefer Wald | wucht 1,5; stich 0,5 |  |  |  |  |
| Goblin | 2 | 18 | 2 | 5 | 15 | 16 | 10 | nah | Wald, Tiefer Wald, Höhle |  |  |  |  |  |
| Goblin-Späher | 2 | 22 | 1 | 5 | 15 | 12 | 20 | fern | Wald, Tiefer Wald, Höhle |  |  |  |  |  |
| Skelett | 2 | 36 | 1 | 5 | 15 | 12 | 10 | nah | Wald, Tiefer Wald, Höhle | wucht 1,5; stich 0,5; gift 0 |  |  |  |  |
| Zombie | 2 | 44 | 0 | 3 | 10 | 2 | 0 | nah | Wald, Tiefer Wald, Höhle | feuer 1,5; gift 0 |  |  |  |  |
| Riesenfledermaus | 3 | 46 | 1 | 5 | 20 | 17 | 40 | nah | Wald, Tiefer Wald, Höhle | stich 1,5 |  |  |  |  |
| Goblin-Schamane | 3 | 29 | 1 | 4 | 15 | 15 | 50 | zauber | Tiefer Wald, Höhle | stich 1,5; feuer 0,5 |  |  |  |  |
| Riesenspinne | 4 | 43 | 2 | 7 | 25 | 24 | 40 | nah | Tiefer Wald, Höhle | feuer 1,5; gift 0,5 |  |  |  |  |
| Ghul | 4 | 37 | 1 | 6 | 25 | 20 | 40 | nah | Tiefer Wald, Höhle | licht 1,5; gift 0 |  |  |  |  |
| Ockerschleim | 5 | 44 | 0 | 5 | 30 | 17 | 10 | nah | Höhle | feuer 1,5; saeure 0 |  |  |  |  |
| Krogg | 4 | 55 | 2 | 7 | 20 | 28 | 60 | nah | Höhle |  | ja | ja |  |  |
| Grimmzahn | 5 | 55 | 2 | 7 | 22 | 29 | 80 | nah | Tiefer Wald |  | ja |  | Leibwache | ja |

### monster.Grak

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `stufe` | 6 | – | `regeln/brs.gd:61`, `regeln/brs.gd:118`, +10, Sim. |
| `leben` | 60 | 870c 1 A (Vorentscheid Sokrates 10.11.): 75 -> 60, Wachsoldat Stufe 6 ohne Ring etwa 85 % im echten Kampf (ruft hoechstens einen Goblin) | `regeln/brs.gd:56`, Sim. |
| `ruestung` | 2 | – | Sim. |
| `schaden` | 7 | – | `regeln/brs.gd:55`, `regeln/brs.gd:118`, Sim. |
| `angriff` | 25 | – | `regeln/brs.gd:54`, `regeln/brs.gd:118`, Sim. |
| `abwehr` | 38 | – | Sim. |
| `wachsamkeit` | 90 | – | Sim. |
| `art` | nah | – | `regeln/brs.gd:38`, Sim. |
| `gebiet` | Höhle | – | `regeln/brs.gd:161` |
| `boss` | ja | – | `regeln/brs.gd:51`, `regeln/brs.gd:62`, +2, Sim. |

## merkmale

- **Herkunft der Zahlen:** 427.1 (Jerry 02.11.): aus dem alten Spiel umgerechnet (core Packs.kt, Battle.kt, Monsters.kt), A; 1 Punkt W20 = 5 % = 10 Punkte Angriff (trefferchance_je_punkt 0,5)
- **Gelesen von:** `regeln/brs.gd`, `regeln/brs_kampf.gd`, `regeln/lohn.gd`, `regeln/mars.gd`, `tools/sim444/sim.py`, `tools/sim444/handlungen.py`

### merkmale.rudel

Gelesen in: `regeln/brs.gd:45`, `regeln/brs.gd:52`, +3, Sim.

- **info:** A: Begleiter stehen hinter dem Anfuehrer, jeder greift je Runde nach ihm mit 'chance' an, nicht angreifbar (angreifbar: false; Jungwolf im Spiel angreifbar), fliehen, wenn er faellt (wie im alten Spiel). Angriff = Anfuehrer + angriff_verschiebung, Schaden = Anfuehrer x schaden_anteil

#### merkmale.rudel.Leibwache

Herkunft: Packs.kt guard: 2 Woelfe, 55 %, -1 auf W20, 1W4 gegen 2W6+1 des Leitwolfs

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `anzahl` | 2 | – | Sim. |
| `chance` | 0,55 | – | `regeln/brs.gd:57`, `regeln/brs_kampf.gd:162`, +1, Sim. |
| `angriff_verschiebung` | -10 | – | `regeln/brs.gd:54`, Sim. |
| `schaden_anteil` | 0,31 | – | `regeln/brs.gd:55`, `regeln/mars.gd:1563`, Sim. |
| `koerper` | Wolf | – | `regeln/brs.gd:49`, `regeln/mars.gd:722` |
| `leben_anteil` | 1 | – | `regeln/brs.gd:56` |
| `angreifbar` | nein | – | `regeln/brs.gd:58`, `regeln/mars.gd:319` |
| `erfahrung_anteil` | 0,25 | vorlaeufig (870.5): wie alt Packs.kt xpShare 0,25 je Wolf der Leibwache; Werte-Vorlage an den Chef vor B1 | `regeln/lohn.gd:34` |

#### merkmale.rudel.Jungwolf

Herkunft: A (870.3): Packs.kt cubs, 399.2a: 1-2 Jungwoelfe hinter dem Wolf, 50 %, -1 auf W20, 1W3 gegen 2W4+2 des Wolfs, halbe Leben; im Spiel angreifbar; seit 870c 3 A rechnet die Simulation sie als Monster 'Rudel' (Wolf mit 1-2 Jungwoelfen, nicht angreifbar, fliehen mit ihm); Werte bleiben: Wanderer Stufe 1 gegen das Rudel im echten Kampf 69 % (Ziel etwa 70)

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `anzahl` | 1, 2 | – | Sim. |
| `chance` | 0,5 | – | `regeln/brs.gd:57`, `regeln/brs_kampf.gd:162`, +1, Sim. |
| `angriff_verschiebung` | -10 | – | `regeln/brs.gd:54`, Sim. |
| `schaden_anteil` | 0,29 | – | `regeln/brs.gd:55`, `regeln/mars.gd:1563`, Sim. |
| `koerper` | Wolf | – | `regeln/brs.gd:49`, `regeln/mars.gd:722` |
| `leben_anteil` | 0,5 | – | `regeln/brs.gd:56` |
| `angreifbar` | ja | – | `regeln/brs.gd:58`, `regeln/mars.gd:319` |
| `erfahrung_anteil` | 0,3 | vorlaeufig (870.5): wie alt Packs.kt xpShare 0,3 je Jungwolf; Werte-Vorlage an den Chef vor B1 | `regeln/lohn.gd:34` |

### merkmale.umreissen

Herkunft: Monsters.kt KNOCKDOWN: bei Treffer Rettungswurf Staerke 11 (etwa die Haelfte), sonst liegt der Held, sein naechster Angriff mit Nachteil

Gelesen in: `regeln/brs.gd:53`, `regeln/brs_kampf.gd:38`, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `chance_bei_treffer` | 0,5 | – | Sim. |
| `naechster_angriff_treffer` | -25 | – | `regeln/brs_kampf.gd:38`, Sim. |

### merkmale.ueberfall

Herkunft: Monsters.kt SURPRISE_ATTACK, Battle.kt: erster Treffer +2W6 (zu 2W8+2 also x1,6) und betaeubt (Konstitution 12, etwa die Haelfte) fuer einen Zug; Sokrates 02.11., 19:0x: Held beginnt im Nachteil (Gegner zuerst); Morwens Rauch (D4.1): der erste Hieb geht fehl

Gelesen in: `regeln/mars.gd:445`, `regeln/mars.gd:2301`, +1, Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `gegner_zuerst` | ja | – | `regeln/mars.gd:444`, Sim. |
| `erster_treffer_faktor` | 1,6 | – | `regeln/mars.gd:2314`, Sim. |
| `betaeubt_chance` | 0,5 | – | `regeln/mars.gd:1356`, Sim. |
| `betaeubt_zuege` | 1 | – | `regeln/mars.gd:1357`, Sim. |

## wirtschaft

- **Regel** (`DESIGN-BRS.md` „8. Die Welt“): Tiere beruhigen: Ein feindliches Tier lässt sich vor dem Kampf beruhigen
- **Regel** (`DESIGN-BRS.md` „10. Herstellen und Sammeln“): Fleisch, Fell, Knochen, Sehnen, Zähne – erlegte Tiere – Jagd (Zerlegen nach dem Sieg; ohne Jagd weniger und schlechtere Teile, nie nichts)
- **Regel** (`DESIGN-BRS.md` „11. Ausrüstung: Seltenheit, Abnutzung und Reparatur“): Ausrüstung hat einen Zustand: Makellos (neu gekauft, frisch hergestellt oder voll repariert), Benutzt, Beschädigt, Defekt (Vorschlag Chef 31.10., 21:5x).
- **Herkunft der Zahlen:** Stufe 3 (447.3): N 8 Tiere beruhigen, N 10 Zerlegen, N 11 Abnutzung und Reparatur; Gold, Beute, Preise, Startausruestung aus der alten Fassung (Monsters.kt, Items.kt, Rules.kt; Katalog 458 'alt'); alles Uebrige A
- **Gelesen von:** `regeln/tabellen.gd`, `skripte/spiel.gd`, `tools/sim444/sim.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `punkte_variante` | ja | gerechnet mit 21 Punkten (Entscheidung 77), also den Herkuenften mit plus_variante | Sim. |
| `startgold` | 20 | alt: 15 bis 25 Gold, 1 bis 3 Heiltraenke je Klasse; hier Mittel | `skripte/spiel.gd:1321`, Sim. |
| `start_heiltraenke` | 2 | – | `skripte/spiel.gd:1322`, Sim. |
| `verkauf_anteil` | 0,5 | alt: Haendler zahlt den halben Ladenpreis (Game.kt sellPrice) | Sim. |
| `dorf_alle_kaempfe` | 8 | A: der Held geht alle 8 Kaempfe ins Dorf, frueher, sobald ein Stueck 'Beschaedigt' ist (Warnung, N 11); dort verkaufen, reparieren, Traenke kaufen | Sim. |

### wirtschaft.preise

Herkunft: Ladenpreise alt (Katalog 458 'alt'); Teile ohne alten Preis A; Verband 1037 A

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `Heiltrank` | 25 | – | Sim. |
| `Großer Heiltrank` | 75 | – | Sim. |
| `Verband` | 8 | – | – |
| `Alchemistenfeuer` | 30 | – | Sim. |
| `Weihwasser` | 25 | – | – |
| `Fleisch` | 6 | – | – |
| `Wolfsfell` | 24 | – | – |
| `Hauer` | 20 | – | – |
| `Spinnendrüse` | 30 | – | – |
| `Fledermausflügel` | 16 | – | – |
| `Fell klein` | 8 | – | – |
| `Zähne` | 10 | – | – |
| `Schwarte` | 12 | – | – |
| `Giftdrüse` | 20 | – | – |
| `Panzerplatten` | 10 | – | – |
| `Spinnseide` | 20 | – | – |
| `Knochen` | 4 | – | – |
| `Säure` | 20 | – | – |

### wirtschaft.beute

Herkunft: alt Monsters.kt: Gold als Wuerfel (min, max), Beute mit Chance; Tierteile (Fleisch, Fell, Hauer, Druese, Fluegel) nur noch ueber Zerlegen

Gelesen in: `regeln/tabellen.gd:32`, `regeln/tabellen.gd:42`, Sim.

| Eintrag | gold | dinge |
|---|---|---|
| Riesenratte | 1, 4 | (Heiltrank, 0,08) |
| Kobold | 2, 8 | (Heiltrank, 0,12), (Alchemistenfeuer, 0,04) |
| Blutflügler | 1, 3 | (Heiltrank, 0,06) |
| Wolf | 1, 6 | (Heiltrank, 0,12) |
| Wildschwein | 1, 3 | (Heiltrank, 0,08) |
| Riesen-Hundertfüßer | 1, 3 | (Heiltrank, 0,1) |
| Goblin | 2, 12 | (Heiltrank, 0,15), (Alchemistenfeuer, 0,06) |
| Goblin-Späher | 2, 16 | (Heiltrank, 0,15), (Alchemistenfeuer, 0,05) |
| Skelett | 1, 8 | (Heiltrank, 0,08), (Weihwasser, 0,04) |
| Zombie | 1, 6 | (Heiltrank, 0,1), (Weihwasser, 0,06) |
| Riesenfledermaus | 1, 4 | (Heiltrank, 0,1) |
| Goblin-Schamane | 3, 18 | (Heiltrank, 0,25), (Großer Heiltrank, 0,06) |
| Riesenspinne | 2, 20 | (Großer Heiltrank, 0,15) |
| Ghul | 2, 16 | (Großer Heiltrank, 0,15), (Weihwasser, 0,06) |
| Ockerschleim | 3, 30 | (Großer Heiltrank, 0,2) |

### wirtschaft.zerlegen

Herkunft: N 10, Teile nach Bestiarium 'Zerlegen (Vorschlag)'; Formel A: das erste Teil immer ('nie nichts'), jedes weitere mit Chance = Ausbeute; Erloes x Ausbeute (Guete); Ausbeute = min + (1 - min) x Jagd / jagd_voll

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ausbeute_min` | 0,4 | – | Sim. |
| `jagd_voll` | 49 | – | Sim. |

| Eintrag | Riesenratte | Wolf | Wildschwein | Riesen-Hundertfüßer | Riesenspinne | Riesenfledermaus | Skelett | Ockerschleim |
|---|---|---|---|---|---|---|---|---|
| teile | Fleisch, Fell klein | Fleisch, Wolfsfell, Zähne | Fleisch, Schwarte, Hauer | Giftdrüse, Panzerplatten | Spinnendrüse, Spinnseide | Fledermausflügel | Knochen | Säure |

### wirtschaft.tiere_beruhigen

Herkunft: N 8 und Entscheidung 58: vor dem Kampf, gelingt es, dreht das Tier ab, Erfahrung wie fuer einen Sieg; je hoeher der Rang, desto staerkere Tiere. Zahlen A: Chance wie Trefferchance mit Basis 50 gegen die Wachsamkeit des Tiers; misslingt es, schlaegt das Tier zuerst

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `arten` | Riesenratte, Wolf, Wildschwein, Riesenfledermaus | – | Sim. |
| `chance_basis` | 50 | – | Sim. |
| `chance_je_punkt` | 0,5 | – | Sim. |
| `chance_min` | 5 | – | Sim. |
| `chance_max` | 95 | – | Sim. |
| `rang_bis_tierstufe` | (24, 2), (49, 4) | Anfaenger (bis 24) beruhigt Tiere bis Stufe 2, Geselle (bis 49) bis Stufe 4 | Sim. |

### wirtschaft.abnutzung

Herkunft: N 11: Zustaende Makellos, Benutzt, Beschaedigt, Defekt; Leistung sinkt; defekt wirkt nicht; gegen viel schwaechere Gegner kaum Abnutzung. Zahlen A

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `waffe_je_treffer` | 1 | Zustandspunkte (von 100) je eigenem Treffer (Waffe), je erlittenem Treffer (Ruestung, Schild), je Abwehr mit dem Schild | Sim. |
| `ruestung_je_treffer` | 1 | – | Sim. |
| `schild_je_abwehr` | 1 | – | Sim. |
| `faktor_teiler` | 5 | x (1 + (Gegnerstufe - Heldenstufe) / 5), 0,05 bis 1,5 | Sim. |
| `faktor_min` | 0,05 | – | Sim. |
| `faktor_max` | 1,5 | – | Sim. |

| Eintrag | Makellos | Benutzt | Beschädigt | Defekt |
|---|---|---|---|---|
| zustand_ab | 90 | 50 | 1 | 0 |
| leistung | 1 | 0,95 | 0,75 | 0 |

### wirtschaft.reparatur

Herkunft: N 11: beim Handwerker gegen Gold (Ruf nicht gerechnet), selbst mit Material und Rang; Zahlen A

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `handwerker_anteil` | 0,5 | von 0 auf 100 kostet die Haelfte des Ladenpreises, anteilig | Sim. |
| `selbst_anteil` | 0,2 | Material: ein Fuenftel des Ladenpreises, anteilig; braucht die Fertigkeit des Materials mit Rang wie N 11 | Sim. |

| Eintrag | Anfänger | Geselle | Meister |
|---|---|---|---|
| rang_ab | 1 | 25 | 50 |

### wirtschaft.ausruestung

Herkunft: Startausruestung je Waffen- und Ruestungsart: Gegenstand, Ladenpreis alt (Katalog 458), Material und Reparaturrang nach N 11 (A)

Gelesen in: Sim.

- **holz:** A: Boegen repariert der Schmied (Geselle), N 11 nennt Boegen beim Gesellen ohne Werkstoff

#### wirtschaft.ausruestung.Einhänder

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ding` | Langschwert | – | `skripte/spiel.gd:770`, `skripte/spiel.gd:778`, +9, Sim. |
| `preis` | 15 | – | Sim. |
| `material` | Metall | – | Sim. |
| `rang` | Geselle | – | Sim. |

#### wirtschaft.ausruestung.Bogen

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ding` | Kurzbogen | – | `skripte/spiel.gd:770`, `skripte/spiel.gd:778`, +9, Sim. |
| `preis` | 25 | – | Sim. |
| `material` | Holz | – | Sim. |
| `rang` | Geselle | – | Sim. |

#### wirtschaft.ausruestung.Dolche

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ding` | Dolch | – | `skripte/spiel.gd:770`, `skripte/spiel.gd:778`, +9, Sim. |
| `preis` | 2 | – | Sim. |
| `material` | Metall | – | Sim. |
| `rang` | Anfänger | – | Sim. |

#### wirtschaft.ausruestung.Stumpfe Waffen

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ding` | Streitkolben | – | `skripte/spiel.gd:770`, `skripte/spiel.gd:778`, +9, Sim. |
| `preis` | 5 | – | Sim. |
| `material` | Metall | – | Sim. |
| `rang` | Anfänger | – | Sim. |

#### wirtschaft.ausruestung.Mittlere Rüstung

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ding` | Kettenhemd | – | `skripte/spiel.gd:770`, `skripte/spiel.gd:778`, +9, Sim. |
| `preis` | 50 | – | Sim. |
| `material` | Metall | – | Sim. |
| `rang` | Geselle | – | Sim. |

#### wirtschaft.ausruestung.Leichte Rüstung

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ding` | Lederrüstung | – | `skripte/spiel.gd:770`, `skripte/spiel.gd:778`, +9, Sim. |
| `preis` | 10 | – | Sim. |
| `material` | Leder | – | Sim. |
| `rang` | Anfänger | – | Sim. |

#### wirtschaft.ausruestung.Schild

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `ding` | Schild | – | `skripte/spiel.gd:770`, `skripte/spiel.gd:778`, +9, Sim. |
| `preis` | 10 | – | Sim. |
| `material` | Metall | – | Sim. |
| `rang` | Geselle | – | Sim. |

#### wirtschaft.ausruestung.material_fertigkeit

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `Metall` | Schmieden | – | – |
| `Leder` | Lederarbeit | – | – |
| `Stoff` | Lederarbeit | – | – |
| `Holz` | Schmieden | – | – |

### wirtschaft.traenke

Herkunft: Wirkung im BRS ohne Zahl (A); alt heilt der Heiltrank 2W4+2, der grosse 4W4+4; Preis alt

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `trinken_unter` | 0,35 | A: Held trinkt statt anzugreifen, wenn Leben unter 35 % (erst den kleinen, dann den grossen) | Sim. |
| `vorrat_ziel` | 3 | A: im Dorf kauft er Heiltraenke bis 3 im Beutel, wenn das Gold reicht | Sim. |
| `brauen_kosten` | 8 | A: wer Alchemie hat, braut den Heiltrank selbst statt zu kaufen; Kraeuter fuer 8 Gold (2 x 'herbs' alt zum halben Preis), uebt Alchemie | Sim. |

| Eintrag | heilung |
|---|---|
| Heiltrank | 12 |
| Großer Heiltrank | 30 |

## fortschritt

- **Herkunft der Zahlen:** A: Held kaempft Zufallsbegegnungen seines Gebiets; Leben und Mana voll vor jedem Kampf; Niederlage ohne Erfahrung, er macht weiter; Erfahrungstopf, Quests, Hauptquest nicht gerechnet
- **Gelesen von:** `tools/sim444/sim.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `gegner_band_unten` | 2 | Gegnerstufe von Heldenstufe - 2 bis Heldenstufe + 1, gleich verteilt ueber die Arten (ohne Bosse) | Sim. |
| `gegner_band_oben` | 1 | – | Sim. |
| `max_kaempfe` | 2000 | – | Sim. |

## erschaffung

- **Regel** (`DESIGN-BRS.md` „Heldenerschaffung“): der Spieler verteilt 9 Punkte, kein Wert über 8 (933 A, 11.11.; gleiche Rechnung wie Entscheidung 77: Start 1, 21 Punkte, 12 für die Untergrenze 3 gebunden), etwa Wille 8, Verstand 6, Zähigkeit 4, sonst 3.
- **Herkunft der Zahlen:** 470 (Abnahme 1.1): N 2 'Heldenerschaffung', E 68-72, 77, 78; die Simulation rechnet die Voelker nicht. Grenzen 3 bis 8 und Startwert der Fertigkeiten stehen unter 'held'; die Herkunft verteilt 'plus' und 'plus_variante' vor (zusammen die 9 freien Punkte, Spalte '21' der Simulation)
- **Gelesen von:** `regeln/brs_fertigkeit.gd`, `regeln/brs_held.gd`, `regeln/brs_kampf.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `grundwerte` | kraft, gewandtheit, zaehigkeit, verstand, wille, wahrnehmung | – | `regeln/brs_held.gd:96`, `regeln/brs_held.gd:503`, +1 |
| `start` | 1 | – | `regeln/brs_held.gd:107`, `regeln/brs_held.gd:411` |
| `punkte` | 21 | E 77: jeder Grundwert beginnt bei 1, 21 Punkte, danach jeder zwischen 3 und 8 (12 gebunden, 9 frei) | `regeln/brs_held.gd:107` |
| `volk_max` | 9 | E 78: das Volk hebt bis 9, senkt nie unter 3 | `regeln/brs_held.gd:163` |
| `volk_min` | 3 | – | `regeln/brs_held.gd:164` |
| `wanderer_fertigkeiten` | 2 | – | `regeln/brs_held.gd:190` |
| `nicht_waehlbar` | Bergbau | – | `regeln/brs_held.gd:197`, `regeln/brs_held.gd:202`, +1 |

### erschaffung.voelker

Gelesen in: `regeln/brs_held.gd:97`, `regeln/brs_held.gd:143`, +3

- **voelker:** E 72: Mensch +1 frei und eine Startfertigkeit mehr (Wandelbar); sonst je +1, +1, -1 und ein Merkmal

| Eintrag | plus | frei | fertigkeit_extra | merkmal |
|---|---|---|---|---|
| Mensch | – | 1 | 1 | Wandelbar |
| Elf | gewandtheit 1; wahrnehmung 1; zaehigkeit -1 |  |  | Wachsame Sinne |
| Zwerg | zaehigkeit 1; verstand 1; gewandtheit -1 |  |  | Steinblut |
| Hügelvolk | gewandtheit 1; wille 1; kraft -1 |  |  | Glückskind |
| Orkblütiger | kraft 1; zaehigkeit 1; wille -1 |  |  | Letzter Atemzug |

### erschaffung.fertigkeiten

Gelesen in: `regeln/brs_fertigkeit.gd:127`, `regeln/brs_held.gd:186`, +3

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `Waffen` | Einhänder, Zweihänder, Stangenwaffen, Stumpfe Waffen, Dolche, Faustkampf, Schild, Bogen, Armbrust, Wurfwaffen | – | – |
| `Rüstung` | Leichte Rüstung, Mittlere Rüstung, Schwere Rüstung, Ausweichen | – | – |
| `Schatten` | Schleichen, Spähen, Schlösser knacken, Fallen entschärfen | – | – |
| `Magie` | Evokation, Schutzmagie, Heilmagie, Illusion, Beschwörung | – | – |
| `Wildnis` | Tiere beruhigen | – | – |
| `Gesellschaft` | Überreden, Einschüchtern, Handeln | – | – |
| `Sammeln` | Kräutersammeln, Bergbau, Angeln, Jagd | – | – |
| `Meisterschaften` | Schmieden, Lederarbeit, Alchemie, Kochen, Runenkunde, Heilkunde | – | – |

- **fertigkeiten:** N 3: 37 Fertigkeiten in acht Gruppen; Bergbau zeigt sich ab Kapitel 2 (461c), zur Wahl erst dann

## kampftraenke

- **Herkunft der Zahlen:** 481.1 (Jerry 02.11.): Vorschlag Sokrates (Zu 481, Chat 18:58): Kampftraenke mit Preis, je ein Zug, Wirkung nach Kraeuterkunde statt Sperre; seit 876 (857a A, Chef 10.11.) nach Alchemie; Chef 18:55 'zwei Runden unverwundbar'. Alle Zahlen A
- **Gelesen von:** `regeln/mars.gd`, `tools/sim444/sim.py`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wirkung_grund` | 0,5 | A: Wirkung = 0,5 + 0,05 x Alchemie (857a A), hoechstens 2: ohne Alchemie 0,5 (halbe Wirkung statt Gift), Startwert 10 = 1, Decke Kapitel 1 (24) = 1,7, ab 30 = 2 | `regeln/mars.gd:1467`, Sim. |
| `wirkung_je_alchemie` | 0,05 | – | Sim. |
| `wirkung_max` | 2 | – | `regeln/mars.gd:1467`, Sim. |
| `heiltraenke` | 2 | – | Sim. |
| `proben_alchemie` | 10, 24, 30 | – | Sim. |
| `alchemie_decke` | 24 | Spalte 'Alch. 24': wer mit Alchemie beginnt, hat sie bis zur Decke von Kapitel 1 geuebt (Sammeln ist nicht gerechnet) | Sim. |

### kampftraenke.satz

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `Steinhaut` | 1 | – | Sim. |
| `Berserkertrank` | 1 | – | Sim. |
| `Alchemistenfeuer` | 2 | – | Sim. |

### kampftraenke.proben

Gelesen in: `regeln/mars.gd:525`, Sim.

| Eintrag | Steinhaut | Berserkertrank | Alchemistenfeuer |
|---|---|---|---|
| Satz wie oben | 1 | 1 | 2 |
| 2 Steinhaut, 1 Berserker, 4 Feuer | 2 | 1 | 4 |
| 6 Feuer |  |  | 6 |

### kampftraenke.Steinhaut

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `preis` | 40 | – | Sim. |
| `runden` | 2 | – | `regeln/mars.gd:1330`, Sim. |
| `schutz` | 0,5 | – | Sim. |

- **steinhaut:** A: zwei Runden kommt Schaden x (1 - 0,5 x Wirkung) an; Wirkung 2 = unverwundbar (Chef 18:55)

### kampftraenke.Berserkertrank

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `preis` | 40 | – | Sim. |
| `runden` | 3 | – | `regeln/mars.gd:1330`, Sim. |
| `schaden_plus` | 0,5 | – | Sim. |

- **berserker:** A: drei Runden Waffenschaden x (1 + 0,5 x Wirkung); nicht fuer Zauber

### kampftraenke.Alchemistenfeuer

Gelesen in: Sim.

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schaden` | 10 | – | `regeln/mars.gd:932`, `regeln/mars.gd:956`, +9, Sim. |
| `fertigkeit` | Wurfwaffen | – | `regeln/mars.gd:507`, `regeln/mars.gd:633`, Sim. |
| `typ` | feuer | – | `regeln/mars.gd:945`, `regeln/mars.gd:1469`, +6, Sim. |

- **feuer:** A: geworfen (Treffer mit Wurfwaffen und Wahrnehmung), Grundschaden 10 x Wirkung, Feuer; Preis aus 'wirtschaft'; geworfen, wenn sein Grundschaden den der Waffe oder des Zaubers uebersteigt

### kampftraenke.Weihwasser

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `schaden` | 10 | – | `regeln/mars.gd:932`, `regeln/mars.gd:956`, +9, Sim. |
| `fertigkeit` | Wurfwaffen | – | `regeln/mars.gd:507`, `regeln/mars.gd:633`, Sim. |
| `typ` | licht | – | `regeln/mars.gd:945`, `regeln/mars.gd:1469`, +6, Sim. |
| `nur_untote` | ja | – | `regeln/mars.gd:886` |

- **weih:** 870.6 A: wie Alchemistenfeuer (alt beide 2W6), Licht, wirkt nur gegen Untote (Homer 870.15); Preis aus 'wirtschaft'

## kampftasche

- **Herkunft der Zahlen:** 532, 935 (Jerry 11.11.; alt ItemKind POTION, BOMB, Battle.useItem): was der Held im Kampf aus der Tasche nimmt; trinken (Heilung: welt heilung), werfen (Ding -> Eintrag in kampftraenke), heilt_zustaende: nimmt alle Zustaende ausser dem Rausch
- **Gelesen von:** `regeln/tabellen.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `trinken` | potion, greater_potion, superior_potion, remedy | – | `regeln/tabellen.gd:54` |
| `heilt_zustaende` | remedy | – | `regeln/tabellen.gd:56` |

| Eintrag | alchemist_fire | holy_water |
|---|---|---|
| werfen | Alchemistenfeuer | Weihwasser |

## welt

- **Herkunft der Zahlen:** 870.4 (Tom 11.11., LISTE-UMZUG-BRS.md Schritt 4): die Welt nach dem BRS statt nach dem SRD (Heldwerte entfallen). Alle Zahlen A als Uebergang, so gewaehlt, dass sich wenig aendert (Leben nach BRS sind auf Stufe 1 etwa doppelt so gross wie die alten TP); Vorentscheid Sokrates erbeten (783 W5), Messung 444, Vorlage an den Chef vor B1
- **Gelesen von:** `regeln/brs_held.gd`, `regeln/mars.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `essen_je_kochen` | 0,2 | A: eine Mahlzeit heilt dazu 0,2 Leben je Punkt Kochen (alt: Modifikator Konstitution) | `skripte/laden.gd:26` |
| `handeln_je_punkt` | 0,002 | A: kaufen je Punkt Handeln 0,2 % billiger, verkaufen 0,2 % teurer (Handeln 100: 20 %, wie alt hoechstens Charisma +4); Ruf spaeter | `skripte/laden.gd:14`, `skripte/laden.gd:15` |
| `brauen_je_alchemie` | 0,01 | A: Chance auf einen Trank mehr bei Morwens Sud je Punkt Alchemie 1 % (alt 10 % je Punkt Mod(INT)) | `skripte/laden.gd:19` |
| `kraut_je_kraeutersammeln` | 0,01 | A: Chance auf ein Kraut mehr: 1 % je Punkt Kraeutersammeln (875) und 5 % je Punkt Wahrnehmung ueber 3 (alt 15 % je Punkt Mod(WEI)) | `skripte/laden.gd:23` |
| `kraut_je_wahrnehmung` | 0,05 | – | `skripte/laden.gd:24` |
| `kraut_wahrnehmung_ab` | 3 | – | `skripte/laden.gd:24` |
| `bemerken_felder` | 4 | – | `regeln/brs_held.gd:323` |
| `bemerken_je_gewandtheit` | 0,2 | – | `regeln/brs_held.gd:322` |
| `bemerken_min` | 2 | – | `regeln/brs_held.gd:323` |
| `hinterhalt_je_wahrnehmung` | 0,075 | – | `regeln/brs_held.gd:328` |
| `hinterhalt_min` | 0,4 | – | `regeln/brs_held.gd:328` |
| `sinne_ab` | 3 | A: Monster bemerken den Helden aus bemerken_felder, je Punkt Gewandtheit ueber sinne_ab ein Fuenftelfeld spaeter (abgerundet, Gewandtheit 8: ein Feld), mindestens bemerken_min (alt je zwei Punkte Mod(GES) ein Feld); Hinterhalt je Punkt Wahrnehmung ueber sinne_ab 7,5 % seltener, hoechstens bis 40 % (alt 15 % je Punkt Mod(WEI)) | `regeln/brs_held.gd:322`, `regeln/brs_held.gd:328` |
| `wissen_verstand_ab` | 6 | 870d Vorentscheid Sokrates (11.11., 02:00): Schwaechen und Staerken der Gegner vorher sehen ab Verstand 6 (alt INT 12) | `regeln/brs_held.gd:317` |
| `leiden_zaehigkeit_ab` | 5 | A: Gift und Blutung aus einem Kampf klingen je Punkt Zaehigkeit ueber 5 eine Runde frueher ab (alt Mod(KON)) | `skripte/spiel.gd:659` |

### welt.heilung

Gelesen in: `regeln/mars.gd:1483`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `potion` | 14 | – | – |
| `greater_potion` | 28 | – | – |
| `superior_potion` | 56 | – | – |
| `remedy` | 5 | – | – |
| `roast_meat` | 14 | – | – |

### welt.verband

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `grund` | 5 | – | – |
| `je_heilkunde` | 0,2 | – | – |
| `uebung` | 1 | – | – |

### welt.ausdauer

Gelesen in: `regeln/brs_held.gd:307`, `regeln/brs_held.gd:314`, +2

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `sekunden` | 6 | – | `regeln/brs_held.gd:308` |
| `je_punkt` | 0,5 | – | `regeln/brs_held.gd:308`, `regeln/mars.gd:539`, +2 |
| `mitte` | 10 | – | `regeln/brs_held.gd:308` |
| `je_zwei_stufen` | 1 | – | `regeln/brs_held.gd:309` |
| `min` | 2 | – | `regeln/brs_held.gd:310`, `regeln/mars.gd:541` |
| `schwer_kraft` | 7 | – | `regeln/brs_held.gd:314` |

### welt.gebiet

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `forest` | Wald | – | – |
| `deep_forest` | Tiefer Wald | – | – |
| `cave` | Höhle | – | – |

### welt.start

Gelesen in: `regeln/brs_held.gd:107`, `regeln/brs_held.gd:411`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `Wachsoldat` | longsword, chain_shirt, round_shield | – | – |
| `Jägerkind` | shortbow, leather | – | – |
| `Zauberlehrling` | quarterstaff, robe | – | – |
| `Klosterschüler` | quarterstaff, leather | – | – |
| `Kräutersammler` | dagger, leather | – | – |
| `Schmiedelehrling` | quarterstaff, leather | – | – |
| `Herumtreiber` | dagger, leather | – | – |
| `Wanderer` | shortsword, leather | – | `regeln/brs_held.gd:19` |

## zustaende

- **Herkunft der Zahlen:** 870.6 (Zu 870.6 von Tom 11.11., 02:13; Sokrates 20:05): was im Kampf noch in Wuerfeln der alten Fassung rechnete (Gift, Brand, Blutung, Schwaechung, Saettigung, Sammeln des Schamanen, Untotenzaehigkeit) nach dem BRS, ohne Massstab der alten Trefferpunkte. Alle Zahlen A, bis 444 sie misst (dann Chef)
- **Gelesen von:** `regeln/mars.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `sammeln_anteil` | 0,28 | A: Grak heilt sich beim Sammeln um diesen Anteil seines vollen Lebens (alt 2W10 gegen 6W10+6 Trefferpunkte, im Mittel 11 von 39 = 28 %; 0,5 nahm 444 bis 11 Punkte bei Stufe 5, 870.6 Tuffy 11.11.) | `regeln/mars.gd:1639` |

### zustaende.schaden_anteil

Gelesen in: `regeln/mars.gd:1563`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `POISON` | 0,08 | – | `regeln/mars.gd:98`, `regeln/mars.gd:110`, +8 |
| `BURN` | 0,1 | – | `regeln/mars.gd:99`, `regeln/mars.gd:111`, +4 |
| `BLEED` | 0,06 | – | `regeln/mars.gd:100`, `regeln/mars.gd:112`, +6 |

### zustaende.treffer

Gelesen in: `regeln/mars.gd:1349`, `regeln/mars.gd:1352`, +4

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `SLOW` | -10 | – | `regeln/mars.gd:102`, `regeln/mars.gd:114`, +2 |
| `WEAK` | -10 | – | `regeln/mars.gd:103`, `regeln/mars.gd:115`, +4 |
| `satt` | 5 | – | `regeln/mars.gd:2114`, `regeln/mars.gd:2129` |

### zustaende.schaden_faktor

Gelesen in: `regeln/mars.gd:1347`, `regeln/mars.gd:1349`, +2

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `WEAK` | 0,8 | – | `regeln/mars.gd:103`, `regeln/mars.gd:115`, +4 |
| `satt` | 1,1 | – | `regeln/mars.gd:2114`, `regeln/mars.gd:2129` |

### zustaende.untot_zaeh

Gelesen in: `regeln/mars.gd:568`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `basis` | 95 | – | `regeln/mars.gd:539`, `regeln/mars.gd:569` |
| `je_prozent` | 1,1 | – | `regeln/mars.gd:569` |

## gegenstaende

- **Regel** (`DESIGN-BRS.md` „11. Ausrüstung: Seltenheit, Abnutzung und Reparatur“): Seltenheitsdecke je Kapitel (644 C2): in Kapitel 1 als Beute höchstens ungewöhnlich, Bosse und besondere Funde höchstens selten
- **Herkunft der Zahlen:** 870.6 (N 11, 870a 6 A, 644 B und C): was beim Fund gewuerfelt wird (godot/skripte/beute.gd). Seltenheiten, Gewichte, Decken, Mindeststufen, Preisfaktoren: Startwerte der alten Fassung (Loot.kt, beute.gd); Guete, Werte und Deckel der Zusatzeigenschaften, Gewichtung nach Fertigkeiten: A, bis 444 sie misst (dann Chef)
- **Gelesen von:** `regeln/brs_held.gd`, `skripte/beute.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `seltenheiten` | COMMON, UNCOMMON, RARE, VERY_RARE, EPIC, DIVINE | – | – |
| `kapitel1_ungewoehnlich_ab_stufe` | 2 | – | `skripte/beute.gd:56` |
| `kapitel1_ungewoehnlich_promille` | 150 | – | `skripte/beute.gd:57` |
| `beute_chance` | 0,38 | Chance, dass ein gewoehnlicher Gegner ein Stueck fallen laesst (Loot.drops); Bosse eins der Decke 'besonders' ab selten und 0 bis 2 weitere, Elite eins ab ungewoehnlich | `skripte/beute.gd:160` |
| `preis_grund_plus` | 10 | – | `skripte/beute.gd:254` |
| `preis_je_stufe` | 0,2 | – | `skripte/beute.gd:254` |
| `guete` | Normal, Gut, Meisterhaft | A: Guete beim Fund (gewoehnliche Beute, Bosse und besondere Funde); in Kapitel 1 als gewoehnliche Beute hoechstens Gut; Haendler verkaufen Normal; Einzelstuecke fest. Alt 'plus' (+1 ab selten) geht in Guete auf (870a 6 A) | `regeln/brs_held.gd:413`, `regeln/brs_held.gd:453`, +8 |
| `guete_faktor` | 1, 1,15, 1,3 | A: Faktor auf den Grundschaden der Waffe und den Schutzwert von Ruestung und Schild (N 11 'hebt die Werte der Grundform') | `regeln/brs_held.gd:469`, `regeln/brs_held.gd:477`, +5 |
| `guete_preis` | 1, 1,5, 2,5 | – | `skripte/beute.gd:253` |
| `guete_gewicht_beute` | 85, 12, 3 | – | `skripte/beute.gd:70` |
| `guete_gewicht_besonders` | 50, 35, 15 | – | `skripte/beute.gd:70` |
| `guete_decke_kapitel1` | Gut | – | `skripte/beute.gd:72` |
| `fertigkeit_grund` | 10 | A (870a 6, kein Klassenfilter): Beute nach den Fertigkeiten des Helden gewichtet: Gewicht je Grundform = fertigkeit_grund + Wert der Fertigkeit, die sie braucht (Waffengruppe, Ruestung, Schild); ohne Fertigkeit fertigkeit_grund + fertigkeit_grund | `skripte/beute.gd:124` |

### gegenstaende.zusatzzahl

Gelesen in: `skripte/beute.gd:22`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `COMMON` | 0 | – | `regeln/brs_held.gd:413`, `skripte/beute.gd:12`, +8 |
| `UNCOMMON` | 1 | – | `skripte/beute.gd:12`, `skripte/beute.gd:58`, +4 |
| `RARE` | 2 | – | `skripte/beute.gd:12`, `skripte/beute.gd:156` |
| `VERY_RARE` | 3 | – | `skripte/beute.gd:12` |
| `EPIC` | 4 | – | `skripte/beute.gd:12`, `skripte/beute.gd:273` |
| `DIVINE` | 5 | – | `skripte/beute.gd:12`, `skripte/beute.gd:40`, +1 |

### gegenstaende.gewicht

Gelesen in: `regeln/brs_held.gd:265`, `skripte/beute.gd:43`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `COMMON` | 560 | – | `regeln/brs_held.gd:413`, `skripte/beute.gd:12`, +8 |
| `UNCOMMON` | 270 | – | `skripte/beute.gd:12`, `skripte/beute.gd:58`, +4 |
| `RARE` | 115 | – | `skripte/beute.gd:12`, `skripte/beute.gd:156` |
| `VERY_RARE` | 40 | – | `skripte/beute.gd:12` |
| `EPIC` | 12 | – | `skripte/beute.gd:12`, `skripte/beute.gd:273` |
| `DIVINE` | 3 | – | `skripte/beute.gd:12`, `skripte/beute.gd:40`, +1 |

### gegenstaende.mindeststufe

Gelesen in: `skripte/beute.gd:30`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `EPIC` | 3 | – | `skripte/beute.gd:12`, `skripte/beute.gd:273` |
| `DIVINE` | 5 | – | `skripte/beute.gd:12`, `skripte/beute.gd:40`, +1 |

### gegenstaende.decke_beute

Gelesen in: `skripte/beute.gd:36`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `1` | UNCOMMON | – | – |
| `2` | RARE | – | – |
| `3` | VERY_RARE | – | – |
| `sonst` | EPIC | – | `skripte/beute.gd:34` |

### gegenstaende.decke_besonders

Gelesen in: `skripte/beute.gd:37`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `1` | RARE | – | – |
| `2` | VERY_RARE | – | – |
| `3` | EPIC | – | – |
| `4` | EPIC | – | – |
| `sonst` | DIVINE | – | `skripte/beute.gd:34` |

### gegenstaende.preis_faktor

Gelesen in: `skripte/beute.gd:253`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `COMMON` | 1 | – | `regeln/brs_held.gd:413`, `skripte/beute.gd:12`, +8 |
| `UNCOMMON` | 3 | – | `skripte/beute.gd:12`, `skripte/beute.gd:58`, +4 |
| `RARE` | 8 | – | `skripte/beute.gd:12`, `skripte/beute.gd:156` |
| `VERY_RARE` | 20 | – | `skripte/beute.gd:12` |
| `EPIC` | 50 | – | `skripte/beute.gd:12`, `skripte/beute.gd:273` |
| `DIVINE` | 150 | – | `skripte/beute.gd:12`, `skripte/beute.gd:40`, +1 |

### gegenstaende.zusatz

Gelesen in: `regeln/brs_held.gd:81`, `regeln/brs_held.gd:454`, +5

#### gegenstaende.zusatz.STR

Gelesen in: `regeln/brs_held.gd:63`, `regeln/brs_held.gd:70`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `grundwert` | kraft | – | `regeln/brs_held.gd:250`, `regeln/brs_held.gd:487` |

#### gegenstaende.zusatz.DEX

Gelesen in: `regeln/brs_held.gd:63`, `regeln/brs_held.gd:70`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `grundwert` | gewandtheit | – | `regeln/brs_held.gd:250`, `regeln/brs_held.gd:487` |

#### gegenstaende.zusatz.CON

Gelesen in: `regeln/brs_held.gd:64`, `regeln/brs_held.gd:70`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `grundwert` | zaehigkeit | – | `regeln/brs_held.gd:250`, `regeln/brs_held.gd:487` |

#### gegenstaende.zusatz.INT

Gelesen in: `regeln/brs_held.gd:64`, `regeln/brs_held.gd:71`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `grundwert` | verstand | – | `regeln/brs_held.gd:250`, `regeln/brs_held.gd:487` |

#### gegenstaende.zusatz.WIS

Gelesen in: `regeln/brs_held.gd:64`, `regeln/brs_held.gd:71`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `grundwert` | wahrnehmung | – | `regeln/brs_held.gd:250`, `regeln/brs_held.gd:487` |

#### gegenstaende.zusatz.CHA

Gelesen in: `regeln/brs_held.gd:65`, `regeln/brs_held.gd:71`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `grundwert` | wille | – | `regeln/brs_held.gd:250`, `regeln/brs_held.gd:487` |

#### gegenstaende.zusatz.AC

Gelesen in: `regeln/brs_held.gd:66`, `regeln/brs_held.gd:303`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `wert2_ab_stufe` | 4 | – | `skripte/beute.gd:97` |

#### gegenstaende.zusatz.HP

Gelesen in: `regeln/brs_held.gd:66`, `regeln/brs_held.gd:231`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 5 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |

#### gegenstaende.zusatz.SP

Gelesen in: `regeln/brs_held.gd:66`, `regeln/brs_held.gd:232`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 5 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |

#### gegenstaende.zusatz.CRIT

Gelesen in: `regeln/brs_held.gd:67`, `regeln/brs_held.gd:243`, +2

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 3 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `prozent` | ja | – | `regeln/brs_held.gd:80`, `regeln/brs_held.gd:85`, +1 |

#### gegenstaende.zusatz.SPELL

Gelesen in: `regeln/brs_held.gd:67`, `regeln/brs_held.gd:357`, +1

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 10 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `prozent` | ja | – | `regeln/brs_held.gd:80`, `regeln/brs_held.gd:85`, +1 |

#### gegenstaende.zusatz.TENACITY

Gelesen in: `regeln/brs_held.gd:68`, `regeln/brs_held.gd:75`, +3

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 5 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `prozent` | ja | – | `regeln/brs_held.gd:80`, `regeln/brs_held.gd:85`, +1 |

#### gegenstaende.zusatz.SKILL

Gelesen in: `regeln/brs_held.gd:78`, `regeln/brs_held.gd:79`, +5

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `wert` | 1 | – | `regeln/brs_held.gd:284`, `regeln/brs_held.gd:301`, +2 |
| `wert2_ab_stufe` | 6 | – | `skripte/beute.gd:97` |
| `ab_seltenheit` | EPIC | – | `skripte/beute.gd:90` |

### gegenstaende.deckel

Gelesen in: `regeln/brs_held.gd:344`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `STR` | 1, 0 | – | `regeln/brs_held.gd:63`, `regeln/brs_held.gd:70`, +1 |
| `DEX` | 1, 0 | – | `regeln/brs_held.gd:63`, `regeln/brs_held.gd:70`, +1 |
| `CON` | 1, 0 | – | `regeln/brs_held.gd:64`, `regeln/brs_held.gd:70`, +1 |
| `INT` | 1, 0 | – | `regeln/brs_held.gd:64`, `regeln/brs_held.gd:71`, +1 |
| `WIS` | 1, 0 | – | `regeln/brs_held.gd:64`, `regeln/brs_held.gd:71`, +1 |
| `CHA` | 1, 0 | – | `regeln/brs_held.gd:65`, `regeln/brs_held.gd:71`, +1 |
| `AC` | 1, 1 | – | `regeln/brs_held.gd:66`, `regeln/brs_held.gd:303`, +1 |

### gegenstaende.erlaubt

Gelesen in: `skripte/beute.gd:81`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `WAFFE` | STR, DEX, CRIT | – | `skripte/beute.gd:86` |
| `FERNWAFFE` | DEX, WIS, CRIT | – | `skripte/beute.gd:86` |
| `FOKUS` | CHA, INT, SPELL, SP, CRIT | – | `skripte/beute.gd:85` |
| `SHIELD` | AC, HP, CON, STR, TENACITY | – | `regeln/brs_held.gd:273`, `regeln/brs_held.gd:283`, +3 |
| `HEAD` | STR, DEX, CON, INT, WIS, CHA, AC, HP, SP, SPELL, TENACITY | – | `skripte/beute.gd:11` |
| `CHEST` | AC, HP, STR, DEX, CON, TENACITY | – | `regeln/brs_held.gd:261`, `regeln/brs_held.gd:275`, +5 |
| `ARMS` | STR, DEX, CRIT, AC | – | `skripte/beute.gd:11` |
| `LEGS` | DEX, CON, AC, HP, TENACITY | – | `skripte/beute.gd:11` |
| `CLOAK` | AC, TENACITY, DEX, CHA, HP | – | `skripte/beute.gd:11` |
| `AMULET` | STR, DEX, CON, INT, WIS, CHA, SPELL, HP, SP, TENACITY | – | `skripte/beute.gd:11` |
| `RING` | STR, DEX, CON, INT, WIS, CHA, CRIT, SPELL, SP | – | `skripte/beute.gd:11`, `skripte/beute.gd:88` |

### gegenstaende.einzelstuecke

Gelesen in: `skripte/beute.gd:176`, `skripte/beute.gd:264`

| Eintrag | grundform | seltenheit | guete | zusatz |
|---|---|---|---|---|
| ring_protection | ring | RARE | 0 | (AC, 1), (HP, 5) |
| gauntlets_ogre | gloves | RARE | 0 | (STR, 1), (CRIT, 3) |
| greataxe_grak | greataxe | RARE | 2 | (STR, 1), (CRIT, 3) |
| longsword_oakford | longsword | RARE | 2 | (STR, 1), (HP, 5) |
| staff_of_embers | staff | RARE | 2 | (CHA, 1), (SPELL, 10) |
| rapier_whisper | dagger | RARE | 2 | (DEX, 1), (CRIT, 3) |
| mace_of_dawn | mace | RARE | 2 | (STR, 1), (SPELL, 10) |
| amulet_grimfang | amulet | RARE | 0 | (DEX, 1), (CRIT, 3), (HP, 5) |
| cloak_protection | cloak | RARE | 0 | (AC, 1), (TENACITY, 5) |
| cloak_thessa | cloak | UNCOMMON | 0 | (TENACITY, 5) |
| dagger_borin | dagger | UNCOMMON | 0 | (CRIT, 3) |
| greatsword_nameless | greatsword | RARE | 2 | (STR, 1), (CRIT, 3) |
| spear_wolf | spear | RARE | 2 | (STR, 1), (HP, 5) |
| longbow_blackyew | longbow | RARE | 2 | (DEX, 1), (CRIT, 3) |
| crossbow_nightwatch | light_crossbow | RARE | 2 | (WIS, 1), (CRIT, 3) |

## monsterregeln

- **Herkunft der Zahlen:** 870.6 (LISTE-UMZUG-BRS.md 3: tabellen.json geloescht): was das Spiel je Kennung ausser den Werten (monster) braucht: Sonderregel im Kampf (MARS), Schadensart des Angriffs (Schnitt blutet, Wucht betaeubt bei kritisch), Gift im Verhaeltnis zum ueblichen (alt 1W4 gegen 1W6), immun gegen Zustaende, Gold nur, wo 'wirtschaft' 'beute' keins nennt (Bosse; Wurf gleichverteilt min bis max), Beute als Kennung der Dinge mit Chance (alt Monsters.kt; Spinnseide 870.6, A). Tierteile bleiben Beute, bis es Zerlegen im Spiel gibt
- **Gelesen von:** `regeln/tabellen.gd`

| Eintrag | sonder | typ | beute | gold | gift | immun |
|---|---|---|---|---|---|---|
| wolf | KNOCKDOWN | stich | (potion, 0,12), (raw_meat, 0,6), (wolf_pelt, 0,45) |  |  |  |
| hobgoblin_captain | MARTIAL_ADVANTAGE | schnitt | (sun_amulet, 1), (prophet_letter, 1), (grak_key, 1) | 8, 80 |  |  |
| goblin | NONE | schnitt | (potion, 0,15), (alchemist_fire, 0,06) |  |  |  |
| goblin_archer | NONE | stich | (potion, 0,15), (alchemist_fire, 0,05) |  |  |  |
| giant_spider | POISON | stich | (greater_potion, 0,15), (spider_gland, 0,6), (spider_silk, 0,5) |  | 1 |  |
| dire_wolf | KNOCKDOWN | stich | (greater_potion, 0,5), (wolf_pelt, 1), (raw_meat, 1) | 4, 40 |  |  |
| giant_rat | NONE | stich | (potion, 0,08), (raw_meat, 0,3) |  |  |  |
| giant_bat | EVASIVE | stich | (potion, 0,1), (bat_wing, 0,6) |  |  |  |
| kobold | PACK_TACTICS | stich | (potion, 0,12), (alchemist_fire, 0,04) |  |  |  |
| goblin_shaman | SHAMAN | wucht | (potion, 0,25), (greater_potion, 0,06) |  |  |  |
| boar | CHARGE | schnitt | (potion, 0,08), (raw_meat, 0,8), (boar_tusk, 0,5) |  |  |  |
| giant_centipede | POISON | stich | (potion, 0,1) |  | 0,71 |  |
| bugbear | SURPRISE_ATTACK | stich | (rusty_key, 1) | 4, 40 |  |  |
| stirge | BLOOD_DRAIN | stich | (potion, 0,06) |  |  |  |
| ochre_jelly | ACID | wucht | (greater_potion, 0,2) |  |  | BLEED, STUN, BLIND |
| skeleton | NONE | stich | (potion, 0,08), (holy_water, 0,04) |  |  | POISON, BLEED |
| zombie | UNDEAD_FORTITUDE | wucht | (potion, 0,1), (holy_water, 0,06) |  |  | POISON, BLEED |
| ghoul | PARALYZE | schnitt | (greater_potion, 0,15), (holy_water, 0,06) |  |  | POISON |

## absicht_zusatz

- **Herkunft der Zahlen:** 870.6: Zusatzschaden einer Absicht als Anteil am Schaden des Gegners (alt Wuerfel der Absicht durch Schaden des Monsters: Grak 2W6 bzw. 1W6 zu 1W10+3, Spinne 2W6 zu 1W8+3, Spaeher 1W6 zu 1W6+2)
- **Gelesen von:** `regeln/mars.gd`

| Wert | heute | Formel, Erläuterung | wirkt in |
|---|---|---|---|
| `heavy` | 0,82 | – | `regeln/mars.gd:204` |
| `breakthrough` | 0,41 | – | `regeln/mars.gd:222` |
| `venom` | 0,93 | – | `regeln/mars.gd:218`, `regeln/mars.gd:1781` |
| `aim` | 0,64 | – | `regeln/mars.gd:220` |

## kennungen

- **Regel** (`DESIGN-BRS.md` „12. Namen“): Folklore-Wesen (Goblin, Kobold, Skelett, Zombie, Ghul) und Tiere behalten ihre Namen, ebenso Mensch, Elf, Zwerg, Trefferpunkte und kritischer Treffer
- **Herkunft der Zahlen:** 870.3 (649a Schritt 1): Kennung im Spiel -> Art (Zeile in 'monster'), Anzeigename (DESIGN-BRS.md 12, STORY-BRS-OBERFLAECHE.md [870.15.namen.monster]), Gruppe; interne Kennungen bleiben. Modell und Bewegung: Figurenkatalog 649.2
- **Gelesen von:** `regeln/brs.gd`, `regeln/tabellen.gd`

| Eintrag | art | de | en | gruppe |
|---|---|---|---|---|
| giant_rat | Riesenratte | Riesenratte | Giant Rat | Tier |
| kobold | Kobold | Kobold | Kobold | Kobold |
| stirge | Blutflügler | Riesenegel | Giant Leech | Tier |
| wolf | Wolf | Wolf | Wolf | Tier |
| boar | Wildschwein | Wildschwein | Boar | Tier |
| giant_centipede | Riesen-Hundertfüßer | Riesen-Hundertfüßer | Giant Centipede | Tier |
| goblin | Goblin | Goblin | Goblin | Goblin |
| goblin_archer | Goblin-Späher | Goblin-Späher | Goblin Scout | Goblin |
| skeleton | Skelett | Skelett | Skeleton | Untoter |
| zombie | Zombie | Zombie | Zombie | Untoter |
| giant_bat | Riesenfledermaus | Riesenfledermaus | Giant Bat | Tier |
| goblin_shaman | Goblin-Schamane | Goblin-Schamane | Goblin Shaman | Goblin |
| giant_spider | Riesenspinne | Riesenspinne | Giant Spider | Tier |
| ghoul | Ghul | Ghul | Ghoul | Untoter |
| ochre_jelly | Ockerschleim | Säureschnecke | Acid Slug | Tier |
| bugbear | Krogg | Krogg der Grobian | Krogg the Brute | Bärenschrat |
| dire_wolf | Grimmzahn | Grimmzahn, der Leitwolf | Grimfang the Alpha | Tier |
| hobgoblin_captain | Grak | Hauptmann Grak | Captain Grak | Goblin-Hauptmann |
