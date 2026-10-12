# Balance (Thema 38) – Entwurf

Ziel: herausfordernd, aber nicht zu leicht, über **mindestens 7 Kapitel**, Stufe 20 am Ende. Diese Datei hält die Zielkurve fest; Messungen und Vorschläge verweisen darauf. Entwurf des Beraters (12.10.), Zahlen der Zielkurve sind Vorschläge, bis der Nutzer sie freigibt.

## Heute (Stand 12.10.)

- **Stufen:** Erfahrungsschwellen = halbes SRD (`Rules.xpForLevel`); Kapitel 1 deckelt bei Stufe 6 (`Story.CHAPTER1_LEVEL_CAP`).
- **Ausrüstung:** Deckel je Kapitel (`Rules.gearCap`): Eigenschaften, Angriff, Zauber, RK bis +Kapitel; Schaden, Feuer, Gleißend bis +Kapitel+1.
- **Gold von Gegnern** (Grundwerte, vor Stufenaufschlag): gewöhnliche 1W3–2W8, Schamane 3W6, Spinne 2W10, Ghul 2W8, Ockergallerte 3W10, Krogg 4W10, Grimmzahn 4W10, Grak 8W10. **Aufträge** (29): 40–60 G.
- **Preise:** Heiltrank 25, großer 75, sehr großer 200, Kräutertrank 20, Alchemistenfeuer 30, Weihwasser 25. Ausrüstung: (Grundpreis + 10) × Seltenheit × (1 + Gegenstandsstufe/5).
- **Messung:** `BalanceTest`, `ChapterSimTest`: einzelne Kämpfe mit Ausrüstung (Klassenwaffe, Schutzumhang ab St. 3, Amulett/Ring ab St. 5, Deckel entscheiden), jeder mit vollen TP und 2 Tränken, kein Gold, kein Einkauf. **Der Goldfluss ist ungemessen.**

## Zielkurve (Vorschlag)

| Kapitel | Stufe am Ende | Ausrüstungsdeckel (Eigenschaft / Schaden) |
|---|---|---|
| 1 | 6 (heute) | +1 / +2 |
| 2 | 8 | +2 / +3 |
| 3 | 10 | +3 / +4 |
| 4 | 12 | +4 / +5 |
| 5 | 14 | +5 / +6 |
| 6 | 17 | +6 / +7 |
| 7 | 20 | +7 / +8 |

Ab Kapitel 2 etwa zwei Stufen je Kapitel; spätere Kapitel länger als Kapitel 1. Bei mehr als 7 Kapiteln wird die Kurve flacher, nicht der Deckel lockerer.

## Ziel-Siegquoten auf „Normal“

Durchschnittlich gebauter Held, Ausrüstung im Deckel, Kämpfe hintereinander (nicht mit vollen TP):

- gewöhnliche Begegnung 85–95 %, kostet 20–40 % der TP
- Rudel und starke Gegner 70–85 %
- Vorboss 60–75 %, Kapitelboss 50–65 % (mit Vorbereitung: Tränke, Rast)
- alle vier Klassen höchstens 10 Punkte auseinander
- „Leicht“ etwa 10–15 Punkte darüber, „Schwer“ 15–20 darunter (Thema 39)

## Gold (Ziel)

- Was ein Kapitel einbringt, reicht für die Vorbereitung auf den Boss (Tränke) und ein bis zwei Ausrüstungsteile im Deckel, nicht für den halben Laden.
- Messgröße: Gold am Kapitelende ohne Einkäufe, und welcher Anteil davon für Pflicht (Tränke) gegenüber Kür (Ausrüstung) draufgeht.
- Goldsenken nur, wenn die Messung zu viel Gold zeigt; Ideen dann auf die Merkliste.

## Messplan (Jerry)

1. `ChapterSimTest` erweitern: Kapitel 1 am Stück in Story-Reihenfolge mit Zufallsbegegnungen, TP über Kämpfe hinweg, Rast wie ein Spieler, Gold zählen, einfache Einkaufsregel (Tränke auf 3–4 auffüllen, bestes bezahlbares Teil im Deckel kaufen).
2. Ausgabe je Klasse: Stufe je Abschnitt, Gold rein, raus, übrig, Siegquote Vorboss und Boss.
3. Gegen die Zielwerte oben halten; Abweichungen als Vorschläge (Gold der Gegner, Preise, Erfahrung) zur Freigabe.

## Offen

- Kapitelzahl (mindestens 7) und Länge von Kapitel 2.
- Schwierigkeitsgrad (39) baut auf dem gemessenen „Normal“ auf.
